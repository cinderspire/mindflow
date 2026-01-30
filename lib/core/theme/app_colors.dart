import 'package:flutter/material.dart';

/// MindFlow App Color Palette - Calming gradients with purples, blues, and teals
class AppColors {
  AppColors._();

  // Primary Colors - Calming Purple/Blue spectrum
  static const Color primaryPurple = Color(0xFF6B4CE6);
  static const Color primaryBlue = Color(0xFF4C9AE6);
  static const Color primaryTeal = Color(0xFF4CE6C8);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient calmGradient = LinearGradient(
    colors: [Color(0xFF8E94F2), Color(0xFF4FACFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient meditationGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Mood Colors
  static const Color moodExcellent = Color(0xFF4CAF50); // Green
  static const Color moodGood = Color(0xFF8BC34A); // Light Green
  static const Color moodNeutral = Color(0xFFFFC107); // Amber
  static const Color moodPoor = Color(0xFFFF9800); // Orange
  static const Color moodTerrible = Color(0xFFE91E63); // Pink/Red
  
  // Background Colors - Dark Mode Optimized
  static const Color backgroundDark = Color(0xFF0F0F1E);
  static const Color backgroundDarkElevated = Color(0xFF1A1A2E);
  static const Color backgroundDarkCard = Color(0xFF252541);
  
  // Background Colors - Light Mode
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundLightElevated = Color(0xFFFFFFFF);
  static const Color backgroundLightCard = Color(0xFFFFFFFF);
  
  // Text Colors - Dark Mode
  static const Color textPrimaryDark = Color(0xFFF5F5FF);
  static const Color textSecondaryDark = Color(0xFFB8B8D4);
  static const Color textTertiaryDark = Color(0xFF7F7FA6);
  
  // Text Colors - Light Mode
  static const Color textPrimaryLight = Color(0xFF1F1F3D);
  static const Color textSecondaryLight = Color(0xFF5A5A7A);
  static const Color textTertiaryLight = Color(0xFF9494B8);
  
  // Glassmorphism Colors
  static Color glassDark = const Color(0xFF1A1A2E).withOpacity(0.7);
  static Color glassLight = const Color(0xFFFFFFFF).withOpacity(0.7);
  static Color glassBorder = const Color(0xFFFFFFFF).withOpacity(0.1);
  
  // Accent Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE91E63);
  static const Color info = Color(0xFF4C9AE6);
  
  // Shadow Colors
  static Color shadowDark = const Color(0xFF000000).withOpacity(0.3);
  static Color shadowLight = const Color(0xFF000000).withOpacity(0.1);
}
