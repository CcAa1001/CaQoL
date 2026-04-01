enum QuestType { none, math, typeSentence, simon, qr, squat }

class QuestConfig {
  final QuestType type;
  final int missionSeconds;

  // Math
  final String mathDifficulty; // easy, medium, hard

  // Type sentence
  final String sentence;

  // Simon Says
  final int gridSize; // 3, 4, or 5

  // QR
  final String qrValue;

  // Squat
  final int squatCount;

  const QuestConfig({
    this.type = QuestType.none,
    this.missionSeconds = 30,
    this.mathDifficulty = 'easy',
    this.sentence = 'I am awake and ready for the day',
    this.gridSize = 3,
    this.qrValue = '',
    this.squatCount = 10,
  });

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'missionSeconds': missionSeconds,
    'mathDifficulty': mathDifficulty,
    'sentence': sentence,
    'gridSize': gridSize,
    'qrValue': qrValue,
    'squatCount': squatCount,
  };

  factory QuestConfig.fromMap(Map<String, dynamic> map) => QuestConfig(
    type: QuestType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => QuestType.none,
    ),
    missionSeconds: map['missionSeconds'] ?? 30,
    mathDifficulty: map['mathDifficulty'] ?? 'easy',
    sentence: map['sentence'] ?? 'I am awake and ready for the day',
    gridSize: map['gridSize'] ?? 3,
    qrValue: map['qrValue'] ?? '',
    squatCount: map['squatCount'] ?? 10,
  );

  QuestConfig copyWith({
    QuestType? type,
    int? missionSeconds,
    String? mathDifficulty,
    String? sentence,
    int? gridSize,
    String? qrValue,
    int? squatCount,
  }) =>
      QuestConfig(
        type: type ?? this.type,
        missionSeconds: missionSeconds ?? this.missionSeconds,
        mathDifficulty: mathDifficulty ?? this.mathDifficulty,
        sentence: sentence ?? this.sentence,
        gridSize: gridSize ?? this.gridSize,
        qrValue: qrValue ?? this.qrValue,
        squatCount: squatCount ?? this.squatCount,
      );
}
