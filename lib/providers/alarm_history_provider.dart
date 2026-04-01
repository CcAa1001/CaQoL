import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/alarm_history_entry.dart';
import '../services/alarm_history_service.dart';

final alarmHistoryServiceProvider = Provider((ref) => AlarmHistoryService());

final alarmHistoryProvider =
    StateNotifierProvider<AlarmHistoryNotifier, List<AlarmHistoryEntry>>((ref) {
  return AlarmHistoryNotifier(ref.read(alarmHistoryServiceProvider));
});

class AlarmHistoryNotifier extends StateNotifier<List<AlarmHistoryEntry>> {
  AlarmHistoryNotifier(this._service) : super([]) {
    refresh();
  }

  final AlarmHistoryService _service;

  void refresh() {
    state = _service.getAll();
  }
}
