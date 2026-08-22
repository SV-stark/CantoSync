// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NavigationIndex)
final navigationIndexProvider = NavigationIndexProvider._();

final class NavigationIndexProvider
    extends $NotifierProvider<NavigationIndex, int> {
  NavigationIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationIndexHash();

  @$internal
  @override
  NavigationIndex create() => NavigationIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$navigationIndexHash() => r'712d5b71611346b7ad118fde1bbfe2248a8123a8';

abstract class _$NavigationIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
