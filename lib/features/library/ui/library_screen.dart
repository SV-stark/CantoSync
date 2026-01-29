import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:canto_sync/core/services/playback_sync_service.dart';

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

    return ScaffoldPage.withPadding(
      header: PageHeader(
        title: const Text('Library'),
        commandBar: CommandBar(
          primaryItems: [
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
                  color: Colors.grey.withValues(
                    alpha: 0.2,
                  ), // Placeholder cover
                  width: double.infinity,
                  child: const Icon(FluentIcons.music_note, size: 48),
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
