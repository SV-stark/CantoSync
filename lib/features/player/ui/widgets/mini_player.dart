import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart' as material;
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

    final mediaService = ref.watch(mediaServiceProvider);
    final position = ref.watch(playerPositionProvider).value ?? Duration.zero;
    final duration = ref.watch(playerDurationProvider).value ?? Duration.zero;
    final totalDuration =
        ref.watch(playerTotalDurationProvider).value ?? duration;

    final chapters = ref.watch(playerChaptersProvider).value ?? [];
    final currentIndex = mediaService.currentIndex;

    final isMultiFile =
        totalDuration.inSeconds > (duration.inSeconds + 10) || currentIndex > 0;

    Chapter? currentChapter;
    String? chapterTitle;
    if (chapters.isNotEmpty) {
      if (isMultiFile) {
        if (currentIndex < chapters.length) {
          currentChapter = chapters[currentIndex];
          chapterTitle = currentChapter.title;
        }
      } else {
        final posSeconds = position.inMilliseconds / 1000.0;
        currentChapter = chapters.lastWhere(
          (c) => c.startTime <= posSeconds + 1.0,
          orElse: () => chapters.first,
        );
        chapterTitle = currentChapter.title;
      }
    }

    Duration chapterPosition = position;
    Duration chapterDuration = duration;

    if (currentChapter != null && !isMultiFile) {
      final start = Duration(
        milliseconds: (currentChapter.startTime * 1000).toInt(),
      );
      final end = currentChapter.endTime != null
          ? Duration(milliseconds: (currentChapter.endTime! * 1000).toInt())
          : duration;

      chapterDuration = end - start;
      chapterPosition = position - start;

      if (chapterPosition.isNegative) chapterPosition = Duration.zero;
      if (chapterPosition > chapterDuration) chapterPosition = chapterDuration;
    }

    final sliderMax = chapterDuration.inMilliseconds.toDouble();
    final sliderValue = _isDragging
        ? _dragValue
        : chapterPosition.inMilliseconds.toDouble().clamp(0.0, sliderMax);

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
                        Colors.grey.withAlpha(77),
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
                        final startMs = (currentChapter.startTime * 1000)
                            .toInt();
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
                          child:
                              currentBook.coverPath != null &&
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
                              : const Icon(FluentIcons.music_note, size: 24),
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
                        onPressed: () {
                          final newPos = position - const Duration(seconds: 15);
                          mediaService.seek(
                            newPos.isNegative ? Duration.zero : newPos,
                          );
                        },
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
                        onPressed: () {
                          final newPos = position + const Duration(seconds: 15);
                          mediaService.seek(
                            newPos > duration ? duration : newPos,
                          );
                        },
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
  late Animation<Offset> _animation;
  bool _needsScroll = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.5, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfNeedsScroll();
    });
  }

  void _checkIfNeedsScroll() {
    if (!mounted) return;

    final renderBox = context.findRenderObject() as material.RenderBox?;
    if (renderBox != null) {
      final width = renderBox.size.width;

      final textSpan = material.TextSpan(
        text: widget.text,
        style: widget.style,
      );
      final textPainter = material.TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      if (textPainter.width > width) {
        setState(() {
          _needsScroll = true;
        });
        _controller.repeat();
      }
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
                  offset: Offset(_animation.value.dx * 200, 0),
                  child: Text(
                    widget.text,
                    style: widget.style,
                    maxLines: 1,
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
