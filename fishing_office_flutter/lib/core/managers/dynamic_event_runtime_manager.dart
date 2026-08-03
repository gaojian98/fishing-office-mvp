import 'package:flutter/foundation.dart';

import '../../models/dynamic_event_config.dart';
import '../../models/friendship_state.dart';
import '../../models/living_office_state.dart';
import '../../models/player_influence.dart';
import '../engine/resident_memory_engine.dart';
import '../engine/second_world_engine.dart';
import 'achievement_runtime_manager.dart';
import 'daily_simulation_manager.dart';
import 'dialogue_runtime_manager.dart';
import 'festival_runtime_manager.dart';
import 'fish_runtime_manager.dart';
import 'quest_runtime_manager.dart';
import 'relationship_runtime_manager.dart';
import 'resident_decision_manager.dart';
import 'resident_runtime_manager.dart';
import 'rumor_runtime_manager.dart';
import 'story_runtime_manager.dart';
import 'weather_runtime_manager.dart';
import 'world_clock_manager.dart';
import 'world_save_manager.dart';

class DynamicEventRuntimeRecord {
  const DynamicEventRuntimeRecord({
    required this.eventId,
    required this.status,
    required this.startedDay,
    required this.updatedDay,
    required this.choiceId,
    required this.tags,
  });

  factory DynamicEventRuntimeRecord.fromJson(Map<String, dynamic> json) {
    return DynamicEventRuntimeRecord(
      eventId: json['eventId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      startedDay: _readInt(json['startedDay']) ?? 0,
      updatedDay: _readInt(json['updatedDay']) ?? 0,
      choiceId: json['choiceId']?.toString() ?? '',
      tags: _stringList(json['tags']),
    );
  }

  final String eventId;
  final String status;
  final int startedDay;
  final int updatedDay;
  final String choiceId;
  final List<String> tags;

  DynamicEventRuntimeRecord copyWith({
    String? status,
    int? updatedDay,
    String? choiceId,
    List<String>? tags,
  }) {
    return DynamicEventRuntimeRecord(
      eventId: eventId,
      status: status ?? this.status,
      startedDay: startedDay,
      updatedDay: updatedDay ?? this.updatedDay,
      choiceId: choiceId ?? this.choiceId,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'status': status,
      'startedDay': startedDay,
      'updatedDay': updatedDay,
      'choiceId': choiceId,
      'tags': tags,
    };
  }
}

class DynamicEventContext {
  const DynamicEventContext({
    required this.timeOfDay,
    required this.weatherIds,
    required this.festivalIds,
    required this.locations,
    required this.residentIds,
    required this.relationshipLevels,
    required this.friendshipStages,
    required this.friendshipTags,
    required this.maximumTrust,
    required this.maximumFamiliarity,
    required this.companyIds,
    required this.departmentIds,
    required this.teamIds,
    required this.positionIds,
    required this.organizationTags,
    required this.careerLevels,
    required this.employmentStatuses,
    required this.careerTags,
    required this.maximumSalaryLevel,
    required this.personalityTags,
    required this.memoryTags,
    required this.rumorTags,
    required this.groupActivities,
    required this.groupTopics,
    required this.groupLocations,
    required this.groupTags,
    required this.maxGroupSize,
    required this.officeMood,
    required this.activityLevel,
    required this.socialLevel,
    required this.tensionLevel,
    required this.officeTags,
    required this.playerReputation,
    required this.recentPlayerActions,
    required this.officeInfluence,
    required this.officeTrust,
    required this.fishIds,
    required this.finishedStoryIds,
    required this.unlockedAchievementIds,
    required this.day,
    required this.raw,
  });

  final String timeOfDay;
  final List<String> weatherIds;
  final List<String> festivalIds;
  final List<String> locations;
  final List<String> residentIds;
  final List<String> relationshipLevels;
  final List<String> friendshipStages;
  final List<String> friendshipTags;
  final int maximumTrust;
  final int maximumFamiliarity;
  final List<String> companyIds;
  final List<String> departmentIds;
  final List<String> teamIds;
  final List<String> positionIds;
  final List<String> organizationTags;
  final List<String> careerLevels;
  final List<String> employmentStatuses;
  final List<String> careerTags;
  final int maximumSalaryLevel;
  final List<String> personalityTags;
  final List<String> memoryTags;
  final List<String> rumorTags;
  final List<String> groupActivities;
  final List<String> groupTopics;
  final List<String> groupLocations;
  final List<String> groupTags;
  final int maxGroupSize;
  final String officeMood;
  final int activityLevel;
  final int socialLevel;
  final int tensionLevel;
  final List<String> officeTags;
  final List<String> playerReputation;
  final List<String> recentPlayerActions;
  final int officeInfluence;
  final int officeTrust;
  final List<String> fishIds;
  final List<String> finishedStoryIds;
  final List<String> unlockedAchievementIds;
  final int day;
  final Map<String, dynamic> raw;
}

class DynamicEventResolveResult {
  const DynamicEventResolveResult({
    required this.event,
    required this.choiceId,
    required this.result,
    required this.memoryChanged,
    required this.relationshipChanged,
    required this.questChanged,
    required this.achievementChanged,
  });

  final DynamicEventEntry event;
  final String choiceId;
  final DynamicEventResult result;
  final bool memoryChanged;
  final bool relationshipChanged;
  final bool questChanged;
  final bool achievementChanged;
}

class DynamicEventRuntimeManager extends ChangeNotifier {
  DynamicEventRuntimeManager({
    required DynamicEventConfig config,
    required WorldClockManager worldClockManager,
    required DailySimulationManager dailySimulationManager,
    required ResidentRuntimeManager residentRuntimeManager,
    required ResidentDecisionManager residentDecisionManager,
    required RelationshipRuntimeManager relationshipRuntimeManager,
    required DialogueRuntimeManager dialogueRuntimeManager,
    required StoryRuntimeManager storyRuntimeManager,
    required FestivalRuntimeManager festivalRuntimeManager,
    required WeatherRuntimeManager weatherRuntimeManager,
    required RumorRuntimeManager rumorRuntimeManager,
    required FishRuntimeManager fishRuntimeManager,
    required QuestRuntimeManager questRuntimeManager,
    required AchievementRuntimeManager achievementRuntimeManager,
    required WorldSaveManager worldSaveManager,
    SecondWorldEngine? secondWorldEngine,
    ResidentMemoryEngine? residentMemoryEngine,
  })  : _config = config,
        _worldClockManager = worldClockManager,
        _dailySimulationManager = dailySimulationManager,
        _residentRuntimeManager = residentRuntimeManager,
        _residentDecisionManager = residentDecisionManager,
        _relationshipRuntimeManager = relationshipRuntimeManager,
        _dialogueRuntimeManager = dialogueRuntimeManager,
        _storyRuntimeManager = storyRuntimeManager,
        _festivalRuntimeManager = festivalRuntimeManager,
        _weatherRuntimeManager = weatherRuntimeManager,
        _rumorRuntimeManager = rumorRuntimeManager,
        _fishRuntimeManager = fishRuntimeManager,
        _questRuntimeManager = questRuntimeManager,
        _achievementRuntimeManager = achievementRuntimeManager,
        _worldSaveManager = worldSaveManager,
        _secondWorldEngine = secondWorldEngine,
        _residentMemoryEngine = residentMemoryEngine {
    _restoreState(worldSaveManager.dynamicEventRuntimeState);
  }

  final DynamicEventConfig _config;
  final WorldClockManager _worldClockManager;
  final DailySimulationManager _dailySimulationManager;
  final ResidentRuntimeManager _residentRuntimeManager;
  final ResidentDecisionManager _residentDecisionManager;
  final RelationshipRuntimeManager _relationshipRuntimeManager;
  final DialogueRuntimeManager _dialogueRuntimeManager;
  final StoryRuntimeManager _storyRuntimeManager;
  final FestivalRuntimeManager _festivalRuntimeManager;
  final WeatherRuntimeManager _weatherRuntimeManager;
  final RumorRuntimeManager _rumorRuntimeManager;
  final FishRuntimeManager _fishRuntimeManager;
  final QuestRuntimeManager _questRuntimeManager;
  final AchievementRuntimeManager _achievementRuntimeManager;
  final WorldSaveManager _worldSaveManager;
  final SecondWorldEngine? _secondWorldEngine;
  final ResidentMemoryEngine? _residentMemoryEngine;

  final Map<String, DynamicEventRuntimeRecord> _activeEvents =
      <String, DynamicEventRuntimeRecord>{};
  final Map<String, DynamicEventRuntimeRecord> _finishedEvents =
      <String, DynamicEventRuntimeRecord>{};
  final Map<String, DynamicEventRuntimeRecord> _expiredEvents =
      <String, DynamicEventRuntimeRecord>{};
  final Map<String, int> _cooldowns = <String, int>{};
  final Map<String, String> _choices = <String, String>{};
  final List<DynamicEventRuntimeRecord> _triggerHistory =
      <DynamicEventRuntimeRecord>[];
  LivingOfficeState _livingOfficeState = LivingOfficeState.empty();
  PlayerInfluenceContext _playerInfluenceContext =
      PlayerInfluenceContext.empty();

  List<DynamicEventRuntimeRecord> get triggerHistory =>
      List<DynamicEventRuntimeRecord>.unmodifiable(_triggerHistory);

  void applyLivingOfficeState(LivingOfficeState state) {
    if (state.isEmpty) return;
    _livingOfficeState = state;
  }

  void applyPlayerInfluenceContext(PlayerInfluenceContext context) {
    _playerInfluenceContext = context;
  }

  List<DynamicEventEntry> getAvailableEvents() {
    return _availableEventsFor(getEventContext());
  }

  List<DynamicEventEntry> _availableEventsFor(DynamicEventContext context) {
    final available = _config.events
        .where((event) => event.enabled)
        .where((event) => _matchesEvent(event, context))
        .toList(growable: false);
    available.sort((a, b) {
      final priority = b.priority.compareTo(a.priority);
      if (priority != 0) return priority;
      final weight = b.weight.compareTo(a.weight);
      if (weight != 0) return weight;
      return a.id.compareTo(b.id);
    });
    return available;
  }

  List<DynamicEventEntry> getActiveEvents() {
    return _activeEvents.keys
        .map(_config.findEvent)
        .whereType<DynamicEventEntry>()
        .toList(growable: false);
  }

  DynamicEventRuntimeRecord? triggerEvent(String eventId) {
    return _triggerEventWithContext(eventId, getEventContext());
  }

  DynamicEventRuntimeRecord? _triggerEventWithContext(
    String eventId,
    DynamicEventContext context,
  ) {
    final event = _config.findEvent(eventId);
    if (event == null || !_matchesEvent(event, context)) return null;
    final day = _worldClockManager.today().dayCount;
    final record = DynamicEventRuntimeRecord(
      eventId: event.id,
      status: 'active',
      startedDay: day,
      updatedDay: day,
      choiceId: '',
      tags: <String>{event.type, event.category, ...event.tags}
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
    );
    _activeEvents[event.id] = record;
    _triggerHistory.add(record);
    if (event.cooldown > 0) {
      _cooldowns[event.id] = day + event.cooldown;
    }
    _persistState();
    notifyListeners();
    return record;
  }

  DynamicEventResolveResult? resolveEvent(String eventId, String choice) {
    final event = _config.findEvent(eventId);
    final active = _activeEvents[eventId];
    if (event == null || active == null) return null;
    final selectedChoice = _choiceFor(event, choice);
    final result = selectedChoice == null
        ? event.result
        : event.result.merge(selectedChoice.result);
    final memoryChanged = _applyMemory(event, result);
    final relationshipChanged = _applyRelationships(event, result);
    final friendshipChanged = _applyFriendship(event, result);
    _applyRumors(result);
    _applyStories(result);
    final questChanged = _applyQuest(event, result);
    final achievementChanged = _applyAchievement(event, result);
    final resolved = active.copyWith(
      status: 'finished',
      updatedDay: _worldClockManager.today().dayCount,
      choiceId: selectedChoice?.id ?? choice,
      tags: <String>{...active.tags, ...result.tags, 'resolved'}
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
    );
    _activeEvents.remove(eventId);
    _finishedEvents[eventId] = resolved;
    if (resolved.choiceId.isNotEmpty) _choices[eventId] = resolved.choiceId;
    _worldSaveManager.recordInteraction(
      residentId: event.conditions.residentId.isEmpty
          ? ''
          : event.conditions.residentId.first,
      dialogueId: '',
      storyId: result.storyIds.isEmpty ? '' : result.storyIds.first,
      tags: <String>['dynamic_event', event.id, event.type, ...result.tags],
    );
    _persistState();
    notifyListeners();
    return DynamicEventResolveResult(
      event: event,
      choiceId: resolved.choiceId,
      result: result,
      memoryChanged: memoryChanged,
      relationshipChanged: relationshipChanged || friendshipChanged,
      questChanged: questChanged,
      achievementChanged: achievementChanged,
    );
  }

  void expireEvent(String eventId) {
    final current = _activeEvents.remove(eventId);
    if (current == null) return;
    _expiredEvents[eventId] = current.copyWith(
      status: 'expired',
      updatedDay: _worldClockManager.today().dayCount,
      tags: <String>{...current.tags, 'expired'}.toList(growable: false),
    );
    _persistState();
    notifyListeners();
  }

  DynamicEventContext getEventContext() {
    final weather = _weatherRuntimeManager.getCurrentWeather();
    final activeFestivals = _festivalRuntimeManager.getActiveFestivals();
    final activeRumors = _rumorRuntimeManager.getActiveRumors();
    final fishPool = _fishRuntimeManager.getActiveFishPool();
    final residents = _residentRuntimeManager.residents;
    final officeGroups = _relationshipRuntimeManager.getActiveOfficeGroups();
    final locationSet = <String>{};
    final relationshipSet = <String>{};
    final friendshipStageSet = <String>{};
    final friendshipTagSet = <String>{};
    final companySet = <String>{};
    final departmentSet = <String>{};
    final teamSet = <String>{};
    final positionSet = <String>{};
    final organizationTagSet = <String>{};
    final careerLevelSet = <String>{};
    final employmentStatusSet = <String>{};
    final careerTagSet = <String>{};
    final personalitySet = <String>{};
    final memoryTags = <String>{};
    final groupActivities = <String>{};
    final groupTopics = <String>{};
    final groupLocations = <String>{};
    final groupTags = <String>{};
    var maxGroupSize = 0;
    for (final group in officeGroups) {
      groupActivities.add(group.activity);
      groupTopics.add(group.topic);
      groupLocations.add(group.locationId);
      groupTags.addAll(group.tags);
      if (group.size > maxGroupSize) maxGroupSize = group.size;
    }
    var maximumTrust = 0;
    var maximumFamiliarity = 0;
    var maximumSalaryLevel = 0;
    for (final resident in residents) {
      final state =
          _residentRuntimeManager.getResidentCurrentState(resident.id);
      if (state.location.isNotEmpty) {
        final location =
            _residentRuntimeManager.getLocationContext(state.location);
        locationSet
          ..add(location.locationId)
          ..add(location.locationType)
          ..addAll(location.tags);
      }
      final friendship = _worldSaveManager.getFriendshipState(resident.id);
      relationshipSet.add(friendship.stage);
      friendshipStageSet.add(friendship.stage);
      friendshipTagSet
        ..addAll(friendship.relationshipTags)
        ..addAll(friendship.sharedTopics.map((topic) => 'topic:$topic'))
        ..add(friendship.conflictState);
      if (friendship.trust > maximumTrust) maximumTrust = friendship.trust;
      if (friendship.familiarity > maximumFamiliarity) {
        maximumFamiliarity = friendship.familiarity;
      }
      final organization =
          _residentRuntimeManager.getResidentOrganizationContext(resident.id);
      companySet.add(organization.companyId);
      departmentSet.add(organization.departmentId);
      teamSet.add(organization.teamId);
      positionSet.add(organization.positionId);
      organizationTagSet.addAll(organization.tags);
      final career =
          _residentRuntimeManager.getResidentCareerStatus(resident.id);
      careerLevelSet.add(career.careerLevel);
      employmentStatusSet.add(career.employmentStatus);
      careerTagSet.addAll(career.tags);
      if (career.salaryLevel > maximumSalaryLevel) {
        maximumSalaryLevel = career.salaryLevel;
      }
      final personality =
          _residentRuntimeManager.getResidentPersonalityContext(resident.id);
      personalitySet
        ..addAll(personality.traits)
        ..addAll(personality.eventReactionTags)
        ..add(personality.storyPreference)
        ..add(personality.rumorPreference);
      final memory = _residentMemoryEngine?.getResidentMemory(resident.id);
      if (memory != null) {
        memoryTags.addAll(memory.memoryTags);
        relationshipSet.addAll(_relationshipLevelsFromMeetCount(
          memory.meetCount,
        ));
      }
      _residentDecisionManager.decisionFor(resident.id);
    }
    final unlockedAchievements = _achievementRuntimeManager
        .getUnlockedAchievements()
        .map((item) => item.id)
        .toList(growable: false);
    final context = DynamicEventContext(
      timeOfDay: _timeOfDay(),
      weatherIds: <String>[
        if (weather != null) weather.id,
        if (weather != null) weather.type,
        ..._weatherRuntimeManager.getWeatherTags(),
      ],
      festivalIds: <String>[
        ...activeFestivals.map((festival) => festival.id),
        ..._festivalRuntimeManager.getFestivalTags(),
      ],
      locations: locationSet.toList(growable: false),
      residentIds: residents.map((resident) => resident.id).toList(),
      relationshipLevels: relationshipSet.toList(growable: false),
      friendshipStages: friendshipStageSet.toList(growable: false),
      friendshipTags: friendshipTagSet.toList(growable: false),
      maximumTrust: maximumTrust,
      maximumFamiliarity: maximumFamiliarity,
      companyIds:
          companySet.where((item) => item.isNotEmpty).toList(growable: false),
      departmentIds: departmentSet
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      teamIds: teamSet.where((item) => item.isNotEmpty).toList(growable: false),
      positionIds:
          positionSet.where((item) => item.isNotEmpty).toList(growable: false),
      organizationTags: organizationTagSet
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      careerLevels: careerLevelSet
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      employmentStatuses: employmentStatusSet
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      careerTags:
          careerTagSet.where((item) => item.isNotEmpty).toList(growable: false),
      maximumSalaryLevel: maximumSalaryLevel,
      personalityTags: personalitySet.toList(growable: false),
      memoryTags: memoryTags.toList(growable: false),
      rumorTags: <String>[
        ...activeRumors.map((rumor) => rumor.id),
        ..._rumorRuntimeManager.getRumorTags(),
      ],
      groupActivities: groupActivities.toList(growable: false),
      groupTopics: groupTopics.toList(growable: false),
      groupLocations: groupLocations.toList(growable: false),
      groupTags: groupTags.toList(growable: false),
      maxGroupSize: maxGroupSize,
      officeMood: _livingOfficeState.officeMood,
      activityLevel: _livingOfficeState.activityLevel,
      socialLevel: _livingOfficeState.socialLevel,
      tensionLevel: _livingOfficeState.tensionLevel,
      officeTags: _livingOfficeState.worldTags,
      playerReputation: _playerInfluenceContext.reputation,
      recentPlayerActions:
          _playerInfluenceContext.recentActionTypes.toList(growable: false),
      officeInfluence: _playerInfluenceContext.officeInfluence.overall,
      officeTrust: _playerInfluenceContext.officeInfluence.officeTrust,
      fishIds: fishPool.map((fish) => fish.id).toList(growable: false),
      finishedStoryIds: _storyRuntimeManager.finishedStoryIds,
      unlockedAchievementIds: unlockedAchievements,
      day: _worldClockManager.today().dayCount,
      raw: <String, dynamic>{
        'todaySummary':
            _dailySimulationManager.getTodayWorldSummary()?.toJson(),
        'hasSecondWorldEngine': _secondWorldEngine != null,
        'dialogueProbe': residents.isEmpty
            ? ''
            : _dialogueRuntimeManager.getDialogue(residents.first.id).id,
        'questMetrics': _questRuntimeManager.cumulativeMetrics,
        'officeGroupCount': officeGroups.length,
        'livingOfficeState': _livingOfficeState.toJson(),
        'playerInfluenceContext': _playerInfluenceContext.toJson(),
      },
    );
    return context;
  }

  bool hasTriggered(String eventId) {
    return _activeEvents.containsKey(eventId) ||
        _finishedEvents.containsKey(eventId) ||
        _expiredEvents.containsKey(eventId) ||
        _triggerHistory.any((record) => record.eventId == eventId);
  }

  DynamicEventRuntimeRecord? runMinuteCheck() => _triggerBest(
        categories: const <String>{'waiting'},
        types: const <String>{'fish_talk', 'fish_complain', 'fish_help'},
      );

  DynamicEventRuntimeRecord? runHourCheck() => _triggerBest(
        categories: const <String>{'resident', 'weather', 'office'},
      );

  DynamicEventRuntimeRecord? runDayCheck() => _triggerBest();

  DynamicEventRuntimeRecord? _triggerBest({
    Set<String> categories = const <String>{},
    Set<String> types = const <String>{},
  }) {
    final context = getEventContext();
    final available = _availableEventsFor(context).where((event) {
      final categoryOk =
          categories.isEmpty || categories.contains(event.category);
      final typeOk = types.isEmpty || types.contains(event.type);
      return categoryOk || typeOk;
    }).toList(growable: false);
    if (available.isEmpty) return null;
    return _triggerEventWithContext(available.first.id, context);
  }

  bool _matchesEvent(DynamicEventEntry event, DynamicEventContext context) {
    if (_activeEvents.containsKey(event.id)) return false;
    if (!event.repeatable && _finishedEvents.containsKey(event.id)) {
      return false;
    }
    if (!event.repeatable &&
        _triggerHistory.any((record) => record.eventId == event.id)) {
      return false;
    }
    final cooldownUntil = _cooldowns[event.id];
    if (cooldownUntil != null && cooldownUntil > context.day) return false;
    final conditions = event.conditions;
    if (!_containsAll(context.finishedStoryIds, conditions.requiredEvents)) {
      return false;
    }
    if (_intersects(context.finishedStoryIds, conditions.excludedEvents) ||
        _intersects(_finishedEvents.keys, conditions.excludedEvents) ||
        _intersects(_activeEvents.keys, conditions.excludedEvents)) {
      return false;
    }
    if (!_matchesAnyOrEmpty(
        conditions.timeOfDay, <String>{context.timeOfDay})) {
      return false;
    }
    if (!_matchesAnyOrEmpty(conditions.weather, context.weatherIds.toSet())) {
      return false;
    }
    if (!_matchesAnyOrEmpty(conditions.festival, context.festivalIds.toSet())) {
      return false;
    }
    if (!_matchesAnyOrEmpty(conditions.location, context.locations.toSet())) {
      return false;
    }
    if (!_matchesAnyOrEmpty(
        conditions.residentId, context.residentIds.toSet())) {
      return false;
    }
    if (!_matchesAnyOrEmpty(
        conditions.relationshipLevel, context.relationshipLevels.toSet())) {
      return false;
    }
    if (!_matchesAnyOrEmpty(
        conditions.friendshipStage, context.friendshipStages.toSet())) {
      return false;
    }
    if (conditions.minimumFriendshipStage.isNotEmpty &&
        !context.friendshipStages.any((stage) =>
            friendshipStageRank(stage) >=
            friendshipStageRank(conditions.minimumFriendshipStage))) {
      return false;
    }
    if (conditions.minimumTrust > 0 &&
        context.maximumTrust < conditions.minimumTrust) {
      return false;
    }
    if (conditions.minimumFamiliarity > 0 &&
        context.maximumFamiliarity < conditions.minimumFamiliarity) {
      return false;
    }
    if (!_containsAll(context.friendshipTags, conditions.friendshipTags)) {
      return false;
    }
    if (!_matchesAnyOrEmpty(conditions.companyId, context.companyIds.toSet())) {
      return false;
    }
    if (!_matchesAnyOrEmpty(
      conditions.departmentId,
      context.departmentIds.toSet(),
    )) {
      return false;
    }
    if (!_matchesAnyOrEmpty(conditions.teamId, context.teamIds.toSet())) {
      return false;
    }
    if (!_matchesAnyOrEmpty(
      conditions.positionId,
      context.positionIds.toSet(),
    )) {
      return false;
    }
    if (!_containsAll(context.organizationTags, conditions.organizationTags)) {
      return false;
    }
    if (!_matchesAnyOrEmpty(
      conditions.careerLevel,
      context.careerLevels.toSet(),
    )) {
      return false;
    }
    if (!_matchesAnyOrEmpty(
      conditions.employmentStatus,
      context.employmentStatuses.toSet(),
    )) {
      return false;
    }
    if (!_containsAll(context.careerTags, conditions.careerTags)) {
      return false;
    }
    if (conditions.salaryLevelMin > 0 &&
        context.maximumSalaryLevel < conditions.salaryLevelMin) {
      return false;
    }
    if (!_matchesAnyOrEmpty(
      conditions.personalityTags,
      context.personalityTags.toSet(),
    )) {
      return false;
    }
    if (_intersects(
      context.personalityTags,
      conditions.excludedPersonalityTags,
    )) {
      return false;
    }
    if (conditions.groupSizeMin > 0 &&
        context.maxGroupSize < conditions.groupSizeMin) {
      return false;
    }
    if (!_matchesAnyOrEmpty(
      conditions.groupActivity,
      context.groupActivities.toSet(),
    )) {
      return false;
    }
    if (!_matchesAnyOrEmpty(
      conditions.groupTopic,
      context.groupTopics.toSet(),
    )) {
      return false;
    }
    if (!_matchesAnyOrEmpty(
      conditions.groupLocation,
      context.groupLocations.toSet(),
    )) {
      return false;
    }
    if (!_containsAll(context.groupTags, conditions.groupTags)) {
      return false;
    }
    if (!_matchesAnyOrEmpty(
      conditions.officeMood,
      <String>{context.officeMood},
    )) {
      return false;
    }
    if (conditions.minimumActivityLevel > 0 &&
        context.activityLevel < conditions.minimumActivityLevel) {
      return false;
    }
    if (conditions.maximumTensionLevel > 0 &&
        context.tensionLevel > conditions.maximumTensionLevel) {
      return false;
    }
    if (!_containsAll(context.officeTags, conditions.requiredOfficeTags)) {
      return false;
    }
    if (_intersects(context.officeTags, conditions.excludedOfficeTags)) {
      return false;
    }
    if (!_containsAll(
      context.playerReputation,
      conditions.requiredPlayerReputation,
    )) {
      return false;
    }
    if (!_containsAll(
      context.recentPlayerActions,
      conditions.requiredRecentActions,
    )) {
      return false;
    }
    if (conditions.minimumOfficeInfluence > 0 &&
        context.officeInfluence < conditions.minimumOfficeInfluence) {
      return false;
    }
    if (conditions.minimumOfficeTrust > 0 &&
        context.officeTrust < conditions.minimumOfficeTrust) {
      return false;
    }
    if (!_containsAll(context.memoryTags, conditions.memoryTags)) return false;
    if (!_containsAll(context.rumorTags, conditions.rumorTags)) return false;
    if (!_matchesAnyOrEmpty(conditions.fishId, context.fishIds.toSet())) {
      return false;
    }
    if (!_containsAll(context.finishedStoryIds, conditions.storyState)) {
      return false;
    }
    if (!_containsAll(
      context.unlockedAchievementIds,
      conditions.achievementState,
    )) {
      return false;
    }
    return _passesProbability(event, context);
  }

  bool _passesProbability(
      DynamicEventEntry event, DynamicEventContext context) {
    if (event.probability >= 1) return true;
    if (event.probability <= 0) return false;
    final seed =
        event.id.codeUnits.fold<int>(context.day, (sum, code) => sum + code);
    final bucket = (seed % 100) / 100.0;
    return bucket <= event.probability;
  }

  DynamicEventChoice? _choiceFor(DynamicEventEntry event, String choiceId) {
    if (choiceId.isEmpty) return null;
    for (final choice in event.choices) {
      if (choice.id == choiceId) return choice;
    }
    return null;
  }

  bool _applyMemory(DynamicEventEntry event, DynamicEventResult result) {
    final memory = _residentMemoryEngine;
    if (memory == null) return false;
    final residentIds = event.conditions.residentId.isEmpty
        ? _residentRuntimeManager.residents.take(1).map((item) => item.id)
        : event.conditions.residentId;
    var changed = false;
    for (final residentId in residentIds) {
      if (residentId.isEmpty) continue;
      memory.recordInteraction(
        residentId,
        'dynamic_event',
        tags: <String>{
          event.id,
          event.type,
          ...event.tags,
          ...result.memoryTags
        }.toList(growable: false),
      );
      changed = true;
    }
    return changed;
  }

  bool _applyRelationships(DynamicEventEntry event, DynamicEventResult result) {
    var changed = false;
    for (final change in result.relationshipChanges) {
      final source = change['source']?.toString() ??
          (event.conditions.residentId.isEmpty
              ? ''
              : event.conditions.residentId.first);
      final target = change['target']?.toString() ?? '';
      final amount = _readInt(change['amount']) ?? 0;
      if (source.isEmpty || target.isEmpty || amount == 0) continue;
      _relationshipRuntimeManager.applyRelationshipChange(
        source,
        target,
        change['reason']?.toString() ?? '事件让关系发生变化。',
        amount,
      );
      changed = true;
    }
    if (!changed && event.conditions.residentId.length >= 2) {
      _relationshipRuntimeManager.applyRelationshipChange(
        event.conditions.residentId[0],
        event.conditions.residentId[1],
        '共同经历事件。',
        1,
      );
      changed = true;
    }
    return changed;
  }

  bool _applyFriendship(DynamicEventEntry event, DynamicEventResult result) {
    var changed = false;
    for (final change in result.friendshipChanges) {
      final residentId = change['residentId']?.toString() ??
          (event.conditions.residentId.isEmpty
              ? ''
              : event.conditions.residentId.first);
      final record = _relationshipRuntimeManager.applyFriendshipChange(
        residentId: residentId,
        sourceType: change['sourceType']?.toString() ?? 'dynamic_event',
        sourceId: change['sourceId']?.toString() ?? event.id,
        scoreDelta: _readInt(change['scoreDelta']) ?? 0,
        trustDelta: _readInt(change['trustDelta']) ?? 0,
        familiarityDelta: _readInt(change['familiarityDelta']) ?? 0,
        reason: change['reason']?.toString() ?? '共同经历事件。',
        tags: _stringList(change['tags']),
        interactionType: change['interactionType']?.toString() ?? '',
      );
      if (record != null) changed = true;
    }
    if (!changed &&
        event.conditions.residentId.length == 1 &&
        _isSocialEvent(event)) {
      final record = _relationshipRuntimeManager.applyFriendshipChange(
        residentId: event.conditions.residentId.first,
        sourceType: 'dynamic_event',
        sourceId: event.id,
        scoreDelta: event.type == 'resident_conflict' ? -2 : 2,
        trustDelta: event.type == 'work_help' ? 1 : 0,
        familiarityDelta: 2,
        reason: event.type == 'resident_conflict'
            ? '轻微误会让关系暂时有点紧张。'
            : '社交事件让彼此更熟悉。',
        tags: <String>[event.type, event.category, ...event.tags],
        interactionType: event.type,
      );
      changed = record != null;
    }
    return changed;
  }

  bool _isSocialEvent(DynamicEventEntry event) {
    const socialTypes = <String>{
      'coffee_invitation',
      'work_help',
      'shared_break',
      'office_joke',
      'resident_conflict',
      'conflict_resolution',
      'birthday_greeting',
      'shared_fishing',
      'quiet_companionship',
      'group_lunch',
      'rumor_discussion',
    };
    return socialTypes.contains(event.type) ||
        event.tags.any((tag) => tag.contains('social'));
  }

  void _applyRumors(DynamicEventResult result) {
    for (final rumorId in result.rumorIds) {
      _rumorRuntimeManager.addRumor(rumorId);
    }
  }

  void _applyStories(DynamicEventResult result) {
    for (final storyId in result.storyIds) {
      _storyRuntimeManager.finishStory(storyId);
    }
  }

  bool _applyQuest(DynamicEventEntry event, DynamicEventResult result) {
    if (result.questEvents.isEmpty) {
      _questRuntimeManager.recordWorldEvent(
        'dynamic_event',
        id: event.id,
        amount: 1,
      );
      return true;
    }
    for (final questEvent in result.questEvents) {
      _questRuntimeManager.recordWorldEvent(
        questEvent['type']?.toString() ?? 'dynamic_event',
        id: questEvent['id']?.toString() ?? event.id,
        amount: _readInt(questEvent['amount']) ?? 1,
      );
    }
    return true;
  }

  bool _applyAchievement(DynamicEventEntry event, DynamicEventResult result) {
    if (result.achievementEvents.isEmpty) {
      _achievementRuntimeManager.updateAchievementProgress(
        AchievementEvent(type: 'dynamic_event_seen', id: event.id),
      );
      _achievementRuntimeManager.updateAchievementProgress(
        AchievementEvent(type: '${event.type}_seen', id: event.id),
      );
      return true;
    }
    for (final achievementEvent in result.achievementEvents) {
      _achievementRuntimeManager.updateAchievementProgress(
        AchievementEvent(
          type: achievementEvent['type']?.toString() ?? 'dynamic_event_seen',
          id: achievementEvent['id']?.toString() ?? event.id,
          amount: _readInt(achievementEvent['amount']) ?? 1,
          payload: _mapOf(achievementEvent['payload']),
        ),
      );
    }
    return true;
  }

  void _persistState() {
    _worldSaveManager.setDynamicEventRuntimeState({
      'activeEvents': _activeEvents.values
          .map((record) => record.toJson())
          .toList(growable: false),
      'finishedEvents': _finishedEvents.values
          .map((record) => record.toJson())
          .toList(growable: false),
      'expiredEvents': _expiredEvents.values
          .map((record) => record.toJson())
          .toList(growable: false),
      'cooldowns': Map<String, int>.from(_cooldowns),
      'choices': Map<String, String>.from(_choices),
      'triggerHistory': _triggerHistory
          .map((record) => record.toJson())
          .toList(growable: false),
    });
  }

  List<String> _relationshipLevelsFromMeetCount(int meetCount) {
    if (meetCount >= 20) {
      return const <String>['known', 'friend', 'close_friend'];
    }
    if (meetCount >= 5) return const <String>['known', 'friend'];
    if (meetCount >= 1) return const <String>['known'];
    return const <String>[];
  }

  void _restoreState(Map<String, dynamic> state) {
    _loadRecordMap(_activeEvents, state['activeEvents']);
    _loadRecordMap(_finishedEvents, state['finishedEvents']);
    _loadRecordMap(_expiredEvents, state['expiredEvents']);
    _cooldowns
      ..clear()
      ..addEntries(
        _mapOf(state['cooldowns']).entries.map(
              (entry) => MapEntry(entry.key, _readInt(entry.value) ?? 0),
            ),
      );
    _choices
      ..clear()
      ..addEntries(
        _mapOf(state['choices']).entries.map(
              (entry) => MapEntry(entry.key, entry.value.toString()),
            ),
      );
    _triggerHistory
      ..clear()
      ..addAll(
        _listOfMaps(state['triggerHistory'])
            .map(DynamicEventRuntimeRecord.fromJson),
      );
  }

  void _loadRecordMap(
    Map<String, DynamicEventRuntimeRecord> target,
    Object? raw,
  ) {
    target
      ..clear()
      ..addEntries(
        _listOfMaps(raw).map(DynamicEventRuntimeRecord.fromJson).where(
          (record) {
            return record.eventId.isNotEmpty;
          },
        ).map((record) => MapEntry(record.eventId, record)),
      );
  }

  String _timeOfDay() {
    final hour = _worldClockManager.hour();
    if (hour >= 5 && hour < 11) return 'morning';
    if (hour >= 11 && hour < 14) return 'noon';
    if (hour >= 14 && hour < 18) return 'afternoon';
    if (hour >= 18 && hour < 22) return 'evening';
    return 'night';
  }

  bool _matchesAnyOrEmpty(List<String> expected, Set<String> actual) {
    if (expected.isEmpty) return true;
    return expected.any(actual.contains);
  }

  bool _containsAll(Iterable<String> actual, Iterable<String> expected) {
    final actualSet = actual.toSet();
    return expected.every(actualSet.contains);
  }

  bool _intersects(Iterable<String> a, Iterable<String> b) {
    final set = a.toSet();
    return b.any(set.contains);
  }
}

List<Map<String, dynamic>> _listOfMaps(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

Map<String, dynamic> _mapOf(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return value
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
