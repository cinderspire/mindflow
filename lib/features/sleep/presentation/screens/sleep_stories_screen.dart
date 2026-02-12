import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/sleep_story.dart';

const _stories = [
  SleepStory(
    id: 's1',
    title: 'The Enchanted Forest',
    narrator: 'Serene Voice',
    description: 'Wander through an ancient forest where fireflies dance between silver birch trees.',
    durationMinutes: 20,
    category: 'Nature',
    icon: Icons.forest_rounded,
    gradientColors: [Color(0xFF2D6A4F), Color(0xFF1B4332)],
  ),
  SleepStory(
    id: 's2',
    title: 'Ocean of Dreams',
    narrator: 'Calm Narrator',
    description: 'Float on gentle waves under a canopy of stars. The rhythmic ocean carries you to peace.',
    durationMinutes: 25,
    category: 'Ocean',
    icon: Icons.water_rounded,
    gradientColors: [Color(0xFF4C9AE6), Color(0xFF1A3A5C)],
  ),
  SleepStory(
    id: 's3',
    title: 'Starlit Mountain',
    narrator: 'Peaceful Guide',
    description: 'Ascend a quiet mountain trail at twilight. Each breath brings you closer to infinite peace.',
    durationMinutes: 18,
    category: 'Mountain',
    icon: Icons.terrain_rounded,
    gradientColors: [Color(0xFF764BA2), Color(0xFF4C3F91)],
  ),
  SleepStory(
    id: 's4',
    title: 'The Cloud Traveler',
    narrator: 'Gentle Voice',
    description: 'Drift among soft clouds in an endless sky. Feel weightless in moonlight and shadow.',
    durationMinutes: 22,
    category: 'Sky',
    icon: Icons.cloud_rounded,
    gradientColors: [Color(0xFF667EEA), Color(0xFF4FACFE)],
  ),
  SleepStory(
    id: 's5',
    title: 'Midnight Garden',
    narrator: 'Soothing Narrator',
    description: 'Step into a hidden garden that blooms only at midnight. Silver roses fill the air with calm.',
    durationMinutes: 15,
    category: 'Nature',
    icon: Icons.local_florist_rounded,
    gradientColors: [Color(0xFFE91E63), Color(0xFF4A00E0)],
  ),
  SleepStory(
    id: 's6',
    title: 'The Lighthouse Keeper',
    narrator: 'Warm Voice',
    description: 'Watch the beam sweep across calm waters as the world settles into silence.',
    durationMinutes: 20,
    category: 'Ocean',
    icon: Icons.nightlight_round,
    gradientColors: [Color(0xFFFFA726), Color(0xFF4C3F91)],
  ),
];

class SleepStoriesScreen extends StatelessWidget {
  const SleepStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Sleep Stories', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0D1033),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: _stories.length,
            itemBuilder: (context, index) {
              final story = _stories[index];
              return _StoryCard(story: story, index: index);
            },
          ),
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final SleepStory story;
  final int index;

  const _StoryCard({required this.story, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _StoryPlayerScreen(story: story)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              story.gradientColors[0].withValues(alpha: 0.2),
              AppColors.backgroundDarkCard.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: story.gradientColors[0].withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: story.gradientColors[0].withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(story.icon, color: story.gradientColors[0], size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(story.title, style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
                  const SizedBox(height: 3),
                  Text(story.narrator, style: AppTextStyles.bodySmall.copyWith(color: story.gradientColors[0])),
                  const SizedBox(height: 4),
                  Text(story.description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                Icon(Icons.play_circle_filled_rounded, color: story.gradientColors[0].withValues(alpha: 0.7), size: 36),
                const SizedBox(height: 4),
                Text('${story.durationMinutes}m', style: AppTextStyles.labelSmall.copyWith(color: story.gradientColors[0])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryPlayerScreen extends StatefulWidget {
  final SleepStory story;
  const _StoryPlayerScreen({required this.story});

  @override
  State<_StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}

class _StoryPlayerScreenState extends State<_StoryPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isPlaying = false;
  int _remainingSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.story.durationMinutes * 60;
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          setState(() => _isPlaying = false);
        }
      });
    } else {
      _timer?.cancel();
    }
  }

  String _fmt(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final color = widget.story.gradientColors[0];
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.2), AppColors.backgroundDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), color: AppColors.textTertiaryDark),
                    const Spacer(),
                    Text('SLEEP STORY', style: AppTextStyles.labelSmall.copyWith(letterSpacing: 2, color: AppColors.textTertiaryDark)),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) => Transform.scale(
                  scale: 0.9 + _pulseController.value * 0.15,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.05)]),
                      boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 50, spreadRadius: 15)],
                    ),
                    child: Icon(widget.story.icon, color: color.withValues(alpha: 0.7), size: 56),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(widget.story.title, style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimaryDark)),
              const SizedBox(height: 8),
              Text(widget.story.narrator, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark)),
              const SizedBox(height: 24),
              Text(_fmt(_remainingSeconds), style: AppTextStyles.headlineLarge.copyWith(color: color, fontWeight: FontWeight.w300, fontSize: 48)),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(widget.story.description, style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic, height: 1.7, color: AppColors.textSecondaryDark), textAlign: TextAlign.center),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _toggle,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 20, spreadRadius: 2)],
                  ),
                  child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
