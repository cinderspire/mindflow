// User Profile Model for MindFlow

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final UserStats stats;
  final UserSettings settings;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
    this.isPremium = false,
    this.premiumExpiresAt,
    required this.stats,
    required this.settings,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt.toIso8601String(),
    'isPremium': isPremium,
    'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
    'stats': stats.toJson(),
    'settings': settings.toJson(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    avatarUrl: json['avatarUrl'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isPremium: json['isPremium'] as bool? ?? false,
    premiumExpiresAt: json['premiumExpiresAt'] != null
        ? DateTime.parse(json['premiumExpiresAt'] as String)
        : null,
    stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
    settings: UserSettings.fromJson(json['settings'] as Map<String, dynamic>),
  );

  factory UserProfile.empty() => UserProfile(
    id: '',
    name: 'Guest User',
    email: '',
    createdAt: DateTime.now(),
    stats: UserStats.empty(),
    settings: UserSettings.defaults(),
  );
}

class UserStats {
  final int totalMeditationMinutes;
  final int totalJournalEntries;
  final int currentStreak;
  final int longestStreak;
  final int totalMoodEntries;
  final double averageMood;
  final int moodImprovementPercent;

  UserStats({
    this.totalMeditationMinutes = 0,
    this.totalJournalEntries = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalMoodEntries = 0,
    this.averageMood = 3.0,
    this.moodImprovementPercent = 0,
  });

  double get totalMeditationHours => totalMeditationMinutes / 60;

  Map<String, dynamic> toJson() => {
    'totalMeditationMinutes': totalMeditationMinutes,
    'totalJournalEntries': totalJournalEntries,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'totalMoodEntries': totalMoodEntries,
    'averageMood': averageMood,
    'moodImprovementPercent': moodImprovementPercent,
  };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    totalMeditationMinutes: json['totalMeditationMinutes'] as int? ?? 0,
    totalJournalEntries: json['totalJournalEntries'] as int? ?? 0,
    currentStreak: json['currentStreak'] as int? ?? 0,
    longestStreak: json['longestStreak'] as int? ?? 0,
    totalMoodEntries: json['totalMoodEntries'] as int? ?? 0,
    averageMood: (json['averageMood'] as num?)?.toDouble() ?? 3.0,
    moodImprovementPercent: json['moodImprovementPercent'] as int? ?? 0,
  );

  factory UserStats.empty() => UserStats();
}

class UserSettings {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool hapticEnabled;
  final String language;
  final String reminderTime;
  final bool dailyReminderEnabled;

  UserSettings({
    this.notificationsEnabled = true,
    this.darkModeEnabled = true,
    this.hapticEnabled = true,
    this.language = 'en',
    this.reminderTime = '09:00',
    this.dailyReminderEnabled = true,
  });

  Map<String, dynamic> toJson() => {
    'notificationsEnabled': notificationsEnabled,
    'darkModeEnabled': darkModeEnabled,
    'hapticEnabled': hapticEnabled,
    'language': language,
    'reminderTime': reminderTime,
    'dailyReminderEnabled': dailyReminderEnabled,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    darkModeEnabled: json['darkModeEnabled'] as bool? ?? true,
    hapticEnabled: json['hapticEnabled'] as bool? ?? true,
    language: json['language'] as String? ?? 'en',
    reminderTime: json['reminderTime'] as String? ?? '09:00',
    dailyReminderEnabled: json['dailyReminderEnabled'] as bool? ?? true,
  );

  factory UserSettings.defaults() => UserSettings();

  UserSettings copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? hapticEnabled,
    String? language,
    String? reminderTime,
    bool? dailyReminderEnabled,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      language: language ?? this.language,
      reminderTime: reminderTime ?? this.reminderTime,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
    );
  }
}
