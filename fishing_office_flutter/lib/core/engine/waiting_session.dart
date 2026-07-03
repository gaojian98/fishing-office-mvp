import 'waiting_commitment.dart';

enum WaitingSessionState {
  idle,
  waiting,
  paused,
  committed,
  completed,
  cancelled,
}

class WaitingSession {
  const WaitingSession({
    required this.id,
    required this.commitment,
    required this.metadata,
    this.fishingSessionId,
    this.state = WaitingSessionState.idle,
    this.startedAt,
    this.updatedAt,
    this.elapsedSeconds = 0,
  });

  final String id;
  final String? fishingSessionId;
  final WaitingCommitment commitment;
  final WaitingSessionState state;
  final DateTime? startedAt;
  final DateTime? updatedAt;
  final int elapsedSeconds;
  final Map<String, dynamic> metadata;

  WaitingSession copyWith({
    String? id,
    String? fishingSessionId,
    WaitingCommitment? commitment,
    WaitingSessionState? state,
    DateTime? startedAt,
    DateTime? updatedAt,
    int? elapsedSeconds,
    Map<String, dynamic>? metadata,
  }) {
    return WaitingSession(
      id: id ?? this.id,
      fishingSessionId: fishingSessionId ?? this.fishingSessionId,
      commitment: commitment ?? this.commitment,
      state: state ?? this.state,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      metadata: metadata ?? this.metadata,
    );
  }
}
