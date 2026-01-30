import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/gratitude_entry.dart';
import '../../../../core/providers/gratitude_provider.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';
import '../../../../shared/widgets/gradient_button.dart';

class GratitudeScreen extends ConsumerStatefulWidget {
  const GratitudeScreen({super.key});

  @override
  ConsumerState<GratitudeScreen> createState() => _GratitudeScreenState();
}

class _GratitudeScreenState extends ConsumerState<GratitudeScreen> {
  final _item1Controller = TextEditingController();
  final _item2Controller = TextEditingController();
  final _item3Controller = TextEditingController();
  final _reflectionController = TextEditingController();

  @override
  void dispose() {
    _item1Controller.dispose();
    _item2Controller.dispose();
    _item3Controller.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(gratitudeProvider);
    final todaysEntry = ref.watch(todaysGratitudeProvider);
    final weeklyEntries = ref.watch(weeklyGratitudeProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gratitude Journal',
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
                // Weekly Summary Card
                _buildWeeklySummary(weeklyEntries),

                const SizedBox(height: 24),

                // Today's Entry or New Entry Form
                if (todaysEntry != null)
                  _buildTodaysEntry(todaysEntry)
                else
                  _buildNewEntryForm(),

                const SizedBox(height: 24),

                // Past Entries
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Past Entries',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (entries.isEmpty)
                  _buildEmptyState()
                else
                  ...entries.take(10).map((entry) => _buildEntryCard(entry)),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklySummary(List<GratitudeEntry> weeklyEntries) {
    final daysCount = weeklyEntries.length;
    final totalItems = weeklyEntries.fold<int>(0, (sum, e) => sum + e.items.length);
    final themes = ref.read(gratitudeProvider.notifier).getWeeklyThemes();
    final topThemes = themes.entries.take(4).map((e) => e.key).toList();

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
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
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
                      'This Week',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$daysCount days, $totalItems things grateful for',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (topThemes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Common themes:',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topThemes.map((theme) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    theme,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryTeal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTodaysEntry(GratitudeEntry entry) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🙏', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                "Today's Gratitude",
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Done',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...entry.items.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${e.key + 1}. ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (entry.reflection != null && entry.reflection!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                entry.reflection!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryDark,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNewEntryForm() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🙏', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                'What are you grateful for?',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Write 3 things you appreciate today',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiaryDark,
            ),
          ),
          const SizedBox(height: 20),
          _buildGratitudeField(1, _item1Controller),
          const SizedBox(height: 12),
          _buildGratitudeField(2, _item2Controller),
          const SizedBox(height: 12),
          _buildGratitudeField(3, _item3Controller),
          const SizedBox(height: 16),
          TextField(
            controller: _reflectionController,
            maxLines: 2,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimaryDark,
            ),
            decoration: InputDecoration(
              hintText: 'Optional reflection...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiaryDark,
              ),
            ),
          ),
          const SizedBox(height: 20),
          GradientButton(
            text: 'Save Gratitude',
            onPressed: _saveEntry,
            icon: Icons.favorite_rounded,
            width: double.infinity,
            height: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildGratitudeField(int number, TextEditingController controller) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$number',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimaryDark,
            ),
            decoration: InputDecoration(
              hintText: 'I am grateful for...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiaryDark,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(GratitudeEntry entry) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM d, yyyy').format(entry.timestamp),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textTertiaryDark,
                ),
              ),
              Text(
                DateFormat('h:mm a').format(entry.timestamp),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...entry.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    size: 14,
                    color: AppColors.primaryTeal.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.favorite_outline_rounded,
              size: 60,
              color: AppColors.textTertiaryDark.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No entries yet',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your gratitude practice above',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveEntry() {
    final items = [
      _item1Controller.text.trim(),
      _item2Controller.text.trim(),
      _item3Controller.text.trim(),
    ].where((s) => s.isNotEmpty).toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please write at least one thing you are grateful for',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final entry = GratitudeEntry(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      items: items,
      reflection: _reflectionController.text.trim().isEmpty
          ? null
          : _reflectionController.text.trim(),
    );

    ref.read(gratitudeProvider.notifier).addEntry(entry);
    ref.read(profileStatsProvider.notifier).recordActivity();
    HapticFeedback.mediumImpact();

    _item1Controller.clear();
    _item2Controller.clear();
    _item3Controller.clear();
    _reflectionController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Gratitude saved! Keep up the practice.',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
