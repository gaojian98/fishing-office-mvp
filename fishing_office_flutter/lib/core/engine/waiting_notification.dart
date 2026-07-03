class WaitingNotification {
  const WaitingNotification({
    required this.notificationId,
    required this.type,
    required this.message,
    required this.effect,
    required this.visibleToPlayer,
    required this.payload,
    this.time,
  });

  final String notificationId;
  final String type;
  final String message;
  final String effect;
  final bool visibleToPlayer;
  final Map<String, dynamic> payload;
  final DateTime? time;
}
