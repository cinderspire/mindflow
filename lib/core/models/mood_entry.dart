// Mood Entry Model for MindFlow
import 'package:flutter/material.dart';

enum MoodLevel {
  terrible(1, 'Terrible', '😢', Color(0xFFEF4444)),
  poor(2, 'Poor', '😕', Color(0xFFF97316)),
  neutral(3, 'Okay', '😐', Color(0xFFFACC15)),
  good(4, 'Good', '😊', Color(0xFF84CC16)),
  excellent(5, 'Excellent', '😄', Color(0xFF22C55E));

  final int value;
  final String label;
  final String emoji;
  final Color color;

  const MoodLevel(this.value, this.label, this.emoji, this.color);

  static MoodLevel fromValue(int value) {
    return MoodLevel.values.firstWhere(
      (m) => m.value == value,
      orElse: () => MoodLevel.neutral,
    );
  }

  static MoodLevel fromString(String name) {
    return MoodLevel.values.firstWhere(
      (m) => m.name == name,
      orElse: () => MoodLevel.neutral,
    );
  }
}

class MoodEntry {
  final String id;
  final MoodLevel mood;
  final DateTime timestamp;
  final String? note;
  final List<String>? tags;

  MoodEntry({
    required this.id,
    required this.mood,
    required this.timestamp,
    this.note,
    this.tags,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'mood': mood.name,
    'timestamp': timestamp.toIso8601String(),
    'note': note,
    'tags': tags,
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
    id: json['id'] as String,
    mood: MoodLevel.fromString(json['mood'] as String),
    timestamp: DateTime.parse(json['timestamp'] as String),
    note: json['note'] as String?,
    tags: (json['tags'] as List?)?.cast<String>(),
  );

  MoodEntry copyWith({
    String? id,
    MoodLevel? mood,
    DateTime? timestamp,
    String? note,
    List<String>? tags,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }
}
