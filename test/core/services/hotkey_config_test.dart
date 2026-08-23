import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:canto_sync/core/data/keyboard_shortcuts.dart';
import 'package:canto_sync/core/services/hotkey_service.dart';

void main() {
  group('deriveHotKey', () {
    test('derives modifiers in correct collection order (Ctrl, Alt, Shift)', () {
      final shortcut = KeyboardShortcut(
        action: 'test_all_mods',
        keyValue: 'K',
        ctrl: true,
        alt: true,
        shift: true,
        description: 'Test All Modifiers',
      );

      final hotKey = deriveHotKey(shortcut);
      expect(hotKey, isNotNull);
      expect(hotKey!.key, shortcut.logicalKeys!.last);
      expect(
        hotKey.modifiers,
        equals([
          HotKeyModifier.control,
          HotKeyModifier.alt,
          HotKeyModifier.shift,
        ]),
      );
      expect(hotKey.scope, HotKeyScope.system);
    });

    test('media key maps to system scope even without modifiers', () {
      final mediaShortcut = KeyboardShortcut(
        action: ShortcutAction.playPause,
        keyValue: 'MediaPlayPause',
        description: 'Play/Pause',
      );

      final hotKey = deriveHotKey(mediaShortcut);
      expect(hotKey, isNotNull);
      expect(hotKey!.key, LogicalKeyboardKey.mediaPlay);
      expect(hotKey.modifiers, isEmpty);
      expect(hotKey.scope, HotKeyScope.system);
    });

    test('bare non-media key maps to inapp scope', () {
      final spaceShortcut = KeyboardShortcut(
        action: ShortcutAction.playPause,
        keyValue: 'Space',
        description: 'Play/Pause',
      );

      final hotKey = deriveHotKey(spaceShortcut);
      expect(hotKey, isNotNull);
      expect(hotKey!.key, LogicalKeyboardKey.space);
      expect(hotKey.modifiers, isEmpty);
      expect(hotKey.scope, HotKeyScope.inapp);
    });

    test('key with modifiers maps to system scope', () {
      final ctrlBShortcut = KeyboardShortcut(
        action: ShortcutAction.addBookmark,
        keyValue: 'B',
        ctrl: true,
        description: 'Add Bookmark',
      );

      final hotKey = deriveHotKey(ctrlBShortcut);
      expect(hotKey, isNotNull);
      expect(hotKey!.key, ctrlBShortcut.logicalKeys!.last);
      expect(hotKey.modifiers, [HotKeyModifier.control]);
      expect(hotKey.scope, HotKeyScope.system);
    });

    test('unmappable or empty key returns null (skips registration)', () {
      final invalidShortcut = KeyboardShortcut(
        action: 'invalid',
        keyValue: 'UnknownKeySequence12345',
        description: 'Invalid',
      );

      final hotKey = deriveHotKey(invalidShortcut);
      expect(hotKey, isNull);
    });
  });

  group('isMediaKey', () {
    test('identifies all media keys correctly', () {
      expect(isMediaKey(LogicalKeyboardKey.mediaPlay), isTrue);
      expect(isMediaKey(LogicalKeyboardKey.mediaPause), isTrue);
      expect(isMediaKey(LogicalKeyboardKey.mediaPlayPause), isTrue);
      expect(isMediaKey(LogicalKeyboardKey.mediaTrackNext), isTrue);
      expect(isMediaKey(LogicalKeyboardKey.mediaTrackPrevious), isTrue);
      expect(isMediaKey(LogicalKeyboardKey.mediaStop), isTrue);
      expect(isMediaKey(LogicalKeyboardKey.mediaRewind), isTrue);
      expect(isMediaKey(LogicalKeyboardKey.mediaFastForward), isTrue);
      expect(isMediaKey(LogicalKeyboardKey.audioVolumeUp), isTrue);
      expect(isMediaKey(LogicalKeyboardKey.audioVolumeDown), isTrue);
      expect(isMediaKey(LogicalKeyboardKey.audioVolumeMute), isTrue);

      expect(isMediaKey(LogicalKeyboardKey.space), isFalse);
      expect(isMediaKey(LogicalKeyboardKey.keyA), isFalse);
    });
  });
}
