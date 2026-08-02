import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/living_office_state.dart';
import '../../models/office_group.dart';
import '../../models/player_influence.dart';
import '../engine/second_world_engine.dart';
import 'achievement_runtime_manager.dart';
import 'dialogue_runtime_manager.dart';
import 'dynamic_event_runtime_manager.dart';
import 'economy_runtime_manager.dart';
import 'festival_runtime_manager.dart';
import 'fish_runtime_manager.dart';
import 'quest_runtime_manager.dart';
import 'resident_decision_manager.dart';
import 'relationship_runtime_manager.dart';
import 'resident_runtime_manager.dart';
import 'rumor_runtime_manager.dart';
import 'story_runtime_manager.dart';
import 'weather_runtime_manager.dart';
import 'world_clock_manager.dart';
import 'world_save_manager.dart';

enum TickType {
  minuteTick,
  hourTick,
  dayTick,
  weekTick,
  monthTick,
}

enum TickEventType {
  beforeTick,
  afterTick,
}

class TickEvent {
  const TickEvent({
    required this.type,
    required this.tickType,
    required this.stage,
  });

  final TickEventType type;
  final TickType tickType;
  final String stage;
}

class SimulationProfile {
  const SimulationProfile({
    required this.tickType,
    required this.startedAt,
    required this.finishedAt,
    required this.durationMs,
    required this.executedStages,
    required this.skippedStages,
    required this.errorStages,
  });

  final TickType tickType;
  final DateTime startedAt;
  final DateTime finishedAt;
  final int durationMs;
  final List<String> executedStages;
  final List<String> skippedStages;
  final Map<String, String> errorStages;
}

class SimulationProfiler {
  final List<SimulationProfile> _profiles = <SimulationProfile>[];

  List<SimulationProfile> get profiles =>
      List<SimulationProfile>.from(_profiles);
  SimulationProfile? get lastProfile =>
      _profiles.isEmpty ? null : _profiles.last;

  SimulationProfile record({
    required TickType tickType,
    required DateTime startedAt,
    required DateTime finishedAt,
    required List<String> executedStages,
    required List<String> skippedStages,
    required Map<String, String> errorStages,
  }) {
    final profile = SimulationProfile(
      tickType: tickType,
      startedAt: startedAt,
      finishedAt: finishedAt,
      durationMs: finishedAt.difference(startedAt).inMilliseconds,
      executedStages: List<String>.from(executedStages),
      skippedStages: List<String>.from(skippedStages),
      errorStages: Map<String, String>.from(errorStages),
    );
    _profiles.add(profile);
    return profile;
  }
}

class SimulationTickResult {
  const SimulationTickResult({
    required this.success,
    required this.tickType,
    required this.executedStages,
    required this.skippedStages,
    required this.errors,
    required this.durationMs,
    required this.stateChanged,
    required this.worldContext,
    required this.runtimeResults,
  });

  final bool success;
  final TickType tickType;
  final List<String> executedStages;
  final List<String> skippedStages;
  final Map<String, String> errors;
  final int durationMs;
  final bool stateChanged;
  final WorldSimulationContext worldContext;
  final List<RuntimeResult> runtimeResults;

  double get cacheHitRate {
    final total = executedStages.length + skippedStages.length;
    if (total == 0) return 0;
    return skippedStages.length / total;
  }
}

class SimulationRuntimeCache {
  final Map<String, String> _keys = <String, String>{};
  final Map<String, Object?> _values = <String, Object?>{};

  bool isFresh(String id, String key) => _keys[id] == key;

  T remember<T>(String id, String key, T Function() loader) {
    if (_keys[id] == key && _values.containsKey(id)) {
      return _values[id] as T;
    }
    final value = loader();
    _keys[id] = key;
    _values[id] = value;
    return value;
  }

  void markFresh(String id, String key) {
    _keys[id] = key;
  }

  void invalidateWhere(bool Function(String id) test) {
    for (final id in _keys.keys.toList(growable: false)) {
      if (test(id)) {
        _keys.remove(id);
        _values.remove(id);
      }
    }
  }

  void clear() {
    _keys.clear();
    _values.clear();
  }
}

class WorldSimulationContext {
  const WorldSimulationContext({
    required this.tickType,
    required this.clock,
    required this.festivals,
    required this.festivalTags,
    required this.weather,
    required this.weatherTags,
    required this.residentStates,
    required this.rumors,
    required this.rumorTags,
    required this.fishPool,
    required this.economy,
    required this.relationships,
    required this.events,
    required this.quests,
    required this.achievements,
    required this.worldDate,
    required this.timeOfDay,
    required this.weekday,
    required this.season,
    required this.weatherContext,
    required this.festivalContext,
    required this.activeRumors,
    required this.residentSnapshot,
    required this.locationSnapshot,
    required this.personalitySnapshot,
    required this.friendshipSnapshot,
    required this.activeGroups,
    required this.activeStories,
    required this.activeEvents,
    required this.careerContext,
    required this.skillSummary,
    required this.questSummary,
    required this.achievementSummary,
    required this.livingOfficeState,
    required this.playerInfluenceContext,
    required this.errors,
  });

  final TickType tickType;
  final String clock;
  final List<Object?> festivals;
  final List<String> festivalTags;
  final Object? weather;
  final List<String> weatherTags;
  final Map<String, Object?> residentStates;
  final List<Object?> rumors;
  final List<String> rumorTags;
  final List<Object?> fishPool;
  final Map<String, Object?> economy;
  final Map<String, Object?> relationships;
  final List<Object?> events;
  final Map<String, Object?> quests;
  final List<Object?> achievements;
  final String worldDate;
  final String timeOfDay;
  final int weekday;
  final String season;
  final Object? weatherContext;
  final Object? festivalContext;
  final List<Object?> activeRumors;
  final Map<String, Object?> residentSnapshot;
  final Map<String, Object?> locationSnapshot;
  final Map<String, Object?> personalitySnapshot;
  final Map<String, Object?> friendshipSnapshot;
  final List<OfficeGroup> activeGroups;
  final List<Object?> activeStories;
  final List<Object?> activeEvents;
  final Object? careerContext;
  final Map<String, Object?> skillSummary;
  final Map<String, Object?> questSummary;
  final List<Object?> achievementSummary;
  final LivingOfficeState livingOfficeState;
  final PlayerInfluenceContext playerInfluenceContext;
  final Map<String, String> errors;

  String get signature {
    return [
      clock,
      festivalTags.join('|'),
      weather?.toString() ?? '',
      residentStates.length,
      rumorTags.join('|'),
      fishPool.length,
      economy.entries.map((entry) => '${entry.key}:${entry.value}').join('|'),
      relationships.length,
      events.length,
      quests.entries.map((entry) => '${entry.key}:${entry.value}').join('|'),
      achievements.length,
      livingOfficeState.officeMood,
      livingOfficeState.activityLevel,
      livingOfficeState.socialLevel,
      livingOfficeState.tensionLevel,
      playerInfluenceContext.officeInfluence.overall,
      playerInfluenceContext.reputation.join('|'),
    ].join('::');
  }

  WorldSimulationContext copyWith({
    List<OfficeGroup>? activeGroups,
    List<Object?>? activeStories,
    List<Object?>? activeEvents,
    LivingOfficeState? livingOfficeState,
    PlayerInfluenceContext? playerInfluenceContext,
  }) {
    return WorldSimulationContext(
      tickType: tickType,
      clock: clock,
      festivals: festivals,
      festivalTags: festivalTags,
      weather: weather,
      weatherTags: weatherTags,
      residentStates: residentStates,
      rumors: rumors,
      rumorTags: rumorTags,
      fishPool: fishPool,
      economy: economy,
      relationships: relationships,
      events: events,
      quests: quests,
      achievements: achievements,
      worldDate: worldDate,
      timeOfDay: timeOfDay,
      weekday: weekday,
      season: season,
      weatherContext: weatherContext,
      festivalContext: festivalContext,
      activeRumors: activeRumors,
      residentSnapshot: residentSnapshot,
      locationSnapshot: locationSnapshot,
      personalitySnapshot: personalitySnapshot,
      friendshipSnapshot: friendshipSnapshot,
      activeGroups: activeGroups ?? this.activeGroups,
      activeStories: activeStories ?? this.activeStories,
      activeEvents: activeEvents ?? this.activeEvents,
      careerContext: careerContext,
      skillSummary: skillSummary,
      questSummary: questSummary,
      achievementSummary: achievementSummary,
      livingOfficeState: livingOfficeState ?? this.livingOfficeState,
      playerInfluenceContext:
          playerInfluenceContext ?? this.playerInfluenceContext,
      errors: errors,
    );
  }
}

class RuntimeResult {
  const RuntimeResult({
    required this.stage,
    required this.success,
    required this.stateChanged,
    required this.changedKeys,
    required this.cacheInvalidations,
    required this.saveRequired,
    required this.errors,
    required this.durationMs,
    required this.skipped,
  });

  final String stage;
  final bool success;
  final bool stateChanged;
  final List<String> changedKeys;
  final List<String> cacheInvalidations;
  final bool saveRequired;
  final Map<String, String> errors;
  final int durationMs;
  final bool skipped;
}

class WorldTickContext {
  const WorldTickContext({
    required this.tickType,
    required this.beforeClockDay,
    required this.beforeClockHour,
    required this.beforeClockMinute,
    required this.afterClockDay,
    required this.afterClockHour,
    required this.afterClockMinute,
    required this.events,
    required this.stages,
    required this.livingOfficeState,
    required this.playerInfluenceContext,
  });

  final TickType tickType;
  final int beforeClockDay;
  final int beforeClockHour;
  final int beforeClockMinute;
  final int afterClockDay;
  final int afterClockHour;
  final int afterClockMinute;
  final List<TickEvent> events;
  final List<String> stages;
  final LivingOfficeState livingOfficeState;
  final PlayerInfluenceContext playerInfluenceContext;
}

class WorldTickManager extends ChangeNotifier {
  WorldTickManager({
    required WorldClockManager worldClockManager,
    required FestivalRuntimeManager festivalRuntimeManager,
    required WeatherRuntimeManager weatherRuntimeManager,
    required RumorRuntimeManager rumorRuntimeManager,
    required ResidentRuntimeManager residentRuntimeManager,
    required DialogueRuntimeManager dialogueRuntimeManager,
    required StoryRuntimeManager storyRuntimeManager,
    required WorldSaveManager worldSaveManager,
    FishRuntimeManager? fishRuntimeManager,
    EconomyRuntimeManager? economyRuntimeManager,
    QuestRuntimeManager? questRuntimeManager,
    RelationshipRuntimeManager? relationshipRuntimeManager,
    AchievementRuntimeManager? achievementRuntimeManager,
    DynamicEventRuntimeManager? dynamicEventRuntimeManager,
    ResidentDecisionManager? residentDecisionManager,
    SecondWorldEngine? secondWorldEngine,
  })  : _worldClockManager = worldClockManager,
        _festivalRuntimeManager = festivalRuntimeManager,
        _weatherRuntimeManager = weatherRuntimeManager,
        _rumorRuntimeManager = rumorRuntimeManager,
        _residentRuntimeManager = residentRuntimeManager,
        _dialogueRuntimeManager = dialogueRuntimeManager,
        _storyRuntimeManager = storyRuntimeManager,
        _worldSaveManager = worldSaveManager,
        _fishRuntimeManager = fishRuntimeManager,
        _economyRuntimeManager = economyRuntimeManager,
        _questRuntimeManager = questRuntimeManager,
        _relationshipRuntimeManager = relationshipRuntimeManager,
        _achievementRuntimeManager = achievementRuntimeManager,
        _dynamicEventRuntimeManager = dynamicEventRuntimeManager,
        _residentDecisionManager = residentDecisionManager,
        _secondWorldEngine = secondWorldEngine;

  final WorldClockManager _worldClockManager;
  final FestivalRuntimeManager _festivalRuntimeManager;
  final WeatherRuntimeManager _weatherRuntimeManager;
  final RumorRuntimeManager _rumorRuntimeManager;
  final ResidentRuntimeManager _residentRuntimeManager;
  final DialogueRuntimeManager _dialogueRuntimeManager;
  final StoryRuntimeManager _storyRuntimeManager;
  final WorldSaveManager _worldSaveManager;
  final FishRuntimeManager? _fishRuntimeManager;
  EconomyRuntimeManager? _economyRuntimeManager;
  QuestRuntimeManager? _questRuntimeManager;
  RelationshipRuntimeManager? _relationshipRuntimeManager;
  AchievementRuntimeManager? _achievementRuntimeManager;
  DynamicEventRuntimeManager? _dynamicEventRuntimeManager;
  final ResidentDecisionManager? _residentDecisionManager;
  SecondWorldEngine? _secondWorldEngine;

  final List<TickEvent> _events = <TickEvent>[];
  final List<WorldTickContext> _history = <WorldTickContext>[];
  final SimulationProfiler _profiler = SimulationProfiler();
  final SimulationRuntimeCache _runtimeCache = SimulationRuntimeCache();
  bool _registered = false;
  SimulationTickResult? _lastResult;

  bool get registered => _registered;
  bool get hasSecondWorldEngine => _secondWorldEngine != null;
  List<TickEvent> get events => List<TickEvent>.from(_events);
  List<WorldTickContext> get history => List<WorldTickContext>.from(_history);
  WorldTickContext? get lastContext => _history.isEmpty ? null : _history.last;
  SimulationProfiler get profiler => _profiler;
  SimulationRuntimeCache get runtimeCache => _runtimeCache;
  SimulationTickResult? get lastResult => _lastResult;

  void setEconomyRuntimeManager(EconomyRuntimeManager manager) {
    _economyRuntimeManager = manager;
  }

  void setQuestRuntimeManager(QuestRuntimeManager manager) {
    _questRuntimeManager = manager;
  }

  void setRelationshipRuntimeManager(RelationshipRuntimeManager manager) {
    _relationshipRuntimeManager = manager;
  }

  void setAchievementRuntimeManager(AchievementRuntimeManager manager) {
    _achievementRuntimeManager = manager;
  }

  void setDynamicEventRuntimeManager(DynamicEventRuntimeManager manager) {
    _dynamicEventRuntimeManager = manager;
  }

  void register(SecondWorldEngine engine) {
    _secondWorldEngine = engine;
    _registered = true;
    notifyListeners();
  }

  void unregister() {
    _registered = false;
    notifyListeners();
  }

  Future<WorldTickContext> tickMinute({bool advanceClock = true}) =>
      runTick(TickType.minuteTick, advanceClock: advanceClock);
  Future<WorldTickContext> tickHour({bool advanceClock = true}) =>
      runTick(TickType.hourTick, advanceClock: advanceClock);
  Future<WorldTickContext> tickDay({bool advanceClock = true}) =>
      runTick(TickType.dayTick, advanceClock: advanceClock);
  Future<WorldTickContext> tickWeek({bool advanceClock = true}) =>
      runTick(TickType.weekTick, advanceClock: advanceClock);
  Future<WorldTickContext> tickMonth({bool advanceClock = true}) =>
      runTick(TickType.monthTick, advanceClock: advanceClock);

  Future<WorldTickContext> runTick(
    TickType type, {
    bool advanceClock = true,
  }) async {
    final startedAt = DateTime.now();
    final before = _worldClockManager.clock;
    final startEventIndex = _events.length;
    final executedStages = <String>[];
    final skippedStages = <String>[];
    final errors = <String, String>{};
    final runtimeResults = <RuntimeResult>[];
    var stateChanged = false;
    _event(TickEventType.beforeTick, type, 'Tick');
    final clockChanged = await _runStage(
      type,
      'Clock',
      cacheKey: 'clock:${type.name}:$advanceClock:${_clockSignature()}',
      cacheable: false,
      executedStages: executedStages,
      skippedStages: skippedStages,
      errors: errors,
      runtimeResults: runtimeResults,
      action: () => _driveClock(type, advanceClock: advanceClock),
    );
    stateChanged = stateChanged || clockChanged;
    if (clockChanged) {
      _runtimeCache.clear();
      _festivalRuntimeManager.invalidateCache();
      _weatherRuntimeManager.invalidateCache();
    }
    var worldContext = _buildWorldContext(type);
    errors.addAll(worldContext.errors);
    final baseWorldContextKey = _baseWorldContextKey(worldContext);
    stateChanged = await _runCachedStage(
          type,
          'Festival',
          cacheKey: 'festival:$baseWorldContextKey',
          executedStages: executedStages,
          skippedStages: skippedStages,
          errors: errors,
          runtimeResults: runtimeResults,
          action: () => _driveFestival(type, worldContext),
        ) ||
        stateChanged;
    stateChanged = await _runCachedStage(
          type,
          'Weather',
          cacheKey: 'weather:$baseWorldContextKey',
          executedStages: executedStages,
          skippedStages: skippedStages,
          errors: errors,
          runtimeResults: runtimeResults,
          action: () => _driveWeather(type, worldContext),
        ) ||
        stateChanged;
    stateChanged = await _runCachedStage(
          type,
          'ResidentDecision',
          cacheKey: 'decision:$baseWorldContextKey',
          executedStages: executedStages,
          skippedStages: skippedStages,
          errors: errors,
          runtimeResults: runtimeResults,
          action: () => _driveResidentDecision(type),
        ) ||
        stateChanged;
    stateChanged = await _runCachedStage(
          type,
          'Resident',
          cacheKey: 'resident:$baseWorldContextKey',
          executedStages: executedStages,
          skippedStages: skippedStages,
          errors: errors,
          runtimeResults: runtimeResults,
          action: () => _driveResident(type, worldContext),
        ) ||
        stateChanged;
    stateChanged = await _runCachedStage(
          type,
          'Rumor',
          cacheKey: 'rumor:$baseWorldContextKey',
          executedStages: executedStages,
          skippedStages: skippedStages,
          errors: errors,
          runtimeResults: runtimeResults,
          action: () => _driveRumor(type, worldContext),
        ) ||
        stateChanged;
    final worldContextKey = _worldContextKey(worldContext);
    stateChanged = await _runCachedStage(
          type,
          'Fish',
          cacheKey: 'fish:$worldContextKey',
          executedStages: executedStages,
          skippedStages: skippedStages,
          errors: errors,
          runtimeResults: runtimeResults,
          action: () => _driveFish(type, worldContext),
        ) ||
        stateChanged;
    stateChanged = await _runCachedStage(
          type,
          'Economy',
          cacheKey: _economyStageKey(type),
          executedStages: executedStages,
          skippedStages: skippedStages,
          errors: errors,
          runtimeResults: runtimeResults,
          action: () => _driveEconomy(type),
        ) ||
        stateChanged;
    final relationshipChanged = await _runCachedStage(
      type,
      'Relationship',
      cacheKey: _relationshipStageKey(type),
      executedStages: executedStages,
      skippedStages: skippedStages,
      errors: errors,
      runtimeResults: runtimeResults,
      action: () => _driveRelationship(type),
    );
    stateChanged = relationshipChanged || stateChanged;
    worldContext = _refreshLivingOfficeState(type, worldContext);
    stateChanged = await _runCachedStage(
          type,
          'DynamicEvent',
          cacheKey:
              'dynamic:$worldContextKey:${_relationshipRuntimeManager?.lastUpdateDay ?? -1}',
          executedStages: executedStages,
          skippedStages: skippedStages,
          errors: errors,
          runtimeResults: runtimeResults,
          action: () => _driveDynamicEvent(type),
        ) ||
        stateChanged;
    stateChanged = await _runCachedStage(
          type,
          'Dialogue',
          cacheKey:
              'dialogue:$worldContextKey:${_dynamicEventRuntimeManager?.hasTriggered('__cache_probe__') ?? false}',
          executedStages: executedStages,
          skippedStages: skippedStages,
          errors: errors,
          runtimeResults: runtimeResults,
          action: () => _driveDialogue(type),
        ) ||
        stateChanged;
    stateChanged = await _runCachedStage(
          type,
          'Story',
          cacheKey:
              'story:$worldContextKey:${_storyRuntimeManager.finishedStoryIds.join('|')}',
          executedStages: executedStages,
          skippedStages: skippedStages,
          errors: errors,
          runtimeResults: runtimeResults,
          action: () => _driveStory(type),
        ) ||
        stateChanged;
    stateChanged = await _runCachedStage(
          type,
          'Quest',
          cacheKey: 'quest:$worldContextKey',
          executedStages: executedStages,
          skippedStages: skippedStages,
          errors: errors,
          runtimeResults: runtimeResults,
          action: () => _driveQuest(type, worldContext),
        ) ||
        stateChanged;
    stateChanged = await _runCachedStage(
          type,
          'Achievement',
          cacheKey: 'achievement:$worldContextKey',
          executedStages: executedStages,
          skippedStages: skippedStages,
          errors: errors,
          runtimeResults: runtimeResults,
          action: () => _driveAchievement(type, worldContext),
        ) ||
        stateChanged;
    await _runStage(
      type,
      'Save',
      cacheKey: 'save:${_clockSignature()}:$stateChanged:${errors.isEmpty}',
      cacheable: false,
      executedStages: executedStages,
      skippedStages: skippedStages,
      errors: errors,
      runtimeResults: runtimeResults,
      action: () => _driveSave(type, canSave: errors.isEmpty),
    );
    _event(TickEventType.afterTick, type, 'Tick');
    final after = _worldClockManager.clock;
    final tickEvents = _events.sublist(startEventIndex);
    final context = WorldTickContext(
      tickType: type,
      beforeClockDay: before.dayCount,
      beforeClockHour: before.hour,
      beforeClockMinute: before.minute,
      afterClockDay: after.dayCount,
      afterClockHour: after.hour,
      afterClockMinute: after.minute,
      events: tickEvents,
      stages: tickEvents.map((event) => event.stage).toList(growable: false),
      livingOfficeState: worldContext.livingOfficeState,
      playerInfluenceContext: worldContext.playerInfluenceContext,
    );
    _history.add(context);
    final finishedAt = DateTime.now();
    final profile = _profiler.record(
      tickType: type,
      startedAt: startedAt,
      finishedAt: finishedAt,
      executedStages: executedStages,
      skippedStages: skippedStages,
      errorStages: errors,
    );
    _lastResult = SimulationTickResult(
      success: errors.isEmpty,
      tickType: type,
      executedStages: executedStages,
      skippedStages: skippedStages,
      errors: errors,
      durationMs: profile.durationMs,
      stateChanged: stateChanged,
      worldContext: worldContext,
      runtimeResults: runtimeResults,
    );
    if (kDebugMode) {
      debugPrint(
        'WorldTickManager | tick=${type.name} executed=${executedStages.join('>')} skipped=${skippedStages.join('>')} errors=${errors.keys.join(',')}',
      );
    }
    notifyListeners();
    return context;
  }

  bool _driveClock(TickType type, {required bool advanceClock}) {
    if (!advanceClock) return false;
    final before = _clockSignature();
    if (advanceClock) {
      switch (type) {
        case TickType.minuteTick:
          _worldClockManager.tick(const Duration(minutes: 1));
          break;
        case TickType.hourTick:
          _worldClockManager.tick(const Duration(hours: 1));
          break;
        case TickType.dayTick:
          _worldClockManager.tick(const Duration(days: 1));
          break;
        case TickType.weekTick:
          _worldClockManager.tick(const Duration(days: 7));
          break;
        case TickType.monthTick:
          _worldClockManager.tick(const Duration(days: 30));
          break;
      }
    }
    return before != _clockSignature();
  }

  bool _driveFestival(TickType type, WorldSimulationContext context) {
    if (context.errors.containsKey('FestivalContext') ||
        context.errors.containsKey('FestivalTags')) {
      throw StateError('festival context failed');
    }
    _runtimeCache.remember(
      'activeFestivals',
      context.signature,
      () => context.festivals,
    );
    _runtimeCache.remember(
      'festivalTags',
      context.signature,
      () => context.festivalTags,
    );
    return false;
  }

  bool _driveWeather(TickType type, WorldSimulationContext context) {
    if (context.errors.containsKey('WeatherContext') ||
        context.errors.containsKey('WeatherTags')) {
      throw StateError('weather context failed');
    }
    _runtimeCache.remember(
      'currentWeather',
      context.signature,
      () => context.weather,
    );
    _runtimeCache.remember(
      'weatherTags',
      context.signature,
      () => context.weatherTags,
    );
    return false;
  }

  bool _driveFish(TickType type, WorldSimulationContext context) {
    _fishRuntimeManager?.refresh();
    _runtimeCache.remember(
      'activeFishPool',
      context.signature,
      () => context.fishPool,
    );
    return _fishRuntimeManager != null;
  }

  bool _driveEconomy(TickType type) {
    if (type == TickType.dayTick ||
        _economyRuntimeManager?.lastMarketDay == null) {
      _economyRuntimeManager?.updateMarket();
      return _economyRuntimeManager != null;
    } else {
      _economyRuntimeManager?.getMarketMultiplier();
    }
    return false;
  }

  bool _driveResident(TickType type, WorldSimulationContext context) {
    _runtimeCache.remember(
      'residentStates',
      context.signature,
      () => context.residentStates,
    );
    return false;
  }

  bool _driveResidentDecision(TickType type) {
    _residentDecisionManager?.runResidentDecision();
    return _residentDecisionManager != null;
  }

  bool _driveRelationship(TickType type) {
    if (type == TickType.dayTick &&
        _relationshipRuntimeManager?.lastUpdateDay !=
            _worldClockManager.today().dayCount) {
      _relationshipRuntimeManager?.updateResidentRelationships();
      return _relationshipRuntimeManager != null;
    }
    return false;
  }

  bool _driveRumor(TickType type, WorldSimulationContext context) {
    _runtimeCache.remember(
      'activeRumors',
      context.signature,
      () => context.rumors,
    );
    _runtimeCache.remember(
      'rumorTags',
      context.signature,
      () => context.rumorTags,
    );
    return false;
  }

  bool _driveDialogue(TickType type) {
    for (final resident in _residentRuntimeManager.residents) {
      _dialogueRuntimeManager.getAvailableDialogues(resident.id);
    }
    return false;
  }

  bool _driveStory(TickType type) {
    for (final resident in _residentRuntimeManager.residents) {
      _storyRuntimeManager.getAvailableStories(resident.id);
    }
    return false;
  }

  bool _driveQuest(TickType type, WorldSimulationContext context) {
    context.quests;
    return false;
  }

  bool _driveAchievement(TickType type, WorldSimulationContext context) {
    if (type == TickType.dayTick) {
      _achievementRuntimeManager?.updateAchievementProgress(
        const AchievementEvent(type: 'day_tick', amount: 0),
      );
      return _achievementRuntimeManager != null;
    } else {
      context.achievements;
    }
    return false;
  }

  bool _driveDynamicEvent(TickType type) {
    final beforeActive = _dynamicEventRuntimeManager?.getActiveEvents().length;
    switch (type) {
      case TickType.minuteTick:
        _dynamicEventRuntimeManager?.runMinuteCheck();
        break;
      case TickType.hourTick:
        _dynamicEventRuntimeManager?.runHourCheck();
        break;
      case TickType.dayTick:
        _dynamicEventRuntimeManager?.runDayCheck();
        break;
      case TickType.weekTick:
      case TickType.monthTick:
        _dynamicEventRuntimeManager?.getAvailableEvents();
        break;
    }
    final afterActive = _dynamicEventRuntimeManager?.getActiveEvents().length;
    return beforeActive != afterActive;
  }

  Future<bool> _driveSave(
    TickType type, {
    required bool canSave,
  }) async {
    if (!canSave) return false;
    await _worldSaveManager.autoSave(force: type == TickType.dayTick);
    return false;
  }

  Future<bool> _runCachedStage(
    TickType type,
    String stage, {
    required String cacheKey,
    required List<String> executedStages,
    required List<String> skippedStages,
    required Map<String, String> errors,
    required List<RuntimeResult> runtimeResults,
    required FutureOr<bool> Function() action,
  }) {
    return _runStage(
      type,
      stage,
      cacheKey: cacheKey,
      cacheable: true,
      executedStages: executedStages,
      skippedStages: skippedStages,
      errors: errors,
      runtimeResults: runtimeResults,
      action: action,
    );
  }

  Future<bool> _runStage(
    TickType type,
    String stage, {
    required String cacheKey,
    required bool cacheable,
    required List<String> executedStages,
    required List<String> skippedStages,
    required Map<String, String> errors,
    required List<RuntimeResult> runtimeResults,
    required FutureOr<bool> Function() action,
  }) async {
    final startedAt = DateTime.now();
    _event(TickEventType.beforeTick, type, stage);
    if (cacheable && _runtimeCache.isFresh(stage, cacheKey)) {
      skippedStages.add(stage);
      _event(TickEventType.afterTick, type, stage);
      runtimeResults.add(
        RuntimeResult(
          stage: stage,
          success: true,
          stateChanged: false,
          changedKeys: const <String>[],
          cacheInvalidations: const <String>[],
          saveRequired: false,
          errors: const <String, String>{},
          durationMs: DateTime.now().difference(startedAt).inMilliseconds,
          skipped: true,
        ),
      );
      return false;
    }
    try {
      final changed = await action();
      executedStages.add(stage);
      if (cacheable) {
        _runtimeCache.markFresh(stage, cacheKey);
      }
      _event(TickEventType.afterTick, type, stage);
      runtimeResults.add(
        RuntimeResult(
          stage: stage,
          success: true,
          stateChanged: changed,
          changedKeys: changed ? <String>[stage] : const <String>[],
          cacheInvalidations: changed ? <String>[stage] : const <String>[],
          saveRequired: changed || stage == 'Save',
          errors: const <String, String>{},
          durationMs: DateTime.now().difference(startedAt).inMilliseconds,
          skipped: false,
        ),
      );
      return changed;
    } catch (error) {
      errors[stage] = error.toString();
      if (cacheable) {
        _runtimeCache.invalidateWhere((id) => id == stage);
      }
      if (kDebugMode) {
        debugPrint('WorldTickManager | stage=$stage error=$error');
      }
      _event(TickEventType.afterTick, type, stage);
      runtimeResults.add(
        RuntimeResult(
          stage: stage,
          success: false,
          stateChanged: false,
          changedKeys: const <String>[],
          cacheInvalidations: <String>[stage],
          saveRequired: false,
          errors: <String, String>{stage: error.toString()},
          durationMs: DateTime.now().difference(startedAt).inMilliseconds,
          skipped: false,
        ),
      );
      return false;
    }
  }

  String _clockSignature() {
    final clock = _worldClockManager.clock;
    return '${clock.dayCount}:${clock.hour}:${clock.minute}';
  }

  String _festivalStageKey() {
    final calendar = _worldClockManager.today();
    return 'festival:${calendar.dayCount}:${calendar.month}:${calendar.day}';
  }

  String _weatherStageKey() {
    return 'weather:${_clockSignature()}:${_worldClockManager.season()}';
  }

  String _baseWorldContextKey(WorldSimulationContext context) {
    return [
      context.clock,
      context.weather?.toString() ?? '',
      context.festivalTags.join('|'),
      context.residentStates.length,
    ].join(':');
  }

  String _worldContextKey(WorldSimulationContext context) {
    return '${_baseWorldContextKey(context)}:${context.rumorTags.join('|')}:${context.fishPool.length}:${context.events.length}:${context.livingOfficeState.officeMood}:${context.livingOfficeState.activityLevel}:${context.livingOfficeState.socialLevel}:${context.livingOfficeState.tensionLevel}';
  }

  String _economyStageKey(TickType type) {
    return 'economy:${type.name}:${_worldClockManager.today().dayCount}:${_weatherStageKey()}:${_festivalStageKey()}';
  }

  String _relationshipStageKey(TickType type) {
    return 'relationship:${type.name}:${_worldClockManager.today().dayCount}:${_residentRuntimeManager.residents.length}';
  }

  WorldSimulationContext _buildWorldContext(TickType type) {
    final contextErrors = <String, String>{};
    T safe<T>(String key, T fallback, T Function() loader) {
      try {
        return loader();
      } catch (error) {
        contextErrors[key] = error.toString();
        return fallback;
      }
    }

    final festivals = safe<List<Object?>>(
      'FestivalContext',
      const <Object?>[],
      () => _festivalRuntimeManager.getActiveFestivals(),
    );
    final festivalTags = safe<List<String>>(
      'FestivalTags',
      const <String>[],
      _festivalRuntimeManager.getFestivalTags,
    );
    final weather = safe<Object?>(
      'WeatherContext',
      null,
      _weatherRuntimeManager.getCurrentWeather,
    );
    final weatherTags = safe<List<String>>(
      'WeatherTags',
      const <String>[],
      _weatherRuntimeManager.getWeatherTags,
    );
    final residentStates = safe<Map<String, Object?>>(
      'ResidentStates',
      const <String, Object?>{},
      () => _residentRuntimeManager.getAllResidentCurrentStates(),
    );
    final rumors = safe<List<Object?>>(
      'RumorContext',
      const <Object?>[],
      _rumorRuntimeManager.getActiveRumors,
    );
    final rumorTags = safe<List<String>>(
      'RumorTags',
      const <String>[],
      _rumorRuntimeManager.getRumorTags,
    );
    final fishPool = safe<List<Object?>>(
      'FishPool',
      const <Object?>[],
      () => _fishRuntimeManager?.getActiveFishPool() ?? const <Object?>[],
    );
    final economy = safe<Map<String, Object?>>(
      'EconomyContext',
      const <String, Object?>{},
      () => <String, Object?>{
        'marketTrend': _economyRuntimeManager?.marketTrend,
        'priceMultiplier': _economyRuntimeManager?.priceMultiplier,
        'lastMarketDay': _economyRuntimeManager?.lastMarketDay,
      },
    );
    final relationships = safe<Map<String, Object?>>(
      'RelationshipContext',
      const <String, Object?>{},
      () => <String, Object?>{
        for (final relationship
            in _relationshipRuntimeManager?.residentRelationships ??
                const <RuntimeRelationshipRecord>[])
          '${relationship.sourceId}:${relationship.targetId}': relationship,
      },
    );
    final events = safe<List<Object?>>(
      'DynamicEventContext',
      const <Object?>[],
      () => _dynamicEventRuntimeManager?.getActiveEvents() ?? const <Object?>[],
    );
    final quests = safe<Map<String, Object?>>(
      'QuestContext',
      const <String, Object?>{},
      () => Map<String, Object?>.from(
        _questRuntimeManager?.cumulativeMetrics ?? const <String, int>{},
      ),
    );
    final achievements = safe<List<Object?>>(
      'AchievementContext',
      const <Object?>[],
      () =>
          _achievementRuntimeManager?.getAllAchievements() ?? const <Object?>[],
    );
    final activeGroups = safe<List<OfficeGroup>>(
      'OfficeGroups',
      const <OfficeGroup>[],
      () =>
          _relationshipRuntimeManager?.getActiveOfficeGroups() ??
          _worldSaveManager.activeGroups,
    );
    final locationSnapshot = safe<Map<String, Object?>>(
      'LocationSnapshot',
      const <String, Object?>{},
      () => <String, Object?>{
        for (final resident in _residentRuntimeManager.residents)
          resident.id:
              _residentRuntimeManager.getResidentLocationContext(resident.id),
      },
    );
    final personalitySnapshot = safe<Map<String, Object?>>(
      'PersonalitySnapshot',
      const <String, Object?>{},
      () => _residentRuntimeManager.getAllResidentPersonalityContexts(),
    );
    final friendshipSnapshot = safe<Map<String, Object?>>(
      'FriendshipSnapshot',
      const <String, Object?>{},
      () => <String, Object?>{
        for (final state
            in _relationshipRuntimeManager?.getAllFriendshipStates() ??
                const <Object?>[])
          if (_objectResidentId(state).isNotEmpty)
            _objectResidentId(state): state,
      },
    );
    final activeStories = safe<List<Object?>>(
      'StoryContext',
      const <Object?>[],
      () => _storyRuntimeManager.finishedStoryIds
          .take(12)
          .map<Object?>((id) => id)
          .toList(growable: false),
    );
    final calendar = _worldClockManager.today();
    final worldDate =
        'Y${calendar.year}-M${calendar.month}-D${calendar.day}-#${calendar.dayCount}';
    final timeOfDay = _timeOfDayFor(_worldClockManager.hour());
    final livingOfficeState = _secondWorldEngine?.buildLivingOfficeState(
          worldDate: worldDate,
          timeOfDay: timeOfDay,
          weekday: calendar.weekdayIndex,
          season: calendar.season,
          weatherContext: weather,
          festivalContext: festivals.isEmpty ? null : festivals.first,
          activeRumors: rumors,
          residentSnapshot: residentStates,
          activeGroups: activeGroups,
          activeStories: activeStories,
          activeEvents: events,
          careerContext: _worldSaveManager.careerState,
          skillSummary:
              Map<String, Object?>.from(_worldSaveManager.playerSkillStates),
          questSummary: quests,
          achievementSummary: achievements,
          previousState: _worldSaveManager.livingOfficeState,
        ) ??
        _worldSaveManager.livingOfficeState;
    final playerInfluenceContext =
        _secondWorldEngine?.buildPlayerInfluenceContext(
              livingOfficeState: livingOfficeState,
              questSummary: quests,
              achievementSummary: achievements,
              activeRumors: rumors,
              activeEvents: events,
            ) ??
            _worldSaveManager.playerInfluenceContext;
    return WorldSimulationContext(
      tickType: type,
      clock: _clockSignature(),
      festivals: festivals,
      festivalTags: festivalTags,
      weather: weather,
      weatherTags: weatherTags,
      residentStates: residentStates,
      rumors: rumors,
      rumorTags: rumorTags,
      fishPool: fishPool,
      economy: economy,
      relationships: relationships,
      events: events,
      quests: quests,
      achievements: achievements,
      worldDate: worldDate,
      timeOfDay: timeOfDay,
      weekday: calendar.weekdayIndex,
      season: calendar.season,
      weatherContext: weather,
      festivalContext: festivals.isEmpty ? null : festivals.first,
      activeRumors: rumors,
      residentSnapshot: residentStates,
      locationSnapshot: locationSnapshot,
      personalitySnapshot: personalitySnapshot,
      friendshipSnapshot: friendshipSnapshot,
      activeGroups: activeGroups,
      activeStories: activeStories,
      activeEvents: events,
      careerContext: _worldSaveManager.careerState,
      skillSummary:
          Map<String, Object?>.from(_worldSaveManager.playerSkillStates),
      questSummary: quests,
      achievementSummary: achievements,
      livingOfficeState: livingOfficeState,
      playerInfluenceContext: playerInfluenceContext,
      errors: contextErrors,
    );
  }

  WorldSimulationContext _refreshLivingOfficeState(
    TickType type,
    WorldSimulationContext context,
  ) {
    final engine = _secondWorldEngine;
    if (engine == null) return context;
    final groups = _relationshipRuntimeManager?.getActiveOfficeGroups() ??
        _worldSaveManager.activeGroups;
    final state = engine.buildLivingOfficeState(
      worldDate: context.worldDate,
      timeOfDay: context.timeOfDay,
      weekday: context.weekday,
      season: context.season,
      weatherContext: context.weatherContext,
      festivalContext: context.festivalContext,
      activeRumors: context.activeRumors,
      residentSnapshot: context.residentSnapshot,
      activeGroups: groups,
      activeStories: context.activeStories,
      activeEvents: _dynamicEventRuntimeManager?.getActiveEvents() ??
          context.activeEvents,
      careerContext: context.careerContext,
      skillSummary: context.skillSummary,
      questSummary: context.questSummary,
      achievementSummary: context.achievementSummary,
      previousState: _worldSaveManager.livingOfficeState,
    );
    final playerInfluenceContext = engine.buildPlayerInfluenceContext(
      livingOfficeState: state,
      questSummary: context.questSummary,
      achievementSummary: context.achievementSummary,
      activeRumors: context.activeRumors,
      activeEvents: _dynamicEventRuntimeManager?.getActiveEvents() ??
          context.activeEvents,
    );
    _worldSaveManager.setLivingOfficeState(state);
    _worldSaveManager.setPlayerInfluenceContext(playerInfluenceContext);
    _dialogueRuntimeManager.applyLivingOfficeState(state);
    _dialogueRuntimeManager.applyPlayerInfluenceContext(
      playerInfluenceContext,
    );
    _storyRuntimeManager.applyLivingOfficeState(state);
    _storyRuntimeManager.applyPlayerInfluenceContext(playerInfluenceContext);
    _dynamicEventRuntimeManager?.applyLivingOfficeState(state);
    _dynamicEventRuntimeManager?.applyPlayerInfluenceContext(
      playerInfluenceContext,
    );
    _questRuntimeManager?.applyPlayerInfluenceContext(playerInfluenceContext);
    _achievementRuntimeManager?.applyPlayerInfluenceContext(
      playerInfluenceContext,
    );
    if (type == TickType.dayTick) {
      _worldSaveManager.recordOfficeWorldHistory(
        engine.buildOfficeWorldHistoryEntry(state),
      );
    }
    return context.copyWith(
      activeGroups: groups,
      activeEvents: _dynamicEventRuntimeManager?.getActiveEvents() ??
          context.activeEvents,
      livingOfficeState: state,
      playerInfluenceContext: playerInfluenceContext,
    );
  }

  String _timeOfDayFor(int hour) {
    if (hour < 6) return 'late_night';
    if (hour < 11) return 'morning';
    if (hour < 14) return 'noon';
    if (hour < 18) return 'afternoon';
    if (hour < 22) return 'evening';
    return 'night';
  }

  String _objectResidentId(Object? value) {
    if (value == null) return '';
    try {
      final dynamic item = value;
      return item.residentId?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  void _event(TickEventType eventType, TickType tickType, String stage) {
    _events.add(TickEvent(type: eventType, tickType: tickType, stage: stage));
  }
}
