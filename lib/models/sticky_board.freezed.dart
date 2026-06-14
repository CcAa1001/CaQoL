// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sticky_board.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StickyBoard {

 String get id; String get name; String get viewMode; DateTime get createdAt; DateTime get updatedAt; DateTime get deviceUpdatedAt; bool get isDeleted;
/// Create a copy of StickyBoard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StickyBoardCopyWith<StickyBoard> get copyWith => _$StickyBoardCopyWithImpl<StickyBoard>(this as StickyBoard, _$identity);

  /// Serializes this StickyBoard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StickyBoard&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deviceUpdatedAt, deviceUpdatedAt) || other.deviceUpdatedAt == deviceUpdatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,viewMode,createdAt,updatedAt,deviceUpdatedAt,isDeleted);

@override
String toString() {
  return 'StickyBoard(id: $id, name: $name, viewMode: $viewMode, createdAt: $createdAt, updatedAt: $updatedAt, deviceUpdatedAt: $deviceUpdatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $StickyBoardCopyWith<$Res>  {
  factory $StickyBoardCopyWith(StickyBoard value, $Res Function(StickyBoard) _then) = _$StickyBoardCopyWithImpl;
@useResult
$Res call({
 String id, String name, String viewMode, DateTime createdAt, DateTime updatedAt, DateTime deviceUpdatedAt, bool isDeleted
});




}
/// @nodoc
class _$StickyBoardCopyWithImpl<$Res>
    implements $StickyBoardCopyWith<$Res> {
  _$StickyBoardCopyWithImpl(this._self, this._then);

  final StickyBoard _self;
  final $Res Function(StickyBoard) _then;

/// Create a copy of StickyBoard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? viewMode = null,Object? createdAt = null,Object? updatedAt = null,Object? deviceUpdatedAt = null,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deviceUpdatedAt: null == deviceUpdatedAt ? _self.deviceUpdatedAt : deviceUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StickyBoard].
extension StickyBoardPatterns on StickyBoard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StickyBoard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StickyBoard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StickyBoard value)  $default,){
final _that = this;
switch (_that) {
case _StickyBoard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StickyBoard value)?  $default,){
final _that = this;
switch (_that) {
case _StickyBoard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String viewMode,  DateTime createdAt,  DateTime updatedAt,  DateTime deviceUpdatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StickyBoard() when $default != null:
return $default(_that.id,_that.name,_that.viewMode,_that.createdAt,_that.updatedAt,_that.deviceUpdatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String viewMode,  DateTime createdAt,  DateTime updatedAt,  DateTime deviceUpdatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _StickyBoard():
return $default(_that.id,_that.name,_that.viewMode,_that.createdAt,_that.updatedAt,_that.deviceUpdatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String viewMode,  DateTime createdAt,  DateTime updatedAt,  DateTime deviceUpdatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _StickyBoard() when $default != null:
return $default(_that.id,_that.name,_that.viewMode,_that.createdAt,_that.updatedAt,_that.deviceUpdatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StickyBoard extends StickyBoard {
  const _StickyBoard({required this.id, required this.name, this.viewMode = 'grid', required this.createdAt, required this.updatedAt, required this.deviceUpdatedAt, this.isDeleted = false}): super._();
  factory _StickyBoard.fromJson(Map<String, dynamic> json) => _$StickyBoardFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  String viewMode;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime deviceUpdatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of StickyBoard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StickyBoardCopyWith<_StickyBoard> get copyWith => __$StickyBoardCopyWithImpl<_StickyBoard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StickyBoardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StickyBoard&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deviceUpdatedAt, deviceUpdatedAt) || other.deviceUpdatedAt == deviceUpdatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,viewMode,createdAt,updatedAt,deviceUpdatedAt,isDeleted);

@override
String toString() {
  return 'StickyBoard(id: $id, name: $name, viewMode: $viewMode, createdAt: $createdAt, updatedAt: $updatedAt, deviceUpdatedAt: $deviceUpdatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$StickyBoardCopyWith<$Res> implements $StickyBoardCopyWith<$Res> {
  factory _$StickyBoardCopyWith(_StickyBoard value, $Res Function(_StickyBoard) _then) = __$StickyBoardCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String viewMode, DateTime createdAt, DateTime updatedAt, DateTime deviceUpdatedAt, bool isDeleted
});




}
/// @nodoc
class __$StickyBoardCopyWithImpl<$Res>
    implements _$StickyBoardCopyWith<$Res> {
  __$StickyBoardCopyWithImpl(this._self, this._then);

  final _StickyBoard _self;
  final $Res Function(_StickyBoard) _then;

/// Create a copy of StickyBoard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? viewMode = null,Object? createdAt = null,Object? updatedAt = null,Object? deviceUpdatedAt = null,Object? isDeleted = null,}) {
  return _then(_StickyBoard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deviceUpdatedAt: null == deviceUpdatedAt ? _self.deviceUpdatedAt : deviceUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
