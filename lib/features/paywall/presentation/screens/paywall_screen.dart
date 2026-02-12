import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/revenuecat_service.dart';
import '../../../../shared/widgets/gradient_button.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  final String? featureName;

  const PaywallScreen({super.key, this.featureName});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  int _selectedPlanIndex = 1; // Default to yearly

  static const _premiumFeatures = [
    _Feature(Icons.psychology_rounded, 'AI Wellness Coach',
        'Personalized coaching sessions powered by on-device AI'),
    _Feature(Icons.bedtime_rounded, 'Sleep Stories',
        'Calming narrated stories to drift into peaceful sleep'),
    _Feature(Icons.self_improvement_rounded, 'Unlimited Meditations',
        'Access all meditation sessions without limits'),
    _Feature(Icons.accessibility_new_rounded, 'Body Scan',
        'Guided progressive relaxation for deep rest'),
    _Feature(Icons.auto_awesome, 'Daily Affirmations',
        'Personalized positive affirmations every day'),
    _Feature(Icons.analytics_rounded, 'Advanced Analytics',
        'Deep insights into your wellness patterns'),
  ];

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryPurple.withValues(alpha: 0.3),
              AppColors.backgroundDark,
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textTertiaryDark),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Crown icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPurple.withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.diamond_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Unlock Simon Premium',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      if (widget.featureName != null)
                        Text(
                          '${widget.featureName} is a premium feature',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryPurple,
                          ),
                        ),

                      Text(
                        'Your complete AI wellness companion',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Features
                      ..._premiumFeatures.map((f) => _buildFeatureRow(f)),

                      const SizedBox(height: 32),

                      // Pricing plans
                      if (subscription.availablePackages.isNotEmpty) ...[
                        ...subscription.availablePackages
                            .asMap()
                            .entries
                            .map((entry) => _buildPlanCard(entry.key, entry.value)),
                      ] else ...[
                        // Fallback static plans
                        _buildStaticPlanCard(0, 'Monthly', '\$2.99/mo', false),
                        const SizedBox(height: 12),
                        _buildStaticPlanCard(1, 'Yearly', '\$14.99/yr', true),
                      ],

                      const SizedBox(height: 24),

                      // Purchase button
                      GradientButton(
                        text: subscription.isLoading ? 'Processing...' : 'Start Free Trial',
                        onPressed: subscription.isLoading
                            ? () {}
                            : () => _handlePurchase(subscription),
                        isLoading: subscription.isLoading,
                        icon: Icons.rocket_launch_rounded,
                      ),

                      const SizedBox(height: 16),

                      // Restore
                      TextButton(
                        onPressed: () async {
                          final restored = await ref
                              .read(subscriptionProvider.notifier)
                              .restorePurchases();
                          if (mounted) {
                            if (restored) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Purchases restored!')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No purchases to restore')),
                              );
                            }
                          }
                        },
                        child: Text(
                          'Restore Purchases',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiaryDark,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Legal
                      Text(
                        'Cancel anytime. Subscription auto-renews.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiaryDark,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),
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

  Widget _buildFeatureRow(_Feature feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: AppColors.primaryPurple, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                Text(
                  feature.description,
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

  Widget _buildPlanCard(int index, Package package) {
    final isSelected = _selectedPlanIndex == index;
    final isYearly = package.packageType == PackageType.annual;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primaryPurple.withValues(alpha: 0.2),
                    AppColors.primaryBlue.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.backgroundDarkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple
                : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primaryPurple : AppColors.textTertiaryDark,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.storeProduct.title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  Text(
                    package.storeProduct.priceString,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            if (isYearly)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'SAVE 50%',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticPlanCard(int index, String name, String price, bool isBestValue) {
    final isSelected = _selectedPlanIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primaryPurple.withValues(alpha: 0.2),
                    AppColors.primaryBlue.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.backgroundDarkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primaryPurple : AppColors.textTertiaryDark,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark)),
                  Text(price, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark)),
                ],
              ),
            ),
            if (isBestValue)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'BEST VALUE',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase(SubscriptionState subscription) async {
    if (subscription.availablePackages.isNotEmpty &&
        _selectedPlanIndex < subscription.availablePackages.length) {
      final package = subscription.availablePackages[_selectedPlanIndex];
      final success = await ref
          .read(subscriptionProvider.notifier)
          .purchasePackage(package);
      if (success && mounted) {
        Navigator.pop(context);
      }
    } else {
      // Demo mode — just show message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configure RevenueCat API keys to enable purchases'),
          ),
        );
      }
    }
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String description;

  const _Feature(this.icon, this.title, this.description);
}

/// Helper to show paywall when a premium feature is tapped
void showPaywallIfNeeded(BuildContext context, WidgetRef ref, {String? featureName}) {
  final isPremium = ref.read(isPremiumProvider);
  if (!isPremium) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaywallScreen(featureName: featureName),
        fullscreenDialog: true,
      ),
    );
  }
}
