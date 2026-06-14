// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NoteFolder _$NoteFolderFromJson(Map<String, dynamic> json) => _NoteFolder(
  id: json['id'] as String,
  name: json['name'] as String,
  parentId: json['parentId'] as String?,
  manualSortEnabled: json['manualSortEnabled'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deviceUpdatedAt: DateTime.parse(json['deviceUpdatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$NoteFolderToJson(_NoteFolder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parentId': instance.parentId,
      'manualSortEnabled': instance.manualSortEnabled,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deviceUpdatedAt': instance.deviceUpdatedAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
