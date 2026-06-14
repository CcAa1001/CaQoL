import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sticky_board.dart';
import '../services/auth_service.dart';

final stickyBoardsProvider = StateNotifierProvider<StickyBoardsNotifier, List<StickyBoard>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return StickyBoardsNotifier(userId: user?.uid);
});

class StickyBoardsNotifier extends StateNotifier<List<StickyBoard>> {
  final String? userId;
  StreamSubscription<QuerySnapshot>? _subscription;

  StickyBoardsNotifier({required this.userId}) : super([]) {
    _init();
  }

  void _init() {
    if (userId == null) return;
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('sticky_boards')
        .snapshots()
        .listen((snapshot) {
      final boards = snapshot.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          data['name'] = data['name'] ?? 'Board';
          data['isDeleted'] = data['isDeleted'] ?? false;
          
          final nowIso = DateTime.now().toIso8601String();
          if (data['createdAt'] is Timestamp) data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
          else if (data['createdAt'] == null) data['createdAt'] = nowIso;
          
          if (data['updatedAt'] is Timestamp) data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
          else if (data['updatedAt'] == null) data['updatedAt'] = nowIso;
          
          if (data['deviceUpdatedAt'] is Timestamp) data['deviceUpdatedAt'] = (data['deviceUpdatedAt'] as Timestamp).toDate().toIso8601String();
          else if (data['deviceUpdatedAt'] == null) data['deviceUpdatedAt'] = data['updatedAt'] ?? nowIso;
          
          return StickyBoard.fromJson(data);
        } catch (e) {
          print('Error parsing sticky board: $e');
          return null;
        }
      }).whereType<StickyBoard>().where((b) => !b.isDeleted).toList();
      
      boards.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = boards;
    });
  }

  CollectionReference get _collection {
    if (userId == null) throw Exception('User not logged in');
    return FirebaseFirestore.instance.collection('users').doc(userId).collection('sticky_boards');
  }

  Future<StickyBoard> add(String name) async {
    final now = DateTime.now();
    final board = StickyBoard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: now,
      updatedAt: now,
      deviceUpdatedAt: now,
    );
    await _collection.doc(board.id).set(board.toJson());
    return board;
  }

  Future<void> update(StickyBoard board) async {
    final updated = board.copyWith(
      updatedAt: DateTime.now(),
      deviceUpdatedAt: DateTime.now(),
    );
    await _collection.doc(board.id).set(updated.toJson());
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).update({
      'isDeleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
      'deviceUpdatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> setViewMode(String id, String mode) async {
    try {
      final board = state.firstWhere((b) => b.id == id);
      await update(board.copyWith(viewMode: mode));
    } catch (_) {}
  }

  Future<void> importAll(List<StickyBoard> boards) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final board in boards) {
      batch.set(_collection.doc(board.id), board.toJson());
    }
    await batch.commit();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
