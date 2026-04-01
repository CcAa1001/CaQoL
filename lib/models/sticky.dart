import 'package:flutter/material.dart';

class Sticky {
  final String id;
  final String title;
  final String body;
  final Color color;
  final String? boardId;
  final String? linkedNoteId;
  final String? linkedNoteTitle;
  final String size;
  final bool isPinned;
  final int sortOrder;
  final DateTime updatedAt;
  final DateTime deviceUpdatedAt;
  final bool isDeleted;

  Sticky({
    required this.id,
    this.title = '',
    required this.body,
    required this.color,
    this.boardId,
    this.linkedNoteId,
    this.linkedNoteTitle,
    this.size = 'medium',
    this.isPinned = false,
    this.sortOrder = 0,
    required this.updatedAt,
    required this.deviceUpdatedAt,
    this.isDeleted = false,
  });

  Sticky copyWith({
    String? title,
    String? body,
    Color? color,
    String? boardId,
    bool? clearBoardId,
    String? linkedNoteId,
    bool? clearLinkedNoteId,
    String? linkedNoteTitle,
    String? size,
    bool? isPinned,
    int? sortOrder,
    DateTime? updatedAt,
    DateTime? deviceUpdatedAt,
    bool? isDeleted,
  }) {
    final now = DateTime.now();
    return Sticky(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      color: color ?? this.color,
      boardId: clearBoardId == true ? null : boardId ?? this.boardId,
      linkedNoteId:
          clearLinkedNoteId == true ? null : linkedNoteId ?? this.linkedNoteId,
      linkedNoteTitle: clearLinkedNoteId == true
          ? null
          : linkedNoteTitle ?? this.linkedNoteTitle,
      size: size ?? this.size,
      isPinned: isPinned ?? this.isPinned,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? now,
      deviceUpdatedAt: deviceUpdatedAt ?? now,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'color': color.value,
    'boardId': boardId,
    'linkedNoteId': linkedNoteId,
    'linkedNoteTitle': linkedNoteTitle,
    'size': size,
    'isPinned': isPinned,
    'sortOrder': sortOrder,
    'updatedAt': updatedAt.toIso8601String(),
    'deviceUpdatedAt': deviceUpdatedAt.toIso8601String(),
    'isDeleted': isDeleted,
  };

  factory Sticky.fromMap(Map<String, dynamic> map) => Sticky(
    id: map['id'],
    title: map['title'] ?? '',
    body: map['body'],
    color: Color(map['color']),
    boardId: map['boardId'],
    linkedNoteId: map['linkedNoteId'],
    linkedNoteTitle: map['linkedNoteTitle'],
    size: map['size'] ?? 'medium',
    isPinned: map['isPinned'] ?? false,
    sortOrder: map['sortOrder'] ?? 0,
    updatedAt: DateTime.parse(map['updatedAt']),
    deviceUpdatedAt: map['deviceUpdatedAt'] != null
        ? DateTime.parse(map['deviceUpdatedAt'])
        : DateTime.parse(map['updatedAt']),
    isDeleted: map['isDeleted'] ?? false,
  );
}
