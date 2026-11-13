// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlaybackStateNotifier)
final playbackStateProvider = PlaybackStateNotifierProvider._();

final class PlaybackStateNotifierProvider
    extends $NotifierProvider<PlaybackStateNotifier, PlaybackState> {
  PlaybackStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackStateNotifierHash();

  @$internal
  @override
  PlaybackStateNotifier create() => PlaybackStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackState>(value),
    );
  }
}

String _$playbackStateNotifierHash() =>
    r'36c91d0ead5d7109c933b73c5e0a8fece8ffd4c3';

abstract class _$PlaybackStateNotifier extends $Notifier<PlaybackState> {
  PlaybackState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PlaybackState, PlaybackState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlaybackState, PlaybackState>,
              PlaybackState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
