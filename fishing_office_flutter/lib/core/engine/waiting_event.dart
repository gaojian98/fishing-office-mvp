import 'waiting_notification.dart';

class WaitingEvent {
  const WaitingEvent({
    required this.eventId,
    required this.sessionId,
    required this.eventType,
    required this.time,
    required this.message,
    required this.effect,
    required this.visibleToPlayer,
    required this.payload,
    this.effectType,
    this.effectValue,
    this.target,
  });

  factory WaitingEvent.notification({
    required String sessionId,
    required WaitingNotification notification,
  }) {
    return WaitingEvent(
      eventId: notification.notificationId,
      sessionId: sessionId,
      eventType: notification.type,
      time: notification.time ?? DateTime.now(),
      message: notification.message,
      effect: notification.effect,
      visibleToPlayer: notification.visibleToPlayer,
      payload: notification.payload,
    );
  }

  final String eventId;
  final String sessionId;
  final String eventType;
  final DateTime time;
  final String message;
  final String effect;
  final bool visibleToPlayer;
  final Map<String, dynamic> payload;
  final String? effectType;
  final num? effectValue;
  final String? target;
}
