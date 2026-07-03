class OceanMemory {
  const OceanMemory({
    required this.memoryId,
    required this.memoryType,
    required this.description,
    required this.payload,
    required this.createdAt,
  });

  final String memoryId;
  final String memoryType;
  final String description;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
}
