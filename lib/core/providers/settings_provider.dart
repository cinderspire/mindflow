// Settings Provider for MindFlow
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import 'dart:convert';

// Settings state notifier with persistence
class SettingsNotifier extends StateNotifier<UserSettings> {
  SettingsNotifier() : super(UserSettings.defaults()) {
    _loadSettings();
  }

  static const String _storageKey = 'user_settings';

  Future<void> _loadSettings() async {
    final jsonString = StorageService.getString(_storageKey);
    if (jsonString != null) {
      state = UserSettings.fromJson(jsonDecode(jsonString));
    }
  }

  Future<void> _saveSettings() async {
    await StorageService.setString(_storageKey, jsonEncode(state.toJson()));
  }

  Future<void> setNotificationsEnabled(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    await _saveSettings();
  }

  Future<void> setDarkModeEnabled(bool value) async {
    state = state.copyWith(darkModeEnabled: value);
    await _saveSettings();
  }

  Future<void> setHapticEnabled(bool value) async {
    state = state.copyWith(hapticEnabled: value);
    await _saveSettings();
  }

  Future<void> setLanguage(String value) async {
    state = state.copyWith(language: value);
    await _saveSettings();
  }

  Future<void> setReminderTime(String value) async {
    state = state.copyWith(reminderTime: value);
    await _saveSettings();
  }

  Future<void> setDailyReminderEnabled(bool value) async {
    state = state.copyWith(dailyReminderEnabled: value);
    await _saveSettings();
  }
}

// Profile stats notifier
class ProfileStatsNotifier extends StateNotifier<UserStats> {
  ProfileStatsNotifier() : super(UserStats.empty()) {
    _loadStats();
  }

  static const String _storageKey = 'user_stats';
  static const String _streakKey = 'last_activity_date';

  Future<void> _loadStats() async {
    final jsonString = StorageService.getString(_storageKey);
    if (jsonString != null) {
      state = UserStats.fromJson(jsonDecode(jsonString));
    }
    _checkStreak();
  }

  Future<void> _saveStats() async {
    await StorageService.setString(_storageKey, jsonEncode(state.toJson()));
  }

  void _checkStreak() {
    final lastDateStr = StorageService.getString(_streakKey);
    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final last = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final diff = today.difference(last).inDays;

      if (diff > 1) {
        // Streak broken
        state = UserStats(
          totalMeditationMinutes: state.totalMeditationMinutes,
          totalJournalEntries: state.totalJournalEntries,
          currentStreak: 0,
          longestStreak: state.longestStreak,
          totalMoodEntries: state.totalMoodEntries,
          averageMood: state.averageMood,
          moodImprovementPercent: state.moodImprovementPercent,
        );
        _saveStats();
      }
    }
  }

  Future<void> recordActivity() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDateStr = StorageService.getString(_streakKey);

    int newStreak = state.currentStreak;
    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);
      final last = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final diff = today.difference(last).inDays;

      if (diff == 1) {
        newStreak = state.currentStreak + 1;
      } else if (diff == 0) {
        newStreak = state.currentStreak; // Same day
      } else {
        newStreak = 1; // Streak broken, start new
      }
    } else {
      newStreak = 1;
    }

    final longestStreak = newStreak > state.longestStreak
        ? newStreak
        : state.longestStreak;

    state = UserStats(
      totalMeditationMinutes: state.totalMeditationMinutes,
      totalJournalEntries: state.totalJournalEntries,
      currentStreak: newStreak,
      longestStreak: longestStreak,
      totalMoodEntries: state.totalMoodEntries,
      averageMood: state.averageMood,
      moodImprovementPercent: state.moodImprovementPercent,
    );

    await StorageService.setString(_streakKey, today.toIso8601String());
    await _saveStats();
  }

  Future<void> addMoodEntry(double avgMood) async {
    state = UserStats(
      totalMeditationMinutes: state.totalMeditationMinutes,
      totalJournalEntries: state.totalJournalEntries,
      currentStreak: state.currentStreak,
      longestStreak: state.longestStreak,
      totalMoodEntries: state.totalMoodEntries + 1,
      averageMood: avgMood,
      moodImprovementPercent: state.moodImprovementPercent,
    );
    await recordActivity();
  }

  Future<void> addJournalEntry() async {
    state = UserStats(
      totalMeditationMinutes: state.totalMeditationMinutes,
      totalJournalEntries: state.totalJournalEntries + 1,
      currentStreak: state.currentStreak,
      longestStreak: state.longestStreak,
      totalMoodEntries: state.totalMoodEntries,
      averageMood: state.averageMood,
      moodImprovementPercent: state.moodImprovementPercent,
    );
    await recordActivity();
  }

  Future<void> addMeditationMinutes(int minutes) async {
    state = UserStats(
      totalMeditationMinutes: state.totalMeditationMinutes + minutes,
      totalJournalEntries: state.totalJournalEntries,
      currentStreak: state.currentStreak,
      longestStreak: state.longestStreak,
      totalMoodEntries: state.totalMoodEntries,
      averageMood: state.averageMood,
      moodImprovementPercent: state.moodImprovementPercent,
    );
    await recordActivity();
  }
}

// Providers
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  return SettingsNotifier();
});

final profileStatsProvider =
    StateNotifierProvider<ProfileStatsNotifier, UserStats>((ref) {
  return ProfileStatsNotifier();
});
