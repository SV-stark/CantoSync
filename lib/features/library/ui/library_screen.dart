import 'dart:io';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
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
                  ...book.collections!.toList().map(
                    (c) => MenuFlyoutItem(
                      text: Text(c),
                      trailing: const Icon(FluentIcons.remove),
                      onPressed: () async {
                        book.collections!.remove(c);
                        await book.save();
                        if (mounted) {
                          setState(() {});
                        }
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

  void _showCollectionContextMenu(
    BuildContext context,
    String collectionName,
    Offset position,
  ) {
    final libraryService = ref.read(libraryServiceProvider);
    _flyoutController.showFlyout(
      position: position,
      builder: (context) {
        return MenuFlyout(
          items: [
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.play),
              text: const Text('Play All'),
              onPressed: () async {
                final books = libraryService.getBooksByCollection(
                  collectionName,
                );
                if (books.isNotEmpty) {
                  ref.read(playbackSyncProvider).resumeBook(books.first.path);
                }
              },
            ),
            const MenuFlyoutSeparator(),
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.delete),
              text: const Text('Delete Collection'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ContentDialog(
                    title: const Text('Delete Collection?'),
                    content: Text(
                      'Are you sure you want to delete the collection "$collectionName"? Books will remain in your library.',
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
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
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
    final sortedCollections = collections.toList()..sort();

    return ScaffoldPage(
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
                isGroupingEnabled ? FluentIcons.group_list : FluentIcons.group,
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
      content: Row(
        children: [
          // Sidebar
          SizedBox(
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
                  onPressed: () {
                    ref
                        .read(libraryCollectionFilterProvider.notifier)
                        .setFilter(null);
                  },
                ),
                ...sortedCollections.map((c) {
                  return FlyoutTarget(
                    controller: _flyoutController,
                    child: GestureDetector(
                      onSecondaryTapDown: (detail) {
                        _showCollectionContextMenu(
                          context,
                          c,
                          detail.globalPosition,
                        );
                      },
                      child: ListTile.selectable(
                        selected: selectedCollection == c,
                        leading: const Icon(FluentIcons.library),
                        title: Text(c),
                        onPressed: () {
                          ref
                              .read(libraryCollectionFilterProvider.notifier)
                              .setFilter(c);
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(direction: Axis.vertical),
          // Main Content
          Expanded(
            child: DropTarget(
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
        ],
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
    bool isGridView, {
    Map<String, int>? seriesTotals,
  }) {
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
          final seriesTotal = book.series != null
              ? (seriesTotals != null ? seriesTotals[book.series!] : null)
              : null;
          return FlyoutTarget(
            controller: _flyoutController,
            child: BookCard(
              book: book,
              onSecondaryTapDown: (pos) =>
                  _showBookContextMenu(context, book, pos),
              seriesTotal: seriesTotal,
            ),
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

        // Calculate series totals for each series
        final seriesTotals = <String, int>{};
        for (final entry in groups.entries) {
          final seriesName = entry.key;
          final booksInSeries = entry.value;
          seriesTotals[seriesName] = booksInSeries.length;
        }

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
                  child: _buildBookList(
                    context,
                    books,
                    viewMode,
                    seriesTotals: seriesTotals,
                  ),
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

class BookCard extends ConsumerStatefulWidget {
  final Book book;
  final Function(Offset)? onSecondaryTapDown;
  final int? seriesTotal;

  const BookCard({
    required this.book,
    this.onSecondaryTapDown,
    this.seriesTotal,
    super.key,
  });

  @override
  ConsumerState<BookCard> createState() => _BookCardState();
}

class _BookCardState extends ConsumerState<BookCard> {
  bool _imageLoaded = false;
  bool _imageError = false;

  double get _progressPercent {
    if (widget.book.durationSeconds == null ||
        widget.book.durationSeconds == 0) {
      return 0;
    }
    final percent =
        (widget.book.positionSeconds ?? 0) / widget.book.durationSeconds!;
    return percent.clamp(0.0, 1.0);
  }

  bool get _hasProgress {
    final pos = widget.book.positionSeconds ?? 0;
    final dur = widget.book.durationSeconds ?? 0;
    return pos > 0 && pos < dur * 0.95; // Not completed (within 95%)
  }

  bool get _isCompleted {
    final pos = widget.book.positionSeconds ?? 0;
    final dur = widget.book.durationSeconds ?? 0;
    return dur > 0 && pos >= dur * 0.95;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (detail) {
        if (widget.onSecondaryTapDown != null) {
          widget.onSecondaryTapDown!(detail.globalPosition);
        }
      },
      child: HoverButton(
        onPressed: () {
          ref.read(playbackSyncProvider).resumeBook(widget.book.path);
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
                          color: Colors.grey.withAlpha(51),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Cover Image or Placeholder
                              _buildCoverImage(),

                              // Shimmer Loading Effect
                              if (!_imageLoaded && !_imageError)
                                Shimmer.fromColors(
                                  baseColor: Colors.grey.withAlpha(26),
                                  highlightColor: Colors.grey.withAlpha(77),
                                  child: Container(
                                    color: Colors.grey.withAlpha(51),
                                  ),
                                ),

                              // Progress Indicator Overlay
                              if (_hasProgress && _imageLoaded)
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  child: _CircularProgressIndicator(
                                    progress: _progressPercent,
                                    size: 36,
                                    strokeWidth: 3,
                                  ),
                                ),

                              // Completed Badge
                              if (_isCompleted && _imageLoaded)
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.successPrimaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          FluentIcons.check_mark,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Completed',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // Continue Listening Badge
                              if (_hasProgress && _imageLoaded)
                                Positioned(
                                  top: _isCompleted ? 36 : 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(51),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          FluentIcons.play_resume,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Continue',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // Series Indicator
                              if (widget.book.series != null &&
                                  widget.book.seriesIndex != null &&
                                  _imageLoaded)
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(179),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Book ${widget.book.seriesIndex}${widget.seriesTotal != null ? ' of ${widget.seriesTotal}' : ''}',
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.book.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FluentTheme.of(
                              context,
                            ).typography.bodyStrong,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.book.author ?? 'Unknown Author',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FluentTheme.of(context).typography.caption,
                          ),
                          if (widget.book.series != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                widget.book.series!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FluentTheme.of(context)
                                    .typography
                                    .caption
                                    ?.copyWith(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
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
                            builder: (context) =>
                                MetadataEditor(book: widget.book),
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

  Widget _buildCoverImage() {
    if (widget.book.coverPath == null) {
      return const Center(child: Icon(FluentIcons.music_note, size: 48));
    }

    return Image.file(
      File(widget.book.coverPath!),
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          if (!_imageLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _imageLoaded = true);
              }
            });
          }
          return child;
        }
        return const SizedBox.shrink();
      },
      errorBuilder: (context, error, stackTrace) {
        if (!_imageError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _imageError = true);
            }
          });
        }
        return const Center(child: Icon(FluentIcons.music_note, size: 48));
      },
    );
  }
}

class _CircularProgressIndicator extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;

  const _CircularProgressIndicator({
    required this.progress,
    required this.size,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withAlpha(179),
      ),
      child: Padding(
        padding: EdgeInsets.all(strokeWidth / 2),
        child: CustomPaint(
          painter: _CircularProgressPainter(
            progress: progress,
            strokeWidth: strokeWidth,
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.grey.withAlpha(77)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
