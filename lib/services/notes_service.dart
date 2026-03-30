import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';

class NotesService {
  static const _boxName = 'notes';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_boxName);
  }

  Box<Map> get _box => Hive.box<Map>(_boxName);

  List<Note> getAll() {
    return _box.values
        .map((e) => Note.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> save(Note note) async {
    await _box.put(note.id, note.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}