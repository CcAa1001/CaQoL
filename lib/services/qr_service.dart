import 'package:hive_flutter/hive_flutter.dart';

class QrService {
  static const _boxName = 'qr_codes';
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  Map<String, String> getAll() {
    final map = <String, String>{};
    for (final key in _box.keys) {
      map[key.toString()] = _box.get(key)!;
    }
    return map;
  }

  Future<void> save(String name, String code) async {
    await _box.put(name, code);
  }

  Future<void> delete(String name) async {
    await _box.delete(name);
  }
}
