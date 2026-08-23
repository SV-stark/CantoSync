// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyboard_shortcuts_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KeyboardShortcuts)
final keyboardShortcutsProvider = KeyboardShortcutsProvider._();

final class KeyboardShortcutsProvider
    extends $NotifierProvider<KeyboardShortcuts, List<KeyboardShortcut>> {
  KeyboardShortcutsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keyboardShortcutsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keyboardShortcutsHash();

  @$internal
  @override
  KeyboardShortcuts create() => KeyboardShortcuts();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<KeyboardShortcut> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<KeyboardShortcut>>(value),
    );
  }
}

String _$keyboardShortcutsHash() => r'00582c213bc73b3da0b54e92b9743d1a88e832d8';

abstract class _$KeyboardShortcuts extends $Notifier<List<KeyboardShortcut>> {
  List<KeyboardShortcut> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<List<KeyboardShortcut>, List<KeyboardShortcut>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<KeyboardShortcut>, List<KeyboardShortcut>>,
              List<KeyboardShortcut>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(shortcutActionCallbacks)
final shortcutActionCallbacksProvider = ShortcutActionCallbacksProvider._();

final class ShortcutActionCallbacksProvider
    extends
        $FunctionalProvider<
          ShortcutActionCallbacks,
          ShortcutActionCallbacks,
          ShortcutActionCallbacks
        >
    with $Provider<ShortcutActionCallbacks> {
  ShortcutActionCallbacksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shortcutActionCallbacksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shortcutActionCallbacksHash();

  @$internal
  @override
  $ProviderElement<ShortcutActionCallbacks> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShortcutActionCallbacks create(Ref ref) {
    return shortcutActionCallbacks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShortcutActionCallbacks value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShortcutActionCallbacks>(value),
    );
  }
}

String _$shortcutActionCallbacksHash() =>
    r'7f5bb5cea9a955bd968ab4af6e3004ec1cb8816b';
