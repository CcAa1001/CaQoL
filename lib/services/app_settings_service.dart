import 'package:hive_flutter/hive_flutter.dart';

class AppSettings {
  final int defaultMissionSeconds;
  final bool noteEditorCollapsedTools;
  final String? defaultStickyBoardId;
  final bool awakeCheckEnabled;
  final int awakeCheckDelayMinutes;
  final int awakeCheckWindowMinutes;
  final bool alarmRescheduleOnResume;
  final bool alarmAudioBoostEnabled;
  final bool alarmEscalationEnabled;
  final int alarmEscalationSeconds;
  final int emergencyDismissTapCount;
  final int emergencyDismissCooldownDays;
  final String? emergencyDismissLastUsedAt;

  const AppSettings({
    this.defaultMissionSeconds = 30,
    this.noteEditorCollapsedTools = false,
    this.defaultStickyBoardId,
    this.awakeCheckEnabled = false,
    this.awakeCheckDelayMinutes = 5,
    this.awakeCheckWindowMinutes = 2,
    this.alarmRescheduleOnResume = true,
    this.alarmAudioBoostEnabled = true,
    this.alarmEscalationEnabled = true,
    this.alarmEscalationSeconds = 20,
    this.emergencyDismissTapCount = 100,
    this.emergencyDismissCooldownDays = 7,
    this.emergencyDismissLastUsedAt,
  });

  AppSettings copyWith({
    int? defaultMissionSeconds,
    bool? noteEditorCollapsedTools,
    String? defaultStickyBoardId,
    bool? clearDefaultStickyBoardId,
    bool? awakeCheckEnabled,
    int? awakeCheckDelayMinutes,
    int? awakeCheckWindowMinutes,
    bool? alarmRescheduleOnResume,
    bool? alarmAudioBoostEnabled,
    bool? alarmEscalationEnabled,
    int? alarmEscalationSeconds,
    int? emergencyDismissTapCount,
    int? emergencyDismissCooldownDays,
    String? emergencyDismissLastUsedAt,
    bool? clearEmergencyDismissLastUsedAt,
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
      alarmRescheduleOnResume:
          alarmRescheduleOnResume ?? this.alarmRescheduleOnResume,
      alarmAudioBoostEnabled:
          alarmAudioBoostEnabled ?? this.alarmAudioBoostEnabled,
      alarmEscalationEnabled:
          alarmEscalationEnabled ?? this.alarmEscalationEnabled,
      alarmEscalationSeconds:
          alarmEscalationSeconds ?? this.alarmEscalationSeconds,
      emergencyDismissTapCount:
          emergencyDismissTapCount ?? this.emergencyDismissTapCount,
      emergencyDismissCooldownDays:
          emergencyDismissCooldownDays ?? this.emergencyDismissCooldownDays,
      emergencyDismissLastUsedAt: clearEmergencyDismissLastUsedAt == true
          ? null
          : emergencyDismissLastUsedAt ?? this.emergencyDismissLastUsedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'defaultMissionSeconds': defaultMissionSeconds,
        'noteEditorCollapsedTools': noteEditorCollapsedTools,
        'defaultStickyBoardId': defaultStickyBoardId,
        'awakeCheckEnabled': awakeCheckEnabled,
        'awakeCheckDelayMinutes': awakeCheckDelayMinutes,
        'awakeCheckWindowMinutes': awakeCheckWindowMinutes,
        'alarmRescheduleOnResume': alarmRescheduleOnResume,
        'alarmAudioBoostEnabled': alarmAudioBoostEnabled,
        'alarmEscalationEnabled': alarmEscalationEnabled,
        'alarmEscalationSeconds': alarmEscalationSeconds,
        'emergencyDismissTapCount': emergencyDismissTapCount,
        'emergencyDismissCooldownDays': emergencyDismissCooldownDays,
        'emergencyDismissLastUsedAt': emergencyDismissLastUsedAt,
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
      alarmRescheduleOnResume: map['alarmRescheduleOnResume'] ?? true,
      alarmAudioBoostEnabled: map['alarmAudioBoostEnabled'] ?? true,
      alarmEscalationEnabled: map['alarmEscalationEnabled'] ?? true,
      alarmEscalationSeconds: map['alarmEscalationSeconds'] ?? 20,
      emergencyDismissTapCount: map['emergencyDismissTapCount'] ?? 100,
      emergencyDismissCooldownDays: map['emergencyDismissCooldownDays'] ?? 7,
      emergencyDismissLastUsedAt:
          map['emergencyDismissLastUsedAt']?.toString(),
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
