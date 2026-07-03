class FishingResult {
  const FishingResult({
    required this.sessionId,
    required this.status,
    required this.fishId,
    required this.fishName,
    required this.value,
    required this.points,
    required this.keepable,
    required this.sellable,
    required this.companionEligible,
    required this.collectionEligible,
    required this.metadata,
  });

  factory FishingResult.pending({required String sessionId}) {
    return FishingResult(
      sessionId: sessionId,
      status: 'pending',
      fishId: '',
      fishName: '',
      value: 0,
      points: 0,
      keepable: false,
      sellable: false,
      companionEligible: false,
      collectionEligible: false,
      metadata: const {},
    );
  }

  final String sessionId;
  final String status;
  final String fishId;
  final String fishName;
  final int value;
  final int points;
  final bool keepable;
  final bool sellable;
  final bool companionEligible;
  final bool collectionEligible;
  final Map<String, dynamic> metadata;

  bool get isResolved => status != 'pending';
}
