import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';
part 'note.g.dart';

@freezed
abstract class NoteComment with _$NoteComment {
  const factory NoteComment({
    required String id,
    required String text,
    @Default('') String quotedText,
    required DateTime createdAt,
  }) = _NoteComment;

  factory NoteComment.fromMap(Map<String, dynamic> map) {
    return NoteComment(
      id: (map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString()).toString(),
      text: (map['text'] ?? '').toString(),
      quotedText: (map['quotedText'] ?? '').toString(),
      createdAt: _readNoteDate(map['createdAt']),
    );
  }

  factory NoteComment.fromJson(Map<String, dynamic> json) => _$NoteCommentFromJson(json);
}

@freezed
abstract class NoteAttachment with _$NoteAttachment {
  const factory NoteAttachment({
    required String id,
    required String name,
    required String path,
    required String type,
    required DateTime createdAt,
  }) = _NoteAttachment;

  factory NoteAttachment.fromMap(Map<String, dynamic> map) {
    return NoteAttachment(
      id: (map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString()).toString(),
      name: (map['name'] ?? 'Attachment').toString(),
      path: (map['path'] ?? '').toString(),
      type: (map['type'] ?? 'file').toString(),
      createdAt: _readNoteDate(map['createdAt']),
    );
  }

  factory NoteAttachment.fromJson(Map<String, dynamic> json) => _$NoteAttachmentFromJson(json);
}

@freezed
abstract class Note with _$Note {
  const Note._(); // Added to allow custom methods
  const factory Note({
    required String id,
    required String title,
    required String body,
    String? folderId,
    @Default(0) int sortOrder,
    @Default(false) bool isFavorite,
    @Default([]) List<String> tags,
    @Default([]) List<NoteComment> comments,
    @Default([]) List<NoteAttachment> attachments,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime deviceUpdatedAt,
    @Default(false) bool isDeleted,
  }) = _Note;

  factory Note.fromMap(Map<String, dynamic> map) {
    final normalized = _normalizeNoteMap(map);
    final updatedAt = _readNoteDate(normalized['updatedAt']);
    return Note(
      id: (normalized['id'] ?? DateTime.now().millisecondsSinceEpoch.toString()).toString(),
      title: (normalized['title'] ?? 'Untitled').toString(),
      body: (normalized['body'] ?? '').toString(),
      folderId: normalized['folderId']?.toString(),
      sortOrder: normalized['sortOrder'] is int
          ? normalized['sortOrder'] as int
          : int.tryParse((normalized['sortOrder'] ?? '').toString()) ?? 0,
      isFavorite: normalized['isFavorite'] == true,
      tags: _readStringList(normalized['tags']),
      comments: _readMapList(normalized['comments']).map(NoteComment.fromMap).toList(),
      attachments: _readMapList(normalized['attachments']).map(NoteAttachment.fromMap).toList(),
      createdAt: _readNoteDate(normalized['createdAt']),
      updatedAt: updatedAt,
      deviceUpdatedAt: _readNoteDate(normalized['deviceUpdatedAt'], fallback: updatedAt),
      isDeleted: normalized['isDeleted'] == true,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  
  // Custom copyWith to allow clearing folderId
  Note copyWithClearFolder({
    String? title,
    String? body,
    String? folderId,
    bool clearFolderId = false,
    int? sortOrder,
    bool? isFavorite,
    List<String>? tags,
    List<NoteComment>? comments,
    List<NoteAttachment>? attachments,
    DateTime? updatedAt,
    DateTime? deviceUpdatedAt,
    bool? isDeleted,
  }) {
    final now = DateTime.now();
    return copyWith(
      title: title ?? this.title,
      body: body ?? this.body,
      folderId: clearFolderId ? null : (folderId ?? this.folderId),
      sortOrder: sortOrder ?? this.sortOrder,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      comments: comments ?? this.comments,
      attachments: attachments ?? this.attachments,
      updatedAt: updatedAt ?? now,
      deviceUpdatedAt: deviceUpdatedAt ?? now,
      isDeleted: isDeleted ?? this.isDeleted,
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
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList();
}

List<Map<String, dynamic>> _readMapList(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<Map>().map((item) => _normalizeNoteMap(item)).toList();
}

DateTime _readNoteDate(dynamic value, {DateTime? fallback}) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value) ?? fallback ?? DateTime.now();
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  return fallback ?? DateTime.now();
}
