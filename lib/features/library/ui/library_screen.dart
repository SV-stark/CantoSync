import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:canto_sync/core/services/playback_sync_service.dart';

import 'package:canto_sync/core/services/app_settings_service.dart';

class LibraryViewMode extends Notifier<bool> {
  @override
  bool build() => true; // Grid by default

  void toggle() => state = !state;
}

final libraryViewModeProvider = NotifierProvider<LibraryViewMode, bool>(
  LibraryViewMode.new,
);

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  Future<void> _pickFolder(WidgetRef ref) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      ref.read(appSettingsProvider.notifier).addLibraryPath(selectedDirectory);
      ref.read(libraryServiceProvider).scanDirectory(selectedDirectory);
    }
  }

  Future<void> _rescanLibrary(BuildContext context, WidgetRef ref) async {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(libraryBooksProvider);
    final isGridView = ref.watch(libraryViewModeProvider);
    final isGroupingEnabled = ref.watch(libraryGroupingModeProvider);

    return ScaffoldPage.withPadding(
      header: PageHeader(
        title: const Text('Library'),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
              icon: Icon(
                isGridView ? FluentIcons.view_all : FluentIcons.bulleted_list,
              ),
              label: Text(isGridView ? 'Grid View' : 'List View'),
              onPressed: () =>
                  ref.read(libraryViewModeProvider.notifier).toggle(),
            ),
            const CommandBarSeparator(),
            CommandBarButton(
              icon: Icon(
                isGroupingEnabled ? FluentIcons.group_list : FluentIcons.group,
              ),
              label: const Text('Group by Series'),
              onPressed: () =>
                  ref.read(libraryGroupingModeProvider.notifier).toggle(),
            ),
            CommandBarBuilderItem(
              builder: (context, mode, w) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: TextBox(
                  placeholder: 'Search library...',
                  onChanged: (text) => ref
                      .read(librarySearchQueryProvider.notifier)
                      .updateQuery(text),
                  suffix: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(FluentIcons.search),
                  ),
                ),
              ),
              wrappedItem:
                  CommandBarButton(
                        icon: const Icon(FluentIcons.search),
                        onPressed: () {},
                      )
                      as CommandBarItem,
            ),
            const CommandBarSeparator(),
            CommandBarButton(
              icon: const Icon(FluentIcons.sync),
              label: const Text('Rescan'),
              onPressed: () => _rescanLibrary(context, ref),
            ),
            const CommandBarSeparator(),
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('Add Folder'),
              onPressed: () => _pickFolder(ref),
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
            ? _buildGroupedView(context, ref)
            : booksAsync.when(
                data: (books) {
                  if (books.isEmpty) return _buildEmptyState(ref);
                  return _buildBookList(context, books, isGridView, ref);
                },
                loading: () => const Center(child: ProgressRing()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
      ),
    );
  }

  Widget _buildEmptyState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FluentIcons.library, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Your library is empty'),
          const SizedBox(height: 16),
          const Text('Drag and drop a folder here to import books'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _pickFolder(ref),
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
    WidgetRef ref,
  ) {
    if (isGridView) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return BookCard(book: book);
        },
      );
    } else {
      return ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return ListTile(
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
          );
        },
      );
    }
  }

  Widget _buildGroupedView(BuildContext context, WidgetRef ref) {
    final groupedBooksAsync = ref.watch(libraryGroupedBooksProvider);
    final isGridView = ref.watch(libraryViewModeProvider);

    return groupedBooksAsync.when(
      data: (groups) {
        if (groups.isEmpty) return _buildEmptyState(ref);

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
                  // Dynamic height based on view mode and item count
                  height: isGridView
                      ? 300
                      : (books.length * 60.0).clamp(100.0, 500.0),
                  child: _buildBookList(context, books, isGridView, ref),
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

  const BookCard({required this.book, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HoverButton(
      onPressed: () {
        ref.read(playbackSyncProvider).resumeBook(book.path);
      },
      builder: (context, states) {
        return Card(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    boxShadow: states.isHovered
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
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
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                FluentIcons.music_note,
                                size: 48,
                              );
                            },
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
                      style: FluentTheme.of(context).typography.bodyStrong,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author ?? 'Unknown Author',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FluentTheme.of(context).typography.caption
                          ?.copyWith(
                            color: FluentTheme.of(
                              context,
                            ).typography.caption?.color?.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
