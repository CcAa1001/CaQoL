// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_folder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NoteFolder {

 String get id; String get name; String? get parentId; bool get manualSortEnabled; DateTime get createdAt; DateTime get updatedAt; DateTime get deviceUpdatedAt; bool get isDeleted;
/// Create a copy of NoteFolder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteFolderCopyWith<NoteFolder> get copyWith => _$NoteFolderCopyWithImpl<NoteFolder>(this as NoteFolder, _$identity);

  /// Serializes this NoteFolder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteFolder&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.manualSortEnabled, manualSortEnabled) || other.manualSortEnabled == manualSortEnabled)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deviceUpdatedAt, deviceUpdatedAt) || other.deviceUpdatedAt == deviceUpdatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,parentId,manualSortEnabled,createdAt,updatedAt,deviceUpdatedAt,isDeleted);

@override
String toString() {
  return 'NoteFolder(id: $id, name: $name, parentId: $parentId, manualSortEnabled: $manualSortEnabled, createdAt: $createdAt, updatedAt: $updatedAt, deviceUpdatedAt: $deviceUpdatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $NoteFolderCopyWith<$Res>  {
  factory $NoteFolderCopyWith(NoteFolder value, $Res Function(NoteFolder) _then) = _$NoteFolderCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? parentId, bool manualSortEnabled, DateTime createdAt, DateTime updatedAt, DateTime deviceUpdatedAt, bool isDeleted
});




}
/// @nodoc
class _$NoteFolderCopyWithImpl<$Res>
    implements $NoteFolderCopyWith<$Res> {
  _$NoteFolderCopyWithImpl(this._self, this._then);

  final NoteFolder _self;
  final $Res Function(NoteFolder) _then;

/// Create a copy of NoteFolder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? parentId = freezed,Object? manualSortEnabled = null,Object? createdAt = null,Object? updatedAt = null,Object? deviceUpdatedAt = null,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,manualSortEnabled: null == manualSortEnabled ? _self.manualSortEnabled : manualSortEnabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deviceUpdatedAt: null == deviceUpdatedAt ? _self.deviceUpdatedAt : deviceUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NoteFolder].
extension NoteFolderPatterns on NoteFolder {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteFolder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteFolder() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteFolder value)  $default,){
final _that = this;
switch (_that) {
case _NoteFolder():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteFolder value)?  $default,){
final _that = this;
switch (_that) {
case _NoteFolder() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? parentId,  bool manualSortEnabled,  DateTime createdAt,  DateTime updatedAt,  DateTime deviceUpdatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteFolder() when $default != null:
return $default(_that.id,_that.name,_that.parentId,_that.manualSortEnabled,_that.createdAt,_that.updatedAt,_that.deviceUpdatedAt,_that.isDeleted);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? parentId,  bool manualSortEnabled,  DateTime createdAt,  DateTime updatedAt,  DateTime deviceUpdatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _NoteFolder():
return $default(_that.id,_that.name,_that.parentId,_that.manualSortEnabled,_that.createdAt,_that.updatedAt,_that.deviceUpdatedAt,_that.isDeleted);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? parentId,  bool manualSortEnabled,  DateTime createdAt,  DateTime updatedAt,  DateTime deviceUpdatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _NoteFolder() when $default != null:
return $default(_that.id,_that.name,_that.parentId,_that.manualSortEnabled,_that.createdAt,_that.updatedAt,_that.deviceUpdatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NoteFolder extends NoteFolder {
  const _NoteFolder({required this.id, required this.name, this.parentId, this.manualSortEnabled = false, required this.createdAt, required this.updatedAt, required this.deviceUpdatedAt, this.isDeleted = false}): super._();
  factory _NoteFolder.fromJson(Map<String, dynamic> json) => _$NoteFolderFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? parentId;
@override@JsonKey() final  bool manualSortEnabled;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime deviceUpdatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of NoteFolder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteFolderCopyWith<_NoteFolder> get copyWith => __$NoteFolderCopyWithImpl<_NoteFolder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NoteFolderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteFolder&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.manualSortEnabled, manualSortEnabled) || other.manualSortEnabled == manualSortEnabled)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deviceUpdatedAt, deviceUpdatedAt) || other.deviceUpdatedAt == deviceUpdatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,parentId,manualSortEnabled,createdAt,updatedAt,deviceUpdatedAt,isDeleted);

@override
String toString() {
  return 'NoteFolder(id: $id, name: $name, parentId: $parentId, manualSortEnabled: $manualSortEnabled, createdAt: $createdAt, updatedAt: $updatedAt, deviceUpdatedAt: $deviceUpdatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$NoteFolderCopyWith<$Res> implements $NoteFolderCopyWith<$Res> {
  factory _$NoteFolderCopyWith(_NoteFolder value, $Res Function(_NoteFolder) _then) = __$NoteFolderCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? parentId, bool manualSortEnabled, DateTime createdAt, DateTime updatedAt, DateTime deviceUpdatedAt, bool isDeleted
});




}
/// @nodoc
class __$NoteFolderCopyWithImpl<$Res>
    implements _$NoteFolderCopyWith<$Res> {
  __$NoteFolderCopyWithImpl(this._self, this._then);

  final _NoteFolder _self;
  final $Res Function(_NoteFolder) _then;

/// Create a copy of NoteFolder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? parentId = freezed,Object? manualSortEnabled = null,Object? createdAt = null,Object? updatedAt = null,Object? deviceUpdatedAt = null,Object? isDeleted = null,}) {
  return _then(_NoteFolder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,manualSortEnabled: null == manualSortEnabled ? _self.manualSortEnabled : manualSortEnabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deviceUpdatedAt: null == deviceUpdatedAt ? _self.deviceUpdatedAt : deviceUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
