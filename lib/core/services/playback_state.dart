import 'dart:async';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:canto_sync/core/constants/app_constants.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/features/library/data/book.dart';

part 'playback_state.freezed.dart';
part 'playback_state.g.dart';

/// Unified playback state shared across [MediaService], [PlaybackSyncService],
/// [PlayerScreen], and [MiniPlayer].
@freezed
abstract class PlaybackState with _$PlaybackState {
  const factory PlaybackState({
    Book? currentBook,
    String? currentPath,
    @Default(false) bool isPlaying,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(Duration.zero) Duration totalDuration,
    @Default(1.0) double rate,
    @Default(100.0) double volume,
    @Default(0) int currentIndex,
    @Default(-1) int currentChapterIndex,
    @Default(false) bool eofReached,
    @Default(false) bool isPlaylistOpen,
    @Default(<Chapter>[]) List<Chapter> chapters,
  }) = _PlaybackState;

  const PlaybackState._();

  /// Effective total duration, falling back to the scanned [Book.durationSeconds]
  /// while the audio engine is still probing.
  Duration get effectiveTotalDuration {
    if (totalDuration.inSeconds > 0) return totalDuration;
    final bookDurationSeconds = currentBook?.durationSeconds;
    if (bookDurationSeconds != null && bookDurationSeconds > 0) {
      return Duration(milliseconds: (bookDurationSeconds * 1000).toInt());
    }
    return totalDuration;
  }

  /// Active chapter for the current position (single-file) or playlist index
  /// (multi-file). Uses mpv's observed `chapter` index for single-file books
  /// when available, falling back to position matching.
  Chapter? get currentChapter {
    if (chapters.isEmpty) return null;
    if (isPlaylistOpen) {
      return currentIndex < chapters.length ? chapters[currentIndex] : null;
    }
    if (currentChapterIndex >= 0 && currentChapterIndex < chapters.length) {
      return chapters[currentChapterIndex];
    }
    final posSeconds = position.inMilliseconds / 1000.0;
    return chapters.lastWhere(
      (c) =>
          c.startTime <= posSeconds + AppConstants.chapterMatchingToleranceSeconds,
      orElse: () => chapters.first,
    );
  }

  /// Global playback position in seconds across the entire book.
  double get globalPositionSeconds {
    double seconds = position.inMilliseconds / 1000.0;
    final chapter = currentChapter;
    if (chapter != null && isPlaylistOpen) {
      seconds += chapter.startTime;
    }
    return seconds;
  }

  /// Formatted completion percentage across the entire book, or empty if unknown.
  String get percentageText {
    final totalBookSeconds = effectiveTotalDuration.inMilliseconds / 1000.0;
    if (totalBookSeconds <= 0) return '';
    final percent = (globalPositionSeconds / totalBookSeconds * 100).clamp(
      0.0,
      100.0,
    );
    return '${percent.toStringAsFixed(1)}%';
  }

  /// Position within the active chapter (or track).
  Duration get chapterPosition {
    final chapter = currentChapter;
    if (chapter == null || isPlaylistOpen) return position;
    final start = Duration(milliseconds: (chapter.startTime * 1000).toInt());
    var local = position - start;
    if (local.isNegative) local = Duration.zero;
    final maxDur = chapterDuration;
    if (local > maxDur) local = maxDur;
    return local;
  }

  /// Duration of the active chapter (or track).
  Duration get chapterDuration {
    final chapter = currentChapter;
    if (chapter == null || isPlaylistOpen) return duration;
    final start = Duration(milliseconds: (chapter.startTime * 1000).toInt());
    final end = chapter.endTime != null
        ? Duration(milliseconds: (chapter.endTime! * 1000).toInt())
        : duration;
    final diff = end - start;
    return diff.isNegative ? Duration.zero : diff;
  }
}

@Riverpod(keepAlive: true)
class PlaybackStateNotifier extends _$PlaybackStateNotifier {
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  PlaybackState build() {
    final mediaService = ref.watch(mediaServiceProvider);

    _cancelSubscriptions();
    _subscriptions.addAll([
      mediaService.playingStream.listen((playing) {
        state = state.copyWith(isPlaying: playing);
      }),
      mediaService.positionStream.listen((position) {
        state = state.copyWith(position: position);
      }),
      mediaService.durationStream.listen((duration) {
        state = state.copyWith(duration: duration);
      }),
      mediaService.totalDurationStream.listen((total) {
        state = state.copyWith(totalDuration: total);
      }),
      mediaService.rateStream.listen((rate) {
        state = state.copyWith(rate: rate);
      }),
      mediaService.volumeStream.listen((volume) {
        state = state.copyWith(volume: volume);
      }),
      mediaService.playlistStream.listen((playlist) {
        state = state.copyWith(
          currentIndex: playlist.index,
          isPlaylistOpen: mediaService.isPlaylistOpen,
        );
      }),
      mediaService.chaptersStream.listen((chapters) {
        state = state.copyWith(
          chapters: chapters,
          isPlaylistOpen: mediaService.isPlaylistOpen,
        );
      }),
      mediaService.currentChapterIndexStream.listen((chapterIndex) {
        state = state.copyWith(currentChapterIndex: chapterIndex);
      }),
      mediaService.eofReachedStream.listen((eof) {
        state = state.copyWith(eofReached: eof);
      }),
    ]);

    ref.onDispose(_cancelSubscriptions);

    return PlaybackState(
      isPlaying: mediaService.isPlaying,
      position: mediaService.position,
      duration: mediaService.duration,
      totalDuration: mediaService.lastTotalDuration,
      rate: mediaService.playRate,
      volume: mediaService.volume,
      currentIndex: mediaService.currentIndex,
      isPlaylistOpen: mediaService.isPlaylistOpen,
      chapters: mediaService.lastChapters,
    );
  }

  void _cancelSubscriptions() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  void setCurrentPath(String? path) {
    state = state.copyWith(currentPath: path);
  }

  void setCurrentBook(Book? book, {String? path}) {
    state = state.copyWith(
      currentBook: book,
      currentPath: path ?? book?.path ?? state.currentPath,
    );
  }

  void updateCurrentBookProgress(double positionSeconds, int trackIndex) {
    final book = state.currentBook;
    if (book == null) return;
    book.positionSeconds = positionSeconds;
    book.lastTrackIndex = trackIndex;
  }
}
