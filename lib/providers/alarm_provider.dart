import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/alarm.dart';
import 'alarm_history_provider.dart';
import '../services/alarm_history_service.dart';
import '../services/alarm_service.dart';

final alarmServiceProvider = Provider((ref) => AlarmService());

final alarmProvider = StateNotifierProvider<AlarmNotifier, List<AlarmModel>>((ref) {
  return AlarmNotifier(
    ref.read(alarmServiceProvider),
    ref.read(alarmHistoryServiceProvider),
  );
});

class AlarmNotifier extends StateNotifier<List<AlarmModel>> {
  AlarmNotifier(this._service, this._historyService) : super([]) {
    _load();
  }

  final AlarmService _service;
  final AlarmHistoryService _historyService;

  void _load() {
    state = _service.getAll();
  }

  Future<void> add(AlarmModel alarm) async {
    await _service.save(alarm);
    await _service.schedule(alarm);
    await _historyService.log(alarm, 'created');
    _load();
  }

  Future<void> update(AlarmModel alarm) async {
    await _service.cancel(alarm);
    await _service.save(alarm);
    await _service.schedule(alarm);
    await _historyService.log(alarm, 'updated');
    _load();
  }

  Future<void> toggle(String id) async {
    final alarm = state.firstWhere((a) => a.id == id);
    final updated = alarm.copyWith(isEnabled: !alarm.isEnabled);
    if (updated.isEnabled) {
      await _service.schedule(updated);
      await _historyService.log(updated, 'enabled');
    } else {
      await _service.cancel(updated);
      await _historyService.log(updated, 'disabled');
    }
    await _service.save(updated);
    _load();
  }

  Future<void> delete(String id) async {
    final alarm = state.firstWhere((a) => a.id == id);
    await _service.cancel(alarm);
    await _service.delete(id);
    await _historyService.log(alarm, 'deleted');
    _load();
  }

  Future<void> completeAfterDismiss(String id) async {
    final alarm = _service.getById(id);
    if (alarm == null) return;

    await _service.cancel(alarm);
    await _historyService.log(alarm, 'dismissed');

    if (_service.repeats(alarm)) {
      await _service.schedule(
        alarm,
        from: DateTime.now().add(const Duration(minutes: 1)),
      );
      await _historyService.log(alarm, 'rescheduled');
      _load();
      return;
    }

    await _service.save(alarm.copyWith(isEnabled: false));
    _load();
  }

  Future<void> snooze(
    String id, {
    Duration duration = const Duration(minutes: 10),
  }) async {
    final alarm = _service.getById(id);
    if (alarm == null) return;

    await _service.cancel(alarm);
    await _service.schedule(alarm, at: DateTime.now().add(duration));
    await _historyService.log(alarm, 'snoozed', details: '${duration.inMinutes} min');
    _load();
  }

  Future<void> silenceForMission(String id) async {
    final alarm = _service.getById(id);
    if (alarm == null) return;

    await _service.cancel(alarm);
    await _historyService.log(
      alarm,
      'mission_started',
      details: 'Quest: ${alarm.quest.type.name}',
    );
    _load();
  }

  Future<void> restartAfterMissionTimeout(String id) async {
    final alarm = _service.getById(id);
    if (alarm == null) return;

    await _service.cancel(alarm);
    await _service.schedule(
      alarm,
      at: DateTime.now().add(const Duration(seconds: 1)),
    );
    await _historyService.log(
      alarm,
      'missed',
      details:
          'Mission timer expired during ${alarm.quest.type.name} (${alarm.quest.missionSeconds}s)',
    );
    _load();
  }
}
