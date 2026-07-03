import 'dart:async';

import 'fishing_event.dart';
import 'fishing_result.dart';
import 'fishing_session.dart';
import 'ocean_engine.dart';

typedef FishingEngineListener = void Function(FishingEvent event);

class FishingEngine {
  FishingEngine({
    required this.oceanEngine,
    List<FishingEngineListener> listeners = const [],
  }) : _listeners = List<FishingEngineListener>.from(listeners);

  final OceanEngine oceanEngine;
  final List<FishingEngineListener> _listeners;
  final StreamController<FishingEvent> _eventController =
      StreamController<FishingEvent>.broadcast();

  Stream<FishingEvent> get events => _eventController.stream;

  FishingSession createSession({
    String? id,
    Map<String, dynamic> initialData = const {},
  }) {
    return FishingSession(
      id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      initialData: initialData,
    );
  }

  void addListener(FishingEngineListener listener) {
    _listeners.add(listener);
  }

  void removeListener(FishingEngineListener listener) {
    _listeners.remove(listener);
  }

  void emit(FishingEvent event) {
    for (final listener in List<FishingEngineListener>.from(_listeners)) {
      listener(event);
    }
    _eventController.add(event);
  }

  Future<FishingResult> resolve(FishingSession session) async {
    final oceanSnapshot = oceanEngine.state;
    final result = FishingResult.pending(sessionId: session.id);
    emit(FishingEvent.started(sessionId: session.id));
    emit(FishingEvent.updated(
      sessionId: session.id,
      stage: session.stage,
      payload: {
        ...session.data,
        'oceanState': oceanSnapshot.toMap(),
      },
    ));
    return result;
  }

  Future<void> dispose() async {
    await _eventController.close();
  }
}
