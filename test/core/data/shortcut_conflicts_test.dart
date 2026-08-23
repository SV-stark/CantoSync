import 'package:flutter_test/flutter_test.dart';
import 'package:canto_sync/core/data/keyboard_shortcuts.dart';
import 'package:canto_sync/core/services/keyboard_shortcuts_service.dart';

void main() {
  group('KeyboardShortcuts static conflict resolution', () {
    test('isSameShortcut returns true for identical combos', () {
      final a = KeyboardShortcut(
        action: ShortcutAction.playPause,
        keyValue: 'Space',
        ctrl: true,
        alt: false,
        shift: true,
        description: 'Action A',
      );
      final b = KeyboardShortcut(
        action: ShortcutAction.stop,
        keyValue: 'Space',
        ctrl: true,
        alt: false,
        shift: true,
        description: 'Action B',
      );

      expect(KeyboardShortcuts.isSameShortcut(a, b), isTrue);
    });

    test('isSameShortcut returns false when modifiers or key differs', () {
      final base = KeyboardShortcut(
        action: ShortcutAction.playPause,
        keyValue: 'Space',
        ctrl: true,
        description: 'Base',
      );
      final diffKey = KeyboardShortcut(
        action: ShortcutAction.playPause,
        keyValue: 'Enter',
        ctrl: true,
        description: 'Diff Key',
      );
      final diffModifier = KeyboardShortcut(
        action: ShortcutAction.playPause,
        keyValue: 'Space',
        ctrl: false,
        alt: true,
        description: 'Diff Mod',
      );

      expect(KeyboardShortcuts.isSameShortcut(base, diffKey), isFalse);
      expect(KeyboardShortcuts.isSameShortcut(base, diffModifier), isFalse);
    });

    test('findConflicts identifies different actions with same key combo', () {
      final s1 = KeyboardShortcut(
        action: ShortcutAction.playPause,
        keyValue: 'Space',
        description: 'Play/Pause',
      );
      final s2 = KeyboardShortcut(
        action: ShortcutAction.stop,
        keyValue: 'Space', // Conflicting key combo with s1
        description: 'Stop',
      );
      final s3 = KeyboardShortcut(
        action: ShortcutAction.nextTrack,
        keyValue: 'ArrowRight',
        description: 'Next',
      );

      final conflicts = KeyboardShortcuts.findConflicts([s1, s2, s3]);
      expect(conflicts.length, 1);
      expect(conflicts.first.key.action, ShortcutAction.playPause);
      expect(conflicts.first.value.action, ShortcutAction.stop);
    });

    test('hasConflict returns true for collision with another action', () {
      final list = [
        KeyboardShortcut(
          action: ShortcutAction.playPause,
          keyValue: 'Space',
          description: 'Play/Pause',
        ),
        KeyboardShortcut(
          action: ShortcutAction.stop,
          keyValue: 'Escape',
          description: 'Stop',
        ),
      ];

      final candidate = KeyboardShortcut(
        action: ShortcutAction.toggleFullscreen,
        keyValue: 'Space', // Collides with playPause
        description: 'Fullscreen',
      );

      expect(KeyboardShortcuts.hasConflict(list, candidate), isTrue);
    });

    test('hasConflict excludes self (same action does not conflict with itself)', () {
      final existing = KeyboardShortcut(
        action: ShortcutAction.playPause,
        keyValue: 'Space',
        description: 'Play/Pause',
      );
      final list = [existing];

      // Updating playPause to the same key 'Space' should NOT conflict with itself
      final updatedSelf = KeyboardShortcut(
        action: ShortcutAction.playPause,
        keyValue: 'Space',
        description: 'Play/Pause Updated',
      );

      expect(KeyboardShortcuts.hasConflict(list, updatedSelf), isFalse);
    });
  });
}
