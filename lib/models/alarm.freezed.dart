// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alarm.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlarmModel {

 String get id; int get platformId; String get label; String get soundPath; String get soundCategory; String get soundPackId; String get fallbackSoundPath; double get alarmVolume; int get wakeCheckMinutes; String? get noteId; int get hour; int get minute; List<bool> get repeatDays; bool get isEnabled; DateTime? get scheduledAt; QuestConfig get quest;
/// Create a copy of AlarmModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlarmModelCopyWith<AlarmModel> get copyWith => _$AlarmModelCopyWithImpl<AlarmModel>(this as AlarmModel, _$identity);

  /// Serializes this AlarmModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlarmModel&&(identical(other.id, id) || other.id == id)&&(identical(other.platformId, platformId) || other.platformId == platformId)&&(identical(other.label, label) || other.label == label)&&(identical(other.soundPath, soundPath) || other.soundPath == soundPath)&&(identical(other.soundCategory, soundCategory) || other.soundCategory == soundCategory)&&(identical(other.soundPackId, soundPackId) || other.soundPackId == soundPackId)&&(identical(other.fallbackSoundPath, fallbackSoundPath) || other.fallbackSoundPath == fallbackSoundPath)&&(identical(other.alarmVolume, alarmVolume) || other.alarmVolume == alarmVolume)&&(identical(other.wakeCheckMinutes, wakeCheckMinutes) || other.wakeCheckMinutes == wakeCheckMinutes)&&(identical(other.noteId, noteId) || other.noteId == noteId)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.minute, minute) || other.minute == minute)&&const DeepCollectionEquality().equals(other.repeatDays, repeatDays)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.quest, quest) || other.quest == quest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,platformId,label,soundPath,soundCategory,soundPackId,fallbackSoundPath,alarmVolume,wakeCheckMinutes,noteId,hour,minute,const DeepCollectionEquality().hash(repeatDays),isEnabled,scheduledAt,quest);

@override
String toString() {
  return 'AlarmModel(id: $id, platformId: $platformId, label: $label, soundPath: $soundPath, soundCategory: $soundCategory, soundPackId: $soundPackId, fallbackSoundPath: $fallbackSoundPath, alarmVolume: $alarmVolume, wakeCheckMinutes: $wakeCheckMinutes, noteId: $noteId, hour: $hour, minute: $minute, repeatDays: $repeatDays, isEnabled: $isEnabled, scheduledAt: $scheduledAt, quest: $quest)';
}


}

/// @nodoc
abstract mixin class $AlarmModelCopyWith<$Res>  {
  factory $AlarmModelCopyWith(AlarmModel value, $Res Function(AlarmModel) _then) = _$AlarmModelCopyWithImpl;
@useResult
$Res call({
 String id, int platformId, String label, String soundPath, String soundCategory, String soundPackId, String fallbackSoundPath, double alarmVolume, int wakeCheckMinutes, String? noteId, int hour, int minute, List<bool> repeatDays, bool isEnabled, DateTime? scheduledAt, QuestConfig quest
});


$QuestConfigCopyWith<$Res> get quest;

}
/// @nodoc
class _$AlarmModelCopyWithImpl<$Res>
    implements $AlarmModelCopyWith<$Res> {
  _$AlarmModelCopyWithImpl(this._self, this._then);

  final AlarmModel _self;
  final $Res Function(AlarmModel) _then;

/// Create a copy of AlarmModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? platformId = null,Object? label = null,Object? soundPath = null,Object? soundCategory = null,Object? soundPackId = null,Object? fallbackSoundPath = null,Object? alarmVolume = null,Object? wakeCheckMinutes = null,Object? noteId = freezed,Object? hour = null,Object? minute = null,Object? repeatDays = null,Object? isEnabled = null,Object? scheduledAt = freezed,Object? quest = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,platformId: null == platformId ? _self.platformId : platformId // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,soundPath: null == soundPath ? _self.soundPath : soundPath // ignore: cast_nullable_to_non_nullable
as String,soundCategory: null == soundCategory ? _self.soundCategory : soundCategory // ignore: cast_nullable_to_non_nullable
as String,soundPackId: null == soundPackId ? _self.soundPackId : soundPackId // ignore: cast_nullable_to_non_nullable
as String,fallbackSoundPath: null == fallbackSoundPath ? _self.fallbackSoundPath : fallbackSoundPath // ignore: cast_nullable_to_non_nullable
as String,alarmVolume: null == alarmVolume ? _self.alarmVolume : alarmVolume // ignore: cast_nullable_to_non_nullable
as double,wakeCheckMinutes: null == wakeCheckMinutes ? _self.wakeCheckMinutes : wakeCheckMinutes // ignore: cast_nullable_to_non_nullable
as int,noteId: freezed == noteId ? _self.noteId : noteId // ignore: cast_nullable_to_non_nullable
as String?,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,repeatDays: null == repeatDays ? _self.repeatDays : repeatDays // ignore: cast_nullable_to_non_nullable
as List<bool>,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,quest: null == quest ? _self.quest : quest // ignore: cast_nullable_to_non_nullable
as QuestConfig,
  ));
}
/// Create a copy of AlarmModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuestConfigCopyWith<$Res> get quest {
  
  return $QuestConfigCopyWith<$Res>(_self.quest, (value) {
    return _then(_self.copyWith(quest: value));
  });
}
}


/// Adds pattern-matching-related methods to [AlarmModel].
extension AlarmModelPatterns on AlarmModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlarmModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlarmModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlarmModel value)  $default,){
final _that = this;
switch (_that) {
case _AlarmModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlarmModel value)?  $default,){
final _that = this;
switch (_that) {
case _AlarmModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int platformId,  String label,  String soundPath,  String soundCategory,  String soundPackId,  String fallbackSoundPath,  double alarmVolume,  int wakeCheckMinutes,  String? noteId,  int hour,  int minute,  List<bool> repeatDays,  bool isEnabled,  DateTime? scheduledAt,  QuestConfig quest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlarmModel() when $default != null:
return $default(_that.id,_that.platformId,_that.label,_that.soundPath,_that.soundCategory,_that.soundPackId,_that.fallbackSoundPath,_that.alarmVolume,_that.wakeCheckMinutes,_that.noteId,_that.hour,_that.minute,_that.repeatDays,_that.isEnabled,_that.scheduledAt,_that.quest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int platformId,  String label,  String soundPath,  String soundCategory,  String soundPackId,  String fallbackSoundPath,  double alarmVolume,  int wakeCheckMinutes,  String? noteId,  int hour,  int minute,  List<bool> repeatDays,  bool isEnabled,  DateTime? scheduledAt,  QuestConfig quest)  $default,) {final _that = this;
switch (_that) {
case _AlarmModel():
return $default(_that.id,_that.platformId,_that.label,_that.soundPath,_that.soundCategory,_that.soundPackId,_that.fallbackSoundPath,_that.alarmVolume,_that.wakeCheckMinutes,_that.noteId,_that.hour,_that.minute,_that.repeatDays,_that.isEnabled,_that.scheduledAt,_that.quest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int platformId,  String label,  String soundPath,  String soundCategory,  String soundPackId,  String fallbackSoundPath,  double alarmVolume,  int wakeCheckMinutes,  String? noteId,  int hour,  int minute,  List<bool> repeatDays,  bool isEnabled,  DateTime? scheduledAt,  QuestConfig quest)?  $default,) {final _that = this;
switch (_that) {
case _AlarmModel() when $default != null:
return $default(_that.id,_that.platformId,_that.label,_that.soundPath,_that.soundCategory,_that.soundPackId,_that.fallbackSoundPath,_that.alarmVolume,_that.wakeCheckMinutes,_that.noteId,_that.hour,_that.minute,_that.repeatDays,_that.isEnabled,_that.scheduledAt,_that.quest);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _AlarmModel extends AlarmModel {
  const _AlarmModel({required this.id, required this.platformId, required this.label, required this.soundPath, this.soundCategory = 'Motivation', this.soundPackId = 'genius_brain_frequency', this.fallbackSoundPath = 'assets/alarm.mp3', this.alarmVolume = 1.0, this.wakeCheckMinutes = 0, this.noteId, required this.hour, required this.minute, required final  List<bool> repeatDays, required this.isEnabled, this.scheduledAt, required this.quest}): _repeatDays = repeatDays,super._();
  factory _AlarmModel.fromJson(Map<String, dynamic> json) => _$AlarmModelFromJson(json);

@override final  String id;
@override final  int platformId;
@override final  String label;
@override final  String soundPath;
@override@JsonKey() final  String soundCategory;
@override@JsonKey() final  String soundPackId;
@override@JsonKey() final  String fallbackSoundPath;
@override@JsonKey() final  double alarmVolume;
@override@JsonKey() final  int wakeCheckMinutes;
@override final  String? noteId;
@override final  int hour;
@override final  int minute;
 final  List<bool> _repeatDays;
@override List<bool> get repeatDays {
  if (_repeatDays is EqualUnmodifiableListView) return _repeatDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_repeatDays);
}

@override final  bool isEnabled;
@override final  DateTime? scheduledAt;
@override final  QuestConfig quest;

/// Create a copy of AlarmModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlarmModelCopyWith<_AlarmModel> get copyWith => __$AlarmModelCopyWithImpl<_AlarmModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlarmModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlarmModel&&(identical(other.id, id) || other.id == id)&&(identical(other.platformId, platformId) || other.platformId == platformId)&&(identical(other.label, label) || other.label == label)&&(identical(other.soundPath, soundPath) || other.soundPath == soundPath)&&(identical(other.soundCategory, soundCategory) || other.soundCategory == soundCategory)&&(identical(other.soundPackId, soundPackId) || other.soundPackId == soundPackId)&&(identical(other.fallbackSoundPath, fallbackSoundPath) || other.fallbackSoundPath == fallbackSoundPath)&&(identical(other.alarmVolume, alarmVolume) || other.alarmVolume == alarmVolume)&&(identical(other.wakeCheckMinutes, wakeCheckMinutes) || other.wakeCheckMinutes == wakeCheckMinutes)&&(identical(other.noteId, noteId) || other.noteId == noteId)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.minute, minute) || other.minute == minute)&&const DeepCollectionEquality().equals(other._repeatDays, _repeatDays)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.quest, quest) || other.quest == quest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,platformId,label,soundPath,soundCategory,soundPackId,fallbackSoundPath,alarmVolume,wakeCheckMinutes,noteId,hour,minute,const DeepCollectionEquality().hash(_repeatDays),isEnabled,scheduledAt,quest);

@override
String toString() {
  return 'AlarmModel(id: $id, platformId: $platformId, label: $label, soundPath: $soundPath, soundCategory: $soundCategory, soundPackId: $soundPackId, fallbackSoundPath: $fallbackSoundPath, alarmVolume: $alarmVolume, wakeCheckMinutes: $wakeCheckMinutes, noteId: $noteId, hour: $hour, minute: $minute, repeatDays: $repeatDays, isEnabled: $isEnabled, scheduledAt: $scheduledAt, quest: $quest)';
}


}

/// @nodoc
abstract mixin class _$AlarmModelCopyWith<$Res> implements $AlarmModelCopyWith<$Res> {
  factory _$AlarmModelCopyWith(_AlarmModel value, $Res Function(_AlarmModel) _then) = __$AlarmModelCopyWithImpl;
@override @useResult
$Res call({
 String id, int platformId, String label, String soundPath, String soundCategory, String soundPackId, String fallbackSoundPath, double alarmVolume, int wakeCheckMinutes, String? noteId, int hour, int minute, List<bool> repeatDays, bool isEnabled, DateTime? scheduledAt, QuestConfig quest
});


@override $QuestConfigCopyWith<$Res> get quest;

}
/// @nodoc
class __$AlarmModelCopyWithImpl<$Res>
    implements _$AlarmModelCopyWith<$Res> {
  __$AlarmModelCopyWithImpl(this._self, this._then);

  final _AlarmModel _self;
  final $Res Function(_AlarmModel) _then;

/// Create a copy of AlarmModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? platformId = null,Object? label = null,Object? soundPath = null,Object? soundCategory = null,Object? soundPackId = null,Object? fallbackSoundPath = null,Object? alarmVolume = null,Object? wakeCheckMinutes = null,Object? noteId = freezed,Object? hour = null,Object? minute = null,Object? repeatDays = null,Object? isEnabled = null,Object? scheduledAt = freezed,Object? quest = null,}) {
  return _then(_AlarmModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,platformId: null == platformId ? _self.platformId : platformId // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,soundPath: null == soundPath ? _self.soundPath : soundPath // ignore: cast_nullable_to_non_nullable
as String,soundCategory: null == soundCategory ? _self.soundCategory : soundCategory // ignore: cast_nullable_to_non_nullable
as String,soundPackId: null == soundPackId ? _self.soundPackId : soundPackId // ignore: cast_nullable_to_non_nullable
as String,fallbackSoundPath: null == fallbackSoundPath ? _self.fallbackSoundPath : fallbackSoundPath // ignore: cast_nullable_to_non_nullable
as String,alarmVolume: null == alarmVolume ? _self.alarmVolume : alarmVolume // ignore: cast_nullable_to_non_nullable
as double,wakeCheckMinutes: null == wakeCheckMinutes ? _self.wakeCheckMinutes : wakeCheckMinutes // ignore: cast_nullable_to_non_nullable
as int,noteId: freezed == noteId ? _self.noteId : noteId // ignore: cast_nullable_to_non_nullable
as String?,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,repeatDays: null == repeatDays ? _self._repeatDays : repeatDays // ignore: cast_nullable_to_non_nullable
as List<bool>,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,quest: null == quest ? _self.quest : quest // ignore: cast_nullable_to_non_nullable
as QuestConfig,
  ));
}

/// Create a copy of AlarmModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuestConfigCopyWith<$Res> get quest {
  
  return $QuestConfigCopyWith<$Res>(_self.quest, (value) {
    return _then(_self.copyWith(quest: value));
  });
}
}

// dart format on
