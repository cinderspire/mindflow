// Mood Provider for MindFlow
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_entry.dart';
import '../services/storage_service.dart';
import 'dart:convert';

// Mood entries state notifier
class MoodNotifier extends StateNotifier<List<MoodEntry>> {
  MoodNotifier() : super([]) {
    _loadMoods();
  }

  static const String _storageKey = 'mood_entries';

  Future<void> _loadMoods() async {
    final jsonString = StorageService.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      state = jsonList.map((e) => MoodEntry.fromJson(e)).toList();
    }
  }

  Future<void> _saveMoods() async {
    final jsonList = state.map((e) => e.toJson()).toList();
    await StorageService.setString(_storageKey, jsonEncode(jsonList));
  }

  // Add new mood entry
  Future<void> addMood(MoodEntry entry) async {
    state = [entry, ...state];
    await _saveMoods();
  }

  // Update mood entry
  Future<void> updateMood(MoodEntry entry) async {
    state = state.map((e) => e.id == entry.id ? entry : e).toList();
    await _saveMoods();
  }

  // Delete mood entry
  Future<void> deleteMood(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _saveMoods();
  }

  // Get moods for date range
  List<MoodEntry> getMoodsForDateRange(DateTime start, DateTime end) {
    return state.where((e) =>
      e.timestamp.isAfter(start) && e.timestamp.isBefore(end)
    ).toList();
  }

  // Get today's mood
  MoodEntry? getTodaysMood() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    try {
      return state.firstWhere((e) =>
        e.timestamp.year == today.year &&
        e.timestamp.month == today.month &&
        e.timestamp.day == today.day
      );
    } catch (_) {
      return null;
    }
  }

  // Get weekly moods
  List<MoodEntry> getWeeklyMoods() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return getMoodsForDateRange(weekAgo, now);
  }

  // Calculate average mood
  double getAverageMood({int days = 7}) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final moods = getMoodsForDateRange(startDate, now);
    if (moods.isEmpty) return 3.0;
    final total = moods.fold<int>(0, (sum, e) => sum + e.mood.value);
    return total / moods.length;
  }

  // Get mood trend (positive, negative, neutral)
  String getMoodTrend() {
    final thisWeek = getAverageMood(days: 7);
    final lastWeek = getAverageMood(days: 14) - getAverageMood(days: 7);
    if (thisWeek > lastWeek + 0.3) return 'improving';
    if (thisWeek < lastWeek - 0.3) return 'declining';
    return 'stable';
  }
}

// Providers
final moodProvider = StateNotifierProvider<MoodNotifier, List<MoodEntry>>((ref) {
  return MoodNotifier();
});

final todaysMoodProvider = Provider<MoodEntry?>((ref) {
  final notifier = ref.watch(moodProvider.notifier);
  return notifier.getTodaysMood();
});

final weeklyMoodsProvider = Provider<List<MoodEntry>>((ref) {
  final notifier = ref.watch(moodProvider.notifier);
  return notifier.getWeeklyMoods();
});

final averageMoodProvider = Provider<double>((ref) {
  final notifier = ref.watch(moodProvider.notifier);
  return notifier.getAverageMood();
});

final moodTrendProvider = Provider<String>((ref) {
  final notifier = ref.watch(moodProvider.notifier);
  return notifier.getMoodTrend();
});
