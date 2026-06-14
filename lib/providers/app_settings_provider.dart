import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_settings_service.dart';

final appSettingsServiceProvider = Provider((ref) => AppSettingsService());

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier(ref.read(appSettingsServiceProvider));
});

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier(this._service) : super(const AppSettings()) {
    load();
  }

  final AppSettingsService _service;

  void load() {
    state = _service.getSettings();
  }

  Future<void> setDefaultMissionSeconds(int seconds) async {
    final updated = state.copyWith(defaultMissionSeconds: seconds);
    await _service.save(updated);
    state = updated;
  }

  Future<void> setNoteEditorCollapsedTools(bool value) async {
    final updated = state.copyWith(noteEditorCollapsedTools: value);
    await _service.save(updated);
    state = updated;
  }

  Future<void> setDefaultStickyBoardId(String? boardId) async {
    final updated = state.copyWith(
      defaultStickyBoardId: boardId,
      clearDefaultStickyBoardId: boardId == null,
    );
    await _service.save(updated);
    state = updated;
  }

  Future<void> setAwakeCheckEnabled(bool value) async {
    final updated = state.copyWith(awakeCheckEnabled: value);
    await _service.save(updated);
    state = updated;
  }

  Future<void> setAwakeCheckDelayMinutes(int minutes) async {
    final updated = state.copyWith(awakeCheckDelayMinutes: minutes);
    await _service.save(updated);
    state = updated;
  }

  Future<void> setAwakeCheckWindowMinutes(int minutes) async {
    final updated = state.copyWith(awakeCheckWindowMinutes: minutes);
    await _service.save(updated);
    state = updated;
  }

  Future<void> setAlarmRescheduleOnResume(bool value) async {
    final updated = state.copyWith(alarmRescheduleOnResume: value);
    await _service.save(updated);
    state = updated;
  }

  Future<void> setAlarmAudioBoostEnabled(bool value) async {
    final updated = state.copyWith(alarmAudioBoostEnabled: value);
    await _service.save(updated);
    state = updated;
  }

  Future<void> setAlarmEscalationEnabled(bool value) async {
    final updated = state.copyWith(alarmEscalationEnabled: value);
    await _service.save(updated);
    state = updated;
  }

  Future<void> setAlarmEscalationSeconds(int seconds) async {
    final updated = state.copyWith(alarmEscalationSeconds: seconds);
    await _service.save(updated);
    state = updated;
  }

  Future<void> setEmergencyDismissTapCount(int taps) async {
    final updated = state.copyWith(emergencyDismissTapCount: taps);
    await _service.save(updated);
    state = updated;
  }

  Future<void> setEmergencyDismissCooldownDays(int days) async {
    final updated = state.copyWith(emergencyDismissCooldownDays: days);
    await _service.save(updated);
    state = updated;
  }

  Future<void> markEmergencyDismissUsed(DateTime at) async {
    final updated = state.copyWith(
      emergencyDismissLastUsedAt: at.toIso8601String(),
    );
    await _service.save(updated);
    state = updated;
  }
}
