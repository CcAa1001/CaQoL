enum QuestType { none, math, typeSentence, simon, qr, squat }

class QuestConfig {
  final QuestType type;

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
    this.mathDifficulty = 'easy',
    this.sentence = 'I am awake and ready for the day',
    this.gridSize = 3,
    this.qrValue = '',
    this.squatCount = 10,
  });

  Map<String, dynamic> toMap() => {
    'type': type.name,
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
    mathDifficulty: map['mathDifficulty'] ?? 'easy',
    sentence: map['sentence'] ?? 'I am awake and ready for the day',
    gridSize: map['gridSize'] ?? 3,
    qrValue: map['qrValue'] ?? '',
    squatCount: map['squatCount'] ?? 10,
  );

  QuestConfig copyWith({
    QuestType? type,
    String? mathDifficulty,
    String? sentence,
    int? gridSize,
    String? qrValue,
    int? squatCount,
  }) =>
      QuestConfig(
        type: type ?? this.type,
        mathDifficulty: mathDifficulty ?? this.mathDifficulty,
        sentence: sentence ?? this.sentence,
        gridSize: gridSize ?? this.gridSize,
        qrValue: qrValue ?? this.qrValue,
        squatCount: squatCount ?? this.squatCount,
      );
}