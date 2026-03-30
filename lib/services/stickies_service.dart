import 'package:hive_flutter/hive_flutter.dart';
import '../models/sticky.dart';

class StickiesService {
  static const _boxName = 'stickies';

  Future<void> init() async {
    await Hive.openBox<Map>(_boxName);
  }

  Box<Map> get _box => Hive.box<Map>(_boxName);

  List<Sticky> getAll() {
    return _box.values
        .map((e) => Sticky.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> save(Sticky sticky) async {
    await _box.put(sticky.id, sticky.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}