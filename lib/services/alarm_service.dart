import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/alarm.dart';

class AlarmService {
  static const _boxName = 'alarms';

  Future<void> init() async {
    await Hive.openBox<Map>(_boxName);
  }

  Box<Map> get _box => Hive.box<Map>(_boxName);

  List<AlarmModel> getAll() {
    return _box.values
        .map((e) => AlarmModel.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) {
        final aMin = a.hour * 60 + a.minute;
        final bMin = b.hour * 60 + b.minute;
        return aMin.compareTo(bMin);
      });
  }

  AlarmModel? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return AlarmModel.fromMap(Map<String, dynamic>.from(raw));
  }

  AlarmModel? findByPlatformId(int platformId) {
    for (final alarm in getAll()) {
      if (platformAlarmId(alarm.id) == platformId) {
        return alarm;
      }
    }
    return null;
  }

  int platformAlarmId(String id) => id.hashCode.abs() % 2147483647;

  bool repeats(AlarmModel alarm) => alarm.repeatDays.any((day) => day);

  DateTime nextOccurrence(AlarmModel alarm, {DateTime? from}) {
    final base = from ?? DateTime.now();

    if (!repeats(alarm)) {
      var candidate =
          DateTime(base.year, base.month, base.day, alarm.hour, alarm.minute);
      if (!candidate.isAfter(base)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      return candidate;
    }

    final start = DateTime(base.year, base.month, base.day);
    for (var offset = 0; offset < 8; offset++) {
      final day = start.add(Duration(days: offset));
      final candidate =
          DateTime(day.year, day.month, day.day, alarm.hour, alarm.minute);
      final weekdayIndex = candidate.weekday - 1;
      if (!alarm.repeatDays[weekdayIndex]) continue;
      if (candidate.isAfter(base)) return candidate;
    }

    return DateTime(base.year, base.month, base.day, alarm.hour, alarm.minute)
        .add(const Duration(days: 1));
  }

  Future<void> schedule(
    AlarmModel alarm, {
    DateTime? at,
    DateTime? from,
  }) async {
    if (!alarm.isEnabled || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final scheduledAt = at ?? nextOccurrence(alarm, from: from);
    final label = alarm.label.isEmpty ? 'Alarm' : alarm.label;

    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: platformAlarmId(alarm.id),
        dateTime: scheduledAt,
        assetAudioPath: alarm.soundPath,
        loopAudio: true,
        vibrate: true,
        volumeEnforced: true,
        fadeDuration: 2.0,
        warningNotificationOnKill: true,
        androidFullScreenIntent: true,
        notificationSettings: NotificationSettings(
          title: label,
          body: 'Time to wake up!',
          stopButton: 'Open app',
        ),
      ),
    );
  }

  Future<void> cancel(AlarmModel alarm) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await Alarm.stop(platformAlarmId(alarm.id));
  }

  Future<void> save(AlarmModel alarm) async {
    await _box.put(alarm.id, alarm.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
