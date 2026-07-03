class LifePersonality {
  const LifePersonality({
    this.curiosity = 50,
    this.patience = 50,
    this.humor = 50,
    this.courage = 50,
    this.kindness = 50,
    this.freedom = 50,
    this.metadata = const {},
  });

  final int curiosity;
  final int patience;
  final int humor;
  final int courage;
  final int kindness;
  final int freedom;
  final Map<String, dynamic> metadata;

  LifePersonality copyWith({
    int? curiosity,
    int? patience,
    int? humor,
    int? courage,
    int? kindness,
    int? freedom,
    Map<String, dynamic>? metadata,
  }) {
    return LifePersonality(
      curiosity: curiosity ?? this.curiosity,
      patience: patience ?? this.patience,
      humor: humor ?? this.humor,
      courage: courage ?? this.courage,
      kindness: kindness ?? this.kindness,
      freedom: freedom ?? this.freedom,
      metadata: metadata ?? this.metadata,
    );
  }
}
