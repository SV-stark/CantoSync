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
    final flyoutController = useMemoized(() => FlyoutController());
    useEffect(() => flyoutController.dispose, [flyoutController]);

    final booksAsync = ref.watch(libraryBooksProvider);
    final viewMode = ref.watch(libraryViewModeProvider);
    final isGroupingEnabled = ref.watch(libraryGroupingModeProvider);
    final selectedCollection = ref.watch(libraryCollectionFilterProvider);

    final allBooks = ref.watch(libraryBooksProvider).maybeWhen(
          data: (books) => books,
          orElse: () => <Book>[],
        );

    final collections = <String>{};
    for (final book in allBooks) {
      if (book.collections != null) {
        collections.addAll(book.collections!);
      }
    }
    final sortedCollections = collections.toList()..sort();

    Future<void> pickFolder() async {
      String? selectedDirectory = await FilePicker.getDirectoryPath();
      if (selectedDirectory != null) {
        ref.read(appSettingsNotifierProvider.notifier).addLibraryPath(selectedDirectory);
      }
    }

    Future<void> rescanLibrary() async {
      displayInfoBar(
        context,
        builder: (context, close) => InfoBar(
          title: const Text('Scanning Library...'),
          content: const Text('Updating books and metadata'),
          action: IconButton(icon: const Icon(FluentIcons.clear), onPressed: close),
          severity: InfoBarSeverity.info,
        ),
      );

      await ref.read(libraryServiceProvider).rescanLibraries();

      if (context.mounted) {
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: const Text('Scan Complete'),
            content: const Text('Library updated successfully'),
            action: IconButton(icon: const Icon(FluentIcons.clear), onPressed: close),
            severity: InfoBarSeverity.success,
          ),
        );
      }
    }

    return ScaffoldPage(
      header: PageHeader(
        title: Text(selectedCollection ?? 'Library'),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.refresh),
              label: const Text('Rescan All'),
              onPressed: rescanLibrary,
            ),
            CommandBarButton(
              icon: Icon(viewMode ? FluentIcons.list : FluentIcons.view_all),
              label: Text(viewMode ? 'List View' : 'Grid View'),
              onPressed: () => ref.read(libraryViewModeProvider.notifier).toggle(),
            ),
            CommandBarButton(
              icon: Icon(isGroupingEnabled ? FluentIcons.group_list : FluentIcons.group),
              label: const Text('Group by Series'),
              onPressed: () => ref.read(libraryGroupingModeProvider.notifier).toggle(),
            ),
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('Add Folder'),
              onPressed: pickFolder,
            ),
          ],
        ),
      ),
      content: Row(
        children: [
          _Sidebar(
            selectedCollection: selectedCollection,
            sortedCollections: sortedCollections,
            flyoutController: flyoutController,
          ),
          const Divider(direction: Axis.vertical),
          Expanded(
            child: DropTarget(
              onDragDone: (detail) {
                for (final file in detail.files) {
                  ref.read(libraryServiceProvider).scanDirectory(file.path);
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RecentsRow(flyoutController: flyoutController),
                  Expanded(
                    child: Skeletonizer(
                      enabled: booksAsync.isLoading,
                      child: isGroupingEnabled
                          ? _GroupedView(
                              viewMode: viewMode,
                              flyoutController: flyoutController,
                            )
                          : booksAsync.maybeWhen(
                              data: (books) {
                                if (books.isEmpty) return _EmptyState(onAddFolder: pickFolder);
                                return _BookList(
                                  books: books,
                                  isGridView: viewMode,
                                  flyoutController: flyoutController,
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
    required this.flyoutController,
  });
  final String? selectedCollection;
  final List<String> sortedCollections;
  final FlyoutController flyoutController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 200,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text('Collections', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile.selectable(
            selected: selectedCollection == null,
            leading: const Icon(FluentIcons.all_apps),
            title: const Text('All Books'),
            onPressed: () => ref.read(libraryCollectionFilterProvider.notifier).setFilter(null),
          ),
          ...sortedCollections.map((c) => FlyoutTarget(
                controller: flyoutController,
                child: GestureDetector(
                  onSecondaryTapDown: (detail) => _showCollectionContextMenu(context, ref, c, detail.globalPosition, flyoutController),
                  child: ListTile.selectable(
                    selected: selectedCollection == c,
                    leading: const Icon(FluentIcons.library),
                    title: Text(c),
                    onPressed: () => ref.read(libraryCollectionFilterProvider.notifier).setFilter(c),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _showCollectionContextMenu(BuildContext context, WidgetRef ref, String collectionName, Offset position, FlyoutController controller) {
    final libraryService = ref.read(libraryServiceProvider);
    controller.showFlyout(
      position: position,
      builder: (context) => MenuFlyout(
        items: [
          MenuFlyoutItem(
            leading: const Icon(FluentIcons.play),
            text: const Text('Play All'),
            onPressed: () async {
              final books = await libraryService.getAllBooks(); // Simplified for now
              final collectionBooks = books.where((b) => b.collections?.contains(collectionName) ?? false).toList();
              if (collectionBooks.isNotEmpty) {
                ref.read(playbackSyncProvider).resumeBook(collectionBooks.first.path!);
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
                content: Text('Are you sure you want to delete "$collectionName"? Books will remain.'),
                actions: [
                  Button(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
                  FilledButton(
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
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
  final FlyoutController flyoutController;
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
          return FlyoutTarget(
            controller: flyoutController,
            child: BookCard(
              book: book,
              flyoutController: flyoutController,
              seriesTotal: (book.series != null && seriesTotals != null) ? seriesTotals![book.series!] : null,
            ),
          );
        },
      );
    } else {
      return ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return GestureDetector(
            onSecondaryTapDown: (detail) => _showBookContextMenu(context, ref, book, detail.globalPosition, flyoutController),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: book.coverPath != null ? Image.file(File(book.coverPath!), width: 40, height: 40, fit: BoxFit.cover) : const Icon(FluentIcons.music_note),
              ),
              title: Text(book.title ?? 'Unknown'),
              subtitle: Text(book.author ?? 'Unknown Author'),
              onPressed: () => ref.read(playbackSyncProvider).resumeBook(book.path!),
            ),
          );
        },
      );
    }
  }
}

class _GroupedView extends ConsumerWidget {

  const _GroupedView({required this.viewMode, required this.flyoutController});
  final bool viewMode;
  final FlyoutController flyoutController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedBooksAsync = ref.watch(libraryGroupedBooksProvider);

    return groupedBooksAsync.when(
      data: (groups) {
        if (groups.isEmpty) return const SizedBox.shrink();
        final sortedKeys = groups.keys.toList()..sort();
        final seriesTotals = groups.map((key, value) => MapEntry(key, value.length));

        return ListView.builder(
          itemCount: sortedKeys.length,
          itemBuilder: (context, index) {
            final series = sortedKeys[index];
            final books = groups[series]!;
            return Expander(
              initiallyExpanded: true,
              header: Text(series, style: FluentTheme.of(context).typography.subtitle),
              content: SizedBox(
                height: viewMode ? 300 : (books.length * 60.0).clamp(100.0, 500.0),
                child: _BookList(
                  books: books,
                  isGridView: viewMode,
                  flyoutController: flyoutController,
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
  const _RecentsRow({required this.flyoutController});
  final FlyoutController flyoutController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentBooks = ref.watch(libraryRecentBooksProvider);
    if (recentBooks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text('Continue Listening', style: FluentTheme.of(context).typography.subtitle),
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
              child: BookCard(book: recentBooks[index], flyoutController: flyoutController),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class BookCard extends ConsumerWidget {

  const BookCard({required this.book, required this.flyoutController, this.seriesTotal, super.key});
  final Book book;
  final FlyoutController flyoutController;
  final int? seriesTotal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dur = book.durationSeconds ?? 1;
    final pos = book.positionSeconds ?? 0;
    final progress = (pos / dur).clamp(0.0, 1.0);
    final hasProgress = pos > 0 && pos < dur * AppConstants.bookCompletionThreshold;
    final isCompleted = dur > 0 && pos >= dur * AppConstants.bookCompletionThreshold;

    return GestureDetector(
      onSecondaryTapDown: (detail) => _showBookContextMenu(context, ref, book, detail.globalPosition, flyoutController),
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
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (book.coverPath != null)
                            Image.file(File(book.coverPath!), fit: BoxFit.cover)
                          else
                            const Center(child: Icon(FluentIcons.music_note, size: 48)),
                          
                          if (hasProgress)
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: CircularPercentIndicator(
                                radius: 18.0,
                                lineWidth: 3.0,
                                percent: progress,
                                center: Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                progressColor: Colors.white,
                                backgroundColor: Colors.white.withAlpha(51),
                                circularStrokeCap: CircularStrokeCap.round,
                                fillColor: Colors.black.withAlpha(179),
                              ),
                            ),
                          
                          if (isCompleted)
                            _Badge(icon: FluentIcons.check_mark, label: 'Completed', color: Colors.green),
                          if (hasProgress && !isCompleted)
                            _Badge(icon: FluentIcons.play_resume, label: 'Continue', color: Colors.orange, topOffset: isCompleted ? 36 : 8),
                          
                          if (book.series != null && book.seriesIndex != null)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.black.withAlpha(179), borderRadius: BorderRadius.circular(12)),
                                child: Text('Book ${book.seriesIndex}${seriesTotal != null ? ' of $seriesTotal' : ''}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
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
                        Text(book.title ?? 'Unknown', maxLines: 1, overflow: TextOverflow.ellipsis, style: FluentTheme.of(context).typography.bodyStrong),
                        const SizedBox(height: 4),
                        Text(book.author ?? 'Unknown Author', maxLines: 1, overflow: TextOverflow.ellipsis, style: FluentTheme.of(context).typography.caption),
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
                    onPressed: () => Navigator.push(context, FluentPageRoute(builder: (context) => MetadataEditor(book: book))),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {

  const _Badge({required this.icon, required this.label, required this.color, this.topOffset = 8});
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
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

void _showBookContextMenu(BuildContext context, WidgetRef ref, Book book, Offset position, FlyoutController controller) {
  controller.showFlyout(
    position: position,
    builder: (context) => MenuFlyout(
      items: [
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.play),
          text: const Text('Play'),
          onPressed: () => ref.read(playbackSyncProvider).resumeBook(book.path!),
        ),
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.info),
          text: const Text('INFO'),
          onPressed: () => showDialog(context: context, builder: (context) => BookInfoDialog(book: book)),
        ),
        const MenuFlyoutSeparator(),
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.delete),
          text: const Text('Delete'),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => ContentDialog(
              title: const Text('Delete Book?'),
              content: Text('Are you sure you want to remove "${book.title ?? 'Unknown'}"?'),
              actions: [
                Button(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
                FilledButton(
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
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
