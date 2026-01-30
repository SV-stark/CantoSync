import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:canto_sync/core/services/playback_sync_service.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/player/ui/widgets/ambient_background.dart';
import 'package:canto_sync/features/player/ui/widgets/glass_player_card.dart';
import 'package:canto_sync/core/services/sleep_timer_service.dart';

// Stream Providers
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
  return service.playingStream.startWith(service.isPlaying);
});

final playerTotalDurationProvider = StreamProvider.autoDispose<Duration>((ref) {
  final service = ref.watch(mediaServiceProvider);
  return service.totalDurationStream;
});

final playlistProvider = StreamProvider.autoDispose<Playlist>((ref) {
  final service = ref.watch(mediaServiceProvider);
  return service.playlistStream;
});

final playerChaptersProvider = FutureProvider.autoDispose<List<Chapter>>((
  ref,
) async {
  final service = ref.watch(mediaServiceProvider);
  // Re-fetch when playlist updates
  ref.watch(playlistProvider);
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
    final remainingTimer = ref.watch(sleepTimerServiceProvider);

    final position = ref.watch(playerPositionProvider).value ?? Duration.zero;
    final duration = ref.watch(playerDurationProvider).value ?? Duration.zero;
    final totalDuration =
        ref.watch(playerTotalDurationProvider).value ?? Duration.zero;
    final isPlaying =
        ref.watch(playerPlayingProvider).value ?? mediaService.isPlaying;

    final chapters = ref.watch(playerChaptersProvider).value ?? [];

    // Determine current chapter
    final currentIndex = mediaService.currentIndex;
    final isMultiFile =
        totalDuration.inSeconds > (duration.inSeconds + 10) || currentIndex > 0;

    Chapter? currentChapter;
    if (chapters.isNotEmpty) {
      if (isMultiFile) {
        if (currentIndex < chapters.length) {
          currentChapter = chapters[currentIndex];
        }
      } else {
        final posSeconds = position.inMilliseconds / 1000.0;
        currentChapter = chapters.lastWhere(
          (c) => c.startTime <= posSeconds + 0.5,
          orElse: () => chapters.first,
        );
      }
    }

    // --- Calculations ---

    // 1. Total Progress (Global)
    double globalPositionSeconds = position.inMilliseconds / 1000.0;
    if (currentChapter != null && isMultiFile) {
      globalPositionSeconds += currentChapter.startTime;
    }

    double totalBookSeconds = totalDuration.inMilliseconds / 1000.0;

    // Percentage
    String percentageText = '';
    if (totalBookSeconds > 0) {
      final percent = (globalPositionSeconds / totalBookSeconds * 100).clamp(
        0.0,
        100.0,
      );
      percentageText = '${percent.toStringAsFixed(1)}%';
    }

    // 2. Chapter Progress (Local)
    Duration chapterPosition = Duration.zero;
    Duration chapterDuration = duration;

    if (currentChapter != null) {
      if (isMultiFile) {
        chapterDuration = duration; // File duration
        chapterPosition = position; // File position
      } else {
        // Single File Chapter Logic
        final start = Duration(
          milliseconds: (currentChapter.startTime * 1000).toInt(),
        );
        final end = currentChapter.endTime != null
            ? Duration(milliseconds: (currentChapter.endTime! * 1000).toInt())
            : duration;

        chapterDuration = end - start;
        chapterPosition = position - start;

        if (chapterPosition.isNegative) {
          chapterPosition = Duration.zero;
        }
        if (chapterPosition > chapterDuration) {
          chapterPosition = chapterDuration;
        }
      }
    } else {
      chapterDuration = duration;
      chapterPosition = position;
    }

    // Slider logic
    double sliderMax = chapterDuration.inMilliseconds.toDouble();
    if (sliderMax <= 0) sliderMax = 1.0;
    double sliderValue = _isDragging
        ? _dragValue
        : chapterPosition.inMilliseconds.toDouble().clamp(0.0, sliderMax);

    // Book Info
    final currentPath = ref.watch(currentBookPathProvider);
    final books = ref.watch(libraryBooksProvider).value ?? [];
    final currentBook = currentPath != null
        ? books.where((b) => b.path == currentPath).firstOrNull
        : null;

    // --- UI Structure ---
    return Stack(
      children: [
        // 1. Dynamic Background
        AmbientBackground(coverPath: currentBook?.coverPath),

        // 2. Content Layer
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;

              if (isWide) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Left: Cover Art
                        Hero(
                          tag: 'player_cover',
                          child: _buildCoverArt(currentBook, size: 450),
                        ),
                        const SizedBox(width: 60),

                        // Right: Glass Card Controls
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 550),
                            child: GlassPlayerCard(
                              child: Padding(
                                padding: const EdgeInsets.all(30),
                                child: _buildPlayerControls(
                                  context: context,
                                  currentBook: currentBook,
                                  currentChapter: currentChapter,
                                  chapterPosition: chapterPosition,
                                  chapterDuration: chapterDuration,
                                  sliderValue: sliderValue,
                                  sliderMax: sliderMax,
                                  isPlaying: isPlaying,
                                  percentageText: percentageText,
                                  globalPositionSeconds: globalPositionSeconds,
                                  totalDuration: totalDuration,
                                  mediaService: mediaService,
                                  remainingTimer: remainingTimer,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Narrow / Vertical Layout
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildCoverArt(currentBook, size: 300),
                      const SizedBox(height: 30),
                      GlassPlayerCard(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: _buildPlayerControls(
                            context: context,
                            currentBook: currentBook,
                            currentChapter: currentChapter,
                            chapterPosition: chapterPosition,
                            chapterDuration: chapterDuration,
                            sliderValue: sliderValue,
                            sliderMax: sliderMax,
                            isPlaying: isPlaying,
                            percentageText: percentageText,
                            globalPositionSeconds: globalPositionSeconds,
                            totalDuration: totalDuration,
                            mediaService: mediaService,
                            remainingTimer: remainingTimer,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),

        // Back Button (Top Left)
        Positioned(
          top: 20,
          left: 20,
          child: IconButton(
            icon: const Icon(FluentIcons.back, size: 24, color: Colors.white),
            onPressed: () {
              // Assuming navigation stack handling; usually handled by parent
              // generic navigation, but here we might want to pop or just let user click library sidebar
            },
            // Actually, existing app uses NavigationPane which handles switching.
            // We don't really need a back button if it's a pane item, unless full screen?
            // Existing had 'CommandBar' in header.
            // We'll leave it clean for now or add a clear 'Library' button if needed?
          ),
        ),
      ],
    );
  }

  Widget _buildCoverArt(Book? book, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: book?.coverPath != null
            ? Image.file(File(book!.coverPath!), fit: BoxFit.cover)
            : const Icon(
                FluentIcons.music_in_collection,
                size: 80,
                color: Colors.grey,
              ),
      ),
    );
  }

  Widget _buildPlayerControls({
    required BuildContext context,
    required Book? currentBook,
    required Chapter? currentChapter,
    required Duration chapterPosition,
    required Duration chapterDuration,
    required double sliderValue,
    required double sliderMax,
    required bool isPlaying,
    required String percentageText,
    required double globalPositionSeconds,
    required Duration totalDuration,
    required MediaService mediaService,
    required Duration? remainingTimer,
  }) {
    // Standard Fluent Accent Color or Custom Golden if desired.
    final accentColor = FluentTheme.of(context).accentColor;
    // Using white with alpha values instead of Material shortcuts
    final white70 = Colors.white.withValues(alpha: 0.7);
    final white24 = Colors.white.withValues(alpha: 0.24);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Actions (Bookmark, Playlist)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(FluentIcons.bookmarks, color: white70),
              onPressed: currentBook == null
                  ? null
                  : () => _showAddBookmarkDialog(
                      context,
                      ref,
                      currentBook,
                      Duration(milliseconds: sliderValue.toInt()),
                    ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(FluentIcons.list, color: white70),
              onPressed: () {
                if (currentBook != null) {
                  ref.watch(playerChaptersProvider).whenData((chapters) {
                    _showChaptersList(context, chapters, currentChapter);
                  });
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Title & Author
        Text(
          currentBook?.title ?? 'No Book Selected',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          currentBook?.author ?? 'Unknown Author',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
          ),
        ),
        if (currentChapter != null) ...[
          const SizedBox(height: 8),
          Text(
            currentChapter.title,
            style: TextStyle(
              color: accentColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        const SizedBox(height: 40),

        // --- Progress Section (Chapter) ---
        // Slider
        Slider(
          value: sliderValue,
          min: 0,
          max: sliderMax,
          style: SliderThemeData(
            thumbColor: WidgetStateProperty.all(accentColor),
            activeColor: WidgetStateProperty.all(accentColor),
            inactiveColor: WidgetStateProperty.all(white24),
          ),
          onChangeStart: (val) {
            setState(() {
              _isDragging = true;
              _dragValue = val;
            });
          },
          onChanged: (val) {
            setState(() => _dragValue = val);
          },
          onChangeEnd: (val) async {
            // Simplify seek logic
            if (currentChapter != null &&
                !isMultiFile(totalDuration, chapterDuration)) {
              final startMs = (currentChapter.startTime * 1000).toInt();
              await mediaService.seek(
                Duration(milliseconds: startMs + val.toInt()),
              );
            } else {
              await mediaService.seek(Duration(milliseconds: val.toInt()));
            }

            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              setState(() => _isDragging = false);
            }
          },
        ),

        const SizedBox(height: 8),

        // Chapter Time Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(chapterPosition),
              style: TextStyle(color: white70, fontSize: 13),
            ),
            Text(
              '-${_formatDuration(chapterDuration - chapterPosition)}', // Remaining
              style: TextStyle(color: white70, fontSize: 13),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // --- Global Progress Indicator (New) ---
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Book Progress',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  Text(
                    _formatDuration(
                      Duration(seconds: globalPositionSeconds.toInt()),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' / ${_formatDuration(totalDuration)} ',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '($percentageText)',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replay 15 (Rewind)
            IconButton(
              icon: const Icon(FluentIcons.rewind, color: Colors.white),
              onPressed: () => mediaService.seek(
                Duration(
                  milliseconds: (globalPositionSeconds * 1000).toInt() - 15000,
                ),
              ),
              style: ButtonStyle(iconSize: WidgetStateProperty.all(20)),
            ),

            const SizedBox(width: 20),

            // Previous
            IconButton(
              icon: const Icon(FluentIcons.previous, color: Colors.white),
              onPressed: () => mediaService.previousChapter(),
              style: ButtonStyle(iconSize: WidgetStateProperty.all(24)),
            ),

            const SizedBox(width: 24),

            // Play/Pause (Big)
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  isPlaying ? FluentIcons.pause : FluentIcons.play,
                  color: Colors.black, // High contrast
                  size: 28,
                ),
                onPressed: () => mediaService.playOrPause(),
              ),
            ),

            const SizedBox(width: 24),

            // Next
            IconButton(
              icon: const Icon(FluentIcons.next, color: Colors.white),
              onPressed: () => mediaService.nextChapter(),
              style: ButtonStyle(iconSize: WidgetStateProperty.all(24)),
            ),

            const SizedBox(width: 20),

            // Forward 30
            GestureDetector(
              onTap: () {
                mediaService.seek(
                  Duration(
                    milliseconds:
                        (globalPositionSeconds * 1000).toInt() + 30000,
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: const [
                  Icon(FluentIcons.fast_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // Footer Section (Speed, Timer, Volume)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _FooterButton(
              icon: FluentIcons.playback_rate1x,
              label: '${mediaService.playRate}x',
              onTap: () {
                double newRate = mediaService.playRate + 0.25;
                if (newRate > 2.0) newRate = 0.5;
                mediaService.setRate(newRate);
              },
            ),
            _FooterButton(
              icon: FluentIcons.timer,
              label: remainingTimer != null
                  ? '${remainingTimer.inMinutes}:${(remainingTimer.inSeconds % 60).toString().padLeft(2, '0')}'
                  : 'Timer',
              onTap: () {
                _showSleepTimerMenu(
                  context,
                  ref,
                  chapterDuration - chapterPosition,
                );
              },
            ),
            // Volume Slider (Mini)
            SizedBox(
              width: 100,
              child: Slider(
                value: mediaService.volume,
                min: 0,
                max: 100,
                onChanged: (v) => mediaService.setVolume(v),
                style: SliderThemeData(thumbRadius: WidgetStateProperty.all(6)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper
  bool isMultiFile(Duration total, Duration current) {
    return total.inSeconds > (current.inSeconds + 10);
  }

  void _showAddBookmarkDialog(
    BuildContext context,
    WidgetRef ref,
    Book book,
    Duration position,
  ) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Add Bookmark'),
        content: Text(
          'Placeholder for adding bookmark at ${_formatDuration(position)}',
        ),
        actions: [
          Button(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
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
      builder: (context) => ContentDialog(
        title: const Text('Chapters'),
        content: SizedBox(
          height: 300,
          width: 300,
          child: ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final c = chapters[index];
              return ListTile(
                title: Text(c.title),
                onPressed: () {
                  // Seek logic
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
      ),
    );
  }

  void _showSleepTimerMenu(
    BuildContext context,
    WidgetRef ref,
    Duration remainingChapter,
  ) {
    final timerService = ref.read(sleepTimerServiceProvider.notifier);
    showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text('Sleep Timer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TimerOption(
                label: 'Off',
                onTap: () => timerService.cancelTimer(),
              ),
              _TimerOption(
                label: '15 Minutes',
                onTap: () =>
                    timerService.startTimer(const Duration(minutes: 15)),
              ),
              _TimerOption(
                label: '30 Minutes',
                onTap: () =>
                    timerService.startTimer(const Duration(minutes: 30)),
              ),
              _TimerOption(
                label: '60 Minutes',
                onTap: () =>
                    timerService.startTimer(const Duration(minutes: 60)),
              ),
              _TimerOption(
                label: 'End of Chapter',
                onTap: () => timerService.startTimer(remainingChapter),
              ),
            ],
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

class _TimerOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TimerOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Button(
        onPressed: () {
          onTap();
          Navigator.pop(context);
        },
        child: Align(alignment: Alignment.centerLeft, child: Text(label)),
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FooterButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final white70 = Colors.white.withValues(alpha: 0.7);
    final white54 = Colors.white.withValues(alpha: 0.54);

    return HoverButton(
      onPressed: onTap,
      builder: (context, states) {
        return Column(
          children: [
            Icon(icon, color: white70, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: white54, fontSize: 11)),
          ],
        );
      },
    );
  }
}
