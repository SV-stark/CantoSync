import 'dart:async';
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
        // Never steal keystrokes from an editable field, whether or not the
        // shortcut uses a modifier. The old guard only ran for unmodified
        // keys, so Ctrl+B / Ctrl+1 fired "add bookmark" / "open library"
        // while the user was typing in the metadata editor or search box.
        if (!isMediaKeyIn(shortcut)) {
          if (_isEditingText()) return;

          final context = _primaryFocusContext;
          if (context != null) {
            final route = ModalRoute.of(context);
            if (route != null && !route.isCurrent) {
              // Focus is on a background element behind a modal overlay.
              return;
            }
          }
        }

        unawaited(
          _ref
              .read(keyboardShortcutsProvider.notifier)
              .executeAction(shortcut.action),
        );
      });
    }
  }

  /// The logical key that carries the shortcut, or null if unresolvable.
  static LogicalKeyboardKey? _mainKeyOf(KeyboardShortcut shortcut) {
    final keys = shortcut.logicalKeys;
    if (keys == null || keys.isEmpty) return null;
    return keys.last;
  }

  static bool isMediaKeyIn(KeyboardShortcut shortcut) {
    final mainKey = _mainKeyOf(shortcut);
    return mainKey != null && isMediaKey(mainKey);
  }

  static bool _isEditingText() {
    final context = _primaryFocusContext;
    if (context == null) return false;
    return context.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  static BuildContext? get _primaryFocusContext {
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus == null) return null;
    final context = primaryFocus.context;
    return context != null && context.mounted ? context : null;
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
    scope: resolveHotKeyScope(modifiers, mainKey),
  );
}

/// Resolves the registration scope for a hotkey.
///
/// `HotKeyScope.inapp` is only implemented on Windows and macOS; registering
/// it on Linux silently swallows the key, so unmodified non-media shortcuts
/// fall back to system scope there.
HotKeyScope resolveHotKeyScope(
  List<HotKeyModifier> modifiers,
  LogicalKeyboardKey mainKey,
) {
  if (modifiers.isNotEmpty || isMediaKey(mainKey)) {
    return HotKeyScope.system;
  }
  if (Platform.isLinux) {
    return HotKeyScope.system;
  }
  return HotKeyScope.inapp;
}

