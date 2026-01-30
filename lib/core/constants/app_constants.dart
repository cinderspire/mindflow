// App Constants for MindFlow
class AppConstants {
  // App Info
  static const String appName = 'MindFlow';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your AI Mental Wellness Companion';

  // Timing
  static const int splashDuration = 2000; // milliseconds
  static const int animationDuration = 300;
  static const int toastDuration = 3000;

  // Limits
  static const int maxJournalLength = 5000;
  static const int maxMoodNotesLength = 500;
  static const int meditationSessionMin = 1;
  static const int meditationSessionMax = 60;

  // Mood Values
  static const int moodMin = 1;
  static const int moodMax = 5;

  // Storage Keys
  static const String keyUserId = 'user_id';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyDailyReminderTime = 'daily_reminder_time';

  // Default Values
  static const String defaultReminderTime = '20:00';
  static const int defaultMeditationDuration = 10;

  // Mood Labels
  static const Map<int, String> moodLabels = {
    1: 'Very Bad',
    2: 'Bad',
    3: 'Okay',
    4: 'Good',
    5: 'Great',
  };

  // Mood Emojis
  static const Map<int, String> moodEmojis = {
    1: '😢',
    2: '😔',
    3: '😐',
    4: '🙂',
    5: '😊',
  };
}
