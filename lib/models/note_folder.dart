class NoteFolder {
  final String id;
  final String name;
  final String? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime deviceUpdatedAt;
  final bool isDeleted;

  NoteFolder({
    required this.id,
    required this.name,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    required this.deviceUpdatedAt,
    this.isDeleted = false,
  });

  NoteFolder copyWith({
    String? name,
    String? parentId,
    bool? clearParentId,
    DateTime? updatedAt,
    DateTime? deviceUpdatedAt,
    bool? isDeleted,
  }) {
    final now = DateTime.now();
    return NoteFolder(
      id: id,
      name: name ?? this.name,
      parentId: clearParentId == true ? null : parentId ?? this.parentId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? now,
      deviceUpdatedAt: deviceUpdatedAt ?? now,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'parentId': parentId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deviceUpdatedAt': deviceUpdatedAt.toIso8601String(),
    'isDeleted': isDeleted,
  };

  factory NoteFolder.fromMap(Map<String, dynamic> map) => NoteFolder(
    id: map['id'],
    name: map['name'],
    parentId: map['parentId'],
    createdAt: DateTime.parse(map['createdAt']),
    updatedAt: DateTime.parse(map['updatedAt']),
    deviceUpdatedAt: map['deviceUpdatedAt'] != null
        ? DateTime.parse(map['deviceUpdatedAt'])
        : DateTime.parse(map['updatedAt']),
    isDeleted: map['isDeleted'] ?? false,
  );
}
