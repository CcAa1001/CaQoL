import 'package:hive_flutter/hive_flutter.dart';

class AppSettings {
  final int defaultMissionSeconds;
  final bool noteEditorCollapsedTools;

  const AppSettings({
    this.defaultMissionSeconds = 30,
    this.noteEditorCollapsedTools = false,
  });

  AppSettings copyWith({
    int? defaultMissionSeconds,
    bool? noteEditorCollapsedTools,
  }) {
    return AppSettings(
      defaultMissionSeconds: defaultMissionSeconds ?? this.defaultMissionSeconds,
      noteEditorCollapsedTools:
          noteEditorCollapsedTools ?? this.noteEditorCollapsedTools,
    );
  }

  Map<String, dynamic> toMap() => {
        'defaultMissionSeconds': defaultMissionSeconds,
        'noteEditorCollapsedTools': noteEditorCollapsedTools,
      };

  factory AppSettings.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const AppSettings();
    }
    return AppSettings(
      defaultMissionSeconds: map['defaultMissionSeconds'] ?? 30,
      noteEditorCollapsedTools: map['noteEditorCollapsedTools'] ?? false,
    );
  }
}

class AppSettingsService {
  static const _boxName = 'app_settings';
  static const _settingsKey = 'settings';

  Future<void> init() async {
    await Hive.openBox<Map>(_boxName);
  }

  Box<Map> get _box => Hive.box<Map>(_boxName);

  AppSettings getSettings() {
    return AppSettings.fromMap(_box.get(_settingsKey));
  }

  Future<void> save(AppSettings settings) async {
    await _box.put(_settingsKey, settings.toMap());
  }
}
