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

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}:${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
    return '${d.inMinutes}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaService = ref.watch(mediaServiceProvider);

    final positionAsync = ref.watch(playerPositionProvider);
    final durationAsync = ref.watch(playerDurationProvider);
    final playingAsync = ref.watch(playerPlayingProvider);

    final position = positionAsync.value ?? Duration.zero;
    final duration = durationAsync.value ?? Duration.zero;
    final isPlaying = playingAsync.value ?? false;

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
                          const SizedBox(height: 40),

                          // Slider / Progress
                          Column(
                            children: [
                              Slider(
                                value: position.inMilliseconds.toDouble().clamp(
                                  0,
                                  duration.inMilliseconds.toDouble(),
                                ),
                                min: 0,
                                max: duration.inMilliseconds.toDouble() > 0
                                    ? duration.inMilliseconds.toDouble()
                                    : 1,
                                onChanged: (value) {
                                  mediaService.seek(
                                    Duration(milliseconds: value.toInt()),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDuration(position)),
                                  Text(_formatDuration(duration)),
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
                                  if (position.inSeconds > 5) {
                                    mediaService.seek(Duration.zero);
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
}
