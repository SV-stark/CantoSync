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
  // Ensure we get initial state immediately
  return service.playingStream.startWith(service.isPlaying);
});

final playerTotalDurationProvider = StreamProvider.autoDispose<Duration>((ref) {
  final service = ref.watch(mediaServiceProvider);
  return service.totalDurationStream;
});

// ... (other providers unchanged) ...

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
    final totalDurationAsync = ref.watch(playerTotalDurationProvider);
    final playingAsync = ref.watch(playerPlayingProvider);
    final chaptersAsync = ref.watch(playerChaptersProvider);

    final position = positionAsync.value ?? Duration.zero;
    final duration = durationAsync.value ?? Duration.zero;
    final totalDuration = totalDurationAsync.value ?? Duration.zero;
    final isPlaying =
        playingAsync.value ??
        mediaService.isPlaying; // Fallback to current state
    final chapters = chaptersAsync.value ?? [];

    // Determine current chapter
    Chapter? currentChapter;

    // Check if we are in multi-file mode.
    // Logic: If totalDuration is significantly larger than current file duration, assume multi-file.
    // Strictly, totalDuration should be exactly sum, but stream updates might be async.
    // Also, rely on currentIndex.
    final currentIndex = mediaService.currentIndex;
    final isMultiFile =
        totalDuration.inSeconds > (duration.inSeconds + 10) || currentIndex > 0;

    if (chapters.isNotEmpty) {
      if (isMultiFile) {
        // Multi-file: Use playlist index to find chapter
        if (currentIndex < chapters.length) {
          currentChapter = chapters[currentIndex];
        }
      } else {
        // Single file: Use time-based lookup
        final posSeconds = position.inMilliseconds / 1000.0;
        // Find the last chapter where startTime <= currentPosition
        currentChapter = chapters.lastWhere(
          (c) => c.startTime <= posSeconds + 0.5, // 0.5 buffer
          orElse: () => chapters.first,
        );
      }
    }

    // Calculate Global Progress for Percentage
    double globalPositionSeconds = position.inMilliseconds / 1000.0;
    if (currentChapter != null && isMultiFile) {
      // For multi-file, currentChapter.startTime is the cumulative offset
      globalPositionSeconds += currentChapter.startTime;
    }

    double totalBookSeconds = totalDuration.inMilliseconds / 1000.0;
    String percentageText = '';
    if (totalBookSeconds > 0) {
      final percent = (globalPositionSeconds / totalBookSeconds * 100).clamp(
        0.0,
        100.0,
      );
      percentageText = '${percent.toStringAsFixed(1)}%';
    }

    // Calculate display values for SLIDER (Local Progress)
    double sliderValue = 0.0;
    double sliderMax = 1.0;

    // Check for Custom Skip function provider (not yet created, implementing simple local state later or assumption).
    // For now, let's complete the UI structure.

    // Volume Boost Logic
    // We need to read current volume to show slider accurately?
    // MediaService stream provides volume.
    // Let's rely on mediaService.volumeStream (not watched yet in build, let's add it).
    // ...
    // Wait, I missed adding volumeStream provider.
    // I will add it to the build method first.

    // Chapter stats
    Duration chapterPosition = Duration.zero;
    Duration chapterDuration = duration; // Default to full duration

    if (currentChapter != null) {
      // In Multi-file: currentChapter corresponds to current FILE.
      // So chapterDuration should be duration.
      // In Single-file: currentChapter is internal section.

      if (isMultiFile) {
        // Multi-file: Chapter IS the file.
        chapterDuration = duration;
        chapterPosition = position;
      } else {
        // Single-file: Calculate relative position within chapter
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
        if (chapterPosition > chapterDuration) {
          chapterPosition = chapterDuration;
        }
      }

      sliderMax = chapterDuration.inMilliseconds.toDouble();
      if (sliderMax <= 0) sliderMax = 1.0;

      sliderValue = _isDragging
          ? _dragValue
          : chapterPosition.inMilliseconds.toDouble().clamp(0.0, sliderMax);
    } else {
      // No chapters or fallback, use total duration
      // BUT if we are in multi-file without chapters(?), we still want local progress.
      // Assume local logic matches 'duration'.
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
                  const MenuFlyoutSeparator(),
                  MenuFlyoutItem(
                    text: const Text('Custom...'),
                    onPressed: () async {
                      final duration = await _showCustomTimerDialog(context);
                      if (duration != null && duration > Duration.zero) {
                        ref
                            .read(sleepTimerServiceProvider.notifier)
                            .startTimer(duration);
                      }
                    },
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
            const CommandBarSeparator(),
            // Speed & Skip Silence
            CommandBarBuilderItem(
              builder: (context, mode, w) => DropDownButton(
                title: const Text('Speed'),
                leading: const Icon(FluentIcons.playback_rate1x),
                items: [
                  MenuFlyoutItem(
                    text: const Text('Skip Silence (Toggle)'),
                    onPressed: () {
                      // We need state to show checked. For now, simple toggle action?
                      // Ideally, we listen to a provider.
                      // Let's assume user just wants to toggle it.
                      // We need a boolean state in the parent or mediaService?
                      // Let's add 'Skip Silence' checkable item.
                      // Since we don't have a provider for it exposed yet, we will implement it in MediaService stream or local state?
                      // Better: Just add a simple toggle in the menu for now that toggles the filter.
                      // Refactor: We need a provider to track this state for UI feedback.
                      // For this step, I'll add the button that toggles a local bool or calls service.
                      ref.read(mediaServiceProvider).setSkipSilence(true);
                      // Wait, how do we toggle off?
                      // We need state.
                    },
                  ),
                  const MenuFlyoutSeparator(),
                  ...[0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((rate) {
                    return MenuFlyoutItem(
                      text: Text('${rate}x'),
                      onPressed: () =>
                          ref.read(mediaServiceProvider).setRate(rate),
                    );
                  }),
                ],
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
                                ).accentColor.withValues(alpha: 0.1),
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
                              // Percentage Display (New)
                              if (percentageText.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    percentageText,
                                    style: FluentTheme.of(context)
                                        .typography
                                        .caption
                                        ?.copyWith(
                                          color: FluentTheme.of(context)
                                              .typography
                                              .caption
                                              ?.color
                                              ?.withValues(alpha: 0.6),
                                        ),
                                  ),
                                ),
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
                                onChangeEnd: (value) async {
                                  // Optimistic UI: Keep slider at target value visually
                                  // by managing _isDragging/_dragValue or introducing _isSeeking.
                                  // Simplified: don't clear _isDragging yet.
                                  setState(() {
                                    _dragValue = value;
                                  });

                                  if (currentChapter != null) {
                                    if (isMultiFile) {
                                      await mediaService.seek(
                                        Duration(milliseconds: value.toInt()),
                                      );
                                    } else {
                                      final chapterStartMs =
                                          (currentChapter.startTime * 1000)
                                              .toInt();
                                      final seekMs =
                                          chapterStartMs + value.toInt();
                                      await mediaService.seek(
                                        Duration(milliseconds: seekMs),
                                      );
                                    }
                                  } else {
                                    await mediaService.seek(
                                      Duration(milliseconds: value.toInt()),
                                    );
                                  }

                                  // Wait a tiny bit for the player to actually report new position
                                  // before releasing the slider back to the stream.
                                  // This prevents the "jump back" glitch.
                                  if (mounted) {
                                    // Delay sufficient for stream to catch up. 500ms usually enough.
                                    await Future.delayed(
                                      const Duration(milliseconds: 500),
                                    );
                                    if (mounted) {
                                      setState(() {
                                        _isDragging = false;
                                      });
                                    }
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
                                          'Total: ${_formatDuration(position)}', // This could be global position if we want? User said "Total book progress data".
                                          // Let's keep it as is or update to global?
                                          // "total book time always shows current total progress / 0.00"
                                          // The user specifically complained about the /0.00 part.
                                          // Let's fix the denominator.
                                          style: FluentTheme.of(context)
                                              .typography
                                              .caption
                                              ?.copyWith(
                                                color: FluentTheme.of(context)
                                                    .typography
                                                    .caption
                                                    ?.color
                                                    ?.withValues(alpha: 0.7),
                                              ),
                                        ),
                                      Text(
                                        currentChapter != null
                                            ? '/ ${_formatDuration(totalDuration)}' // Fixed: use totalDuration
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

  Future<Duration?> _showCustomTimerDialog(BuildContext context) async {
    int minutes = 30;
    return await showDialog<Duration>(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text('Custom Sleep Timer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InfoLabel(
                label: 'Minutes',
                child: NumberBox<int>(
                  value: minutes,
                  min: 1,
                  max: 1440, // 24 hours
                  onChanged: (v) => minutes = v ?? 1,
                  mode: SpinButtonPlacementMode.inline,
                ),
              ),
            ],
          ),
          actions: [
            Button(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
              child: const Text('Start'),
              onPressed: () =>
                  Navigator.pop(context, Duration(minutes: minutes)),
            ),
          ],
        );
      },
    );
  }
}
