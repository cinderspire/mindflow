import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../breathing/presentation/screens/breathing_screen.dart';

class CrisisResourcesScreen extends StatelessWidget {
  const CrisisResourcesScreen({super.key});

  static const List<Map<String, String>> _hotlines = [
    {
      'name': '988 Suicide & Crisis Lifeline',
      'number': '988',
      'description': 'Free, confidential 24/7 support for people in distress',
      'country': 'US',
    },
    {
      'name': 'Crisis Text Line',
      'number': 'Text HOME to 741741',
      'description': 'Free 24/7 crisis support via text message',
      'country': 'US',
    },
    {
      'name': 'SAMHSA Helpline',
      'number': '1-800-662-4357',
      'description': 'Free referral and information service for mental health',
      'country': 'US',
    },
    {
      'name': 'NAMI Helpline',
      'number': '1-800-950-6264',
      'description': 'National Alliance on Mental Illness support line',
      'country': 'US',
    },
    {
      'name': 'Samaritans',
      'number': '116 123',
      'description': '24-hour emotional support for anyone in the UK & Ireland',
      'country': 'UK',
    },
    {
      'name': 'Befrienders Worldwide',
      'number': 'befrienders.org',
      'description': 'International crisis center directory',
      'country': 'International',
    },
  ];

  static const List<Map<String, dynamic>> _copingStrategies = [
    {
      'title': 'Ground yourself (5-4-3-2-1)',
      'description': 'Name 5 things you see, 4 you feel, 3 you hear, 2 you smell, 1 you taste',
      'icon': Icons.nature_people_rounded,
    },
    {
      'title': 'Try box breathing',
      'description': 'Breathe in 4s, hold 4s, out 4s, hold 4s. Repeat 5 times.',
      'icon': Icons.air_rounded,
    },
    {
      'title': 'Hold ice or cold water',
      'description': 'The cold sensation can help interrupt intense emotions',
      'icon': Icons.ac_unit_rounded,
    },
    {
      'title': 'Move your body',
      'description': 'Walk, stretch, or do jumping jacks to release tension',
      'icon': Icons.directions_walk_rounded,
    },
    {
      'title': 'Call someone you trust',
      'description': 'Reach out to a friend, family member, or counselor',
      'icon': Icons.call_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Crisis Resources',
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
                // Emergency banner
                _buildEmergencyBanner(),

                const SizedBox(height: 24),

                // Quick breathing exercise
                _buildQuickBreathingCard(context),

                const SizedBox(height: 24),

                // Coping strategies
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Coping Strategies',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ..._copingStrategies.map((s) => _buildCopingCard(s)),

                const SizedBox(height: 24),

                // Hotlines
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Crisis Hotlines',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Free, confidential support available 24/7',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ..._hotlines.map((h) => _buildHotlineCard(h)),

                const SizedBox(height: 24),

                // Disclaimer
                _buildDisclaimer(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFFF5252)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emergency_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'If you are in immediate danger',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Please call emergency services (911)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'You are not alone. Help is available right now.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBreathingCard(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.air_rounded,
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
                      'Quick Breathing Exercise',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Calm your nervous system in minutes',
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
          GradientButton(
            text: 'Start Breathing Exercise',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BreathingScreen(),
                ),
              );
            },
            icon: Icons.play_arrow_rounded,
            width: double.infinity,
            height: 48,
            gradient: const LinearGradient(
              colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopingCard(Map<String, dynamic> strategy) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              strategy['icon'] as IconData,
              color: AppColors.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strategy['title'] as String,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  strategy['description'] as String,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotlineCard(Map<String, String> hotline) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.phone_rounded,
              color: AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hotline['name']!,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.textTertiaryDark.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hotline['country']!,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiaryDark,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  hotline['number']!,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hotline['description']!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.textTertiaryDark,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Important Notice',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.textSecondaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'MindFlow is a wellness tool and is not a substitute for professional medical advice, diagnosis, or treatment. If you are experiencing a mental health emergency, please contact emergency services or a crisis hotline immediately.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiaryDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
