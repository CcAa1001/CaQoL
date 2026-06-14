// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlarmModel _$AlarmModelFromJson(Map<String, dynamic> json) => _AlarmModel(
  id: json['id'] as String,
  platformId: (json['platformId'] as num).toInt(),
  label: json['label'] as String,
  soundPath: json['soundPath'] as String,
  soundCategory: json['soundCategory'] as String? ?? 'Motivation',
  soundPackId: json['soundPackId'] as String? ?? 'genius_brain_frequency',
  fallbackSoundPath: json['fallbackSoundPath'] as String? ?? 'assets/alarm.mp3',
  alarmVolume: (json['alarmVolume'] as num?)?.toDouble() ?? 1.0,
  wakeCheckMinutes: (json['wakeCheckMinutes'] as num?)?.toInt() ?? 0,
  noteId: json['noteId'] as String?,
  hour: (json['hour'] as num).toInt(),
  minute: (json['minute'] as num).toInt(),
  repeatDays: (json['repeatDays'] as List<dynamic>)
      .map((e) => e as bool)
      .toList(),
  isEnabled: json['isEnabled'] as bool,
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  quest: QuestConfig.fromJson(json['quest'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AlarmModelToJson(_AlarmModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'platformId': instance.platformId,
      'label': instance.label,
      'soundPath': instance.soundPath,
      'soundCategory': instance.soundCategory,
      'soundPackId': instance.soundPackId,
      'fallbackSoundPath': instance.fallbackSoundPath,
      'alarmVolume': instance.alarmVolume,
      'wakeCheckMinutes': instance.wakeCheckMinutes,
      'noteId': instance.noteId,
      'hour': instance.hour,
      'minute': instance.minute,
      'repeatDays': instance.repeatDays,
      'isEnabled': instance.isEnabled,
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
      'quest': instance.quest.toJson(),
    };
