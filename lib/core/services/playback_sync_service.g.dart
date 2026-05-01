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

@ProviderFor(CurrentBookPath)
final currentBookPathProvider = CurrentBookPathProvider._();

final class CurrentBookPathProvider
    extends $NotifierProvider<CurrentBookPath, String?> {
  CurrentBookPathProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentBookPathProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentBookPathHash();

  @$internal
  @override
  CurrentBookPath create() => CurrentBookPath();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentBookPathHash() => r'69272bd242d4140259c387ea01ff5b40a11baa63';

abstract class _$CurrentBookPath extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
