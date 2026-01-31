import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canto_sync/core/services/media_service.dart';

final sleepTimerServiceProvider =
    NotifierProvider<SleepTimerService, SleepTimerState>(() {
      return SleepTimerService();
    });

class SleepTimerState {
  final Duration? remainingTime;
  final bool isEndOfChapter;

  SleepTimerState({this.remainingTime, this.isEndOfChapter = false});

  SleepTimerState copyWith({Duration? remainingTime, bool? isEndOfChapter}) {
    return SleepTimerState(
      remainingTime: remainingTime ?? this.remainingTime,
      isEndOfChapter: isEndOfChapter ?? this.isEndOfChapter,
    );
  }
}

class SleepTimerService extends Notifier<SleepTimerState> {
  Timer? _timer;
  StreamSubscription? _posSub;

  @override
  SleepTimerState build() {
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

    // Listen to position changes to detect end of chapter
    _posSub = ref.read(mediaServiceProvider).positionStream.listen((pos) {
      // In CantoSync, media_service handles chapter navigation.
      // For now, we'll use a simple approach: if position is near end of current media
      // AND we are in end-of-chapter mode, we might want to pause.
      // However, "End of Chapter" usually means the NEXT chapter boundary.
      // A better way is to check the remaining time in the current chapter from the UI.
      // But let's implement it here if possible.
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
