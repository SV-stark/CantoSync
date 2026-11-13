// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlaybackState {

 Book? get currentBook; String? get currentPath; bool get isPlaying; Duration get position; Duration get duration; Duration get totalDuration; double get rate; double get volume; int get currentIndex; int get currentChapterIndex; bool get eofReached; bool get isPlaylistOpen; List<Chapter> get chapters;
/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackStateCopyWith<PlaybackState> get copyWith => _$PlaybackStateCopyWithImpl<PlaybackState>(this as PlaybackState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlaybackState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackState&&(identical(other.currentBook, _this.currentBook) || other.currentBook == _this.currentBook)&&(identical(other.currentPath, _this.currentPath) || other.currentPath == _this.currentPath)&&(identical(other.isPlaying, _this.isPlaying) || other.isPlaying == _this.isPlaying)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.totalDuration, _this.totalDuration) || other.totalDuration == _this.totalDuration)&&(identical(other.rate, _this.rate) || other.rate == _this.rate)&&(identical(other.volume, _this.volume) || other.volume == _this.volume)&&(identical(other.currentIndex, _this.currentIndex) || other.currentIndex == _this.currentIndex)&&(identical(other.currentChapterIndex, _this.currentChapterIndex) || other.currentChapterIndex == _this.currentChapterIndex)&&(identical(other.eofReached, _this.eofReached) || other.eofReached == _this.eofReached)&&(identical(other.isPlaylistOpen, _this.isPlaylistOpen) || other.isPlaylistOpen == _this.isPlaylistOpen)&&const DeepCollectionEquality().equals(other.chapters, _this.chapters));
}


@override
int get hashCode {
  final _this = this as PlaybackState;
  return Object.hash(runtimeType,_this.currentBook,_this.currentPath,_this.isPlaying,_this.position,_this.duration,_this.totalDuration,_this.rate,_this.volume,_this.currentIndex,_this.currentChapterIndex,_this.eofReached,_this.isPlaylistOpen,const DeepCollectionEquality().hash(_this.chapters));
}

@override
String toString() {
  final _this = this as PlaybackState;
  return 'PlaybackState(currentBook: ${_this.currentBook}, currentPath: ${_this.currentPath}, isPlaying: ${_this.isPlaying}, position: ${_this.position}, duration: ${_this.duration}, totalDuration: ${_this.totalDuration}, rate: ${_this.rate}, volume: ${_this.volume}, currentIndex: ${_this.currentIndex}, currentChapterIndex: ${_this.currentChapterIndex}, eofReached: ${_this.eofReached}, isPlaylistOpen: ${_this.isPlaylistOpen}, chapters: ${_this.chapters})';
}


}

/// @nodoc
abstract mixin class $PlaybackStateCopyWith<$Res>  {
  factory $PlaybackStateCopyWith(PlaybackState value, $Res Function(PlaybackState) _then) = _$PlaybackStateCopyWithImpl;
@useResult
$Res call({
 Book? currentBook, String? currentPath, bool isPlaying, Duration position, Duration duration, Duration totalDuration, double rate, double volume, int currentIndex, int currentChapterIndex, bool eofReached, bool isPlaylistOpen, List<Chapter> chapters
});




}
/// @nodoc
class _$PlaybackStateCopyWithImpl<$Res>
    implements $PlaybackStateCopyWith<$Res> {
  _$PlaybackStateCopyWithImpl(this._self, this._then);

  final PlaybackState _self;
  final $Res Function(PlaybackState) _then;

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentBook = freezed,Object? currentPath = freezed,Object? isPlaying = null,Object? position = null,Object? duration = null,Object? totalDuration = null,Object? rate = null,Object? volume = null,Object? currentIndex = null,Object? currentChapterIndex = null,Object? eofReached = null,Object? isPlaylistOpen = null,Object? chapters = null,}) {
  return _then(PlaybackState(
currentBook: freezed == currentBook ? _self.currentBook : currentBook // ignore: cast_nullable_to_non_nullable
as Book?,currentPath: freezed == currentPath ? _self.currentPath : currentPath // ignore: cast_nullable_to_non_nullable
as String?,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,totalDuration: null == totalDuration ? _self.totalDuration : totalDuration // ignore: cast_nullable_to_non_nullable
as Duration,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as double,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,currentChapterIndex: null == currentChapterIndex ? _self.currentChapterIndex : currentChapterIndex // ignore: cast_nullable_to_non_nullable
as int,eofReached: null == eofReached ? _self.eofReached : eofReached // ignore: cast_nullable_to_non_nullable
as bool,isPlaylistOpen: null == isPlaylistOpen ? _self.isPlaylistOpen : isPlaylistOpen // ignore: cast_nullable_to_non_nullable
as bool,chapters: null == chapters ? _self.chapters : chapters // ignore: cast_nullable_to_non_nullable
as List<Chapter>,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaybackState].
extension PlaybackStatePatterns on PlaybackState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackState value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackState value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Book? currentBook,  String? currentPath,  bool isPlaying,  Duration position,  Duration duration,  Duration totalDuration,  double rate,  double volume,  int currentIndex,  int currentChapterIndex,  bool eofReached,  bool isPlaylistOpen,  List<Chapter> chapters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackState() when $default != null:
return $default(_that.currentBook,_that.currentPath,_that.isPlaying,_that.position,_that.duration,_that.totalDuration,_that.rate,_that.volume,_that.currentIndex,_that.currentChapterIndex,_that.eofReached,_that.isPlaylistOpen,_that.chapters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Book? currentBook,  String? currentPath,  bool isPlaying,  Duration position,  Duration duration,  Duration totalDuration,  double rate,  double volume,  int currentIndex,  int currentChapterIndex,  bool eofReached,  bool isPlaylistOpen,  List<Chapter> chapters)  $default,) {final _that = this;
switch (_that) {
case _PlaybackState():
return $default(_that.currentBook,_that.currentPath,_that.isPlaying,_that.position,_that.duration,_that.totalDuration,_that.rate,_that.volume,_that.currentIndex,_that.currentChapterIndex,_that.eofReached,_that.isPlaylistOpen,_that.chapters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Book? currentBook,  String? currentPath,  bool isPlaying,  Duration position,  Duration duration,  Duration totalDuration,  double rate,  double volume,  int currentIndex,  int currentChapterIndex,  bool eofReached,  bool isPlaylistOpen,  List<Chapter> chapters)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackState() when $default != null:
return $default(_that.currentBook,_that.currentPath,_that.isPlaying,_that.position,_that.duration,_that.totalDuration,_that.rate,_that.volume,_that.currentIndex,_that.currentChapterIndex,_that.eofReached,_that.isPlaylistOpen,_that.chapters);case _:
  return null;

}
}

}

/// @nodoc


class _PlaybackState extends PlaybackState {
  const _PlaybackState({this.currentBook, this.currentPath, this.isPlaying = false, this.position = Duration.zero, this.duration = Duration.zero, this.totalDuration = Duration.zero, this.rate = 1.0, this.volume = 100.0, this.currentIndex = 0, this.currentChapterIndex = -1, this.eofReached = false, this.isPlaylistOpen = false,  List<Chapter> chapters = const <Chapter>[]}): _chapters = chapters,super._();
  

@override final  Book? currentBook;
@override final  String? currentPath;
@override@JsonKey() final  bool isPlaying;
@override@JsonKey() final  Duration position;
@override@JsonKey() final  Duration duration;
@override@JsonKey() final  Duration totalDuration;
@override@JsonKey() final  double rate;
@override@JsonKey() final  double volume;
@override@JsonKey() final  int currentIndex;
@override@JsonKey() final  int currentChapterIndex;
@override@JsonKey() final  bool eofReached;
@override@JsonKey() final  bool isPlaylistOpen;
 final  List<Chapter> _chapters;
@override@JsonKey() List<Chapter> get chapters {
  if (_chapters is EqualUnmodifiableListView) return _chapters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chapters);
}


/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackStateCopyWith<_PlaybackState> get copyWith => __$PlaybackStateCopyWithImpl<_PlaybackState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackState&&(identical(other.currentBook, currentBook) || other.currentBook == currentBook)&&(identical(other.currentPath, currentPath) || other.currentPath == currentPath)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.totalDuration, totalDuration) || other.totalDuration == totalDuration)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.currentChapterIndex, currentChapterIndex) || other.currentChapterIndex == currentChapterIndex)&&(identical(other.eofReached, eofReached) || other.eofReached == eofReached)&&(identical(other.isPlaylistOpen, isPlaylistOpen) || other.isPlaylistOpen == isPlaylistOpen)&&const DeepCollectionEquality().equals(other.chapters, _chapters));
}


@override
int get hashCode {
    return Object.hash(runtimeType,currentBook,currentPath,isPlaying,position,duration,totalDuration,rate,volume,currentIndex,currentChapterIndex,eofReached,isPlaylistOpen,const DeepCollectionEquality().hash(_chapters));
}

@override
String toString() {
    return 'PlaybackState(currentBook: $currentBook, currentPath: $currentPath, isPlaying: $isPlaying, position: $position, duration: $duration, totalDuration: $totalDuration, rate: $rate, volume: $volume, currentIndex: $currentIndex, currentChapterIndex: $currentChapterIndex, eofReached: $eofReached, isPlaylistOpen: $isPlaylistOpen, chapters: $chapters)';
}


}

/// @nodoc
abstract mixin class _$PlaybackStateCopyWith<$Res> implements $PlaybackStateCopyWith<$Res> {
  factory _$PlaybackStateCopyWith(_PlaybackState value, $Res Function(_PlaybackState) _then) = __$PlaybackStateCopyWithImpl;
@override @useResult
$Res call({
 Book? currentBook, String? currentPath, bool isPlaying, Duration position, Duration duration, Duration totalDuration, double rate, double volume, int currentIndex, int currentChapterIndex, bool eofReached, bool isPlaylistOpen, List<Chapter> chapters
});




}
/// @nodoc
class __$PlaybackStateCopyWithImpl<$Res>
    implements _$PlaybackStateCopyWith<$Res> {
  __$PlaybackStateCopyWithImpl(this._self, this._then);

  final _PlaybackState _self;
  final $Res Function(_PlaybackState) _then;

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentBook = freezed,Object? currentPath = freezed,Object? isPlaying = null,Object? position = null,Object? duration = null,Object? totalDuration = null,Object? rate = null,Object? volume = null,Object? currentIndex = null,Object? currentChapterIndex = null,Object? eofReached = null,Object? isPlaylistOpen = null,Object? chapters = null,}) {
  return _then(_PlaybackState(
currentBook: freezed == currentBook ? _self.currentBook : currentBook // ignore: cast_nullable_to_non_nullable
as Book?,currentPath: freezed == currentPath ? _self.currentPath : currentPath // ignore: cast_nullable_to_non_nullable
as String?,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,totalDuration: null == totalDuration ? _self.totalDuration : totalDuration // ignore: cast_nullable_to_non_nullable
as Duration,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as double,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,currentChapterIndex: null == currentChapterIndex ? _self.currentChapterIndex : currentChapterIndex // ignore: cast_nullable_to_non_nullable
as int,eofReached: null == eofReached ? _self.eofReached : eofReached // ignore: cast_nullable_to_non_nullable
as bool,isPlaylistOpen: null == isPlaylistOpen ? _self.isPlaylistOpen : isPlaylistOpen // ignore: cast_nullable_to_non_nullable
as bool,chapters: null == chapters ? _self._chapters : chapters // ignore: cast_nullable_to_non_nullable
as List<Chapter>,
  ));
}


}

// dart format on
