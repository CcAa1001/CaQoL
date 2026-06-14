import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sticky.freezed.dart';
part 'sticky.g.dart';

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.value;
}

@freezed
abstract class StickyChecklistItem with _$StickyChecklistItem {
  const factory StickyChecklistItem({
    required String id,
    required String text,
    @Default(false) bool isDone,
  }) = _StickyChecklistItem;

  factory StickyChecklistItem.fromMap(Map<String, dynamic> map) {
    return StickyChecklistItem(
      id: (map['id'] ?? DateTime.now().microsecondsSinceEpoch.toString()).toString(),
      text: (map['text'] ?? '').toString(),
      isDone: map['isDone'] == true,
    );
  }

  factory StickyChecklistItem.fromJson(Map<String, dynamic> json) => _$StickyChecklistItemFromJson(json);
}

@freezed
abstract class Sticky with _$Sticky {
  const Sticky._();
  const factory Sticky({
    required String id,
    @Default('') String title,
    required String body,
    @ColorConverter() required Color color,
    String? boardId,
    String? linkedNoteId,
    String? linkedNoteTitle,
    @Default('text') String stickyType,
    String? sourceName,
    String? sourcePath,
    @Default('Inbox') String lane,
    String? liveUrl,
    @Default(5) int liveRefreshMinutes,
    DateTime? liveRefreshedAt,
    @Default('medium') String size,
    @Default(false) bool checklistMode,
    @Default([]) List<StickyChecklistItem> checklistItems,
    DateTime? expiresAt,
    @Default(false) bool isPinned,
    @Default(0) int sortOrder,
    required DateTime updatedAt,
    required DateTime deviceUpdatedAt,
    @Default(false) bool isDeleted,
  }) = _Sticky;

  factory Sticky.fromMap(Map<String, dynamic> map) {
    return Sticky(
      id: (map['id'] ?? DateTime.now().microsecondsSinceEpoch.toString()).toString(),
      title: (map['title'] ?? '').toString(),
      body: (map['body'] ?? '').toString(),
      color: Color((map['color'] ?? 0xFFFFFF00) as int),
      boardId: map['boardId']?.toString(),
      linkedNoteId: map['linkedNoteId']?.toString(),
      linkedNoteTitle: map['linkedNoteTitle']?.toString(),
      stickyType: (map['stickyType'] ?? 'text').toString(),
      sourceName: map['sourceName']?.toString(),
      sourcePath: map['sourcePath']?.toString(),
      lane: (map['lane'] ?? 'Inbox').toString(),
      liveUrl: map['liveUrl']?.toString(),
      liveRefreshMinutes: map['liveRefreshMinutes'] is int
          ? map['liveRefreshMinutes'] as int
          : int.tryParse((map['liveRefreshMinutes'] ?? '').toString()) ?? 5,
      liveRefreshedAt: map['liveRefreshedAt'] == null || map['liveRefreshedAt'].toString().isEmpty
          ? null
          : DateTime.tryParse(map['liveRefreshedAt'].toString()),
      size: (map['size'] ?? 'medium').toString(),
      checklistMode: map['checklistMode'] == true,
      checklistItems: map['checklistItems'] is List
          ? (map['checklistItems'] as List)
              .whereType<Map>()
              .map((item) => StickyChecklistItem.fromMap(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
      expiresAt: map['expiresAt'] == null || map['expiresAt'].toString().isEmpty
          ? null
          : DateTime.tryParse(map['expiresAt'].toString()),
      isPinned: map['isPinned'] ?? false,
      sortOrder: map['sortOrder'] ?? 0,
      updatedAt: DateTime.tryParse((map['updatedAt'] ?? '').toString()) ?? DateTime.now(),
      deviceUpdatedAt: map['deviceUpdatedAt'] != null
          ? DateTime.tryParse(map['deviceUpdatedAt'].toString()) ??
              DateTime.tryParse((map['updatedAt'] ?? '').toString()) ??
              DateTime.now()
          : DateTime.tryParse((map['updatedAt'] ?? '').toString()) ?? DateTime.now(),
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  factory Sticky.fromJson(Map<String, dynamic> json) => _$StickyFromJson(json);

  Sticky copyWithClearBoard({
    String? title,
    String? body,
    Color? color,
    String? boardId,
    bool clearBoardId = false,
    String? linkedNoteId,
    bool clearLinkedNoteId = false,
    String? linkedNoteTitle,
    String? stickyType,
    String? sourceName,
    String? sourcePath,
    bool clearSourceName = false,
    bool clearSourcePath = false,
    String? lane,
    String? liveUrl,
    bool clearLiveUrl = false,
    int? liveRefreshMinutes,
    DateTime? liveRefreshedAt,
    bool clearLiveRefreshedAt = false,
    String? size,
    bool? checklistMode,
    List<StickyChecklistItem>? checklistItems,
    DateTime? expiresAt,
    bool clearExpiresAt = false,
    bool? isPinned,
    int? sortOrder,
    DateTime? updatedAt,
    DateTime? deviceUpdatedAt,
    bool? isDeleted,
  }) {
    final now = DateTime.now();
    return copyWith(
      title: title ?? this.title,
      body: body ?? this.body,
      color: color ?? this.color,
      boardId: clearBoardId ? null : (boardId ?? this.boardId),
      linkedNoteId: clearLinkedNoteId ? null : (linkedNoteId ?? this.linkedNoteId),
      linkedNoteTitle: clearLinkedNoteId ? null : (linkedNoteTitle ?? this.linkedNoteTitle),
      stickyType: stickyType ?? this.stickyType,
      sourceName: clearSourceName ? null : (sourceName ?? this.sourceName),
      sourcePath: clearSourcePath ? null : (sourcePath ?? this.sourcePath),
      lane: lane ?? this.lane,
      liveUrl: clearLiveUrl ? null : (liveUrl ?? this.liveUrl),
      liveRefreshMinutes: liveRefreshMinutes ?? this.liveRefreshMinutes,
      liveRefreshedAt: clearLiveRefreshedAt ? null : (liveRefreshedAt ?? this.liveRefreshedAt),
      size: size ?? this.size,
      checklistMode: checklistMode ?? this.checklistMode,
      checklistItems: checklistItems ?? this.checklistItems,
      expiresAt: clearExpiresAt ? null : (expiresAt ?? this.expiresAt),
      isPinned: isPinned ?? this.isPinned,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? now,
      deviceUpdatedAt: deviceUpdatedAt ?? now,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
