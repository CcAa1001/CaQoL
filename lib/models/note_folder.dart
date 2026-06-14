import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_folder.freezed.dart';
part 'note_folder.g.dart';

@freezed
abstract class NoteFolder with _$NoteFolder {
  const NoteFolder._();
  const factory NoteFolder({
    required String id,
    required String name,
    String? parentId,
    @Default(false) bool manualSortEnabled,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime deviceUpdatedAt,
    @Default(false) bool isDeleted,
  }) = _NoteFolder;

  factory NoteFolder.fromJson(Map<String, dynamic> json) => _$NoteFolderFromJson(json);

  NoteFolder copyWithClearParent({
    String? name,
    String? parentId,
    bool clearParentId = false,
    bool? manualSortEnabled,
    DateTime? updatedAt,
    DateTime? deviceUpdatedAt,
    bool? isDeleted,
  }) {
    final now = DateTime.now();
    return copyWith(
      name: name ?? this.name,
      parentId: clearParentId ? null : (parentId ?? this.parentId),
      manualSortEnabled: manualSortEnabled ?? this.manualSortEnabled,
      updatedAt: updatedAt ?? now,
      deviceUpdatedAt: deviceUpdatedAt ?? now,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
