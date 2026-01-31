import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:canto_sync/core/data/keyboard_shortcuts.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/core/services/sleep_timer_service.dart';

final keyboardShortcutsProvider = NotifierProvider<KeyboardShortcutsNotifier, List<KeyboardShortcut>>(
  KeyboardShortcutsNotifier.new,
);

class KeyboardShortcutsNotifier extends Notifier<List<KeyboardShortcut>> {
  static const String boxName = 'keyboardShortcuts';
  late Box<KeyboardShortcut> _box;

  @override
  List<KeyboardShortcut> build() {
    _init();
    return getDefaultShortcuts();
  }

  Future<void> _init() async {
    try {
      _box = await Hive.openBox<KeyboardShortcut>(boxName);
      await loadShortcuts();
    } catch (e) {
      debugPrint('Error initializing keyboard shortcuts box: $e');
    }
  }

  Future<void> loadShortcuts() async {
    try {
      if (_box.isEmpty) {
        await resetToDefaults();
        return;
      }

      final shortcuts = _box.values.toList();
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
        await _box.put(shortcut.action, shortcut);
      }
    } catch (e) {
      debugPrint('Error updating shortcut: $e');
    }
  }

  Future<void> resetToDefaults() async {
    try {
      await _box.clear();
      final defaults = getDefaultShortcuts();
      for (final shortcut in defaults) {
        await _box.put(shortcut.action, shortcut);
      }
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
    return state.any((s) =>
        s.action != shortcut.action && _isSameShortcut(s, shortcut));
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
        await mediaService.setVolume(
          (mediaService.volume + 10).clamp(0, 200),
        );
        break;
      case ShortcutAction.volumeDown:
        await mediaService.setVolume(
          (mediaService.volume - 10).clamp(0, 200),
        );
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
      case ShortcutAction.addBookmark:
      case ShortcutAction.openLibrary:
      case ShortcutAction.openPlayer:
      case ShortcutAction.openSettings:
      case ShortcutAction.focusSearch:
      case ShortcutAction.toggleViewMode:
        break;
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
