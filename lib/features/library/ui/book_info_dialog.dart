import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/library/data/library_service.dart';

class BookInfoDialog extends ConsumerStatefulWidget {
  final Book book;

  const BookInfoDialog({super.key, required this.book});

  @override
  ConsumerState<BookInfoDialog> createState() => _BookInfoDialogState();
}

class _BookInfoDialogState extends ConsumerState<BookInfoDialog> {
  String _formatDuration(double? seconds) {
    if (seconds == null) return 'Unknown';
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else {
      return '${minutes}m ${secs}s';
    }
  }

  Future<void> _pickNewCover() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      await ref
          .read(libraryServiceProvider)
          .updateBookCover(widget.book, result.files.single.path!);
      setState(() {}); // Refresh UI
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final theme = FluentTheme.of(context);

    return ContentDialog(
      title: Text(book.title),
      constraints: const BoxConstraints(maxWidth: 600),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 150,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: theme.resources.cardBackgroundFillColorDefault,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: book.coverPath != null
                            ? Image.file(
                                File(book.coverPath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      FluentIcons.music_note,
                                      size: 64,
                                    ),
                              )
                            : const Icon(FluentIcons.music_note, size: 64),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 150,
                      child: FilledButton(
                        onPressed: _pickNewCover,
                        child: const Text('Change Cover'),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        label: 'Author',
                        value: book.author ?? 'Unknown',
                      ),
                      _InfoRow(
                        label: 'Narrator',
                        value: book.narrator ?? 'Unknown',
                      ),
                      _InfoRow(label: 'Album', value: book.album ?? 'N/A'),
                      _InfoRow(label: 'Series', value: book.series ?? 'N/A'),
                      _InfoRow(
                        label: 'Length',
                        value: _formatDuration(book.durationSeconds),
                      ),
                      _InfoRow(
                        label: 'Location',
                        value: book.path,
                        isPath: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (book.description != null && book.description!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Description', style: theme.typography.subtitle),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.resources.cardBackgroundFillColorDefault,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: theme.resources.dividerStrokeColorDefault,
                  ),
                ),
                child: Text(book.description!, style: theme.typography.body),
              ),
            ],
          ],
        ),
      ),
      actions: [
        FilledButton(
          child: const Text('Close'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPath;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isPath = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.typography.caption?.copyWith(
              color: theme.typography.caption?.color?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.typography.bodyStrong,
            maxLines: isPath ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
