import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:canto_sync/features/library/data/book.dart';

class MetadataEditor extends StatefulWidget {
  final Book book;

  const MetadataEditor({super.key, required this.book});

  @override
  State<MetadataEditor> createState() => _MetadataEditorState();
}

class _MetadataEditorState extends State<MetadataEditor> {
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _albumController;
  late TextEditingController _seriesController;
  late TextEditingController _narratorController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _albumController = TextEditingController(text: widget.book.album);
    _seriesController = TextEditingController(text: widget.book.series);
    _narratorController = TextEditingController(text: widget.book.narrator);
    _descriptionController = TextEditingController(
      text: widget.book.description,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _albumController.dispose();
    _seriesController.dispose();
    _narratorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    widget.book.title = _titleController.text;
    widget.book.author = _authorController.text;
    widget.book.album = _albumController.text;
    widget.book.series = _seriesController.text;
    widget.book.narrator = _narratorController.text;
    widget.book.description = _descriptionController.text;
    await widget.book.save();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Edit Metadata'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.book.coverPath != null)
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(File(widget.book.coverPath!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      InfoLabel(
                        label: 'Title',
                        child: TextBox(
                          controller: _titleController,
                          placeholder: 'Title',
                        ),
                      ),
                      const SizedBox(height: 8),
                      InfoLabel(
                        label: 'Author',
                        child: TextBox(
                          controller: _authorController,
                          placeholder: 'Author',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InfoLabel(
              label: 'Album',
              child: TextBox(
                controller: _albumController,
                placeholder: 'Album',
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: 'Series',
              child: TextBox(
                controller: _seriesController,
                placeholder: 'Series',
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: 'Narrator',
              child: TextBox(
                controller: _narratorController,
                placeholder: 'Narrator',
              ),
            ),
            const SizedBox(height: 12),
            InfoLabel(
              label: 'Description / Synopsis',
              child: TextBox(
                controller: _descriptionController,
                placeholder: 'Enter synopsis...',
                maxLines: 5,
                minLines: 3,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
