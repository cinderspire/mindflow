import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class _BodyRegion {
  final String name;
  final String instruction;
  final double topRatio;
  const _BodyRegion(this.name, this.instruction, this.topRatio);
}

const _regions = [
  _BodyRegion('Crown of Head', 'Bring your attention to the very top of your head. Notice any sensations—warmth, tingling, or tension. Gently relax this area.', 0.02),
  _BodyRegion('Forehead & Eyes', 'Move awareness to your forehead and eyes. Let go of any furrowing. Allow your eyelids to feel heavy and relaxed.', 0.08),
  _BodyRegion('Jaw & Mouth', 'Release your jaw. Let your teeth part slightly. Relax your tongue and lips.', 0.14),
  _BodyRegion('Neck & Throat', 'Notice your neck and throat. Roll awareness around the full circumference. Release any tightness.', 0.20),
  _BodyRegion('Shoulders', 'Let your shoulders drop away from your ears. Feel them soften and release.', 0.26),
  _BodyRegion('Upper Arms', 'Move awareness down to your upper arms. Allow them to feel supported and relaxed.', 0.34),
  _BodyRegion('Hands & Fingers', 'Feel your hands and each finger. Let your hands uncurl and rest open.', 0.44),
  _BodyRegion('Chest & Heart', 'Feel your heartbeat. With each beat, let warmth radiate outward. Breathe deeply.', 0.38),
  _BodyRegion('Belly & Core', 'Notice your belly rising and falling. Release any holding. Allow your belly to be soft.', 0.50),
  _BodyRegion('Lower Back', 'Bring attention to your lower back. Offer it gratitude and let tension flow away.', 0.55),
  _BodyRegion('Hips & Pelvis', 'Feel your hips grounded and supported by the earth.', 0.60),
  _BodyRegion('Thighs', 'These powerful muscles can now rest. Let them feel heavy and warm.', 0.70),
  _BodyRegion('Knees', 'Send your knees gratitude and warmth. Let any stiffness dissolve.', 0.76),
  _BodyRegion('Calves & Shins', 'Notice warmth, tingling, weight. Allow these muscles to fully relax.', 0.83),
  _BodyRegion('Feet & Toes', 'Feel each toe, the arch, the heel. Honor your feet with relaxation.', 0.93),
];

class BodyScanScreen extends StatefulWidget {
  const BodyScanScreen({super.key});

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends State<BodyScanScreen> with TickerProviderStateMixin {
  int _currentRegionIndex = -1;
  bool _isActive = false;
  Timer? _autoAdvanceTimer;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 15));
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _glowController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _start() {
    HapticFeedback.mediumImpact();
    setState(() { _isActive = true; _currentRegionIndex = 0; });
    _startRegionTimer();
  }

  void _startRegionTimer() {
    _progressController.reset();
    _progressController.forward();
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(seconds: 15), _nextRegion);
  }

  void _nextRegion() {
    HapticFeedback.lightImpact();
    if (_currentRegionIndex < _regions.length - 1) {
      setState(() => _currentRegionIndex++);
      _startRegionTimer();
    } else {
      _complete();
    }
  }

  void _complete() {
    HapticFeedback.heavyImpact();
    _autoAdvanceTimer?.cancel();
    _progressController.stop();
    setState(() { _isActive = false; _currentRegionIndex = -1; });
  }

  double get _overallProgress => _currentRegionIndex < 0 ? 0 : (_currentRegionIndex + 1) / _regions.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
        title: Text('Body Scan', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A2A3A), Color(0xFF0A1520)]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (!_isActive) ...[
                const SizedBox(height: 24),
                _buildIntroCard(),
              ],
              if (_isActive) ...[
                const SizedBox(height: 12),
                _buildProgressBar(),
              ],
              Expanded(child: _isActive ? _buildActiveView() : _buildBodyPreview()),
              if (!_isActive) _buildStartButton() else _buildActiveControls(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.accessibility_new_rounded, color: AppColors.primaryTeal, size: 32),
          const SizedBox(height: 12),
          Text('Scan through 15 body regions', style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryDark)),
          const SizedBox(height: 6),
          Text('Each region gets 15 seconds of focused attention.\nAbout 4 minutes total.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _overallProgress,
              minHeight: 6,
              backgroundColor: AppColors.backgroundDarkCard.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryTeal),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(_overallProgress * 100).round()}%', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryTeal)),
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) => Text('${(15 * (1 - _progressController.value)).round()}s', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyPreview() {
    return Center(
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, _) => Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [AppColors.primaryTeal.withValues(alpha: _glowAnimation.value * 0.4), AppColors.primaryTeal.withValues(alpha: 0.05)]),
            boxShadow: [BoxShadow(color: AppColors.primaryTeal.withValues(alpha: _glowAnimation.value * 0.2), blurRadius: 40, spreadRadius: 10)],
          ),
          child: const Icon(Icons.accessibility_new_rounded, color: AppColors.primaryTeal, size: 60),
        ),
      ),
    );
  }

  Widget _buildActiveView() {
    if (_currentRegionIndex < 0 || _currentRegionIndex >= _regions.length) return const SizedBox();
    final region = _regions[_currentRegionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.accessibility_new_rounded, size: 180, color: AppColors.textTertiaryDark.withValues(alpha: 0.15)),
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, _) => Positioned(
                    top: 10 + (region.topRatio * 180),
                    child: Container(
                      width: 20 + _glowAnimation.value * 10,
                      height: 20 + _glowAnimation.value * 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryTeal.withValues(alpha: _glowAnimation.value * 0.6),
                        boxShadow: [BoxShadow(color: AppColors.primaryTeal.withValues(alpha: _glowAnimation.value * 0.4), blurRadius: 20, spreadRadius: 5)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(region.name, key: ValueKey(region.name), style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primaryTeal)),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Container(
              key: ValueKey(region.instruction),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundDarkCard.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
              ),
              child: Text(region.instruction, style: AppTextStyles.bodyLarge.copyWith(fontStyle: FontStyle.italic, height: 1.7, color: AppColors.textPrimaryDark), textAlign: TextAlign.center),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, _) => ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: _progressController.value,
                minHeight: 4,
                backgroundColor: AppColors.backgroundDarkCard.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation(AppColors.primaryTeal),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _start,
      child: Container(
        width: 200,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primaryTeal, Color(0xFF0D4F4F)]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: AppColors.primaryTeal.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Center(child: Text('Begin Scan', style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontSize: 18))),
      ),
    );
  }

  Widget _buildActiveControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: _currentRegionIndex > 0 ? () { setState(() => _currentRegionIndex--); _startRegionTimer(); } : null, icon: const Icon(Icons.skip_previous_rounded), color: AppColors.textSecondaryDark, iconSize: 32),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: _nextRegion,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppColors.primaryTeal, Color(0xFF0D4F4F)]),
              boxShadow: [BoxShadow(color: AppColors.primaryTeal.withValues(alpha: 0.3), blurRadius: 16, spreadRadius: 2)],
            ),
            child: Icon(_currentRegionIndex >= _regions.length - 1 ? Icons.check_rounded : Icons.skip_next_rounded, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(onPressed: _complete, icon: const Icon(Icons.stop_rounded), color: AppColors.error, iconSize: 32),
      ],
    );
  }
}
