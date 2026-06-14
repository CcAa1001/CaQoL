import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/alarm.dart';

class AlarmService {
  static const _boxName = 'alarms';
  static const _androidAlarmClockChannel = MethodChannel('caqol/alarm_clock');

  Future<void> init() async {
    await Hive.openBox<Map>(_boxName);
  }

  Box<Map> get _box => Hive.box<Map>(_boxName);

  List<AlarmModel> getAll() {
    final alarms = <AlarmModel>[];
    for (final raw in _box.values) {
      try {
        alarms.add(AlarmModel.fromJson(Map<String, dynamic>.from(raw)));
      } catch (_) {
        // Skip corrupt legacy entries instead of breaking the alarm list.
      }
    }
    alarms.sort((a, b) {
      final aMin = a.hour * 60 + a.minute;
      final bMin = b.hour * 60 + b.minute;
      return aMin.compareTo(bMin);
    });
    return alarms;
  }

  AlarmModel? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    try {
      return AlarmModel.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  AlarmModel? findByPlatformId(int platformId) {
    for (final alarm in getAll()) {
      if (alarm.platformId == platformId) {
        return alarm;
      }
    }
    return null;
  }

  bool repeats(AlarmModel alarm) => alarm.repeatDays.any((day) => day);

  DateTime nextOccurrence(AlarmModel alarm, {DateTime? from}) {
    final base = from ?? DateTime.now();

    if (!repeats(alarm)) {
      if (alarm.scheduledAt != null && alarm.scheduledAt!.isAfter(base)) {
        return alarm.scheduledAt!;
      }
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
    final soundPath = _effectiveSoundPath(alarm);
    await save(alarm.copyWith(scheduledAt: scheduledAt));

    await _requestAndroidAlarmPermissions();
    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: alarm.platformId,
        dateTime: scheduledAt,
        assetAudioPath: soundPath,
        loopAudio: true,
        vibrate: true,
        volume: alarm.alarmVolume,
        volumeEnforced: false,
        fadeDuration: 0.0,
        warningNotificationOnKill: true,
        androidFullScreenIntent: true,
        notificationSettings: NotificationSettings(
          title: label,
          body: 'Wake up now. Open CaQoL to stop this alarm.',
          stopButton: 'Open app',
        ),
      ),
    );
    await _scheduleAndroidAlarmClockFallback(
      alarm: alarm,
      scheduledAt: scheduledAt,
      label: label,
      soundPath: soundPath,
    );
  }

  Future<void> ringNow(AlarmModel alarm) async {
    if (!alarm.isEnabled || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final label = alarm.label.isEmpty ? 'Alarm' : alarm.label;
    final soundPath = _effectiveSoundPath(alarm);
    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: alarm.platformId,
        dateTime: DateTime.now().add(const Duration(seconds: 1)),
        assetAudioPath: soundPath,
        loopAudio: true,
        vibrate: true,
        volume: alarm.alarmVolume,
        volumeEnforced: false,
        fadeDuration: 0.0,
        warningNotificationOnKill: true,
        androidFullScreenIntent: true,
        notificationSettings: NotificationSettings(
          title: label,
          body: 'Wake up now. Open CaQoL to stop this alarm.',
          stopButton: 'Open app',
        ),
      ),
    );
  }

  Future<void> cancel(AlarmModel alarm) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await Alarm.stop(alarm.platformId);
  }

  Future<void> markMissedAndDisable(AlarmModel alarm) async {
    await cancel(alarm);
    await save(alarm.copyWithClearNote(isEnabled: false, clearScheduledAt: true));
  }

  Future<void> _requestAndroidAlarmPermissions() async {
    final notificationStatus = await Permission.notification.status;
    if (notificationStatus.isDenied) {
      await Permission.notification.request();
    }

    final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
    if (exactAlarmStatus.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> _scheduleAndroidAlarmClockFallback({
    required AlarmModel alarm,
    required DateTime scheduledAt,
    required String label,
    required String soundPath,
  }) async {
    try {
      final result = await _androidAlarmClockChannel.invokeMethod<Map<dynamic, dynamic>>(
        'scheduleAlarmClock',
        {
          'id': alarm.platformId,
          'millisecondsSinceEpoch': scheduledAt.millisecondsSinceEpoch,
          'assetAudioPath': soundPath,
          'loopAudio': true,
          'vibrate': true,
          'volume': alarm.alarmVolume,
          'volumeEnforced': true,
          'fadeDuration': 0.0,
          'fullScreenIntent': true,
          'notificationTitle': label,
          'notificationBody': 'Wake up now. Open CaQoL to stop this alarm.',
          'notificationStopButton': 'Open app',
        },
      );
      if (result?['scheduled'] != true) {
        debugPrint('Android alarm clock fallback was not scheduled: $result');
      }
    } on PlatformException catch (error) {
      debugPrint('Unable to schedule Android alarm clock fallback: $error');
    }
  }

  String _effectiveSoundPath(AlarmModel alarm) {
    if (alarm.soundPath.trim().isNotEmpty) {
      return alarm.soundPath;
    }
    if (alarm.fallbackSoundPath.trim().isNotEmpty) {
      return alarm.fallbackSoundPath;
    }
    return 'assets/alarm.mp3';
  }

  Future<void> save(AlarmModel alarm) async {
    await _box.put(alarm.id, alarm.toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<List<AlarmModel>> ensureScheduledForEnabledAlarms() async {
    final missed = <AlarmModel>[];
    final now = DateTime.now();
    for (final alarm in getAll()) {
      if (!alarm.isEnabled) {
        continue;
      }
      if (!repeats(alarm) &&
          alarm.scheduledAt != null &&
          alarm.scheduledAt!.isBefore(now)) {
        final isRinging = await Alarm.isRinging(alarm.platformId);
        if (!isRinging) {
          await markMissedAndDisable(alarm);
          missed.add(alarm);
          continue;
        }
      }
      await schedule(alarm);
    }
    return missed;
  }

  Future<int> countCurrentlyRinging() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return 0;
    }
    var count = 0;
    for (final alarm in getAll()) {
      final isRinging = await Alarm.isRinging(alarm.platformId);
      if (isRinging) {
        count += 1;
      }
    }
    return count;
  }
}
