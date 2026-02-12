import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/revenuecat_service.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';
import '../../../paywall/presentation/screens/paywall_screen.dart';
import '../../../coach/presentation/screens/ai_coach_screen.dart';
import '../../../sleep/presentation/screens/sleep_stories_screen.dart';
import '../../../affirmations/presentation/screens/affirmations_screen.dart';
import '../../../bodyscan/presentation/screens/body_scan_screen.dart';
import '../../../meditation/presentation/screens/meditation_screen.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Discover', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          if (!isPremium)
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen(), fullscreenDialog: true)),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.diamond_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text('PRO', style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundDark, AppColors.backgroundDark.withBlue(40), AppColors.backgroundDark.withGreen(30)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Coach banner
                _buildCoachBanner(context, ref, isPremium),
                const SizedBox(height: 24),

                Text('Wellness Tools', style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Grid of features
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.1,
                  children: [
                    _FeatureCard(
                      icon: Icons.self_improvement_rounded,
                      title: 'Meditations',
                      subtitle: 'Guided sessions',
                      gradient: AppColors.meditationGradient,
                      isPremium: false,
                      onTap: () => _navigate(context, const MeditationScreen()),
                    ),
                    _FeatureCard(
                      icon: Icons.bedtime_rounded,
                      title: 'Sleep Stories',
                      subtitle: 'Drift to sleep',
                      gradient: const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF4C3F91)]),
                      isPremium: true,
                      isLocked: !isPremium,
                      onTap: () {
                        if (isPremium) {
                          _navigate(context, const SleepStoriesScreen());
                        } else {
                          showPaywallIfNeeded(context, ref, featureName: 'Sleep Stories');
                        }
                      },
                    ),
                    _FeatureCard(
                      icon: Icons.accessibility_new_rounded,
                      title: 'Body Scan',
                      subtitle: 'Progressive relax',
                      gradient: const LinearGradient(colors: [Color(0xFF4CE6C8), Color(0xFF0D4F4F)]),
                      isPremium: true,
                      isLocked: !isPremium,
                      onTap: () {
                        if (isPremium) {
                          _navigate(context, const BodyScanScreen());
                        } else {
                          showPaywallIfNeeded(context, ref, featureName: 'Body Scan');
                        }
                      },
                    ),
                    _FeatureCard(
                      icon: Icons.auto_awesome,
                      title: 'Affirmations',
                      subtitle: 'Daily positivity',
                      gradient: const LinearGradient(colors: [Color(0xFFFFA726), Color(0xFF4C3F91)]),
                      isPremium: true,
                      isLocked: !isPremium,
                      onTap: () {
                        if (isPremium) {
                          _navigate(context, const AffirmationsScreen());
                        } else {
                          showPaywallIfNeeded(context, ref, featureName: 'Affirmations');
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Free tier note
                if (!isPremium)
                  GlassCard(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen(), fullscreenDialog: true)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.diamond_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Unlock Everything', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
                              Text('AI Coach, Sleep Stories, Body Scan & more', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiaryDark, size: 16),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoachBanner(BuildContext context, WidgetRef ref, bool isPremium) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (isPremium) {
          _navigate(context, const AiCoachScreen());
        } else {
          showPaywallIfNeeded(context, ref, featureName: 'AI Coach');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.primaryPurple.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Stack(
          children: [
            Positioned(right: -20, top: -20, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.psychology_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text('AI COACH', style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ],
                      ),
                    ),
                    if (!isPremium) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)),
                        child: Text('PRO', style: AppTextStyles.caption.copyWith(color: Colors.amber, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text('Talk to Simon', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Your personal AI wellness coach.\nCBT techniques, mindfulness guidance, and emotional support.', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8), height: 1.5)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_rounded, color: AppColors.primaryPurple, size: 18),
                      const SizedBox(width: 8),
                      Text('Start Session', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryPurple)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final bool isPremium;
  final bool isLocked;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.isPremium = false,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
              ],
            ),
            if (isLocked)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.lock_rounded, color: Colors.amber, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
