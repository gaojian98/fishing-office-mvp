import 'life_emotion.dart';
import 'life_personality.dart';
import 'relationship_profile.dart';

class LifeProfile {
  const LifeProfile({
    required this.lifeId,
    required this.playerId,
    required this.targetId,
    required this.personality,
    required this.emotion,
    required this.metadata,
    this.relationship,
  });

  final String lifeId;
  final String playerId;
  final String targetId;
  final RelationshipProfile? relationship;
  final LifePersonality personality;
  final LifeEmotion emotion;
  final Map<String, dynamic> metadata;

  LifeProfile copyWith({
    String? lifeId,
    String? playerId,
    String? targetId,
    RelationshipProfile? relationship,
    LifePersonality? personality,
    LifeEmotion? emotion,
    Map<String, dynamic>? metadata,
  }) {
    return LifeProfile(
      lifeId: lifeId ?? this.lifeId,
      playerId: playerId ?? this.playerId,
      targetId: targetId ?? this.targetId,
      relationship: relationship ?? this.relationship,
      personality: personality ?? this.personality,
      emotion: emotion ?? this.emotion,
      metadata: metadata ?? this.metadata,
    );
  }
}
