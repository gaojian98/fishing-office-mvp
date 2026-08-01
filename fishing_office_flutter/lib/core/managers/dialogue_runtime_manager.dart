import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../models/resident_dialogue_config.dart';
import '../../models/resident_memory_config.dart';
import '../../models/resident_relationship_config.dart';
import '../engine/festival_manager.dart';
import '../engine/resident_memory_engine.dart';
import '../engine/resident_relationship_engine.dart';
import '../engine/weather_state.dart';
import '../utils/resident_mood.dart';
import 'festival_runtime_manager.dart';
import 'resident_life_manager.dart';
import 'resident_runtime_manager.dart';
import 'rumor_runtime_manager.dart';
import 'weather_runtime_manager.dart';
import 'world_clock_manager.dart';

class DialogueRuntimeManager {
  DialogueRuntimeManager({
    required ResidentDialogueConfig config,
    required ResidentRuntimeManager residentRuntimeManager,
    required ResidentMemoryEngine residentMemoryEngine,
    required ResidentRelationshipEngine residentRelationshipEngine,
    required WorldClockManager worldClockManager,
    FestivalRuntimeManager? festivalRuntimeManager,
    WeatherRuntimeManager? weatherRuntimeManager,
    RumorRuntimeManager? rumorRuntimeManager,
    Random? random,
  })  : _config = config,
        _residentRuntimeManager = residentRuntimeManager,
        _residentMemoryEngine = residentMemoryEngine,
        _residentRelationshipEngine = residentRelationshipEngine,
        _worldClockManager = worldClockManager,
        _festivalRuntimeManager = festivalRuntimeManager,
        _weatherRuntimeManager = weatherRuntimeManager,
        _rumorRuntimeManager = rumorRuntimeManager,
        _random = random ?? Random();

  final ResidentDialogueConfig _config;
  final ResidentRuntimeManager _residentRuntimeManager;
  final ResidentMemoryEngine _residentMemoryEngine;
  final ResidentRelationshipEngine _residentRelationshipEngine;
  final WorldClockManager _worldClockManager;
  final FestivalRuntimeManager? _festivalRuntimeManager;
  final WeatherRuntimeManager? _weatherRuntimeManager;
  final RumorRuntimeManager? _rumorRuntimeManager;
  final Random _random;
  final Set<String> _servedNonRepeatableIds = <String>{};

  List<String> get servedNonRepeatableIds =>
      _servedNonRepeatableIds.toList(growable: true)..sort();

  void loadServedNonRepeatableIds(List<String> ids) {
    _servedNonRepeatableIds
      ..clear()
      ..addAll(ids.where((id) => id.isNotEmpty));
  }

  List<ResidentDialogueEntry> getAvailableDialogues(String residentId) {
    final context = _DialogueRuntimeContext(
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
    );
    final matches = _config.dialogues
        .where((dialogue) => _matchesResident(dialogue, residentId))
        .where((dialogue) =>
            dialogue.repeatable ||
            !_servedNonRepeatableIds.contains(dialogue.id))
        .where((dialogue) => _matchesConditions(dialogue.conditions, context))
        .toList(growable: false);
    final mood = context.effectiveResidentMood;
    final sorted = List<ResidentDialogueEntry>.from(matches)
      ..sort((a, b) {
        final priority =
            _effectivePriority(b, mood).compareTo(_effectivePriority(a, mood));
        if (priority != 0) return priority;
        return a.id.compareTo(b.id);
      });
    return sorted;
  }

  ResidentDialogueEntry getDialogue(String residentId) {
    final available = getAvailableDialogues(residentId);
    if (available.isEmpty) {
      if (kDebugMode) {
        debugPrint(
            'DialogueRuntimeManager | resident=$residentId result=fallback');
      }
      return _config.fallback;
    }
    final topPriority = available.first.priority;
    final top = available
        .where((dialogue) => dialogue.priority == topPriority)
        .toList(growable: false);
    final selected =
        top.length == 1 ? top.first : top[_random.nextInt(top.length)];
    if (!selected.repeatable) {
      _servedNonRepeatableIds.add(selected.id);
    }
    if (kDebugMode) {
      final state = _residentRuntimeManager.getResidentCurrentState(residentId);
      final relationship =
          _residentRelationshipEngine.getRelationship(residentId);
      debugPrint(
        'DialogueRuntimeManager | resident=$residentId dialogue=${selected.id} '
        'time=${_timeOfDay()} weather=${_worldClockManager.weather().weatherType.name} '
        'festival=${_worldClockManager.festival().activeFestivals.join(',')} '
        'relationship=${relationship.relationshipLevel} mood=${state.mood} '
        'activity=${state.activity} location=${state.location}',
      );
    }
    return selected;
  }

  bool _matchesResident(ResidentDialogueEntry dialogue, String residentId) {
    return dialogue.residentId == residentId || dialogue.residentId == '*';
  }

  bool _matchesConditions(
    ResidentDialogueConditions conditions,
    _DialogueRuntimeContext context,
  ) {
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

  bool _matchesValue(String expected, String actual) {
    if (expected.isEmpty || expected == 'any') return true;
    return _tokens(expected).contains(actual);
  }

  bool _matchesMood(String expected, String actual) {
    if (expected.isEmpty || expected == 'any') return true;
    final actualMood = normalizeResidentMood(actual);
    return _tokens(expected).map(normalizeResidentMood).contains(actualMood);
  }

  int _effectivePriority(ResidentDialogueEntry dialogue, String mood) {
    final normalizedMood = normalizeResidentMood(mood);
    var priority = dialogue.priority;
    final conditionMood = dialogue.conditions.residentMood;
    if (conditionMood.isNotEmpty &&
        _matchesMood(conditionMood, normalizedMood)) {
      priority += 3;
    }
    if (dialogue.tags.map(normalizeResidentMood).contains(normalizedMood)) {
      priority += 1;
    }
    return priority;
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

class _DialogueRuntimeContext {
  const _DialogueRuntimeContext({
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
