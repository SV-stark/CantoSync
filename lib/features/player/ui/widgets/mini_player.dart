import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/core/services/playback_sync_service.dart';

import 'package:canto_sync/features/library/data/library_service.dart';

class MiniPlayer extends ConsumerWidget {
  final VoidCallback? onTap;
  const MiniPlayer({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get current book path
    final currentPath = ref.watch(currentBookPathProvider);

    // If no book selected, hide
    if (currentPath == null) return const SizedBox.shrink();

    // 2. Get Book object
    final books = ref.watch(libraryBooksProvider).value ?? [];
    final currentBook = books.where((b) => b.path == currentPath).firstOrNull;

    if (currentBook == null) return const SizedBox.shrink();

    // 3. Media State
    final mediaService = ref.watch(mediaServiceProvider);

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: FluentTheme.of(context).resources.dividerStrokeColorDefault,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AspectRatio(
              aspectRatio: 1,
              child: currentBook.coverPath != null
                  ? Image.file(File(currentBook.coverPath!), fit: BoxFit.cover)
                  : const Icon(FluentIcons.music_note, size: 24),
            ),
          ),
          const SizedBox(width: 12),

          // Info (Clickable to open player)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onTap,
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
                  if (currentBook.author != null)
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
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Controls
          StreamBuilder<bool>(
            stream: mediaService.playingStream,
            initialData: mediaService.isPlaying,
            builder: (context, snapshot) {
              final isPlaying = snapshot.data ?? false;
              return IconButton(
                icon: Icon(
                  isPlaying ? FluentIcons.pause : FluentIcons.play,
                  size: 20,
                ),
                onPressed: () => mediaService.playOrPause(),
              );
            },
          ),
        ],
      ),
    );
  }
}
