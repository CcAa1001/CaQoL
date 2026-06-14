import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<void> add(AlarmModel alarm) async {
    await _service.save(alarm);
    _load();
  }

  Future<void> update(AlarmModel alarm) async {
    await _service.save(alarm);
    _load();
  }

  Future<void> toggle(String id) async {
    final alarm = state.firstWhere((a) => a.id == id);
    await _service.save(alarm.copyWith(isEnabled: !alarm.isEnabled));
    _load();
  }

  Future<void> delete(String id) async {
    await _service.delete(id);
    _load();
  }
}
