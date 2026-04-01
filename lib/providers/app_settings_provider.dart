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
}
