// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_timer_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SleepTimer)
final sleepTimerProvider = SleepTimerProvider._();

final class SleepTimerProvider
    extends $NotifierProvider<SleepTimer, SleepTimerState> {
  SleepTimerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sleepTimerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sleepTimerHash();

  @$internal
  @override
  SleepTimer create() => SleepTimer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SleepTimerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SleepTimerState>(value),
    );
  }
}

String _$sleepTimerHash() => r'91c9bf8766386e7392dc42bb38432fd483a1b005';

abstract class _$SleepTimer extends $Notifier<SleepTimerState> {
  SleepTimerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SleepTimerState, SleepTimerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SleepTimerState, SleepTimerState>,
              SleepTimerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
