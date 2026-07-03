class LegacyManager {
  const LegacyManager();

  MeaningLegacy build({
    required String playerId,
    required List<String> storyIds,
    required List<String> identityTags,
    Map<String, dynamic> context = const {},
  }) {
    return MeaningLegacy(
      legacyId: DateTime.now().microsecondsSinceEpoch.toString(),
      playerId: playerId,
      storyIds: storyIds,
      identityTags: identityTags,
      context: context,
      createdAt: DateTime.now(),
    );
  }
}

class MeaningLegacy {
  const MeaningLegacy({
    required this.legacyId,
    required this.playerId,
    required this.storyIds,
    required this.identityTags,
    required this.context,
    required this.createdAt,
  });

  final String legacyId;
  final String playerId;
  final List<String> storyIds;
  final List<String> identityTags;
  final Map<String, dynamic> context;
  final DateTime createdAt;
}
