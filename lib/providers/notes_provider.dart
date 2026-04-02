import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../services/cloud_sync_service.dart';
import '../services/notes_service.dart';
import '../services/auth_service.dart';

final notesServiceProvider = Provider((ref) => NotesService());

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return NotesNotifier(
    ref.read(notesServiceProvider),
    ref.read(notesCloudSyncServiceProvider),
    isCloudEnabled: user != null,
  );
});

class NotesNotifier extends StateNotifier<List<Note>> {
  final NotesService _service;
  final NotesCloudSyncService _cloudSync;
  final bool isCloudEnabled;
  StreamSubscription<List<Note>>? _cloudSubscription;

  NotesNotifier(this._service, this._cloudSync, {required this.isCloudEnabled})
    : super([]) {
    _initialize();
  }

  Future<void> _initialize() async {
    _load();
    if (!isCloudEnabled) {
      return;
    }
    await _cloudSync.pushLocalSnapshot(_service.getAll(includeDeleted: true));
    _cloudSubscription = _cloudSync.watch().listen((remoteNotes) async {
      final locals = _service.getAll(includeDeleted: true);
      final localById = {for (var n in locals) n.id: n};
      final toSave = <Note>[];
      for (final remote in remoteNotes) {
        final local = localById[remote.id];
        if (local == null || remote.deviceUpdatedAt.isAfter(local.deviceUpdatedAt)) {
          toSave.add(remote);
        }
      }
      if (toSave.isNotEmpty) {
        await _service.saveAll(toSave);
        _load();
      }
    });
  }

  void _load() {
    state = _service.getAll();
  }

  Future<Note> add(
    String title,
    String body, {
    String? folderId,
    bool isFavorite = false,
    List<String> tags = const [],
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.isEmpty ? 'Untitled' : title,
      body: body,
      folderId: folderId,
      isFavorite: isFavorite,
      tags: tags,
      createdAt: now,
      updatedAt: now,
      deviceUpdatedAt: now,
    );
    await _service.save(note);
    _load();
    if (isCloudEnabled) {
      unawaited(_cloudSync.save(note));
    }
    return note;
  }

  Future<void> update(Note note) async {
    await _service.save(note);
    _load();
    if (isCloudEnabled) {
      unawaited(_cloudSync.save(note));
    }
  }

  Future<void> delete(String id) async {
    final deletedNote = _service.getById(id)?.copyWith(isDeleted: true);
    await _service.delete(id);
    _load();
    if (isCloudEnabled && deletedNote != null) {
      unawaited(_cloudSync.save(deletedNote));
    }
  }

  Future<void> toggleFavorite(String id) async {
    final note = _service.getById(id);
    if (note == null) {
      return;
    }
    final updated = note.copyWith(isFavorite: !note.isFavorite);
    await update(updated);
  }

  Future<void> moveOutOfFolder(String folderId) async {
    final notes = _service.getAll(includeDeleted: true)
        .where((note) => note.folderId == folderId)
        .map((note) => note.copyWith(clearFolderId: true))
        .toList();
    await _service.moveNotesOutOfFolder(folderId);
    _load();
    if (isCloudEnabled) {
      for (final note in notes) {
        unawaited(_cloudSync.save(note));
      }
    }
  }

  Future<void> importAll(List<Note> notes) async {
    await _service.saveAll(notes);
    _load();
    if (isCloudEnabled) {
      for (final note in notes) {
        unawaited(_cloudSync.save(note));
      }
    }
  }

  @override
  void dispose() {
    _cloudSubscription?.cancel();
    super.dispose();
  }
}
