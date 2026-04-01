import '../models/note.dart';

class NoteLink {
  final String noteId;
  final String title;
  final bool isTitleLink;

  const NoteLink({
    required this.noteId,
    required this.title,
    this.isTitleLink = false,
  });
}

class NoteLinksService {
  static final _tokenPattern = RegExp(r'\[\[note:([^\|\]]+)\|([^\]]+)\]\]');
  static final _titlePattern = RegExp(r'\[\[([^\[\]\|]+)\]\]');
  static final _attachmentTokenPattern =
      RegExp(r'\[\[attachment:([^\|\]]+)\|([^\]]+)\]\]');

  List<NoteLink> parse(String body, {List<Note> notes = const []}) {
    final links = <NoteLink>[];
    for (final match in _tokenPattern.allMatches(body)) {
      final noteId = match.group(1) ?? '';
      if (noteId.isEmpty) {
        continue;
      }
      links.add(
        NoteLink(
          noteId: noteId,
          title: match.group(2) ?? 'Linked note',
        ),
      );
    }
    for (final match in _titlePattern.allMatches(body)) {
      final token = match.group(0) ?? '';
      if (token.startsWith('[[note:') || token.startsWith('[[attachment:')) {
        continue;
      }
      final title = (match.group(1) ?? '').trim();
      if (title.isEmpty) {
        continue;
      }
      String noteId = '';
      for (final note in notes) {
        if (note.title.trim().toLowerCase() == title.toLowerCase()) {
          noteId = note.id;
          break;
        }
      }
      links.add(
        NoteLink(
          noteId: noteId,
          title: title,
          isTitleLink: true,
        ),
      );
    }
    return links;
  }

  String insertLink(String body, Note note) {
    final token = '[[${note.title}]]';
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
          _titlePattern,
          (match) {
            final token = match.group(0) ?? '';
            if (token.startsWith('[[note:') || token.startsWith('[[attachment:')) {
              return token;
            }
            return match.group(1) ?? 'Linked note';
          },
        )
        .replaceAllMapped(
          _attachmentTokenPattern,
          (match) => match.group(2) ?? 'Attachment',
        );
  }

  List<Note> backlinksFor(Note target, List<Note> allNotes) {
    return allNotes
        .where((note) => note.id != target.id)
        .where(
          (note) => parse(note.body, notes: allNotes).any(
            (link) =>
                link.noteId == target.id ||
                (link.isTitleLink &&
                    link.title.trim().toLowerCase() ==
                        target.title.trim().toLowerCase()),
          ),
        )
        .toList();
  }
}
