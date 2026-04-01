import 'package:hive_flutter/hive_flutter.dart';
import '../models/sticky.dart';

class StickiesService {
  static const _boxName = 'stickies';

  Future<void> init() async {
    await Hive.openBox<Map>(_boxName);
  }

  Box<Map> get _box => Hive.box<Map>(_boxName);

  List<Sticky> getAll({bool includeDeleted = false}) {
    final stickies = <Sticky>[];
    for (final raw in _box.values) {
      try {
        final sticky = Sticky.fromMap(Map<String, dynamic>.from(raw));
        if (includeDeleted || !sticky.isDeleted) {
          stickies.add(sticky);
        }
      } catch (_) {
        // Skip corrupt legacy entries instead of breaking the whole board.
      }
    }
    return stickies
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        final orderCompare = a.sortOrder.compareTo(b.sortOrder);
        if (orderCompare != 0) {
          return orderCompare;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });
  }

  Sticky? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) {
      return null;
    }
    try {
      return Sticky.fromMap(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Sticky sticky) async {
    await _box.put(sticky.id, sticky.toMap());
  }

  Future<void> saveAll(Iterable<Sticky> stickies) async {
    for (final sticky in stickies) {
      await save(sticky);
    }
  }

  Future<void> delete(String id) async {
    final existing = getById(id);
    if (existing == null) {
      return;
    }
    final now = DateTime.now();
    await save(
      existing.copyWith(updatedAt: now, deviceUpdatedAt: now, isDeleted: true),
    );
  }

  Future<void> moveStickiesOutOfBoard(String boardId) async {
    final stickies = getAll(includeDeleted: true)
        .where((sticky) => sticky.boardId == boardId)
        .toList();
    for (final sticky in stickies) {
      await save(sticky.copyWith(clearBoardId: true));
    }
  }

  int nextSortOrder({String? boardId}) {
    final relevant = getAll(includeDeleted: true)
        .where((sticky) => sticky.boardId == boardId)
        .toList();
    if (relevant.isEmpty) {
      return 0;
    }
    return relevant.map((sticky) => sticky.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }
}
