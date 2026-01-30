// Gratitude Entry Model for MindFlow

class GratitudeEntry {
  final String id;
  final DateTime timestamp;
  final List<String> items; // 3 things you're grateful for
  final String? reflection; // optional additional reflection

  GratitudeEntry({
    required this.id,
    required this.timestamp,
    required this.items,
    this.reflection,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'items': items,
    'reflection': reflection,
  };

  factory GratitudeEntry.fromJson(Map<String, dynamic> json) => GratitudeEntry(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    items: (json['items'] as List).cast<String>(),
    reflection: json['reflection'] as String?,
  );

  GratitudeEntry copyWith({
    String? id,
    DateTime? timestamp,
    List<String>? items,
    String? reflection,
  }) {
    return GratitudeEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      items: items ?? this.items,
      reflection: reflection ?? this.reflection,
    );
  }
}
