// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuestConfig _$QuestConfigFromJson(Map<String, dynamic> json) => _QuestConfig(
  type: $enumDecodeNullable(_$QuestTypeEnumMap, json['type']) ?? QuestType.none,
  missionSeconds: (json['missionSeconds'] as num?)?.toInt() ?? 30,
  missionSlots:
      (json['missionSlots'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  mathDifficulty: json['mathDifficulty'] as String? ?? 'easy',
  mathRepeatCount: (json['mathRepeatCount'] as num?)?.toInt() ?? 1,
  sentence: json['sentence'] as String? ?? 'I am awake and ready for the day',
  typingPhraseCount: (json['typingPhraseCount'] as num?)?.toInt() ?? 1,
  gridSize: (json['gridSize'] as num?)?.toInt() ?? 3,
  simonRounds: (json['simonRounds'] as num?)?.toInt() ?? 3,
  qrValue: json['qrValue'] as String? ?? '',
  qrOptions:
      (json['qrOptions'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  squatCount: (json['squatCount'] as num?)?.toInt() ?? 10,
  randomQuestTypes:
      (json['randomQuestTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$QuestConfigToJson(_QuestConfig instance) =>
    <String, dynamic>{
      'type': _$QuestTypeEnumMap[instance.type]!,
      'missionSeconds': instance.missionSeconds,
      'missionSlots': instance.missionSlots,
      'mathDifficulty': instance.mathDifficulty,
      'mathRepeatCount': instance.mathRepeatCount,
      'sentence': instance.sentence,
      'typingPhraseCount': instance.typingPhraseCount,
      'gridSize': instance.gridSize,
      'simonRounds': instance.simonRounds,
      'qrValue': instance.qrValue,
      'qrOptions': instance.qrOptions,
      'squatCount': instance.squatCount,
      'randomQuestTypes': instance.randomQuestTypes,
    };

const _$QuestTypeEnumMap = {
  QuestType.none: 'none',
  QuestType.math: 'math',
  QuestType.typeSentence: 'typeSentence',
  QuestType.simon: 'simon',
  QuestType.qr: 'qr',
  QuestType.squat: 'squat',
  QuestType.pushup: 'pushup',
  QuestType.situp: 'situp',
};
