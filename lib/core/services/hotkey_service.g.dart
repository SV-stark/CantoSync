// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotkey_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hotkeyService)
final hotkeyServiceProvider = HotkeyServiceProvider._();

final class HotkeyServiceProvider
    extends $FunctionalProvider<HotkeyService, HotkeyService, HotkeyService>
    with $Provider<HotkeyService> {
  HotkeyServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotkeyServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hotkeyServiceHash();

  @$internal
  @override
  $ProviderElement<HotkeyService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HotkeyService create(Ref ref) {
    return hotkeyService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HotkeyService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HotkeyService>(value),
    );
  }
}

String _$hotkeyServiceHash() => r'3e17eb7d04ec097e2f08d60d6a5c7d80ed84e874';
