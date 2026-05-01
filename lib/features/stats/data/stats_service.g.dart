// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(listeningStatsService)
final listeningStatsServiceProvider = ListeningStatsServiceProvider._();

final class ListeningStatsServiceProvider
    extends
        $FunctionalProvider<
          ListeningStatsService,
          ListeningStatsService,
          ListeningStatsService
        >
    with $Provider<ListeningStatsService> {
  ListeningStatsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listeningStatsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listeningStatsServiceHash();

  @$internal
  @override
  $ProviderElement<ListeningStatsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ListeningStatsService create(Ref ref) {
    return listeningStatsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListeningStatsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListeningStatsService>(value),
    );
  }
}

String _$listeningStatsServiceHash() =>
    r'ef67ce8825558c0fe44e4bf10ec8eca74aa3ac48';

@ProviderFor(listeningStats)
final listeningStatsProvider = ListeningStatsProvider._();

final class ListeningStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ListeningStatsSummary>,
          ListeningStatsSummary,
          Stream<ListeningStatsSummary>
        >
    with
        $FutureModifier<ListeningStatsSummary>,
        $StreamProvider<ListeningStatsSummary> {
  ListeningStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listeningStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listeningStatsHash();

  @$internal
  @override
  $StreamProviderElement<ListeningStatsSummary> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ListeningStatsSummary> create(Ref ref) {
    return listeningStats(ref);
  }
}

String _$listeningStatsHash() => r'5d699d756453d8fb4a226bfb3b603c816ce1f69d';
