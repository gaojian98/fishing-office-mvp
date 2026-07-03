import 'relationship_memory.dart';
import 'relationship_profile.dart';
import 'life_profile.dart';

class LifeEmotion {
  const LifeEmotion({
    this.name = 'Silent',
    this.intensity = 0,
    this.context = const {},
  });

  final String name;
  final int intensity;
  final Map<String, dynamic> context;

  factory LifeEmotion.resolve({
    required RelationshipProfile relationship,
    required List<RelationshipMemory> memories,
    required LifeProfile profile,
  }) {
    final score = relationship.score;
    final memoryCount = memories.length;
    final name = score >= 7000
        ? 'Peaceful'
        : score >= 4500
            ? 'Curious'
            : memoryCount > 3
                ? 'Thinking'
                : 'Silent';
    return LifeEmotion(
      name: name,
      intensity: (score / 1000).round().clamp(0, 10),
      context: {
        'relationshipLevel': relationship.level.name,
        'memoryCount': memoryCount,
        'lifeId': profile.lifeId,
      },
    );
  }

  LifeEmotion copyWith({
    String? name,
    int? intensity,
    Map<String, dynamic>? context,
  }) {
    return LifeEmotion(
      name: name ?? this.name,
      intensity: intensity ?? this.intensity,
      context: context ?? this.context,
    );
  }
}
