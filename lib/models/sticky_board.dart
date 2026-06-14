import 'package:freezed_annotation/freezed_annotation.dart';

part 'sticky_board.freezed.dart';
part 'sticky_board.g.dart';

@freezed
abstract class StickyBoard with _$StickyBoard {
  const StickyBoard._();
  const factory StickyBoard({
    required String id,
    required String name,
    @Default('grid') String viewMode,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime deviceUpdatedAt,
    @Default(false) bool isDeleted,
  }) = _StickyBoard;

  factory StickyBoard.fromJson(Map<String, dynamic> json) => _$StickyBoardFromJson(json);

  StickyBoard copyWithDefaults({
    String? name,
    String? viewMode,
    DateTime? updatedAt,
    DateTime? deviceUpdatedAt,
    bool? isDeleted,
  }) {
    final now = DateTime.now();
    return copyWith(
      name: name ?? this.name,
      viewMode: viewMode ?? this.viewMode,
      updatedAt: updatedAt ?? now,
      deviceUpdatedAt: deviceUpdatedAt ?? now,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
