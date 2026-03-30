import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:alarm/alarm.dart';
import '../models/alarm.dart';
import '../services/alarm_service.dart';

final alarmServiceProvider = Provider((ref) => AlarmService());

final alarmProvider = StateNotifierProvider<AlarmNotifier, List<AlarmModel>>((ref) {
  return AlarmNotifier(ref.read(alarmServiceProvider));
});

class AlarmNotifier extends StateNotifier<List<AlarmModel>> {
  final AlarmService _service;

  AlarmNotifier(this._service) : super([]) {
    _load();
  }

  void _load() {
    state = _service.getAll();
  }

  DateTime _nextAlarmTime(int hour, int minute, List<bool> repeatDays) {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    if (repeatDays.every((d) => !d)) return scheduled;
    for (int i = 0; i < 7; i++) {
      final candidate = scheduled.add(Duration(days: i));
      final weekday = candidate.weekday - 1;
      if (repeatDays[weekday]) return candidate;
    }
    return scheduled;
  }

  int _alarmId(String id) => id.hashCode.abs() % 2147483647;

  Future<void> _schedule(AlarmModel alarm) async {
    if (!alarm.isEnabled) return;
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final time = _nextAlarmTime(alarm.hour, alarm.minute, alarm.repeatDays);
    final label = alarm.label.isEmpty ? 'Alarm' : alarm.label;

    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: _alarmId(alarm.id),
        dateTime: time,
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: true,
        vibrate: true,
        fadeDuration: 3,
        notificationSettings: NotificationSettings(
          title: label,
          body: 'Time to wake up!',
          stopButton: 'Open app',
        ),
      ),
    );
  }

  Future<void> _cancel(AlarmModel alarm) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await Alarm.stop(_alarmId(alarm.id));
  }

  Future<void> add(AlarmModel alarm) async {
    await _service.save(alarm);
    await _schedule(alarm);
    _load();
  }

  Future<void> update(AlarmModel alarm) async {
    await _cancel(alarm);
    await _service.save(alarm);
    await _schedule(alarm);
    _load();
  }

  Future<void> toggle(String id) async {
    final alarm = state.firstWhere((a) => a.id == id);
    final updated = alarm.copyWith(isEnabled: !alarm.isEnabled);
    if (updated.isEnabled) {
      await _schedule(updated);
    } else {
      await _cancel(updated);
    }
    await _service.save(updated);
    _load();
  }

  Future<void> delete(String id) async {
    final alarm = state.firstWhere((a) => a.id == id);
    await _cancel(alarm);
    await _service.delete(id);
    _load();
  }
}
