import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/mood_entry.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/providers/mood_provider.dart';
import '../../../../core/providers/journal_provider.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allMoods = ref.watch(moodProvider);
    final averageMood = ref.watch(averageMoodProvider);
    final moodTrend = ref.watch(moodTrendProvider);
    final journalCount = ref.watch(journalCountProvider);
    final stats = ref.watch(profileStatsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              AppColors.backgroundDark.withBlue(40),
              AppColors.backgroundDark.withGreen(30),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                _buildSummaryCards(stats, averageMood, journalCount),

                const SizedBox(height: 24),

                // Weekly Mood Line Chart
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Mood Over Time',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildMoodLineChart(allMoods),

                const SizedBox(height: 24),

                // Mood Distribution
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Mood Distribution',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildMoodDistribution(allMoods),

                const SizedBox(height: 24),

                // Insights
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Insights & Patterns',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildInsights(allMoods, moodTrend, averageMood, stats),

                const SizedBox(height: 24),

                // Streak Visualization
                if (stats.currentStreak > 0 || stats.longestStreak > 0) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Your Streak',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStreakVisualization(stats),
                  const SizedBox(height: 24),
                ],

                // Activity Heatmap
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Activity This Month',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildActivityGrid(allMoods),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakVisualization(UserStats stats) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              // Current streak
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withValues(alpha: 0.15),
                        Colors.orange.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        '${stats.currentStreak}',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Current Streak',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Longest streak
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondaryLavender.withValues(alpha: 0.15),
                        AppColors.secondaryLavenderDark.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        '${stats.longestStreak}',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.secondaryLavender,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Longest Streak',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (stats.currentStreak > 0) ...[
            const SizedBox(height: 16),
            // Streak progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                stats.currentStreak.clamp(0, 14),
                (i) => Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withValues(alpha: 0.6 + (i / 14) * 0.4),
                        Colors.orange.withValues(alpha: 0.4 + (i / 14) * 0.6),
                      ],
                    ),
                  ),
                  child: i == stats.currentStreak.clamp(0, 14) - 1
                      ? const Icon(Icons.star_rounded, color: Colors.white, size: 10)
                      : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
      UserStats stats, double averageMood, int journalCount) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          _summaryCard(
            icon: Icons.local_fire_department_rounded,
            value: '${stats.currentStreak}',
            label: 'Day Streak',
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            ),
          ),
          _summaryCard(
            icon: Icons.emoji_emotions_rounded,
            value: averageMood.toStringAsFixed(1),
            label: 'Avg Mood',
            gradient: const LinearGradient(
              colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
            ),
          ),
          _summaryCard(
            icon: Icons.edit_note_rounded,
            value: '$journalCount',
            label: 'Entries',
            gradient: AppColors.primaryGradient,
          ),
          _summaryCard(
            icon: Icons.self_improvement_rounded,
            value: '${(stats.totalMeditationMinutes / 60).toStringAsFixed(1)}h',
            label: 'Meditation',
            gradient: AppColors.meditationGradient,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String value,
    required String label,
    required Gradient gradient,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (gradient as LinearGradient).colors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodLineChart(List<MoodEntry> allMoods) {
    final now = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayMoods = allMoods.where((m) =>
          m.timestamp.year == date.year &&
          m.timestamp.month == date.month &&
          m.timestamp.day == date.day);

      if (dayMoods.isNotEmpty) {
        final avg = dayMoods.fold<int>(0, (s, m) => s + m.mood.value) /
            dayMoods.length;
        spots.add(FlSpot((6 - i).toDouble(), avg));
      }
    }

    if (spots.isEmpty) {
      return GlassCard(
        child: SizedBox(
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.85, end: 1.0),
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Icon(
                  Icons.show_chart_rounded,
                  size: 48,
                  color: AppColors.primaryPurple.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Track your mood daily to see trends here',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GlassCard(
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: AppColors.glassBorder,
                strokeWidth: 0.5,
              ),
            ),
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final emojis = ['', '😢', '😕', '😐', '😊', '😄'];
                    if (value >= 1 && value <= 5) {
                      return Text(
                        emojis[value.toInt()],
                        style: const TextStyle(fontSize: 14),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final date =
                        now.subtract(Duration(days: 6 - value.toInt()));
                    return Text(
                      DateFormat('E').format(date),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiaryDark,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 6,
            minY: 0.5,
            maxY: 5.5,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.3,
                gradient: AppColors.primaryGradient,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 5,
                    color: AppColors.primaryPurple,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryPurple.withValues(alpha: 0.3),
                      AppColors.primaryBlue.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodDistribution(List<MoodEntry> allMoods) {
    if (allMoods.isEmpty) {
      return GlassCard(
        child: SizedBox(
          height: 140,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 44,
                color: AppColors.primaryBlue.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'No mood data yet',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start tracking to see distribution.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final counts = <MoodLevel, int>{};
    for (final mood in MoodLevel.values) {
      counts[mood] = allMoods.where((m) => m.mood == mood).length;
    }
    final total = allMoods.length;

    return GlassCard(
      child: Column(
        children: MoodLevel.values.reversed.map((mood) {
          final count = counts[mood] ?? 0;
          final percent = total > 0 ? count / total : 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    mood.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: Text(
                    mood.label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: AppColors.backgroundDarkCard,
                      valueColor: AlwaysStoppedAnimation<Color>(mood.color),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${(percent * 100).toInt()}%',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsights(List<MoodEntry> allMoods, String moodTrend,
      double averageMood, UserStats stats) {
    final insights = <Map<String, dynamic>>[];

    // Trend insight
    if (allMoods.length >= 3) {
      IconData icon;
      Color color;
      String text;
      switch (moodTrend) {
        case 'improving':
          icon = Icons.trending_up_rounded;
          color = AppColors.success;
          text =
              'Your mood is trending upward! Keep maintaining your routines.';
          break;
        case 'declining':
          icon = Icons.trending_down_rounded;
          color = AppColors.warning;
          text =
              'Your mood has dipped recently. Try a breathing exercise or journal about your feelings.';
          break;
        default:
          icon = Icons.trending_flat_rounded;
          color = AppColors.primaryBlue;
          text =
              'Your mood has been steady. Consistent self-care helps maintain balance.';
      }
      insights.add({'icon': icon, 'color': color, 'text': text});
    }

    // Streak insight
    if (stats.currentStreak >= 3) {
      insights.add({
        'icon': Icons.local_fire_department_rounded,
        'color': const Color(0xFFFF6B6B),
        'text':
            'You are on a ${stats.currentStreak}-day streak! Consistency builds lasting habits.',
      });
    }

    // Average mood insight
    if (averageMood >= 4.0) {
      insights.add({
        'icon': Icons.star_rounded,
        'color': AppColors.moodExcellent,
        'text':
            'Your average mood is ${averageMood.toStringAsFixed(1)}/5 -- you are doing great!',
      });
    } else if (averageMood < 3.0 && allMoods.isNotEmpty) {
      insights.add({
        'icon': Icons.favorite_rounded,
        'color': AppColors.moodPoor,
        'text':
            'Your average mood is lower than usual. Remember to be gentle with yourself.',
      });
    }

    // Best time insight
    if (allMoods.length >= 5) {
      final morningMoods = allMoods
          .where((m) => m.timestamp.hour >= 6 && m.timestamp.hour < 12);
      final eveningMoods =
          allMoods.where((m) => m.timestamp.hour >= 18);
      if (morningMoods.isNotEmpty && eveningMoods.isNotEmpty) {
        final morningAvg =
            morningMoods.fold<int>(0, (s, m) => s + m.mood.value) /
                morningMoods.length;
        final eveningAvg =
            eveningMoods.fold<int>(0, (s, m) => s + m.mood.value) /
                eveningMoods.length;
        if (morningAvg > eveningAvg + 0.5) {
          insights.add({
            'icon': Icons.wb_sunny_rounded,
            'color': AppColors.moodNeutral,
            'text':
                'You tend to feel better in the mornings. Consider scheduling important tasks early.',
          });
        } else if (eveningAvg > morningAvg + 0.5) {
          insights.add({
            'icon': Icons.nightlight_round,
            'color': AppColors.primaryBlue,
            'text':
                'Your mood improves in the evenings. Wind down with a relaxing routine.',
          });
        }
      }
    }

    if (insights.isEmpty) {
      insights.add({
        'icon': Icons.lightbulb_outline_rounded,
        'color': AppColors.primaryPurple,
        'text':
            'Keep tracking your mood daily to unlock personalized insights and patterns.',
      });
    }

    return Column(
      children: insights.map((insight) {
        return GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      (insight['color'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  insight['icon'] as IconData,
                  color: insight['color'] as Color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  insight['text'] as String,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityGrid(List<MoodEntry> allMoods) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    // Build a set of dates with mood entries
    final activeDates = <int>{};
    final moodByDay = <int, MoodLevel>{};
    for (final mood in allMoods) {
      if (mood.timestamp.year == now.year &&
          mood.timestamp.month == now.month) {
        activeDates.add(mood.timestamp.day);
        moodByDay[mood.timestamp.day] = mood.mood;
      }
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(now),
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => SizedBox(
                      width: 36,
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiaryDark,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          ..._buildWeeks(firstDayOfMonth, daysInMonth, now.day, moodByDay),
        ],
      ),
    );
  }

  List<Widget> _buildWeeks(DateTime firstDay, int daysInMonth, int today,
      Map<int, MoodLevel> moodByDay) {
    final widgets = <Widget>[];
    // Monday = 1, Sunday = 7 in Dart
    int weekday = firstDay.weekday; // 1=Mon
    int day = 1;

    while (day <= daysInMonth) {
      final cells = <Widget>[];
      for (int w = 1; w <= 7; w++) {
        if ((widgets.isEmpty && w < weekday) || day > daysInMonth) {
          cells.add(const SizedBox(width: 36, height: 36));
        } else {
          final d = day;
          final hasMood = moodByDay.containsKey(d);
          final mood = moodByDay[d];
          final isToday = d == today;

          cells.add(
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasMood
                    ? mood!.color.withValues(alpha: 0.7)
                    : isToday
                        ? AppColors.primaryPurple.withValues(alpha: 0.2)
                        : Colors.transparent,
                border: isToday
                    ? Border.all(color: AppColors.primaryPurple, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$d',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: hasMood
                        ? Colors.white
                        : d <= today
                            ? AppColors.textSecondaryDark
                            : AppColors.textTertiaryDark.withValues(alpha: 0.4),
                    fontWeight:
                        isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
          day++;
        }
      }
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: cells,
        ),
      ));
    }
    return widgets;
  }
}
