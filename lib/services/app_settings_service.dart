import 'package:hive_flutter/hive_flutter.dart';

class AppSettings {
  final int defaultMissionSeconds;
  final bool noteEditorCollapsedTools;
  final String? defaultStickyBoardId;
  final bool awakeCheckEnabled;
  final int awakeCheckDelayMinutes;
  final int awakeCheckWindowMinutes;

  const AppSettings({
    this.defaultMissionSeconds = 30,
    this.noteEditorCollapsedTools = false,
    this.defaultStickyBoardId,
    this.awakeCheckEnabled = false,
    this.awakeCheckDelayMinutes = 5,
    this.awakeCheckWindowMinutes = 2,
  });

  AppSettings copyWith({
    int? defaultMissionSeconds,
    bool? noteEditorCollapsedTools,
    String? defaultStickyBoardId,
    bool? clearDefaultStickyBoardId,
    bool? awakeCheckEnabled,
    int? awakeCheckDelayMinutes,
    int? awakeCheckWindowMinutes,
  }) {
    return AppSettings(
      defaultMissionSeconds: defaultMissionSeconds ?? this.defaultMissionSeconds,
      noteEditorCollapsedTools:
          noteEditorCollapsedTools ?? this.noteEditorCollapsedTools,
      defaultStickyBoardId: clearDefaultStickyBoardId == true
          ? null
          : defaultStickyBoardId ?? this.defaultStickyBoardId,
      awakeCheckEnabled: awakeCheckEnabled ?? this.awakeCheckEnabled,
      awakeCheckDelayMinutes:
          awakeCheckDelayMinutes ?? this.awakeCheckDelayMinutes,
      awakeCheckWindowMinutes:
          awakeCheckWindowMinutes ?? this.awakeCheckWindowMinutes,
    );
  }

  Map<String, dynamic> toMap() => {
        'defaultMissionSeconds': defaultMissionSeconds,
        'noteEditorCollapsedTools': noteEditorCollapsedTools,
        'defaultStickyBoardId': defaultStickyBoardId,
        'awakeCheckEnabled': awakeCheckEnabled,
        'awakeCheckDelayMinutes': awakeCheckDelayMinutes,
        'awakeCheckWindowMinutes': awakeCheckWindowMinutes,
      };

  factory AppSettings.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const AppSettings();
    }
    return AppSettings(
      defaultMissionSeconds: map['defaultMissionSeconds'] ?? 30,
      noteEditorCollapsedTools: map['noteEditorCollapsedTools'] ?? false,
      defaultStickyBoardId: map['defaultStickyBoardId']?.toString(),
      awakeCheckEnabled: map['awakeCheckEnabled'] ?? false,
      awakeCheckDelayMinutes: map['awakeCheckDelayMinutes'] ?? 5,
      awakeCheckWindowMinutes: map['awakeCheckWindowMinutes'] ?? 2,
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
