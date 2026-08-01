import '../managers/world_clock_manager.dart';

class FishingEvent {
  const FishingEvent({
    required this.type,
    required this.sessionId,
    required this.stage,
    required this.payload,
    required this.timestamp,
  });

  factory FishingEvent.started({required String sessionId}) {
    return FishingEvent(
      type: 'started',
      sessionId: sessionId,
      stage: 'preparing',
      payload: const {},
      timestamp: WorldClockManager.systemNow(),
    );
  }

  factory FishingEvent.updated({
    required String sessionId,
    required dynamic stage,
    required Map<String, dynamic> payload,
  }) {
    return FishingEvent(
      type: 'updated',
      sessionId: sessionId,
      stage: '$stage',
      payload: payload,
      timestamp: WorldClockManager.systemNow(),
    );
  }

  final String type;
  final String sessionId;
  final String stage;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
}
