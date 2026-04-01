import 'package:hive_flutter/hive_flutter.dart';

import '../models/sticky_board.dart';

class StickyBoardsService {
  static const _boxName = 'sticky_boards';

  Future<void> init() async {
    await Hive.openBox<Map>(_boxName);
  }

  Box<Map> get _box => Hive.box<Map>(_boxName);

  List<StickyBoard> getAll({bool includeDeleted = false}) {
    final boards = <StickyBoard>[];
    for (final raw in _box.values) {
      try {
        final board = StickyBoard.fromMap(Map<String, dynamic>.from(raw));
        if (includeDeleted || !board.isDeleted) {
          boards.add(board);
        }
      } catch (_) {}
    }
    boards.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return boards;
  }

  StickyBoard? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) {
      return null;
    }
    try {
      return StickyBoard.fromMap(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> save(StickyBoard board) async {
    await _box.put(board.id, board.toMap());
  }

  Future<void> saveAll(Iterable<StickyBoard> boards) async {
    for (final board in boards) {
      await save(board);
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
