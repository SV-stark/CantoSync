// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_sync_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playbackSync)
final playbackSyncProvider = PlaybackSyncProvider._();

final class PlaybackSyncProvider
    extends
        $FunctionalProvider<
          PlaybackSyncService,
          PlaybackSyncService,
          PlaybackSyncService
        >
    with $Provider<PlaybackSyncService> {
  PlaybackSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackSyncHash();

  @$internal
  @override
  $ProviderElement<PlaybackSyncService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlaybackSyncService create(Ref ref) {
    return playbackSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackSyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackSyncService>(value),
    );
  }
}

String _$playbackSyncHash() => r'c434dab503c74f3f2c9c2db55386cc9d29ec74a2';
