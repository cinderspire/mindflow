import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// On-device AI coaching - no external API required.
/// Uses a rule-based therapeutic framework (CBT + mindfulness techniques).
class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addCoachMessage(_CoachEngine.greeting());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addCoachMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: false));
    });
    _scrollToBottom();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    HapticFeedback.lightImpact();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulate thinking delay
    Future.delayed(Duration(milliseconds: 800 + Random().nextInt(1200)), () {
      if (!mounted) return;
      final response = _CoachEngine.respond(text, _messages);
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(text: response, isUser: false));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Simon', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark)),
                Text('AI Wellness Coach', style: AppTextStyles.caption.copyWith(color: AppColors.primaryPurple)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundDark, AppColors.backgroundDark.withBlue(40)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Quick prompts
              if (_messages.length <= 2)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _QuickPrompt('I feel anxious', onTap: () { _controller.text = 'I feel anxious'; _sendMessage(); }),
                      _QuickPrompt('Help me relax', onTap: () { _controller.text = 'Help me relax'; _sendMessage(); }),
                      _QuickPrompt('I can\'t sleep', onTap: () { _controller.text = 'I can\'t sleep'; _sendMessage(); }),
                      _QuickPrompt('Feeling low', onTap: () { _controller.text = 'I\'m feeling low today'; _sendMessage(); }),
                    ],
                  ),
                ),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
              ),

              // Input
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDarkElevated.withValues(alpha: 0.9),
                  border: Border(top: BorderSide(color: AppColors.glassBorder)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
                        decoration: InputDecoration(
                          hintText: 'Share what\'s on your mind...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiaryDark),
                          filled: true,
                          fillColor: AppColors.backgroundDarkCard,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
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

  Widget _buildMessageBubble(_ChatMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFA78BFA), Color(0xFF8B5CF6)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryLavender.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            msg.text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ),
      );
    }
    // Coach message with avatar
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, bottom: 2),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_rounded, color: AppColors.secondaryLavender, size: 16),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundDarkCard,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(
                  color: AppColors.secondaryLavender.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                msg.text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkCard,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 14),
            ),
            ...List.generate(3, (i) {
              return _TypingDot(delay: i * 200);
            }),
          ],
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryPurple.withValues(alpha: _animation.value),
        ),
      ),
    );
  }
}

class _QuickPrompt extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickPrompt(this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryPurple)),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  const _ChatMessage({required this.text, required this.isUser});
}

/// On-device rule-based coaching engine using CBT & mindfulness principles
class _CoachEngine {
  static final _rng = Random();

  static String greeting() {
    final greetings = [
      "Hi, I'm Simon — your wellness coach. 💜 I'm here to listen and guide you. What's on your mind today?",
      "Welcome back! I'm Simon, your AI wellness companion. How are you feeling right now?",
      "Hello! I'm Simon. Think of me as your personal mindfulness guide. What would you like to work on today?",
    ];
    return greetings[_rng.nextInt(greetings.length)];
  }

  static String respond(String input, List<_ChatMessage> history) {
    final lower = input.toLowerCase();

    // Anxiety / worry
    if (_matches(lower, ['anxious', 'anxiety', 'worried', 'worry', 'panic', 'nervous', 'scared'])) {
      return _pick([
        "I hear you — anxiety can feel overwhelming. Let's try something together: Take a slow breath in for 4 counts, hold for 4, and exhale for 6. Do this three times. How does that feel?",
        "Anxiety often comes from future-focused thinking. Let's ground you in the present: Name 5 things you can see right now. This activates your parasympathetic nervous system.",
        "When anxiety rises, try this CBT technique: Ask yourself — 'What evidence do I have for this worry? What would I tell a friend in this situation?' Often our anxious thoughts aren't as factual as they feel.",
        "That sounds tough. Remember: anxiety is your brain trying to protect you, even when the threat isn't real. Let's try the 5-4-3-2-1 grounding technique. Name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, and 1 you taste.",
      ]);
    }

    // Sleep
    if (_matches(lower, ['sleep', 'insomnia', 'can\'t sleep', 'awake', 'tired', 'restless'])) {
      return _pick([
        "Sleep troubles are really common. Here's a technique: Try progressive muscle relaxation — tense each muscle group for 5 seconds, then release. Start from your toes and work up. This signals your body it's safe to rest.",
        "For better sleep tonight, try the 4-7-8 breathing method: Inhale for 4 seconds, hold for 7, exhale slowly for 8. Repeat 4 times. This activates your body's natural relaxation response.",
        "A racing mind at bedtime? Try a 'thought download' — write everything on your mind on paper. This externalizes worries so your brain doesn't need to hold them while you sleep.",
      ]);
    }

    // Sadness / depression
    if (_matches(lower, ['sad', 'depressed', 'low', 'down', 'hopeless', 'empty', 'lonely', 'unhappy'])) {
      return _pick([
        "I'm sorry you're feeling this way. Your feelings are valid. One thing that can help: behavioral activation. Even a small action — a short walk, calling someone, or making tea — can shift your neurochemistry. What's one tiny thing you could do right now?",
        "When we feel low, our thinking can become more negative. This is called cognitive distortion. Try to notice: are you catastrophizing or generalizing? Sometimes just labeling the thought pattern reduces its power.",
        "Sadness is a natural human emotion, and it's okay to feel it. Be gentle with yourself. Can you think of three things, no matter how small, that you're grateful for today? Gratitude practice rewires the brain toward positivity over time.",
        "I hear you. Remember that feelings are temporary states, not permanent truths. You don't need to fix everything right now. What's one kind thing you can do for yourself in the next hour?",
      ]);
    }

    // Stress
    if (_matches(lower, ['stress', 'stressed', 'overwhelmed', 'too much', 'pressure', 'burnout'])) {
      return _pick([
        "Stress often comes from feeling like demands exceed resources. Let's break it down: What's the ONE most important thing you need to handle right now? Just one. Everything else can wait.",
        "When stress builds up, your body tenses. Try a quick body scan: close your eyes and notice where you hold tension. Shoulders? Jaw? Just bringing awareness there helps release it.",
        "Here's a powerful reframe: Instead of 'I have to do this,' try 'I get to do this.' This small language shift moves you from pressure to purpose. What's stressing you most?",
      ]);
    }

    // Anger
    if (_matches(lower, ['angry', 'anger', 'frustrated', 'irritated', 'mad', 'furious'])) {
      return _pick([
        "Anger is valid — it tells us a boundary has been crossed. Before reacting, try the STOP technique: Stop what you're doing, Take a breath, Observe your feelings without judgment, Proceed mindfully.",
        "When anger rises, try this: breathe out longer than you breathe in (inhale 4, exhale 8). This physiologically calms your fight-or-flight response. What triggered this feeling?",
      ]);
    }

    // Gratitude / positive
    if (_matches(lower, ['grateful', 'thankful', 'good', 'happy', 'great', 'wonderful', 'amazing'])) {
      return _pick([
        "That's wonderful to hear! 🌟 Savoring positive moments amplifies their impact. Take a moment to really feel this — where do you notice it in your body?",
        "I love hearing that! Positive emotions broaden our thinking and build resilience. What specifically made you feel this way? Naming it makes it stick.",
      ]);
    }

    // Meditation / mindfulness
    if (_matches(lower, ['meditat', 'mindful', 'calm', 'relax', 'peace', 'breathe', 'breathing'])) {
      return _pick([
        "Great instinct to reach for mindfulness! Try this: Close your eyes and focus on your breath for just 60 seconds. When thoughts arise, acknowledge them like clouds passing, then return to your breath. No judgment.",
        "Mindfulness is a skill that gets stronger with practice. Even 2 minutes of focused breathing daily changes brain structure over time. Would you like to try a quick breathing exercise together?",
        "Here's a micro-meditation you can do anywhere: Take three conscious breaths. On each exhale, let your shoulders drop. Notice the space between your thoughts. That's the calm that's always there.",
      ]);
    }

    // Self-esteem / confidence
    if (_matches(lower, ['worthless', 'not good enough', 'failure', 'hate myself', 'useless', 'confidence'])) {
      return _pick([
        "I hear pain in those words, and I want you to know: those thoughts are not facts. They're stories your inner critic tells. Try this: What would your most compassionate friend say to you right now?",
        "Self-criticism is one of the most common patterns. Here's a CBT exercise: Write down the negative thought, then list three pieces of evidence against it. You might be surprised how much your mind distorts reality.",
        "You are worthy of kindness — including from yourself. Try placing your hand on your heart and saying 'I'm doing my best, and that is enough.' Self-compassion is scientifically shown to build resilience.",
      ]);
    }

    // Default / general
    return _pick([
      "Thank you for sharing that. Can you tell me more about how that makes you feel? Understanding our emotions is the first step to working with them.",
      "I appreciate you opening up. Let's explore this together: On a scale of 1-10, how intense is this feeling right now? Sometimes just measuring it gives us perspective.",
      "That's interesting. In CBT, we look at the connection between thoughts, feelings, and behaviors. What thoughts were going through your mind when you felt this way?",
      "Thank you for trusting me with that. Remember: you don't have to have everything figured out. What would feel like a small step forward right now?",
      "I'm here with you. Let's try a quick check-in: Take a breath and notice — what emotion is strongest for you right now? Just naming it can reduce its intensity by up to 50%.",
    ]);
  }

  static bool _matches(String input, List<String> keywords) {
    return keywords.any((k) => input.contains(k));
  }

  static String _pick(List<String> options) => options[_rng.nextInt(options.length)];
}
