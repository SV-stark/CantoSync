// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppSettings {

 ThemeMode get themeMode; AudioPreset get audioPreset; List<String> get libraryPaths; bool get skipSilence; bool get loudnessNormalization; PlayerThemeMode get playerThemeMode; bool get showWaveform; bool get showCoverReflection;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.audioPreset, audioPreset) || other.audioPreset == audioPreset)&&const DeepCollectionEquality().equals(other.libraryPaths, libraryPaths)&&(identical(other.skipSilence, skipSilence) || other.skipSilence == skipSilence)&&(identical(other.loudnessNormalization, loudnessNormalization) || other.loudnessNormalization == loudnessNormalization)&&(identical(other.playerThemeMode, playerThemeMode) || other.playerThemeMode == playerThemeMode)&&(identical(other.showWaveform, showWaveform) || other.showWaveform == showWaveform)&&(identical(other.showCoverReflection, showCoverReflection) || other.showCoverReflection == showCoverReflection));
}


@override
int get hashCode => Object.hash(runtimeType,themeMode,audioPreset,const DeepCollectionEquality().hash(libraryPaths),skipSilence,loudnessNormalization,playerThemeMode,showWaveform,showCoverReflection);

@override
String toString() {
  return 'AppSettings(themeMode: $themeMode, audioPreset: $audioPreset, libraryPaths: $libraryPaths, skipSilence: $skipSilence, loudnessNormalization: $loudnessNormalization, playerThemeMode: $playerThemeMode, showWaveform: $showWaveform, showCoverReflection: $showCoverReflection)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 ThemeMode themeMode, AudioPreset audioPreset, List<String> libraryPaths, bool skipSilence, bool loudnessNormalization, PlayerThemeMode playerThemeMode, bool showWaveform, bool showCoverReflection
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? audioPreset = null,Object? libraryPaths = null,Object? skipSilence = null,Object? loudnessNormalization = null,Object? playerThemeMode = null,Object? showWaveform = null,Object? showCoverReflection = null,}) {
  return _then(_self.copyWith(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,audioPreset: null == audioPreset ? _self.audioPreset : audioPreset // ignore: cast_nullable_to_non_nullable
as AudioPreset,libraryPaths: null == libraryPaths ? _self.libraryPaths : libraryPaths // ignore: cast_nullable_to_non_nullable
as List<String>,skipSilence: null == skipSilence ? _self.skipSilence : skipSilence // ignore: cast_nullable_to_non_nullable
as bool,loudnessNormalization: null == loudnessNormalization ? _self.loudnessNormalization : loudnessNormalization // ignore: cast_nullable_to_non_nullable
as bool,playerThemeMode: null == playerThemeMode ? _self.playerThemeMode : playerThemeMode // ignore: cast_nullable_to_non_nullable
as PlayerThemeMode,showWaveform: null == showWaveform ? _self.showWaveform : showWaveform // ignore: cast_nullable_to_non_nullable
as bool,showCoverReflection: null == showCoverReflection ? _self.showCoverReflection : showCoverReflection // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ThemeMode themeMode,  AudioPreset audioPreset,  List<String> libraryPaths,  bool skipSilence,  bool loudnessNormalization,  PlayerThemeMode playerThemeMode,  bool showWaveform,  bool showCoverReflection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.themeMode,_that.audioPreset,_that.libraryPaths,_that.skipSilence,_that.loudnessNormalization,_that.playerThemeMode,_that.showWaveform,_that.showCoverReflection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ThemeMode themeMode,  AudioPreset audioPreset,  List<String> libraryPaths,  bool skipSilence,  bool loudnessNormalization,  PlayerThemeMode playerThemeMode,  bool showWaveform,  bool showCoverReflection)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.themeMode,_that.audioPreset,_that.libraryPaths,_that.skipSilence,_that.loudnessNormalization,_that.playerThemeMode,_that.showWaveform,_that.showCoverReflection);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ThemeMode themeMode,  AudioPreset audioPreset,  List<String> libraryPaths,  bool skipSilence,  bool loudnessNormalization,  PlayerThemeMode playerThemeMode,  bool showWaveform,  bool showCoverReflection)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.themeMode,_that.audioPreset,_that.libraryPaths,_that.skipSilence,_that.loudnessNormalization,_that.playerThemeMode,_that.showWaveform,_that.showCoverReflection);case _:
  return null;

}
}

}

/// @nodoc


class _AppSettings implements AppSettings {
  const _AppSettings({this.themeMode = ThemeMode.system, this.audioPreset = AudioPreset.flat, final  List<String> libraryPaths = const [], this.skipSilence = false, this.loudnessNormalization = false, this.playerThemeMode = PlayerThemeMode.standard, this.showWaveform = true, this.showCoverReflection = true}): _libraryPaths = libraryPaths;
  

@override@JsonKey() final  ThemeMode themeMode;
@override@JsonKey() final  AudioPreset audioPreset;
 final  List<String> _libraryPaths;
@override@JsonKey() List<String> get libraryPaths {
  if (_libraryPaths is EqualUnmodifiableListView) return _libraryPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_libraryPaths);
}

@override@JsonKey() final  bool skipSilence;
@override@JsonKey() final  bool loudnessNormalization;
@override@JsonKey() final  PlayerThemeMode playerThemeMode;
@override@JsonKey() final  bool showWaveform;
@override@JsonKey() final  bool showCoverReflection;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.audioPreset, audioPreset) || other.audioPreset == audioPreset)&&const DeepCollectionEquality().equals(other._libraryPaths, _libraryPaths)&&(identical(other.skipSilence, skipSilence) || other.skipSilence == skipSilence)&&(identical(other.loudnessNormalization, loudnessNormalization) || other.loudnessNormalization == loudnessNormalization)&&(identical(other.playerThemeMode, playerThemeMode) || other.playerThemeMode == playerThemeMode)&&(identical(other.showWaveform, showWaveform) || other.showWaveform == showWaveform)&&(identical(other.showCoverReflection, showCoverReflection) || other.showCoverReflection == showCoverReflection));
}


@override
int get hashCode => Object.hash(runtimeType,themeMode,audioPreset,const DeepCollectionEquality().hash(_libraryPaths),skipSilence,loudnessNormalization,playerThemeMode,showWaveform,showCoverReflection);

@override
String toString() {
  return 'AppSettings(themeMode: $themeMode, audioPreset: $audioPreset, libraryPaths: $libraryPaths, skipSilence: $skipSilence, loudnessNormalization: $loudnessNormalization, playerThemeMode: $playerThemeMode, showWaveform: $showWaveform, showCoverReflection: $showCoverReflection)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 ThemeMode themeMode, AudioPreset audioPreset, List<String> libraryPaths, bool skipSilence, bool loudnessNormalization, PlayerThemeMode playerThemeMode, bool showWaveform, bool showCoverReflection
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? audioPreset = null,Object? libraryPaths = null,Object? skipSilence = null,Object? loudnessNormalization = null,Object? playerThemeMode = null,Object? showWaveform = null,Object? showCoverReflection = null,}) {
  return _then(_AppSettings(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,audioPreset: null == audioPreset ? _self.audioPreset : audioPreset // ignore: cast_nullable_to_non_nullable
as AudioPreset,libraryPaths: null == libraryPaths ? _self._libraryPaths : libraryPaths // ignore: cast_nullable_to_non_nullable
as List<String>,skipSilence: null == skipSilence ? _self.skipSilence : skipSilence // ignore: cast_nullable_to_non_nullable
as bool,loudnessNormalization: null == loudnessNormalization ? _self.loudnessNormalization : loudnessNormalization // ignore: cast_nullable_to_non_nullable
as bool,playerThemeMode: null == playerThemeMode ? _self.playerThemeMode : playerThemeMode // ignore: cast_nullable_to_non_nullable
as PlayerThemeMode,showWaveform: null == showWaveform ? _self.showWaveform : showWaveform // ignore: cast_nullable_to_non_nullable
as bool,showCoverReflection: null == showCoverReflection ? _self.showCoverReflection : showCoverReflection // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
