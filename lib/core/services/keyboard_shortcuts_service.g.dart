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

String _$keyboardShortcutsHash() => r'dd376171e096d4e05a15b8a2301abcd05cb6c6c4';

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
          Map<String, List<ShortcutActionCallback>>,
          Map<String, List<ShortcutActionCallback>>,
          Map<String, List<ShortcutActionCallback>>
        >
    with $Provider<Map<String, List<ShortcutActionCallback>>> {
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
  $ProviderElement<Map<String, List<ShortcutActionCallback>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, List<ShortcutActionCallback>> create(Ref ref) {
    return shortcutActionCallbacks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, List<ShortcutActionCallback>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Map<String, List<ShortcutActionCallback>>>(value),
    );
  }
}

String _$shortcutActionCallbacksHash() =>
    r'69ca88bee22fa8913f077742e5e3fdafcf0b82ee';
