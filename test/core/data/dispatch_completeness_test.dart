import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:canto_sync/core/data/keyboard_shortcuts.dart';
import 'package:canto_sync/core/services/keyboard_shortcuts_service.dart';

void main() {
  group('ShortcutAction Dispatch & Definition Completeness Guard', () {
    const allActions = [
      ShortcutAction.playPause,
      ShortcutAction.stop,
      ShortcutAction.nextTrack,
      ShortcutAction.previousTrack,
      ShortcutAction.skipForward,
      ShortcutAction.skipBackward,
      ShortcutAction.volumeUp,
      ShortcutAction.volumeDown,
      ShortcutAction.volumeMute,
      ShortcutAction.toggleFullscreen,
      ShortcutAction.increaseSpeed,
      ShortcutAction.decreaseSpeed,
      ShortcutAction.toggleSleepTimer,
      ShortcutAction.addBookmark,
      ShortcutAction.openLibrary,
      ShortcutAction.openPlayer,
      ShortcutAction.openSettings,
      ShortcutAction.focusSearch,
      ShortcutAction.toggleViewMode,
    ];

    test('every ShortcutAction constant has a description in descriptions map', () {
      for (final action in allActions) {
        expect(
          ShortcutAction.descriptions.containsKey(action),
          isTrue,
          reason: 'Missing description for action: $action',
        );
        expect(
          ShortcutAction.descriptions[action]!.trim().isNotEmpty,
          isTrue,
          reason: 'Empty description for action: $action',
        );
      }
      expect(ShortcutAction.descriptions.length, allActions.length);
    });

    test('every ShortcutAction constant maps to a known valid category in getCategory', () {
      final validCategories = {'Playback', 'Audio', 'Speed', 'Features', 'Navigation'};

      for (final action in allActions) {
        final category = KeyboardShortcuts.getCategory(action);
        expect(
          validCategories.contains(category),
          isTrue,
          reason: 'Action $action produced unknown category "$category" (should not fall back to Other)',
        );
      }
    });

    test('every ShortcutAction is explicitly handled in executeAction', () {
      final file = File('lib/core/services/keyboard_shortcuts_service.dart');
      final content = file.readAsStringSync();

      // Ensure executeAction contains a case for each action constant
      for (final action in allActions) {
        final hasCase = content.contains('case ShortcutAction.$action:') ||
            content.contains("case '$action':") ||
            content.contains('case ShortcutAction.${_actionToFieldName(action)}:');

        expect(
          hasCase,
          isTrue,
          reason: 'executeAction in keyboard_shortcuts_service.dart must handle action "$action"',
        );
      }
    });
  });
}

String _actionToFieldName(String action) {
  // Convert snake_case to camelCase
  final parts = action.split('_');
  if (parts.isEmpty) return action;
  final buffer = StringBuffer(parts.first);
  for (int i = 1; i < parts.length; i++) {
    if (parts[i].isNotEmpty) {
      buffer.write(parts[i][0].toUpperCase() + parts[i].substring(1));
    }
  }
  return buffer.toString();
}
