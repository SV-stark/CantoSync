// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(isar)
final isarProvider = IsarProvider._();

final class IsarProvider extends $FunctionalProvider<Isar, Isar, Isar>
    with $Provider<Isar> {
  IsarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isarHash();

  @$internal
  @override
  $ProviderElement<Isar> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Isar create(Ref ref) {
    return isar(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Isar value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Isar>(value),
    );
  }
}

String _$isarHash() => r'0736f5b74e3aef62a2757db5c57c6d3267d60de4';

@ProviderFor(libraryService)
final libraryServiceProvider = LibraryServiceProvider._();

final class LibraryServiceProvider
    extends $FunctionalProvider<LibraryService, LibraryService, LibraryService>
    with $Provider<LibraryService> {
  LibraryServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryServiceHash();

  @$internal
  @override
  $ProviderElement<LibraryService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LibraryService create(Ref ref) {
    return libraryService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LibraryService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LibraryService>(value),
    );
  }
}

String _$libraryServiceHash() => r'36aac050924d19c9471e679e4572c1084c72e6a7';

@ProviderFor(LibrarySearchQuery)
final librarySearchQueryProvider = LibrarySearchQueryProvider._();

final class LibrarySearchQueryProvider
    extends $NotifierProvider<LibrarySearchQuery, String> {
  LibrarySearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'librarySearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$librarySearchQueryHash();

  @$internal
  @override
  LibrarySearchQuery create() => LibrarySearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$librarySearchQueryHash() =>
    r'409814798eb4ede9cf088f8c7c8078665599ad20';

abstract class _$LibrarySearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(LibraryGroupingMode)
final libraryGroupingModeProvider = LibraryGroupingModeProvider._();

final class LibraryGroupingModeProvider
    extends $NotifierProvider<LibraryGroupingMode, bool> {
  LibraryGroupingModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryGroupingModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryGroupingModeHash();

  @$internal
  @override
  LibraryGroupingMode create() => LibraryGroupingMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$libraryGroupingModeHash() =>
    r'7618ee00202489c56ae91e5ee405756aa6a7e339';

abstract class _$LibraryGroupingMode extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(LibraryCollectionFilter)
final libraryCollectionFilterProvider = LibraryCollectionFilterProvider._();

final class LibraryCollectionFilterProvider
    extends $NotifierProvider<LibraryCollectionFilter, String?> {
  LibraryCollectionFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryCollectionFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryCollectionFilterHash();

  @$internal
  @override
  LibraryCollectionFilter create() => LibraryCollectionFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$libraryCollectionFilterHash() =>
    r'b0d13f35c5ca3add60f3c64d50db961ab2598a17';

abstract class _$LibraryCollectionFilter extends $Notifier<String?> {
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

@ProviderFor(libraryBooks)
final libraryBooksProvider = LibraryBooksProvider._();

final class LibraryBooksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Book>>,
          List<Book>,
          Stream<List<Book>>
        >
    with $FutureModifier<List<Book>>, $StreamProvider<List<Book>> {
  LibraryBooksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryBooksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryBooksHash();

  @$internal
  @override
  $StreamProviderElement<List<Book>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Book>> create(Ref ref) {
    return libraryBooks(ref);
  }
}

String _$libraryBooksHash() => r'abfb842ac8f98e788f39254ea76059d9ce35e06e';

@ProviderFor(libraryRecentBooks)
final libraryRecentBooksProvider = LibraryRecentBooksProvider._();

final class LibraryRecentBooksProvider
    extends $FunctionalProvider<List<Book>, List<Book>, List<Book>>
    with $Provider<List<Book>> {
  LibraryRecentBooksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryRecentBooksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryRecentBooksHash();

  @$internal
  @override
  $ProviderElement<List<Book>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Book> create(Ref ref) {
    return libraryRecentBooks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Book> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Book>>(value),
    );
  }
}

String _$libraryRecentBooksHash() =>
    r'3ebcfc3c20a7def5647e10cc772f84d34497a213';

@ProviderFor(libraryGroupedBooks)
final libraryGroupedBooksProvider = LibraryGroupedBooksProvider._();

final class LibraryGroupedBooksProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, List<Book>>>,
          Map<String, List<Book>>,
          FutureOr<Map<String, List<Book>>>
        >
    with
        $FutureModifier<Map<String, List<Book>>>,
        $FutureProvider<Map<String, List<Book>>> {
  LibraryGroupedBooksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryGroupedBooksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryGroupedBooksHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, List<Book>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, List<Book>>> create(Ref ref) {
    return libraryGroupedBooks(ref);
  }
}

String _$libraryGroupedBooksHash() =>
    r'59b2b039a0f421c0d3215de7ed4bb1dc4abc399f';
