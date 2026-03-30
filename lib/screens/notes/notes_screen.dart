import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notes_provider.dart';
import 'note_editor_screen.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: notes.isEmpty
          ? const Center(child: Text('No notes yet. Tap + to add one.'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: notes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final note = notes[i];
                return Dismissible(
                  key: Key(note.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => ref.read(notesProvider.notifier).delete(note.id),
                  child: Card(
                    child: ListTile(
                      title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        note.body.isEmpty ? 'No content' : note.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        '${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}