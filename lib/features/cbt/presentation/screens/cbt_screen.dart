import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/cbt_record.dart';
import '../../../../core/providers/cbt_provider.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';
import '../../../../shared/widgets/gradient_button.dart';

class CbtScreen extends ConsumerStatefulWidget {
  const CbtScreen({super.key});

  @override
  ConsumerState<CbtScreen> createState() => _CbtScreenState();
}

class _CbtScreenState extends ConsumerState<CbtScreen> {
  @override
  Widget build(BuildContext context) {
    final records = ref.watch(cbtProvider);
    final commonDistortions = ref.watch(commonDistortionsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thought Record',
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
                // Info Card
                _buildInfoCard(),

                const SizedBox(height: 16),

                // Stats Card
                if (records.isNotEmpty)
                  _buildStatsCard(records, commonDistortions),

                const SizedBox(height: 16),

                // New Record Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GradientButton(
                    text: 'New Thought Record',
                    onPressed: _showNewRecordSheet,
                    icon: Icons.add_rounded,
                    width: double.infinity,
                  ),
                ),

                const SizedBox(height: 24),

                // Past Records
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Past Records',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (records.isEmpty)
                  _buildEmptyState()
                else
                  ...records.take(20).map((record) => _buildRecordCard(record)),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
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
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
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
                      'CBT Thought Record',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Challenge negative thinking patterns',
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
            'Cognitive Behavioral Therapy helps you identify and reframe negative thoughts. '
            'Record a situation, notice the automatic negative thought, identify the cognitive '
            'distortion, and create a balanced alternative thought.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    List<CbtRecord> records,
    Map<CognitiveDistortion, int> commonDistortions,
  ) {
    final avgReduction = ref.read(cbtProvider.notifier).getAverageBeliefReduction();
    final topDistortions = commonDistortions.entries.take(3).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Insights',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Records',
                  value: '${records.length}',
                  icon: Icons.description_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  label: 'Avg Reduction',
                  value: '${avgReduction.toStringAsFixed(0)}%',
                  icon: Icons.trending_down_rounded,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          if (topDistortions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Most common patterns:',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 8),
            ...topDistortions.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: AppColors.primaryPurple.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${e.key.label} (${e.value}x)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(CbtRecord record) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      onTap: () => _showRecordDetail(record),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM d, yyyy').format(record.timestamp),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textTertiaryDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${record.beliefBefore - record.beliefAfter}%',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            record.situation,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: record.distortions.map((d) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  d.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryPurple,
                    fontSize: 10,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showRecordDetail(CbtRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.backgroundDarkElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiaryDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM d, yyyy - h:mm a').format(record.timestamp),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textTertiaryDark,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildDetailSection(
                      'Situation',
                      record.situation,
                      Icons.place_rounded,
                      AppColors.primaryBlue,
                    ),
                    const SizedBox(height: 16),

                    _buildDetailSection(
                      'Negative Thought',
                      record.negativeThought,
                      Icons.cloud_rounded,
                      AppColors.error,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Cognitive Distortions',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...record.distortions.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 16, color: AppColors.warning),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.label,
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.textPrimaryDark,
                                  ),
                                ),
                                Text(
                                  d.description,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textTertiaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),

                    const SizedBox(height: 16),

                    _buildDetailSection(
                      'Reframed Thought',
                      record.reframedThought,
                      Icons.lightbulb_rounded,
                      AppColors.success,
                    ),
                    const SizedBox(height: 16),

                    // Belief meter
                    Row(
                      children: [
                        Expanded(
                          child: _buildBeliefMeter(
                            'Before',
                            record.beliefBefore,
                            AppColors.error,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBeliefMeter(
                            'After',
                            record.beliefAfter,
                            AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBeliefMeter(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value%',
            style: AppTextStyles.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'belief in thought',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiaryDark,
            ),
          ),
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
              Icons.psychology_outlined,
              size: 60,
              color: AppColors.textTertiaryDark.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No thought records yet',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button above to challenge a negative thought',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showNewRecordSheet() {
    final situationController = TextEditingController();
    final thoughtController = TextEditingController();
    final reframeController = TextEditingController();
    final selectedDistortions = <CognitiveDistortion>{};
    int beliefBefore = 80;
    int beliefAfter = 30;
    int step = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.85,
            decoration: const BoxDecoration(
              color: AppColors.backgroundDarkElevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiaryDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getStepTitle(step),
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Step ${step + 1}/4',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textTertiaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LinearProgressIndicator(
                    value: (step + 1) / 4,
                    backgroundColor: AppColors.backgroundDarkCard,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildStep(
                      step,
                      setModalState,
                      situationController,
                      thoughtController,
                      reframeController,
                      selectedDistortions,
                      beliefBefore,
                      beliefAfter,
                      (v) => setModalState(() => beliefBefore = v),
                      (v) => setModalState(() => beliefAfter = v),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      if (step > 0)
                        Expanded(
                          child: OutlineGradientButton(
                            text: 'Back',
                            onPressed: () => setModalState(() => step--),
                            height: 48,
                          ),
                        ),
                      if (step > 0) const SizedBox(width: 12),
                      Expanded(
                        child: GradientButton(
                          text: step < 3 ? 'Next' : 'Save Record',
                          onPressed: () {
                            if (step < 3) {
                              setModalState(() => step++);
                            } else {
                              _saveRecord(
                                ctx,
                                situationController.text.trim(),
                                thoughtController.text.trim(),
                                reframeController.text.trim(),
                                selectedDistortions.toList(),
                                beliefBefore,
                                beliefAfter,
                              );
                            }
                          },
                          icon: step < 3 ? Icons.arrow_forward_rounded : Icons.check_rounded,
                          height: 48,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0: return 'What happened?';
      case 1: return 'Negative thought';
      case 2: return 'Identify distortions';
      case 3: return 'Reframe the thought';
      default: return '';
    }
  }

  Widget _buildStep(
    int step,
    StateSetter setModalState,
    TextEditingController situationController,
    TextEditingController thoughtController,
    TextEditingController reframeController,
    Set<CognitiveDistortion> selectedDistortions,
    int beliefBefore,
    int beliefAfter,
    ValueChanged<int> onBeliefBeforeChanged,
    ValueChanged<int> onBeliefAfterChanged,
  ) {
    switch (step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Describe the situation that triggered a negative feeling.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: situationController,
              maxLines: 4,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. My friend cancelled our plans at the last minute...',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What negative thought popped into your mind?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: thoughtController,
              maxLines: 3,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Nobody really wants to spend time with me...',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'How strongly do you believe this thought? ($beliefBefore%)',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            Slider(
              value: beliefBefore.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              activeColor: AppColors.error,
              inactiveColor: AppColors.error.withValues(alpha: 0.2),
              onChanged: (v) => onBeliefBeforeChanged(v.round()),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Which cognitive distortions apply to this thought?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 16),
            ...CognitiveDistortion.values.map((distortion) {
              final isSelected = selectedDistortions.contains(distortion);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setModalState(() {
                    if (isSelected) {
                      selectedDistortions.remove(distortion);
                    } else {
                      selectedDistortions.add(distortion);
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryPurple.withValues(alpha: 0.2)
                        : AppColors.backgroundDarkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryPurple
                          : AppColors.glassBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: isSelected ? AppColors.primaryPurple : AppColors.textTertiaryDark,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              distortion.label,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isSelected
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textSecondaryDark,
                              ),
                            ),
                            Text(
                              distortion.description,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rewrite the thought in a more balanced, realistic way.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reframeController,
              maxLines: 4,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. My friend had a valid reason. We can reschedule and I have other people who care about me...',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'After reframing, how strongly do you believe the original negative thought? ($beliefAfter%)',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            Slider(
              value: beliefAfter.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              activeColor: AppColors.success,
              inactiveColor: AppColors.success.withValues(alpha: 0.2),
              onChanged: (v) => onBeliefAfterChanged(v.round()),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _saveRecord(
    BuildContext ctx,
    String situation,
    String negativeThought,
    String reframedThought,
    List<CognitiveDistortion> distortions,
    int beliefBefore,
    int beliefAfter,
  ) {
    if (situation.isEmpty || negativeThought.isEmpty || reframedThought.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all fields',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final record = CbtRecord(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      situation: situation,
      negativeThought: negativeThought,
      distortions: distortions.isEmpty ? [CognitiveDistortion.allOrNothing] : distortions,
      reframedThought: reframedThought,
      beliefBefore: beliefBefore,
      beliefAfter: beliefAfter,
    );

    ref.read(cbtProvider.notifier).addRecord(record);
    ref.read(profileStatsProvider.notifier).recordActivity();
    HapticFeedback.mediumImpact();
    Navigator.pop(ctx);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Thought record saved! Great work on reframing.',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
