import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/providers/mood_provider.dart';
import '../../../../core/providers/journal_provider.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';
import '../../../../shared/widgets/gradient_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final stats = ref.watch(profileStatsProvider);
    final averageMood = ref.watch(averageMoodProvider);
    final journalCount = ref.watch(journalCountProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Profile',
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
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(stats),

                const SizedBox(height: 24),

                // Stats Grid
                _buildStatsGrid(stats, averageMood, journalCount),

                const SizedBox(height: 24),

                // Premium Banner
                _buildPremiumBanner(),

                const SizedBox(height: 24),

                // Settings Section
                _buildSettingsSection(ref, settings),

                const SizedBox(height: 24),

                // Account Section
                _buildAccountSection(context),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '🧘',
                    style: TextStyle(fontSize: 48),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDarkElevated,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryPurple,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Mindful User',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'user@mindflow.app',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiaryDark,
            ),
          ),

          const SizedBox(height: 16),

          // Streak Badge
          if (stats.currentStreak > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withOpacity(0.2),
                    Colors.orange.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '${stats.currentStreak} Day Streak',
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
    );
  }

  Widget _buildStatsGrid(
      UserStats stats, double averageMood, int journalCount) {
    final moodPercent =
        ((averageMood / 5.0) * 100).toInt();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.self_improvement_rounded,
              value:
                  '${(stats.totalMeditationMinutes / 60).toStringAsFixed(1)}h',
              label: 'Meditation',
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.edit_note_rounded,
              value: '$journalCount',
              label: 'Journal Entries',
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.trending_up_rounded,
              value: '$moodPercent%',
              label: 'Mood Score',
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryPurple.withOpacity(0.3),
              AppColors.primaryBlue.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.amber,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unlock Premium',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Unlimited meditations, AI insights & more',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GradientButton(
              text: 'Start Free Trial',
              onPressed: () {},
              width: double.infinity,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(WidgetRef ref, UserSettings settings) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Settings',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textTertiaryDark,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          _buildSettingsToggle(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Daily reminders and updates',
            value: settings.notificationsEnabled,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              ref
                  .read(settingsProvider.notifier)
                  .setNotificationsEnabled(value);
            },
          ),
          _buildDivider(),
          _buildSettingsToggle(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Reduce eye strain',
            value: settings.darkModeEnabled,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              ref
                  .read(settingsProvider.notifier)
                  .setDarkModeEnabled(value);
            },
          ),
          _buildDivider(),
          _buildSettingsToggle(
            icon: Icons.vibration_rounded,
            title: 'Haptic Feedback',
            subtitle: 'Vibrations on interactions',
            value: settings.hapticEnabled,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              ref.read(settingsProvider.notifier).setHapticEnabled(value);
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: settings.language == 'en' ? 'English' : settings.language,
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.access_time_rounded,
            title: 'Reminder Time',
            subtitle: settings.reminderTime,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Account',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textTertiaryDark,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          _buildSettingsItem(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.lock_outline_rounded,
            title: 'Privacy & Security',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.info_outline_rounded,
            title: 'About MindFlow',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            textColor: AppColors.error,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryPurple, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.textPrimaryDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textTertiaryDark,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryPurple,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? AppColors.primaryPurple).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: textColor ?? AppColors.primaryPurple,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: textColor ?? AppColors.textPrimaryDark,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiaryDark,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textTertiaryDark,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.glassBorder,
      indent: 70,
      endIndent: 20,
    );
  }
}

