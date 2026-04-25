import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:canto_sync/core/data/keyboard_shortcuts.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/core/services/sleep_timer_service.dart';
import 'package:isar/isar.dart';
import 'package:window_manager/window_manager.dart';

final keyboardShortcutsProvider =
    NotifierProvider<KeyboardShortcutsNotifier, List<KeyboardShortcut>>(
      KeyboardShortcutsNotifier.new,
    );

typedef ShortcutActionCallback = void Function();
final shortcutActionCallbacksProvider =
    Provider<Map<String, List<ShortcutActionCallback>>>((ref) => {});

class KeyboardShortcutsNotifier extends Notifier<List<KeyboardShortcut>> {
  late Isar _isar;

  @override
  List<KeyboardShortcut> build() {
    _isar = ref.watch(isarProvider);
    _init();
    return getDefaultShortcuts();
  }

  Future<void> _init() async {
    await loadShortcuts();
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
      debugPrint('Error loading shortcuts: $e');
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
      debugPrint('Error updating shortcut: $e');
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
      debugPrint('Error resetting to defaults: $e');
    }
  }

  List<MapEntry<KeyboardShortcut, KeyboardShortcut>> getConflicts() {
    final conflicts = <MapEntry<KeyboardShortcut, KeyboardShortcut>>[];
    final shortcuts = state;

    for (int i = 0; i < shortcuts.length; i++) {
      for (int j = i + 1; j < shortcuts.length; j++) {
        final s1 = shortcuts[i];
        final s2 = shortcuts[j];
        if (_isSameShortcut(s1, s2)) {
          conflicts.add(MapEntry(s1, s2));
        }
      }
    }
    return conflicts;
  }

  bool _isSameShortcut(KeyboardShortcut a, KeyboardShortcut b) {
    return a.key == b.key &&
        a.ctrl == b.ctrl &&
        a.alt == b.alt &&
        a.shift == b.shift;
  }

  KeyboardShortcut? findShortcut(String action) {
    try {
      return state.firstWhere((s) => s.action == action);
    } catch (e) {
      return null;
    }
  }

  bool hasConflicts(KeyboardShortcut shortcut) {
    return state.any(
      (s) => s.action != shortcut.action && _isSameShortcut(s, shortcut),
    );
  }

  Future<void> executeAction(String action) async {
    final mediaService = ref.read(mediaServiceProvider);
    final sleepTimerState = ref.read(sleepTimerServiceProvider);
    final sleepTimerNotifier = ref.read(sleepTimerServiceProvider.notifier);

    switch (action) {
      case ShortcutAction.playPause:
        await mediaService.playOrPause();
        break;
      case ShortcutAction.stop:
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
        await mediaService.setVolume((mediaService.volume + 10).clamp(0, 200));
        break;
      case ShortcutAction.volumeDown:
        await mediaService.setVolume((mediaService.volume - 10).clamp(0, 200));
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
      final Map<String, List<ShortcutActionCallback>> callbacks = ref.read(shortcutActionCallbacksProvider);
      final List<ShortcutActionCallback>? actionCallbacks = callbacks[action];
      if (actionCallbacks != null) {
        for (final callback in actionCallbacks) {
          callback();
        }
      }
    } catch (e) {
      debugPrint('Error executing shortcut callback for $action: $e');
    }
  }

  List<KeyboardShortcut> getShortcutsByCategory(String category) {
    return state.where((s) => _getCategory(s.action) == category).toList();
  }

  String _getCategory(String action) {
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
