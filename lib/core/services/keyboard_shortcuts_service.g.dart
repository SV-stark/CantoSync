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

String _$keyboardShortcutsHash() => r'eedcde19e5fa57fd13459ba07b4a32617ee36f25';

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

@ProviderFor(ShortcutActionCallbacks)
final shortcutActionCallbacksProvider = ShortcutActionCallbacksProvider._();

final class ShortcutActionCallbacksProvider
    extends
        $NotifierProvider<
          ShortcutActionCallbacks,
          Map<String, List<ShortcutActionCallback>>
        > {
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
  ShortcutActionCallbacks create() => ShortcutActionCallbacks();

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
    r'c1ba98e8c373eb449123041a1962af40779cfdcb';

abstract class _$ShortcutActionCallbacks
    extends $Notifier<Map<String, List<ShortcutActionCallback>>> {
  Map<String, List<ShortcutActionCallback>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, List<ShortcutActionCallback>>,
              Map<String, List<ShortcutActionCallback>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, List<ShortcutActionCallback>>,
                Map<String, List<ShortcutActionCallback>>
              >,
              Map<String, List<ShortcutActionCallback>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
