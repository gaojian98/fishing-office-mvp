enum FishingSessionStage {
  preparing,
  waiting,
  fishInterested,
  fishTesting,
  fishEscaped,
  fishHooked,
  pulling,
  finished,
  cancelled,
}

class FishingSession {
  const FishingSession({
    required this.id,
    required this.initialData,
    this.stage = FishingSessionStage.preparing,
    this.data = const {},
  });

  final String id;
  final Map<String, dynamic> initialData;
  final FishingSessionStage stage;
  final Map<String, dynamic> data;

  FishingSession copyWith({
    String? id,
    Map<String, dynamic>? initialData,
    FishingSessionStage? stage,
    Map<String, dynamic>? data,
  }) {
    return FishingSession(
      id: id ?? this.id,
      initialData: initialData ?? this.initialData,
      stage: stage ?? this.stage,
      data: data ?? this.data,
    );
  }
}
