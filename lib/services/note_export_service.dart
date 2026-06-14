import 'dart:convert';

import '../models/note.dart';
import '../models/note_folder.dart';
import 'note_export_service_impl.dart'
    if (dart.library.html) 'note_export_service_web.dart'
    if (dart.library.io) 'note_export_service_io.dart';

class NoteExportService {
  Future<String> exportAll({
    required List<NoteFolder> folders,
    required List<Note> notes,
  }) {
    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'folders': folders.map((f) => f.toJson()).toList(),
      'notes': notes.map((n) => n.toJson()).toList(),
    };

    return saveNotesExport(
      jsonEncode(payload),
      filename:
          'caqol_notes_${DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-')}.json',
    );
  }

  Future<String> exportCompiledDocument({
    required String title,
    required String content,
  }) {
    final safeTitle = title
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
    return saveNotesExport(
      content,
      filename:
          '${safeTitle.isEmpty ? 'caqol_manuscript' : safeTitle}_${DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-')}.txt',
    );
  }
}
