import 'package:flutter/material.dart';

class StickyChecklistItem {
  final String id;
  final String text;
  final bool isDone;

  const StickyChecklistItem({
    required this.id,
    required this.text,
    this.isDone = false,
  });

  StickyChecklistItem copyWith({
    String? text,
    bool? isDone,
  }) {
    return StickyChecklistItem(
      id: id,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'isDone': isDone,
      };

  factory StickyChecklistItem.fromMap(Map<String, dynamic> map) {
    return StickyChecklistItem(
      id: (map['id'] ?? DateTime.now().microsecondsSinceEpoch.toString())
          .toString(),
      text: (map['text'] ?? '').toString(),
      isDone: map['isDone'] == true,
    );
  }
}

class Sticky {
  final String id;
  final String title;
  final String body;
  final Color color;
  final String? boardId;
  final String? linkedNoteId;
  final String? linkedNoteTitle;
  final String size;
  final bool checklistMode;
  final List<StickyChecklistItem> checklistItems;
  final DateTime? expiresAt;
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
    this.checklistMode = false,
    this.checklistItems = const [],
    this.expiresAt,
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
    bool? checklistMode,
    List<StickyChecklistItem>? checklistItems,
    DateTime? expiresAt,
    bool? clearExpiresAt,
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
      checklistMode: checklistMode ?? this.checklistMode,
      checklistItems: checklistItems ?? this.checklistItems,
      expiresAt: clearExpiresAt == true ? null : expiresAt ?? this.expiresAt,
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
    'checklistMode': checklistMode,
    'checklistItems': checklistItems.map((item) => item.toMap()).toList(),
    'expiresAt': expiresAt?.toIso8601String(),
    'isPinned': isPinned,
    'sortOrder': sortOrder,
    'updatedAt': updatedAt.toIso8601String(),
    'deviceUpdatedAt': deviceUpdatedAt.toIso8601String(),
    'isDeleted': isDeleted,
  };

  factory Sticky.fromMap(Map<String, dynamic> map) => Sticky(
    id: (map['id'] ?? DateTime.now().microsecondsSinceEpoch.toString())
        .toString(),
    title: (map['title'] ?? '').toString(),
    body: (map['body'] ?? '').toString(),
    color: Color((map['color'] ?? 0xFFFFFF00) as int),
    boardId: map['boardId']?.toString(),
    linkedNoteId: map['linkedNoteId']?.toString(),
    linkedNoteTitle: map['linkedNoteTitle']?.toString(),
    size: (map['size'] ?? 'medium').toString(),
    checklistMode: map['checklistMode'] == true,
    checklistItems: map['checklistItems'] is List
        ? (map['checklistItems'] as List)
            .whereType<Map>()
            .map((item) => StickyChecklistItem.fromMap(
                  Map<String, dynamic>.from(item),
                ))
            .toList()
        : const [],
    expiresAt: map['expiresAt'] == null || map['expiresAt'].toString().isEmpty
        ? null
        : DateTime.tryParse(map['expiresAt'].toString()),
    isPinned: map['isPinned'] ?? false,
    sortOrder: map['sortOrder'] ?? 0,
    updatedAt: DateTime.tryParse((map['updatedAt'] ?? '').toString()) ??
        DateTime.now(),
    deviceUpdatedAt: map['deviceUpdatedAt'] != null
        ? DateTime.tryParse(map['deviceUpdatedAt'].toString()) ??
            DateTime.tryParse((map['updatedAt'] ?? '').toString()) ??
            DateTime.now()
        : DateTime.tryParse((map['updatedAt'] ?? '').toString()) ??
            DateTime.now(),
    isDeleted: map['isDeleted'] ?? false,
  );
}
