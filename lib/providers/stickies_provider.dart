import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sticky.dart';
import '../services/auth_service.dart';

final stickiesProvider = StateNotifierProvider<StickiesNotifier, List<Sticky>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return StickiesNotifier(userId: user?.uid);
});

class StickiesNotifier extends StateNotifier<List<Sticky>> {
  final String? userId;
  StreamSubscription<QuerySnapshot>? _subscription;

  StickiesNotifier({required this.userId}) : super([]) {
    _init();
  }

  void _init() {
    if (userId == null) return;
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('stickies')
        .snapshots()
        .listen((snapshot) {
      final stickies = snapshot.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          data['title'] = data['title'] ?? '';
          data['body'] = data['body'] ?? '';
          data['isDeleted'] = data['isDeleted'] ?? false;
          
          final nowIso = DateTime.now().toIso8601String();
          if (data['createdAt'] is Timestamp) data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
          else if (data['createdAt'] == null) data['createdAt'] = nowIso;
          
          if (data['updatedAt'] is Timestamp) data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
          else if (data['updatedAt'] == null) data['updatedAt'] = nowIso;
          
          if (data['deviceUpdatedAt'] is Timestamp) data['deviceUpdatedAt'] = (data['deviceUpdatedAt'] as Timestamp).toDate().toIso8601String();
          else if (data['deviceUpdatedAt'] == null) data['deviceUpdatedAt'] = data['updatedAt'] ?? nowIso;
          
          if (data['expiresAt'] is Timestamp) data['expiresAt'] = (data['expiresAt'] as Timestamp).toDate().toIso8601String();
          
          return Sticky.fromJson(data);
        } catch (e) {
          print('Error parsing sticky: $e');
          return null;
        }
      }).whereType<Sticky>().where((s) => !s.isDeleted).toList();
      
      stickies.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = stickies;
      _expireOldStickies(stickies);
    });
  }

  CollectionReference get _collection {
    if (userId == null) throw Exception('User not logged in');
    return FirebaseFirestore.instance.collection('users').doc(userId).collection('stickies');
  }

  Future<void> _expireOldStickies(List<Sticky> currentStickies) async {
    final now = DateTime.now();
    final expired = currentStickies.where(
      (sticky) => sticky.expiresAt != null && !sticky.expiresAt!.isAfter(now),
    ).toList();
    
    if (expired.isEmpty) return;
    
    final batch = FirebaseFirestore.instance.batch();
    for (final sticky in expired) {
      batch.update(_collection.doc(sticky.id), {'isDeleted': true});
    }
    await batch.commit();
  }

  Future<void> add({
    String title = '',
    String body = '',
    Color color = Colors.yellow,
    String? boardId,
    String? linkedNoteId,
    String? linkedNoteTitle,
    String stickyType = 'text',
    String? sourceName,
    String? sourcePath,
    String lane = 'Inbox',
    String? liveUrl,
    int liveRefreshMinutes = 5,
    DateTime? liveRefreshedAt,
    String size = 'medium',
    bool checklistMode = false,
    List<StickyChecklistItem> checklistItems = const [],
    DateTime? expiresAt,
    bool isPinned = false,
  }) async {
    final now = DateTime.now();
    final sticky = Sticky(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      color: color,
      boardId: boardId,
      linkedNoteId: linkedNoteId,
      linkedNoteTitle: linkedNoteTitle,
      stickyType: stickyType,
      sourceName: sourceName,
      sourcePath: sourcePath,
      lane: lane,
      liveUrl: liveUrl,
      liveRefreshMinutes: liveRefreshMinutes,
      liveRefreshedAt: liveRefreshedAt,
      size: size,
      checklistMode: checklistMode,
      checklistItems: checklistItems,
      expiresAt: expiresAt,
      isPinned: isPinned,
      sortOrder: 0,
      updatedAt: now,
      deviceUpdatedAt: now,
    );
    await _collection.doc(sticky.id).set(sticky.toJson());
  }

  Future<void> update(Sticky sticky) async {
    final updated = sticky.copyWith(
      updatedAt: DateTime.now(),
      deviceUpdatedAt: DateTime.now(),
    );
    await _collection.doc(sticky.id).set(updated.toJson());
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).update({
      'isDeleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
      'deviceUpdatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> moveOutOfBoard(String boardId) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final sticky in state.where((s) => s.boardId == boardId)) {
      final updated = sticky.copyWithClearBoard(clearBoardId: true);
      batch.set(_collection.doc(sticky.id), updated.toJson());
    }
    await batch.commit();
  }

  Future<void> togglePinned(String id) async {
    try {
      final sticky = state.firstWhere((s) => s.id == id);
      await update(sticky.copyWith(isPinned: !sticky.isPinned));
    } catch (_) {}
  }

  Future<void> importAll(List<Sticky> stickies) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final sticky in stickies) {
      batch.set(_collection.doc(sticky.id), sticky.toJson());
    }
    await batch.commit();
  }

  Future<void> reorder({
    required String? boardId,
    required List<String> orderedIds,
  }) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var i = 0; i < orderedIds.length; i++) {
      final id = orderedIds[i];
      try {
        final sticky = state.firstWhere((s) => s.id == id);
        final updated = sticky.copyWith(sortOrder: i);
        batch.set(_collection.doc(id), updated.toJson());
      } catch (_) {}
    }
    await batch.commit();
  }

  Future<void> toggleChecklistItem(
    String stickyId,
    String itemId,
  ) async {
    try {
      final sticky = state.firstWhere((s) => s.id == stickyId);
      final updatedItems = sticky.checklistItems.map((item) {
        return item.id == itemId ? item.copyWith(isDone: !item.isDone) : item;
      }).toList();
      await update(sticky.copyWith(checklistItems: updatedItems));
    } catch (_) {}
  }

  Future<void> refreshLiveSticky(
    String stickyId, {
    required String snapshot,
    required DateTime refreshedAt,
  }) async {
    try {
      final sticky = state.firstWhere((s) => s.id == stickyId);
      if (sticky.stickyType != 'live') return;
      await update(
        sticky.copyWith(
          body: snapshot,
          liveRefreshedAt: refreshedAt,
        ),
      );
    } catch (_) {}
  }

  Future<void> pinAllInBoard(String? boardId) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final sticky in state.where((s) => s.boardId == boardId)) {
      final updated = sticky.copyWith(isPinned: true);
      batch.set(_collection.doc(sticky.id), updated.toJson());
    }
    await batch.commit();
  }

  Future<void> clearCompletedChecklistItems(String? boardId) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final sticky in state.where((s) => s.boardId == boardId && s.checklistMode)) {
      if (sticky.checklistItems.any((item) => item.isDone)) {
        final updated = sticky.copyWith(
          checklistItems: sticky.checklistItems.where((item) => !item.isDone).toList(),
        );
        batch.set(_collection.doc(sticky.id), updated.toJson());
      }
    }
    await batch.commit();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
