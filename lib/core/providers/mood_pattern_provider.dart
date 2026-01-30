// Mood Pattern Detection Provider for MindFlow
// Analyzes mood entries over time and detects patterns
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_entry.dart';
import 'mood_provider.dart';

class MoodPattern {
  final String title;
  final String description;
  final String icon;
  final PatternType type;

  MoodPattern({
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
  });
}

enum PatternType { dayOfWeek, timeOfDay, tag, streak, general }

class MoodPatternAnalyzer {
  /// Analyze mood entries and return detected patterns
  static List<MoodPattern> analyzePatterns(List<MoodEntry> moods) {
    final patterns = <MoodPattern>[];

    if (moods.length < 3) {
      patterns.add(MoodPattern(
        title: 'Keep tracking',
        description: 'Log at least 3 mood entries to start seeing patterns.',
        icon: 'lightbulb',
        type: PatternType.general,
      ));
      return patterns;
    }

    // 1. Day-of-week patterns
    patterns.addAll(_analyzeDayOfWeek(moods));

    // 2. Time-of-day patterns
    patterns.addAll(_analyzeTimeOfDay(moods));

    // 3. Tag correlations
    patterns.addAll(_analyzeTagCorrelations(moods));

    // 4. Streak / consistency patterns
    patterns.addAll(_analyzeConsistency(moods));

    // 5. Overall trend
    patterns.addAll(_analyzeOverallTrend(moods));

    if (patterns.isEmpty) {
      patterns.add(MoodPattern(
        title: 'Building your profile',
        description: 'Keep tracking daily to uncover deeper patterns in your mood.',
        icon: 'timeline',
        type: PatternType.general,
      ));
    }

    return patterns;
  }

  static List<MoodPattern> _analyzeDayOfWeek(List<MoodEntry> moods) {
    final patterns = <MoodPattern>[];
    final dayNames = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    // Group mood values by day of week
    final dayMoods = <int, List<int>>{};
    for (final mood in moods) {
      final day = mood.timestamp.weekday; // 1=Mon, 7=Sun
      dayMoods.putIfAbsent(day, () => []);
      dayMoods[day]!.add(mood.mood.value);
    }

    // Find best and worst days (need at least 2 entries per day)
    int? bestDay;
    int? worstDay;
    double bestAvg = 0;
    double worstAvg = 6;

    for (final entry in dayMoods.entries) {
      if (entry.value.length >= 2) {
        final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
        if (avg > bestAvg) {
          bestAvg = avg;
          bestDay = entry.key;
        }
        if (avg < worstAvg) {
          worstAvg = avg;
          worstDay = entry.key;
        }
      }
    }

    if (bestDay != null && bestAvg >= 3.5) {
      patterns.add(MoodPattern(
        title: '${dayNames[bestDay]}s are your best days',
        description: 'Your average mood on ${dayNames[bestDay]}s is ${bestAvg.toStringAsFixed(1)}/5. Consider what makes this day special.',
        icon: 'star',
        type: PatternType.dayOfWeek,
      ));
    }

    if (worstDay != null && worstAvg <= 3.0 && worstDay != bestDay) {
      patterns.add(MoodPattern(
        title: 'Your mood tends to dip on ${dayNames[worstDay]}s',
        description: 'Average mood on ${dayNames[worstDay]}s is ${worstAvg.toStringAsFixed(1)}/5. Planning enjoyable activities may help.',
        icon: 'info',
        type: PatternType.dayOfWeek,
      ));
    }

    // Weekend vs weekday comparison
    final weekdayMoods = <int>[];
    final weekendMoods = <int>[];
    for (final mood in moods) {
      if (mood.timestamp.weekday <= 5) {
        weekdayMoods.add(mood.mood.value);
      } else {
        weekendMoods.add(mood.mood.value);
      }
    }

    if (weekdayMoods.length >= 3 && weekendMoods.length >= 2) {
      final weekdayAvg = weekdayMoods.reduce((a, b) => a + b) / weekdayMoods.length;
      final weekendAvg = weekendMoods.reduce((a, b) => a + b) / weekendMoods.length;
      if ((weekendAvg - weekdayAvg).abs() > 0.5) {
        if (weekendAvg > weekdayAvg) {
          patterns.add(MoodPattern(
            title: 'You feel better on weekends',
            description: 'Your weekend mood averages ${weekendAvg.toStringAsFixed(1)} vs ${weekdayAvg.toStringAsFixed(1)} on weekdays. Work-life balance may need attention.',
            icon: 'weekend',
            type: PatternType.dayOfWeek,
          ));
        } else {
          patterns.add(MoodPattern(
            title: 'You feel better on weekdays',
            description: 'Your weekday mood averages ${weekdayAvg.toStringAsFixed(1)} vs ${weekendAvg.toStringAsFixed(1)} on weekends. Structured routines seem to help you.',
            icon: 'work',
            type: PatternType.dayOfWeek,
          ));
        }
      }
    }

    return patterns;
  }

  static List<MoodPattern> _analyzeTimeOfDay(List<MoodEntry> moods) {
    final patterns = <MoodPattern>[];
    final morningMoods = <int>[];
    final afternoonMoods = <int>[];
    final eveningMoods = <int>[];

    for (final mood in moods) {
      final hour = mood.timestamp.hour;
      if (hour >= 5 && hour < 12) {
        morningMoods.add(mood.mood.value);
      } else if (hour >= 12 && hour < 18) {
        afternoonMoods.add(mood.mood.value);
      } else {
        eveningMoods.add(mood.mood.value);
      }
    }

    final times = <String, List<int>>{
      'Morning': morningMoods,
      'Afternoon': afternoonMoods,
      'Evening': eveningMoods,
    };

    String? bestTime;
    double bestAvg = 0;

    for (final entry in times.entries) {
      if (entry.value.length >= 2) {
        final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
        if (avg > bestAvg) {
          bestAvg = avg;
          bestTime = entry.key;
        }
      }
    }

    if (bestTime != null && bestAvg >= 3.5) {
      patterns.add(MoodPattern(
        title: '$bestTime is your peak time',
        description: 'You tend to feel best during the $bestTime with an average mood of ${bestAvg.toStringAsFixed(1)}/5.',
        icon: bestTime == 'Morning' ? 'sunrise' : bestTime == 'Afternoon' ? 'sun' : 'moon',
        type: PatternType.timeOfDay,
      ));
    }

    return patterns;
  }

  static List<MoodPattern> _analyzeTagCorrelations(List<MoodEntry> moods) {
    final patterns = <MoodPattern>[];
    final tagMoods = <String, List<int>>{};

    for (final mood in moods) {
      if (mood.tags != null) {
        for (final tag in mood.tags!) {
          tagMoods.putIfAbsent(tag.toLowerCase(), () => []);
          tagMoods[tag.toLowerCase()]!.add(mood.mood.value);
        }
      }
    }

    for (final entry in tagMoods.entries) {
      if (entry.value.length >= 2) {
        final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
        if (avg >= 4.0) {
          patterns.add(MoodPattern(
            title: '"${entry.key}" days correlate with better mood',
            description: 'When you tag "${entry.key}", your average mood is ${avg.toStringAsFixed(1)}/5. Keep it up!',
            icon: 'trending_up',
            type: PatternType.tag,
          ));
        }
      }
    }

    return patterns;
  }

  static List<MoodPattern> _analyzeConsistency(List<MoodEntry> moods) {
    final patterns = <MoodPattern>[];

    // Count unique days tracked in last 14 days
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    final recentMoods = moods.where((m) => m.timestamp.isAfter(twoWeeksAgo)).toList();

    final uniqueDays = <String>{};
    for (final mood in recentMoods) {
      uniqueDays.add('${mood.timestamp.year}-${mood.timestamp.month}-${mood.timestamp.day}');
    }

    if (uniqueDays.length >= 10) {
      patterns.add(MoodPattern(
        title: 'Excellent consistency',
        description: 'You tracked your mood ${uniqueDays.length} out of 14 days. Consistent tracking leads to better self-awareness.',
        icon: 'check_circle',
        type: PatternType.streak,
      ));
    } else if (uniqueDays.length >= 5) {
      patterns.add(MoodPattern(
        title: 'Good tracking habit',
        description: 'You tracked ${uniqueDays.length} of the last 14 days. Try to make it a daily habit for better insights.',
        icon: 'thumb_up',
        type: PatternType.streak,
      ));
    }

    return patterns;
  }

  static List<MoodPattern> _analyzeOverallTrend(List<MoodEntry> moods) {
    final patterns = <MoodPattern>[];
    if (moods.length < 7) return patterns;

    // Compare first half vs second half of entries
    final midpoint = moods.length ~/ 2;
    final recentHalf = moods.sublist(0, midpoint);
    final olderHalf = moods.sublist(midpoint);

    final recentAvg = recentHalf.fold<int>(0, (s, m) => s + m.mood.value) / recentHalf.length;
    final olderAvg = olderHalf.fold<int>(0, (s, m) => s + m.mood.value) / olderHalf.length;
    final diff = recentAvg - olderAvg;

    if (diff > 0.5) {
      patterns.add(MoodPattern(
        title: 'Your mood is improving',
        description: 'Recent entries average ${recentAvg.toStringAsFixed(1)} vs ${olderAvg.toStringAsFixed(1)} previously. Your wellness efforts are paying off!',
        icon: 'trending_up',
        type: PatternType.general,
      ));
    } else if (diff < -0.5) {
      patterns.add(MoodPattern(
        title: 'Mood has been lower recently',
        description: 'Recent entries average ${recentAvg.toStringAsFixed(1)} vs ${olderAvg.toStringAsFixed(1)} previously. Consider trying a CBT exercise or talking to someone.',
        icon: 'favorite',
        type: PatternType.general,
      ));
    }

    return patterns;
  }
}

// Provider for mood patterns
final moodPatternsProvider = Provider<List<MoodPattern>>((ref) {
  final moods = ref.watch(moodProvider);
  return MoodPatternAnalyzer.analyzePatterns(moods);
});
