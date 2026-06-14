import 'package:freezed_annotation/freezed_annotation.dart';

part 'quest_config.freezed.dart';
part 'quest_config.g.dart';

enum QuestType { none, math, typeSentence, simon, qr, squat, pushup, situp }

@freezed
abstract class QuestConfig with _$QuestConfig {
  @JsonSerializable(explicitToJson: true)
  const factory QuestConfig({
    @Default(QuestType.none) QuestType type,
    @Default(30) int missionSeconds,
    @Default([]) List<String> missionSlots,
    
    // Math
    @Default('easy') String mathDifficulty,
    @Default(1) int mathRepeatCount,
    
    // Type sentence
    @Default('I am awake and ready for the day') String sentence,
    @Default(1) int typingPhraseCount,
    
    // Simon Says
    @Default(3) int gridSize,
    @Default(3) int simonRounds,
    
    // QR
    @Default('') String qrValue,
    @Default([]) List<String> qrOptions,
    
    // Squat / Pushup / Situp
    @Default(10) int squatCount,
    
    @Default([]) List<String> randomQuestTypes,
  }) = _QuestConfig;

  factory QuestConfig.fromJson(Map<String, dynamic> json) => _$QuestConfigFromJson(json);
}
