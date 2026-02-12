import 'package:flutter/material.dart';

class SleepStory {
  final String id;
  final String title;
  final String narrator;
  final String description;
  final int durationMinutes;
  final String category;
  final IconData icon;
  final List<Color> gradientColors;

  const SleepStory({
    required this.id,
    required this.title,
    required this.narrator,
    required this.description,
    required this.durationMinutes,
    this.category = 'Nature',
    this.icon = Icons.nightlight_round,
    this.gradientColors = const [Color(0xFF6B4CE6), Color(0xFF4C9AE6)],
  });
}
