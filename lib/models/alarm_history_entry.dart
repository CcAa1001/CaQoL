class AlarmHistoryEntry {
  final String id;
  final String alarmId;
  final String alarmLabel;
  final String event;
  final DateTime timestamp;
  final String details;

  AlarmHistoryEntry({
    required this.id,
    required this.alarmId,
    required this.alarmLabel,
    required this.event,
    required this.timestamp,
    this.details = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'alarmId': alarmId,
    'alarmLabel': alarmLabel,
    'event': event,
    'timestamp': timestamp.toIso8601String(),
    'details': details,
  };

  factory AlarmHistoryEntry.fromMap(Map<String, dynamic> map) => AlarmHistoryEntry(
    id: map['id'],
    alarmId: map['alarmId'],
    alarmLabel: map['alarmLabel'],
    event: map['event'],
    timestamp: DateTime.parse(map['timestamp']),
    details: map['details'] ?? '',
  );
}
