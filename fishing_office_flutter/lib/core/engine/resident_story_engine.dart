import 'package:flutter/foundation.dart';

import '../../models/living_world_config.dart';
import '../../models/resident_dialogue_config.dart';
import '../../models/resident_memory_config.dart';
import '../../models/resident_relationship_config.dart';
import '../../models/resident_story_config.dart';
import '../managers/resident_life_manager.dart';
import '../managers/world_clock_manager.dart';
import 'resident_dialogue_engine.dart';
import 'resident_memory_engine.dart';
import 'resident_relationship_engine.dart';

class ResidentStoryEngine {
  const ResidentStoryEngine({
    required ResidentStoryConfig config,
    required ResidentLifeManager lifeManager,
    required ResidentMemoryEngine memoryEngine,
    required ResidentRelationshipEngine relationshipEngine,
    required ResidentDialogueEngine dialogueEngine,
    WorldClockManager? worldClockManager,
  })  : _config = config,
        _lifeManager = lifeManager,
        _memoryEngine = memoryEngine,
        _relationshipEngine = relationshipEngine,
        _dialogueEngine = dialogueEngine,
        _worldClockManager = worldClockManager;

  final ResidentStoryConfig _config;
  final ResidentLifeManager _lifeManager;
  final ResidentMemoryEngine _memoryEngine;
  final ResidentRelationshipEngine _relationshipEngine;
  final ResidentDialogueEngine _dialogueEngine;
  final WorldClockManager? _worldClockManager;

  List<ResidentStoryEntry> getAvailableStoriesForResident(
    String id, {
    WorldClockConfig? clock,
    DateTime? now,
  }) {
    final state =
        _lifeManager.getResidentCurrentState(id, clock: clock, now: now);
    final memory = _memoryEngine.getResidentMemory(id);
    final relationship = _relationshipEngine.getRelationship(id);
    final dialogue =
        _dialogueEngine.getDialogueForResident(id, clock: clock, now: now);
    final timeOfDay = _timeOfDay(clock, now);
    final matches = _config.stories
        .where((item) => item.residentId == id || item.residentId == '*')
        .where((item) =>
            _matches(item, state, memory, relationship, dialogue, timeOfDay))
        .toList(growable: false);
    final sorted = List<ResidentStoryEntry>.from(matches)
      ..sort((a, b) {
        final priority = b.priority.compareTo(a.priority);
        if (priority != 0) return priority;
        return a.id.compareTo(b.id);
      });
    if (kDebugMode) {
      debugPrint(
          'ResidentStoryEngine | resident=$id available=${sorted.map((item) => item.id).join(',')}');
    }
    return sorted;
  }

  ResidentStoryTriggerResult? triggerResidentStory(
    String id,
    String storyId, {
    WorldClockConfig? clock,
    DateTime? now,
  }) {
    final story = getAvailableStoriesForResident(id, clock: clock, now: now)
        .where((item) => item.id == storyId)
        .firstOrNull;
    if (story == null) {
      if (kDebugMode) {
        debugPrint(
            'ResidentStoryEngine | resident=$id story=$storyId result=not_available');
      }
      return null;
    }
    final memory = _memoryEngine.recordInteraction(
      id,
      'story_triggered',
      time: now,
      tags: <String>{
        'story_triggered',
        'story:$storyId',
        ...story.tags,
        ...story.resultMemoryTags,
      }.toList(growable: false),
    );
    if (kDebugMode) {
      debugPrint(
          'ResidentStoryEngine | resident=$id story=$storyId result=triggered');
    }
    return ResidentStoryTriggerResult(story: story, memory: memory);
  }

  bool _matches(
    ResidentStoryEntry story,
    ResidentCurrentState state,
    ResidentMemoryRecord memory,
    ResidentRelationshipRecord relationship,
    ResidentDialogueEntry dialogue,
    String timeOfDay,
  ) {
    if (!story.repeatable && memory.memoryTags.contains('story:${story.id}')) {
      return false;
    }
    if (story.dialogueIds.isNotEmpty &&
        !story.dialogueIds.contains(dialogue.id)) {
      return false;
    }
    final conditions = story.conditions;
    if (conditions.timeOfDay.isNotEmpty && conditions.timeOfDay != timeOfDay) {
      return false;
    }
    if (conditions.location.isNotEmpty &&
        conditions.location != state.location) {
      return false;
    }
    if (conditions.activity.isNotEmpty &&
        conditions.activity != state.activity) {
      return false;
    }
    if (conditions.mood.isNotEmpty && conditions.mood != state.mood) {
      return false;
    }
    if (conditions.relationshipLevel.isNotEmpty &&
        conditions.relationshipLevel != relationship.relationshipLevel) {
      return false;
    }
    if (conditions.meetCountMin > 0 &&
        memory.meetCount < conditions.meetCountMin) {
      return false;
    }
    for (final tag in conditions.memoryTags) {
      if (!memory.memoryTags.contains(tag)) {
        return false;
      }
    }
    return true;
  }

  String _timeOfDay(WorldClockConfig? clock, DateTime? now) {
    final hour = clock?.hour ?? now?.hour ?? _worldClockManager?.hour() ?? 5;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 18) return 'afternoon';
    if (hour >= 18 && hour < 24) return 'night';
    return 'late_night';
  }
}

class ResidentStoryTriggerResult {
  const ResidentStoryTriggerResult({
    required this.story,
    required this.memory,
  });

  final ResidentStoryEntry story;
  final ResidentMemoryRecord memory;
}
