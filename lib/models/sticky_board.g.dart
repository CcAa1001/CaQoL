// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticky_board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StickyBoard _$StickyBoardFromJson(Map<String, dynamic> json) => _StickyBoard(
  id: json['id'] as String,
  name: json['name'] as String,
  viewMode: json['viewMode'] as String? ?? 'grid',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deviceUpdatedAt: DateTime.parse(json['deviceUpdatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$StickyBoardToJson(_StickyBoard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'viewMode': instance.viewMode,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deviceUpdatedAt': instance.deviceUpdatedAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
