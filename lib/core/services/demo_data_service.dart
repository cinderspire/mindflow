// Demo Data Seeder for MindFlow
// Seeds rich sample data on first launch so the app looks full and impressive.
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/mood_entry.dart';
import '../models/journal_entry.dart';
import '../models/gratitude_entry.dart';
import '../models/cbt_record.dart';
import 'storage_service.dart';

class DemoDataService {
  static const String _seededKey = 'demo_data_seeded_v2';
  static const _uuid = Uuid();

  /// Returns true if demo data was just seeded (first launch).
  static Future<bool> seedIfNeeded() async {
    if (StorageService.getBool(_seededKey) == true) return false;
    await _seedMoods();
    await _seedJournal();
    await _seedGratitude();
    await _seedCbt();
    await _seedStats();
    await StorageService.setBool(_seededKey, true);
    return true;
  }

  // ─── Mood entries: 14 days of data ───────────────────────────
  static Future<void> _seedMoods() async {
    final now = DateTime.now();
    final entries = <MoodEntry>[];

    // Pattern: generally improving over 2 weeks with natural variation
    final moodPattern = [
      MoodLevel.neutral,   // 14 days ago
      MoodLevel.poor,      // 13
      MoodLevel.neutral,   // 12
      MoodLevel.neutral,   // 11
      MoodLevel.good,      // 10
      MoodLevel.good,      // 9
      MoodLevel.neutral,   // 8
      MoodLevel.good,      // 7
      MoodLevel.excellent, // 6
      MoodLevel.good,      // 5
      MoodLevel.good,      // 4
      MoodLevel.excellent, // 3
      MoodLevel.good,      // 2
      MoodLevel.excellent, // 1 (yesterday)
    ];

    final notes = [
      'Feeling a bit flat today. Need to get more sleep.',
      'Rough morning, work stress piling up.',
      null,
      'Okay day. Tried the breathing exercise — helped a bit.',
      'Good walk in the park this morning. Nature helps!',
      'Weekend vibes 🌿 Did a 10-min meditation.',
      'Sunday evening anxiety about the week ahead.',
      'Started the week strong! Journaled this morning.',
      'Amazing session with the AI coach. Feeling empowered.',
      'Productive day. Grateful for small wins.',
      'A bit tired but overall positive.',
      'Great conversation with a friend. Connection matters.',
      'Meditation streak going strong 💪',
      'Feeling really good about my progress!',
    ];

    for (int i = 0; i < moodPattern.length; i++) {
      final daysAgo = moodPattern.length - i;
      final date = DateTime(now.year, now.month, now.day - daysAgo, 8 + (i % 5), 15 + (i * 7) % 45);
      entries.add(MoodEntry(
        id: _uuid.v4(),
        mood: moodPattern[i],
        timestamp: date,
        note: notes[i],
        tags: _moodTags(moodPattern[i]),
      ));
    }

    // Today's mood
    entries.add(MoodEntry(
      id: _uuid.v4(),
      mood: MoodLevel.good,
      timestamp: DateTime(now.year, now.month, now.day, now.hour > 8 ? 8 : now.hour, 30),
      note: 'Ready for a good day ☀️',
      tags: ['morning', 'motivated'],
    ));

    final jsonList = entries.map((e) => e.toJson()).toList();
    await StorageService.setString('mood_entries', jsonEncode(jsonList));
  }

  static List<String>? _moodTags(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.excellent:
        return ['grateful', 'energetic'];
      case MoodLevel.good:
        return ['productive'];
      case MoodLevel.neutral:
        return null;
      case MoodLevel.poor:
        return ['stressed'];
      case MoodLevel.terrible:
        return ['anxious'];
    }
  }

  // ─── Journal entries ────────────────────────────────────────
  static Future<void> _seedJournal() async {
    final now = DateTime.now();
    final entries = <JournalEntry>[
      JournalEntry(
        id: _uuid.v4(),
        content: 'Today I tried the 4-7-8 breathing technique for the first time. I was skeptical at first, but after three rounds I noticed my heart rate actually slowing down. The tension in my shoulders melted away. I want to make this a daily habit.\n\nNote to self: do this before bed tonight.',
        timestamp: DateTime(now.year, now.month, now.day - 1, 21, 15),
        mood: 'good',
        type: JournalType.text,
        tags: ['breathing', 'self-care', 'evening'],
        aiInsight: 'You\'re building a wonderful relaxation routine. Breathing exercises before bed can improve sleep quality by up to 42%.',
      ),
      JournalEntry(
        id: _uuid.v4(),
        content: 'Had a difficult conversation with my manager about the project deadline. My first instinct was to panic and assume the worst. But I used the CBT reframing technique — asked myself "What evidence do I actually have?" Turns out, the situation wasn\'t nearly as bad as my anxiety made it seem.',
        timestamp: DateTime(now.year, now.month, now.day - 2, 18, 42),
        mood: 'neutral',
        type: JournalType.text,
        tags: ['work', 'CBT', 'growth'],
        aiInsight: 'Great use of cognitive reframing! Questioning automatic thoughts is a core skill that gets stronger with practice.',
      ),
      JournalEntry(
        id: _uuid.v4(),
        content: 'Woke up early and watched the sunrise from my balcony. There\'s something magical about those quiet morning moments before the world gets loud. I could hear birds singing and feel the cool air on my skin. These small moments of mindfulness are becoming my favorite part of the day.',
        timestamp: DateTime(now.year, now.month, now.day - 4, 6, 30),
        mood: 'excellent',
        type: JournalType.text,
        tags: ['mindfulness', 'morning', 'gratitude'],
        aiInsight: 'Morning mindfulness sets a positive tone for the entire day. Your awareness of sensory details shows deep present-moment attention.',
      ),
      JournalEntry(
        id: _uuid.v4(),
        content: 'Feeling overwhelmed today. Too many tasks, too little time. I need to remember that I can only do one thing at a time. Taking a deep breath and prioritizing.\n\n1. Finish the report\n2. Call mom\n3. Everything else can wait',
        timestamp: DateTime(now.year, now.month, now.day - 6, 14, 20),
        mood: 'poor',
        type: JournalType.text,
        tags: ['stress', 'work', 'planning'],
        aiInsight: 'Writing down priorities is a powerful stress management technique. You\'re already taking control by breaking overwhelm into manageable steps.',
      ),
      JournalEntry(
        id: _uuid.v4(),
        content: 'Completed my first full week of daily meditation! Started at 5 minutes and now I\'m up to 10. The difference in my focus and calm throughout the day is noticeable. My coworker even mentioned I seem more relaxed lately.',
        timestamp: DateTime(now.year, now.month, now.day - 8, 20, 0),
        mood: 'excellent',
        type: JournalType.text,
        tags: ['meditation', 'milestone', 'growth'],
        aiInsight: 'A week of consistent practice is a real achievement! Research shows meditation benefits compound — you\'re building neural pathways for calm.',
      ),
      JournalEntry(
        id: _uuid.v4(),
        content: 'Voice memo after my evening walk. Reflected on how much better I handle anxiety now compared to a month ago. The combination of journaling, breathing exercises, and talking to Simon has genuinely shifted something in me.',
        timestamp: DateTime(now.year, now.month, now.day - 10, 19, 45),
        mood: 'good',
        type: JournalType.voice,
        audioDuration: '2:34',
        tags: ['reflection', 'progress'],
      ),
    ];

    final jsonList = entries.map((e) => e.toJson()).toList();
    await StorageService.setString('journal_entries', jsonEncode(jsonList));
  }

  // ─── Gratitude entries ──────────────────────────────────────
  static Future<void> _seedGratitude() async {
    final now = DateTime.now();
    final entries = <GratitudeEntry>[
      GratitudeEntry(
        id: _uuid.v4(),
        timestamp: DateTime(now.year, now.month, now.day - 1, 9, 0),
        items: [
          'My morning coffee ritual — 5 minutes of peace',
          'A supportive friend who checked in on me',
          'The sunset that painted the sky purple and gold',
        ],
        reflection: 'Small moments of beauty are everywhere when I pay attention.',
      ),
      GratitudeEntry(
        id: _uuid.v4(),
        timestamp: DateTime(now.year, now.month, now.day - 2, 8, 30),
        items: [
          'A productive day at work — finished the big project',
          'Healthy lunch I cooked for myself',
          'The feeling of fresh sheets on my bed',
        ],
      ),
      GratitudeEntry(
        id: _uuid.v4(),
        timestamp: DateTime(now.year, now.month, now.day - 3, 9, 15),
        items: [
          'My body — it carried me through another day',
          'Access to clean water and warm shelter',
          'Music that lifts my mood instantly',
        ],
        reflection: 'Gratitude for the basics reminds me how much I have.',
      ),
      GratitudeEntry(
        id: _uuid.v4(),
        timestamp: DateTime(now.year, now.month, now.day - 5, 8, 45),
        items: [
          'A good night\'s sleep after trying the sleep meditation',
          'My pet greeting me at the door',
          'Learning something new today',
        ],
      ),
    ];

    final jsonList = entries.map((e) => e.toJson()).toList();
    await StorageService.setString('gratitude_entries', jsonEncode(jsonList));
  }

  // ─── CBT thought records ────────────────────────────────────
  static Future<void> _seedCbt() async {
    final now = DateTime.now();
    final records = <CbtRecord>[
      CbtRecord(
        id: _uuid.v4(),
        timestamp: DateTime(now.year, now.month, now.day - 3, 16, 30),
        situation: 'My friend cancelled our dinner plans at the last minute.',
        negativeThought: 'Nobody really wants to spend time with me. I\'m not important to anyone.',
        distortions: [CognitiveDistortion.overgeneralization, CognitiveDistortion.personalization],
        reframedThought: 'My friend had a valid reason — they weren\'t feeling well. They suggested rescheduling, which shows they do want to see me. One cancellation doesn\'t mean everyone feels this way.',
        beliefBefore: 75,
        beliefAfter: 20,
      ),
      CbtRecord(
        id: _uuid.v4(),
        timestamp: DateTime(now.year, now.month, now.day - 7, 10, 15),
        situation: 'Made a small mistake in my presentation at work.',
        negativeThought: 'I\'m terrible at my job. Everyone noticed and thinks I\'m incompetent.',
        distortions: [CognitiveDistortion.allOrNothing, CognitiveDistortion.magnification, CognitiveDistortion.jumpingToConclusions],
        reframedThought: 'A small mistake doesn\'t define my entire performance. My colleague said the presentation was great overall. Everyone makes mistakes — it\'s part of learning.',
        beliefBefore: 85,
        beliefAfter: 25,
      ),
    ];

    final jsonList = records.map((e) => e.toJson()).toList();
    await StorageService.setString('cbt_records', jsonEncode(jsonList));
  }

  // ─── User stats (streak, meditation minutes, etc.) ──────────
  static Future<void> _seedStats() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final stats = {
      'totalMeditationMinutes': 185,
      'totalJournalEntries': 6,
      'currentStreak': 7,
      'longestStreak': 7,
      'totalMoodEntries': 15,
      'averageMood': 3.8,
      'moodImprovementPercent': 15,
    };

    await StorageService.setString('user_stats', jsonEncode(stats));
    await StorageService.setString('last_activity_date', today.toIso8601String());

    // Seed breathing sessions for today
    final todayStr = '${now.year}-${now.month}-${now.day}';
    await StorageService.setInt('breathing_sessions_today', 1);
    await StorageService.setString('breathing_sessions_date', todayStr);
  }
}
