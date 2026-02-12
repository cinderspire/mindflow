import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/mood_entry.dart';
import '../../../../core/providers/mood_provider.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/providers/navigation_provider.dart';
import '../../../../core/providers/wellness_provider.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../widgets/mood_selector.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/mood_chart.dart';
import '../../../gratitude/presentation/screens/gratitude_screen.dart';
import '../../../cbt/presentation/screens/cbt_screen.dart';
import '../../../crisis/presentation/screens/crisis_screen.dart';
import '../../../coach/presentation/screens/ai_coach_screen.dart';
import '../../../../core/services/revenuecat_service.dart';
import '../../../paywall/presentation/screens/paywall_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedMood = 'neutral';
  bool _moodSavedToday = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final todaysMood = ref.read(todaysMoodProvider);
      if (todaysMood != null) {
        setState(() {
          _selectedMood = todaysMood.mood.name;
          _moodSavedToday = true;
        });
      }
    });
  }

  void _saveMoodWithNote(String moodId) {
    final noteController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.backgroundDarkElevated,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiaryDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add a note (optional)',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What is on your mind right now?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiaryDark,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 3,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Feeling grateful today...',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textTertiaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlineGradientButton(
                      text: 'Skip',
                      onPressed: () {
                        Navigator.pop(ctx);
                        _doSaveMood(moodId, null);
                      },
                      height: 48,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      text: 'Save',
                      onPressed: () {
                        Navigator.pop(ctx);
                        final note = noteController.text.trim().isEmpty
                            ? null
                            : noteController.text.trim();
                        _doSaveMood(moodId, note);
                      },
                      height: 48,
                      icon: Icons.check_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _doSaveMood(String moodId, String? note) async {
    final moodLevel = MoodLevel.fromString(moodId);
    final entry = MoodEntry(
      id: const Uuid().v4(),
      mood: moodLevel,
      timestamp: DateTime.now(),
      note: note,
    );
    await ref.read(moodProvider.notifier).addMood(entry);
    await ref.read(profileStatsProvider.notifier).recordActivity();
    setState(() {
      _selectedMood = moodId;
      _moodSavedToday = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weeklyMoods = ref.watch(weeklyMoodsProvider);
    final moodTrend = ref.watch(moodTrendProvider);
    final stats = ref.watch(profileStatsProvider);
    final wellnessScore = ref.watch(wellnessScoreProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        title: Text(
          'Simon',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emergency_rounded),
            tooltip: 'Crisis Resources',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CrisisResourcesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Cosmic background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.backgroundDark,
                  const Color(0xFF0F1B3D),
                  const Color(0xFF0A1628),
                ],
              ),
            ),
          ),
          // Decorative cosmic orbs
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondaryLavender.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondaryLavenderDark.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting with Streak
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 12 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good ${_getTimeOfDay()},',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.textSecondaryDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFFA78BFA), Color(0xFFC4B5FD), Color(0xFFF1F5F9)],
                                ).createShader(bounds),
                                child: Text(
                                  'How are you feeling?',
                                  style: AppTextStyles.headlineMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (stats.currentStreak > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.withValues(alpha: 0.2),
                                Colors.orange.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥',
                                  style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(
                                '${stats.currentStreak}',
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Wellness Score Card
                _buildWellnessScoreCard(wellnessScore),

                const SizedBox(height: 24),

                // Mood Check-in
                MoodSelector(
                  selectedMood: _selectedMood,
                  onMoodSelected: (mood) {
                    if (!_moodSavedToday) {
                      _saveMoodWithNote(mood);
                    } else {
                      setState(() => _selectedMood = mood);
                    }
                  },
                ),

                if (_moodSavedToday)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text(
                        "Today's mood recorded",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Quick Actions',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.edit_note_rounded,
                          title: 'Journal',
                          subtitle: 'Express yourself',
                          gradient: AppColors.primaryGradient,
                          onTap: () => ref
                              .read(selectedTabProvider.notifier)
                              .state = 1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.air_rounded,
                          title: 'Breathe',
                          subtitle: 'Find calm',
                          gradient: AppColors.calmGradient,
                          onTap: () => ref
                              .read(selectedTabProvider.notifier)
                              .state = 2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.favorite_rounded,
                          title: 'Gratitude',
                          subtitle: '3 daily thanks',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, animation, __) => const GratitudeScreen(),
                                transitionsBuilder: (_, animation, __, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.08),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      )),
                                      child: child,
                                    ),
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 400),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.psychology_rounded,
                          title: 'CBT',
                          subtitle: 'Reframe thoughts',
                          gradient: AppColors.meditationGradient,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, animation, __) => const CbtScreen(),
                                transitionsBuilder: (_, animation, __, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.08),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      )),
                                      child: child,
                                    ),
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 400),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.psychology_rounded,
                          title: 'AI Coach',
                          subtitle: 'Talk to Simon',
                          gradient: AppColors.primaryGradient,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            final isPremium = ref.read(isPremiumProvider);
                            if (isPremium) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AiCoachScreen()));
                            } else {
                              showPaywallIfNeeded(context, ref, featureName: 'AI Coach');
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.emergency_rounded,
                          title: 'Crisis Help',
                          subtitle: 'Get support',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE91E63), Color(0xFFFF5252)],
                          ),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, animation, __) => const CrisisResourcesScreen(),
                                transitionsBuilder: (_, animation, __, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 300),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Weekly Mood Chart
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Your Mood This Week',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const MoodChart(),

                const SizedBox(height: 30),

                // Daily Insight Card
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Daily Insight',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.textPrimaryDark,
                                  ),
                                ),
                                Text(
                                  'Based on your data',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textTertiaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getMoodInsight(moodTrend, weeklyMoods.length),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondaryDark,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GradientButton(
                        text: 'View Full Analysis',
                        onPressed: () =>
                            ref.read(selectedTabProvider.notifier).state = 3,
                        height: 48,
                        icon: Icons.analytics_outlined,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessScoreCard(WellnessScoreData score) {
    final Color scoreColor;
    final String scoreLabel;
    if (score.totalScore >= 80) {
      scoreColor = AppColors.moodExcellent;
      scoreLabel = 'Excellent';
    } else if (score.totalScore >= 60) {
      scoreColor = AppColors.moodGood;
      scoreLabel = 'Good';
    } else if (score.totalScore >= 40) {
      scoreColor = AppColors.moodNeutral;
      scoreLabel = 'Fair';
    } else if (score.totalScore >= 20) {
      scoreColor = AppColors.moodPoor;
      scoreLabel = 'Low';
    } else {
      scoreColor = AppColors.textTertiaryDark;
      scoreLabel = 'Start today';
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.95 + (0.05 * value),
            child: child,
          ),
        );
      },
      child: GlassCard(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Score circle
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(
                        value: score.totalScore / 100,
                        strokeWidth: 6,
                        backgroundColor: AppColors.backgroundDarkCard,
                        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${score.totalScore}',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: scoreColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wellness Score',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scoreLabel,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: scoreColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Log mood, journal, breathe & meditate to boost your score',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Score breakdown
          Row(
            children: [
              _buildScoreChip('Mood', score.moodScore, 40, AppColors.primaryPurple),
              const SizedBox(width: 8),
              _buildScoreChip('Journal', score.journalScore, 20, AppColors.primaryBlue),
              const SizedBox(width: 8),
              _buildScoreChip('Meditate', score.meditationScore, 20, AppColors.primaryTeal),
              const SizedBox(width: 8),
              _buildScoreChip('Breathe', score.breathingScore, 20, AppColors.moodGood),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildScoreChip(String label, int score, int maxScore, Color color) {
    final completed = score > 0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: completed ? color.withValues(alpha: 0.15) : AppColors.backgroundDarkCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: completed ? color.withValues(alpha: 0.4) : AppColors.glassBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              completed ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 16,
              color: completed ? color : AppColors.textTertiaryDark,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: completed ? color : AppColors.textTertiaryDark,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _getMoodInsight(String trend, int entriesCount) {
    if (entriesCount == 0) {
      return 'Start tracking your mood daily to see personalized insights and patterns. Tap on how you feel to begin!';
    }
    switch (trend) {
      case 'improving':
        return 'Your mood patterns show improvement this week! Keep maintaining your wellness routines for best results.';
      case 'declining':
        return 'Your mood has been a bit lower this week. Consider trying a breathing exercise or journaling to process your feelings.';
      default:
        return 'Your mood has been consistent this week. Regular check-ins help you understand your emotional patterns better.';
    }
  }
}
