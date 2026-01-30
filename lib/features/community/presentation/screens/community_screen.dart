import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';
import '../../../../shared/widgets/gradient_button.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _postController = TextEditingController();

  // Sample community posts
  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'author': 'Anonymous User',
      'avatar': '🦋',
      'content': 'Today I completed my 30-day meditation streak! Never thought I could be this consistent. Small steps lead to big changes.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'likes': 24,
      'comments': 8,
      'isLiked': false,
      'tags': ['Achievement', 'Meditation'],
    },
    {
      'id': '2',
      'author': 'Anonymous User',
      'avatar': '🌸',
      'content': 'Struggling with anxiety lately. Anyone else feel like the holidays make it worse? Looking for some support and tips.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'likes': 45,
      'comments': 23,
      'isLiked': true,
      'tags': ['Anxiety', 'Support'],
    },
    {
      'id': '3',
      'author': 'Anonymous User',
      'avatar': '🌊',
      'content': 'The box breathing exercise in this app literally saved me during a panic attack yesterday. Grateful for this community.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'likes': 89,
      'comments': 15,
      'isLiked': false,
      'tags': ['Breathing', 'Gratitude'],
    },
    {
      'id': '4',
      'author': 'Anonymous User',
      'avatar': '🌻',
      'content': 'Reminder: Your mental health journey is not linear. Bad days don\'t erase your progress. Be gentle with yourself.',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'likes': 156,
      'comments': 32,
      'isLiked': true,
      'tags': ['Motivation', 'Self-Care'],
    },
  ];

  final List<Map<String, dynamic>> _supportGroups = [
    {
      'name': 'Anxiety Support',
      'members': 1250,
      'icon': '💙',
      'color': AppColors.primaryBlue,
    },
    {
      'name': 'Daily Meditation',
      'members': 3420,
      'icon': '🧘',
      'color': AppColors.primaryPurple,
    },
    {
      'name': 'Sleep Better',
      'members': 890,
      'icon': '🌙',
      'color': const Color(0xFF4C3F91),
    },
    {
      'name': 'Mindful Living',
      'members': 2100,
      'icon': '🌿',
      'color': AppColors.primaryTeal,
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
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Community',
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
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryPurple,
          labelColor: AppColors.textPrimaryDark,
          unselectedLabelColor: AppColors.textTertiaryDark,
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Groups'),
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
              _buildFeedTab(),
              _buildGroupsTab(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewPostSheet,
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildFeedTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Crisis Resources Banner
        SliverToBoxAdapter(
          child: _buildCrisisBanner(),
        ),

        // Posts
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildPostCard(_posts[index]),
            childCount: _posts.length,
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildCrisisBanner() {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.emergency_rounded,
              color: AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need immediate help?',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Access crisis resources and hotlines',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiaryDark,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
            ),
            color: AppColors.textSecondaryDark,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    post['avatar'] as String,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['author'] as String,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTimestamp(post['timestamp'] as DateTime),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz_rounded),
                color: AppColors.textSecondaryDark,
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content
          Text(
            post['content'] as String,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 12),

          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (post['tags'] as List<String>).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#$tag',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryPurple,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              _buildActionButton(
                icon: post['isLiked'] as bool
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: '${post['likes']}',
                isActive: post['isLiked'] as bool,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    post['isLiked'] = !(post['isLiked'] as bool);
                    post['likes'] = post['isLiked']
                        ? (post['likes'] as int) + 1
                        : (post['likes'] as int) - 1;
                  });
                },
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: '${post['comments']}',
                isActive: false,
                onTap: () {},
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                isActive: false,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive ? AppColors.error : AppColors.textSecondaryDark,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isActive ? AppColors.error : AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Support Groups',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join a group to connect with others on similar journeys',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 20),

        ..._supportGroups.map((group) => _buildGroupCard(group)).toList(),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: (group['color'] as Color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                group['icon'] as String,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['name'] as String,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatNumber(group['members'] as int)} members',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiaryDark,
                  ),
                ),
              ],
            ),
          ),
          OutlineGradientButton(
            text: 'Join',
            onPressed: () {},
            width: 80,
            height: 36,
          ),
        ],
      ),
    );
  }

  void _showNewPostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiaryDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Share with Community',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.textSecondaryDark,
                  ),
                ],
              ),
            ),

            // Anonymous notice
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryPurple.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.privacy_tip_rounded,
                    color: AppColors.primaryPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your post will be shared anonymously',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Text Input
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _postController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimaryDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Share your thoughts, experiences, or ask for support...',
                    hintStyle: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textTertiaryDark,
                    ),
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
            ),

            // Post Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: GradientButton(
                text: 'Post',
                onPressed: () {
                  Navigator.pop(context);
                  _postController.clear();
                },
                icon: Icons.send_rounded,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
