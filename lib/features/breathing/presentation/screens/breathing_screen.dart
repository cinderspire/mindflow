import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../widgets/breathing_circle.dart';

enum BreathingTechnique {
  boxBreathing(
    name: 'Box Breathing',
    description: 'Equal inhale, hold, exhale, hold. Perfect for stress relief.',
    inhale: 4,
    holdIn: 4,
    exhale: 4,
    holdOut: 4,
    gradient: LinearGradient(
      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  relaxing478(
    name: '4-7-8 Relaxing',
    description: 'Deep relaxation technique. Great for sleep and anxiety.',
    inhale: 4,
    holdIn: 7,
    exhale: 8,
    holdOut: 0,
    gradient: LinearGradient(
      colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  energizing(
    name: 'Energizing',
    description: 'Quick, invigorating breath to boost energy and focus.',
    inhale: 2,
    holdIn: 0,
    exhale: 2,
    holdOut: 0,
    gradient: LinearGradient(
      colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  calming(
    name: 'Deep Calm',
    description:
        'Extended exhale for deep relaxation and parasympathetic activation.',
    inhale: 4,
    holdIn: 2,
    exhale: 6,
    holdOut: 2,
    gradient: LinearGradient(
      colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  focus(
    name: 'Focus',
    description:
        'Balanced breathing to enhance concentration and mental clarity.',
    inhale: 5,
    holdIn: 5,
    exhale: 5,
    holdOut: 0,
    gradient: LinearGradient(
      colors: [Color(0xFFFC466B), Color(0xFF3F5EFB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  final String name;
  final String description;
  final int inhale;
  final int holdIn;
  final int exhale;
  final int holdOut;
  final LinearGradient gradient;

  const BreathingTechnique({
    required this.name,
    required this.description,
    required this.inhale,
    required this.holdIn,
    required this.exhale,
    required this.holdOut,
    required this.gradient,
  });

  int get totalCycleDuration => inhale + holdIn + exhale + holdOut;
}

/// Standalone breathing screen (pushed via Navigator)
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with TickerProviderStateMixin {
  BreathingTechnique _selectedTechnique = BreathingTechnique.boxBreathing;
  bool _isActive = false;
  int _cyclesCompleted = 0;
  int _targetCycles = 5;

  late AnimationController _breathController;
  String _currentPhase = 'Ready';

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _breathController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _selectedTechnique.totalCycleDuration),
    );

    _breathController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isActive) {
        setState(() => _cyclesCompleted++);
        if (_cyclesCompleted < _targetCycles) {
          _breathController.reset();
          _breathController.forward();
        } else {
          _stopBreathing();
          HapticFeedback.heavyImpact();
          _showCompletionDialog();
        }
      }
    });

    _breathController.addListener(() {
      _updatePhase();
    });
  }

  void _updatePhase() {
    final technique = _selectedTechnique;
    final totalDuration = technique.totalCycleDuration;
    final currentSecond = (_breathController.value * totalDuration).floor();

    String newPhase;
    if (currentSecond < technique.inhale) {
      newPhase = 'Breathe In';
    } else if (currentSecond < technique.inhale + technique.holdIn) {
      newPhase = 'Hold';
    } else if (currentSecond <
        technique.inhale + technique.holdIn + technique.exhale) {
      newPhase = 'Breathe Out';
    } else {
      newPhase = technique.holdOut > 0 ? 'Hold' : 'Breathe In';
    }

    if (newPhase != _currentPhase) {
      setState(() => _currentPhase = newPhase);
      HapticFeedback.lightImpact();
    }
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _cyclesCompleted = 0;
      _currentPhase = 'Breathe In';
    });
    HapticFeedback.mediumImpact();
    _breathController.forward();
  }

  void _stopBreathing() {
    setState(() {
      _isActive = false;
      _currentPhase = 'Ready';
    });
    _breathController.reset();
  }

  void _selectTechnique(BreathingTechnique technique) {
    if (_isActive) _stopBreathing();
    setState(() => _selectedTechnique = technique);
    _breathController.dispose();
    _initializeController();
    HapticFeedback.selectionClick();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Great Job!',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        content: Text(
          'You completed $_targetCycles breathing cycles.\nTake a moment to notice how you feel.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Done',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Breathing',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
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
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Technique Selector
            _buildTechniqueSelector(),

            const SizedBox(height: 16),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _selectedTechnique.description,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ),

            const Spacer(),

            // Breathing Circle Animation
            BreathingCircle(
              animation: _breathController,
              technique: _selectedTechnique,
              isActive: _isActive,
              currentPhase: _currentPhase,
            ),

            const SizedBox(height: 30),

            // Cycles Counter
            if (_isActive)
              Text(
                'Cycle ${_cyclesCompleted + 1} of $_targetCycles',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),

            const Spacer(),

            // Cycles Selector (only when not active)
            if (!_isActive) _buildCyclesSelector(),

            const SizedBox(height: 30),

            // Start/Stop Button
            _buildStartStopButton(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTechniqueSelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: BreathingTechnique.values.length,
        itemBuilder: (context, index) {
          final technique = BreathingTechnique.values[index];
          final isSelected = technique == _selectedTechnique;

          return GestureDetector(
            onTap: () => _selectTechnique(technique),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isSelected ? technique.gradient : null,
                color: isSelected ? null : AppColors.backgroundDarkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.glassBorder,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    technique.name,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${technique.totalCycleDuration}s cycle',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.white70
                          : AppColors.textTertiaryDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCyclesSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Cycles: ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          ...List.generate(4, (index) {
            final cycles = [3, 5, 7, 10][index];
            final isSelected = _targetCycles == cycles;
            return GestureDetector(
              onTap: () {
                setState(() => _targetCycles = cycles);
                HapticFeedback.selectionClick();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? _selectedTechnique.gradient : null,
                  color: isSelected ? null : AppColors.backgroundDarkCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$cycles',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondaryDark,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStartStopButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: _isActive ? _stopBreathing : _startBreathing,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: _isActive ? null : _selectedTechnique.gradient,
            color: _isActive ? AppColors.error : null,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _isActive
                    ? AppColors.error.withOpacity(0.3)
                    : AppColors.primaryPurple.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _isActive ? 'Stop' : 'Start',
              style: AppTextStyles.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Embedded version for bottom navigation tab
class BreathingExercisesScreen extends StatefulWidget {
  const BreathingExercisesScreen({super.key});

  @override
  State<BreathingExercisesScreen> createState() =>
      _BreathingExercisesScreenState();
}

class _BreathingExercisesScreenState extends State<BreathingExercisesScreen>
    with TickerProviderStateMixin {
  BreathingTechnique _selectedTechnique = BreathingTechnique.boxBreathing;
  bool _isActive = false;
  int _cyclesCompleted = 0;
  int _targetCycles = 5;

  late AnimationController _breathController;
  String _currentPhase = 'Ready';

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _breathController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _selectedTechnique.totalCycleDuration),
    );

    _breathController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isActive) {
        setState(() => _cyclesCompleted++);
        if (_cyclesCompleted < _targetCycles) {
          _breathController.reset();
          _breathController.forward();
        } else {
          _stopBreathing();
          HapticFeedback.heavyImpact();
          _showCompletionDialog();
        }
      }
    });

    _breathController.addListener(() {
      _updatePhase();
    });
  }

  void _updatePhase() {
    final technique = _selectedTechnique;
    final totalDuration = technique.totalCycleDuration;
    final currentSecond = (_breathController.value * totalDuration).floor();

    String newPhase;
    if (currentSecond < technique.inhale) {
      newPhase = 'Breathe In';
    } else if (currentSecond < technique.inhale + technique.holdIn) {
      newPhase = 'Hold';
    } else if (currentSecond <
        technique.inhale + technique.holdIn + technique.exhale) {
      newPhase = 'Breathe Out';
    } else {
      newPhase = technique.holdOut > 0 ? 'Hold' : 'Breathe In';
    }

    if (newPhase != _currentPhase) {
      setState(() => _currentPhase = newPhase);
      HapticFeedback.lightImpact();
    }
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _cyclesCompleted = 0;
      _currentPhase = 'Breathe In';
    });
    HapticFeedback.mediumImpact();
    _breathController.forward();
  }

  void _stopBreathing() {
    setState(() {
      _isActive = false;
      _currentPhase = 'Ready';
    });
    _breathController.reset();
  }

  void _selectTechnique(BreathingTechnique technique) {
    if (_isActive) _stopBreathing();
    setState(() => _selectedTechnique = technique);
    _breathController.dispose();
    _initializeController();
    HapticFeedback.selectionClick();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Great Job!',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        content: Text(
          'You completed $_targetCycles breathing cycles.\nTake a moment to notice how you feel.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Done',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Breathing Exercises',
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
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Technique Selector
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: BreathingTechnique.values.length,
                  itemBuilder: (context, index) {
                    final technique = BreathingTechnique.values[index];
                    final isSelected = technique == _selectedTechnique;

                    return GestureDetector(
                      onTap: () => _selectTechnique(technique),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: isSelected ? technique.gradient : null,
                          color:
                              isSelected ? null : AppColors.backgroundDarkCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : AppColors.glassBorder,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              technique.name,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimaryDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${technique.totalCycleDuration}s cycle',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isSelected
                                    ? Colors.white70
                                    : AppColors.textTertiaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _selectedTechnique.description,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ),

              const Spacer(),

              // Breathing Circle Animation
              BreathingCircle(
                animation: _breathController,
                technique: _selectedTechnique,
                isActive: _isActive,
                currentPhase: _currentPhase,
              ),

              const SizedBox(height: 24),

              // Cycles Counter
              if (_isActive)
                Text(
                  'Cycle ${_cyclesCompleted + 1} of $_targetCycles',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),

              const Spacer(),

              // Cycles Selector
              if (!_isActive)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Cycles: ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      ...List.generate(4, (index) {
                        final cycles = [3, 5, 7, 10][index];
                        final isSelected = _targetCycles == cycles;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _targetCycles = cycles);
                            HapticFeedback.selectionClick();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? _selectedTechnique.gradient
                                  : null,
                              color: isSelected
                                  ? null
                                  : AppColors.backgroundDarkCard,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$cycles',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondaryDark,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Start/Stop Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GestureDetector(
                  onTap: _isActive ? _stopBreathing : _startBreathing,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient:
                          _isActive ? null : _selectedTechnique.gradient,
                      color: _isActive ? AppColors.error : null,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: _isActive
                              ? AppColors.error.withOpacity(0.3)
                              : AppColors.primaryPurple.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _isActive ? 'Stop' : 'Start Breathing',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100), // bottom nav padding
            ],
          ),
        ),
      ),
    );
  }
}
