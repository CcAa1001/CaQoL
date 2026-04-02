import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sticky_board.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/sticky_boards_service.dart';

final stickyBoardsServiceProvider = Provider((ref) => StickyBoardsService());

final stickyBoardsProvider =
    StateNotifierProvider<StickyBoardsNotifier, List<StickyBoard>>((ref) {
      final user = ref.watch(authStateProvider).valueOrNull;
      return StickyBoardsNotifier(
        ref.read(stickyBoardsServiceProvider),
        ref.read(stickyBoardsCloudSyncServiceProvider),
        isCloudEnabled: user != null,
      );
    });

class StickyBoardsNotifier extends StateNotifier<List<StickyBoard>> {
  StickyBoardsNotifier(
    this._service,
    this._cloudSync, {
    required this.isCloudEnabled,
  }) : super([]) {
    _initialize();
  }

  final StickyBoardsService _service;
  final StickyBoardsCloudSyncService _cloudSync;
  final bool isCloudEnabled;
  StreamSubscription<List<StickyBoard>>? _cloudSubscription;

  Future<void> _initialize() async {
    _load();
    if (!isCloudEnabled) return;

    await _cloudSync.pushLocalSnapshot(_service.getAll(includeDeleted: true));
    _cloudSubscription = _cloudSync.watch().listen((remoteBoards) async {
      final locals = _service.getAll(includeDeleted: true);
      final localById = {for (var b in locals) b.id: b};
      final toSave = <StickyBoard>[];
      for (final remote in remoteBoards) {
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

  Future<void> add(String name) async {
    final now = DateTime.now();
    final board = StickyBoard(
      id: now.microsecondsSinceEpoch.toString(),
      name: name.trim(),
      createdAt: now,
      updatedAt: now,
      deviceUpdatedAt: now,
    );
    await _service.save(board);
    _load();
    if (isCloudEnabled) {
      unawaited(_cloudSync.save(board));
    }
  }

  Future<void> update(StickyBoard board) async {
    await _service.save(board);
    _load();
    if (isCloudEnabled) {
      unawaited(_cloudSync.save(board));
    }
  }

  Future<void> delete(String id) async {
    final deleted = _service.getById(id)?.copyWith(isDeleted: true);
    await _service.delete(id);
    _load();
    if (isCloudEnabled && deleted != null) {
      unawaited(_cloudSync.save(deleted));
    }
  }

  Future<void> importAll(List<StickyBoard> boards) async {
    await _service.saveAll(boards);
    _load();
    if (isCloudEnabled) {
      for (final board in boards) {
        unawaited(_cloudSync.save(board));
      }
    }
  }

  @override
  void dispose() {
    _cloudSubscription?.cancel();
    super.dispose();
  }
}
