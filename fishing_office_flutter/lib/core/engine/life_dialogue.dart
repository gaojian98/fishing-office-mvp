import 'life_memory.dart';
import 'life_profile.dart';
import 'relationship_memory.dart';
import 'relationship_profile.dart';

class LifeDialogue {
  const LifeDialogue({
    required this.dialogueId,
    required this.lifeId,
    required this.playerId,
    required this.targetId,
    required this.message,
    required this.source,
    required this.context,
    required this.createdAt,
  });

  factory LifeDialogue.fromContext({
    required LifeProfile profile,
    required RelationshipProfile relationship,
    required List<RelationshipMemory> memories,
    required List<LifeMemory> lifeMemories,
  }) {
    final message = _buildMessage(
      relationship: relationship,
      memories: memories,
      lifeMemories: lifeMemories,
    );
    return LifeDialogue(
      dialogueId: DateTime.now().microsecondsSinceEpoch.toString(),
      lifeId: profile.lifeId,
      playerId: profile.playerId,
      targetId: profile.targetId,
      message: message,
      source: 'life_state',
      context: {
        'relationshipLevel': relationship.level.name,
        'emotion': profile.emotion.name,
        'memoryCount': memories.length + lifeMemories.length,
      },
      createdAt: DateTime.now(),
    );
  }

  final String dialogueId;
  final String lifeId;
  final String playerId;
  final String targetId;
  final String message;
  final String source;
  final Map<String, dynamic> context;
  final DateTime createdAt;
}

String _buildMessage({
  required RelationshipProfile relationship,
  required List<RelationshipMemory> memories,
  required List<LifeMemory> lifeMemories,
}) {
  if (relationship.level == RelationshipLevel.companion ||
      relationship.level == RelationshipLevel.soulmate) {
    return '今天也想和你一起待一会儿。';
  }
  if (memories.isNotEmpty || lifeMemories.isNotEmpty) {
    return '我记得我们一起经历过一些事。';
  }
  return '你好，我在这里。';
}
