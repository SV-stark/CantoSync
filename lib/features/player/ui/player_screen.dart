import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/core/services/playback_sync_service.dart';

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

  Future<void> _pickFile(WidgetRef ref) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      final path = result.files.single.path!;
      ref.read(playbackSyncProvider).resumeBook(path);
      // ref.read(mediaServiceProvider).open(path);
      // ref.read(mediaServiceProvider).play();
    }
  }

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

    return ScaffoldPage.withPadding(
      header: const PageHeader(title: Text('Now Playing')),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cover Art Placeholder
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              color: FluentTheme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(FluentIcons.music_in_collection, size: 80),
          ),
          const SizedBox(height: 40),

          // Slider / Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Slider(
                  value: position.inMilliseconds.toDouble(),
                  min: 0,
                  max: duration.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    mediaService.seek(Duration(milliseconds: value.toInt()));
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(position)),
                    Text(_formatDuration(duration)),
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
              IconButton(
                icon: const Icon(FluentIcons.previous, size: 24),
                onPressed: () {
                  mediaService.seek(position - const Duration(seconds: 15));
                },
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: Icon(
                  isPlaying ? FluentIcons.pause : FluentIcons.play,
                  size: 40,
                ),
                onPressed: () {
                  mediaService.playOrPause();
                },
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(const CircleBorder()),
                  padding: WidgetStateProperty.all(const EdgeInsets.all(12)),
                  backgroundColor: WidgetStateProperty.all(
                    FluentTheme.of(context).accentColor,
                  ),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(FluentIcons.next, size: 24),
                onPressed: () {
                  mediaService.seek(position + const Duration(seconds: 15));
                },
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Chapters List
          Consumer(
            builder: (context, ref, child) {
              final chaptersAsync = ref.watch(playerChaptersProvider);
              return chaptersAsync.when(
                data: (chapters) {
                  if (chapters.isEmpty) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Expander(
                      header: const Text('Chapters'),
                      content: SizedBox(
                        height: 200, // Limit height
                        child: ListView.builder(
                          itemCount: chapters.length,
                          itemBuilder: (context, index) {
                            final chapter = chapters[index];
                            return ListTile(
                              title: Text(chapter.title),
                              trailing: Text(
                                _formatDuration(
                                  Duration(seconds: chapter.startTime.toInt()),
                                ),
                              ),
                              onPressed: () {
                                mediaService.jumpToChapter(index);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(),
                error: (e, _) => Text('Error loading chapters: $e'),
              );
            },
          ),

          FilledButton(
            onPressed: () => _pickFile(ref),
            child: const Text('Open Audio File'),
          ),
        ],
      ),
    );
  }
}
