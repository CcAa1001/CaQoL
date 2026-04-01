import 'dart:convert';

import 'package:file_picker/file_picker.dart';

import '../models/sticky.dart';
import '../models/sticky_board.dart';
import 'note_export_service_impl.dart'
    if (dart.library.html) 'note_export_service_web.dart'
    if (dart.library.io) 'note_export_service_io.dart';

class StickyImportPayload {
  final List<StickyBoard> boards;
  final List<Sticky> stickies;

  const StickyImportPayload({
    required this.boards,
    required this.stickies,
  });
}

class StickyBackupService {
  Future<String> exportAll({
    required List<StickyBoard> boards,
    required List<Sticky> stickies,
  }) {
    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'boards': boards.map((board) => board.toMap()).toList(),
      'stickies': stickies.map((sticky) => sticky.toMap()).toList(),
    };

    return saveNotesExport(
      jsonEncode(payload),
      filename:
          'caqol_stickies_${DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-')}.json',
    );
  }

  Future<StickyImportPayload?> pickAndParse() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) return null;

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

    final boardsRaw = raw['boards'];
    final stickiesRaw = raw['stickies'];
    if (boardsRaw is! List || stickiesRaw is! List) {
      throw const FormatException('Backup is missing boards or stickies.');
    }

    return StickyImportPayload(
      boards: boardsRaw
          .map((item) => StickyBoard.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      stickies: stickiesRaw
          .map((item) => Sticky.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}
