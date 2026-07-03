class EmotionState {
  const EmotionState({
    this.name = 'neutral',
    this.intensity = 0,
    this.mood = 'calm',
    this.metadata = const {},
  });

  final String name;
  final int intensity;
  final String mood;
  final Map<String, dynamic> metadata;

  EmotionState copyWith({
    String? name,
    int? intensity,
    String? mood,
    Map<String, dynamic>? metadata,
  }) {
    return EmotionState(
      name: name ?? this.name,
      intensity: intensity ?? this.intensity,
      mood: mood ?? this.mood,
      metadata: metadata ?? this.metadata,
    );
  }
}
