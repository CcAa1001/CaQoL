import 'quest_config.dart';

class AlarmModel {
  final String id;
  final int platformId;
  final String label;
  final String soundPath;
  final String? noteId;
  final int hour;
  final int minute;
  final List<bool> repeatDays; // index 0=Mon, 6=Sun
  final bool isEnabled;
  final QuestConfig quest;

  AlarmModel({
    required this.id,
    required this.platformId,
    required this.label,
    required this.soundPath,
    this.noteId,
    required this.hour,
    required this.minute,
    required this.repeatDays,
    required this.isEnabled,
    required this.quest,
  });

  AlarmModel copyWith({
    int? platformId,
    String? label,
    String? soundPath,
    String? noteId,
    bool? clearNoteId,
    int? hour,
    int? minute,
    List<bool>? repeatDays,
    bool? isEnabled,
    QuestConfig? quest,
  }) =>
      AlarmModel(
        id: id,
        platformId: platformId ?? this.platformId,
        label: label ?? this.label,
        soundPath: soundPath ?? this.soundPath,
        noteId: clearNoteId == true ? null : noteId ?? this.noteId,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        repeatDays: repeatDays ?? this.repeatDays,
        isEnabled: isEnabled ?? this.isEnabled,
        quest: quest ?? this.quest,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'platformId': platformId,
    'label': label,
    'soundPath': soundPath,
    'noteId': noteId,
    'hour': hour,
    'minute': minute,
    'repeatDays': repeatDays,
    'isEnabled': isEnabled,
    'quest': quest.toMap(),
  };

  factory AlarmModel.fromMap(Map<String, dynamic> map) => AlarmModel(
    id: map['id'],
    platformId: map['platformId'] ?? map['id'].hashCode.abs() % 2147483647, // Fallback for old local alarms
    label: map['label'],
    soundPath: map['soundPath'] ?? 'assets/alarm.mp3',
    noteId: map['noteId'],
    hour: map['hour'],
    minute: map['minute'],
    repeatDays: List<bool>.from(map['repeatDays']),
    isEnabled: map['isEnabled'],
    quest: QuestConfig.fromMap(Map<String, dynamic>.from(map['quest'])),
  );

  String get timeString {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get repeatString {
    if (repeatDays.every((d) => !d)) return 'Once';
    if (repeatDays.every((d) => d)) return 'Every day';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return repeatDays
        .asMap()
        .entries
        .where((e) => e.value)
        .map((e) => names[e.key])
        .join(', ');
  }
}
