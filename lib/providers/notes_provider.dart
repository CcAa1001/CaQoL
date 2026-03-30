import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../services/notes_service.dart';

final notesServiceProvider = Provider((ref) => NotesService());

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  return NotesNotifier(ref.read(notesServiceProvider));
});

class NotesNotifier extends StateNotifier<List<Note>> {
  final NotesService _service;

  NotesNotifier(this._service) : super([]) {
    _load();
  }

  void _load() {
    state = _service.getAll();
  }

  Future<void> add(String title, String body) async {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.isEmpty ? 'Untitled' : title,
      body: body,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _service.save(note);
    _load();
  }

  Future<void> update(Note note) async {
    await _service.save(note);
    _load();
  }

  Future<void> delete(String id) async {
    await _service.delete(id);
    _load();
  }
}