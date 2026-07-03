import 'dart:async';

import 'emotion_state.dart';
import 'relationship_event.dart';
import 'relationship_memory.dart';
import 'relationship_profile.dart';

typedef RelationshipEngineListener = void Function(RelationshipEvent event);

class RelationshipEngine {
  RelationshipEngine({
    List<RelationshipEngineListener> listeners = const [],
  }) : _listeners = List<RelationshipEngineListener>.from(listeners);

  final List<RelationshipEngineListener> _listeners;
  final StreamController<RelationshipEvent> _eventController =
      StreamController<RelationshipEvent>.broadcast();

  Stream<RelationshipEvent> get events => _eventController.stream;

  RelationshipProfile createProfile({
    required String playerId,
    required String targetId,
    RelationshipLevel level = RelationshipLevel.stranger,
    int score = 0,
    EmotionState emotion = const EmotionState(),
    Map<String, dynamic> metadata = const {},
  }) {
    return RelationshipProfile(
      playerId: playerId,
      targetId: targetId,
      level: level,
      score: score,
      emotion: emotion,
      metadata: metadata,
    );
  }

  void addListener(RelationshipEngineListener listener) {
    _listeners.add(listener);
  }

  void removeListener(RelationshipEngineListener listener) {
    _listeners.remove(listener);
  }

  void emit(RelationshipEvent event) {
    for (final listener in List<RelationshipEngineListener>.from(_listeners)) {
      listener(event);
    }
    _eventController.add(event);
  }

  RelationshipProfile updateProfile({
    required RelationshipProfile profile,
    RelationshipLevel? level,
    int? score,
    EmotionState? emotion,
    Map<String, dynamic>? metadata,
  }) {
    final updated = profile.copyWith(
      level: level,
      score: score,
      emotion: emotion,
      metadata: metadata,
    );
    emit(RelationshipEvent.updated(profile: updated));
    return updated;
  }

  RelationshipMemory recordMemory({
    required RelationshipProfile profile,
    required String memoryType,
    required String description,
    Map<String, dynamic> payload = const {},
  }) {
    final memory = RelationshipMemory(
      memoryId: DateTime.now().microsecondsSinceEpoch.toString(),
      playerId: profile.playerId,
      targetId: profile.targetId,
      memoryType: memoryType,
      description: description,
      payload: payload,
      createdAt: DateTime.now(),
    );
    emit(RelationshipEvent.memoryRecorded(
      profile: profile,
      memory: memory,
    ));
    return memory;
  }

  Future<void> dispose() async {
    await _eventController.close();
  }
}
