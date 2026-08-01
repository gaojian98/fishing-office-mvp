import 'package:flutter/foundation.dart';

import '../../models/resident_dialogue_config.dart';
import '../../models/resident_memory_config.dart';
import '../../models/resident_relationship_config.dart';
import '../../models/resident_story_config.dart';
import '../engine/festival_manager.dart';
import '../engine/resident_memory_engine.dart';
import '../engine/resident_relationship_engine.dart';
import '../engine/weather_state.dart';
import '../utils/resident_mood.dart';
import 'dialogue_runtime_manager.dart';
import 'festival_runtime_manager.dart';
import 'resident_life_manager.dart';
import 'resident_runtime_manager.dart';
import 'rumor_runtime_manager.dart';
import 'weather_runtime_manager.dart';
import 'world_clock_manager.dart';

class StoryRuntimeManager {
  StoryRuntimeManager({
    required ResidentStoryConfig config,
    required ResidentRuntimeManager residentRuntimeManager,
    required ResidentMemoryEngine residentMemoryEngine,
    required ResidentRelationshipEngine residentRelationshipEngine,
    required DialogueRuntimeManager dialogueRuntimeManager,
    required WorldClockManager worldClockManager,
    FestivalRuntimeManager? festivalRuntimeManager,
    WeatherRuntimeManager? weatherRuntimeManager,
    RumorRuntimeManager? rumorRuntimeManager,
  })  : _config = config,
        _residentRuntimeManager = residentRuntimeManager,
        _residentMemoryEngine = residentMemoryEngine,
        _residentRelationshipEngine = residentRelationshipEngine,
        _dialogueRuntimeManager = dialogueRuntimeManager,
        _worldClockManager = worldClockManager,
        _festivalRuntimeManager = festivalRuntimeManager,
        _weatherRuntimeManager = weatherRuntimeManager,
        _rumorRuntimeManager = rumorRuntimeManager;

  final ResidentStoryConfig _config;
  final ResidentRuntimeManager _residentRuntimeManager;
  final ResidentMemoryEngine _residentMemoryEngine;
  final ResidentRelationshipEngine _residentRelationshipEngine;
  final DialogueRuntimeManager _dialogueRuntimeManager;
  final WorldClockManager _worldClockManager;
  final FestivalRuntimeManager? _festivalRuntimeManager;
  final WeatherRuntimeManager? _weatherRuntimeManager;
  final RumorRuntimeManager? _rumorRuntimeManager;
  final Set<String> _finishedStoryIds = <String>{};

  List<String> get finishedStoryIds {
    _hydrateFinishedStories();
    return _finishedStoryIds.toList(growable: true)..sort();
  }

  void loadFinishedStoryIds(List<String> ids) {
    _finishedStoryIds
      ..clear()
      ..addAll(ids.where((id) => id.isNotEmpty));
  }

  List<ResidentStoryEntry> getAvailableStories(String residentId) {
    _hydrateFinishedStories();
    final context = _StoryRuntimeContext(
      residentId: residentId,
      timeOfDay: _timeOfDay(),
      weather: _worldClockManager.weather(),
      festival: _worldClockManager.festival(),
      festivalContext:
          _festivalRuntimeManager?.residentFestivalContext(residentId),
      weatherContext:
          _weatherRuntimeManager?.residentWeatherContext(residentId),
      rumorContext: _rumorRuntimeManager?.residentRumorContext(residentId),
      state: _residentRuntimeManager.getResidentCurrentState(residentId),
      memory: _residentMemoryEngine.getResidentMemory(residentId),
      relationship: _residentRelationshipEngine.getRelationship(residentId),
      availableDialogues:
          _dialogueRuntimeManager.getAvailableDialogues(residentId),
    );
    final matches = _config.stories
        .where((story) => _matchesResident(story, residentId))
        .where(_storyCanRepeat)
        .where((story) => _hasRequiredStories(story.conditions))
        .where((story) => _matchesConditions(story, context))
        .toList(growable: false);
    final sorted = List<ResidentStoryEntry>.from(matches)
      ..sort((a, b) {
        final priority = b.priority.compareTo(a.priority);
        if (priority != 0) return priority;
        return a.id.compareTo(b.id);
      });
    if (kDebugMode) {
      debugPrint(
        'StoryRuntimeManager | resident=$residentId available=${sorted.map((item) => item.id).join(',')}',
      );
    }
    return sorted;
  }

  StoryRuntimeResult? triggerStory(String residentId) {
    final available = getAvailableStories(residentId);
    if (available.isEmpty) {
      if (kDebugMode) {
        debugPrint(
            'StoryRuntimeManager | resident=$residentId result=not_available');
      }
      return null;
    }
    return finishStory(available.first.id);
  }

  StoryRuntimeResult? finishStory(String storyId) {
    final story = _findStory(storyId);
    if (story == null) {
      if (kDebugMode) {
        debugPrint('StoryRuntimeManager | story=$storyId result=missing');
      }
      return null;
    }
    if (!story.repeatable && hasFinishedStory(storyId)) {
      if (kDebugMode) {
        debugPrint('StoryRuntimeManager | story=$storyId result=already_done');
      }
      return null;
    }
    _finishedStoryIds.add(storyId);
    final beforeState =
        _residentRuntimeManager.getResidentCurrentState(story.residentId);
    final storyMood = _storyResultMood(story);
    final moodChanged = storyMood.isNotEmpty &&
        normalizeResidentMood(storyMood) != beforeState.mood;
    final memory = _residentMemoryEngine.recordInteraction(
      story.residentId,
      'story_triggered',
      tags: <String>{
        'story_triggered',
        'story:$storyId',
        ...story.tags,
        ...story.resultMemoryTags,
      }.toList(growable: false),
    );
    if (moodChanged) {
      final applied = _residentRuntimeManager.applyEmotionOverride(
        ResidentRuntimeOverride(
          residentId: story.residentId,
          location: beforeState.location,
          activity: beforeState.activity,
          mood: storyMood,
          dayCount: _worldClockManager.today().dayCount,
          source: 'story_runtime',
          reason: 'story_finished',
        ),
        reason: 'story_finished',
        major: true,
      );
      _residentMemoryEngine.recordEmotionChange(
        story.residentId,
        previousMood: beforeState.mood,
        newMood: applied.mood,
        reason: 'story_finished',
        relatedStoryId: story.id,
      );
    }
    final relationship =
        _residentRelationshipEngine.updateRelationship(story.residentId);
    final dialogue = _dialogueRuntimeManager.getDialogue(story.residentId);
    if (kDebugMode) {
      debugPrint(
        'StoryRuntimeManager | resident=${story.residentId} story=$storyId result=finished relationship=${relationship.relationshipLevel} dialogue=${dialogue.id}',
      );
    }
    return StoryRuntimeResult(
      story: story,
      memory: memory,
      relationship: relationship,
      refreshedDialogue: dialogue,
    );
  }

  bool hasFinishedStory(String storyId) {
    if (_finishedStoryIds.contains(storyId)) return true;
    for (final memory in _residentMemoryEngine.records) {
      if (memory.memoryTags.contains('story:$storyId')) {
        _finishedStoryIds.add(storyId);
        return true;
      }
    }
    return false;
  }

  bool _matchesResident(ResidentStoryEntry story, String residentId) {
    return story.residentId == residentId || story.residentId == '*';
  }

  bool _storyCanRepeat(ResidentStoryEntry story) {
    return story.repeatable || !hasFinishedStory(story.id);
  }

  bool _hasRequiredStories(ResidentStoryConditions conditions) {
    final required = <String>{
      ...conditions.requiredStories,
      ...conditions.finishedStories,
    };
    if (required.isEmpty) return true;
    return required.every(hasFinishedStory);
  }

  bool _matchesConditions(
    ResidentStoryEntry story,
    _StoryRuntimeContext context,
  ) {
    final conditions = story.conditions;
    if (story.dialogueIds.isNotEmpty &&
        !_dialogueIds(context).any(story.dialogueIds.contains)) {
      return false;
    }
    if (!_matchesValue(conditions.timeOfDay, context.timeOfDay)) return false;
    if (!_matchesWeather(
      conditions.weather,
      context.weather,
      context.weatherContext,
    )) {
      return false;
    }
    if (!_matchesFestival(
      conditions.festival,
      context.festival,
      context.festivalContext,
    )) {
      return false;
    }
    if (!_matchesValue(
        conditions.relationshipLevel, context.relationship.relationshipLevel)) {
      return false;
    }
    if (conditions.meetCountMin > 0 &&
        context.memory.meetCount < conditions.meetCountMin) {
      return false;
    }
    if (conditions.meetCount > 0 &&
        context.memory.meetCount != conditions.meetCount) {
      return false;
    }
    if (!_matchesValue(conditions.residentLocation, context.state.location)) {
      return false;
    }
    if (!_matchesValue(
        conditions.residentActivity, context.effectiveResidentActivity)) {
      return false;
    }
    if (!_matchesMood(conditions.residentMood, context.effectiveResidentMood)) {
      return false;
    }
    if (!_matchesMemoryTags(conditions.memoryTags, context.memory.memoryTags)) {
      return false;
    }
    if (!_matchesRumorTags(conditions.rumorTags, context.rumorContext)) {
      return false;
    }
    if (!_matchesStoryState(conditions.storyState, context.memory.memoryTags)) {
      return false;
    }
    return true;
  }

  Iterable<String> _dialogueIds(_StoryRuntimeContext context) {
    return context.availableDialogues.map((dialogue) => dialogue.id);
  }

  bool _matchesValue(String expected, String actual) {
    if (expected.isEmpty || expected == 'any') return true;
    return _tokens(expected).contains(actual);
  }

  bool _matchesMood(String expected, String actual) {
    if (expected.isEmpty || expected == 'any') return true;
    final actualMood = normalizeResidentMood(actual);
    return _tokens(expected).map(normalizeResidentMood).contains(actualMood);
  }

  String _storyResultMood(ResidentStoryEntry story) {
    final explicit = story.result['residentMood'] ??
        story.result['mood'] ??
        story.result['moodChange'];
    if (explicit is Map) {
      return normalizeResidentMood(explicit['newMood']?.toString() ?? '');
    }
    final explicitText = explicit?.toString() ?? '';
    if (explicitText.isNotEmpty) return normalizeResidentMood(explicitText);
    for (final tag in <String>{...story.tags, ...story.resultMemoryTags}) {
      final reason = moodReasonFromTag(tag);
      if (reason == 'player_helped') return 'grateful';
      if (reason == 'rumor_heard') return 'curious';
      if (reason == 'festival_started') return 'excited';
    }
    return '';
  }

  bool _matchesWeather(
    String expected,
    WeatherState weather,
    WeatherContext? context,
  ) {
    if (expected.isEmpty || expected == 'any') return true;
    final values = _tokens(expected);
    if (context != null) {
      return values.contains(context.weatherId) ||
          values.contains(context.weatherType) ||
          values.any(context.tags.contains);
    }
    return values.contains(weather.weatherType.name) ||
        values.contains(weather.title) ||
        values.contains(weather.title.toLowerCase());
  }

  bool _matchesFestival(
    String expected,
    FestivalState festival,
    FestivalContext? context,
  ) {
    if (expected.isEmpty || expected == 'any') return true;
    final hasFestival = context?.hasFestival ?? festival.hasFestival;
    if (expected == 'none') return !hasFestival;
    if (expected == 'active') return hasFestival;
    final values = _tokens(expected);
    if (context != null) {
      return values.any(context.tags.contains) ||
          context.activeFestivals.any((item) => values.contains(item.id));
    }
    return festival.activeFestivals.any(values.contains);
  }

  bool _matchesMemoryTags(List<String> expected, List<String> actual) {
    if (expected.isEmpty) return true;
    return expected.every(actual.contains);
  }

  bool _matchesRumorTags(List<String> expected, RumorContext? context) {
    if (expected.isEmpty) return true;
    if (context == null) return false;
    return expected.every(context.tags.contains);
  }

  bool _matchesStoryState(String expected, List<String> memoryTags) {
    if (expected.isEmpty || expected == 'any') return true;
    final hasStory = memoryTags.any((tag) =>
        tag == 'story_triggered' ||
        tag.startsWith('story:') ||
        tag.startsWith('story_'));
    if (expected == 'completed' || expected == 'story_completed') {
      return hasStory;
    }
    if (expected == 'none' || expected == 'not_started') return !hasStory;
    return memoryTags.contains(expected);
  }

  ResidentStoryEntry? _findStory(String storyId) {
    for (final story in _config.stories) {
      if (story.id == storyId) return story;
    }
    return null;
  }

  void _hydrateFinishedStories() {
    for (final memory in _residentMemoryEngine.records) {
      for (final tag in memory.memoryTags) {
        if (tag.startsWith('story:')) {
          _finishedStoryIds.add(tag.substring('story:'.length));
        }
      }
    }
  }

  List<String> _tokens(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String _timeOfDay() {
    final hour = _worldClockManager.hour();
    if (hour >= 5 && hour < 11) return 'morning';
    if (hour >= 11 && hour < 13) return 'noon';
    if (hour >= 13 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 20) return 'dusk';
    if (hour >= 20 && hour < 24) return 'night';
    return 'late_night';
  }
}

class StoryRuntimeResult {
  const StoryRuntimeResult({
    required this.story,
    required this.memory,
    required this.relationship,
    required this.refreshedDialogue,
  });

  final ResidentStoryEntry story;
  final ResidentMemoryRecord memory;
  final ResidentRelationshipRecord relationship;
  final ResidentDialogueEntry refreshedDialogue;
}

class _StoryRuntimeContext {
  const _StoryRuntimeContext({
    required this.residentId,
    required this.timeOfDay,
    required this.weather,
    required this.festival,
    required this.festivalContext,
    required this.weatherContext,
    required this.rumorContext,
    required this.state,
    required this.memory,
    required this.relationship,
    required this.availableDialogues,
  });

  final String residentId;
  final String timeOfDay;
  final WeatherState weather;
  final FestivalState festival;
  final FestivalContext? festivalContext;
  final WeatherContext? weatherContext;
  final RumorContext? rumorContext;
  final ResidentCurrentState state;
  final ResidentMemoryRecord memory;
  final ResidentRelationshipRecord relationship;
  final List<ResidentDialogueEntry> availableDialogues;

  String get effectiveResidentMood {
    final mood = festivalContext?.residentMood ?? '';
    if (mood.isNotEmpty) return normalizeResidentMood(mood);
    final weatherMood = weatherContext?.residentMood ?? '';
    return normalizeResidentMood(
        weatherMood.isEmpty ? state.mood : weatherMood);
  }

  String get effectiveResidentActivity {
    final activity = festivalContext?.residentActivity ?? '';
    if (activity.isNotEmpty) return activity;
    final weatherActivity = weatherContext?.residentActivity ?? '';
    return weatherActivity.isEmpty ? state.activity : weatherActivity;
  }
}
