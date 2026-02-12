import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/meditation_card.dart';
import '../widgets/meditation_player.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Sleep',
    'Anxiety',
    'Focus',
    'Stress',
    'Self-Love',
    'Breathing',
  ];

  // Sample meditation sessions
  final List<Map<String, dynamic>> _meditations = [
    {
      'id': '1',
      'title': 'Morning Calm',
      'description': 'Start your day with peace and clarity',
      'duration': 10,
      'category': 'Focus',
      'instructor': 'Sarah Chen',
      'isPremium': false,
      'gradient': [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      'playCount': 12500,
    },
    {
      'id': '2',
      'title': 'Deep Sleep Journey',
      'description': 'Drift into restful sleep with gentle guidance',
      'duration': 20,
      'category': 'Sleep',
      'instructor': 'James Miller',
      'isPremium': true,
      'gradient': [const Color(0xFF1A1A2E), const Color(0xFF4C3F91)],
      'playCount': 45200,
    },
    {
      'id': '3',
      'title': 'Anxiety Relief',
      'description': 'Release tension and find inner peace',
      'duration': 15,
      'category': 'Anxiety',
      'instructor': 'Emma Wilson',
      'isPremium': false,
      'gradient': [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      'playCount': 32100,
    },
    {
      'id': '4',
      'title': 'Box Breathing',
      'description': 'Simple technique for instant calm',
      'duration': 5,
      'category': 'Breathing',
      'instructor': 'Dr. Michael Brown',
      'isPremium': false,
      'gradient': [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      'playCount': 67800,
    },
    {
      'id': '5',
      'title': 'Self-Compassion',
      'description': 'Cultivate kindness towards yourself',
      'duration': 12,
      'category': 'Self-Love',
      'instructor': 'Lisa Park',
      'isPremium': true,
      'gradient': [const Color(0xFFFA709A), const Color(0xFFFEE140)],
      'playCount': 18900,
    },
    {
      'id': '6',
      'title': 'Stress Release',
      'description': 'Let go of daily tensions and worries',
      'duration': 15,
      'category': 'Stress',
      'instructor': 'Sarah Chen',
      'isPremium': false,
      'gradient': [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      'playCount': 28400,
    },
    {
      'id': '7',
      'title': 'Focus Flow',
      'description': 'Enter a state of deep concentration',
      'duration': 10,
      'category': 'Focus',
      'instructor': 'James Miller',
      'isPremium': true,
      'gradient': [const Color(0xFF0093E9), const Color(0xFF80D0C7)],
      'playCount': 41200,
    },
    {
      'id': '8',
      'title': 'Body Scan',
      'description': 'Progressive relaxation for complete rest',
      'duration': 20,
      'category': 'Sleep',
      'instructor': 'Emma Wilson',
      'isPremium': false,
      'gradient': [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
      'playCount': 35600,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredMeditations {
    if (_selectedCategory == 'All') return _meditations;
    return _meditations
        .where((m) => m['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Meditate',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryPurple,
          labelColor: AppColors.textPrimaryDark,
          unselectedLabelColor: AppColors.textTertiaryDark,
          tabs: const [
            Tab(text: 'Explore'),
            Tab(text: 'My Sessions'),
          ],
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
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildExploreTab(),
              _buildMySessionsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExploreTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Featured Section
        SliverToBoxAdapter(
          child: _buildFeaturedSection(),
        ),

        // Categories
        SliverToBoxAdapter(
          child: _buildCategoryFilter(),
        ),

        // Meditation Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final meditation = _filteredMeditations[index];
                return MeditationCard(
                  title: meditation['title'] as String,
                  description: meditation['description'] as String,
                  duration: meditation['duration'] as int,
                  instructor: meditation['instructor'] as String,
                  isPremium: meditation['isPremium'] as bool,
                  gradient: LinearGradient(
                    colors: meditation['gradient'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => _openMeditation(meditation),
                );
              },
              childCount: _filteredMeditations.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildFeaturedSection() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => _openMeditation(_meditations[3]), // Box Breathing
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.meditationGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background decoration
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'FEATURED',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Box Breathing',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '5 min • Instant calm technique',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: AppColors.primaryPurple,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Start Now',
                              style: AppTextStyles.titleSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : AppColors.backgroundDarkCard,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.glassBorder),
              ),
              child: Text(
                category,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondaryDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMySessionsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.secondaryLavender.withValues(alpha: 0.15),
                  AppColors.secondaryLavender.withValues(alpha: 0.03),
                ],
              ),
            ),
            child: Icon(
              Icons.self_improvement_rounded,
              size: 48,
              color: AppColors.secondaryLavender.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your meditation journey begins ✨',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Favorite meditations will appear here like stars in your sky',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openMeditation(Map<String, dynamic> meditation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MeditationPlayer(
        title: meditation['title'] as String,
        description: meditation['description'] as String,
        duration: meditation['duration'] as int,
        instructor: meditation['instructor'] as String,
        gradient: LinearGradient(
          colors: meditation['gradient'] as List<Color>,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
