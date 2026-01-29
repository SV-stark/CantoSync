import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canto_sync/core/services/media_service.dart';

final sleepTimerServiceProvider =
    NotifierProvider<SleepTimerService, Duration?>(() {
      return SleepTimerService();
    });

class SleepTimerService extends Notifier<Duration?> {
  Timer? _timer;

  @override
  Duration? build() {
    return null;
  }

  void startTimer(Duration duration) {
    cancelTimer();
    state = duration;
    _timer = Timer(duration, () {
      ref.read(mediaServiceProvider).pause();
      state = null; // Timer finished
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    state = null;
  }
}
