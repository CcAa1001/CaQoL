import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/note_folder.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/note_folders_service.dart';

final noteFoldersServiceProvider = Provider((ref) => NoteFoldersService());

final noteFoldersProvider =
    StateNotifierProvider<NoteFoldersNotifier, List<NoteFolder>>((ref) {
      final user = ref.watch(authStateProvider).valueOrNull;
      return NoteFoldersNotifier(
        ref.read(noteFoldersServiceProvider),
        ref.read(noteFoldersCloudSyncServiceProvider),
        isCloudEnabled: user != null,
      );
    });

class NoteFoldersNotifier extends StateNotifier<List<NoteFolder>> {
  NoteFoldersNotifier(
    this._service,
    this._cloudSync, {
    required this.isCloudEnabled,
  }) : super([]) {
    _initialize();
  }

  final NoteFoldersService _service;
  final NoteFoldersCloudSyncService _cloudSync;
  final bool isCloudEnabled;
  StreamSubscription<List<NoteFolder>>? _cloudSubscription;

  Future<void> _initialize() async {
    _load();
    if (!isCloudEnabled) {
      return;
    }
    await _cloudSync.pushLocalSnapshot(_service.getAll(includeDeleted: true));
    _cloudSubscription = _cloudSync.watch().listen((remoteFolders) async {
      await _service.saveAll(remoteFolders);
      _load();
    });
  }

  void _load() {
    state = _service.getAll();
  }

  Future<void> add(String name, {String? parentId}) async {
    final now = DateTime.now();
    final folder = NoteFolder(
      id: now.microsecondsSinceEpoch.toString(),
      name: name.trim(),
      parentId: parentId,
      createdAt: now,
      updatedAt: now,
      deviceUpdatedAt: now,
    );
    await _service.save(folder);
    _load();
    if (isCloudEnabled) {
      unawaited(_cloudSync.save(folder));
    }
  }

  Future<void> update(NoteFolder folder) async {
    await _service.save(folder);
    _load();
    if (isCloudEnabled) {
      unawaited(_cloudSync.save(folder));
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

  Future<void> importAll(List<NoteFolder> folders) async {
    await _service.saveAll(folders);
    _load();
    if (isCloudEnabled) {
      for (final folder in folders) {
        unawaited(_cloudSync.save(folder));
      }
    }
  }

  @override
  void dispose() {
    _cloudSubscription?.cancel();
    super.dispose();
  }
}
