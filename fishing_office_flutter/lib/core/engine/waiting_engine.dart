import 'dart:async';

import 'waiting_event.dart';
import 'waiting_notification.dart';
import 'waiting_session.dart';
import 'waiting_commitment.dart';

typedef WaitingEngineListener = void Function(WaitingEvent event);

class WaitingEngine {
  WaitingEngine({
    List<WaitingEngineListener> listeners = const [],
  }) : _listeners = List<WaitingEngineListener>.from(listeners);

  final List<WaitingEngineListener> _listeners;
  final StreamController<WaitingEvent> _eventController =
      StreamController<WaitingEvent>.broadcast();

  Stream<WaitingEvent> get events => _eventController.stream;

  WaitingSession createSession({
    String? id,
    String? fishingSessionId,
    WaitingCommitment commitment = const WaitingCommitment(),
    Map<String, dynamic> metadata = const {},
  }) {
    return WaitingSession(
      id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      fishingSessionId: fishingSessionId,
      commitment: commitment,
      metadata: metadata,
    );
  }

  void addListener(WaitingEngineListener listener) {
    _listeners.add(listener);
  }

  void removeListener(WaitingEngineListener listener) {
    _listeners.remove(listener);
  }

  void emit(WaitingEvent event) {
    for (final listener in List<WaitingEngineListener>.from(_listeners)) {
      listener(event);
    }
    _eventController.add(event);
  }

  void notify(
    WaitingSession session,
    WaitingNotification notification,
  ) {
    emit(
      WaitingEvent.notification(
        sessionId: session.id,
        notification: notification,
      ),
    );
  }

  Future<void> dispose() async {
    await _eventController.close();
  }
}
