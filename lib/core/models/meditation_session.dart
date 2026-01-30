// Meditation Session Model for MindFlow
import 'package:flutter/material.dart';

class MeditationSession {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final String category;
  final String instructor;
  final bool isPremium;
  final List<Color> gradientColors;
  final String? audioUrl;
  final int playCount;
  final double? rating;
  final bool isFavorite;

  MeditationSession({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.category,
    required this.instructor,
    this.isPremium = false,
    required this.gradientColors,
    this.audioUrl,
    this.playCount = 0,
    this.rating,
    this.isFavorite = false,
  });

  LinearGradient get gradient => LinearGradient(
    colors: gradientColors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes min';
    }
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (mins == 0) return '$hours hr';
    return '$hours hr $mins min';
  }

  String get formattedPlayCount {
    if (playCount >= 1000000) {
      return '${(playCount / 1000000).toStringAsFixed(1)}M';
    } else if (playCount >= 1000) {
      return '${(playCount / 1000).toStringAsFixed(1)}K';
    }
    return playCount.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'durationMinutes': durationMinutes,
    'category': category,
    'instructor': instructor,
    'isPremium': isPremium,
    'gradientColors': gradientColors.map((c) => c.value).toList(),
    'audioUrl': audioUrl,
    'playCount': playCount,
    'rating': rating,
    'isFavorite': isFavorite,
  };

  factory MeditationSession.fromJson(Map<String, dynamic> json) => MeditationSession(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    durationMinutes: json['durationMinutes'] as int,
    category: json['category'] as String,
    instructor: json['instructor'] as String,
    isPremium: json['isPremium'] as bool? ?? false,
    gradientColors: (json['gradientColors'] as List)
        .map((c) => Color(c as int))
        .toList(),
    audioUrl: json['audioUrl'] as String?,
    playCount: json['playCount'] as int? ?? 0,
    rating: json['rating'] as double?,
    isFavorite: json['isFavorite'] as bool? ?? false,
  );

  MeditationSession copyWith({
    String? id,
    String? title,
    String? description,
    int? durationMinutes,
    String? category,
    String? instructor,
    bool? isPremium,
    List<Color>? gradientColors,
    String? audioUrl,
    int? playCount,
    double? rating,
    bool? isFavorite,
  }) {
    return MeditationSession(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      category: category ?? this.category,
      instructor: instructor ?? this.instructor,
      isPremium: isPremium ?? this.isPremium,
      gradientColors: gradientColors ?? this.gradientColors,
      audioUrl: audioUrl ?? this.audioUrl,
      playCount: playCount ?? this.playCount,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

// Categories
class MeditationCategory {
  static const String all = 'All';
  static const String sleep = 'Sleep';
  static const String anxiety = 'Anxiety';
  static const String focus = 'Focus';
  static const String stress = 'Stress';
  static const String selfLove = 'Self-Love';
  static const String breathing = 'Breathing';

  static const List<String> categories = [
    all,
    sleep,
    anxiety,
    focus,
    stress,
    selfLove,
    breathing,
  ];
}
