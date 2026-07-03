import 'emotion_state.dart';

enum RelationshipLevel {
  stranger,
  acquaintance,
  familiar,
  trust,
  companion,
  soulmate,
}

class RelationshipProfile {
  const RelationshipProfile({
    required this.playerId,
    required this.targetId,
    required this.level,
    required this.score,
    required this.emotion,
    required this.metadata,
  });

  final String playerId;
  final String targetId;
  final RelationshipLevel level;
  final int score;
  final EmotionState emotion;
  final Map<String, dynamic> metadata;

  RelationshipProfile copyWith({
    String? playerId,
    String? targetId,
    RelationshipLevel? level,
    int? score,
    EmotionState? emotion,
    Map<String, dynamic>? metadata,
  }) {
    return RelationshipProfile(
      playerId: playerId ?? this.playerId,
      targetId: targetId ?? this.targetId,
      level: level ?? this.level,
      score: score ?? this.score,
      emotion: emotion ?? this.emotion,
      metadata: metadata ?? this.metadata,
    );
  }
}
