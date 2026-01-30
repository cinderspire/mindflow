import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/mood_entry.dart';
import '../../../../core/providers/mood_provider.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';

class MoodChart extends ConsumerWidget {
  const MoodChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyMoods = ref.watch(weeklyMoodsProvider);
    final moodTrend = ref.watch(moodTrendProvider);
    final averageMood = ref.watch(averageMoodProvider);

    // Generate data for the last 7 days
    final List<Map<String, dynamic>> weekData = _generateWeekData(weeklyMoods);

    // Calculate trend percentage
    final trendPercentage = _calculateTrendPercentage(moodTrend, averageMood);

    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Overview',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: _getTrendGradient(moodTrend),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getTrendIcon(moodTrend),
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trendPercentage,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Chart
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekData.map((data) {
                return _buildBar(
                  day: data['day'] as String,
                  value: data['value'] as double,
                  mood: data['mood'] as String,
                  hasData: data['hasData'] as bool,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateWeekData(List<MoodEntry> moods) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> weekData = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = DateFormat('E').format(date);

      // Find mood entry for this date
      final moodEntry = moods.where((m) =>
        m.timestamp.year == date.year &&
        m.timestamp.month == date.month &&
        m.timestamp.day == date.day
      ).toList();

      if (moodEntry.isNotEmpty) {
        final mood = moodEntry.first.mood;
        weekData.add({
          'day': dayName,
          'value': mood.value / 5.0,
          'mood': mood.name,
          'hasData': true,
        });
      } else {
        weekData.add({
          'day': dayName,
          'value': 0.1,
          'mood': 'none',
          'hasData': false,
        });
      }
    }

    return weekData;
  }

  String _calculateTrendPercentage(String trend, double average) {
    switch (trend) {
      case 'improving':
        return '+${((average - 3) / 3 * 100).abs().toInt()}%';
      case 'declining':
        return '-${((3 - average) / 3 * 100).abs().toInt()}%';
      default:
        return '0%';
    }
  }

  LinearGradient _getTrendGradient(String trend) {
    switch (trend) {
      case 'improving':
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
        );
      case 'declining':
        return const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFE91E63)],
        );
      default:
        return AppColors.primaryGradient;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'improving':
        return Icons.trending_up_rounded;
      case 'declining':
        return Icons.trending_down_rounded;
      default:
        return Icons.trending_flat_rounded;
    }
  }

  Widget _buildBar({
    required String day,
    required double value,
    required String mood,
    required bool hasData,
  }) {
    Color getMoodColor() {
      switch (mood) {
        case 'excellent':
          return AppColors.moodExcellent;
        case 'good':
          return AppColors.moodGood;
        case 'neutral':
          return AppColors.moodNeutral;
        case 'poor':
          return AppColors.moodPoor;
        case 'terrible':
          return AppColors.moodTerrible;
        default:
          return AppColors.textTertiaryDark.withOpacity(0.3);
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          width: 32,
          height: 120 * value,
          decoration: BoxDecoration(
            gradient: hasData
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      getMoodColor(),
                      getMoodColor().withOpacity(0.6),
                    ],
                  )
                : null,
            color: hasData ? null : getMoodColor(),
            borderRadius: BorderRadius.circular(8),
            boxShadow: hasData
                ? [
                    BoxShadow(
                      color: getMoodColor().withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: AppTextStyles.labelSmall.copyWith(
            color: hasData ? AppColors.textSecondaryDark : AppColors.textTertiaryDark,
          ),
        ),
      ],
    );
  }
}
