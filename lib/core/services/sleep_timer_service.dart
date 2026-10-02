import 'dart:async';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sleep_timer_service.freezed.dart';
part 'sleep_timer_service.g.dart';

@freezed
abstract class SleepTimerState with _$SleepTimerState {
  const factory SleepTimerState({
    Duration? remainingTime,
    @Default(false) bool isEndOfChapter,
  }) = _SleepTimerState;
}

@Riverpod(keepAlive: true)
class SleepTimer extends _$SleepTimer {
  Timer? _timer;
  StreamSubscription? _posSub;
  bool _isFadingOut = false;

  /// Generation token so a fade started by a previous timer can be aborted
  /// when the user cancels mid-fade.
  int _fadeGeneration = 0;

  @override
  SleepTimerState build() {
    ref.onDispose(() {
      _teardown();
    });
    return const SleepTimerState();
  }

  /// Cancels timers/subscriptions and any in-flight fade without touching
  /// `state`. Safe to call from build() and from dispose().
  void _teardown() {
    _fadeGeneration++;
    _timer?.cancel();
    _timer = null;
    _posSub?.cancel();
    _posSub = null;
  }

  Future<void> _fadeOutAndPause() async {
    if (_isFadingOut) return;
    _isFadingOut = true;
    final generation = ++_fadeGeneration;

    final mediaService = ref.read(mediaServiceProvider);
    final originalVolume = mediaService.volume;
    final startVol = originalVolume;

    // Fade out over 3 seconds (12 steps of 250ms)
    const steps = 12;
    const interval = Duration(milliseconds: 250);
    final volumeStep = startVol / steps;

    double currentVol = startVol;
    for (int i = 0; i < steps; i++) {
      // Abort if the user cancelled while we were fading.
      if (generation != _fadeGeneration) {
        await mediaService.setVolume(startVol);
        _isFadingOut = false;
        return;
      }
      currentVol = (currentVol - volumeStep).clamp(0.0, startVol);
      await mediaService.setVolume(currentVol);
      await Future.delayed(interval);
    }

    if (generation != _fadeGeneration) {
      await mediaService.setVolume(startVol);
      _isFadingOut = false;
      return;
    }

    await mediaService.pause();
    // Restore original volume after pausing
    await mediaService.setVolume(startVol);
    _isFadingOut = false;
  }

  void startTimer(Duration duration) {
    cancelTimer();
    if (duration <= Duration.zero) return;
    state = state.copyWith(remainingTime: duration, isEndOfChapter: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final step = stepSleepTimer(state.remainingTime);
      if (step.shouldCancel) {
        cancelTimer();
      } else if (step.shouldExpire) {
        cancelTimer();
        _fadeOutAndPause();
      } else {
        state = state.copyWith(remainingTime: step.remainingTime);
      }
    });
  }

  void setEndOfChapter() {
    cancelTimer();
    state = state.copyWith(isEndOfChapter: true);

    _posSub = ref.read(mediaServiceProvider).positionStream.listen((position) {
      if (state.isEndOfChapter) {
        final mediaService = ref.read(mediaServiceProvider);

        final remaining = calculateEndOfChapterRemaining(
          position: position,
          trackDuration: mediaService.duration,
          hasCustomChapters: mediaService.customChapters != null &&
              mediaService.customChapters!.isNotEmpty,
          customChapters: mediaService.customChapters,
          currentIndex: mediaService.currentIndex,
        );

        if (remaining <= const Duration(seconds: 3) &&
            remaining >= Duration.zero) {
          cancelTimer();
          _fadeOutAndPause();
        }
      }
    });
  }

  void cancelTimer() {
    _teardown();
    if (!_isFadingOut) {
      state = const SleepTimerState();
    } else {
      // A fade is in flight; it will observe the generation change, restore
      // the original volume and reset the state itself.
      state = state.copyWith(remainingTime: null, isEndOfChapter: false);
    }
  }
}

class SleepTimerStepResult {
  const SleepTimerStepResult({
    this.remainingTime,
    this.shouldExpire = false,
    this.shouldCancel = false,
  });

  final Duration? remainingTime;
  final bool shouldExpire;
  final bool shouldCancel;
}

SleepTimerStepResult stepSleepTimer(Duration? currentRemaining) {
  if (currentRemaining == null) {
    return const SleepTimerStepResult(shouldCancel: true);
  }
  if (currentRemaining <= Duration.zero) {
    return const SleepTimerStepResult(shouldExpire: true);
  }
  return SleepTimerStepResult(
    remainingTime: currentRemaining - const Duration(seconds: 1),
  );
}

/// Time remaining until the end of the current chapter.
///
/// For multi-file books each chapter is a playlist item, so the remaining time
/// is simply the rest of the current file. For single files with embedded
/// chapters the chapter end comes from the chapter list matched against the
/// current position -- the old implementation returned "rest of the file"
/// instead, so the end-of-chapter timer always waited for the whole book.
Duration calculateEndOfChapterRemaining({
  required Duration position,
  required Duration trackDuration,
  required bool hasCustomChapters,
  List<Chapter>? customChapters,
  int currentIndex = 0,
  Duration fallbackDuration = const Duration(minutes: 60),
}) {
  if (hasCustomChapters) {
    // Multi-file: the chapter *is* the current track.
    return trackDuration > Duration.zero
        ? trackDuration - position
        : fallbackDuration;
  }

  // Single file with embedded chapters.
  var chapterEndTime = trackDuration;
  if (customChapters != null && customChapters.isNotEmpty) {
    final positionSeconds = position.inMilliseconds / 1000.0;
    var index = currentIndex;
    if (index < 0 || index >= customChapters.length) {
      index = MediaService.currentChapterIndex(
        customChapters,
        positionSeconds,
      );
    }
    final endTime = customChapters[index].endTime;
    if (endTime != null) {
      chapterEndTime = Duration(milliseconds: (endTime * 1000).toInt());
    }
  }

  final remaining = chapterEndTime - position;
  // Guard against a chapter end earlier than the current position (bad tags).
  return remaining.isNegative ? Duration.zero : remaining;
}
