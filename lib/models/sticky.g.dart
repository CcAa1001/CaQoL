// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticky.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StickyChecklistItem _$StickyChecklistItemFromJson(Map<String, dynamic> json) =>
    _StickyChecklistItem(
      id: json['id'] as String,
      text: json['text'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );

Map<String, dynamic> _$StickyChecklistItemToJson(
  _StickyChecklistItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'isDone': instance.isDone,
};

_Sticky _$StickyFromJson(Map<String, dynamic> json) => _Sticky(
  id: json['id'] as String,
  title: json['title'] as String? ?? '',
  body: json['body'] as String,
  color: const ColorConverter().fromJson((json['color'] as num).toInt()),
  boardId: json['boardId'] as String?,
  linkedNoteId: json['linkedNoteId'] as String?,
  linkedNoteTitle: json['linkedNoteTitle'] as String?,
  stickyType: json['stickyType'] as String? ?? 'text',
  sourceName: json['sourceName'] as String?,
  sourcePath: json['sourcePath'] as String?,
  lane: json['lane'] as String? ?? 'Inbox',
  liveUrl: json['liveUrl'] as String?,
  liveRefreshMinutes: (json['liveRefreshMinutes'] as num?)?.toInt() ?? 5,
  liveRefreshedAt: json['liveRefreshedAt'] == null
      ? null
      : DateTime.parse(json['liveRefreshedAt'] as String),
  size: json['size'] as String? ?? 'medium',
  checklistMode: json['checklistMode'] as bool? ?? false,
  checklistItems:
      (json['checklistItems'] as List<dynamic>?)
          ?.map((e) => StickyChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  isPinned: json['isPinned'] as bool? ?? false,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deviceUpdatedAt: DateTime.parse(json['deviceUpdatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$StickyToJson(_Sticky instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'body': instance.body,
  'color': const ColorConverter().toJson(instance.color),
  'boardId': instance.boardId,
  'linkedNoteId': instance.linkedNoteId,
  'linkedNoteTitle': instance.linkedNoteTitle,
  'stickyType': instance.stickyType,
  'sourceName': instance.sourceName,
  'sourcePath': instance.sourcePath,
  'lane': instance.lane,
  'liveUrl': instance.liveUrl,
  'liveRefreshMinutes': instance.liveRefreshMinutes,
  'liveRefreshedAt': instance.liveRefreshedAt?.toIso8601String(),
  'size': instance.size,
  'checklistMode': instance.checklistMode,
  'checklistItems': instance.checklistItems,
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'isPinned': instance.isPinned,
  'sortOrder': instance.sortOrder,
  'updatedAt': instance.updatedAt.toIso8601String(),
  'deviceUpdatedAt': instance.deviceUpdatedAt.toIso8601String(),
  'isDeleted': instance.isDeleted,
};
