import 'package:freezed_annotation/freezed_annotation.dart';
import 'quest_config.dart';

part 'alarm.freezed.dart';
part 'alarm.g.dart';

@freezed
abstract class AlarmModel with _$AlarmModel {
  const AlarmModel._();
  @JsonSerializable(explicitToJson: true)
  const factory AlarmModel({
    required String id,
    required int platformId,
    required String label,
    required String soundPath,
    @Default('Motivation') String soundCategory,
    @Default('genius_brain_frequency') String soundPackId,
    @Default('assets/alarm.mp3') String fallbackSoundPath,
    @Default(1.0) double alarmVolume,
    @Default(0) int wakeCheckMinutes,
    String? noteId,
    required int hour,
    required int minute,
    required List<bool> repeatDays,
    required bool isEnabled,
    DateTime? scheduledAt,
    required QuestConfig quest,
  }) = _AlarmModel;

  factory AlarmModel.fromJson(Map<String, dynamic> json) => _$AlarmModelFromJson(json);

  String get timeString {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get repeatString {
    if (repeatDays.every((d) => !d)) return 'Once';
    if (repeatDays.every((d) => d)) return 'Every day';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return repeatDays
        .asMap()
        .entries
        .where((e) => e.value)
        .map((e) => names[e.key])
        .join(', ');
  }

  AlarmModel copyWithClearNote({
    int? platformId,
    String? label,
    String? soundPath,
    String? soundCategory,
    String? soundPackId,
    String? fallbackSoundPath,
    double? alarmVolume,
    int? wakeCheckMinutes,
    String? noteId,
    bool clearNoteId = false,
    int? hour,
    int? minute,
    List<bool>? repeatDays,
    bool? isEnabled,
    DateTime? scheduledAt,
    bool clearScheduledAt = false,
    QuestConfig? quest,
  }) {
    return copyWith(
      platformId: platformId ?? this.platformId,
      label: label ?? this.label,
      soundPath: soundPath ?? this.soundPath,
      soundCategory: soundCategory ?? this.soundCategory,
      soundPackId: soundPackId ?? this.soundPackId,
      fallbackSoundPath: fallbackSoundPath ?? this.fallbackSoundPath,
      alarmVolume: alarmVolume ?? this.alarmVolume,
      wakeCheckMinutes: wakeCheckMinutes ?? this.wakeCheckMinutes,
      noteId: clearNoteId ? null : (noteId ?? this.noteId),
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
      scheduledAt: clearScheduledAt ? null : (scheduledAt ?? this.scheduledAt),
      quest: quest ?? this.quest,
    );
  }
}
