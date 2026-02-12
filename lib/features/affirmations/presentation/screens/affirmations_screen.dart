import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

const _affirmations = [
  'I am at peace with who I am and where I am in life.',
  'I release all tension and embrace calm with every breath.',
  'I am worthy of love, happiness, and inner peace.',
  'My mind is clear, my heart is open, and my spirit is free.',
  'I choose to let go of what I cannot control.',
  'I am grateful for this moment and the peace it brings.',
  'With every breath, I draw in calm and release worry.',
  'I trust the journey of my life and welcome new beginnings.',
  'I am strong, capable, and filled with light.',
  'I deserve rest, and I give myself permission to relax.',
  'I am surrounded by love and everything is fine.',
  'My thoughts are becoming calmer with each passing moment.',
  'I am enough, exactly as I am right now.',
  'I welcome sleep as a gift and embrace the night with gratitude.',
  'I radiate peace and attract positive energy into my life.',
  'Every day, in every way, I am becoming more peaceful.',
  'I forgive myself and others, freeing my heart from burden.',
  'I am connected to the infinite calm of the universe.',
  'Today I choose joy over worry and peace over anxiety.',
  'My body is relaxed, my mind is quiet, and my soul is at ease.',
];

class AffirmationsScreen extends StatefulWidget {
  const AffirmationsScreen({super.key});

  @override
  State<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends State<AffirmationsScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final _gradientColors = const [
    [Color(0xFF6B4CE6), Color(0xFF1A1A2E)],
    [Color(0xFF4C9AE6), Color(0xFF0D1F33)],
    [Color(0xFF4CE6C8), Color(0xFF0A2A2A)],
    [Color(0xFF764BA2), Color(0xFF1A0D26)],
    [Color(0xFFFFA726), Color(0xFF1F1505)],
  ];

  @override
  void initState() {
    super.initState();
    final todayIndex = DateTime.now().day % _affirmations.length;
    _currentPage = todayIndex;
    _pageController = PageController(initialPage: todayIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _gradientColors[_currentPage % _gradientColors.length];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(''),
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.auto_awesome, color: Color(0xFFFFC107), size: 28),
              const SizedBox(height: 12),
              Text('Daily Affirmation', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimaryDark)),
              const SizedBox(height: 4),
              Text('Swipe for more', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark)),
              const Spacer(flex: 1),
              SizedBox(
                height: 320,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _affirmations.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) => _AffirmationCard(text: _affirmations[index], index: index),
                ),
              ),
              const SizedBox(height: 24),
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(min(7, _affirmations.length), (i) {
                  final startIdx = max(0, _currentPage - 3);
                  final dotIdx = startIdx + i;
                  if (dotIdx >= _affirmations.length) return const SizedBox();
                  final isActive = dotIdx == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 24 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: isActive ? const Color(0xFFFFC107) : AppColors.textTertiaryDark.withValues(alpha: 0.3),
                    ),
                  );
                }),
              ),
              const Spacer(flex: 1),
              // Random button
              GestureDetector(
                onTap: () {
                  final rng = Random();
                  int next;
                  do { next = rng.nextInt(_affirmations.length); } while (next == _currentPage);
                  _pageController.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDarkCard.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shuffle_rounded, color: AppColors.textSecondaryDark, size: 20),
                      const SizedBox(width: 8),
                      Text('Random', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondaryDark)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _AffirmationCard extends StatelessWidget {
  final String text;
  final int index;
  const _AffirmationCard({required this.text, required this.index});

  @override
  Widget build(BuildContext context) {
    final accents = [AppColors.primaryPurple, AppColors.primaryBlue, AppColors.primaryTeal, AppColors.info, AppColors.warning];
    final accent = accents[index % accents.length];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.15), AppColors.backgroundDarkCard.withValues(alpha: 0.85)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.format_quote_rounded, color: accent.withValues(alpha: 0.4), size: 36),
          const SizedBox(height: 20),
          Text(text, style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryDark, fontStyle: FontStyle.italic, height: 1.6), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Container(width: 40, height: 2, decoration: BoxDecoration(color: accent.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(1))),
        ],
      ),
    );
  }
}
