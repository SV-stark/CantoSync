// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tray_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trayService)
final trayServiceProvider = TrayServiceProvider._();

final class TrayServiceProvider
    extends $FunctionalProvider<TrayService, TrayService, TrayService>
    with $Provider<TrayService> {
  TrayServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trayServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trayServiceHash();

  @$internal
  @override
  $ProviderElement<TrayService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TrayService create(Ref ref) {
    return trayService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrayService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrayService>(value),
    );
  }
}

String _$trayServiceHash() => r'eb82ebff19c5fcb7474378274ebc0c08a0ac7c6b';
