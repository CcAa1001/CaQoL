import '../models/note.dart';

class NoteLink {
  final String noteId;
  final String title;

  const NoteLink({
    required this.noteId,
    required this.title,
  });
}

class NoteLinksService {
  static final _tokenPattern = RegExp(r'\[\[note:([^\|\]]+)\|([^\]]+)\]\]');
  static final _attachmentTokenPattern =
      RegExp(r'\[\[attachment:([^\|\]]+)\|([^\]]+)\]\]');

  List<NoteLink> parse(String body) {
    return _tokenPattern
        .allMatches(body)
        .map(
          (match) => NoteLink(
            noteId: match.group(1) ?? '',
            title: match.group(2) ?? 'Linked note',
          ),
        )
        .where((link) => link.noteId.isNotEmpty)
        .toList();
  }

  String insertLink(String body, Note note) {
    final token = '[[note:${note.id}|${note.title}]]';
    if (body.trim().isEmpty) {
      return token;
    }
    return '$body\n$token';
  }

  String plainText(String body) {
    return body
        .replaceAllMapped(
          _tokenPattern,
          (match) => match.group(2) ?? 'Linked note',
        )
        .replaceAllMapped(
          _attachmentTokenPattern,
          (match) => match.group(2) ?? 'Attachment',
        );
  }

  List<Note> backlinksFor(Note target, List<Note> allNotes) {
    return allNotes
        .where((note) => note.id != target.id)
        .where((note) => parse(note.body).any((link) => link.noteId == target.id))
        .toList();
  }
}
