import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/core/services/playback_sync_service.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:canto_sync/features/player/ui/player_screen.dart';

class MiniPlayer extends ConsumerStatefulWidget {
  final VoidCallback? onTap;
  const MiniPlayer({super.key, this.onTap});

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

    final sliderMax = duration.inMilliseconds.toDouble();
    final sliderValue = _isDragging
        ? _dragValue
        : position.inMilliseconds.toDouble().clamp(0.0, sliderMax);

    final chapters = ref.watch(playerChaptersProvider).value ?? [];
    final currentIndex = mediaService.currentIndex;
    String? chapterTitle;

    if (chapters.isNotEmpty && currentIndex < chapters.length) {
      chapterTitle = chapters[currentIndex].title;
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: FluentTheme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: FluentTheme.of(context).resources.dividerStrokeColorDefault,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
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
                    await mediaService.seek(Duration(milliseconds: val.toInt()));
                    await Future.delayed(const Duration(milliseconds: 200));
                    if (mounted) {
                      setState(() => _isDragging = false);
                    }
                  },
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: currentBook.coverPath != null && currentBook.coverPath!.isNotEmpty
                            ? Image.file(File(currentBook.coverPath!), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(FluentIcons.music_note, size: 24))
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
                            currentBook.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                                color: FluentTheme.of(context).typography.caption?.color,
                              ),
                            ),
                          Text(
                            '${_formatDuration(position)} / ${_formatDuration(duration)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: FluentTheme.of(context).typography.caption?.color,
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
                        mediaService.seek(newPos.isNegative ? Duration.zero : newPos);
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
                        mediaService.seek(newPos > duration ? duration : newPos);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}:${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
    return '${d.inMinutes}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }
}

class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const _MarqueeText({required this.text, this.style});

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
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfNeedsScroll();
    });
  }

  void _checkIfNeedsScroll() {
    if (!mounted) return;
    
    final renderBox = context.findRenderObject() as material.RenderBox?;
    if (renderBox != null) {
      final width = renderBox.size.width;
      
      final textSpan = material.TextSpan(text: widget.text, style: widget.style);
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
