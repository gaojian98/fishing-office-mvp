import 'package:flutter/foundation.dart';

import '../../models/living_world_config.dart';
import '../../models/resident_dialogue_config.dart';
import '../../models/resident_memory_config.dart';
import '../../models/resident_relationship_config.dart';
import '../managers/resident_life_manager.dart';
import '../managers/world_clock_manager.dart';
import 'resident_memory_engine.dart';
import 'resident_relationship_engine.dart';

class ResidentDialogueEngine {
  const ResidentDialogueEngine({
    required ResidentDialogueConfig config,
    required ResidentLifeManager lifeManager,
    required ResidentMemoryEngine memoryEngine,
    required ResidentRelationshipEngine relationshipEngine,
    WorldClockManager? worldClockManager,
  })  : _config = config,
        _lifeManager = lifeManager,
        _memoryEngine = memoryEngine,
        _relationshipEngine = relationshipEngine,
        _worldClockManager = worldClockManager;

  final ResidentDialogueConfig _config;
  final ResidentLifeManager _lifeManager;
  final ResidentMemoryEngine _memoryEngine;
  final ResidentRelationshipEngine _relationshipEngine;
  final WorldClockManager? _worldClockManager;

  ResidentDialogueEntry getDialogueForResident(
    String id, {
    WorldClockConfig? clock,
    DateTime? now,
  }) {
    final state =
        _lifeManager.getResidentCurrentState(id, clock: clock, now: now);
    final memory = _memoryEngine.getResidentMemory(id);
    final relationship = _relationshipEngine.getRelationship(id);
    final timeOfDay = _timeOfDay(clock, now);
    final matches = _config.dialogues
        .where((item) => item.residentId == id || item.residentId == '*')
        .where((item) =>
            _matches(item.conditions, state, memory, relationship, timeOfDay))
        .toList(growable: false);
    if (matches.isEmpty) {
      if (kDebugMode) {
        debugPrint('ResidentDialogueEngine | resident=$id result=fallback');
      }
      return _config.fallback;
    }
    final sorted = List<ResidentDialogueEntry>.from(matches)
      ..sort((a, b) {
        final priority = b.priority.compareTo(a.priority);
        if (priority != 0) return priority;
        return a.id.compareTo(b.id);
      });
    final selected = sorted.first;
    if (kDebugMode) {
      debugPrint(
          'ResidentDialogueEngine | resident=$id dialogue=${selected.id} relationship=${relationship.relationshipLevel}');
    }
    return selected;
  }

  bool _matches(
    ResidentDialogueConditions conditions,
    ResidentCurrentState state,
    ResidentMemoryRecord memory,
    ResidentRelationshipRecord relationship,
    String timeOfDay,
  ) {
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
