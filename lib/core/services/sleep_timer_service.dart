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
  double? _originalVolume;
  bool _isFadingOut = false;

  @override
  SleepTimerState build() {
    ref.onDispose(() {
      cancelTimer();
    });
    return const SleepTimerState();
  }

  Future<void> _fadeOutAndPause() async {
    if (_isFadingOut) return;
    _isFadingOut = true;

    final mediaService = ref.read(mediaServiceProvider);
    _originalVolume = mediaService.volume;
    final startVol = _originalVolume ?? 100.0;

    // Fade out over 3 seconds (12 steps of 250ms)
    const steps = 12;
    const interval = Duration(milliseconds: 250);
    final volumeStep = startVol / steps;

    double currentVol = startVol;
    for (int i = 0; i < steps; i++) {
      currentVol = (currentVol - volumeStep).clamp(0.0, startVol);
      await mediaService.setVolume(currentVol);
      await Future.delayed(interval);
    }

    await mediaService.pause();
    // Restore original volume after pausing
    if (_originalVolume != null) {
      await mediaService.setVolume(_originalVolume!);
      _originalVolume = null;
    }
    _isFadingOut = false;
  }

  void startTimer(Duration duration) {
    cancelTimer();
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
    _timer?.cancel();
    _timer = null;
    _posSub?.cancel();
    _posSub = null;
    state = const SleepTimerState();
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

Duration calculateEndOfChapterRemaining({
  required Duration position,
  required Duration trackDuration,
  required bool hasCustomChapters,
  List<Chapter>? customChapters,
  int currentIndex = 0,
  Duration fallbackDuration = const Duration(minutes: 60),
}) {
  if (hasCustomChapters) {
    return trackDuration > Duration.zero
        ? trackDuration - position
        : fallbackDuration;
  } else {
    Duration chapterEndTime = trackDuration;
    if (customChapters != null && customChapters.isNotEmpty) {
      if (currentIndex < customChapters.length) {
        final endTime = customChapters[currentIndex].endTime;
        if (endTime != null) {
          chapterEndTime = Duration(
            milliseconds: (endTime * 1000).toInt(),
          );
        }
      }
    }
    return chapterEndTime - position;
  }
}
