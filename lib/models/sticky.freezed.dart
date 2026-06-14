// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sticky.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StickyChecklistItem {

 String get id; String get text; bool get isDone;
/// Create a copy of StickyChecklistItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StickyChecklistItemCopyWith<StickyChecklistItem> get copyWith => _$StickyChecklistItemCopyWithImpl<StickyChecklistItem>(this as StickyChecklistItem, _$identity);

  /// Serializes this StickyChecklistItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StickyChecklistItem&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.isDone, isDone) || other.isDone == isDone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,isDone);

@override
String toString() {
  return 'StickyChecklistItem(id: $id, text: $text, isDone: $isDone)';
}


}

/// @nodoc
abstract mixin class $StickyChecklistItemCopyWith<$Res>  {
  factory $StickyChecklistItemCopyWith(StickyChecklistItem value, $Res Function(StickyChecklistItem) _then) = _$StickyChecklistItemCopyWithImpl;
@useResult
$Res call({
 String id, String text, bool isDone
});




}
/// @nodoc
class _$StickyChecklistItemCopyWithImpl<$Res>
    implements $StickyChecklistItemCopyWith<$Res> {
  _$StickyChecklistItemCopyWithImpl(this._self, this._then);

  final StickyChecklistItem _self;
  final $Res Function(StickyChecklistItem) _then;

/// Create a copy of StickyChecklistItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? isDone = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StickyChecklistItem].
extension StickyChecklistItemPatterns on StickyChecklistItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StickyChecklistItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StickyChecklistItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StickyChecklistItem value)  $default,){
final _that = this;
switch (_that) {
case _StickyChecklistItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StickyChecklistItem value)?  $default,){
final _that = this;
switch (_that) {
case _StickyChecklistItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  bool isDone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StickyChecklistItem() when $default != null:
return $default(_that.id,_that.text,_that.isDone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  bool isDone)  $default,) {final _that = this;
switch (_that) {
case _StickyChecklistItem():
return $default(_that.id,_that.text,_that.isDone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  bool isDone)?  $default,) {final _that = this;
switch (_that) {
case _StickyChecklistItem() when $default != null:
return $default(_that.id,_that.text,_that.isDone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StickyChecklistItem implements StickyChecklistItem {
  const _StickyChecklistItem({required this.id, required this.text, this.isDone = false});
  factory _StickyChecklistItem.fromJson(Map<String, dynamic> json) => _$StickyChecklistItemFromJson(json);

@override final  String id;
@override final  String text;
@override@JsonKey() final  bool isDone;

/// Create a copy of StickyChecklistItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StickyChecklistItemCopyWith<_StickyChecklistItem> get copyWith => __$StickyChecklistItemCopyWithImpl<_StickyChecklistItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StickyChecklistItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StickyChecklistItem&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.isDone, isDone) || other.isDone == isDone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,isDone);

@override
String toString() {
  return 'StickyChecklistItem(id: $id, text: $text, isDone: $isDone)';
}


}

/// @nodoc
abstract mixin class _$StickyChecklistItemCopyWith<$Res> implements $StickyChecklistItemCopyWith<$Res> {
  factory _$StickyChecklistItemCopyWith(_StickyChecklistItem value, $Res Function(_StickyChecklistItem) _then) = __$StickyChecklistItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, bool isDone
});




}
/// @nodoc
class __$StickyChecklistItemCopyWithImpl<$Res>
    implements _$StickyChecklistItemCopyWith<$Res> {
  __$StickyChecklistItemCopyWithImpl(this._self, this._then);

  final _StickyChecklistItem _self;
  final $Res Function(_StickyChecklistItem) _then;

/// Create a copy of StickyChecklistItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? isDone = null,}) {
  return _then(_StickyChecklistItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Sticky {

 String get id; String get title; String get body;@ColorConverter() Color get color; String? get boardId; String? get linkedNoteId; String? get linkedNoteTitle; String get stickyType; String? get sourceName; String? get sourcePath; String get lane; String? get liveUrl; int get liveRefreshMinutes; DateTime? get liveRefreshedAt; String get size; bool get checklistMode; List<StickyChecklistItem> get checklistItems; DateTime? get expiresAt; bool get isPinned; int get sortOrder; DateTime get updatedAt; DateTime get deviceUpdatedAt; bool get isDeleted;
/// Create a copy of Sticky
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StickyCopyWith<Sticky> get copyWith => _$StickyCopyWithImpl<Sticky>(this as Sticky, _$identity);

  /// Serializes this Sticky to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sticky&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.color, color) || other.color == color)&&(identical(other.boardId, boardId) || other.boardId == boardId)&&(identical(other.linkedNoteId, linkedNoteId) || other.linkedNoteId == linkedNoteId)&&(identical(other.linkedNoteTitle, linkedNoteTitle) || other.linkedNoteTitle == linkedNoteTitle)&&(identical(other.stickyType, stickyType) || other.stickyType == stickyType)&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.sourcePath, sourcePath) || other.sourcePath == sourcePath)&&(identical(other.lane, lane) || other.lane == lane)&&(identical(other.liveUrl, liveUrl) || other.liveUrl == liveUrl)&&(identical(other.liveRefreshMinutes, liveRefreshMinutes) || other.liveRefreshMinutes == liveRefreshMinutes)&&(identical(other.liveRefreshedAt, liveRefreshedAt) || other.liveRefreshedAt == liveRefreshedAt)&&(identical(other.size, size) || other.size == size)&&(identical(other.checklistMode, checklistMode) || other.checklistMode == checklistMode)&&const DeepCollectionEquality().equals(other.checklistItems, checklistItems)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deviceUpdatedAt, deviceUpdatedAt) || other.deviceUpdatedAt == deviceUpdatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,body,color,boardId,linkedNoteId,linkedNoteTitle,stickyType,sourceName,sourcePath,lane,liveUrl,liveRefreshMinutes,liveRefreshedAt,size,checklistMode,const DeepCollectionEquality().hash(checklistItems),expiresAt,isPinned,sortOrder,updatedAt,deviceUpdatedAt,isDeleted]);

@override
String toString() {
  return 'Sticky(id: $id, title: $title, body: $body, color: $color, boardId: $boardId, linkedNoteId: $linkedNoteId, linkedNoteTitle: $linkedNoteTitle, stickyType: $stickyType, sourceName: $sourceName, sourcePath: $sourcePath, lane: $lane, liveUrl: $liveUrl, liveRefreshMinutes: $liveRefreshMinutes, liveRefreshedAt: $liveRefreshedAt, size: $size, checklistMode: $checklistMode, checklistItems: $checklistItems, expiresAt: $expiresAt, isPinned: $isPinned, sortOrder: $sortOrder, updatedAt: $updatedAt, deviceUpdatedAt: $deviceUpdatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $StickyCopyWith<$Res>  {
  factory $StickyCopyWith(Sticky value, $Res Function(Sticky) _then) = _$StickyCopyWithImpl;
@useResult
$Res call({
 String id, String title, String body,@ColorConverter() Color color, String? boardId, String? linkedNoteId, String? linkedNoteTitle, String stickyType, String? sourceName, String? sourcePath, String lane, String? liveUrl, int liveRefreshMinutes, DateTime? liveRefreshedAt, String size, bool checklistMode, List<StickyChecklistItem> checklistItems, DateTime? expiresAt, bool isPinned, int sortOrder, DateTime updatedAt, DateTime deviceUpdatedAt, bool isDeleted
});




}
/// @nodoc
class _$StickyCopyWithImpl<$Res>
    implements $StickyCopyWith<$Res> {
  _$StickyCopyWithImpl(this._self, this._then);

  final Sticky _self;
  final $Res Function(Sticky) _then;

/// Create a copy of Sticky
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? body = null,Object? color = null,Object? boardId = freezed,Object? linkedNoteId = freezed,Object? linkedNoteTitle = freezed,Object? stickyType = null,Object? sourceName = freezed,Object? sourcePath = freezed,Object? lane = null,Object? liveUrl = freezed,Object? liveRefreshMinutes = null,Object? liveRefreshedAt = freezed,Object? size = null,Object? checklistMode = null,Object? checklistItems = null,Object? expiresAt = freezed,Object? isPinned = null,Object? sortOrder = null,Object? updatedAt = null,Object? deviceUpdatedAt = null,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,boardId: freezed == boardId ? _self.boardId : boardId // ignore: cast_nullable_to_non_nullable
as String?,linkedNoteId: freezed == linkedNoteId ? _self.linkedNoteId : linkedNoteId // ignore: cast_nullable_to_non_nullable
as String?,linkedNoteTitle: freezed == linkedNoteTitle ? _self.linkedNoteTitle : linkedNoteTitle // ignore: cast_nullable_to_non_nullable
as String?,stickyType: null == stickyType ? _self.stickyType : stickyType // ignore: cast_nullable_to_non_nullable
as String,sourceName: freezed == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String?,sourcePath: freezed == sourcePath ? _self.sourcePath : sourcePath // ignore: cast_nullable_to_non_nullable
as String?,lane: null == lane ? _self.lane : lane // ignore: cast_nullable_to_non_nullable
as String,liveUrl: freezed == liveUrl ? _self.liveUrl : liveUrl // ignore: cast_nullable_to_non_nullable
as String?,liveRefreshMinutes: null == liveRefreshMinutes ? _self.liveRefreshMinutes : liveRefreshMinutes // ignore: cast_nullable_to_non_nullable
as int,liveRefreshedAt: freezed == liveRefreshedAt ? _self.liveRefreshedAt : liveRefreshedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,checklistMode: null == checklistMode ? _self.checklistMode : checklistMode // ignore: cast_nullable_to_non_nullable
as bool,checklistItems: null == checklistItems ? _self.checklistItems : checklistItems // ignore: cast_nullable_to_non_nullable
as List<StickyChecklistItem>,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deviceUpdatedAt: null == deviceUpdatedAt ? _self.deviceUpdatedAt : deviceUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Sticky].
extension StickyPatterns on Sticky {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Sticky value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Sticky() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Sticky value)  $default,){
final _that = this;
switch (_that) {
case _Sticky():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Sticky value)?  $default,){
final _that = this;
switch (_that) {
case _Sticky() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String body, @ColorConverter()  Color color,  String? boardId,  String? linkedNoteId,  String? linkedNoteTitle,  String stickyType,  String? sourceName,  String? sourcePath,  String lane,  String? liveUrl,  int liveRefreshMinutes,  DateTime? liveRefreshedAt,  String size,  bool checklistMode,  List<StickyChecklistItem> checklistItems,  DateTime? expiresAt,  bool isPinned,  int sortOrder,  DateTime updatedAt,  DateTime deviceUpdatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Sticky() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.color,_that.boardId,_that.linkedNoteId,_that.linkedNoteTitle,_that.stickyType,_that.sourceName,_that.sourcePath,_that.lane,_that.liveUrl,_that.liveRefreshMinutes,_that.liveRefreshedAt,_that.size,_that.checklistMode,_that.checklistItems,_that.expiresAt,_that.isPinned,_that.sortOrder,_that.updatedAt,_that.deviceUpdatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String body, @ColorConverter()  Color color,  String? boardId,  String? linkedNoteId,  String? linkedNoteTitle,  String stickyType,  String? sourceName,  String? sourcePath,  String lane,  String? liveUrl,  int liveRefreshMinutes,  DateTime? liveRefreshedAt,  String size,  bool checklistMode,  List<StickyChecklistItem> checklistItems,  DateTime? expiresAt,  bool isPinned,  int sortOrder,  DateTime updatedAt,  DateTime deviceUpdatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _Sticky():
return $default(_that.id,_that.title,_that.body,_that.color,_that.boardId,_that.linkedNoteId,_that.linkedNoteTitle,_that.stickyType,_that.sourceName,_that.sourcePath,_that.lane,_that.liveUrl,_that.liveRefreshMinutes,_that.liveRefreshedAt,_that.size,_that.checklistMode,_that.checklistItems,_that.expiresAt,_that.isPinned,_that.sortOrder,_that.updatedAt,_that.deviceUpdatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String body, @ColorConverter()  Color color,  String? boardId,  String? linkedNoteId,  String? linkedNoteTitle,  String stickyType,  String? sourceName,  String? sourcePath,  String lane,  String? liveUrl,  int liveRefreshMinutes,  DateTime? liveRefreshedAt,  String size,  bool checklistMode,  List<StickyChecklistItem> checklistItems,  DateTime? expiresAt,  bool isPinned,  int sortOrder,  DateTime updatedAt,  DateTime deviceUpdatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _Sticky() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.color,_that.boardId,_that.linkedNoteId,_that.linkedNoteTitle,_that.stickyType,_that.sourceName,_that.sourcePath,_that.lane,_that.liveUrl,_that.liveRefreshMinutes,_that.liveRefreshedAt,_that.size,_that.checklistMode,_that.checklistItems,_that.expiresAt,_that.isPinned,_that.sortOrder,_that.updatedAt,_that.deviceUpdatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Sticky extends Sticky {
  const _Sticky({required this.id, this.title = '', required this.body, @ColorConverter() required this.color, this.boardId, this.linkedNoteId, this.linkedNoteTitle, this.stickyType = 'text', this.sourceName, this.sourcePath, this.lane = 'Inbox', this.liveUrl, this.liveRefreshMinutes = 5, this.liveRefreshedAt, this.size = 'medium', this.checklistMode = false, final  List<StickyChecklistItem> checklistItems = const [], this.expiresAt, this.isPinned = false, this.sortOrder = 0, required this.updatedAt, required this.deviceUpdatedAt, this.isDeleted = false}): _checklistItems = checklistItems,super._();
  factory _Sticky.fromJson(Map<String, dynamic> json) => _$StickyFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override final  String body;
@override@ColorConverter() final  Color color;
@override final  String? boardId;
@override final  String? linkedNoteId;
@override final  String? linkedNoteTitle;
@override@JsonKey() final  String stickyType;
@override final  String? sourceName;
@override final  String? sourcePath;
@override@JsonKey() final  String lane;
@override final  String? liveUrl;
@override@JsonKey() final  int liveRefreshMinutes;
@override final  DateTime? liveRefreshedAt;
@override@JsonKey() final  String size;
@override@JsonKey() final  bool checklistMode;
 final  List<StickyChecklistItem> _checklistItems;
@override@JsonKey() List<StickyChecklistItem> get checklistItems {
  if (_checklistItems is EqualUnmodifiableListView) return _checklistItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_checklistItems);
}

@override final  DateTime? expiresAt;
@override@JsonKey() final  bool isPinned;
@override@JsonKey() final  int sortOrder;
@override final  DateTime updatedAt;
@override final  DateTime deviceUpdatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of Sticky
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StickyCopyWith<_Sticky> get copyWith => __$StickyCopyWithImpl<_Sticky>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StickyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sticky&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.color, color) || other.color == color)&&(identical(other.boardId, boardId) || other.boardId == boardId)&&(identical(other.linkedNoteId, linkedNoteId) || other.linkedNoteId == linkedNoteId)&&(identical(other.linkedNoteTitle, linkedNoteTitle) || other.linkedNoteTitle == linkedNoteTitle)&&(identical(other.stickyType, stickyType) || other.stickyType == stickyType)&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.sourcePath, sourcePath) || other.sourcePath == sourcePath)&&(identical(other.lane, lane) || other.lane == lane)&&(identical(other.liveUrl, liveUrl) || other.liveUrl == liveUrl)&&(identical(other.liveRefreshMinutes, liveRefreshMinutes) || other.liveRefreshMinutes == liveRefreshMinutes)&&(identical(other.liveRefreshedAt, liveRefreshedAt) || other.liveRefreshedAt == liveRefreshedAt)&&(identical(other.size, size) || other.size == size)&&(identical(other.checklistMode, checklistMode) || other.checklistMode == checklistMode)&&const DeepCollectionEquality().equals(other._checklistItems, _checklistItems)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deviceUpdatedAt, deviceUpdatedAt) || other.deviceUpdatedAt == deviceUpdatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,body,color,boardId,linkedNoteId,linkedNoteTitle,stickyType,sourceName,sourcePath,lane,liveUrl,liveRefreshMinutes,liveRefreshedAt,size,checklistMode,const DeepCollectionEquality().hash(_checklistItems),expiresAt,isPinned,sortOrder,updatedAt,deviceUpdatedAt,isDeleted]);

@override
String toString() {
  return 'Sticky(id: $id, title: $title, body: $body, color: $color, boardId: $boardId, linkedNoteId: $linkedNoteId, linkedNoteTitle: $linkedNoteTitle, stickyType: $stickyType, sourceName: $sourceName, sourcePath: $sourcePath, lane: $lane, liveUrl: $liveUrl, liveRefreshMinutes: $liveRefreshMinutes, liveRefreshedAt: $liveRefreshedAt, size: $size, checklistMode: $checklistMode, checklistItems: $checklistItems, expiresAt: $expiresAt, isPinned: $isPinned, sortOrder: $sortOrder, updatedAt: $updatedAt, deviceUpdatedAt: $deviceUpdatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$StickyCopyWith<$Res> implements $StickyCopyWith<$Res> {
  factory _$StickyCopyWith(_Sticky value, $Res Function(_Sticky) _then) = __$StickyCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String body,@ColorConverter() Color color, String? boardId, String? linkedNoteId, String? linkedNoteTitle, String stickyType, String? sourceName, String? sourcePath, String lane, String? liveUrl, int liveRefreshMinutes, DateTime? liveRefreshedAt, String size, bool checklistMode, List<StickyChecklistItem> checklistItems, DateTime? expiresAt, bool isPinned, int sortOrder, DateTime updatedAt, DateTime deviceUpdatedAt, bool isDeleted
});




}
/// @nodoc
class __$StickyCopyWithImpl<$Res>
    implements _$StickyCopyWith<$Res> {
  __$StickyCopyWithImpl(this._self, this._then);

  final _Sticky _self;
  final $Res Function(_Sticky) _then;

/// Create a copy of Sticky
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? body = null,Object? color = null,Object? boardId = freezed,Object? linkedNoteId = freezed,Object? linkedNoteTitle = freezed,Object? stickyType = null,Object? sourceName = freezed,Object? sourcePath = freezed,Object? lane = null,Object? liveUrl = freezed,Object? liveRefreshMinutes = null,Object? liveRefreshedAt = freezed,Object? size = null,Object? checklistMode = null,Object? checklistItems = null,Object? expiresAt = freezed,Object? isPinned = null,Object? sortOrder = null,Object? updatedAt = null,Object? deviceUpdatedAt = null,Object? isDeleted = null,}) {
  return _then(_Sticky(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,boardId: freezed == boardId ? _self.boardId : boardId // ignore: cast_nullable_to_non_nullable
as String?,linkedNoteId: freezed == linkedNoteId ? _self.linkedNoteId : linkedNoteId // ignore: cast_nullable_to_non_nullable
as String?,linkedNoteTitle: freezed == linkedNoteTitle ? _self.linkedNoteTitle : linkedNoteTitle // ignore: cast_nullable_to_non_nullable
as String?,stickyType: null == stickyType ? _self.stickyType : stickyType // ignore: cast_nullable_to_non_nullable
as String,sourceName: freezed == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String?,sourcePath: freezed == sourcePath ? _self.sourcePath : sourcePath // ignore: cast_nullable_to_non_nullable
as String?,lane: null == lane ? _self.lane : lane // ignore: cast_nullable_to_non_nullable
as String,liveUrl: freezed == liveUrl ? _self.liveUrl : liveUrl // ignore: cast_nullable_to_non_nullable
as String?,liveRefreshMinutes: null == liveRefreshMinutes ? _self.liveRefreshMinutes : liveRefreshMinutes // ignore: cast_nullable_to_non_nullable
as int,liveRefreshedAt: freezed == liveRefreshedAt ? _self.liveRefreshedAt : liveRefreshedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,checklistMode: null == checklistMode ? _self.checklistMode : checklistMode // ignore: cast_nullable_to_non_nullable
as bool,checklistItems: null == checklistItems ? _self._checklistItems : checklistItems // ignore: cast_nullable_to_non_nullable
as List<StickyChecklistItem>,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deviceUpdatedAt: null == deviceUpdatedAt ? _self.deviceUpdatedAt : deviceUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
