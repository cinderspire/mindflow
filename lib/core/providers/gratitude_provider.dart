// Gratitude Provider for MindFlow
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gratitude_entry.dart';
import '../services/storage_service.dart';
import 'dart:convert';

class GratitudeNotifier extends StateNotifier<List<GratitudeEntry>> {
  GratitudeNotifier() : super([]) {
    _loadEntries();
  }

  static const String _storageKey = 'gratitude_entries';

  Future<void> _loadEntries() async {
    final jsonString = StorageService.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      state = jsonList.map((e) => GratitudeEntry.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> _saveEntries() async {
    final jsonList = state.map((e) => e.toJson()).toList();
    await StorageService.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<void> addEntry(GratitudeEntry entry) async {
    state = [entry, ...state];
    await _saveEntries();
  }

  Future<void> deleteEntry(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _saveEntries();
  }

  GratitudeEntry? getTodaysEntry() {
    final now = DateTime.now();
    try {
      return state.firstWhere((e) =>
        e.timestamp.year == now.year &&
        e.timestamp.month == now.month &&
        e.timestamp.day == now.day
      );
    } catch (_) {
      return null;
    }
  }

  List<GratitudeEntry> getThisWeeksEntries() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return state.where((e) => e.timestamp.isAfter(weekAgo)).toList();
  }

  /// Get weekly gratitude summary - most frequent themes
  Map<String, int> getWeeklyThemes() {
    final weekEntries = getThisWeeksEntries();
    final themes = <String, int>{};
    for (final entry in weekEntries) {
      for (final item in entry.items) {
        final lower = item.toLowerCase().trim();
        if (lower.isNotEmpty) {
          // Simple keyword extraction
          final words = lower.split(RegExp(r'\s+'));
          for (final word in words) {
            if (word.length > 3) {
              themes[word] = (themes[word] ?? 0) + 1;
            }
          }
        }
      }
    }
    // Sort by frequency and return top entries
    final sorted = themes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(8));
  }

  int get totalEntries => state.length;
  int get thisWeekCount => getThisWeeksEntries().length;
}

// Providers
final gratitudeProvider = StateNotifierProvider<GratitudeNotifier, List<GratitudeEntry>>((ref) {
  return GratitudeNotifier();
});

final todaysGratitudeProvider = Provider<GratitudeEntry?>((ref) {
  final notifier = ref.watch(gratitudeProvider.notifier);
  return notifier.getTodaysEntry();
});

final weeklyGratitudeProvider = Provider<List<GratitudeEntry>>((ref) {
  final notifier = ref.watch(gratitudeProvider.notifier);
  return notifier.getThisWeeksEntries();
});

final gratitudeCountProvider = Provider<int>((ref) {
  return ref.watch(gratitudeProvider).length;
});
