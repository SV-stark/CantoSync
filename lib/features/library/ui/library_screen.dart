import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:canto_sync/core/services/playback_sync_service.dart';
import 'package:canto_sync/core/services/app_settings_service.dart';
import 'package:canto_sync/features/library/ui/metadata_editor.dart';
import 'package:canto_sync/features/library/ui/book_info_dialog.dart';
import 'package:canto_sync/core/constants/app_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:canto_sync/core/data/keyboard_shortcuts.dart';
import 'package:canto_sync/core/services/keyboard_shortcuts_service.dart';

part 'library_screen.g.dart';

@riverpod
class LibraryViewMode extends _$LibraryViewMode {
  @override
  bool build() => true;
  void toggle() => state = !state;
}

class LibraryScreen extends HookConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(libraryBooksProvider);
    final viewMode = ref.watch(libraryViewModeProvider);
    final isGroupingEnabled = ref.watch(libraryGroupingModeProvider);
    final selectedCollection = ref.watch(libraryCollectionFilterProvider);
    final collectionsAsync = ref.watch(libraryCollectionsProvider);

    final sortedCollections = collectionsAsync.maybeWhen(
      data: (c) => c,
      orElse: () => <String>[],
    );

    final searchController = useTextEditingController(
      text: ref.read(librarySearchQueryProvider),
    );
    final searchQuery = ref.watch(librarySearchQueryProvider);
    useEffect(() {
      if (searchController.text != searchQuery) {
        searchController.text = searchQuery;
      }
      return null;
    }, [searchQuery]);

    final searchFocusNode = useFocusNode();
    useEffect(() {
      final callbacks = ref.read(shortcutActionCallbacksProvider.notifier);

      void onFocusSearch() {
        searchFocusNode.requestFocus();
      }

      void onToggleViewMode() {
        ref.read(libraryViewModeProvider.notifier).toggle();
      }

      callbacks.register(ShortcutAction.focusSearch, onFocusSearch);
      callbacks.register(ShortcutAction.toggleViewMode, onToggleViewMode);

      return () {
        callbacks.unregister(ShortcutAction.focusSearch, onFocusSearch);
        callbacks.unregister(ShortcutAction.toggleViewMode, onToggleViewMode);
      };
    }, []);

    Future<void> pickFolder() async {
      String? selectedDirectory = await FilePicker.getDirectoryPath();
      if (selectedDirectory != null) {
        ref
            .read(appSettingsProvider.notifier)
            .addLibraryPath(selectedDirectory);
      }
    }

    final isScanning = useState(false);

    Future<void> rescanLibrary() async {
      if (isScanning.value) return;
      isScanning.value = true;
      displayInfoBar(
        context,
        builder: (context, close) => InfoBar(
          title: const Text('Scanning Library...'),
          content: const Text('Updating books and metadata'),
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
          severity: InfoBarSeverity.info,
        ),
      );

      await ref.read(libraryServiceProvider).rescanLibraries();
      isScanning.value = false;

      if (context.mounted) {
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: const Text('Scan Complete'),
            content: const Text('Library updated successfully'),
            action: IconButton(
              icon: const Icon(FluentIcons.clear),
              onPressed: close,
            ),
            severity: InfoBarSeverity.success,
          ),
        );
      }
    }

    return ScaffoldPage(
      header: PageHeader(
        title: Text(selectedCollection ?? 'Library'),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 240,
              child: TextBox(
                controller: searchController,
                focusNode: searchFocusNode,
                placeholder: 'Search title, author, narrator...',
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(FluentIcons.search, size: 14),
                ),
                suffix: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(FluentIcons.clear, size: 10),
                        onPressed: () {
                          searchController.clear();
                          ref
                              .read(librarySearchQueryProvider.notifier)
                              .setQuery('');
                        },
                      )
                    : null,
                onChanged: (value) => ref
                    .read(librarySearchQueryProvider.notifier)
                    .setQuery(value),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Toggle View Mode',
              child: IconButton(
                icon: Icon(
                  viewMode ? FluentIcons.list : FluentIcons.view_all,
                ),
                onPressed: () =>
                    ref.read(libraryViewModeProvider.notifier).toggle(),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Toggle Grouping by Series',
              child: IconButton(
                icon: Icon(
                  isGroupingEnabled
                      ? FluentIcons.group_list
                      : FluentIcons.bulleted_list,
                  color: isGroupingEnabled
                      ? FluentTheme.of(context).accentColor
                      : null,
                ),
                onPressed: () =>
                    ref.read(libraryGroupingModeProvider.notifier).toggle(),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Rescan Library',
              child: IconButton(
                icon: const Icon(FluentIcons.refresh),
                onPressed: isScanning.value ? null : rescanLibrary,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: pickFolder,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FluentIcons.add, size: 12),
                  SizedBox(width: 6),
                  Text('Add Folder'),
                ],
              ),
            ),
          ],
        ),
      ),
      content: Row(
        children: [
          _Sidebar(
            selectedCollection: selectedCollection,
            sortedCollections: sortedCollections,
          ),
          const Divider(direction: Axis.vertical),
          Expanded(
            child: DropTarget(
              onDragDone: (detail) async {
                final files = detail.files;
                if (files.isEmpty) return;
                for (final file in files) {
                  await ref.read(libraryServiceProvider).scanDirectory(file.path);
                }
                if (context.mounted) {
                  displayInfoBar(
                    context,
                    builder: (context, close) => InfoBar(
                      title: const Text('Import Complete'),
                      content: Text('Processed ${files.length} dragged item(s).'),
                      action: IconButton(
                        icon: const Icon(FluentIcons.clear),
                        onPressed: close,
                      ),
                      severity: InfoBarSeverity.success,
                    ),
                  );
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _RecentsRow(),
                  Expanded(
                    child: Skeletonizer(
                      enabled: booksAsync.isLoading,
                      child: isGroupingEnabled
                          ? _GroupedView(
                              viewMode: viewMode,
                            )
                          : booksAsync.maybeWhen(
                              data: (books) {
                                if (books.isEmpty) {
                                  return _EmptyState(onAddFolder: pickFolder);
                                }
                                return _BookList(
                                  books: books,
                                  isGridView: viewMode,
                                );
                              },
                              orElse: () => const Center(child: ProgressRing()),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.selectedCollection,
    required this.sortedCollections,
  });
  final String? selectedCollection;
  final List<String> sortedCollections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 200,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'Collections',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile.selectable(
            selected: selectedCollection == null,
            leading: const Icon(FluentIcons.all_apps),
            title: const Text('All Books'),
            onPressed: () => ref
                .read(libraryCollectionFilterProvider.notifier)
                .setFilter(null),
          ),
          ...sortedCollections.map(
            (c) => _CollectionTile(
              name: c,
              isSelected: selectedCollection == c,
              onTap: () => ref
                  .read(libraryCollectionFilterProvider.notifier)
                  .setFilter(c),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionTile extends ConsumerStatefulWidget {
  const _CollectionTile({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  ConsumerState<_CollectionTile> createState() => _CollectionTileState();
}

class _CollectionTileState extends ConsumerState<_CollectionTile> {
  final FlyoutController _flyoutController = FlyoutController();

  @override
  void dispose() {
    _flyoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlyoutTarget(
      controller: _flyoutController,
      child: GestureDetector(
        onSecondaryTapDown: (detail) => _showCollectionContextMenu(
          context,
          ref,
          widget.name,
          detail.globalPosition,
          _flyoutController,
        ),
        child: ListTile.selectable(
          selected: widget.isSelected,
          leading: const Icon(FluentIcons.library),
          title: Text(widget.name),
          onPressed: widget.onTap,
        ),
      ),
    );
  }

  void _showCollectionContextMenu(
    BuildContext context,
    WidgetRef ref,
    String collectionName,
    Offset position,
    FlyoutController controller,
  ) {
    final libraryService = ref.read(libraryServiceProvider);
    controller.showFlyout(
      position: position,
      builder: (context) => MenuFlyout(
        items: [
          MenuFlyoutItem(
            leading: const Icon(FluentIcons.play),
            text: const Text('Play All'),
            onPressed: () async {
              final books = await libraryService.getAllBooks();
              final collectionBooks = books
                  .where(
                    (b) => b.collections?.contains(collectionName) ?? false,
                  )
                  .toList();
              if (collectionBooks.isNotEmpty) {
                collectionBooks.sort((a, b) {
                  if (a.seriesIndex != null && b.seriesIndex != null) {
                    return a.seriesIndex!.compareTo(b.seriesIndex!);
                  }
                  if (a.seriesIndex != null) return -1;
                  if (b.seriesIndex != null) return 1;
                  return (a.title ?? '').compareTo(b.title ?? '');
                });
                final firstToPlay = collectionBooks.firstWhere(
                  (b) =>
                      _calculateBookProgress(b) <
                      AppConstants.bookCompletionThreshold,
                  orElse: () => collectionBooks.first,
                );
                if (firstToPlay.path != null) {
                  ref
                      .read(playbackSyncProvider)
                      .resumeBook(firstToPlay.path!);
                }
              }
            },
          ),
          const MenuFlyoutSeparator(),
          MenuFlyoutItem(
            leading: const Icon(FluentIcons.delete),
            text: const Text('Delete Collection'),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => ContentDialog(
                title: const Text('Delete Collection?'),
                content: Text(
                  'Are you sure you want to delete "$collectionName"? Books will remain.',
                ),
                actions: [
                  Button(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.red),
                    ),
                    onPressed: () async {
                      await libraryService.removeCollection(collectionName);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddFolder});
  final VoidCallback onAddFolder;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FluentIcons.library, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No books found in this view'),
          const SizedBox(height: 16),
          FilledButton(onPressed: onAddFolder, child: const Text('Add Folder')),
        ],
      ),
    );
  }
}

class _BookList extends ConsumerWidget {
  const _BookList({
    required this.books,
    required this.isGridView,
    required this.flyoutController,
    this.seriesTotals,
  });
  final List<Book> books;
  final bool isGridView;
  final Map<String, int>? seriesTotals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isGridView) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        padding: const EdgeInsets.all(16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return BookCard(
            book: book,
            seriesTotal: (book.series != null && seriesTotals != null)
                ? seriesTotals![book.series!]
                : null,
          );
        },
      );
    } else {
      return ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          return _BookListTile(book: books[index]);
        },
      );
    }
  }
}

class _BookListTile extends ConsumerStatefulWidget {
  const _BookListTile({required this.book});
  final Book book;

  @override
  ConsumerState<_BookListTile> createState() => _BookListTileState();
}

class _BookListTileState extends ConsumerState<_BookListTile> {
  final FlyoutController _flyoutController = FlyoutController();

  @override
  void dispose() {
    _flyoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return FlyoutTarget(
      controller: _flyoutController,
      child: GestureDetector(
        onSecondaryTapDown: (detail) => _showBookContextMenu(
          context,
          ref,
          book,
          detail.globalPosition,
          _flyoutController,
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: book.coverPath != null
                ? Image.file(
                    File(book.coverPath!),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  )
                : const Icon(FluentIcons.music_note),
          ),
          title: Text(book.title ?? 'Unknown'),
          subtitle: Text(book.author ?? 'Unknown Author'),
          trailing: book.fileExtension.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: FluentTheme.of(
                      context,
                    ).resources.subtleFillColorSecondary,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: FluentTheme.of(
                        context,
                      ).resources.controlStrokeColorDefault,
                    ),
                  ),
                  child: Text(
                    book.fileExtension.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: FluentTheme.of(
                        context,
                      ).typography.caption?.color,
                    ),
                  ),
                )
              : null,
          onPressed: () =>
              ref.read(playbackSyncProvider).resumeBook(book.path!),
        ),
      ),
    );
  }
}

class _GroupedView extends ConsumerWidget {
  const _GroupedView({required this.viewMode});
  final bool viewMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedBooksAsync = ref.watch(libraryGroupedBooksProvider);

    return groupedBooksAsync.when(
      data: (groups) {
        if (groups.isEmpty) return const SizedBox.shrink();
        final sortedKeys = groups.keys.toList()..sort();
        final seriesTotals = groups.map(
          (key, value) => MapEntry(key, value.length),
        );

        return ListView.builder(
          itemCount: sortedKeys.length,
          itemBuilder: (context, index) {
            final series = sortedKeys[index];
            final books = groups[series]!;
            return Expander(
              initiallyExpanded: true,
              header: Text(
                series,
                style: FluentTheme.of(context).typography.subtitle,
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: viewMode
                      ? 300
                      : (books.length * 60.0).clamp(100.0, 1000.0),
                ),
                child: _BookList(
                  books: books,
                  isGridView: viewMode,
                  seriesTotals: seriesTotals,
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: ProgressRing()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _RecentsRow extends ConsumerWidget {
  const _RecentsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentBooks = ref.watch(libraryRecentBooksProvider);
    if (recentBooks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            'Continue Listening',
            style: FluentTheme.of(context).typography.subtitle,
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: recentBooks.length,
            itemBuilder: (context, index) => Container(
              width: 120,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: BookCard(
                book: recentBooks[index],
              ),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

double _calculateBookProgress(Book book) {
  final dur = book.durationSeconds ?? 0;
  if (dur <= 0) return 0.0;
  final pos = book.positionSeconds ?? 0;
  if (book.audioFiles != null && book.audioFiles!.length > 1 && book.filesMetadata != null) {
    final trackIndex = (book.lastTrackIndex ?? 0).clamp(0, book.filesMetadata!.length - 1);
    double cumulativeBefore = 0;
    for (int i = 0; i < trackIndex; i++) {
      cumulativeBefore += book.filesMetadata![i].duration ?? 0;
    }
    final effectivePos = cumulativeBefore + pos;
    return (effectivePos / dur).clamp(0.0, 1.0);
  }
  return (pos / dur).clamp(0.0, 1.0);
}

class BookCard extends ConsumerStatefulWidget {
  const BookCard({
    required this.book,
    this.seriesTotal,
    super.key,
  });
  final Book book;
  final int? seriesTotal;

  @override
  ConsumerState<BookCard> createState() => _BookCardState();
}

class _BookCardState extends ConsumerState<BookCard> {
  final FlyoutController _flyoutController = FlyoutController();

  @override
  void dispose() {
    _flyoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final seriesTotal = widget.seriesTotal;
    final progress = _calculateBookProgress(book);
    final hasProgress =
        progress > 0 && progress < AppConstants.bookCompletionThreshold;
    final isCompleted = progress >= AppConstants.bookCompletionThreshold;

    return FlyoutTarget(
      controller: _flyoutController,
      child: GestureDetector(
        onSecondaryTapDown: (detail) => _showBookContextMenu(
          context,
          ref,
          book,
          detail.globalPosition,
          _flyoutController,
        ),
        child: HoverButton(
          onPressed: () => ref.read(playbackSyncProvider).resumeBook(book.path!),
          builder: (context, states) => Card(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (book.coverPath != null)
                              Image.file(
                                File(book.coverPath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: FluentTheme.of(
                                    context,
                                  ).resources.subtleFillColorSecondary,
                                  child: const Center(
                                    child: Icon(
                                      FluentIcons.music_in_collection,
                                      size: 48,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                color: FluentTheme.of(
                                  context,
                                ).resources.subtleFillColorSecondary,
                                child: const Center(
                                  child: Icon(
                                    FluentIcons.music_in_collection,
                                    size: 48,
                                  ),
                                ),
                              ),

                          if (hasProgress)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: CircularPercentIndicator(
                                  radius: 12.0,
                                  lineWidth: 3.0,
                                  percent: progress,
                                  progressColor: Colors.blue,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                            ),

                          if (isCompleted)
                            _Badge(
                              icon: FluentIcons.check_mark,
                              label: 'Finished',
                              color: Colors.green,
                            ),

                          if (hasProgress)
                            _Badge(
                              icon: FluentIcons.play_resume,
                              label: 'Continue',
                              color: Colors.orange,
                              topOffset: isCompleted ? 36 : 8,
                            ),

                          if (book.series != null && book.seriesIndex != null)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Book ${book.seriesIndex}${seriesTotal != null ? ' of $seriesTotal' : ''}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title ?? 'Unknown',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FluentTheme.of(context).typography.bodyStrong,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                book.author ?? 'Unknown Author',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FluentTheme.of(
                                  context,
                                ).typography.caption,
                              ),
                            ),
                            if (book.fileExtension.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: FluentTheme.of(
                                    context,
                                  ).resources.subtleFillColorSecondary,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: FluentTheme.of(
                                      context,
                                    ).resources.controlStrokeColorDefault,
                                  ),
                                ),
                                child: Text(
                                  book.fileExtension.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: FluentTheme.of(
                                      context,
                                    ).typography.caption?.color,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (states.isHovered)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(FluentIcons.edit),
                    onPressed: () => Navigator.push(
                      context,
                      FluentPageRoute(
                        builder: (context) => MetadataEditor(book: book),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    this.topOffset = 8,
  });
  final IconData icon;
  final String label;
  final Color color;
  final double topOffset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topOffset,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showBookContextMenu(
  BuildContext context,
  WidgetRef ref,
  Book book,
  Offset position,
  FlyoutController controller,
) {
  controller.showFlyout(
    position: position,
    builder: (context) => MenuFlyout(
      items: [
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.play),
          text: const Text('Play'),
          onPressed: () =>
              ref.read(playbackSyncProvider).resumeBook(book.path!),
        ),
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.edit),
          text: const Text('Edit Metadata'),
          onPressed: () => Navigator.push(
            context,
            FluentPageRoute(
              builder: (context) => MetadataEditor(book: book),
            ),
          ),
        ),
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.tag),
          text: const Text('Add to Collection...'),
          onPressed: () => _showAddToCollectionDialog(context, ref, book),
        ),
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.info),
          text: const Text('INFO'),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => BookInfoDialog(book: book),
          ),
        ),
        const MenuFlyoutSeparator(),
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.delete),
          text: const Text('Delete'),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => ContentDialog(
              title: const Text('Delete Book?'),
              content: Text(
                'Are you sure you want to remove "${book.title ?? 'Unknown'}"?',
              ),
              actions: [
                Button(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.red),
                  ),
                  onPressed: () {
                    ref.read(libraryServiceProvider).deleteBook(book.path!);
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

void _showAddToCollectionDialog(
  BuildContext context,
  WidgetRef ref,
  Book book,
) {
  final textController = TextEditingController();
  showDialog(
    context: context,
    builder: (dialogContext) => ContentDialog(
      title: const Text('Add to Collection'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter collection name:'),
          const SizedBox(height: 8),
          TextBox(
            controller: textController,
            placeholder: 'e.g. Sci-Fi, Favorites, To Listen',
            autofocus: true,
          ),
        ],
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(dialogContext),
        ),
        FilledButton(
          child: const Text('Add'),
          onPressed: () {
            final name = textController.text.trim();
            if (name.isNotEmpty && book.path != null) {
              ref.read(libraryServiceProvider).assignCollection(book.path!, name);
            }
            Navigator.pop(dialogContext);
          },
        ),
      ],
    ),
  );
}
