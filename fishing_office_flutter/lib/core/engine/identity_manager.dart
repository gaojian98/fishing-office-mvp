class IdentityManager {
  const IdentityManager();

  IdentityProfile resolve({
    required String playerId,
    required List<String> tags,
    Map<String, dynamic> context = const {},
  }) {
    final resolvedTags = List<String>.from(tags);
    final primaryLabel = resolvedTags.isNotEmpty ? resolvedTags.first : '未定义身份';
    return IdentityProfile(
      playerId: playerId,
      primaryLabel: primaryLabel,
      tags: resolvedTags,
      context: context,
      updatedAt: DateTime.now(),
    );
  }
}

class IdentityProfile {
  const IdentityProfile({
    required this.playerId,
    required this.primaryLabel,
    required this.tags,
    required this.context,
    required this.updatedAt,
  });

  final String playerId;
  final String primaryLabel;
  final List<String> tags;
  final Map<String, dynamic> context;
  final DateTime updatedAt;
}
