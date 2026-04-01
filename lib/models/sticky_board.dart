class StickyBoard {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime deviceUpdatedAt;
  final bool isDeleted;

  StickyBoard({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.deviceUpdatedAt,
    this.isDeleted = false,
  });

  StickyBoard copyWith({
    String? name,
    DateTime? updatedAt,
    DateTime? deviceUpdatedAt,
    bool? isDeleted,
  }) {
    final now = DateTime.now();
    return StickyBoard(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      updatedAt: updatedAt ?? now,
      deviceUpdatedAt: deviceUpdatedAt ?? now,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deviceUpdatedAt': deviceUpdatedAt.toIso8601String(),
    'isDeleted': isDeleted,
  };

  factory StickyBoard.fromMap(Map<String, dynamic> map) => StickyBoard(
    id: map['id'],
    name: map['name'],
    createdAt: DateTime.parse(map['createdAt']),
    updatedAt: DateTime.parse(map['updatedAt']),
    deviceUpdatedAt: map['deviceUpdatedAt'] != null
        ? DateTime.parse(map['deviceUpdatedAt'])
        : DateTime.parse(map['updatedAt']),
    isDeleted: map['isDeleted'] ?? false,
  );
}
