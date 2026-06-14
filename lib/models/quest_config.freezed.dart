// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quest_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuestConfig {

 QuestType get type; int get missionSeconds; List<String> get missionSlots;// Math
 String get mathDifficulty; int get mathRepeatCount;// Type sentence
 String get sentence; int get typingPhraseCount;// Simon Says
 int get gridSize; int get simonRounds;// QR
 String get qrValue; List<String> get qrOptions;// Squat / Pushup / Situp
 int get squatCount; List<String> get randomQuestTypes;
/// Create a copy of QuestConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestConfigCopyWith<QuestConfig> get copyWith => _$QuestConfigCopyWithImpl<QuestConfig>(this as QuestConfig, _$identity);

  /// Serializes this QuestConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuestConfig&&(identical(other.type, type) || other.type == type)&&(identical(other.missionSeconds, missionSeconds) || other.missionSeconds == missionSeconds)&&const DeepCollectionEquality().equals(other.missionSlots, missionSlots)&&(identical(other.mathDifficulty, mathDifficulty) || other.mathDifficulty == mathDifficulty)&&(identical(other.mathRepeatCount, mathRepeatCount) || other.mathRepeatCount == mathRepeatCount)&&(identical(other.sentence, sentence) || other.sentence == sentence)&&(identical(other.typingPhraseCount, typingPhraseCount) || other.typingPhraseCount == typingPhraseCount)&&(identical(other.gridSize, gridSize) || other.gridSize == gridSize)&&(identical(other.simonRounds, simonRounds) || other.simonRounds == simonRounds)&&(identical(other.qrValue, qrValue) || other.qrValue == qrValue)&&const DeepCollectionEquality().equals(other.qrOptions, qrOptions)&&(identical(other.squatCount, squatCount) || other.squatCount == squatCount)&&const DeepCollectionEquality().equals(other.randomQuestTypes, randomQuestTypes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,missionSeconds,const DeepCollectionEquality().hash(missionSlots),mathDifficulty,mathRepeatCount,sentence,typingPhraseCount,gridSize,simonRounds,qrValue,const DeepCollectionEquality().hash(qrOptions),squatCount,const DeepCollectionEquality().hash(randomQuestTypes));

@override
String toString() {
  return 'QuestConfig(type: $type, missionSeconds: $missionSeconds, missionSlots: $missionSlots, mathDifficulty: $mathDifficulty, mathRepeatCount: $mathRepeatCount, sentence: $sentence, typingPhraseCount: $typingPhraseCount, gridSize: $gridSize, simonRounds: $simonRounds, qrValue: $qrValue, qrOptions: $qrOptions, squatCount: $squatCount, randomQuestTypes: $randomQuestTypes)';
}


}

/// @nodoc
abstract mixin class $QuestConfigCopyWith<$Res>  {
  factory $QuestConfigCopyWith(QuestConfig value, $Res Function(QuestConfig) _then) = _$QuestConfigCopyWithImpl;
@useResult
$Res call({
 QuestType type, int missionSeconds, List<String> missionSlots, String mathDifficulty, int mathRepeatCount, String sentence, int typingPhraseCount, int gridSize, int simonRounds, String qrValue, List<String> qrOptions, int squatCount, List<String> randomQuestTypes
});




}
/// @nodoc
class _$QuestConfigCopyWithImpl<$Res>
    implements $QuestConfigCopyWith<$Res> {
  _$QuestConfigCopyWithImpl(this._self, this._then);

  final QuestConfig _self;
  final $Res Function(QuestConfig) _then;

/// Create a copy of QuestConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? missionSeconds = null,Object? missionSlots = null,Object? mathDifficulty = null,Object? mathRepeatCount = null,Object? sentence = null,Object? typingPhraseCount = null,Object? gridSize = null,Object? simonRounds = null,Object? qrValue = null,Object? qrOptions = null,Object? squatCount = null,Object? randomQuestTypes = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as QuestType,missionSeconds: null == missionSeconds ? _self.missionSeconds : missionSeconds // ignore: cast_nullable_to_non_nullable
as int,missionSlots: null == missionSlots ? _self.missionSlots : missionSlots // ignore: cast_nullable_to_non_nullable
as List<String>,mathDifficulty: null == mathDifficulty ? _self.mathDifficulty : mathDifficulty // ignore: cast_nullable_to_non_nullable
as String,mathRepeatCount: null == mathRepeatCount ? _self.mathRepeatCount : mathRepeatCount // ignore: cast_nullable_to_non_nullable
as int,sentence: null == sentence ? _self.sentence : sentence // ignore: cast_nullable_to_non_nullable
as String,typingPhraseCount: null == typingPhraseCount ? _self.typingPhraseCount : typingPhraseCount // ignore: cast_nullable_to_non_nullable
as int,gridSize: null == gridSize ? _self.gridSize : gridSize // ignore: cast_nullable_to_non_nullable
as int,simonRounds: null == simonRounds ? _self.simonRounds : simonRounds // ignore: cast_nullable_to_non_nullable
as int,qrValue: null == qrValue ? _self.qrValue : qrValue // ignore: cast_nullable_to_non_nullable
as String,qrOptions: null == qrOptions ? _self.qrOptions : qrOptions // ignore: cast_nullable_to_non_nullable
as List<String>,squatCount: null == squatCount ? _self.squatCount : squatCount // ignore: cast_nullable_to_non_nullable
as int,randomQuestTypes: null == randomQuestTypes ? _self.randomQuestTypes : randomQuestTypes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [QuestConfig].
extension QuestConfigPatterns on QuestConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuestConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuestConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuestConfig value)  $default,){
final _that = this;
switch (_that) {
case _QuestConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuestConfig value)?  $default,){
final _that = this;
switch (_that) {
case _QuestConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( QuestType type,  int missionSeconds,  List<String> missionSlots,  String mathDifficulty,  int mathRepeatCount,  String sentence,  int typingPhraseCount,  int gridSize,  int simonRounds,  String qrValue,  List<String> qrOptions,  int squatCount,  List<String> randomQuestTypes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuestConfig() when $default != null:
return $default(_that.type,_that.missionSeconds,_that.missionSlots,_that.mathDifficulty,_that.mathRepeatCount,_that.sentence,_that.typingPhraseCount,_that.gridSize,_that.simonRounds,_that.qrValue,_that.qrOptions,_that.squatCount,_that.randomQuestTypes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( QuestType type,  int missionSeconds,  List<String> missionSlots,  String mathDifficulty,  int mathRepeatCount,  String sentence,  int typingPhraseCount,  int gridSize,  int simonRounds,  String qrValue,  List<String> qrOptions,  int squatCount,  List<String> randomQuestTypes)  $default,) {final _that = this;
switch (_that) {
case _QuestConfig():
return $default(_that.type,_that.missionSeconds,_that.missionSlots,_that.mathDifficulty,_that.mathRepeatCount,_that.sentence,_that.typingPhraseCount,_that.gridSize,_that.simonRounds,_that.qrValue,_that.qrOptions,_that.squatCount,_that.randomQuestTypes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( QuestType type,  int missionSeconds,  List<String> missionSlots,  String mathDifficulty,  int mathRepeatCount,  String sentence,  int typingPhraseCount,  int gridSize,  int simonRounds,  String qrValue,  List<String> qrOptions,  int squatCount,  List<String> randomQuestTypes)?  $default,) {final _that = this;
switch (_that) {
case _QuestConfig() when $default != null:
return $default(_that.type,_that.missionSeconds,_that.missionSlots,_that.mathDifficulty,_that.mathRepeatCount,_that.sentence,_that.typingPhraseCount,_that.gridSize,_that.simonRounds,_that.qrValue,_that.qrOptions,_that.squatCount,_that.randomQuestTypes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _QuestConfig implements QuestConfig {
  const _QuestConfig({this.type = QuestType.none, this.missionSeconds = 30, final  List<String> missionSlots = const [], this.mathDifficulty = 'easy', this.mathRepeatCount = 1, this.sentence = 'I am awake and ready for the day', this.typingPhraseCount = 1, this.gridSize = 3, this.simonRounds = 3, this.qrValue = '', final  List<String> qrOptions = const [], this.squatCount = 10, final  List<String> randomQuestTypes = const []}): _missionSlots = missionSlots,_qrOptions = qrOptions,_randomQuestTypes = randomQuestTypes;
  factory _QuestConfig.fromJson(Map<String, dynamic> json) => _$QuestConfigFromJson(json);

@override@JsonKey() final  QuestType type;
@override@JsonKey() final  int missionSeconds;
 final  List<String> _missionSlots;
@override@JsonKey() List<String> get missionSlots {
  if (_missionSlots is EqualUnmodifiableListView) return _missionSlots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missionSlots);
}

// Math
@override@JsonKey() final  String mathDifficulty;
@override@JsonKey() final  int mathRepeatCount;
// Type sentence
@override@JsonKey() final  String sentence;
@override@JsonKey() final  int typingPhraseCount;
// Simon Says
@override@JsonKey() final  int gridSize;
@override@JsonKey() final  int simonRounds;
// QR
@override@JsonKey() final  String qrValue;
 final  List<String> _qrOptions;
@override@JsonKey() List<String> get qrOptions {
  if (_qrOptions is EqualUnmodifiableListView) return _qrOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_qrOptions);
}

// Squat / Pushup / Situp
@override@JsonKey() final  int squatCount;
 final  List<String> _randomQuestTypes;
@override@JsonKey() List<String> get randomQuestTypes {
  if (_randomQuestTypes is EqualUnmodifiableListView) return _randomQuestTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_randomQuestTypes);
}


/// Create a copy of QuestConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestConfigCopyWith<_QuestConfig> get copyWith => __$QuestConfigCopyWithImpl<_QuestConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuestConfig&&(identical(other.type, type) || other.type == type)&&(identical(other.missionSeconds, missionSeconds) || other.missionSeconds == missionSeconds)&&const DeepCollectionEquality().equals(other._missionSlots, _missionSlots)&&(identical(other.mathDifficulty, mathDifficulty) || other.mathDifficulty == mathDifficulty)&&(identical(other.mathRepeatCount, mathRepeatCount) || other.mathRepeatCount == mathRepeatCount)&&(identical(other.sentence, sentence) || other.sentence == sentence)&&(identical(other.typingPhraseCount, typingPhraseCount) || other.typingPhraseCount == typingPhraseCount)&&(identical(other.gridSize, gridSize) || other.gridSize == gridSize)&&(identical(other.simonRounds, simonRounds) || other.simonRounds == simonRounds)&&(identical(other.qrValue, qrValue) || other.qrValue == qrValue)&&const DeepCollectionEquality().equals(other._qrOptions, _qrOptions)&&(identical(other.squatCount, squatCount) || other.squatCount == squatCount)&&const DeepCollectionEquality().equals(other._randomQuestTypes, _randomQuestTypes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,missionSeconds,const DeepCollectionEquality().hash(_missionSlots),mathDifficulty,mathRepeatCount,sentence,typingPhraseCount,gridSize,simonRounds,qrValue,const DeepCollectionEquality().hash(_qrOptions),squatCount,const DeepCollectionEquality().hash(_randomQuestTypes));

@override
String toString() {
  return 'QuestConfig(type: $type, missionSeconds: $missionSeconds, missionSlots: $missionSlots, mathDifficulty: $mathDifficulty, mathRepeatCount: $mathRepeatCount, sentence: $sentence, typingPhraseCount: $typingPhraseCount, gridSize: $gridSize, simonRounds: $simonRounds, qrValue: $qrValue, qrOptions: $qrOptions, squatCount: $squatCount, randomQuestTypes: $randomQuestTypes)';
}


}

/// @nodoc
abstract mixin class _$QuestConfigCopyWith<$Res> implements $QuestConfigCopyWith<$Res> {
  factory _$QuestConfigCopyWith(_QuestConfig value, $Res Function(_QuestConfig) _then) = __$QuestConfigCopyWithImpl;
@override @useResult
$Res call({
 QuestType type, int missionSeconds, List<String> missionSlots, String mathDifficulty, int mathRepeatCount, String sentence, int typingPhraseCount, int gridSize, int simonRounds, String qrValue, List<String> qrOptions, int squatCount, List<String> randomQuestTypes
});




}
/// @nodoc
class __$QuestConfigCopyWithImpl<$Res>
    implements _$QuestConfigCopyWith<$Res> {
  __$QuestConfigCopyWithImpl(this._self, this._then);

  final _QuestConfig _self;
  final $Res Function(_QuestConfig) _then;

/// Create a copy of QuestConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? missionSeconds = null,Object? missionSlots = null,Object? mathDifficulty = null,Object? mathRepeatCount = null,Object? sentence = null,Object? typingPhraseCount = null,Object? gridSize = null,Object? simonRounds = null,Object? qrValue = null,Object? qrOptions = null,Object? squatCount = null,Object? randomQuestTypes = null,}) {
  return _then(_QuestConfig(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as QuestType,missionSeconds: null == missionSeconds ? _self.missionSeconds : missionSeconds // ignore: cast_nullable_to_non_nullable
as int,missionSlots: null == missionSlots ? _self._missionSlots : missionSlots // ignore: cast_nullable_to_non_nullable
as List<String>,mathDifficulty: null == mathDifficulty ? _self.mathDifficulty : mathDifficulty // ignore: cast_nullable_to_non_nullable
as String,mathRepeatCount: null == mathRepeatCount ? _self.mathRepeatCount : mathRepeatCount // ignore: cast_nullable_to_non_nullable
as int,sentence: null == sentence ? _self.sentence : sentence // ignore: cast_nullable_to_non_nullable
as String,typingPhraseCount: null == typingPhraseCount ? _self.typingPhraseCount : typingPhraseCount // ignore: cast_nullable_to_non_nullable
as int,gridSize: null == gridSize ? _self.gridSize : gridSize // ignore: cast_nullable_to_non_nullable
as int,simonRounds: null == simonRounds ? _self.simonRounds : simonRounds // ignore: cast_nullable_to_non_nullable
as int,qrValue: null == qrValue ? _self.qrValue : qrValue // ignore: cast_nullable_to_non_nullable
as String,qrOptions: null == qrOptions ? _self._qrOptions : qrOptions // ignore: cast_nullable_to_non_nullable
as List<String>,squatCount: null == squatCount ? _self.squatCount : squatCount // ignore: cast_nullable_to_non_nullable
as int,randomQuestTypes: null == randomQuestTypes ? _self._randomQuestTypes : randomQuestTypes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
