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
import 'package:canto_sync/features/library/ui/metadata_editor.dart';

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

final currentBookProvider = FutureProvider.autoDispose<Book?>((ref) async {
  final path = ref.watch(currentBookPathProvider);
  if (path == null) return null;
  final books = ref.watch(libraryBooksProvider).value ?? [];
  return books.where((b) => b.path == path).firstOrNull;
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

    // Book Info
    final currentPath = ref.watch(currentBookPathProvider);
    final books = ref.watch(libraryBooksProvider).value ?? [];
    final currentBook = currentPath != null
        ? books.where((b) => b.path == currentPath).firstOrNull
        : null;

    final position = ref.watch(playerPositionProvider).value ?? Duration.zero;
    final duration = ref.watch(playerDurationProvider).value ?? Duration.zero;

    var totalDuration =
        ref.watch(playerTotalDurationProvider).value ?? Duration.zero;

    // Fallback: If player reports 0 duration (common with heavy m4b or initial load),
    // use metadata from library scan.
    if (totalDuration.inSeconds == 0 && currentBook?.durationSeconds != null) {
      final metaSeconds = currentBook!.durationSeconds!;
      if (metaSeconds > 0) {
        totalDuration = Duration(milliseconds: (metaSeconds * 1000).toInt());
      }
    }

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
                                  isMultiPlaylist: isMultiFile,
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
                            isMultiPlaylist: isMultiFile,
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
    required bool isMultiPlaylist,
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
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(FluentIcons.edit, color: white70),
              onPressed: currentBook == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        FluentPageRoute(
                          builder: (context) =>
                              MetadataEditor(book: currentBook),
                        ),
                      );
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
            // Fix: M4B seek must be chapter-relative if it's a single file
            if (currentChapter != null && !isMultiPlaylist) {
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
              onPressed: () {
                final newPos =
                    mediaService.position - const Duration(seconds: 15);
                mediaService.seek(newPos.isNegative ? Duration.zero : newPos);
              },
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
                  mediaService.position + const Duration(seconds: 30),
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
              label: '${mediaService.playRate.toStringAsFixed(2)}x',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => _SpeedControlDialog(
                    initialRate: mediaService.playRate,
                    onRateChanged: (rate) => mediaService.setRate(rate),
                  ),
                );
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
            _FooterButton(
              icon: FluentIcons.equalizer,
              label: 'EQ',
              onTap: () {
                // Show simple EQ menu
                _showEQMenu(context, mediaService);
              },
            ),
            // Volume Slider (Mini)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  FluentIcons.ringer,
                  size: 16,
                  color: Colors
                      .white, // white70 might fail if variable scope issue, using literal or constant
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: Slider(
                    value: mediaService.volume,
                    min: 0,
                    max: 100,
                    onChanged: (v) => mediaService.setVolume(v),
                    style: SliderThemeData(
                      thumbRadius: WidgetStateProperty.all(6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _showEQMenu(BuildContext context, MediaService mediaService) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Equalizer Presets'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _EQOption(
              label: 'Flat (Off)',
              onTap: () => mediaService.setAudioFilter(''),
            ),
            _EQOption(
              label: 'Spoken Word (Optimized)',
              onTap: () => mediaService.setAudioFilter(
                'lavfi=[highpass=f=200,lowpass=f=3000]',
              ),
            ),
            _EQOption(
              label: 'Bass Boost',
              onTap: () =>
                  mediaService.setAudioFilter('lavfi=[bass=g=10:f=100]'),
            ),
            _EQOption(
              label: 'Treble Boost',
              onTap: () =>
                  mediaService.setAudioFilter('lavfi=[treble=g=10:f=5000]'),
            ),
          ],
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

  void _showAddBookmarkDialog(
    BuildContext context,
    WidgetRef ref,
    Book book,
    Duration position,
  ) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Add Bookmark'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add bookmark at ${_formatDuration(position)}'),
            const SizedBox(height: 10),
            TextBox(
              controller: textController,
              placeholder: 'Bookmark Label (Optional)',
            ),
          ],
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Save'),
            onPressed: () async {
              final label = textController.text.trim().isEmpty
                  ? 'Bookmark at ${_formatDuration(position)}'
                  : textController.text.trim();

              book.bookmarks?.add(
                Bookmark(
                  label: label,
                  timestampSeconds: globalPositionSecondsWrapper(ref, position),
                ),
              );
              await book.save();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  double globalPositionSecondsWrapper(WidgetRef ref, Duration pos) {
    return pos.inMilliseconds / 1000.0;
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
                  Navigator.pop(context);
                  ref.read(mediaServiceProvider).jumpToChapter(index);
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
              SizedBox(
                width: double.infinity,
                child: Button(
                  onPressed: () {
                    Navigator.pop(context); // Close menu first
                    showDialog(
                      context: context,
                      builder: (context) {
                        final controller = TextEditingController();
                        return ContentDialog(
                          title: const Text('Set Sleep Timer'),
                          content: TextBox(
                            controller: controller,
                            placeholder: 'Minutes',
                            keyboardType: TextInputType.number,
                          ),
                          actions: [
                            Button(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.pop(context),
                            ),
                            FilledButton(
                              child: const Text('Start'),
                              onPressed: () {
                                final mins =
                                    int.tryParse(controller.text) ?? 30;
                                timerService.startTimer(
                                  Duration(minutes: mins),
                                );
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Custom...'),
                  ),
                ),
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

class _EQOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _EQOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      onPressed: () {
        onTap();
        Navigator.pop(context);
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

class _SpeedControlDialog extends StatefulWidget {
  final double initialRate;
  final ValueChanged<double> onRateChanged;

  const _SpeedControlDialog({
    required this.initialRate,
    required this.onRateChanged,
  });

  @override
  State<_SpeedControlDialog> createState() => _SpeedControlDialogState();
}

class _SpeedControlDialogState extends State<_SpeedControlDialog> {
  late double _rate;

  @override
  void initState() {
    super.initState();
    _rate = widget.initialRate;
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Playback Speed'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_rate.toStringAsFixed(2)}x',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Slider(
            value: _rate,
            min: 0.5,
            max: 3.0,
            onChanged: (v) {
              // Snap to 0.05
              final snapped = (v * 20).round() / 20.0;
              setState(() => _rate = snapped);
              widget.onRateChanged(snapped);
            },
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final preset in [1.0, 1.25, 1.5, 1.75, 2.0, 2.5])
                FilledButton(
                  onPressed: () {
                    setState(() => _rate = preset);
                    widget.onRateChanged(preset);
                  },
                  style: ButtonStyle(
                    backgroundColor: _rate == preset
                        ? WidgetStateProperty.all(
                            FluentTheme.of(context).accentColor,
                          )
                        : null,
                  ),
                  child: Text('${preset}x'),
                ),
            ],
          ),
        ],
      ),
      actions: [
        Button(
          child: const Text('Done'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
