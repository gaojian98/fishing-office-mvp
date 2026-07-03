import 'dart:async';

import 'life_dialogue.dart';
import 'life_emotion.dart';
import 'life_memory.dart';
import 'life_personality.dart';
import 'life_profile.dart';
import 'relationship_engine.dart';
import 'relationship_memory.dart';
import 'relationship_profile.dart';

typedef LifeEngineListener = void Function(LifeDialogue dialogue);

class LifeEngine {
  LifeEngine({
    required this.relationshipEngine,
    List<LifeEngineListener> listeners = const [],
  }) : _listeners = List<LifeEngineListener>.from(listeners);

  final RelationshipEngine relationshipEngine;
  final List<LifeEngineListener> _listeners;
  final StreamController<LifeDialogue> _dialogueController =
      StreamController<LifeDialogue>.broadcast();

  Stream<LifeDialogue> get dialogues => _dialogueController.stream;

  LifeProfile createProfile({
    required String lifeId,
    required String playerId,
    required String targetId,
    LifePersonality personality = const LifePersonality(),
    LifeEmotion emotion = const LifeEmotion(),
    Map<String, dynamic> metadata = const {},
  }) {
    return LifeProfile(
      lifeId: lifeId,
      playerId: playerId,
      targetId: targetId,
      personality: personality,
      emotion: emotion,
      metadata: metadata,
    );
  }

  void addListener(LifeEngineListener listener) {
    _listeners.add(listener);
  }

  void removeListener(LifeEngineListener listener) {
    _listeners.remove(listener);
  }

  void emit(LifeDialogue dialogue) {
    for (final listener in List<LifeEngineListener>.from(_listeners)) {
      listener(dialogue);
    }
    _dialogueController.add(dialogue);
  }

  LifeDialogue generateDialogue({
    required LifeProfile profile,
    required RelationshipProfile relationship,
    required List<RelationshipMemory> memories,
    List<LifeMemory> lifeMemories = const [],
  }) {
    final dialogue = LifeDialogue.fromContext(
      profile: profile,
      relationship: relationship,
      memories: memories,
      lifeMemories: lifeMemories,
    );
    emit(dialogue);
    return dialogue;
  }

  LifeProfile adaptProfile({
    required LifeProfile profile,
    RelationshipProfile? relationship,
    LifePersonality? personality,
    LifeEmotion? emotion,
    Map<String, dynamic>? metadata,
  }) {
    final adapted = profile.copyWith(
      relationship: relationship,
      personality: personality,
      emotion: emotion,
      metadata: metadata,
    );
    return adapted;
  }

  LifeEmotion resolveEmotion({
    required RelationshipProfile relationship,
    required List<RelationshipMemory> memories,
    required LifeProfile profile,
  }) {
    return LifeEmotion.resolve(
      relationship: relationship,
      memories: memories,
      profile: profile,
    );
  }

  Future<void> dispose() async {
    await _dialogueController.close();
  }
}
