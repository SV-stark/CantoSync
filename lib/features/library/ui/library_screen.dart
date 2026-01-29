import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:canto_sync/core/services/playback_sync_service.dart';

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
      ref.read(libraryServiceProvider).scanDirectory(selectedDirectory);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(libraryBooksProvider);
    final isGridView = ref.watch(libraryViewModeProvider);

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
              icon: const Icon(FluentIcons.add),
              label: const Text('Add Folder'),
              onPressed: () => _pickFolder(ref),
            ),
          ],
        ),
      ),
      content: booksAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FluentIcons.library, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Your library is empty'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _pickFolder(ref),
                    child: const Text('Add Folder'),
                  ),
                ],
              ),
            );
          }

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
        },
        loading: () => const Center(child: ProgressRing()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
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
        // Switch to player tab (TODO: implement navigation controller)
      },
      builder: (context, states) {
        return Card(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: Colors.grey.withValues(alpha: 0.2),
                  width: double.infinity,
                  child: book.coverPath != null
                      ? Image.file(
                          File(book.coverPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(FluentIcons.music_note, size: 48);
                          },
                        )
                      : const Icon(FluentIcons.music_note, size: 48),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FluentTheme.of(context).typography.bodyStrong,
                    ),
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
        );
      },
    );
  }
}
