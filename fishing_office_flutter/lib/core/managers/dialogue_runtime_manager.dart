import 'dart:math';

import '../../models/company_organization.dart';
import '../../models/friendship_state.dart';
import '../../models/living_office_state.dart';
import '../../models/player_influence.dart';
import '../../models/resident_dialogue_config.dart';
import '../../models/location_context.dart';
import '../../models/resident_career.dart';
import '../../models/resident_memory_config.dart';
import '../../models/resident_personality_context.dart';
import '../../models/resident_relationship_config.dart';
import '../engine/festival_manager.dart';
import '../engine/resident_memory_engine.dart';
import '../engine/resident_relationship_engine.dart';
import '../utils/runtime_debug.dart';
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
  final Map<String, _DialogueCacheEntry> _availableDialogueCache =
      <String, _DialogueCacheEntry>{};
  LivingOfficeState _livingOfficeState = LivingOfficeState.empty();
  PlayerInfluenceContext _playerInfluenceContext =
      PlayerInfluenceContext.empty();

  List<String> get servedNonRepeatableIds =>
      _servedNonRepeatableIds.toList(growable: true)..sort();

  void loadServedNonRepeatableIds(List<String> ids) {
    _servedNonRepeatableIds
      ..clear()
      ..addAll(ids.where((id) => id.isNotEmpty));
    _availableDialogueCache.clear();
  }

  void applyLivingOfficeState(LivingOfficeState state) {
    if (state.isEmpty) return;
    _livingOfficeState = state;
    _availableDialogueCache.clear();
  }

  void applyPlayerInfluenceContext(PlayerInfluenceContext context) {
    _playerInfluenceContext = context;
    _availableDialogueCache.clear();
  }

  List<ResidentDialogueEntry> getAvailableDialogues(String residentId) {
    final context = _contextFor(residentId);
    final cacheKey = context.cacheKey(
      servedNonRepeatableCount: _servedNonRepeatableIds.length,
      dialogueCount: _config.dialogues.length,
    );
    final cached = _availableDialogueCache[residentId];
    if (cached?.key == cacheKey) {
      return cached!.items;
    }
    final matches = _config.dialogues
        .where((dialogue) => _matchesResident(dialogue, residentId))
        .where((dialogue) => dialogue.actionType.isEmpty)
        .where((dialogue) =>
            dialogue.repeatable ||
            !_servedNonRepeatableIds.contains(dialogue.id))
        .where((dialogue) => _matchesConditions(dialogue.conditions, context))
        .toList(growable: false);
    final sorted = List<ResidentDialogueEntry>.from(matches)
      ..sort((a, b) {
        final priority = _effectivePriority(b, context)
            .compareTo(_effectivePriority(a, context));
        if (priority != 0) return priority;
        return a.id.compareTo(b.id);
      });
    _availableDialogueCache[residentId] = _DialogueCacheEntry(cacheKey, sorted);
    return sorted;
  }

  ResidentDialogueEntry? getInteractionFeedback(
    String residentId,
    String actionType, {
    bool success = true,
  }) {
    if (residentId.isEmpty || actionType.isEmpty) return null;
    final context = _contextFor(residentId);
    final expectedTag = success ? 'success' : 'blocked';
    final matches = _config.dialogues
        .where((dialogue) => _matchesResident(dialogue, residentId))
        .where((dialogue) => dialogue.actionType == actionType)
        .where((dialogue) =>
            dialogue.repeatable ||
            !_servedNonRepeatableIds.contains(dialogue.id))
        .where((dialogue) =>
            dialogue.tags.isEmpty ||
            dialogue.tags.contains(expectedTag) ||
            !dialogue.tags.contains(success ? 'blocked' : 'success'))
        .where((dialogue) => _matchesConditions(dialogue.conditions, context))
        .toList(growable: false);
    if (matches.isEmpty) return null;
    matches.sort((a, b) {
      final priority = _effectivePriority(b, context)
          .compareTo(_effectivePriority(a, context));
      if (priority != 0) return priority;
      final weight = b.weight.compareTo(a.weight);
      if (weight != 0) return weight;
      return a.id.compareTo(b.id);
    });
    final topPriority = _effectivePriority(matches.first, context);
    final top = matches
        .where(
            (dialogue) => _effectivePriority(dialogue, context) == topPriority)
        .toList(growable: false);
    final selected =
        top.length == 1 ? top.first : top[_random.nextInt(top.length)];
    if (!selected.repeatable) {
      _servedNonRepeatableIds.add(selected.id);
      _availableDialogueCache.remove(residentId);
    }
    return selected;
  }

  ResidentDialogueEntry getDialogue(String residentId) {
    final available = getAvailableDialogues(residentId);
    if (available.isEmpty) {
      RuntimeDebug.log(
          'DialogueRuntimeManager | resident=$residentId result=fallback');
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
      _availableDialogueCache.remove(residentId);
    }
    if (RuntimeDebug.enabled) {
      final state = _residentRuntimeManager.getResidentCurrentState(residentId);
      final relationship =
          _residentRelationshipEngine.getRelationship(residentId);
      RuntimeDebug.log(
        'DialogueRuntimeManager | resident=$residentId dialogue=${selected.id} '
        'time=${_timeOfDay()} weather=${_worldClockManager.weather().weatherType.name} '
        'festival=${_worldClockManager.festival().activeFestivals.join(',')} '
        'relationship=${relationship.relationshipLevel} mood=${state.mood} '
        'activity=${state.activity} location=${state.location}',
      );
    }
    return selected;
  }

  _DialogueRuntimeContext _contextFor(String residentId) {
    final state = _residentRuntimeManager.getResidentCurrentState(residentId);
    return _DialogueRuntimeContext(
      residentId: residentId,
      timeOfDay: _timeOfDay(),
      weather: _worldClockManager.weather(),
      festival: _worldClockManager.festival(),
      festivalContext:
          _festivalRuntimeManager?.residentFestivalContext(residentId),
      weatherContext:
          _weatherRuntimeManager?.residentWeatherContext(residentId),
      rumorContext: _rumorRuntimeManager?.residentRumorContext(residentId),
      state: state,
      location: _residentRuntimeManager.getResidentLocationContext(residentId),
      organization:
          _residentRuntimeManager.getResidentOrganizationContext(residentId),
      career: _residentRuntimeManager.getResidentCareerStatus(residentId),
      locationResidentCount:
          _residentRuntimeManager.getResidentsAtLocation(state.location).length,
      personality:
          _residentRuntimeManager.getResidentPersonalityContext(residentId),
      memory: _residentMemoryEngine.getResidentMemory(residentId),
      relationship: _residentRelationshipEngine.getRelationship(residentId),
      livingOfficeState: _livingOfficeState,
      playerInfluenceContext: _playerInfluenceContext,
    );
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
    if (!_matchesValue(conditions.friendshipStage, context.friendshipStage)) {
      return false;
    }
    if (conditions.minimumFriendshipStage.isNotEmpty &&
        friendshipStageRank(context.friendshipStage) <
            friendshipStageRank(conditions.minimumFriendshipStage)) {
      return false;
    }
    if (conditions.friendshipScoreMin > 0 &&
        context.friendshipScore < conditions.friendshipScoreMin) {
      return false;
    }
    if (conditions.minimumTrust > 0 &&
        context.trust < conditions.minimumTrust) {
      return false;
    }
    if (conditions.minimumFamiliarity > 0 &&
        context.familiarity < conditions.minimumFamiliarity) {
      return false;
    }
    if (conditions.sharedTopics.isNotEmpty &&
        !conditions.sharedTopics.every(context.sharedTopics.contains)) {
      return false;
    }
    if (!_matchesValue(
        conditions.lastInteractionType, context.lastInteractionType)) {
      return false;
    }
    if (conditions.recentConflict != null &&
        conditions.recentConflict != context.recentConflict) {
      return false;
    }
    if (conditions.recentConflictResolved != null &&
        conditions.recentConflictResolved != context.recentConflictResolved) {
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
    if (!_matchesLocation(conditions.residentLocation, context.location)) {
      return false;
    }
    if (!_matchesLocationTags(conditions.locationTags, context.location)) {
      return false;
    }
    if (!_matchesPersonalityTags(
      conditions.personalityTags,
      context.personality.traits,
    )) {
      return false;
    }
    if (_intersectsPersonalityTags(
      conditions.excludedPersonalityTags,
      context.personality.traits,
    )) {
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
    if (conditions.groupSizeMin > 0 &&
        context.groupSize < conditions.groupSizeMin) {
      return false;
    }
    if (!_matchesValue(conditions.groupActivity, context.groupActivity)) {
      return false;
    }
    if (!_matchesValue(conditions.groupTopic, context.groupTopic)) {
      return false;
    }
    if (!_matchesMood(conditions.groupMood, context.groupMood)) {
      return false;
    }
    if (!_matchesGroupTags(conditions.groupTags, context.groupTags)) {
      return false;
    }
    if (!_matchesValue(conditions.officeMood, context.officeMood)) {
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
    if (conditions.requiredOfficeTags.isNotEmpty &&
        !conditions.requiredOfficeTags.every(context.officeTags.contains)) {
      return false;
    }
    if (conditions.excludedOfficeTags.isNotEmpty &&
        conditions.excludedOfficeTags.any(context.officeTags.contains)) {
      return false;
    }
    if (conditions.requiredPlayerReputation.isNotEmpty &&
        !conditions.requiredPlayerReputation
            .every(context.playerReputation.contains)) {
      return false;
    }
    if (conditions.requiredRecentActions.isNotEmpty &&
        !conditions.requiredRecentActions
            .every(context.recentPlayerActions.contains)) {
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
    if (!_matchesValue(conditions.companyId, context.companyId)) {
      return false;
    }
    if (!_matchesValue(conditions.departmentId, context.departmentId)) {
      return false;
    }
    if (!_matchesValue(conditions.teamId, context.teamId)) {
      return false;
    }
    if (!_matchesValue(conditions.positionId, context.positionId)) {
      return false;
    }
    if (conditions.organizationTags.isNotEmpty &&
        !conditions.organizationTags.every(context.organizationTags.contains)) {
      return false;
    }
    if (!_matchesValue(conditions.careerLevel, context.careerLevel)) {
      return false;
    }
    if (!_matchesValue(conditions.employmentStatus, context.employmentStatus)) {
      return false;
    }
    if (conditions.careerTags.isNotEmpty &&
        !conditions.careerTags.every(context.careerTags.contains)) {
      return false;
    }
    if (conditions.salaryLevelMin > 0 &&
        context.salaryLevel < conditions.salaryLevelMin) {
      return false;
    }
    return true;
  }

  bool _matchesValue(String expected, String actual) {
    if (expected.isEmpty || expected == 'any') return true;
    return _tokens(expected).contains(actual);
  }

  bool _matchesLocation(String expected, LocationContext actual) {
    if (expected.isEmpty || expected == 'any') return true;
    final values = _tokens(expected).map(LocationContext.normalizeId).toSet();
    return values.contains(actual.locationId) ||
        values.contains(actual.locationType) ||
        values.any(actual.tags.contains);
  }

  bool _matchesLocationTags(List<String> expected, LocationContext actual) {
    if (expected.isEmpty) return true;
    return expected.every((tag) =>
        actual.tags.contains(tag) ||
        actual.locationId == tag ||
        actual.locationType == tag);
  }

  bool _matchesMood(String expected, String actual) {
    if (expected.isEmpty || expected == 'any') return true;
    final actualMood = normalizeResidentMood(actual);
    return _tokens(expected).map(normalizeResidentMood).contains(actualMood);
  }

  int _effectivePriority(
    ResidentDialogueEntry dialogue,
    _DialogueRuntimeContext context,
  ) {
    final normalizedMood = normalizeResidentMood(context.effectiveResidentMood);
    var priority = dialogue.priority;
    final conditionMood = dialogue.conditions.residentMood;
    if (conditionMood.isNotEmpty &&
        _matchesMood(conditionMood, normalizedMood)) {
      priority += 3;
    }
    if (dialogue.tags.map(normalizeResidentMood).contains(normalizedMood)) {
      priority += 1;
    }
    if (_matchesPersonalityTags(
      dialogue.conditions.personalityTags,
      context.personality.traits,
    )) {
      priority += dialogue.conditions.personalityTags.length * 2;
    }
    if (_matchesValue(
      dialogue.conditions.friendshipStage,
      context.friendshipStage,
    )) {
      priority += dialogue.conditions.friendshipStage.isEmpty ? 0 : 2;
    }
    if (dialogue.conditions.minimumFriendshipStage.isNotEmpty &&
        friendshipStageRank(context.friendshipStage) >=
            friendshipStageRank(dialogue.conditions.minimumFriendshipStage)) {
      priority += 1;
    }
    final personalityTags = context.personality.dialogueTags.toSet();
    priority += dialogue.tags.where(personalityTags.contains).length;
    if (dialogue.conditions.groupSizeMin > 0 &&
        context.groupSize >= dialogue.conditions.groupSizeMin) {
      priority += 2;
    }
    if (dialogue.conditions.groupTopic.isNotEmpty &&
        _matchesValue(dialogue.conditions.groupTopic, context.groupTopic)) {
      priority += 2;
    }
    if (dialogue.conditions.officeMood.isNotEmpty &&
        _matchesValue(dialogue.conditions.officeMood, context.officeMood)) {
      priority += 2;
    }
    priority += dialogue.tags.where(context.officeTags.contains).length;
    priority += dialogue.tags.where(context.playerReputation.contains).length;
    if (dialogue.conditions.requiredPlayerReputation.isNotEmpty) {
      priority += dialogue.conditions.requiredPlayerReputation.length * 2;
    }
    if (dialogue.conditions.requiredRecentActions.isNotEmpty) {
      priority += dialogue.conditions.requiredRecentActions.length;
    }
    return priority;
  }

  bool _matchesGroupTags(List<String> expected, List<String> actual) {
    if (expected.isEmpty) return true;
    return expected.every(actual.contains);
  }

  bool _matchesPersonalityTags(List<String> expected, List<String> actual) {
    if (expected.isEmpty) return true;
    final normalizedActual =
        actual.map(ResidentPersonalityContext.normalizeTrait).toSet();
    return expected
        .map(ResidentPersonalityContext.normalizeTrait)
        .every(normalizedActual.contains);
  }

  bool _intersectsPersonalityTags(List<String> expected, List<String> actual) {
    if (expected.isEmpty) return false;
    final normalizedActual =
        actual.map(ResidentPersonalityContext.normalizeTrait).toSet();
    return expected
        .map(ResidentPersonalityContext.normalizeTrait)
        .any(normalizedActual.contains);
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

class _DialogueCacheEntry {
  const _DialogueCacheEntry(this.key, this.items);

  final String key;
  final List<ResidentDialogueEntry> items;
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
    required this.location,
    required this.organization,
    required this.career,
    required this.locationResidentCount,
    required this.personality,
    required this.memory,
    required this.relationship,
    required this.livingOfficeState,
    required this.playerInfluenceContext,
  });

  final String residentId;
  final String timeOfDay;
  final WeatherState weather;
  final FestivalState festival;
  final FestivalContext? festivalContext;
  final WeatherContext? weatherContext;
  final RumorContext? rumorContext;
  final ResidentCurrentState state;
  final LocationContext location;
  final ResidentOrganizationContext organization;
  final ResidentCareerStatus career;
  final int locationResidentCount;
  final ResidentPersonalityContext personality;
  final ResidentMemoryRecord memory;
  final ResidentRelationshipRecord relationship;
  final LivingOfficeState livingOfficeState;
  final PlayerInfluenceContext playerInfluenceContext;

  String get friendshipStage {
    switch (relationship.relationshipLevel) {
      case 'known':
        return 'acquaintance';
      case 'friend':
        return 'familiar';
      case 'old_friend':
      case 'close_friend':
        return 'close_friend';
      case 'trust':
        return 'trusted_friend';
      default:
        return stageFor(
          relationship.relationshipScore.clamp(0, 100).toInt(),
          trust: trust,
          familiarity: familiarity,
        );
    }
  }

  int get friendshipScore =>
      relationship.relationshipScore.clamp(0, 100).toInt();
  int get trust =>
      (relationship.relationshipScore / 4).floor().clamp(0, 100).toInt();
  int get familiarity =>
      (memory.meetCount * 5 + relationship.relationshipScore ~/ 3)
          .clamp(0, 100)
          .toInt();
  List<String> get sharedTopics => memory.memoryTags
      .where((tag) => tag.startsWith('topic:'))
      .map((tag) => tag.substring('topic:'.length))
      .toList(growable: false);
  String get lastInteractionType {
    final tag = memory.memoryTags.lastWhere(
      (item) => item.startsWith('last_interaction:'),
      orElse: () => '',
    );
    return tag.replaceFirst('last_interaction:', '');
  }

  bool get recentConflict =>
      memory.memoryTags.contains('conflict') ||
      memory.memoryTags.contains('minor_tension');
  bool get recentConflictResolved =>
      memory.memoryTags.contains('resolve_conflict') ||
      memory.memoryTags.contains('conflict_resolved');

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

  int get groupSize => locationResidentCount;

  String get groupActivity {
    if (groupSize < 2) return '';
    final activity = effectiveResidentActivity;
    if (location.locationId == 'meeting_room') return 'meeting';
    if (location.locationId == 'pantry' ||
        location.locationId == 'coffee_shop') {
      return activity.contains('lunch') ? 'lunch' : 'coffee_break';
    }
    if (location.locationId == 'dock' ||
        location.locationId == 'sea' ||
        location.locationId == 'seaside') {
      return 'weekend_fishing';
    }
    if (rumorContext?.tags.isNotEmpty == true) return 'rumor_discussion';
    return activity.contains('review') ? 'project_review' : 'office_chat';
  }

  String get groupTopic {
    switch (groupActivity) {
      case 'meeting':
      case 'project_review':
        return 'project_review';
      case 'coffee_break':
        return 'coffee';
      case 'lunch':
        return 'lunch';
      case 'weekend_fishing':
        return 'fishing';
      case 'rumor_discussion':
        return 'rumor';
      default:
        return groupActivity.isEmpty ? '' : 'office_life';
    }
  }

  String get groupMood => groupSize < 2 ? '' : effectiveResidentMood;

  List<String> get groupTags {
    if (groupSize < 2) return const <String>[];
    return <String>{
      'office_group',
      groupActivity,
      if (groupTopic.isNotEmpty) 'topic:$groupTopic',
      'location:${location.locationId}',
      'mood:$groupMood',
      ...location.tags,
    }.where((item) => item.isNotEmpty).toList(growable: false);
  }

  String get officeMood => livingOfficeState.officeMood;
  int get activityLevel => livingOfficeState.activityLevel;
  int get socialLevel => livingOfficeState.socialLevel;
  int get tensionLevel => livingOfficeState.tensionLevel;
  List<String> get officeTags => livingOfficeState.worldTags;
  List<String> get playerReputation => playerInfluenceContext.reputation;
  Set<String> get recentPlayerActions =>
      playerInfluenceContext.recentActionTypes;
  int get officeInfluence => playerInfluenceContext.officeInfluence.overall;
  int get officeTrust => playerInfluenceContext.officeInfluence.officeTrust;
  String get companyId => organization.companyId;
  String get departmentId => organization.departmentId;
  String get teamId => organization.teamId;
  String get positionId => organization.positionId;
  List<String> get organizationTags => organization.tags;
  String get careerLevel => career.careerLevel;
  String get employmentStatus => career.employmentStatus;
  int get salaryLevel => career.salaryLevel;
  List<String> get careerTags => career.tags;

  String cacheKey({
    required int servedNonRepeatableCount,
    required int dialogueCount,
  }) {
    return [
      dialogueCount,
      servedNonRepeatableCount,
      residentId,
      timeOfDay,
      weather.weatherType.name,
      festival.activeFestivals.join('|'),
      state.location,
      state.activity,
      state.mood,
      location.locationId,
      locationResidentCount,
      relationship.relationshipLevel,
      relationship.relationshipScore,
      memory.meetCount,
      memory.memoryTags.join('|'),
      livingOfficeState.officeMood,
      livingOfficeState.activityLevel,
      livingOfficeState.socialLevel,
      livingOfficeState.tensionLevel,
      playerInfluenceContext.reputation.join('|'),
      playerInfluenceContext.recentActionTypes.join('|'),
      officeInfluence,
      officeTrust,
      companyId,
      departmentId,
      teamId,
      positionId,
      careerLevel,
      employmentStatus,
      salaryLevel,
    ].join('::');
  }
}
