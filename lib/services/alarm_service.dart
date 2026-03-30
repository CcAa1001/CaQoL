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

  Future<void> save(AlarmModel alarm) async {
    await _box.put(alarm.id, alarm.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}