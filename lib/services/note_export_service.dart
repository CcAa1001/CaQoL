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
      'folders': folders.map((folder) => folder.toMap()).toList(),
      'notes': notes.map((note) => note.toMap()).toList(),
    };

    return saveNotesExport(
      jsonEncode(payload),
      filename:
          'caqol_notes_${DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-')}.json',
    );
  }
}
