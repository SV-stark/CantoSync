import 'package:canto_sync/core/data/isar_provider.dart';
import 'package:canto_sync/core/data/keyboard_shortcuts.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/core/services/sleep_timer_service.dart';
import 'package:canto_sync/core/utils/logger.dart';
import 'package:isar_community/isar.dart';
import 'package:window_manager/window_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'keyboard_shortcuts_service.g.dart';

typedef ShortcutActionCallback = void Function();

@Riverpod(keepAlive: true)
class KeyboardShortcuts extends _$KeyboardShortcuts {
  late Isar _isar;

  @override
  List<KeyboardShortcut> build() {
    _isar = ref.watch(isarProvider);
    try {
      final shortcuts = _isar.keyboardShortcuts.where().findAllSync();
      if (shortcuts.isNotEmpty) {
        return shortcuts;
      }
      final defaults = getDefaultShortcuts();
      _isar.writeTxnSync(() {
        _isar.keyboardShortcuts.putAllSync(defaults);
      });
      return defaults;
    } catch (e) {
      logger.w('Failed to load shortcuts synchronously: $e');
      return getDefaultShortcuts();
    }
  }

  Future<void> loadShortcuts() async {
    try {
      final shortcuts = await _isar.keyboardShortcuts.where().findAll();
      if (shortcuts.isEmpty) {
        await resetToDefaults();
        return;
      }
      state = shortcuts;
    } catch (e) {
      logger.e('Error loading shortcuts', error: e);
      state = getDefaultShortcuts();
    }
  }

  Future<void> updateShortcut(KeyboardShortcut shortcut) async {
    try {
      final index = state.indexWhere((s) => s.action == shortcut.action);
      if (index != -1) {
        final newState = [...state];
        newState[index] = shortcut;
        state = newState;
        await _isar.writeTxn(() async {
          await _isar.keyboardShortcuts.put(shortcut);
        });
      }
    } catch (e) {
      logger.e('Error updating shortcut', error: e);
    }
  }

  Future<void> resetToDefaults() async {
    try {
      final defaults = getDefaultShortcuts();
      await _isar.writeTxn(() async {
        await _isar.keyboardShortcuts.clear();
        await _isar.keyboardShortcuts.putAll(defaults);
      });
      state = defaults;
    } catch (e) {
      logger.e('Error resetting to defaults', error: e);
    }
  }

  static bool isSameShortcut(KeyboardShortcut a, KeyboardShortcut b) {
    return a.key == b.key &&
        a.ctrl == b.ctrl &&
        a.alt == b.alt &&
        a.shift == b.shift;
  }

  static List<MapEntry<KeyboardShortcut, KeyboardShortcut>> findConflicts(
    List<KeyboardShortcut> shortcuts,
  ) {
    final conflicts = <MapEntry<KeyboardShortcut, KeyboardShortcut>>[];
    for (int i = 0; i < shortcuts.length; i++) {
      for (int j = i + 1; j < shortcuts.length; j++) {
        final s1 = shortcuts[i];
        final s2 = shortcuts[j];
        if (isSameShortcut(s1, s2)) {
          conflicts.add(MapEntry(s1, s2));
        }
      }
    }
    return conflicts;
  }

  static bool hasConflict(
    List<KeyboardShortcut> shortcuts,
    KeyboardShortcut shortcut,
  ) {
    return shortcuts.any(
      (s) => s.action != shortcut.action && isSameShortcut(s, shortcut),
    );
  }

  List<MapEntry<KeyboardShortcut, KeyboardShortcut>> getConflicts() {
    return findConflicts(state);
  }

  KeyboardShortcut? findShortcut(String action) {
    try {
      return state.firstWhere((s) => s.action == action);
    } catch (e) {
      return null;
    }
  }

  bool hasConflicts(KeyboardShortcut shortcut) {
    return hasConflict(state, shortcut);
  }

  Future<void> executeAction(String action) async {
    final mediaService = ref.read(mediaServiceProvider);
    final sleepTimerState = ref.read(sleepTimerProvider);
    final sleepTimerNotifier = ref.read(sleepTimerProvider.notifier);

    switch (action) {
      case ShortcutAction.playPause:
        await mediaService.playOrPause();
        break;
      case ShortcutAction.stop:
        await mediaService.seek(Duration.zero);
        await mediaService.pause();
        break;
      case ShortcutAction.nextTrack:
        await mediaService.nextChapter();
        break;
      case ShortcutAction.previousTrack:
        await mediaService.previousChapter();
        break;
      case ShortcutAction.skipForward:
        await mediaService.seek(
          mediaService.position + const Duration(seconds: 15),
        );
        break;
      case ShortcutAction.skipBackward:
        await mediaService.seek(
          mediaService.position - const Duration(seconds: 15),
        );
        break;
      case ShortcutAction.volumeUp:
        await mediaService.setVolume((mediaService.volume + 5).clamp(0.0, 100.0));
        break;
      case ShortcutAction.volumeDown:
        await mediaService.setVolume((mediaService.volume - 5).clamp(0.0, 100.0));
        break;
      case ShortcutAction.volumeMute:
        await mediaService.setVolume(0);
        break;
      case ShortcutAction.increaseSpeed:
        await mediaService.setRate(
          (mediaService.playRate + 0.1).clamp(0.5, 3.0),
        );
        break;
      case ShortcutAction.decreaseSpeed:
        await mediaService.setRate(
          (mediaService.playRate - 0.1).clamp(0.5, 3.0),
        );
        break;
      case ShortcutAction.toggleSleepTimer:
        if (sleepTimerState.remainingTime != null) {
          sleepTimerNotifier.cancelTimer();
        } else {
          sleepTimerNotifier.startTimer(const Duration(minutes: 30));
        }
        break;
      case ShortcutAction.toggleFullscreen:
        await windowManager.setFullScreen(
          !(await windowManager.isFullScreen()),
        );
        break;
      case ShortcutAction.addBookmark:
        _executeCallbacks(ShortcutAction.addBookmark);
        break;
      case ShortcutAction.openLibrary:
        _executeCallbacks(ShortcutAction.openLibrary);
        break;
      case ShortcutAction.openPlayer:
        _executeCallbacks(ShortcutAction.openPlayer);
        break;
      case ShortcutAction.openSettings:
        _executeCallbacks(ShortcutAction.openSettings);
        break;
      case ShortcutAction.focusSearch:
        _executeCallbacks(ShortcutAction.focusSearch);
        break;
      case ShortcutAction.toggleViewMode:
        _executeCallbacks(ShortcutAction.toggleViewMode);
        break;
    }
  }

  void _executeCallbacks(String action) {
    try {
      ref.read(shortcutActionCallbacksProvider).execute(action);
    } catch (e) {
      logger.e('Error executing shortcut callback for $action', error: e);
    }
  }

  List<KeyboardShortcut> getShortcutsByCategory(String category) {
    return state.where((s) => getCategory(s.action) == category).toList();
  }

  static String getCategory(String action) {
    switch (action) {
      case ShortcutAction.playPause:
      case ShortcutAction.stop:
      case ShortcutAction.nextTrack:
      case ShortcutAction.previousTrack:
      case ShortcutAction.skipForward:
      case ShortcutAction.skipBackward:
        return 'Playback';
      case ShortcutAction.volumeUp:
      case ShortcutAction.volumeDown:
      case ShortcutAction.volumeMute:
        return 'Audio';
      case ShortcutAction.increaseSpeed:
      case ShortcutAction.decreaseSpeed:
        return 'Speed';
      case ShortcutAction.toggleSleepTimer:
      case ShortcutAction.addBookmark:
      case ShortcutAction.toggleFullscreen:
      case ShortcutAction.toggleViewMode:
        return 'Features';
      case ShortcutAction.openLibrary:
      case ShortcutAction.openPlayer:
      case ShortcutAction.openSettings:
      case ShortcutAction.focusSearch:
        return 'Navigation';
      default:
        return 'Other';
    }
  }

  List<String> get categories {
    return ['Playback', 'Audio', 'Speed', 'Features', 'Navigation'];
  }
}

@Riverpod(keepAlive: true)
ShortcutActionCallbacks shortcutActionCallbacks(Ref ref) {
  return ShortcutActionCallbacks();
}

class ShortcutActionCallbacks {
  final Map<String, List<ShortcutActionCallback>> _callbacks = {};

  Map<String, List<ShortcutActionCallback>> get callbacks => _callbacks;

  void register(String action, ShortcutActionCallback callback) {
    final list = _callbacks.putIfAbsent(action, () => []);
    if (!list.contains(callback)) {
      list.add(callback);
    }
  }

  void unregister(String action, ShortcutActionCallback callback) {
    if (_callbacks.containsKey(action)) {
      final list = _callbacks[action]!;
      list.remove(callback);
      if (list.isEmpty) {
        _callbacks.remove(action);
      }
    }
  }

  void execute(String action) {
    final list = _callbacks[action];
    if (list != null) {
      for (final callback in List<ShortcutActionCallback>.from(list)) {
        callback();
      }
    }
  }
}
