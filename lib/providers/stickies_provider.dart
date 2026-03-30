import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sticky.dart';
import '../services/stickies_service.dart';

final stickiesServiceProvider = Provider((ref) => StickiesService());

final stickiesProvider = StateNotifierProvider<StickiesNotifier, List<Sticky>>((ref) {
  return StickiesNotifier(ref.read(stickiesServiceProvider));
});

class StickiesNotifier extends StateNotifier<List<Sticky>> {
  final StickiesService _service;

  StickiesNotifier(this._service) : super([]) {
    _load();
  }

  void _load() {
    state = _service.getAll();
  }

  Future<void> add({String body = '', Color color = Colors.yellow}) async {
    final sticky = Sticky(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      body: body,
      color: color,
      updatedAt: DateTime.now(),
    );
    await _service.save(sticky);
    _load();
  }

  Future<void> update(Sticky sticky) async {
    await _service.save(sticky);
    _load();
  }

  Future<void> delete(String id) async {
    await _service.delete(id);
    _load();
  }
}