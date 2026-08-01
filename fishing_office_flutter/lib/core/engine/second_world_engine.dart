import 'package:flutter/foundation.dart';

import '../../models/living_world_config.dart';
import '../../models/resident_config.dart';
import '../../models/resident_dialogue_config.dart';
import '../../models/resident_memory_config.dart';
import '../../models/resident_relationship_config.dart';
import '../../models/resident_story_config.dart';
import '../managers/dialogue_runtime_manager.dart';
import '../managers/daily_simulation_manager.dart';
import '../managers/dynamic_event_runtime_manager.dart';
import '../managers/festival_runtime_manager.dart';
import '../managers/resident_runtime_manager.dart';
import '../managers/resident_life_manager.dart';
import '../managers/rumor_runtime_manager.dart';
import '../managers/story_runtime_manager.dart';
import '../managers/weather_runtime_manager.dart';
import '../managers/world_save_manager.dart';
import '../services/fairy_event_service.dart';
import 'resident_dialogue_engine.dart';
import 'resident_memory_engine.dart';
import 'resident_relationship_engine.dart';
import 'resident_story_engine.dart';

class SecondWorldEngine {
  const SecondWorldEngine({
    required ResidentConfig residentConfig,
    required ResidentLifeManager residentLifeEngine,
    required ResidentMemoryEngine residentMemoryEngine,
    required ResidentRelationshipEngine residentRelationshipEngine,
    required ResidentDialogueEngine residentDialogueEngine,
    required ResidentStoryEngine residentStoryEngine,
    DialogueRuntimeManager? dialogueRuntimeManager,
    StoryRuntimeManager? storyRuntimeManager,
    FestivalRuntimeManager? festivalRuntimeManager,
    WeatherRuntimeManager? weatherRuntimeManager,
    RumorRuntimeManager? rumorRuntimeManager,
    WorldSaveManager? worldSaveManager,
    ResidentRuntimeManager? residentRuntimeManager,
  })  : _residentConfig = residentConfig,
        _residentLifeEngine = residentLifeEngine,
        _residentMemoryEngine = residentMemoryEngine,
        _residentRelationshipEngine = residentRelationshipEngine,
        _residentDialogueEngine = residentDialogueEngine,
        _residentStoryEngine = residentStoryEngine,
        _dialogueRuntimeManager = dialogueRuntimeManager,
        _storyRuntimeManager = storyRuntimeManager,
        _festivalRuntimeManager = festivalRuntimeManager,
        _weatherRuntimeManager = weatherRuntimeManager,
        _rumorRuntimeManager = rumorRuntimeManager,
        _worldSaveManager = worldSaveManager,
        _residentRuntimeManager = residentRuntimeManager;

  final ResidentConfig _residentConfig;
  final ResidentLifeManager _residentLifeEngine;
  final ResidentMemoryEngine _residentMemoryEngine;
  final ResidentRelationshipEngine _residentRelationshipEngine;
  final ResidentDialogueEngine _residentDialogueEngine;
  final ResidentStoryEngine _residentStoryEngine;
  final DialogueRuntimeManager? _dialogueRuntimeManager;
  final StoryRuntimeManager? _storyRuntimeManager;
  final FestivalRuntimeManager? _festivalRuntimeManager;
  final WeatherRuntimeManager? _weatherRuntimeManager;
  final RumorRuntimeManager? _rumorRuntimeManager;
  final WorldSaveManager? _worldSaveManager;
  final ResidentRuntimeManager? _residentRuntimeManager;

  Future<void> loadWorld() async {
    await _worldSaveManager?.loadWorld();
  }

  Future<void> startWorld({
    DailySimulationManager? dailySimulationManager,
  }) async {
    await loadWorld();
    if (dailySimulationManager != null &&
        !dailySimulationManager.hasRunToday()) {
      await dailySimulationManager.runDailySimulation();
    }
  }

  Future<void> saveWorld() async {
    await _worldSaveManager?.saveWorld();
  }

  FairyEventSelection? selectFairyEvent(
    FairyEventService service, {
    Duration waitingDuration = Duration.zero,
  }) {
    return service.selectEvent(waitingDuration: waitingDuration);
  }

  DynamicEventRuntimeRecord? triggerFairyEvent(
    FairyEventService service, {
    Duration waitingDuration = Duration.zero,
  }) {
    return service.triggerFairyEvent(waitingDuration: waitingDuration);
  }

  ResidentContext getResidentContext(
    String id, {
    WorldClockConfig? clock,
    DateTime? now,
  }) {
    final resident = _residentConfig.findResident(id);
    final runtime = _residentRuntimeManager;
    final life = clock == null && now == null && runtime != null
        ? runtime.getResidentCurrentState(id)
        : _residentLifeEngine.getResidentCurrentState(
            id,
            clock: clock,
            now: now,
          );
    final memory = _residentMemoryEngine.getResidentMemory(id);
    final relationship = _residentRelationshipEngine.getRelationship(id);
    final dialogue = _dialogueForResident(id, clock: clock, now: now);
    final availableStories =
        _availableStoriesForResident(id, clock: clock, now: now);
    final festival = clock == null && now == null
        ? _festivalRuntimeManager?.residentFestivalContext(id)
        : null;
    final weather = clock == null && now == null
        ? _weatherRuntimeManager?.residentWeatherContext(id)
        : null;
    final rumor = clock == null && now == null
        ? _rumorRuntimeManager?.residentRumorContext(id)
        : null;
    return ResidentContext(
      resident: resident,
      life: life,
      memory: memory,
      relationship: relationship,
      dialogue: dialogue,
      availableStories: availableStories,
      festival: festival,
      weather: weather,
      rumor: rumor,
    );
  }

  InteractionResult interactWithResident(
    String id, {
    WorldClockConfig? clock,
    DateTime? now,
  }) {
    final beforeRelationship = _residentRelationshipEngine.getRelationship(id);
    final beforeMemory = _residentMemoryEngine.getResidentMemory(id);
    final beforeContext = getResidentContext(id, clock: clock, now: now);
    final beforeMood = beforeContext.life.mood;
    _residentMemoryEngine.getResidentMemory(id);
    _residentRelationshipEngine.updateRelationship(id, time: now);
    final dialogue = _dialogueForResident(id, clock: clock, now: now);
    final availableStories =
        _availableStoriesForResident(id, clock: clock, now: now);
    ResidentStoryEntry? story;
    ResidentMemoryRecord afterMemory;
    final storyRuntime = _storyRuntimeManager;
    if (storyRuntime != null && clock == null && now == null) {
      final triggered = storyRuntime.triggerStory(id);
      story = triggered?.story;
      afterMemory = triggered?.memory ??
          _residentMemoryEngine.recordInteraction(
            id,
            'resident_interaction',
            time: now,
            tags: const <String>['resident_interaction'],
          );
    } else if (availableStories.isNotEmpty) {
      final triggered = _residentStoryEngine.triggerResidentStory(
        id,
        availableStories.first.id,
        clock: clock,
        now: now,
      );
      story = triggered?.story;
      afterMemory =
          triggered?.memory ?? _residentMemoryEngine.getResidentMemory(id);
    } else {
      afterMemory = _residentMemoryEngine.recordInteraction(
        id,
        'resident_interaction',
        time: now,
        tags: const <String>['resident_interaction'],
      );
    }
    final afterRelationship =
        _residentRelationshipEngine.updateRelationship(id, time: now);
    final context = getResidentContext(id, clock: clock, now: now);
    final currentMood = context.life.mood;
    final moodChanged = beforeMood != currentMood;
    final moodChangeReason = _moodChangeReason(afterMemory, currentMood);
    final tags = <String>{
      ...dialogue.tags,
      if (story != null) ...story.tags,
      ...afterMemory.memoryTags,
    }.where((item) => item.isNotEmpty).toList(growable: false);
    final result = InteractionResult(
      context: context,
      dialogue: dialogue,
      story: story,
      relationshipChanged: beforeRelationship.relationshipLevel !=
              afterRelationship.relationshipLevel ||
          beforeRelationship.relationshipScore !=
              afterRelationship.relationshipScore,
      memoryChanged: beforeMemory.meetCount != afterMemory.meetCount ||
          beforeMemory.memoryTags.join('|') != afterMemory.memoryTags.join('|'),
      tags: tags,
      currentMood: currentMood,
      moodChanged: moodChanged,
      moodChangeReason: moodChangeReason,
    );
    if (kDebugMode) {
      debugPrint(
          'SecondWorldEngine | resident=$id dialogue=${dialogue.id} story=${story?.id ?? ''} relationshipChanged=${result.relationshipChanged} memoryChanged=${result.memoryChanged}');
    }
    _worldSaveManager?.recordInteraction(
      residentId: id,
      dialogueId: dialogue.id,
      storyId: story?.id ?? '',
      tags: tags,
    );
    return result;
  }

  ResidentDialogueEntry _dialogueForResident(
    String id, {
    WorldClockConfig? clock,
    DateTime? now,
  }) {
    final runtime = _dialogueRuntimeManager;
    if (runtime != null && clock == null && now == null) {
      return runtime.getDialogue(id);
    }
    return _residentDialogueEngine.getDialogueForResident(
      id,
      clock: clock,
      now: now,
    );
  }

  List<ResidentStoryEntry> _availableStoriesForResident(
    String id, {
    WorldClockConfig? clock,
    DateTime? now,
  }) {
    final runtime = _storyRuntimeManager;
    if (runtime != null && clock == null && now == null) {
      return runtime.getAvailableStories(id);
    }
    return _residentStoryEngine.getAvailableStoriesForResident(
      id,
      clock: clock,
      now: now,
    );
  }

  String _moodChangeReason(ResidentMemoryRecord memory, String currentMood) {
    for (final item in memory.emotionHistory.reversed) {
      if (item['newMood']?.toString() == currentMood) {
        return item['reason']?.toString() ?? '';
      }
    }
    final reasonTag = memory.memoryTags.lastWhere(
      (tag) => tag.startsWith('mood_reason:'),
      orElse: () => '',
    );
    return reasonTag.replaceFirst('mood_reason:', '');
  }
}

class ResidentContext {
  const ResidentContext({
    required this.resident,
    required this.life,
    required this.memory,
    required this.relationship,
    required this.dialogue,
    required this.availableStories,
    this.festival,
    this.weather,
    this.rumor,
  });

  final ResidentProfile resident;
  final ResidentCurrentState life;
  final ResidentMemoryRecord memory;
  final ResidentRelationshipRecord relationship;
  final ResidentDialogueEntry dialogue;
  final List<ResidentStoryEntry> availableStories;
  final FestivalContext? festival;
  final WeatherContext? weather;
  final RumorContext? rumor;
}

class InteractionResult {
  const InteractionResult({
    required this.context,
    required this.dialogue,
    required this.story,
    required this.relationshipChanged,
    required this.memoryChanged,
    required this.tags,
    this.currentMood = '',
    this.moodChanged = false,
    this.moodChangeReason = '',
  });

  final ResidentContext context;
  final ResidentDialogueEntry dialogue;
  final ResidentStoryEntry? story;
  final bool relationshipChanged;
  final bool memoryChanged;
  final List<String> tags;
  final String currentMood;
  final bool moodChanged;
  final String moodChangeReason;
}
