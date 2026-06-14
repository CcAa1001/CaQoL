// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NoteComment _$NoteCommentFromJson(Map<String, dynamic> json) => _NoteComment(
  id: json['id'] as String,
  text: json['text'] as String,
  quotedText: json['quotedText'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$NoteCommentToJson(_NoteComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'quotedText': instance.quotedText,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_NoteAttachment _$NoteAttachmentFromJson(Map<String, dynamic> json) =>
    _NoteAttachment(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$NoteAttachmentToJson(_NoteAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'path': instance.path,
      'type': instance.type,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_Note _$NoteFromJson(Map<String, dynamic> json) => _Note(
  id: json['id'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  folderId: json['folderId'] as String?,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  isFavorite: json['isFavorite'] as bool? ?? false,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => NoteComment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => NoteAttachment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deviceUpdatedAt: DateTime.parse(json['deviceUpdatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$NoteToJson(_Note instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'body': instance.body,
  'folderId': instance.folderId,
  'sortOrder': instance.sortOrder,
  'isFavorite': instance.isFavorite,
  'tags': instance.tags,
  'comments': instance.comments,
  'attachments': instance.attachments,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'deviceUpdatedAt': instance.deviceUpdatedAt.toIso8601String(),
  'isDeleted': instance.isDeleted,
};
