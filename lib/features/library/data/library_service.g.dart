// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isarHash() => r'43c91a1b471054794dda6e4b0f120026c8bf7ed7';

/// See also [isar].
@ProviderFor(isar)
final isarProvider = Provider<Isar>.internal(
  isar,
  name: r'isarProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isarHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsarRef = ProviderRef<Isar>;
String _$libraryServiceHash() => r'e04d6af8b7b495786be7f169d005ce9240428d26';

/// See also [libraryService].
@ProviderFor(libraryService)
final libraryServiceProvider = Provider<LibraryService>.internal(
  libraryService,
  name: r'libraryServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$libraryServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LibraryServiceRef = ProviderRef<LibraryService>;
String _$libraryBooksHash() => r'99be94668c8408b1abfdb8d8ade711b96730695b';

/// See also [libraryBooks].
@ProviderFor(libraryBooks)
final libraryBooksProvider = AutoDisposeStreamProvider<List<Book>>.internal(
  libraryBooks,
  name: r'libraryBooksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$libraryBooksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LibraryBooksRef = AutoDisposeStreamProviderRef<List<Book>>;
String _$libraryRecentBooksHash() =>
    r'89d56a3c5a1bac20adc56ff1c115d563c5420c3f';

/// See also [libraryRecentBooks].
@ProviderFor(libraryRecentBooks)
final libraryRecentBooksProvider = AutoDisposeProvider<List<Book>>.internal(
  libraryRecentBooks,
  name: r'libraryRecentBooksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$libraryRecentBooksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LibraryRecentBooksRef = AutoDisposeProviderRef<List<Book>>;
String _$libraryGroupedBooksHash() =>
    r'c9a3b4080261ed74a65434f7510a80d2a676f40f';

/// See also [libraryGroupedBooks].
@ProviderFor(libraryGroupedBooks)
final libraryGroupedBooksProvider =
    AutoDisposeFutureProvider<Map<String, List<Book>>>.internal(
  libraryGroupedBooks,
  name: r'libraryGroupedBooksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$libraryGroupedBooksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LibraryGroupedBooksRef
    = AutoDisposeFutureProviderRef<Map<String, List<Book>>>;
String _$librarySearchQueryHash() =>
    r'409814798eb4ede9cf088f8c7c8078665599ad20';

/// See also [LibrarySearchQuery].
@ProviderFor(LibrarySearchQuery)
final librarySearchQueryProvider =
    AutoDisposeNotifierProvider<LibrarySearchQuery, String>.internal(
  LibrarySearchQuery.new,
  name: r'librarySearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$librarySearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LibrarySearchQuery = AutoDisposeNotifier<String>;
String _$libraryGroupingModeHash() =>
    r'7618ee00202489c56ae91e5ee405756aa6a7e339';

/// See also [LibraryGroupingMode].
@ProviderFor(LibraryGroupingMode)
final libraryGroupingModeProvider =
    AutoDisposeNotifierProvider<LibraryGroupingMode, bool>.internal(
  LibraryGroupingMode.new,
  name: r'libraryGroupingModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$libraryGroupingModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LibraryGroupingMode = AutoDisposeNotifier<bool>;
String _$libraryCollectionFilterHash() =>
    r'b0d13f35c5ca3add60f3c64d50db961ab2598a17';

/// See also [LibraryCollectionFilter].
@ProviderFor(LibraryCollectionFilter)
final libraryCollectionFilterProvider =
    AutoDisposeNotifierProvider<LibraryCollectionFilter, String?>.internal(
  LibraryCollectionFilter.new,
  name: r'libraryCollectionFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$libraryCollectionFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LibraryCollectionFilter = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
