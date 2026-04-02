import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/alarm.dart';
import '../models/awake_check_entry.dart';

class AwakeCheckService {
  static const _boxName = 'awake_checks';

  Future<void> init() async {
    await Hive.openBox<Map>(_boxName);
  }

  Box<Map> get _box => Hive.box<Map>(_boxName);

  List<AwakeCheckEntry> getAll({bool includeCompleted = false}) {
    final checks = <AwakeCheckEntry>[];
    for (final raw in _box.values) {
      try {
        final entry = AwakeCheckEntry.fromMap(Map<String, dynamic>.from(raw));
        if (includeCompleted || !entry.completed) {
          checks.add(entry);
        }
      } catch (_) {}
    }
    checks.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return checks;
  }

  AwakeCheckEntry? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    try {
      return AwakeCheckEntry.fromMap(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  AwakeCheckEntry? findByPlatformId(int platformId) {
    for (final entry in getAll(includeCompleted: true)) {
      if (entry.platformId == platformId) {
        return entry;
      }
    }
    return null;
  }

  Future<AwakeCheckEntry> createFor(
    AlarmModel alarm, {
    required int delayMinutes,
    required int windowMinutes,
  }) async {
    final now = DateTime.now();
    final entry = AwakeCheckEntry(
      id: 'awake_${now.microsecondsSinceEpoch}_${alarm.id}',
      platformId: now.microsecondsSinceEpoch % 2147483647,
      alarmId: alarm.id,
      alarmLabel: alarm.label.isEmpty ? 'Alarm ${alarm.timeString}' : alarm.label,
      noteId: alarm.noteId,
      scheduledAt: now.add(Duration(minutes: delayMinutes)),
      expiresAt: now.add(
        Duration(minutes: delayMinutes + windowMinutes),
      ),
    );
    await save(entry);
    return entry;
  }

  Future<void> schedule(AwakeCheckEntry entry) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: entry.platformId,
        dateTime: entry.scheduledAt,
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: false,
        vibrate: false,
        volumeEnforced: false,
        fadeDuration: 0.0,
        warningNotificationOnKill: true,
        androidFullScreenIntent: true,
        notificationSettings: NotificationSettings(
          title: 'Awake Check',
          body: 'Tap to confirm you are still awake.',
          stopButton: 'Open',
        ),
      ),
    );
  }

  Future<void> cancel(AwakeCheckEntry entry) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    await Alarm.stop(entry.platformId);
  }

  Future<void> save(AwakeCheckEntry entry) async {
    await _box.put(entry.id, entry.toMap());
  }

  Future<void> complete(AwakeCheckEntry entry, {bool acknowledged = false}) async {
    await cancel(entry);
    await save(
      entry.copyWith(
        acknowledged: acknowledged || entry.acknowledged,
        completed: true,
      ),
    );
  }

  Future<void> cleanupExpired() async {
    final now = DateTime.now();
    for (final entry in getAll(includeCompleted: false)) {
      if (!entry.completed && entry.expiresAt.isBefore(now) && !entry.acknowledged) {
        await complete(entry);
      }
    }
  }
}
