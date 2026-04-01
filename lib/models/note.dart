class NoteComment {
  final String id;
  final String text;
  final String quotedText;
  final DateTime createdAt;

  const NoteComment({
    required this.id,
    required this.text,
    this.quotedText = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'quotedText': quotedText,
        'createdAt': createdAt.toIso8601String(),
      };

  factory NoteComment.fromMap(Map<String, dynamic> map) => NoteComment(
        id: (map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString())
            .toString(),
        text: (map['text'] ?? '').toString(),
        quotedText: (map['quotedText'] ?? '').toString(),
        createdAt: _readNoteDate(map['createdAt']),
      );
}

class NoteAttachment {
  final String id;
  final String name;
  final String path;
  final String type;
  final DateTime createdAt;

  const NoteAttachment({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'path': path,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
      };

  factory NoteAttachment.fromMap(Map<String, dynamic> map) => NoteAttachment(
        id: (map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString())
            .toString(),
        name: (map['name'] ?? 'Attachment').toString(),
        path: (map['path'] ?? '').toString(),
        type: (map['type'] ?? 'file').toString(),
        createdAt: _readNoteDate(map['createdAt']),
      );
}

class Note {
  final String id;
  final String title;
  final String body;
  final String? folderId;
  final bool isFavorite;
  final List<String> tags;
  final List<NoteComment> comments;
  final List<NoteAttachment> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime deviceUpdatedAt;
  final bool isDeleted;

  Note({
    required this.id,
    required this.title,
    required this.body,
    this.folderId,
    this.isFavorite = false,
    this.tags = const [],
    this.comments = const [],
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.deviceUpdatedAt,
    this.isDeleted = false,
  });

  Note copyWith({
    String? title,
    String? body,
    String? folderId,
    bool? clearFolderId,
    bool? isFavorite,
    List<String>? tags,
    List<NoteComment>? comments,
    List<NoteAttachment>? attachments,
    DateTime? updatedAt,
    DateTime? deviceUpdatedAt,
    bool? isDeleted,
  }) {
    final now = DateTime.now();
    return Note(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      folderId: clearFolderId == true ? null : folderId ?? this.folderId,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      comments: comments ?? this.comments,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt,
      updatedAt: updatedAt ?? now,
      deviceUpdatedAt: deviceUpdatedAt ?? now,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'folderId': folderId,
    'isFavorite': isFavorite,
    'tags': tags,
    'comments': comments.map((comment) => comment.toMap()).toList(),
    'attachments': attachments.map((attachment) => attachment.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deviceUpdatedAt': deviceUpdatedAt.toIso8601String(),
    'isDeleted': isDeleted,
  };

  factory Note.fromMap(Map<String, dynamic> map) {
    final normalized = _normalizeNoteMap(map);
    final updatedAt = _readNoteDate(normalized['updatedAt']);
    return Note(
      id: (normalized['id'] ?? DateTime.now().millisecondsSinceEpoch.toString())
          .toString(),
      title: (normalized['title'] ?? 'Untitled').toString(),
      body: (normalized['body'] ?? '').toString(),
      folderId: normalized['folderId']?.toString(),
      isFavorite: normalized['isFavorite'] == true,
      tags: _readStringList(normalized['tags']),
      comments: _readMapList(normalized['comments'])
          .map(NoteComment.fromMap)
          .toList(),
      attachments: _readMapList(normalized['attachments'])
          .map(NoteAttachment.fromMap)
          .toList(),
      createdAt: _readNoteDate(normalized['createdAt']),
      updatedAt: updatedAt,
      deviceUpdatedAt: _readNoteDate(
        normalized['deviceUpdatedAt'],
        fallback: updatedAt,
      ),
      isDeleted: normalized['isDeleted'] == true,
    );
  }
}

Map<String, dynamic> _normalizeNoteMap(Map<dynamic, dynamic> map) {
  return map.map((key, value) {
    if (value is Map) {
      return MapEntry(key.toString(), _normalizeNoteMap(value));
    }
    if (value is List) {
      return MapEntry(
        key.toString(),
        value.map((item) {
          if (item is Map) {
            return _normalizeNoteMap(item);
          }
          return item;
        }).toList(),
      );
    }
    return MapEntry(key.toString(), value);
  });
}

List<String> _readStringList(dynamic value) {
  if (value is! List) {
    return const [];
  }
  return value.map((item) => item.toString()).toList();
}

List<Map<String, dynamic>> _readMapList(dynamic value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<Map>()
      .map((item) => _normalizeNoteMap(item))
      .toList();
}

DateTime _readNoteDate(dynamic value, {DateTime? fallback}) {
  if (value is DateTime) {
    return value;
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value) ?? fallback ?? DateTime.now();
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  return fallback ?? DateTime.now();
}
