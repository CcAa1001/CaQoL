import 'package:hive_flutter/hive_flutter.dart';

import '../models/note_folder.dart';

class NoteFoldersService {
  static const _boxName = 'note_folders';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_boxName);
  }

  Box<Map> get _box => Hive.box<Map>(_boxName);

  List<NoteFolder> getAll({bool includeDeleted = false}) {
    final folders = <NoteFolder>[];
    for (final raw in _box.values) {
      try {
        final folder = NoteFolder.fromMap(Map<String, dynamic>.from(raw));
        if (includeDeleted || !folder.isDeleted) {
          folders.add(folder);
        }
      } catch (_) {}
    }
    folders.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return folders;
  }

  NoteFolder? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) {
      return null;
    }
    try {
      return NoteFolder.fromMap(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> save(NoteFolder folder) async {
    await _box.put(folder.id, folder.toMap());
  }

  Future<void> saveAll(Iterable<NoteFolder> folders) async {
    for (final folder in folders) {
      await save(folder);
    }
  }

  Future<void> delete(String id) async {
    final existing = getById(id);
    if (existing == null) {
      return;
    }
    final now = DateTime.now();
    await save(
      existing.copyWith(
        updatedAt: now,
        deviceUpdatedAt: now,
        isDeleted: true,
      ),
    );
  }
}
