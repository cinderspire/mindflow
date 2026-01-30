// Journal Provider for MindFlow
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journal_entry.dart';
import '../services/storage_service.dart';
import 'dart:convert';

// Journal entries state notifier
class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  JournalNotifier() : super([]) {
    _loadEntries();
  }

  static const String _storageKey = 'journal_entries';

  Future<void> _loadEntries() async {
    final jsonString = StorageService.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      state = jsonList.map((e) => JournalEntry.fromJson(e)).toList();
    }
  }

  Future<void> _saveEntries() async {
    final jsonList = state.map((e) => e.toJson()).toList();
    await StorageService.setString(_storageKey, jsonEncode(jsonList));
  }

  // Add new journal entry
  Future<void> addEntry(JournalEntry entry) async {
    state = [entry, ...state];
    await _saveEntries();
  }

  // Update journal entry
  Future<void> updateEntry(JournalEntry entry) async {
    state = state.map((e) => e.id == entry.id ? entry : e).toList();
    await _saveEntries();
  }

  // Delete journal entry
  Future<void> deleteEntry(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _saveEntries();
  }

  // Get entry by ID
  JournalEntry? getEntryById(String id) {
    try {
      return state.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  // Get entries for date
  List<JournalEntry> getEntriesForDate(DateTime date) {
    return state.where((e) =>
      e.timestamp.year == date.year &&
      e.timestamp.month == date.month &&
      e.timestamp.day == date.day
    ).toList();
  }

  // Get entries by mood
  List<JournalEntry> getEntriesByMood(String mood) {
    return state.where((e) => e.mood == mood).toList();
  }

  // Search entries
  List<JournalEntry> searchEntries(String query) {
    final lowerQuery = query.toLowerCase();
    return state.where((e) =>
      e.content.toLowerCase().contains(lowerQuery) ||
      (e.tags?.any((t) => t.toLowerCase().contains(lowerQuery)) ?? false)
    ).toList();
  }

  // Get total entry count
  int get totalEntries => state.length;

  // Get voice entry count
  int get voiceEntryCount => state.where((e) => e.isVoiceEntry).length;

  // Get entries this week
  List<JournalEntry> getThisWeeksEntries() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return state.where((e) => e.timestamp.isAfter(weekAgo)).toList();
  }
}

// Providers
final journalProvider = StateNotifierProvider<JournalNotifier, List<JournalEntry>>((ref) {
  return JournalNotifier();
});

final journalEntryProvider = Provider.family<JournalEntry?, String>((ref, id) {
  final entries = ref.watch(journalProvider);
  try {
    return entries.firstWhere((e) => e.id == id);
  } catch (_) {
    return null;
  }
});

final journalCountProvider = Provider<int>((ref) {
  return ref.watch(journalProvider).length;
});

final thisWeeksJournalProvider = Provider<List<JournalEntry>>((ref) {
  final notifier = ref.watch(journalProvider.notifier);
  return notifier.getThisWeeksEntries();
});
