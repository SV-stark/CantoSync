import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canto_sync/core/data/keyboard_shortcuts.dart';
import 'package:canto_sync/core/services/keyboard_shortcuts_service.dart';

class KeyboardShortcutsScreen extends ConsumerStatefulWidget {
  const KeyboardShortcutsScreen({super.key});

  @override
  ConsumerState<KeyboardShortcutsScreen> createState() =>
      _KeyboardShortcutsScreenState();
}

class _KeyboardShortcutsScreenState
    extends ConsumerState<KeyboardShortcutsScreen> {
  @override
  Widget build(BuildContext context) {
    final shortcutsNotifier = ref.read(keyboardShortcutsProvider.notifier);
    final conflicts = shortcutsNotifier.getConflicts();

    return ScaffoldPage.withPadding(
      header: PageHeader(
        title: const Text('Keyboard Shortcuts'),
        commandBar: Button(
          child: const Text('Reset to Defaults'),
          onPressed: () => _showResetDialog(context, shortcutsNotifier),
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (conflicts.isNotEmpty)
            InfoBar(
              title: const Text('Shortcut Conflicts Detected'),
              content: Text(
                '${conflicts.length} conflicting shortcut(s) found. Please resolve these conflicts.',
              ),
              severity: InfoBarSeverity.warning,
            ),
          if (conflicts.isNotEmpty) const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: shortcutsNotifier.categories.length,
              itemBuilder: (context, index) {
                final category = shortcutsNotifier.categories[index];
                final categoryShortcuts = shortcutsNotifier
                    .getShortcutsByCategory(category);

                if (categoryShortcuts.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Expander(
                    header: Text(category),
                    initiallyExpanded: index == 0,
                    content: Column(
                      children: categoryShortcuts.map((shortcut) {
                        final isConflict = shortcutsNotifier.hasConflicts(
                          shortcut,
                        );
                        return ListTile(
                          leading: isConflict
                              ? const Icon(
                                  FluentIcons.warning,
                                  color: Colors.warningPrimaryColor,
                                )
                              : const Icon(FluentIcons.keyboard_classic),
                          title: Text(shortcut.description),
                          subtitle: isConflict
                              ? const Text(
                                  'Conflicting shortcut',
                                  style: TextStyle(
                                    color: Colors.warningPrimaryColor,
                                  ),
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildShortcutBadge(context, shortcut),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(FluentIcons.edit),
                                onPressed: () =>
                                    _showEditDialog(context, shortcut),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutBadge(BuildContext context, KeyboardShortcut shortcut) {
    final parts = <String>[];
    if (shortcut.ctrl) parts.add('Ctrl');
    if (shortcut.alt) parts.add('Alt');
    if (shortcut.shift) parts.add('Shift');
    parts.add(shortcut.key);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).accentColor.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: FluentTheme.of(context).accentColor.withAlpha(76),
        ),
      ),
      child: Text(
        parts.join('+'),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: FluentTheme.of(context).accentColor,
        ),
      ),
    );
  }

  Future<void> _showResetDialog(
    BuildContext dialogContext,
    KeyboardShortcutsNotifier notifier,
  ) async {
    final result = await showDialog<bool>(
      context: dialogContext,
      builder: (context) => ContentDialog(
        title: const Text('Reset Shortcuts'),
        content: const Text(
          'Are you sure you want to reset all keyboard shortcuts to their default values?',
        ),
        actions: [
          Button(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (result == true) {
      await notifier.resetToDefaults();
      if (mounted) {
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: const Text('Shortcuts Reset'),
            content: const Text('All shortcuts have been reset to defaults.'),
            severity: InfoBarSeverity.success,
            onClose: close,
          ),
        );
      }
    }
  }

  void _showEditDialog(BuildContext context, KeyboardShortcut shortcut) {
    showDialog(
      context: context,
      builder: (context) => _EditShortcutDialog(
        shortcut: shortcut,
        onSave: (updatedShortcut) async {
          final notifier = ref.read(keyboardShortcutsProvider.notifier);
          await notifier.updateShortcut(updatedShortcut);
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _EditShortcutDialog extends StatefulWidget {
  final KeyboardShortcut shortcut;
  final Function(KeyboardShortcut) onSave;
  final VoidCallback onCancel;

  const _EditShortcutDialog({
    required this.shortcut,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_EditShortcutDialog> createState() => _EditShortcutDialogState();
}

class _EditShortcutDialogState extends State<_EditShortcutDialog> {
  late String _key;
  late bool _ctrl;
  late bool _alt;
  late bool _shift;

  @override
  void initState() {
    super.initState();
    _key = widget.shortcut.key;
    _ctrl = widget.shortcut.ctrl;
    _alt = widget.shortcut.alt;
    _shift = widget.shortcut.shift;
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text('Edit Shortcut: ${widget.shortcut.description}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current shortcut:'),
          const SizedBox(height: 16),
          Center(child: _buildCurrentShortcutDisplay()),
          const SizedBox(height: 24),
          const Text('Modifiers:'),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                checked: _ctrl,
                onChanged: (v) => setState(() => _ctrl = v ?? false),
              ),
              const Text('Ctrl'),
              const SizedBox(width: 16),
              Checkbox(
                checked: _alt,
                onChanged: (v) => setState(() => _alt = v ?? false),
              ),
              const Text('Alt'),
              const SizedBox(width: 16),
              Checkbox(
                checked: _shift,
                onChanged: (v) => setState(() => _shift = v ?? false),
              ),
              const Text('Shift'),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Key:'),
          const SizedBox(height: 8),
          ComboBox<String>(
            value: _key,
            items: _getAvailableKeys().map((key) {
              return ComboBoxItem(value: key, child: Text(key));
            }).toList(),
            onChanged: (key) {
              if (key != null) {
                setState(() => _key = key);
              }
            },
          ),
        ],
      ),
      actions: [
        Button(onPressed: widget.onCancel, child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final updated = KeyboardShortcut(
              action: widget.shortcut.action,
              keyValue: _key,
              ctrl: _ctrl,
              alt: _alt,
              shift: _shift,
              description: widget.shortcut.description,
            );
            widget.onSave(updated);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildCurrentShortcutDisplay() {
    final parts = <String>[];
    if (_ctrl) parts.add('Ctrl');
    if (_alt) parts.add('Alt');
    if (_shift) parts.add('Shift');
    parts.add(_key);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).accentColor.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: FluentTheme.of(context).accentColor,
          width: 2,
        ),
      ),
      child: Text(
        parts.join(' + '),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: FluentTheme.of(context).accentColor,
        ),
      ),
    );
  }

  List<String> _getAvailableKeys() {
    return [
      'Space',
      'Enter',
      'Escape',
      'Tab',
      'ArrowUp',
      'ArrowDown',
      'ArrowLeft',
      'ArrowRight',
      'Home',
      'End',
      'PageUp',
      'PageDown',
      'Insert',
      'Delete',
      'Backspace',
      'F1',
      'F2',
      'F3',
      'F4',
      'F5',
      'F6',
      'F7',
      'F8',
      'F9',
      'F10',
      'F11',
      'F12',
      'MediaPlayPause',
      'MediaStop',
      'MediaTrackNext',
      'MediaTrackPrevious',
      'MediaRewind',
      'MediaFastForward',
      'VolumeUp',
      'VolumeDown',
      'VolumeMute',
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z',
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '[',
      ']',
      '\\',
      ';',
      "'",
      ',',
      '.',
      '/',
    ];
  }
}
