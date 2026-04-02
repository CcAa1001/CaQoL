class AwakeCheckEntry {
  final String id;
  final int platformId;
  final String alarmId;
  final String alarmLabel;
  final String? noteId;
  final DateTime scheduledAt;
  final DateTime expiresAt;
  final bool acknowledged;
  final bool completed;

  const AwakeCheckEntry({
    required this.id,
    required this.platformId,
    required this.alarmId,
    required this.alarmLabel,
    this.noteId,
    required this.scheduledAt,
    required this.expiresAt,
    this.acknowledged = false,
    this.completed = false,
  });

  AwakeCheckEntry copyWith({
    int? platformId,
    String? alarmLabel,
    String? noteId,
    bool? acknowledged,
    bool? completed,
    DateTime? scheduledAt,
    DateTime? expiresAt,
  }) {
    return AwakeCheckEntry(
      id: id,
      platformId: platformId ?? this.platformId,
      alarmId: alarmId,
      alarmLabel: alarmLabel ?? this.alarmLabel,
      noteId: noteId ?? this.noteId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      expiresAt: expiresAt ?? this.expiresAt,
      acknowledged: acknowledged ?? this.acknowledged,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'platformId': platformId,
        'alarmId': alarmId,
        'alarmLabel': alarmLabel,
        'noteId': noteId,
        'scheduledAt': scheduledAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'acknowledged': acknowledged,
        'completed': completed,
      };

  factory AwakeCheckEntry.fromMap(Map<String, dynamic> map) {
    return AwakeCheckEntry(
      id: (map['id'] ?? '').toString(),
      platformId: map['platformId'] ?? (map['id'] ?? '').hashCode.abs() % 2147483647,
      alarmId: (map['alarmId'] ?? '').toString(),
      alarmLabel: (map['alarmLabel'] ?? 'Awake Check').toString(),
      noteId: map['noteId']?.toString(),
      scheduledAt:
          DateTime.tryParse((map['scheduledAt'] ?? '').toString()) ??
              DateTime.now(),
      expiresAt:
          DateTime.tryParse((map['expiresAt'] ?? '').toString()) ??
              DateTime.now().add(const Duration(minutes: 2)),
      acknowledged: map['acknowledged'] == true,
      completed: map['completed'] == true,
    );
  }
}
