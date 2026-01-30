// CBT Thought Record Model for MindFlow

/// Common cognitive distortions in CBT
enum CognitiveDistortion {
  allOrNothing('All-or-Nothing Thinking', 'Seeing things in black and white, with no middle ground'),
  overgeneralization('Overgeneralization', 'Making broad conclusions from a single event'),
  mentalFilter('Mental Filter', 'Focusing only on negative details while ignoring positives'),
  disqualifyingPositive('Disqualifying the Positive', 'Dismissing positive experiences as not counting'),
  jumpingToConclusions('Jumping to Conclusions', 'Making negative assumptions without evidence'),
  magnification('Magnification/Minimization', 'Blowing things out of proportion or shrinking their importance'),
  emotionalReasoning('Emotional Reasoning', 'Believing something is true because you feel it strongly'),
  shouldStatements('Should Statements', 'Rigid rules about how you or others should behave'),
  labeling('Labeling', 'Attaching a negative label to yourself or others'),
  personalization('Personalization', 'Blaming yourself for things outside your control'),
  catastrophizing('Catastrophizing', 'Expecting the worst possible outcome');

  final String label;
  final String description;

  const CognitiveDistortion(this.label, this.description);

  static CognitiveDistortion fromName(String name) {
    return CognitiveDistortion.values.firstWhere(
      (d) => d.name == name,
      orElse: () => CognitiveDistortion.allOrNothing,
    );
  }
}

class CbtRecord {
  final String id;
  final DateTime timestamp;
  final String situation; // What happened
  final String negativeThought; // Automatic negative thought
  final List<CognitiveDistortion> distortions; // Identified distortions
  final String reframedThought; // Balanced/positive reframe
  final int beliefBefore; // 0-100 belief in negative thought before
  final int beliefAfter; // 0-100 belief in negative thought after reframing

  CbtRecord({
    required this.id,
    required this.timestamp,
    required this.situation,
    required this.negativeThought,
    required this.distortions,
    required this.reframedThought,
    this.beliefBefore = 80,
    this.beliefAfter = 30,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'situation': situation,
    'negativeThought': negativeThought,
    'distortions': distortions.map((d) => d.name).toList(),
    'reframedThought': reframedThought,
    'beliefBefore': beliefBefore,
    'beliefAfter': beliefAfter,
  };

  factory CbtRecord.fromJson(Map<String, dynamic> json) => CbtRecord(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    situation: json['situation'] as String,
    negativeThought: json['negativeThought'] as String,
    distortions: (json['distortions'] as List)
        .map((d) => CognitiveDistortion.fromName(d as String))
        .toList(),
    reframedThought: json['reframedThought'] as String,
    beliefBefore: json['beliefBefore'] as int? ?? 80,
    beliefAfter: json['beliefAfter'] as int? ?? 30,
  );

  CbtRecord copyWith({
    String? id,
    DateTime? timestamp,
    String? situation,
    String? negativeThought,
    List<CognitiveDistortion>? distortions,
    String? reframedThought,
    int? beliefBefore,
    int? beliefAfter,
  }) {
    return CbtRecord(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      situation: situation ?? this.situation,
      negativeThought: negativeThought ?? this.negativeThought,
      distortions: distortions ?? this.distortions,
      reframedThought: reframedThought ?? this.reframedThought,
      beliefBefore: beliefBefore ?? this.beliefBefore,
      beliefAfter: beliefAfter ?? this.beliefAfter,
    );
  }
}
