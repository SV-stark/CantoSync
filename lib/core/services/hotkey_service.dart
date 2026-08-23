import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:canto_sync/core/services/keyboard_shortcuts_service.dart';
import 'package:canto_sync/core/data/keyboard_shortcuts.dart';
import 'package:canto_sync/core/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hotkey_service.g.dart';

@Riverpod(keepAlive: true)
HotkeyService hotkeyService(Ref ref) {
  final service = HotkeyService(ref);
  ref.listen(keyboardShortcutsProvider, (previous, next) {
    service.registerShortcuts();
  });
  return service;
}

class HotkeyService {
  HotkeyService(this._ref);
  final Ref _ref;

  Future<void> init() async {
    await registerShortcuts();
  }

  Future<void> registerShortcuts() async {
    if (kIsWeb) return;
    if (!Platform.isWindows && !Platform.isLinux) return;

    try {
      await hotKeyManager.unregisterAll();
    } catch (e) {
      logger.w('Error unregistering hotkeys: $e');
    }

    final shortcuts = _ref.read(keyboardShortcutsProvider);

    for (final shortcut in shortcuts) {
      await _registerHotKeyFromShortcut(shortcut, () {
        if (!shortcut.ctrl &&
            !shortcut.alt &&
            !shortcut.shift &&
            shortcut.logicalKeys != null &&
            shortcut.logicalKeys!.isNotEmpty &&
            !isMediaKey(shortcut.logicalKeys!.last)) {
          final primaryFocus = FocusManager.instance.primaryFocus;
          if (primaryFocus != null) {
            final context = primaryFocus.context;
            if (context != null) {
              final isEditable =
                  context.findAncestorWidgetOfExactType<EditableText>() != null;
              if (isEditable) return;

              final route = ModalRoute.of(context);
              if (route != null && !route.isCurrent) {
                // Focus is on a background element behind a modal overlay or dialog
                return;
              }
            }
          }
        }
        _ref
            .read(keyboardShortcutsProvider.notifier)
            .executeAction(shortcut.action);
      });
    }
  }

  Future<void> _registerHotKeyFromShortcut(
    KeyboardShortcut shortcut,
    VoidCallback onDown,
  ) async {
    if (kIsWeb) return;
    if (!Platform.isWindows && !Platform.isLinux) return;

    final hotKey = deriveHotKey(shortcut);
    if (hotKey == null) return;

    try {
      await hotKeyManager.register(hotKey, keyDownHandler: (_) => onDown());
    } catch (e) {
      logger.w('Failed to register hotkey ${shortcut.shortcutString}: $e');
    }
  }
}

bool isMediaKey(LogicalKeyboardKey key) {
  return key == LogicalKeyboardKey.mediaPlay ||
      key == LogicalKeyboardKey.mediaPause ||
      key == LogicalKeyboardKey.mediaPlayPause ||
      key == LogicalKeyboardKey.mediaTrackNext ||
      key == LogicalKeyboardKey.mediaTrackPrevious ||
      key == LogicalKeyboardKey.mediaStop ||
      key == LogicalKeyboardKey.mediaRewind ||
      key == LogicalKeyboardKey.mediaFastForward ||
      key == LogicalKeyboardKey.audioVolumeUp ||
      key == LogicalKeyboardKey.audioVolumeDown ||
      key == LogicalKeyboardKey.audioVolumeMute;
}

HotKey? deriveHotKey(KeyboardShortcut shortcut) {
  final logicalKeys = shortcut.logicalKeys;
  if (logicalKeys == null || logicalKeys.isEmpty) return null;

  final mainKey = logicalKeys.last;
  final modifiers = <HotKeyModifier>[];
  for (final key in logicalKeys) {
    if (key == LogicalKeyboardKey.control) {
      modifiers.add(HotKeyModifier.control);
    } else if (key == LogicalKeyboardKey.alt) {
      modifiers.add(HotKeyModifier.alt);
    } else if (key == LogicalKeyboardKey.shift) {
      modifiers.add(HotKeyModifier.shift);
    }
  }

  return HotKey(
    key: mainKey,
    modifiers: modifiers,
    scope: (modifiers.isNotEmpty || isMediaKey(mainKey))
        ? HotKeyScope.system
        : HotKeyScope.inapp,
  );
}

