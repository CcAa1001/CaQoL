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

    final foldersRaw = raw['folders'];
    final notesRaw = raw['notes'];
    if (foldersRaw is! List || notesRaw is! List) {
      throw const FormatException('Backup is missing folders or notes.');
    }

    return NoteImportPayload(
      folders: foldersRaw
          .map((item) => NoteFolder.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      notes: notesRaw
          .map((item) => Note.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}
