import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/core/services/playback_sync_service.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:canto_sync/features/player/ui/player_screen.dart';
import 'package:canto_sync/core/utils/format_duration.dart';

class MiniPlayer extends ConsumerStatefulWidget {
  const MiniPlayer({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  ConsumerState<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends ConsumerState<MiniPlayer> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final currentPath = ref.watch(currentBookPathProvider);
    if (currentPath == null) return const SizedBox.shrink();

    final books = ref.watch(libraryBooksProvider).value ?? [];
    final currentBook = books.where((b) => b.path == currentPath).firstOrNull;
    if (currentBook == null) return const SizedBox.shrink();

    final progress = ref.watch(playerPlaybackProgressProvider);
    final mediaService = ref.watch(mediaServiceProvider);

    final currentChapter = progress.currentChapter;
    final chapterTitle = currentChapter?.title;
    final isMultiFile = progress.isMultiFile;

    final duration = progress.duration;
    final position = progress.position;
    final chapterDuration = progress.chapterDuration;
    final chapterPosition = progress.chapterPosition;

    final sliderMax = (chapterDuration.inMilliseconds > 0)
        ? chapterDuration.inMilliseconds.toDouble()
        : (duration.inMilliseconds > 0
            ? duration.inMilliseconds.toDouble()
            : 1.0);
    final sliderValue = (_isDragging
            ? _dragValue
            : chapterPosition.inMilliseconds.toDouble())
        .clamp(0.0, sliderMax);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 80,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: FluentTheme.of(
            context,
          ).micaBackgroundColor.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: FluentTheme.of(context).resources.dividerStrokeColorDefault,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            children: [
              if (sliderMax > 0)
                SizedBox(
                  height: 3,
                  child: Slider(
                    value: sliderValue,
                    min: 0,
                    max: sliderMax,
                    style: SliderThemeData(
                      thumbColor: WidgetStateProperty.all(
                        FluentTheme.of(context).accentColor,
                      ),
                      activeColor: WidgetStateProperty.all(
                        FluentTheme.of(context).accentColor,
                      ),
                      inactiveColor: WidgetStateProperty.all(
                        Colors.grey.withValues(alpha: 0.3),
                      ),
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
                      if (currentChapter != null && !isMultiFile) {
                        final startMs =
                            (currentChapter.startTime * 1000).toInt();
                        await mediaService.seek(
                          Duration(milliseconds: startMs + val.toInt()),
                        );
                      } else {
                        await mediaService.seek(
                          Duration(milliseconds: val.toInt()),
                        );
                      }
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (mounted) {
                        setState(() => _isDragging = false);
                      }
                    },
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: currentBook.coverPath != null &&
                                  currentBook.coverPath!.isNotEmpty
                              ? Image.file(
                                  File(currentBook.coverPath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    FluentIcons.music_note,
                                    size: 24,
                                  ),
                                )
                              : const Icon(
                                  FluentIcons.music_note,
                                  size: 24,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentBook.title ?? 'Unknown',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (chapterTitle != null)
                              SizedBox(
                                height: 16,
                                child: _MarqueeText(
                                  text: chapterTitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: FluentTheme.of(context).accentColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            else if (currentBook.author != null)
                              Text(
                                currentBook.author!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: FluentTheme.of(
                                    context,
                                  ).typography.caption?.color,
                                ),
                              ),
                            Text(
                              '${_formatDuration(position)} / ${_formatDuration(duration)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: FluentTheme.of(
                                  context,
                                ).typography.caption?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(FluentIcons.rewind, size: 18),
                        onPressed: () => _seekRelative(
                          mediaService,
                          position,
                          duration,
                          const Duration(seconds: -15),
                        ),
                      ),
                      StreamBuilder<bool>(
                        stream: mediaService.playingStream,
                        initialData: mediaService.isPlaying,
                        builder: (context, snapshot) {
                          final isPlaying = snapshot.data ?? false;
                          return IconButton(
                            icon: Icon(
                              isPlaying ? FluentIcons.pause : FluentIcons.play,
                              size: 22,
                            ),
                            onPressed: () => mediaService.playOrPause(),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(FluentIcons.fast_forward, size: 18),
                        onPressed: () => _seekRelative(
                          mediaService,
                          position,
                          duration,
                          const Duration(seconds: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A zero duration means the track has not been probed yet. Seeking to the
  /// end of the track in that state seeks to 0, which looked like the playhead
  /// jumping to the start; fall back to a no-op instead.
  Future<void> _seekRelative(
    MediaService mediaService,
    Duration position,
    Duration duration,
    Duration offset,
  ) async {
    if (duration <= Duration.zero) return;
    final target = position + offset;
    if (target < Duration.zero) {
      await mediaService.seek(Duration.zero);
    } else if (target > duration) {
      await mediaService.seek(duration);
    } else {
      await mediaService.seek(target);
    }
  }

  String _formatDuration(Duration d) => formatDuration(d);
}

class _MarqueeText extends StatefulWidget {
  const _MarqueeText({required this.text, this.style});
  final String text;
  final TextStyle? style;

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _needsScroll = false;
  double _overflowPx = 0;

  /// Gap left on the right while the text scrolls, so the end of the string is
  /// fully visible before it wraps back around.
  static const double _trailingGap = 24;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _animation = _controller.drive(
      Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: Curves.linear)),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfNeedsScroll();
    });
  }

  void _checkIfNeedsScroll() {
    if (!mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final width = renderBox.size.width;
    if (width <= 0) return;

    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    // Scroll distance is the real overflow width plus the trailing gap. The
    // previous implementation used a fixed 100px sweep, which clipped long
    // chapter titles and left a dead gap for short ones.
    final overflow = textPainter.width - width + _trailingGap;
    final needsScroll = textPainter.width > width;

    if (needsScroll != _needsScroll || overflow != _overflowPx) {
      setState(() {
        _needsScroll = needsScroll;
        _overflowPx = overflow;
      });
    }

    if (needsScroll) {
      // Scale the duration with the distance so the speed is constant rather
      // than the sweep being time-based.
      _controller.duration = Duration(
        milliseconds: (overflow / 30 * 1000).clamp(2000, 30000).toInt(),
      );
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void didUpdateWidget(_MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _controller.stop();
      _controller.value = 0;
      setState(() {
        _needsScroll = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkIfNeedsScroll();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: _needsScroll
          ? AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-_animation.value * _overflowPx, 0),
                  child: Text(
                    widget.text,
                    style: widget.style,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                  ),
                );
              },
            )
          : Text(
              widget.text,
              style: widget.style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
    );
  }
}
