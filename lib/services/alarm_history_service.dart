import 'package:hive_flutter/hive_flutter.dart';

import '../models/alarm.dart';
import '../models/alarm_history_entry.dart';

class AlarmHistoryService {
  static const _boxName = 'alarm_history';

  Future<void> init() async {
    await Hive.openBox<Map>(_boxName);
  }

  Box<Map> get _box => Hive.box<Map>(_boxName);

  List<AlarmHistoryEntry> getAll() {
    final entries = <AlarmHistoryEntry>[];
    for (final raw in _box.values) {
      try {
        entries.add(AlarmHistoryEntry.fromMap(Map<String, dynamic>.from(raw)));
      } catch (_) {}
    }
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  Future<void> log(
    AlarmModel alarm,
    String event, {
    String details = '',
  }) async {
    final entry = AlarmHistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      alarmId: alarm.id,
      alarmLabel: alarm.label.isEmpty ? 'Alarm ${alarm.timeString}' : alarm.label,
      event: event,
      timestamp: DateTime.now(),
      details: details,
    );
    await _box.put(entry.id, entry.toMap());
  }
}
