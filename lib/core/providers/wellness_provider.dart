// Wellness Score Provider for MindFlow
// Composite daily wellness score (0-100) combining:
// mood (40%), journal activity (20%), meditation (20%), breathing exercises (20%)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import 'dart:convert';

import 'mood_provider.dart';
import 'journal_provider.dart';
import 'settings_provider.dart';
import 'gratitude_provider.dart';

class WellnessScoreData {
  final int totalScore;
  final int moodScore;
  final int journalScore;
  final int meditationScore;
  final int breathingScore;
  final DateTime date;

  WellnessScoreData({
    required this.totalScore,
    required this.moodScore,
    required this.journalScore,
    required this.meditationScore,
    required this.breathingScore,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'totalScore': totalScore,
    'moodScore': moodScore,
    'journalScore': journalScore,
    'meditationScore': meditationScore,
    'breathingScore': breathingScore,
    'date': date.toIso8601String(),
  };

  factory WellnessScoreData.fromJson(Map<String, dynamic> json) => WellnessScoreData(
    totalScore: json['totalScore'] as int? ?? 0,
    moodScore: json['moodScore'] as int? ?? 0,
    journalScore: json['journalScore'] as int? ?? 0,
    meditationScore: json['meditationScore'] as int? ?? 0,
    breathingScore: json['breathingScore'] as int? ?? 0,
    date: DateTime.parse(json['date'] as String),
  );
}

class BreathingTracker extends StateNotifier<int> {
  BreathingTracker() : super(0) {
    _loadToday();
  }

  static const String _storageKey = 'breathing_sessions_today';
  static const String _dateKey = 'breathing_sessions_date';

  void _loadToday() {
    final dateStr = StorageService.getString(_dateKey);
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';
    if (dateStr == today) {
      state = StorageService.getInt(_storageKey) ?? 0;
    } else {
      state = 0;
    }
  }

  Future<void> recordSession() async {
    state = state + 1;
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';
    await StorageService.setInt(_storageKey, state);
    await StorageService.setString(_dateKey, today);
  }
}

final breathingTrackerProvider = StateNotifierProvider<BreathingTracker, int>((ref) {
  return BreathingTracker();
});

// Compute wellness score from multiple sources
final wellnessScoreProvider = Provider<WellnessScoreData>((ref) {
  final now = DateTime.now();

  // Mood score (0-40): based on today's mood or average
  final moodNotifier = ref.watch(moodProvider.notifier);
  final todaysMood = moodNotifier.getTodaysMood();
  int moodScore = 0;
  if (todaysMood != null) {
    // Mood 1-5 -> score 8-40
    moodScore = (todaysMood.mood.value * 8).clamp(0, 40);
  }

  // Journal score (0-20): did they journal today?
  final journals = ref.watch(journalProvider);
  final todayJournals = journals.where((e) =>
    e.timestamp.year == now.year &&
    e.timestamp.month == now.month &&
    e.timestamp.day == now.day
  ).length;
  int journalScore = todayJournals > 0 ? 20 : 0;

  // Meditation score (0-20): based on meditation minutes from stats
  final stats = ref.watch(profileStatsProvider);
  // Give full marks for 10+ minutes of meditation overall activity today
  int meditationScore = (stats.totalMeditationMinutes > 0) ? 15 : 0;
  if (stats.currentStreak > 0) meditationScore += 5;
  meditationScore = meditationScore.clamp(0, 20);

  // Breathing score (0-20): based on breathing sessions today
  final breathingSessions = ref.watch(breathingTrackerProvider);
  int breathingScore = breathingSessions > 0 ? 20 : 0;

  // Gratitude bonus: add if done gratitude today (bonus within existing categories)
  final gratitude = ref.watch(todaysGratitudeProvider);
  if (gratitude != null) {
    // Boost journal score to full if not already
    journalScore = 20;
  }

  final totalScore = (moodScore + journalScore + meditationScore + breathingScore).clamp(0, 100);

  return WellnessScoreData(
    totalScore: totalScore,
    moodScore: moodScore,
    journalScore: journalScore,
    meditationScore: meditationScore,
    breathingScore: breathingScore,
    date: now,
  );
});

// Historical wellness scores
class WellnessHistoryNotifier extends StateNotifier<List<WellnessScoreData>> {
  WellnessHistoryNotifier() : super([]) {
    _loadHistory();
  }

  static const String _storageKey = 'wellness_history';

  Future<void> _loadHistory() async {
    final jsonString = StorageService.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      state = jsonList.map((e) => WellnessScoreData.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> saveScore(WellnessScoreData score) async {
    // Remove existing score for same date
    final filtered = state.where((s) =>
      !(s.date.year == score.date.year &&
        s.date.month == score.date.month &&
        s.date.day == score.date.day)
    ).toList();
    state = [score, ...filtered];
    // Keep only last 30 days
    if (state.length > 30) {
      state = state.sublist(0, 30);
    }
    final jsonList = state.map((e) => e.toJson()).toList();
    await StorageService.setString(_storageKey, jsonEncode(jsonList));
  }

  double getWeeklyAverage() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekScores = state.where((s) => s.date.isAfter(weekAgo)).toList();
    if (weekScores.isEmpty) return 0;
    final total = weekScores.fold<int>(0, (sum, s) => sum + s.totalScore);
    return total / weekScores.length;
  }
}

final wellnessHistoryProvider = StateNotifierProvider<WellnessHistoryNotifier, List<WellnessScoreData>>((ref) {
  return WellnessHistoryNotifier();
});
