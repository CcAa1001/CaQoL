import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/note.dart';
import '../../providers/notes_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note;
  const NoteEditorScreen({super.key, this.note});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _bodyCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.note?.body ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _saveAndPop() {
    final title = _titleCtrl.text;
    final body = _bodyCtrl.text;

    if (title.isNotEmpty || body.isNotEmpty) {
      final notifier = ref.read(notesProvider.notifier);
      if (widget.note == null) {
        notifier.add(title, body);
      } else {
        notifier.update(widget.note!.copyWith(title: title, body: body));
      }
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _saveAndPop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _saveAndPop,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveAndPop,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleCtrl,
                style: Theme.of(context).textTheme.titleLarge,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                ),
              ),
              const Divider(),
              Expanded(
                child: TextField(
                  controller: _bodyCtrl,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: 'Start writing...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}