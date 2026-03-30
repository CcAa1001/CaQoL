import 'package:flutter/material.dart';

class Sticky {
  final String id;
  final String body;
  final Color color;
  final DateTime updatedAt;

  Sticky({
    required this.id,
    required this.body,
    required this.color,
    required this.updatedAt,
  });

  Sticky copyWith({String? body, Color? color}) {
    return Sticky(
      id: id,
      body: body ?? this.body,
      color: color ?? this.color,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'body': body,
    'color': color.value,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Sticky.fromMap(Map<String, dynamic> map) => Sticky(
    id: map['id'],
    body: map['body'],
    color: Color(map['color']),
    updatedAt: DateTime.parse(map['updatedAt']),
  );
}
