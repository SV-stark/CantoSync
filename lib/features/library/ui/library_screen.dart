import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:canto_sync/core/services/playback_sync_service.dart';
import 'package:canto_sync/core/services/app_settings_service.dart';
import 'package:canto_sync/features/library/ui/metadata_editor.dart';
import 'package:canto_sync/features/library/ui/book_info_dialog.dart';

class LibraryViewModeNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle() => state = !state;
}

final libraryViewModeProvider = NotifierProvider<LibraryViewModeNotifier, bool>(
  LibraryViewModeNotifier.new,
);

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final FlyoutController _flyoutController = FlyoutController();

  @override
  void dispose() {
    _flyoutController.dispose();
    super.dispose();
  }

  Future<void> _pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      ref.read(appSettingsProvider.notifier).addLibraryPath(selectedDirectory);
    }
  }

  Future<void> _rescanLibrary(BuildContext context) async {
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: const Text('Scanning Library...'),
          content: const Text('Updating books and metadata'),
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
          severity: InfoBarSeverity.info,
        );
      },
    );

    await ref.read(libraryServiceProvider).rescanLibraries();

    if (context.mounted) {
      displayInfoBar(
        context,
        builder: (context, close) {
          return InfoBar(
            title: const Text('Scan Complete'),
            content: const Text('Library updated successfully'),
            action: IconButton(
              icon: const Icon(FluentIcons.clear),
              onPressed: close,
            ),
            severity: InfoBarSeverity.success,
          );
        },
      );
    }
  }

  void _showBookContextMenu(BuildContext context, Book book, Offset position) {
    _flyoutController.showFlyout(
      position: position,
      builder: (context) {
        return MenuFlyout(
          items: [
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.play),
              text: const Text('Play'),
              onPressed: () {
                ref.read(playbackSyncProvider).resumeBook(book.path);
              },
            ),
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.info),
              text: const Text('INFO'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => BookInfoDialog(book: book),
                );
              },
            ),
            const MenuFlyoutSeparator(),
            MenuFlyoutSubItem(
              leading: const Icon(FluentIcons.library),
              text: const Text('Collections'),
              items: (context) => [
                MenuFlyoutItem(
                  leading: const Icon(FluentIcons.add),
                  text: const Text('Add to New Collection'),
                  onPressed: () => _addToNewCollection(context, book),
                ),
                if (book.collections != null && book.collections!.isNotEmpty)
                  ...book.collections!.map(
                    (c) => MenuFlyoutItem(
                      text: Text(c),
                      trailing: const Icon(FluentIcons.remove),
                      onPressed: () async {
                        book.collections!.remove(c);
                        await book.save();
                        setState(() {});
                      },
                    ),
                  ),
              ],
            ),
            const MenuFlyoutSeparator(),
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.sync),
              text: const Text('Rescan'),
              onPressed: () {
                ref
                    .read(libraryServiceProvider)
                    .scanDirectory(book.path, forceUpdate: true);
              },
            ),
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.delete),
              text: const Text('Delete'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ContentDialog(
                    title: const Text('Delete Book?'),
                    content: Text(
                      'Are you sure you want to remove "${book.title}" from your library? This will not delete the files from your disk.',
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
                          ref
                              .read(libraryServiceProvider)
                              .deleteBook(book.path);
                          Navigator.pop(context);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addToNewCollection(BuildContext context, Book book) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Add to Collection'),
        content: TextBox(
          controller: controller,
          placeholder: 'Collection Name',
          autofocus: true,
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Add'),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                book.collections ??= [];
                if (!book.collections!.contains(name)) {
                  book.collections!.add(name);
                  await book.save();
                }
              }
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(libraryBooksProvider);
    final viewMode = ref.watch(libraryViewModeProvider);
    final isGroupingEnabled = ref.watch(libraryGroupingModeProvider);
    final selectedCollection = ref.watch(libraryCollectionFilterProvider);

    // Get all unique collections
    final allBooks = ref
        .watch(libraryBooksProvider)
        .maybeWhen(data: (books) => books, orElse: () => <Book>[]);
    final collections = <String>{};
    for (final book in allBooks) {
      if (book.collections != null) {
        collections.addAll(book.collections!);
      }
    }

    return NavigationView(
      pane: NavigationPane(
        selected: selectedCollection == null ? 0 : -1,
        header: const Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Text('Collections'),
        ),
        displayMode: PaneDisplayMode.compact,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.all_apps),
            title: const Text('All Books'),
            body: const SizedBox.shrink(),
            onTap: () {
              ref
                  .read(libraryCollectionFilterProvider.notifier)
                  .setFilter(null);
            },
          ),
          ...collections.map((c) {
            return PaneItem(
              icon: const Icon(FluentIcons.library),
              title: Text(c),
              body: const SizedBox.shrink(),
              onTap: () {
                ref.read(libraryCollectionFilterProvider.notifier).setFilter(c);
              },
            );
          }),
        ],
      ),
      content: ScaffoldPage(
        header: PageHeader(
          title: Text(selectedCollection ?? 'Library'),
          commandBar: CommandBar(
            mainAxisAlignment: MainAxisAlignment.end,
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.refresh),
                label: const Text('Rescan All'),
                onPressed: () => _rescanLibrary(context),
              ),
              CommandBarButton(
                icon: Icon(viewMode ? FluentIcons.list : FluentIcons.view_all),
                label: Text(viewMode ? 'List View' : 'Grid View'),
                onPressed: () {
                  ref.read(libraryViewModeProvider.notifier).toggle();
                },
              ),
              CommandBarButton(
                icon: Icon(
                  isGroupingEnabled
                      ? FluentIcons.group_list
                      : FluentIcons.group,
                ),
                label: const Text('Group by Series'),
                onPressed: () {
                  ref.read(libraryGroupingModeProvider.notifier).toggle();
                },
              ),
              CommandBarButton(
                icon: const Icon(FluentIcons.add),
                label: const Text('Add Folder'),
                onPressed: () => _pickFolder(),
              ),
            ],
          ),
        ),
        content: DropTarget(
          onDragDone: (detail) {
            for (final file in detail.files) {
              ref.read(libraryServiceProvider).scanDirectory(file.path);
            }
          },
          child: isGroupingEnabled
              ? _buildGroupedView(context)
              : booksAsync.when(
                  data: (books) {
                    if (books.isEmpty) return _buildEmptyState();
                    return _buildBookList(context, books, viewMode);
                  },
                  loading: () => const Center(child: ProgressRing()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FluentIcons.library, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No books found in this view'),
          const SizedBox(height: 16),
          const Text('Drag and drop a folder here or change filter'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _pickFolder(),
            child: const Text('Add Folder'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList(
    BuildContext context,
    List<Book> books,
    bool isGridView,
  ) {
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
            onSecondaryTap: (pos) => _showBookContextMenu(context, book, pos),
          );
        },
      );
    } else {
      return ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return FlyoutTarget(
            controller: _flyoutController,
            child: GestureDetector(
              onSecondaryTapDown: (detail) {
                _showBookContextMenu(context, book, detail.globalPosition);
              },
              child: ListTile(
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: book.coverPath != null
                        ? Image.file(File(book.coverPath!), fit: BoxFit.cover)
                        : const Icon(FluentIcons.music_note),
                  ),
                ),
                title: Text(book.title),
                subtitle: Text(book.author ?? 'Unknown Author'),
                onPressed: () {
                  ref.read(playbackSyncProvider).resumeBook(book.path);
                },
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildGroupedView(BuildContext context) {
    final groupedBooksAsync = ref.watch(libraryGroupedBooksProvider);
    final viewMode = ref.watch(libraryViewModeProvider);

    return groupedBooksAsync.when(
      data: (groups) {
        if (groups.isEmpty) return _buildEmptyState();

        final sortedKeys = groups.keys.toList()..sort();

        return ListView.builder(
          itemCount: sortedKeys.length,
          itemBuilder: (context, index) {
            final series = sortedKeys[index];
            final books = groups[series]!;

            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Expander(
                initiallyExpanded: true,
                header: Text(
                  series,
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                content: SizedBox(
                  height: viewMode
                      ? 300
                      : (books.length * 60.0).clamp(100.0, 500.0),
                  child: _buildBookList(context, books, viewMode),
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

class BookCard extends ConsumerWidget {
  final Book book;
  final Function(Offset)? onSecondaryTap;

  const BookCard({required this.book, this.onSecondaryTap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onSecondaryTapDown: (detail) {
        if (onSecondaryTap != null) {
          onSecondaryTap!(detail.globalPosition);
        }
      },
      child: HoverButton(
        onPressed: () {
          ref.read(playbackSyncProvider).resumeBook(book.path);
        },
        builder: (context, states) {
          return Card(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          child: book.coverPath != null
                              ? Image.file(
                                  File(book.coverPath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        FluentIcons.music_note,
                                        size: 48,
                                      ),
                                )
                              : const Icon(FluentIcons.music_note, size: 48),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FluentTheme.of(
                              context,
                            ).typography.bodyStrong,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.author ?? 'Unknown Author',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FluentTheme.of(context).typography.caption,
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          FluentPageRoute(
                            builder: (context) => MetadataEditor(book: book),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
