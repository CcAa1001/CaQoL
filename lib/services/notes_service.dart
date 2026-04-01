import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';

class NotesService {
  static const _boxName = 'notes';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_boxName);
  }

  Box<Map> get _box => Hive.box<Map>(_boxName);

  List<Note> getAll({bool includeDeleted = false}) {
    final notes = <Note>[];
    for (final raw in _box.values) {
      try {
        final note = Note.fromMap(Map<String, dynamic>.from(raw));
        if (includeDeleted || !note.isDeleted) {
          notes.add(note);
        }
      } catch (_) {
        // Skip corrupt legacy entries instead of breaking the whole notes list.
      }
    }
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  Note? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) {
      return null;
    }
    try {
      return Note.fromMap(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Note note) async {
    await _box.put(note.id, note.toMap());
  }

  Future<void> saveAll(Iterable<Note> notes) async {
    for (final note in notes) {
      await save(note);
    }
  }

  Future<void> delete(String id) async {
    final existing = getById(id);
    if (existing == null) {
      return;
    }
    final now = DateTime.now();
    await save(
      existing.copyWith(updatedAt: now, deviceUpdatedAt: now, isDeleted: true),
    );
  }

  Future<void> moveNotesOutOfFolder(String folderId) async {
    final notes = getAll(includeDeleted: true)
        .where((note) => note.folderId == folderId)
        .toList();

    for (final note in notes) {
      await save(note.copyWith(clearFolderId: true));
    }
  }
}
