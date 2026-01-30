import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';

class JournalEntryCard extends StatelessWidget {
  final DateTime date;
  final String content;
  final String mood;
  final String type;
  final String? aiInsight;
  final String? duration;
  final VoidCallback onTap;

  const JournalEntryCard({
    super.key,
    required this.date,
    required this.content,
    required this.mood,
    required this.type,
    this.aiInsight,
    this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date, mood, and type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      _getMoodEmoji(),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(date),
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatTime(date),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildTypeIndicator(),
              ],
            ),

            const SizedBox(height: 12),

            // Content preview
            Text(
              content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
                height: 1.5,
              ),
            ),

            // Voice duration if applicable
            if (type == 'voice' && duration != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.play_circle_filled_rounded,
                    color: AppColors.primaryPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    duration!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
            ],

            // AI Insight
            if (aiInsight != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryPurple.withValues(alpha: 0.1),
                      AppColors.primaryBlue.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryPurple.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.primaryPurple,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        aiInsight!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: type == 'voice'
            ? AppColors.primaryTeal.withValues(alpha: 0.2)
            : AppColors.primaryPurple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            type == 'voice' ? Icons.mic_rounded : Icons.edit_rounded,
            size: 14,
            color: type == 'voice' ? AppColors.primaryTeal : AppColors.primaryPurple,
          ),
          const SizedBox(width: 4),
          Text(
            type == 'voice' ? 'Voice' : 'Text',
            style: AppTextStyles.labelSmall.copyWith(
              color: type == 'voice' ? AppColors.primaryTeal : AppColors.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji() {
    switch (mood) {
      case 'excellent':
        return '😄';
      case 'good':
        return '😊';
      case 'neutral':
        return '😐';
      case 'poor':
        return '😕';
      case 'terrible':
        return '😢';
      default:
        return '😐';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  String _formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }
}
