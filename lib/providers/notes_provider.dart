import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../services/auth_service.dart';

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return NotesNotifier(userId: user?.uid);
});

class NotesNotifier extends StateNotifier<List<Note>> {
  final String? userId;
  StreamSubscription<QuerySnapshot>? _subscription;

  NotesNotifier({required this.userId}) : super([]) {
    _init();
  }

  void _init() {
    if (userId == null) return;
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes')
        .snapshots()
        .listen((snapshot) {
      final notes = snapshot.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          data['title'] = data['title'] ?? 'Untitled';
          data['body'] = data['body'] ?? '';
          data['isDeleted'] = data['isDeleted'] ?? false;
          
          final nowIso = DateTime.now().toIso8601String();
          if (data['createdAt'] is Timestamp) data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
          else if (data['createdAt'] == null) data['createdAt'] = nowIso;
          
          if (data['updatedAt'] is Timestamp) data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
          else if (data['updatedAt'] == null) data['updatedAt'] = nowIso;
          
          if (data['deviceUpdatedAt'] is Timestamp) data['deviceUpdatedAt'] = (data['deviceUpdatedAt'] as Timestamp).toDate().toIso8601String();
          else if (data['deviceUpdatedAt'] == null) data['deviceUpdatedAt'] = data['updatedAt'] ?? nowIso;
          
          return Note.fromJson(data);
        } catch (e) {
          print('Error parsing note: $e');
          return null;
        }
      }).whereType<Note>().where((n) => !n.isDeleted).toList();
      
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = notes;
    });
  }

  CollectionReference get _collection {
    if (userId == null) throw Exception('User not logged in');
    return FirebaseFirestore.instance.collection('users').doc(userId).collection('notes');
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
      sortOrder: 0,
      isFavorite: isFavorite,
      tags: tags,
      createdAt: now,
      updatedAt: now,
      deviceUpdatedAt: now,
    );
    await _collection.doc(note.id).set(note.toJson());
    return note;
  }

  Future<void> update(Note note) async {
    final updated = note.copyWith(
      updatedAt: DateTime.now(),
      deviceUpdatedAt: DateTime.now(),
    );
    await _collection.doc(note.id).set(updated.toJson());
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).update({
      'isDeleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
      'deviceUpdatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> toggleFavorite(String id) async {
    final note = state.firstWhere((n) => n.id == id);
    await update(note.copyWith(isFavorite: !note.isFavorite));
  }

  Future<void> moveOutOfFolder(String folderId) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final note in state.where((n) => n.folderId == folderId)) {
      final updated = note.copyWithClearFolder(clearFolderId: true);
      batch.set(_collection.doc(note.id), updated.toJson());
    }
    await batch.commit();
  }

  Future<void> importAll(List<Note> notes) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final note in notes) {
      batch.set(_collection.doc(note.id), note.toJson());
    }
    await batch.commit();
  }

  Future<void> moveToFolder(String id, String? folderId) async {
    final note = state.firstWhere((n) => n.id == id);
    final updated = note.copyWithClearFolder(
      folderId: folderId,
      clearFolderId: folderId == null,
    );
    await update(updated);
  }

  Future<void> reorder({
    required String? folderId,
    required List<String> orderedIds,
  }) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var i = 0; i < orderedIds.length; i++) {
      final id = orderedIds[i];
      try {
        final note = state.firstWhere((n) => n.id == id);
        final updated = note.copyWith(sortOrder: i);
        batch.set(_collection.doc(id), updated.toJson());
      } catch (_) {}
    }
    await batch.commit();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
