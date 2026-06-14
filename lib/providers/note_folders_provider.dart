import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_folder.dart';
import '../services/auth_service.dart';

final noteFoldersProvider = StateNotifierProvider<NoteFoldersNotifier, List<NoteFolder>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return NoteFoldersNotifier(userId: user?.uid);
});

class NoteFoldersNotifier extends StateNotifier<List<NoteFolder>> {
  final String? userId;
  StreamSubscription<QuerySnapshot>? _subscription;

  NoteFoldersNotifier({required this.userId}) : super([]) {
    _init();
  }

  void _init() {
    if (userId == null) return;
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('folders')
        .snapshots()
        .listen((snapshot) {
      final folders = snapshot.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          data['name'] = data['name'] ?? 'Untitled folder';
          data['isDeleted'] = data['isDeleted'] ?? false;
          
          final nowIso = DateTime.now().toIso8601String();
          if (data['createdAt'] is Timestamp) data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
          else if (data['createdAt'] == null) data['createdAt'] = nowIso;
          
          if (data['updatedAt'] is Timestamp) data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
          else if (data['updatedAt'] == null) data['updatedAt'] = nowIso;
          
          if (data['deviceUpdatedAt'] is Timestamp) data['deviceUpdatedAt'] = (data['deviceUpdatedAt'] as Timestamp).toDate().toIso8601String();
          else if (data['deviceUpdatedAt'] == null) data['deviceUpdatedAt'] = data['updatedAt'] ?? nowIso;
          
          return NoteFolder.fromJson(data);
        } catch (e) {
          print('Error parsing note folder: $e');
          return null;
        }
      }).whereType<NoteFolder>().where((f) => !f.isDeleted).toList();
      
      folders.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = folders;
    });
  }

  CollectionReference get _collection {
    if (userId == null) throw Exception('User not logged in');
    return FirebaseFirestore.instance.collection('users').doc(userId).collection('folders');
  }

  Future<NoteFolder> add(
    String name, {
    String? parentId,
  }) async {
    final now = DateTime.now();
    final folder = NoteFolder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      parentId: parentId,
      createdAt: now,
      updatedAt: now,
      deviceUpdatedAt: now,
    );
    await _collection.doc(folder.id).set(folder.toJson());
    return folder;
  }

  Future<void> update(NoteFolder folder) async {
    final updated = folder.copyWith(
      updatedAt: DateTime.now(),
      deviceUpdatedAt: DateTime.now(),
    );
    await _collection.doc(folder.id).set(updated.toJson());
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).update({
      'isDeleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
      'deviceUpdatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> importAll(List<NoteFolder> folders) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final folder in folders) {
      batch.set(_collection.doc(folder.id), folder.toJson());
    }
    await batch.commit();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
