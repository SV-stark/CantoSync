import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/features/library/data/library_service.dart';

final playbackSyncProvider = Provider<PlaybackSyncService>((ref) {
  final mediaService = ref.watch(mediaServiceProvider);
  final libraryService = ref.watch(libraryServiceProvider);
  return PlaybackSyncService(mediaService, libraryService, ref);
});

final currentBookPathProvider =
    NotifierProvider<CurrentBookPathNotifier, String?>(() {
      return CurrentBookPathNotifier();
    });

class CurrentBookPathNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  set state(String? value) => super.state = value;
}

class PlaybackSyncService {
  final MediaService _mediaService;
  final LibraryService _libraryService;
  final Ref _ref;
  StreamSubscription? _subscription;
  String? _currentPath;
  Timer? _debounceTimer;

  PlaybackSyncService(this._mediaService, this._libraryService, this._ref) {
    _init();
  }

  void _init() {
    _subscription = _mediaService.positionStream.listen((position) {
      if (_currentPath != null && _mediaService.isPlaying) {
        _debounceSave(_currentPath!, position.inMilliseconds / 1000.0);
      }
    });

    // Also listen to media open to update _currentPath
    // MediaKit doesn't give "current file path" stream easily directly from Player.stream.playlist
    // But we can store it when we call open().
    // For now, let's rely on the fact that we call open() via a provider or we can just not handle it here yet?
    // Better: Helper method in this service to open file, ensuring we track it.
  }

  void setCurrentBook(String path) {
    _currentPath = path;
    _ref.read(currentBookPathProvider.notifier).state = path;
  }

  Future<void> resumeBook(String path) async {
    _currentPath = path;
    _ref.read(currentBookPathProvider.notifier).state = path;
    await _mediaService.open(path);

    // Find book to get last position
    try {
      final books = _libraryService.books;
      final book = books.firstWhere((b) => b.path == path);
      if (book.positionSeconds != null && book.positionSeconds! > 0) {
        await _mediaService.seek(
          Duration(milliseconds: (book.positionSeconds! * 1000).toInt()),
        );
      }
    } catch (_) {}

    await _mediaService.play();
  }

  void _debounceSave(String path, double seconds) {
    if (_debounceTimer?.isActive ?? false) return;

    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _libraryService.updateProgress(path, seconds);
    });
  }

  void dispose() {
    _subscription?.cancel();
    _debounceTimer?.cancel();
  }
}
