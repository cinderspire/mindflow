import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/journal_entry.dart';
import '../../../../core/providers/journal_provider.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../widgets/journal_entry_card.dart';
import '../widgets/voice_recorder.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _textController = TextEditingController();
  String _selectedMood = 'neutral';
  String _searchQuery = '';
  bool _showSearch = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journalEntries = ref.watch(journalProvider);
    final filteredEntries = _searchQuery.isEmpty
        ? journalEntries
        : ref.read(journalProvider.notifier).searchEntries(_searchQuery);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                autofocus: true,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Search entries...',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textTertiaryDark,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : Text(
                'Journal',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) _searchQuery = '';
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterDialog(),
          ),
        ],
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
              // New Entry Section
              _buildNewEntrySection(),

              // Journal Entries List
              Expanded(
                child: filteredEntries.isEmpty
                    ? _buildEmptyState()
                    : _buildJournalList(filteredEntries),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewEntrySheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Entry'),
        backgroundColor: AppColors.primaryPurple,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: AppColors.textTertiaryDark.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No journal entries yet'
                : 'No entries found',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Start writing to capture your thoughts'
                : 'Try a different search term',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewEntrySection() {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How are you feeling?',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Express yourself through writing or voice',
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
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  text: 'Write',
                  onPressed: _showNewEntrySheet,
                  icon: Icons.edit_rounded,
                  height: 48,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlineGradientButton(
                  text: 'Record',
                  onPressed: _showVoiceRecorder,
                  icon: Icons.mic_rounded,
                  height: 48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJournalList(List<JournalEntry> entries) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Dismissible(
          key: Key(entry.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          confirmDismiss: (direction) => _confirmDelete(entry),
          onDismissed: (_) => _deleteEntry(entry.id),
          child: JournalEntryCard(
            date: entry.timestamp,
            content: entry.content,
            mood: entry.mood,
            type: entry.type == JournalType.voice ? 'voice' : 'text',
            aiInsight: entry.aiInsight,
            duration: entry.audioDuration,
            onTap: () => _openEntry(entry),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(JournalEntry entry) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.backgroundDarkCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Delete Entry?',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            content: Text(
              'This action cannot be undone.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _deleteEntry(String id) {
    ref.read(journalProvider.notifier).deleteEntry(id);
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Entry deleted',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.backgroundDarkCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.backgroundDarkElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Mood',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildFilterChip('All', null),
                _buildFilterChip('Excellent 😄', 'excellent'),
                _buildFilterChip('Good 😊', 'good'),
                _buildFilterChip('Neutral 😐', 'neutral'),
                _buildFilterChip('Poor 😕', 'poor'),
                _buildFilterChip('Terrible 😢', 'terrible'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? mood) {
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (_) {
        Navigator.pop(context);
        // Apply filter
      },
      backgroundColor: AppColors.backgroundDarkCard,
      selectedColor: AppColors.primaryPurple.withValues(alpha: 0.3),
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
    );
  }

  void _showNewEntrySheet() {
    _textController.clear();
    _selectedMood = 'neutral';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => _buildNewEntryBottomSheet(setModalState),
      ),
    );
  }

  Widget _buildNewEntryBottomSheet(StateSetter setModalState) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  'New Journal Entry',
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

          // Mood Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How are you feeling?',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                _buildMoodSelector(setModalState),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Text Input
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Write about your thoughts, feelings, or anything on your mind...',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textTertiaryDark,
                  ),
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
          ),

          // Save Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: GradientButton(
              text: 'Save Entry',
              onPressed: _saveEntry,
              icon: Icons.check_rounded,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector(StateSetter setModalState) {
    final moods = [
      {'id': 'terrible', 'emoji': '😢', 'color': AppColors.moodTerrible},
      {'id': 'poor', 'emoji': '😕', 'color': AppColors.moodPoor},
      {'id': 'neutral', 'emoji': '😐', 'color': AppColors.moodNeutral},
      {'id': 'good', 'emoji': '😊', 'color': AppColors.moodGood},
      {'id': 'excellent', 'emoji': '😄', 'color': AppColors.moodExcellent},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: moods.map((mood) {
        final isSelected = _selectedMood == mood['id'];
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            setModalState(() => _selectedMood = mood['id'] as String);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? (mood['color'] as Color).withValues(alpha: 0.3)
                  : Colors.transparent,
              border: Border.all(
                color:
                    isSelected ? mood['color'] as Color : AppColors.glassBorder,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                mood['emoji'] as String,
                style: TextStyle(fontSize: isSelected ? 28 : 24),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showVoiceRecorder() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceRecorder(
        onRecordingComplete: (path) {
          Navigator.pop(context);
          // Handle the recorded audio - create voice entry
          _saveVoiceEntry(path);
        },
      ),
    );
  }

  void _saveEntry() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please write something before saving',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final entry = JournalEntry(
      id: const Uuid().v4(),
      content: _textController.text.trim(),
      timestamp: DateTime.now(),
      mood: _selectedMood,
      type: JournalType.text,
    );

    ref.read(journalProvider.notifier).addEntry(entry);
    HapticFeedback.mediumImpact();

    _textController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Entry saved!',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _saveVoiceEntry(String path) {
    final entry = JournalEntry(
      id: const Uuid().v4(),
      content: 'Voice recording',
      timestamp: DateTime.now(),
      mood: _selectedMood,
      type: JournalType.voice,
      audioPath: path,
    );

    ref.read(journalProvider.notifier).addEntry(entry);
    HapticFeedback.mediumImpact();
  }

  void _openEntry(JournalEntry entry) {
    // Navigate to entry detail screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEntryDetailSheet(entry),
    );
  }

  Widget _buildEntryDetailSheet(JournalEntry entry) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(entry.timestamp),
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTime(entry.timestamp),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiaryDark,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getMoodColor(entry.mood).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getMoodEmoji(entry.mood),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                entry.content,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimaryDark,
                  height: 1.6,
                ),
              ),
            ),
          ),

          // AI Insight
          if (entry.aiInsight != null)
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPurple.withValues(alpha: 0.3),
                    AppColors.primaryBlue.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primaryPurple,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.aiInsight!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'excellent':
        return '😄';
      case 'good':
        return '😊';
      case 'neutral':
        return '😐';
      case 'poor':
        return '😕';
      case 'terrible':
        return '😢';
      default:
        return '😐';
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'excellent':
        return AppColors.moodExcellent;
      case 'good':
        return AppColors.moodGood;
      case 'neutral':
        return AppColors.moodNeutral;
      case 'poor':
        return AppColors.moodPoor;
      case 'terrible':
        return AppColors.moodTerrible;
      default:
        return AppColors.moodNeutral;
    }
  }
}
