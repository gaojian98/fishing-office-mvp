import 'relationship_memory.dart';
import 'relationship_profile.dart';

class RelationshipEvent {
  const RelationshipEvent({
    required this.eventId,
    required this.type,
    required this.profile,
    required this.memory,
    required this.message,
    required this.timestamp,
    required this.payload,
  });

  factory RelationshipEvent.updated({
    required RelationshipProfile profile,
  }) {
    return RelationshipEvent(
      eventId: DateTime.now().microsecondsSinceEpoch.toString(),
      type: 'updated',
      profile: profile,
      memory: null,
      message: 'relationship_updated',
      timestamp: DateTime.now(),
      payload: const {},
    );
  }

  factory RelationshipEvent.memoryRecorded({
    required RelationshipProfile profile,
    required RelationshipMemory memory,
  }) {
    return RelationshipEvent(
      eventId: memory.memoryId,
      type: 'memoryRecorded',
      profile: profile,
      memory: memory,
      message: memory.description,
      timestamp: memory.createdAt,
      payload: memory.payload,
    );
  }

  final String eventId;
  final String type;
  final RelationshipProfile profile;
  final RelationshipMemory? memory;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> payload;
}
