import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MoodSelector extends StatefulWidget {
  final String selectedMood;
  final Function(String) onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _moods = [
    {
      'id': 'terrible',
      'emoji': '😢',
      'label': 'Terrible',
      'color': AppColors.moodTerrible,
    },
    {
      'id': 'poor',
      'emoji': '😕',
      'label': 'Poor',
      'color': AppColors.moodPoor,
    },
    {
      'id': 'neutral',
      'emoji': '😐',
      'label': 'Neutral',
      'color': AppColors.moodNeutral,
    },
    {
      'id': 'good',
      'emoji': '😊',
      'label': 'Good',
      'color': AppColors.moodGood,
    },
    {
      'id': 'excellent',
      'emoji': '😄',
      'label': 'Excellent',
      'color': AppColors.moodExcellent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _moods.map((mood) {
              final isSelected = widget.selectedMood == mood['id'];
              
              return GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _bounceController.forward(from: 0);
                  widget.onMoodSelected(mood['id'] as String);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              mood['color'] as Color,
                              (mood['color'] as Color).withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.white.withValues(alpha: 0.1),
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (mood['color'] as Color).withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: isSelected
                        ? AnimatedBuilder(
                            animation: _bounceAnimation,
                            builder: (context, child) => Transform.scale(
                              scale: _bounceAnimation.value,
                              child: child,
                            ),
                            child: Text(
                              mood['emoji'] as String,
                              style: const TextStyle(fontSize: 32),
                            ),
                          )
                        : Text(
                            mood['emoji'] as String,
                            style: const TextStyle(fontSize: 28),
                          ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Selected Mood Label
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _moods.firstWhere(
                (mood) => mood['id'] == widget.selectedMood,
              )['label'] as String,
              key: ValueKey(widget.selectedMood),
              style: AppTextStyles.titleMedium.copyWith(
                color: _moods.firstWhere(
                  (mood) => mood['id'] == widget.selectedMood,
                )['color'] as Color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
