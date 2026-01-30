import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../screens/breathing_screen.dart';

class BreathingCircle extends StatelessWidget {
  final Animation<double> animation;
  final BreathingTechnique technique;
  final bool isActive;
  final String currentPhase;

  const BreathingCircle({
    super.key,
    required this.animation,
    required this.technique,
    required this.isActive,
    required this.currentPhase,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = _calculateScale();
        final opacity = _calculateOpacity();

        return SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 260 * scale,
                height: 260 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      technique.gradient.colors.first.withValues(alpha: 0.1),
                      technique.gradient.colors.last.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Secondary ring
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 220 * scale,
                height: 220 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: technique.gradient.colors.first.withValues(alpha: opacity * 0.3),
                    width: 2,
                  ),
                ),
              ),

              // Main breathing circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 180 * scale,
                height: 180 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: technique.gradient,
                  boxShadow: [
                    BoxShadow(
                      color: technique.gradient.colors.first.withValues(alpha: opacity * 0.5),
                      blurRadius: 40 * scale,
                      spreadRadius: 10 * scale,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentPhase,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 8),
                        Text(
                          _getSecondsRemaining(),
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Particle effects when active
              if (isActive) ..._buildParticles(),
            ],
          ),
        );
      },
    );
  }

  double _calculateScale() {
    if (!isActive) return 1.0;

    final totalDuration = technique.totalCycleDuration;
    final currentSecond = (animation.value * totalDuration);

    // Inhale: scale up from 0.8 to 1.2
    if (currentSecond < technique.inhale) {
      final progress = currentSecond / technique.inhale;
      return 0.8 + (0.4 * progress);
    }

    // Hold (after inhale): stay at 1.2
    if (currentSecond < technique.inhale + technique.holdIn) {
      return 1.2;
    }

    // Exhale: scale down from 1.2 to 0.8
    if (currentSecond < technique.inhale + technique.holdIn + technique.exhale) {
      final exhaleStart = technique.inhale + technique.holdIn;
      final progress = (currentSecond - exhaleStart) / technique.exhale;
      return 1.2 - (0.4 * progress);
    }

    // Hold (after exhale): stay at 0.8
    return 0.8;
  }

  double _calculateOpacity() {
    if (!isActive) return 0.5;

    final totalDuration = technique.totalCycleDuration;
    final currentSecond = (animation.value * totalDuration);

    // Inhale: opacity increases
    if (currentSecond < technique.inhale) {
      final progress = currentSecond / technique.inhale;
      return 0.3 + (0.7 * progress);
    }

    // Hold (after inhale): full opacity
    if (currentSecond < technique.inhale + technique.holdIn) {
      return 1.0;
    }

    // Exhale: opacity decreases
    if (currentSecond < technique.inhale + technique.holdIn + technique.exhale) {
      final exhaleStart = technique.inhale + technique.holdIn;
      final progress = (currentSecond - exhaleStart) / technique.exhale;
      return 1.0 - (0.7 * progress);
    }

    return 0.3;
  }

  String _getSecondsRemaining() {
    final totalDuration = technique.totalCycleDuration;
    final currentSecond = (animation.value * totalDuration).floor();

    int remaining;
    if (currentSecond < technique.inhale) {
      remaining = technique.inhale - currentSecond;
    } else if (currentSecond < technique.inhale + technique.holdIn) {
      remaining = technique.inhale + technique.holdIn - currentSecond;
    } else if (currentSecond < technique.inhale + technique.holdIn + technique.exhale) {
      remaining = technique.inhale + technique.holdIn + technique.exhale - currentSecond;
    } else {
      remaining = totalDuration - currentSecond;
    }

    return '$remaining';
  }

  List<Widget> _buildParticles() {
    // Simple floating particles around the circle
    return List.generate(6, (index) {
      final angle = (index * 60) + (animation.value * 360);
      final radians = angle * (math.pi / 180);
      const radius = 140.0;
      final x = radius * math.cos(radians);
      final y = radius * math.sin(radians);

      return Positioned(
        left: 140 + x - 4,
        top: 140 + y - 4,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: technique.gradient.colors.first.withValues(alpha: 0.6),
            boxShadow: [
              BoxShadow(
                color: technique.gradient.colors.first.withValues(alpha: 0.4),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      );
    });
  }
}
