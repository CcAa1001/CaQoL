import 'package:hive_flutter/hive_flutter.dart';

import '../models/sticky_board.dart';

class StickyBoardsService {
  static const _boxName = 'sticky_boards';

  Future<void> init() async {
    await Hive.openBox<Map>(_boxName);
  }

  Box<Map> get _box => Hive.box<Map>(_boxName);

  List<StickyBoard> getAll({bool includeDeleted = false}) {
    return _box.values
        .map((e) => StickyBoard.fromMap(Map<String, dynamic>.from(e)))
        .where((board) => includeDeleted || !board.isDeleted)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  StickyBoard? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) {
      return null;
    }
    return StickyBoard.fromMap(Map<String, dynamic>.from(raw));
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
