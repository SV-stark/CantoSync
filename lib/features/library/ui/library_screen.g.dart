// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LibraryViewMode)
final libraryViewModeProvider = LibraryViewModeProvider._();

final class LibraryViewModeProvider
    extends $NotifierProvider<LibraryViewMode, bool> {
  LibraryViewModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryViewModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryViewModeHash();

  @$internal
  @override
  LibraryViewMode create() => LibraryViewMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$libraryViewModeHash() => r'82372c99b776e94ce56ec5d282fb2da9d76ed1c9';

abstract class _$LibraryViewMode extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
