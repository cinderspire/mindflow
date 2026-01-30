// Meditation Provider for MindFlow
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meditation_session.dart';
import '../services/storage_service.dart';
import 'dart:convert';

// Meditation state
class MeditationState {
  final List<MeditationSession> sessions;
  final List<String> favoriteIds;
  final String selectedCategory;
  final bool isLoading;

  MeditationState({
    this.sessions = const [],
    this.favoriteIds = const [],
    this.selectedCategory = 'All',
    this.isLoading = false,
  });

  List<MeditationSession> get filteredSessions {
    if (selectedCategory == 'All') return sessions;
    return sessions.where((s) => s.category == selectedCategory).toList();
  }

  List<MeditationSession> get favoriteSessions {
    return sessions.where((s) => favoriteIds.contains(s.id)).toList();
  }

  MeditationState copyWith({
    List<MeditationSession>? sessions,
    List<String>? favoriteIds,
    String? selectedCategory,
    bool? isLoading,
  }) {
    return MeditationState(
      sessions: sessions ?? this.sessions,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Meditation notifier
class MeditationNotifier extends StateNotifier<MeditationState> {
  MeditationNotifier() : super(MeditationState()) {
    _loadData();
  }

  static const String _favoritesKey = 'meditation_favorites';

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);

    // Load favorites
    final favoritesJson = StorageService.getString(_favoritesKey);
    List<String> favorites = [];
    if (favoritesJson != null) {
      favorites = List<String>.from(jsonDecode(favoritesJson));
    }

    // Load default sessions
    final sessions = _getDefaultSessions();

    state = MeditationState(
      sessions: sessions,
      favoriteIds: favorites,
      isLoading: false,
    );
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  Future<void> toggleFavorite(String sessionId) async {
    List<String> newFavorites;
    if (state.favoriteIds.contains(sessionId)) {
      newFavorites = state.favoriteIds.where((id) => id != sessionId).toList();
    } else {
      newFavorites = [...state.favoriteIds, sessionId];
    }

    state = state.copyWith(favoriteIds: newFavorites);
    await StorageService.setString(_favoritesKey, jsonEncode(newFavorites));
  }

  bool isFavorite(String sessionId) {
    return state.favoriteIds.contains(sessionId);
  }

  MeditationSession? getSessionById(String id) {
    try {
      return state.sessions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // Default meditation sessions
  List<MeditationSession> _getDefaultSessions() {
    return [
      MeditationSession(
        id: '1',
        title: 'Morning Calm',
        description: 'Start your day with peace and clarity',
        durationMinutes: 10,
        category: 'Focus',
        instructor: 'Sarah Chen',
        isPremium: false,
        gradientColors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
        playCount: 12500,
        rating: 4.8,
      ),
      MeditationSession(
        id: '2',
        title: 'Deep Sleep Journey',
        description: 'Drift into restful sleep with gentle guidance',
        durationMinutes: 20,
        category: 'Sleep',
        instructor: 'James Miller',
        isPremium: true,
        gradientColors: [const Color(0xFF1A1A2E), const Color(0xFF4C3F91)],
        playCount: 45200,
        rating: 4.9,
      ),
      MeditationSession(
        id: '3',
        title: 'Anxiety Relief',
        description: 'Release tension and find inner peace',
        durationMinutes: 15,
        category: 'Anxiety',
        instructor: 'Emma Wilson',
        isPremium: false,
        gradientColors: [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
        playCount: 32100,
        rating: 4.7,
      ),
      MeditationSession(
        id: '4',
        title: 'Box Breathing',
        description: 'Simple technique for instant calm',
        durationMinutes: 5,
        category: 'Breathing',
        instructor: 'Dr. Michael Brown',
        isPremium: false,
        gradientColors: [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
        playCount: 67800,
        rating: 4.9,
      ),
      MeditationSession(
        id: '5',
        title: 'Self-Compassion',
        description: 'Cultivate kindness towards yourself',
        durationMinutes: 12,
        category: 'Self-Love',
        instructor: 'Lisa Park',
        isPremium: true,
        gradientColors: [const Color(0xFFFA709A), const Color(0xFFFEE140)],
        playCount: 18900,
        rating: 4.8,
      ),
      MeditationSession(
        id: '6',
        title: 'Stress Release',
        description: 'Let go of daily tensions and worries',
        durationMinutes: 15,
        category: 'Stress',
        instructor: 'Sarah Chen',
        isPremium: false,
        gradientColors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
        playCount: 28400,
        rating: 4.6,
      ),
      MeditationSession(
        id: '7',
        title: 'Focus Flow',
        description: 'Enter a state of deep concentration',
        durationMinutes: 10,
        category: 'Focus',
        instructor: 'James Miller',
        isPremium: true,
        gradientColors: [const Color(0xFF0093E9), const Color(0xFF80D0C7)],
        playCount: 41200,
        rating: 4.7,
      ),
      MeditationSession(
        id: '8',
        title: 'Body Scan',
        description: 'Progressive relaxation for complete rest',
        durationMinutes: 20,
        category: 'Sleep',
        instructor: 'Emma Wilson',
        isPremium: false,
        gradientColors: [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
        playCount: 35600,
        rating: 4.8,
      ),
    ];
  }
}

// Providers
final meditationProvider = StateNotifierProvider<MeditationNotifier, MeditationState>((ref) {
  return MeditationNotifier();
});

final filteredMeditationsProvider = Provider<List<MeditationSession>>((ref) {
  return ref.watch(meditationProvider).filteredSessions;
});

final favoriteMeditationsProvider = Provider<List<MeditationSession>>((ref) {
  return ref.watch(meditationProvider).favoriteSessions;
});

final meditationCategoryProvider = Provider<String>((ref) {
  return ref.watch(meditationProvider).selectedCategory;
});
