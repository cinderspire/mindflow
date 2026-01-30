// Journal Entry Model for MindFlow

enum JournalType { text, voice }

class JournalEntry {
  final String id;
  final String content;
  final DateTime timestamp;
  final String mood;
  final JournalType type;
  final String? audioPath;
  final String? audioDuration;
  final String? aiInsight;
  final List<String>? tags;

  JournalEntry({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.mood,
    this.type = JournalType.text,
    this.audioPath,
    this.audioDuration,
    this.aiInsight,
    this.tags,
  });

  bool get isVoiceEntry => type == JournalType.voice;

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'mood': mood,
    'type': type.name,
    'audioPath': audioPath,
    'audioDuration': audioDuration,
    'aiInsight': aiInsight,
    'tags': tags,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'] as String,
    content: json['content'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    mood: json['mood'] as String,
    type: JournalType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => JournalType.text,
    ),
    audioPath: json['audioPath'] as String?,
    audioDuration: json['audioDuration'] as String?,
    aiInsight: json['aiInsight'] as String?,
    tags: (json['tags'] as List?)?.cast<String>(),
  );

  JournalEntry copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    String? mood,
    JournalType? type,
    String? audioPath,
    String? audioDuration,
    String? aiInsight,
    List<String>? tags,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      mood: mood ?? this.mood,
      type: type ?? this.type,
      audioPath: audioPath ?? this.audioPath,
      audioDuration: audioDuration ?? this.audioDuration,
      aiInsight: aiInsight ?? this.aiInsight,
      tags: tags ?? this.tags,
    );
  }
}
