import 'package:flutter_test/flutter_test.dart';
import 'package:canto_sync/core/data/keyboard_shortcuts.dart';

void main() {
  group('KeyboardShortcut', () {
    test('shortcutString formats correctly with no modifiers', () {
      final shortcut = KeyboardShortcut(
        action: 'test',
        keyValue: 'A',
        description: 'Test',
      );
      expect(shortcut.shortcutString, 'A');
    });

    test('shortcutString formats correctly with Ctrl', () {
      final shortcut = KeyboardShortcut(
        action: 'test',
        keyValue: 'S',
        ctrl: true,
        description: 'Test',
      );
      expect(shortcut.shortcutString, 'Ctrl+S');
    });

    test('shortcutString formats correctly with multiple modifiers', () {
      final shortcut = KeyboardShortcut(
        action: 'test',
        keyValue: 'Z',
        ctrl: true,
        shift: true,
        description: 'Test',
      );
      expect(shortcut.shortcutString, 'Ctrl+Shift+Z');
    });

    test('key getter returns keyValue', () {
      final shortcut = KeyboardShortcut(
        action: 'test',
        keyValue: 'Space',
        description: 'Test',
      );
      expect(shortcut.key, 'Space');
    });

    test('logicalKeys returns correct set for Space', () {
      final shortcut = KeyboardShortcut(
        action: 'test',
        keyValue: 'Space',
        description: 'Test',
      );
      expect(shortcut.logicalKeys, isNotNull);
      expect(shortcut.logicalKeys!.length, 1);
    });

    test('logicalKeys returns correct set for Ctrl+ArrowRight', () {
      final shortcut = KeyboardShortcut(
        action: 'test',
        keyValue: 'ArrowRight',
        ctrl: true,
        description: 'Test',
      );
      expect(shortcut.logicalKeys, isNotNull);
      expect(shortcut.logicalKeys!.length, 2);
    });
  });

  group('getDefaultShortcuts', () {
    test('returns expected number of shortcuts', () {
      final shortcuts = getDefaultShortcuts();
      expect(shortcuts.length, greaterThan(10));
    });

    test('all shortcuts have unique actions', () {
      final shortcuts = getDefaultShortcuts();
      final actions = shortcuts.map((s) => s.action).toSet();
      expect(actions.length, shortcuts.length);
    });

    test('play_pause shortcut exists with Space key', () {
      final shortcuts = getDefaultShortcuts();
      final playPause = shortcuts.firstWhere(
        (s) => s.action == ShortcutAction.playPause,
      );
      expect(playPause.keyValue, 'Space');
    });
  });

  group('ShortcutAction', () {
    test('descriptions map contains all actions', () {
      final actions = [
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

      for (final action in actions) {
        expect(ShortcutAction.descriptions.containsKey(action), isTrue);
      }
    });
  });

  group('Symbol and Special Key Mappings', () {
    test('bracket keys [ and ] map correctly to logical keys', () {
      final bracketLeft = KeyboardShortcut(
        action: ShortcutAction.decreaseSpeed,
        keyValue: '[',
        description: 'Decrease Speed',
      );
      final bracketRight = KeyboardShortcut(
        action: ShortcutAction.increaseSpeed,
        keyValue: ']',
        description: 'Increase Speed',
      );
      expect(bracketLeft.logicalKeys, isNotNull);
      expect(bracketLeft.logicalKeys!.isNotEmpty, isTrue);
      expect(bracketRight.logicalKeys, isNotNull);
      expect(bracketRight.logicalKeys!.isNotEmpty, isTrue);
    });

    test('punctuation keys ;, ,, ., /, \\ map correctly', () {
      final keys = [';', ',', '.', '/', '\\', '-', '=', '`', "'"];
      for (final k in keys) {
        final shortcut = KeyboardShortcut(
          action: 'custom',
          keyValue: k,
          description: 'Custom $k',
        );
        expect(
          shortcut.logicalKeys,
          isNotNull,
          reason: 'Key $k should map to a valid LogicalKeyboardKey',
        );
      }
    });
  });
}
