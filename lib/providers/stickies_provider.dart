import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sticky.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/stickies_service.dart';

final stickiesServiceProvider = Provider((ref) => StickiesService());

final stickiesProvider = StateNotifierProvider<StickiesNotifier, List<Sticky>>((
  ref,
) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return StickiesNotifier(
    ref.read(stickiesServiceProvider),
    ref.read(stickiesCloudSyncServiceProvider),
    isCloudEnabled: user != null,
  );
});

class StickiesNotifier extends StateNotifier<List<Sticky>> {
  final StickiesService _service;
  final StickiesCloudSyncService _cloudSync;
  final bool isCloudEnabled;
  StreamSubscription<List<Sticky>>? _cloudSubscription;

  StickiesNotifier(
    this._service,
    this._cloudSync, {
    required this.isCloudEnabled,
  }) : super([]) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _expireOldStickies();
    _load();
    if (!isCloudEnabled) {
      return;
    }
    await _cloudSync.pushLocalSnapshot(_service.getAll(includeDeleted: true));
    _cloudSubscription = _cloudSync.watch().listen((remoteStickies) async {
      await _service.saveAll(remoteStickies);
      _load();
    });
  }

  void _load() {
    state = _service.getAll();
  }

  Future<void> _expireOldStickies() async {
    final now = DateTime.now();
    final expired = _service
        .getAll(includeDeleted: true)
        .where(
          (sticky) =>
              !sticky.isDeleted &&
              sticky.expiresAt != null &&
              !sticky.expiresAt!.isAfter(now),
        )
        .toList();
    if (expired.isEmpty) {
      return;
    }
    for (final sticky in expired) {
      final deleted = sticky.copyWith(isDeleted: true);
      await _service.save(deleted);
      if (isCloudEnabled) {
        unawaited(_cloudSync.save(deleted));
      }
    }
  }

  Future<void> add({
    String title = '',
    String body = '',
    Color color = Colors.yellow,
    String? boardId,
    String? linkedNoteId,
    String? linkedNoteTitle,
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
      size: size,
      checklistMode: checklistMode,
      checklistItems: checklistItems,
      expiresAt: expiresAt,
      isPinned: isPinned,
      sortOrder: _service.nextSortOrder(boardId: boardId),
      updatedAt: now,
      deviceUpdatedAt: now,
    );
    await _service.save(sticky);
    _load();
    if (isCloudEnabled) {
      unawaited(_cloudSync.save(sticky));
    }
  }

  Future<void> update(Sticky sticky) async {
    await _service.save(sticky);
    _load();
    if (isCloudEnabled) {
      unawaited(_cloudSync.save(sticky));
    }
  }

  Future<void> delete(String id) async {
    final deletedSticky = _service.getById(id)?.copyWith(isDeleted: true);
    await _service.delete(id);
    _load();
    if (isCloudEnabled && deletedSticky != null) {
      unawaited(_cloudSync.save(deletedSticky));
    }
  }

  Future<void> moveOutOfBoard(String boardId) async {
    final stickies = _service.getAll(includeDeleted: true)
        .where((sticky) => sticky.boardId == boardId)
        .map((sticky) => sticky.copyWith(clearBoardId: true))
        .toList();
    await _service.moveStickiesOutOfBoard(boardId);
    _load();
    if (isCloudEnabled) {
      for (final sticky in stickies) {
        unawaited(_cloudSync.save(sticky));
      }
    }
  }

  Future<void> togglePinned(String id) async {
    final sticky = _service.getById(id);
    if (sticky == null) return;
    await update(sticky.copyWith(isPinned: !sticky.isPinned));
  }

  Future<void> importAll(List<Sticky> stickies) async {
    await _service.saveAll(stickies);
    _load();
    if (isCloudEnabled) {
      for (final sticky in stickies) {
        unawaited(_cloudSync.save(sticky));
      }
    }
  }

  Future<void> reorder({
    required String? boardId,
    required List<String> orderedIds,
  }) async {
    final relevant = _service
        .getAll(includeDeleted: true)
        .where((sticky) => sticky.boardId == boardId && !sticky.isDeleted)
        .toList();
    if (relevant.isEmpty) {
      return;
    }

    for (var index = 0; index < orderedIds.length; index++) {
      Sticky? sticky;
      for (final item in relevant) {
        if (item.id == orderedIds[index]) {
          sticky = item;
          break;
        }
      }
      if (sticky == null) continue;
      final updated = sticky.copyWith(sortOrder: index);
      await _service.save(updated);
      if (isCloudEnabled) {
        unawaited(_cloudSync.save(updated));
      }
    }
    _load();
  }

  Future<void> toggleChecklistItem(
    String stickyId,
    String itemId,
  ) async {
    final sticky = _service.getById(stickyId);
    if (sticky == null) return;
    final updatedItems = sticky.checklistItems
        .map(
          (item) => item.id == itemId
              ? item.copyWith(isDone: !item.isDone)
              : item,
        )
        .toList();
    await update(sticky.copyWith(checklistItems: updatedItems));
  }

  Future<void> pinAllInBoard(String? boardId) async {
    final targets = _service
        .getAll(includeDeleted: true)
        .where((sticky) => sticky.boardId == boardId && !sticky.isDeleted)
        .toList();
    for (final sticky in targets) {
      final updated = sticky.copyWith(isPinned: true);
      await _service.save(updated);
      if (isCloudEnabled) {
        unawaited(_cloudSync.save(updated));
      }
    }
    _load();
  }

  Future<void> clearCompletedChecklistItems(String? boardId) async {
    final targets = _service
        .getAll(includeDeleted: true)
        .where(
          (sticky) =>
              sticky.boardId == boardId &&
              sticky.checklistMode &&
              sticky.checklistItems.any((item) => item.isDone),
        )
        .toList();
    for (final sticky in targets) {
      final updated = sticky.copyWith(
        checklistItems: sticky.checklistItems
            .where((item) => !item.isDone)
            .toList(),
      );
      await _service.save(updated);
      if (isCloudEnabled) {
        unawaited(_cloudSync.save(updated));
      }
    }
    _load();
  }

  @override
  void dispose() {
    _cloudSubscription?.cancel();
    super.dispose();
  }
}
