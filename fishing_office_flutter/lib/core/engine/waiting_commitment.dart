class WaitingCommitment {
  const WaitingCommitment({
    this.plan = 'short',
    this.durationSeconds = 0,
    this.targetSeconds = 0,
    this.allowEarlyPull = true,
    this.metadata = const {},
  });

  final String plan;
  final int durationSeconds;
  final int targetSeconds;
  final bool allowEarlyPull;
  final Map<String, dynamic> metadata;

  WaitingCommitment copyWith({
    String? plan,
    int? durationSeconds,
    int? targetSeconds,
    bool? allowEarlyPull,
    Map<String, dynamic>? metadata,
  }) {
    return WaitingCommitment(
      plan: plan ?? this.plan,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      targetSeconds: targetSeconds ?? this.targetSeconds,
      allowEarlyPull: allowEarlyPull ?? this.allowEarlyPull,
      metadata: metadata ?? this.metadata,
    );
  }
}
