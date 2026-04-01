import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/alarm.dart';
import 'alarm_history_provider.dart';
import 'app_settings_provider.dart';
import 'awake_check_provider.dart';
import '../services/app_settings_service.dart';
import '../services/awake_check_service.dart';
import '../services/alarm_history_service.dart';
import '../services/alarm_service.dart';

final alarmServiceProvider = Provider((ref) => AlarmService());

final alarmProvider = StateNotifierProvider<AlarmNotifier, List<AlarmModel>>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return AlarmNotifier(
    ref,
    ref.read(alarmServiceProvider),
    ref.read(alarmHistoryServiceProvider),
    ref.read(awakeCheckServiceProvider),
    settings,
  );
});

class AlarmNotifier extends StateNotifier<List<AlarmModel>> {
  AlarmNotifier(
    this._ref,
    this._service,
    this._historyService,
    this._awakeCheckService,
    this._settings,
  ) : super([]) {
    _load();
  }

  final Ref _ref;
  final AlarmService _service;
  final AlarmHistoryService _historyService;
  final AwakeCheckService _awakeCheckService;
  final AppSettings _settings;

  void _refreshHistory() {
    _ref.read(alarmHistoryProvider.notifier).refresh();
  }

  void _load() {
    state = _service.getAll();
  }

  Future<void> add(AlarmModel alarm) async {
    await _service.save(alarm);
    await _service.schedule(alarm);
    await _historyService.log(alarm, 'created');
    _refreshHistory();
    _load();
  }

  Future<void> update(AlarmModel alarm) async {
    await _service.cancel(alarm);
    await _service.save(alarm);
    await _service.schedule(alarm);
    await _historyService.log(alarm, 'updated');
    _refreshHistory();
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
    _refreshHistory();
    await _service.save(updated);
    _load();
  }

  Future<void> delete(String id) async {
    final alarm = state.firstWhere((a) => a.id == id);
    await _service.cancel(alarm);
    await _service.delete(id);
    await _historyService.log(alarm, 'deleted');
    _refreshHistory();
    _load();
  }

  Future<void> completeAfterDismiss(String id) async {
    final alarm = _service.getById(id);
    if (alarm == null) return;

    await _service.cancel(alarm);
    await _historyService.log(alarm, 'dismissed');
    _refreshHistory();
    await _scheduleAwakeCheck(alarm);

    if (_service.repeats(alarm)) {
      await _service.schedule(
        alarm,
        from: DateTime.now().add(const Duration(minutes: 1)),
      );
      await _historyService.log(alarm, 'rescheduled');
      _refreshHistory();
      _load();
      return;
    }

    await _service.save(alarm.copyWith(isEnabled: false));
    _load();
  }

  Future<void> _scheduleAwakeCheck(AlarmModel alarm) async {
    if (!_settings.awakeCheckEnabled) {
      return;
    }
    final entry = await _awakeCheckService.createFor(
      alarm,
      delayMinutes: _settings.awakeCheckDelayMinutes,
      windowMinutes: _settings.awakeCheckWindowMinutes,
    );
    await _awakeCheckService.schedule(entry);
    await _historyService.log(
      alarm,
      'awake_check_scheduled',
      details:
          'Follow-up in ${_settings.awakeCheckDelayMinutes} min, window ${_settings.awakeCheckWindowMinutes} min',
    );
    _refreshHistory();
  }

  Future<void> completeAwakeCheck(String alarmId) async {
    final alarm = _service.getById(alarmId);
    if (alarm == null) return;
    await _historyService.log(alarm, 'awake_check_completed');
    _refreshHistory();
  }

  Future<void> failAwakeCheck(String alarmId) async {
    final alarm = _service.getById(alarmId);
    if (alarm == null) return;
    await _service.cancel(alarm);
    await _service.schedule(
      alarm,
      at: DateTime.now().add(const Duration(seconds: 1)),
    );
    await _historyService.log(
      alarm,
      'awake_check_failed',
      details: 'Follow-up was ignored',
    );
    _refreshHistory();
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
    _refreshHistory();
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
    _refreshHistory();
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
    _refreshHistory();
    _load();
  }
}
