// CBT Thought Record Provider for MindFlow
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cbt_record.dart';
import '../services/storage_service.dart';
import 'dart:convert';

class CbtNotifier extends StateNotifier<List<CbtRecord>> {
  CbtNotifier() : super([]) {
    _loadRecords();
  }

  static const String _storageKey = 'cbt_records';

  Future<void> _loadRecords() async {
    final jsonString = StorageService.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      state = jsonList.map((e) => CbtRecord.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> _saveRecords() async {
    final jsonList = state.map((e) => e.toJson()).toList();
    await StorageService.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<void> addRecord(CbtRecord record) async {
    state = [record, ...state];
    await _saveRecords();
  }

  Future<void> deleteRecord(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _saveRecords();
  }

  /// Get the most common distortions across all records
  Map<CognitiveDistortion, int> getMostCommonDistortions() {
    final counts = <CognitiveDistortion, int>{};
    for (final record in state) {
      for (final distortion in record.distortions) {
        counts[distortion] = (counts[distortion] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  /// Average belief reduction (before - after reframing)
  double getAverageBeliefReduction() {
    if (state.isEmpty) return 0;
    final total = state.fold<int>(
      0, (sum, r) => sum + (r.beliefBefore - r.beliefAfter),
    );
    return total / state.length;
  }

  List<CbtRecord> getThisWeeksRecords() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return state.where((e) => e.timestamp.isAfter(weekAgo)).toList();
  }

  int get totalRecords => state.length;
}

// Providers
final cbtProvider = StateNotifierProvider<CbtNotifier, List<CbtRecord>>((ref) {
  return CbtNotifier();
});

final cbtCountProvider = Provider<int>((ref) {
  return ref.watch(cbtProvider).length;
});

final commonDistortionsProvider = Provider<Map<CognitiveDistortion, int>>((ref) {
  final notifier = ref.watch(cbtProvider.notifier);
  return notifier.getMostCommonDistortions();
});
