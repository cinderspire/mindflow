import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/navigation_provider.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';
import '../../../journal/presentation/screens/journal_screen.dart';
import '../../../breathing/presentation/screens/breathing_screen.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  static const List<Map<String, dynamic>> _navigationItems = [
    {'icon': Icons.home_rounded, 'label': 'Home'},
    {'icon': Icons.edit_note_rounded, 'label': 'Journal'},
    {'icon': Icons.air_rounded, 'label': 'Breathe'},
    {'icon': Icons.analytics_rounded, 'label': 'Analytics'},
    {'icon': Icons.person_rounded, 'label': 'Profile'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          HomeScreen(),
          JournalScreen(),
          BreathingExercisesScreen(),
          AnalyticsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(ref, selectedIndex),
    );
  }

  Widget _buildBottomNavigationBar(WidgetRef ref, int selectedIndex) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: GlassmorphicContainer(
          blur: 15,
          opacity: 0.3,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navigationItems.length,
              (index) => _buildNavItem(ref, index, selectedIndex),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(WidgetRef ref, int index, int selectedIndex) {
    final isSelected = selectedIndex == index;
    final item = _navigationItems[index];

    return GestureDetector(
      onTap: () {
        ref.read(selectedTabProvider.notifier).state = index;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          item['icon'] as IconData,
          color: isSelected ? Colors.white : AppColors.textTertiaryDark,
          size: 24,
        ),
      ),
    );
  }
}
