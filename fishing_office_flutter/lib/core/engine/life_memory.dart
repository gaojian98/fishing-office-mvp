class LifeMemory {
  const LifeMemory({
    required this.memoryId,
    required this.lifeId,
    required this.playerId,
    required this.targetId,
    required this.memoryType,
    required this.description,
    required this.createdAt,
    required this.payload,
  });

  final String memoryId;
  final String lifeId;
  final String playerId;
  final String targetId;
  final String memoryType;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic> payload;
}
