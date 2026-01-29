import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:canto_sync/core/services/playback_sync_service.dart';
import 'package:canto_sync/core/services/sleep_timer_service.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/core/services/app_settings_service.dart';
import 'package:canto_sync/features/library/ui/metadata_editor.dart';

// Stream Providers for reactive UI
final playerPositionProvider = StreamProvider.autoDispose<Duration>((ref) {
  final service = ref.watch(mediaServiceProvider);
  return service.positionStream;
});

final playerDurationProvider = StreamProvider.autoDispose<Duration>((ref) {
  final service = ref.watch(mediaServiceProvider);
  return service.durationStream;
});

final playerPlayingProvider = StreamProvider.autoDispose<bool>((ref) {
  final service = ref.watch(mediaServiceProvider);
  return service.playingStream;
});

final playerTracksProvider = StreamProvider.autoDispose<Tracks>((ref) {
  final service = ref.watch(mediaServiceProvider);
  return service.tracksStream;
});

final playerPlaylistProvider = StreamProvider.autoDispose<Playlist>((ref) {
  final service = ref.watch(mediaServiceProvider);
  return service.playlistStream;
});

final playerChaptersProvider = FutureProvider.autoDispose<List<Chapter>>((
  ref,
) async {
  final service = ref.watch(mediaServiceProvider);
  // Depend on playlist implementation to refresh when file changes
  ref.watch(playerPlaylistProvider);
  // Also delay slightly to ensure metadata is loaded?
  // media_kit usually populates properties after open.
  await Future.delayed(const Duration(milliseconds: 200));
  return service.getChapters();
});

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}:${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
    return '${d.inMinutes}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final mediaService = ref.watch(mediaServiceProvider);

    final positionAsync = ref.watch(playerPositionProvider);
    final durationAsync = ref.watch(playerDurationProvider);
    final playingAsync = ref.watch(playerPlayingProvider);
    final chaptersAsync = ref.watch(playerChaptersProvider);

    final position = positionAsync.value ?? Duration.zero;
    final duration = durationAsync.value ?? Duration.zero;
    final isPlaying = playingAsync.value ?? false;
    final chapters = chaptersAsync.value ?? [];

    // Determine current chapter
    Chapter? currentChapter;
    if (chapters.isNotEmpty) {
      final posSeconds = position.inMilliseconds / 1000.0;
      // Find the last chapter where startTime <= currentPosition
      currentChapter = chapters.lastWhere(
        (c) => c.startTime <= posSeconds + 0.5, // 0.5 buffer
        orElse: () => chapters.first,
      );
    }

    // Calculate display values
    double sliderValue = 0.0;
    double sliderMax = 1.0;

    // Chapter stats
    Duration chapterPosition = Duration.zero;
    Duration chapterDuration = duration; // Default to full duration

    if (currentChapter != null) {
      // We have chapters
      final start = Duration(
        milliseconds: (currentChapter.startTime * 1000).toInt(),
      );
      final end = currentChapter.endTime != null
          ? Duration(milliseconds: (currentChapter.endTime! * 1000).toInt())
          : duration;

      chapterDuration = end - start;
      // Clamp to ensure we don't show negative
      chapterPosition = (position - start);
      if (chapterPosition.isNegative) chapterPosition = Duration.zero;
      if (chapterPosition > chapterDuration) chapterPosition = chapterDuration;

      sliderMax = chapterDuration.inMilliseconds.toDouble();
      if (sliderMax <= 0) sliderMax = 1.0;

      sliderValue = _isDragging
          ? _dragValue
          : chapterPosition.inMilliseconds.toDouble().clamp(0.0, sliderMax);
    } else {
      // No chapters, use total duration
      sliderMax = duration.inMilliseconds.toDouble();
      if (sliderMax <= 0) sliderMax = 1.0;

      sliderValue = _isDragging
          ? _dragValue
          : position.inMilliseconds.toDouble().clamp(0.0, sliderMax);
    }

    // Get current book info
    final currentPath = ref.watch(currentBookPathProvider);
    final books = ref.watch(libraryBooksProvider).value ?? [];
    final currentBook = currentPath != null
        ? books.where((b) => b.path == currentPath).firstOrNull
        : null;

    final sleepTimer = ref.watch(sleepTimerServiceProvider);

    return ScaffoldPage.withPadding(
      header: PageHeader(
        title: const Text('Now Playing'),
        commandBar: CommandBar(
          primaryItems: [
            // Sleep Timer
            CommandBarBuilderItem(
              builder: (context, mode, w) => DropDownButton(
                title: Text(
                  sleepTimer != null
                      ? 'Timer: ${_formatDuration(sleepTimer)}'
                      : 'Sleep Timer',
                ),
                leading: Icon(
                  FluentIcons.timer,
                  color: sleepTimer != null
                      ? FluentTheme.of(context).accentColor
                      : null,
                ),
                items: [
                  MenuFlyoutItem(
                    text: const Text('Off'),
                    onPressed: () => ref
                        .read(sleepTimerServiceProvider.notifier)
                        .cancelTimer(),
                  ),
                  const MenuFlyoutSeparator(),
                  MenuFlyoutItem(
                    text: const Text('15 Minutes'),
                    onPressed: () => ref
                        .read(sleepTimerServiceProvider.notifier)
                        .startTimer(const Duration(minutes: 15)),
                  ),
                  MenuFlyoutItem(
                    text: const Text('30 Minutes'),
                    onPressed: () => ref
                        .read(sleepTimerServiceProvider.notifier)
                        .startTimer(const Duration(minutes: 30)),
                  ),
                  MenuFlyoutItem(
                    text: const Text('1 Hour'),
                    onPressed: () => ref
                        .read(sleepTimerServiceProvider.notifier)
                        .startTimer(const Duration(hours: 1)),
                  ),
                ],
              ),
              wrappedItem:
                  CommandBarButton(
                        icon: const Icon(FluentIcons.timer),
                        onPressed: () {},
                      )
                      as CommandBarItem,
            ),
            const CommandBarSeparator(),
            // Speed
            CommandBarBuilderItem(
              builder: (context, mode, w) => DropDownButton(
                title: const Text('Speed'),
                leading: const Icon(FluentIcons.playback_rate1x),
                items: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((rate) {
                  return MenuFlyoutItem(
                    text: Text('${rate}x'),
                    onPressed: () =>
                        ref.read(mediaServiceProvider).setRate(rate),
                  );
                }).toList(),
              ),
              wrappedItem:
                  CommandBarButton(
                        icon: const Icon(FluentIcons.playback_rate1x),
                        onPressed: () {},
                      )
                      as CommandBarItem,
            ),
            const CommandBarSeparator(),
            // Chapters Button
            if (chapters.isNotEmpty) ...[
              CommandBarButton(
                icon: const Icon(FluentIcons.list),
                label: const Text('Chapters'),
                onPressed: () =>
                    _showChaptersList(context, chapters, currentChapter),
              ),
              const CommandBarSeparator(),
            ],
            // Bookmark
            CommandBarButton(
              icon: const Icon(FluentIcons.bookmarks),
              label: const Text('Add Bookmark'),
              onPressed: currentBook == null
                  ? null
                  : () => _showAddBookmarkDialog(
                      context,
                      ref,
                      currentBook,
                      position,
                    ),
            ),
            const CommandBarSeparator(),
            // Edit Info
            CommandBarButton(
              icon: const Icon(FluentIcons.edit),
              label: const Text('Edit Info'),
              onPressed: currentBook == null
                  ? null
                  : () => showDialog(
                      context: context,
                      builder: (context) => MetadataEditor(book: currentBook),
                    ),
            ),
            const CommandBarSeparator(),
            // EQ
            CommandBarBuilderItem(
              builder: (context, mode, w) => DropDownButton(
                title: Text(
                  'EQ: ${ref.watch(appSettingsProvider).audioPreset.label}',
                ),
                leading: const Icon(FluentIcons.equalizer),
                items: AudioPreset.values.map((preset) {
                  return MenuFlyoutItem(
                    text: Text(preset.label),
                    onPressed: () => ref
                        .read(appSettingsProvider.notifier)
                        .setAudioPreset(preset),
                  );
                }).toList(),
              ),
              wrappedItem:
                  CommandBarButton(
                        icon: const Icon(FluentIcons.equalizer),
                        onPressed: () {},
                      )
                      as CommandBarItem,
            ),
          ],
        ),
      ),
      content: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Cover Art
                  Container(
                    height: isWide ? 400 : 300,
                    width: isWide ? 400 : 300,
                    decoration: BoxDecoration(
                      color: FluentTheme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: currentBook?.coverPath != null
                          ? Image.file(
                              File(currentBook!.coverPath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    FluentIcons.music_in_collection,
                                    size: 100,
                                  ),
                            )
                          : const Icon(
                              FluentIcons.music_in_collection,
                              size: 100,
                            ),
                    ),
                  ),
                  if (isWide)
                    const SizedBox(width: 60)
                  else
                    const SizedBox(height: 40),

                  // Info & Controls
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Book Title & Author
                          Text(
                            currentBook?.title ?? 'No Book Selected',
                            style: FluentTheme.of(context).typography.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentBook?.author ?? 'Unknown Author',
                            style: FluentTheme.of(context).typography.subtitle
                                ?.copyWith(
                                  color: FluentTheme.of(context)
                                      .typography
                                      .subtitle
                                      ?.color
                                      ?.withValues(alpha: 0.8),
                                ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Series
                          if (currentBook?.series != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              currentBook!.series!,
                              style: FluentTheme.of(context)
                                  .typography
                                  .bodyStrong
                                  ?.copyWith(
                                    color: FluentTheme.of(context).accentColor,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],

                          // Current Chapter Title
                          if (currentChapter != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: FluentTheme.of(
                                  context,
                                ).accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                currentChapter.title,
                                style: FluentTheme.of(
                                  context,
                                ).typography.bodyStrong,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],

                          const SizedBox(height: 40),

                          // Slider / Progress
                          Column(
                            children: [
                              Slider(
                                value: sliderValue,
                                min: 0,
                                max: sliderMax,
                                onChangeStart: (val) {
                                  setState(() {
                                    _isDragging = true;
                                    _dragValue = val;
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _dragValue = value;
                                  });
                                },
                                onChangeEnd: (value) {
                                  setState(() {
                                    _isDragging = false;
                                  });
                                  if (currentChapter != null) {
                                    // value is relative to chapter start
                                    final chapterStartMs =
                                        (currentChapter.startTime * 1000)
                                            .toInt();
                                    final seekMs =
                                        chapterStartMs + value.toInt();
                                    mediaService.seek(
                                      Duration(milliseconds: seekMs),
                                    );
                                  } else {
                                    mediaService.seek(
                                      Duration(milliseconds: value.toInt()),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left side: Chapter Progress
                                  Text(
                                    currentChapter != null
                                        ? '${_formatDuration(chapterPosition)} / ${_formatDuration(chapterDuration)}'
                                        : _formatDuration(position),
                                  ),

                                  // Right side: Total Progress
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (currentChapter != null)
                                        Text(
                                          'Total: ${_formatDuration(position)}',
                                          style: FluentTheme.of(context)
                                              .typography
                                              .caption
                                              ?.copyWith(
                                                color: FluentTheme.of(context)
                                                    .typography
                                                    .caption
                                                    ?.color
                                                    ?.withOpacity(0.7),
                                              ),
                                        ),
                                      Text(
                                        currentChapter != null
                                            ? '/ ${_formatDuration(duration)}'
                                            : _formatDuration(duration),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  FluentIcons.previous,
                                  size: 28,
                                ),
                                onPressed: () {
                                  // Logic: If >5s, seek start. If <5s, prev chapter/track
                                  if (chapterPosition.inSeconds > 5) {
                                    // Seek to start of current current chapter
                                    if (currentChapter != null) {
                                      mediaService.seek(
                                        Duration(
                                          milliseconds:
                                              (currentChapter.startTime * 1000)
                                                  .toInt(),
                                        ),
                                      );
                                    } else {
                                      mediaService.seek(Duration.zero);
                                    }
                                  } else {
                                    mediaService.previousChapter();
                                  }
                                },
                              ),
                              const SizedBox(width: 30),
                              IconButton(
                                icon: const Icon(
                                  FluentIcons.rewind,
                                  size: 24,
                                ), // -15s
                                onPressed: () {
                                  mediaService.seek(
                                    position - const Duration(seconds: 15),
                                  );
                                },
                              ),
                              const SizedBox(width: 30),
                              IconButton(
                                icon: Icon(
                                  isPlaying
                                      ? FluentIcons.pause
                                      : FluentIcons.play,
                                  size: 48,
                                  color: FluentTheme.of(context).accentColor,
                                ),
                                onPressed: () {
                                  mediaService.playOrPause();
                                },
                                style: ButtonStyle(
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.all(16),
                                  ),
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith((states) {
                                        if (states.isHovered) {
                                          return FluentTheme.of(
                                            context,
                                          ).cardColor;
                                        }
                                        return Colors.transparent;
                                      }),
                                ),
                              ),
                              const SizedBox(width: 30),
                              IconButton(
                                icon: const Icon(
                                  FluentIcons.fast_forward,
                                  size: 24,
                                ), // +15s
                                onPressed: () {
                                  mediaService.seek(
                                    position + const Duration(seconds: 15),
                                  );
                                },
                              ),
                              const SizedBox(width: 30),
                              IconButton(
                                icon: const Icon(FluentIcons.next, size: 28),
                                onPressed: () {
                                  mediaService.nextChapter();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddBookmarkDialog(
    BuildContext context,
    WidgetRef ref,
    Book book,
    Duration position,
  ) {
    String label = 'Bookmark ${_formatDuration(position)}';
    final controller = TextEditingController(text: label);

    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Add Bookmark'),
        content: TextBox(
          controller: controller,
          placeholder: 'Bookmark Label',
          autofocus: true,
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Save'),
            onPressed: () {
              final bookmark = Bookmark(
                label: controller.text,
                timestampSeconds: position.inMilliseconds / 1000.0,
              );
              ref.read(libraryServiceProvider).addBookmark(book.path, bookmark);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showChaptersList(
    BuildContext context,
    List<Chapter> chapters,
    Chapter? currentChapter,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text('Chapters'),
          content: Container(
            constraints: const BoxConstraints(maxHeight: 400),
            width: 350,
            child: ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                final isCurrent = chapter == currentChapter;

                return ListTile(
                  leading: isCurrent
                      ? Icon(
                          FluentIcons.play,
                          size: 12,
                          color: FluentTheme.of(context).accentColor,
                        )
                      : const SizedBox(width: 12),
                  title: Text(chapter.title),
                  subtitle: Text(
                    _formatDuration(
                      Duration(seconds: chapter.startTime.toInt()),
                    ),
                  ),
                  onPressed: () {
                    ref
                        .read(mediaServiceProvider)
                        .seek(
                          Duration(
                            milliseconds: (chapter.startTime * 1000).toInt(),
                          ),
                        );
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            Button(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
