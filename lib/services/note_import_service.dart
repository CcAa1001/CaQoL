import 'dart:convert';

import 'package:file_picker/file_picker.dart';

import '../models/note.dart';
import '../models/note_folder.dart';

class NoteImportPayload {
  final List<NoteFolder> folders;
  final List<Note> notes;

  const NoteImportPayload({
    required this.folders,
    required this.notes,
  });
}

class NoteImportService {
  Future<NoteImportPayload?> pickAndParse() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) {
      return null;
    }

    String? content;
    if (file.bytes != null) {
      content = utf8.decode(file.bytes!);
    }

    content ??= file.xFile == null ? null : await file.xFile!.readAsString();
    if (content == null || content.trim().isEmpty) {
      throw const FormatException('Selected file is empty.');
    }

    final raw = jsonDecode(content);
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup format.');
    }

    final rawFolders = raw['folders'] as List? ?? [];
    final parsedFolders = rawFolders
        .whereType<Map>()
        .map((m) => NoteFolder.fromJson(Map<String, dynamic>.from(m)))
        .toList();

    final rawNotes = raw['notes'] as List? ?? [];
    final parsedNotes = rawNotes
        .whereType<Map>()
        .map((m) => Note.fromJson(Map<String, dynamic>.from(m)))
        .toList();

    return NoteImportPayload(
      folders: parsedFolders,
      notes: parsedNotes,
    );
  }
}
