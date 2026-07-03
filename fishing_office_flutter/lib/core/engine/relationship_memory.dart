class RelationshipMemory {
  const RelationshipMemory({
    required this.memoryId,
    required this.playerId,
    required this.targetId,
    required this.memoryType,
    required this.description,
    required this.payload,
    required this.createdAt,
  });

  final String memoryId;
  final String playerId;
  final String targetId;
  final String memoryType;
  final String description;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
}
