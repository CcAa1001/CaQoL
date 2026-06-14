import 'package:flutter/material.dart';

import '../../models/note.dart';
import '../../models/note_folder.dart';
import '../../services/note_export_service.dart';
import '../../services/note_links_service.dart';
import '../../theme/app_theme.dart';

class CompiledNoteSection {
  const CompiledNoteSection({
    required this.note,
    required this.folderPath,
  });

  final Note note;
  final String folderPath;
}

class NoteCompileScreen extends StatelessWidget {
  const NoteCompileScreen({
    super.key,
    required this.folder,
    required this.sections,
  });

  final NoteFolder folder;
  final List<CompiledNoteSection> sections;

  String _compiledText() {
    final buffer = StringBuffer();
    buffer.writeln(folder.name);
    buffer.writeln('=' * folder.name.length);
    buffer.writeln();
    final linksService = NoteLinksService();
    for (var index = 0; index < sections.length; index++) {
      final section = sections[index];
      buffer.writeln(section.note.title);
      buffer.writeln('-' * section.note.title.length);
      if (section.folderPath.isNotEmpty && section.folderPath != folder.name) {
        buffer.writeln('Folder: ${section.folderPath}');
        buffer.writeln();
      }
      final body = linksService.plainText(section.note.body).trimRight();
      buffer.writeln(body.isEmpty ? '(Empty note)' : body);
      if (index < sections.length - 1) {
        buffer.writeln();
        buffer.writeln();
      }
    }
    return buffer.toString().trimRight();
  }

  @override
  Widget build(BuildContext context) {
    final compiledText = _compiledText();
    return Scaffold(
      appBar: AppBar(
        title: Text('Compile: ${folder.name}'),
        actions: [
          IconButton(
            tooltip: 'Export manuscript',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                final result = await NoteExportService().exportCompiledDocument(
                  title: folder.name,
                  content: compiledText,
                );
                if (!context.mounted) return;
                messenger.showSnackBar(SnackBar(content: Text(result)));
              } catch (error) {
                if (!context.mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text('Export failed: $error')),
                );
              }
            },
            icon: const Icon(Icons.download_rounded),
          ),
        ],
      ),
      body: sections.isEmpty
          ? const Center(
              child: Text(
                'No notes found in this folder yet.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: sections.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          folder.name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${sections.length} note${sections.length == 1 ? '' : 's'} stitched into one continuous manuscript view.',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final section = sections[index - 1];
                final text = NoteLinksService().plainText(section.note.body).trim();
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.note.title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (section.folderPath.isNotEmpty &&
                          section.folderPath != folder.name) ...[
                        const SizedBox(height: 6),
                        Text(
                          section.folderPath,
                          style: const TextStyle(
                            color: AppTheme.textTertiary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      SelectableText(
                        text.isEmpty ? '(Empty note)' : text,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 17,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
