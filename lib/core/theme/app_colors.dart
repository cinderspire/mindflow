import 'package:flutter/material.dart';

/// MindFlow App Color Palette - Night Sky Theme
class AppColors {
  AppColors._();

  // Primary Colors - Night Sky
  static const Color primaryNavy = Color(0xFF0F172A);
  static const Color primaryNavyLight = Color(0xFF1E293B);
  static const Color primaryNavyDeep = Color(0xFF0A0F1E);

  // Secondary - Lavender
  static const Color secondaryLavender = Color(0xFFA78BFA);
  static const Color secondaryLavenderLight = Color(0xFFC4B5FD);
  static const Color secondaryLavenderDark = Color(0xFF8B5CF6);

  // Accent - Star White
  static const Color accentStarWhite = Color(0xFFF1F5F9);
  static const Color accentMoonGlow = Color(0xFFE2E8F0);

  // Gradient Colors - Cosmic
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cosmicGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient auroraGradient = LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFF818CF8), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient meditationGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Mood Colors (softer, night-sky inspired)
  static const Color moodExcellent = Color(0xFFA78BFA); // Lavender
  static const Color moodGood = Color(0xFF818CF8); // Indigo
  static const Color moodNeutral = Color(0xFF94A3B8); // Slate
  static const Color moodPoor = Color(0xFFF59E0B); // Amber
  static const Color moodTerrible = Color(0xFFEF4444); // Red

  // Background Colors - Dark Mode (Primary)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color backgroundDarkElevated = Color(0xFF1E293B);
  static const Color backgroundDarkCard = Color(0xFF1E1B4B);

  // Background Colors - Light Mode
  static const Color backgroundLight = Color(0xFFF1F5F9);
  static const Color backgroundLightElevated = Color(0xFFFFFFFF);
  static const Color backgroundLightCard = Color(0xFFFFFFFF);

  // Text Colors - Dark Mode
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFFC4B5FD);
  static const Color textTertiaryDark = Color(0xFF94A3B8);

  // Text Colors - Light Mode
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // Glassmorphism Colors
  static Color glassDark = const Color(0xFF1E293B).withValues(alpha: 0.7);
  static Color glassLight = const Color(0xFFFFFFFF).withValues(alpha: 0.7);
  static Color glassBorder = const Color(0xFFA78BFA).withValues(alpha: 0.15);

  // Accent Colors
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFFA78BFA);

  // Shadow Colors
  static Color shadowDark = const Color(0xFF000000).withValues(alpha: 0.4);
  static Color shadowLight = const Color(0xFF000000).withValues(alpha: 0.1);

  // ── Legacy aliases (kept for backward compatibility) ──
  static const Color primaryPurple = secondaryLavender;
  static const Color primaryBlue = Color(0xFF818CF8);
  static const Color primaryTeal = Color(0xFF34D399);
  static const LinearGradient calmGradient = cosmicGradient;
}
