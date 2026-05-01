import 'dart:async';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sleep_timer_service.g.dart';

class SleepTimerState {

  SleepTimerState({this.remainingTime, this.isEndOfChapter = false});
  final Duration? remainingTime;
  final bool isEndOfChapter;

  SleepTimerState copyWith({Duration? remainingTime, bool? isEndOfChapter}) {
    return SleepTimerState(
      remainingTime: remainingTime ?? this.remainingTime,
      isEndOfChapter: isEndOfChapter ?? this.isEndOfChapter,
    );
  }
}

@Riverpod(keepAlive: true)
class SleepTimer extends _$SleepTimer {
  Timer? _timer;
  StreamSubscription? _posSub;

  @override
  SleepTimerState build() {
    ref.onDispose(() {
      cancelTimer();
    });
    return SleepTimerState();
  }

  void startTimer(Duration duration) {
    cancelTimer();
    state = state.copyWith(remainingTime: duration, isEndOfChapter: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingTime == null ||
          state.remainingTime! <= Duration.zero) {
        ref.read(mediaServiceProvider).pause();
        cancelTimer();
      } else {
        state = state.copyWith(
          remainingTime: state.remainingTime! - const Duration(seconds: 1),
        );
      }
    });
  }

  void setEndOfChapter() {
    cancelTimer();
    state = state.copyWith(isEndOfChapter: true);

    _posSub = ref.read(mediaServiceProvider).positionStream.listen((position) {
      if (state.isEndOfChapter) {
        final mediaService = ref.read(mediaServiceProvider);
        final duration = mediaService.duration;
        final remaining = duration - position;
        if (duration > Duration.zero &&
            remaining <= const Duration(seconds: 1) &&
            remaining >= Duration.zero) {
          mediaService.pause();
          cancelTimer();
        }
      }
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _posSub?.cancel();
    _posSub = null;
    state = SleepTimerState();
  }
}
