import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../models/career_state.dart';
import '../../models/friendship_state.dart';
import '../../models/living_office_state.dart';
import '../../models/office_group.dart';
import '../../models/player_influence.dart';
import '../../models/resident_memory_config.dart';
import '../../models/resident_relationship_config.dart';
import '../../models/world_save_data.dart';
import '../engine/resident_memory_engine.dart';
import '../engine/resident_relationship_engine.dart';
import '../engine/world_calendar.dart';
import '../engine/world_clock.dart';
import '../repository/world_save_repository.dart';
import 'dialogue_runtime_manager.dart';
import 'festival_runtime_manager.dart';
import 'app_managers.dart';
import 'resident_runtime_manager.dart';
import 'rumor_runtime_manager.dart';
import 'story_runtime_manager.dart';
import 'weather_runtime_manager.dart';
import 'world_clock_manager.dart';

class WorldSaveManager extends ChangeNotifier {
  WorldSaveManager({
    required WorldSaveRepository repository,
    required WorldClockManager worldClockManager,
    required FestivalRuntimeManager festivalRuntimeManager,
    required WeatherRuntimeManager weatherRuntimeManager,
    required RumorRuntimeManager rumorRuntimeManager,
    required ResidentRuntimeManager residentRuntimeManager,
    required ResidentMemoryEngine residentMemoryEngine,
    required ResidentRelationshipEngine residentRelationshipEngine,
    required StoryRuntimeManager storyRuntimeManager,
    required DialogueRuntimeManager dialogueRuntimeManager,
  })  : _repository = repository,
        _worldClockManager = worldClockManager,
        _festivalRuntimeManager = festivalRuntimeManager,
        _weatherRuntimeManager = weatherRuntimeManager,
        _rumorRuntimeManager = rumorRuntimeManager,
        _residentRuntimeManager = residentRuntimeManager,
        _residentMemoryEngine = residentMemoryEngine,
        _residentRelationshipEngine = residentRelationshipEngine,
        _storyRuntimeManager = storyRuntimeManager,
        _dialogueRuntimeManager = dialogueRuntimeManager;

  final WorldSaveRepository _repository;
  final WorldClockManager _worldClockManager;
  final FestivalRuntimeManager _festivalRuntimeManager;
  final WeatherRuntimeManager _weatherRuntimeManager;
  final RumorRuntimeManager _rumorRuntimeManager;
  final ResidentRuntimeManager _residentRuntimeManager;
  final ResidentMemoryEngine _residentMemoryEngine;
  final ResidentRelationshipEngine _residentRelationshipEngine;
  final StoryRuntimeManager _storyRuntimeManager;
  final DialogueRuntimeManager _dialogueRuntimeManager;

  final List<InteractionHistoryRecord> _interactionHistory =
      <InteractionHistoryRecord>[];
  final Map<String, dynamic> _dailySimulationState = <String, dynamic>{};
  final Map<String, dynamic> _questRuntimeState = <String, dynamic>{};
  final Map<String, dynamic> _economyRuntimeState = <String, dynamic>{};
  final Map<String, dynamic> _relationshipRuntimeState = <String, dynamic>{};
  final Map<String, dynamic> _achievementRuntimeState = <String, dynamic>{};
  final Map<String, dynamic> _dynamicEventRuntimeState = <String, dynamic>{};
  CareerState _careerState = CareerState.initial();
  final List<CareerRewardRecord> _careerRewardHistory = <CareerRewardRecord>[];
  final Set<String> _salaryTransactionIds = <String>{};
  final List<CareerPromotionRecord> _promotionHistory =
      <CareerPromotionRecord>[];
  int? _lastCareerDailySettlement;
  final Map<String, PlayerSkillState> _playerSkillStates =
      <String, PlayerSkillState>{...CareerState.initial().skillSummary};
  final List<SkillExperienceRecord> _skillExperienceHistory =
      <SkillExperienceRecord>[];
  final Set<String> _processedSkillSourceIds = <String>{};
  final List<CareerFeedback> _careerFeedbackHistory = <CareerFeedback>[];
  CareerFeedback? _latestCareerFeedback;
  final Map<String, FriendshipState> _friendshipStates =
      <String, FriendshipState>{};
  final Set<String> _processedSocialSourceIds = <String>{};
  final List<FriendshipChangeRecord> _socialInteractionHistory =
      <FriendshipChangeRecord>[];
  final Map<String, int> _socialCooldowns = <String, int>{};
  final Map<String, String> _conflictStates = <String, String>{};
  Map<String, dynamic> _dailySocialSummary = <String, dynamic>{};
  Map<String, dynamic> _officeGroupState = <String, dynamic>{};
  final List<OfficeGroup> _activeGroups = <OfficeGroup>[];
  final List<OfficeGroup> _recentGroups = <OfficeGroup>[];
  final List<OfficeGroup> _groupHistory = <OfficeGroup>[];
  LivingOfficeState _livingOfficeState = LivingOfficeState.empty();
  final List<OfficeWorldHistoryEntry> _officeWorldHistory =
      <OfficeWorldHistoryEntry>[];
  final List<CompanyNewsItem> _companyNews = <CompanyNewsItem>[];
  final List<CompanyTimelineEvent> _companyTimeline = <CompanyTimelineEvent>[];
  String _lastLivingOfficeUpdate = '';
  final Set<String> _processedOfficeEventIds = <String>{};
  final Map<String, int> _officeEventCooldowns = <String, int>{};
  PlayerInfluenceContext _playerInfluenceContext =
      PlayerInfluenceContext.empty();
  PlayerOfficeInfluence _playerOfficeInfluence = PlayerOfficeInfluence.empty();
  final List<RecentPlayerAction> _recentPlayerActions = <RecentPlayerAction>[];
  final Set<String> _officeReputation = <String>{'quiet'};
  final List<TaskRewardRecord> _taskRewards = <TaskRewardRecord>[];

  WorldSaveData? _lastSave;
  Future<WorldSaveData>? _pendingSave;
  String _lastPayloadSignature = '';
  bool _loaded = false;
  Object? _error;

  WorldSaveData? get lastSave => _lastSave;
  bool get loaded => _loaded;
  Object? get error => _error;
  List<InteractionHistoryRecord> get interactionHistory =>
      List<InteractionHistoryRecord>.from(_interactionHistory);
  Map<String, dynamic> get dailySimulationState =>
      Map<String, dynamic>.unmodifiable(_dailySimulationState);
  Map<String, dynamic> get questRuntimeState =>
      Map<String, dynamic>.unmodifiable(_questRuntimeState);
  Map<String, dynamic> get economyRuntimeState =>
      Map<String, dynamic>.unmodifiable(_economyRuntimeState);
  Map<String, dynamic> get relationshipRuntimeState =>
      Map<String, dynamic>.unmodifiable(_relationshipRuntimeState);
  Map<String, dynamic> get achievementRuntimeState =>
      Map<String, dynamic>.unmodifiable(_achievementRuntimeState);
  Map<String, dynamic> get dynamicEventRuntimeState =>
      Map<String, dynamic>.unmodifiable(_dynamicEventRuntimeState);
  CareerState get careerState => _careerState;
  List<CareerRewardRecord> get careerRewardHistory =>
      List<CareerRewardRecord>.from(_careerRewardHistory);
  Set<String> get salaryTransactionIds =>
      Set<String>.unmodifiable(_salaryTransactionIds);
  List<CareerPromotionRecord> get promotionHistory =>
      List<CareerPromotionRecord>.from(_promotionHistory);
  int? get lastCareerDailySettlement => _lastCareerDailySettlement;
  Map<String, PlayerSkillState> get playerSkillStates =>
      Map<String, PlayerSkillState>.unmodifiable(_playerSkillStates);
  List<SkillExperienceRecord> get skillExperienceHistory =>
      List<SkillExperienceRecord>.from(_skillExperienceHistory);
  Set<String> get processedSkillSourceIds =>
      Set<String>.unmodifiable(_processedSkillSourceIds);
  List<CareerFeedback> get careerFeedbackHistory =>
      List<CareerFeedback>.from(_careerFeedbackHistory);
  CareerFeedback? get latestCareerFeedback => _latestCareerFeedback;
  Map<String, FriendshipState> get friendshipStates =>
      Map<String, FriendshipState>.unmodifiable(_friendshipStates);
  Set<String> get processedSocialSourceIds =>
      Set<String>.unmodifiable(_processedSocialSourceIds);
  List<FriendshipChangeRecord> get socialInteractionHistory =>
      List<FriendshipChangeRecord>.from(_socialInteractionHistory);
  Map<String, int> get socialCooldowns =>
      Map<String, int>.unmodifiable(_socialCooldowns);
  Map<String, String> get conflictStates =>
      Map<String, String>.unmodifiable(_conflictStates);
  Map<String, dynamic> get dailySocialSummary =>
      Map<String, dynamic>.unmodifiable(_dailySocialSummary);
  Map<String, dynamic> get officeGroupState =>
      Map<String, dynamic>.unmodifiable(_officeGroupState);
  List<OfficeGroup> get activeGroups => List<OfficeGroup>.from(_activeGroups);
  List<OfficeGroup> get recentGroups => List<OfficeGroup>.from(_recentGroups);
  List<OfficeGroup> get groupHistory => List<OfficeGroup>.from(_groupHistory);
  LivingOfficeState get livingOfficeState => _livingOfficeState;
  List<OfficeWorldHistoryEntry> get officeWorldHistory =>
      List<OfficeWorldHistoryEntry>.from(_officeWorldHistory);
  List<CompanyNewsItem> get companyNews =>
      List<CompanyNewsItem>.from(_companyNews);
  List<CompanyTimelineEvent> get companyTimeline =>
      List<CompanyTimelineEvent>.from(_companyTimeline);
  String get lastLivingOfficeUpdate => _lastLivingOfficeUpdate;
  Set<String> get processedOfficeEventIds =>
      Set<String>.unmodifiable(_processedOfficeEventIds);
  Map<String, int> get officeEventCooldowns =>
      Map<String, int>.unmodifiable(_officeEventCooldowns);
  PlayerInfluenceContext get playerInfluenceContext => _playerInfluenceContext;
  PlayerOfficeInfluence get playerOfficeInfluence => _playerOfficeInfluence;
  List<RecentPlayerAction> get recentPlayerActions =>
      List<RecentPlayerAction>.from(_recentPlayerActions);
  List<String> get officeReputation =>
      _officeReputation.toList(growable: false)..sort();
  List<TaskRewardRecord> get taskRewards =>
      List<TaskRewardRecord>.from(_taskRewards);

  Future<WorldSaveData> saveWorld({
    bool force = false,
    bool immediate = false,
  }) async {
    if (_pendingSave != null && !immediate) {
      return _pendingSave!;
    }
    final data = _buildSaveData();
    final signature = _saveSignature(data);
    if (!force && signature == _lastPayloadSignature && _lastSave != null) {
      return _lastSave!;
    }
    final pending = _repository.save(data).then((_) {
      _lastSave = data;
      _lastPayloadSignature = signature;
      _loaded = true;
      _error = null;
      return data;
    }).whenComplete(() {
      _pendingSave = null;
    });
    _pendingSave = pending;
    final saved = await pending;
    if (kDebugMode) {
      debugPrint(
        'WorldSaveManager | save version=${saved.saveVersion} interactions=${saved.interactionHistory.length}',
      );
    }
    notifyListeners();
    return saved;
  }

  Future<WorldSaveData?> loadWorld() async {
    try {
      final raw = await _repository.load();
      if (raw == null) {
        _loaded = false;
        _lastSave = null;
        notifyListeners();
        return null;
      }
      final migrated = _compatibleData(raw);
      if (migrated == null) {
        await resetWorld();
        return null;
      }
      _applySaveData(migrated);
      _lastSave = migrated;
      _lastPayloadSignature = _saveSignature(migrated);
      _loaded = true;
      _error = null;
      if (kDebugMode) {
        debugPrint(
          'WorldSaveManager | load version=${migrated.saveVersion} interactions=${migrated.interactionHistory.length}',
        );
      }
      notifyListeners();
      return migrated;
    } catch (error) {
      _error = error;
      _loaded = false;
      if (kDebugMode) {
        debugPrint('WorldSaveManager | load failed=$error');
      }
      notifyListeners();
      return null;
    }
  }

  Future<void> resetWorld() async {
    await _repository.reset();
    _worldClockManager.setClock(
      WorldClock.initial(),
      calendar: WorldCalendar.initial(),
    );
    _rumorRuntimeManager.loadRecords(const []);
    _residentRuntimeManager.clearRuntimeOverrides();
    _residentMemoryEngine.load(
      const ResidentMemoryConfig(version: '1.0', memories: []),
    );
    _residentRelationshipEngine.loadRelationships(const []);
    _storyRuntimeManager.loadFinishedStoryIds(const []);
    _dialogueRuntimeManager.loadServedNonRepeatableIds(const []);
    _dailySimulationState.clear();
    _questRuntimeState.clear();
    _economyRuntimeState.clear();
    _relationshipRuntimeState.clear();
    _achievementRuntimeState.clear();
    _dynamicEventRuntimeState.clear();
    _careerState = CareerState.initial();
    _careerRewardHistory.clear();
    _salaryTransactionIds.clear();
    _promotionHistory.clear();
    _lastCareerDailySettlement = null;
    _playerSkillStates
      ..clear()
      ..addAll(CareerState.initial().skillSummary);
    _skillExperienceHistory.clear();
    _processedSkillSourceIds.clear();
    _careerFeedbackHistory.clear();
    _latestCareerFeedback = null;
    _friendshipStates.clear();
    _processedSocialSourceIds.clear();
    _socialInteractionHistory.clear();
    _socialCooldowns.clear();
    _conflictStates.clear();
    _dailySocialSummary = <String, dynamic>{};
    _officeGroupState = <String, dynamic>{};
    _activeGroups.clear();
    _recentGroups.clear();
    _groupHistory.clear();
    _livingOfficeState = LivingOfficeState.empty();
    _officeWorldHistory.clear();
    _lastLivingOfficeUpdate = '';
    _processedOfficeEventIds.clear();
    _officeEventCooldowns.clear();
    _playerInfluenceContext = PlayerInfluenceContext.empty();
    _playerOfficeInfluence = PlayerOfficeInfluence.empty();
    _recentPlayerActions.clear();
    _officeReputation
      ..clear()
      ..add('quiet');
    _taskRewards.clear();
    _interactionHistory.clear();
    _lastSave = null;
    _lastPayloadSignature = '';
    _loaded = false;
    _error = null;
    notifyListeners();
  }

  Future<WorldSaveData> autoSave({bool force = false}) =>
      saveWorld(force: force);

  void setDailySimulationState(Map<String, dynamic> state) {
    final changed = !_mapEquals(_dailySimulationState, state);
    _dailySimulationState
      ..clear()
      ..addAll(Map<String, dynamic>.from(state));
    if (!changed) return;
  }

  void setQuestRuntimeState(Map<String, dynamic> state) {
    final changed = !_mapEquals(_questRuntimeState, state);
    _questRuntimeState
      ..clear()
      ..addAll(Map<String, dynamic>.from(state));
    if (!changed) return;
  }

  void setEconomyRuntimeState(Map<String, dynamic> state) {
    final changed = !_mapEquals(_economyRuntimeState, state);
    _economyRuntimeState
      ..clear()
      ..addAll(Map<String, dynamic>.from(state));
    if (!changed) return;
  }

  void setRelationshipRuntimeState(Map<String, dynamic> state) {
    final changed = !_mapEquals(_relationshipRuntimeState, state);
    _relationshipRuntimeState
      ..clear()
      ..addAll(Map<String, dynamic>.from(state));
    if (!changed) return;
  }

  void setAchievementRuntimeState(Map<String, dynamic> state) {
    final changed = !_mapEquals(_achievementRuntimeState, state);
    _achievementRuntimeState
      ..clear()
      ..addAll(Map<String, dynamic>.from(state));
    if (!changed) return;
  }

  void setDynamicEventRuntimeState(Map<String, dynamic> state) {
    final changed = !_mapEquals(_dynamicEventRuntimeState, state);
    _dynamicEventRuntimeState
      ..clear()
      ..addAll(Map<String, dynamic>.from(state));
    if (!changed) return;
  }

  CareerPromotionCheck getPromotionRequirements({
    int maxRelationshipRank = 0,
    Set<String> unlockedAchievementIds = const <String>{},
  }) {
    return _careerState.checkPromotion(
      maxRelationshipRank: maxRelationshipRank,
      unlockedAchievementIds: unlockedAchievementIds,
      claimedPromotionRewards:
          _promotionHistory.map((record) => record.id).toSet(),
    );
  }

  PlayerSkillState getSkillState(String skillId) {
    return _playerSkillStates[skillId] ?? PlayerSkillState.initial(skillId);
  }

  bool hasSkillExperienceSource({
    required String sourceType,
    required String sourceId,
    required String skillId,
  }) {
    return _processedSkillSourceIds.contains(
      _skillSourceKey(
          sourceType: sourceType, sourceId: sourceId, skillId: skillId),
    );
  }

  SkillExperienceRecord? recordSkillExperience({
    required String sourceType,
    required String sourceId,
    required String skillId,
    required int amount,
    String reason = '',
  }) {
    if (sourceType.isEmpty ||
        sourceId.isEmpty ||
        skillId.isEmpty ||
        amount <= 0) {
      return null;
    }
    final key = _skillSourceKey(
      sourceType: sourceType,
      sourceId: sourceId,
      skillId: skillId,
    );
    if (_processedSkillSourceIds.contains(key)) return null;
    final now = WorldClockManager.systemNow().toIso8601String();
    final record = SkillExperienceRecord(
      sourceType: sourceType,
      sourceId: sourceId,
      timestamp: now,
      skillId: skillId,
      amount: amount.clamp(1, 1000000).toInt(),
      reason: reason.isEmpty ? sourceType : reason,
    );
    final result = _careerState.withSkillExperience(record: record);
    _careerState = result.state;
    _playerSkillStates
      ..clear()
      ..addAll(_careerState.skillSummary);
    _processedSkillSourceIds.add(key);
    _skillExperienceHistory.insert(0, result.record);
    _trimSkillHistory();
    recordInteraction(
      residentId: '',
      dialogueId: '',
      storyId: '',
      tags: <String>[
        'skill_experience',
        sourceType,
        skillId,
        if (result.levelUps.isNotEmpty) 'skill_level_up',
      ],
    );
    notifyListeners();
    return result.record;
  }

  Map<String, int> recordSkillExperienceBatch({
    required String sourceType,
    required String sourceId,
    required Map<String, int> skills,
    String reason = '',
  }) {
    final gained = <String, int>{};
    for (final entry in skills.entries) {
      final record = recordSkillExperience(
        sourceType: sourceType,
        sourceId: sourceId,
        skillId: entry.key,
        amount: entry.value,
        reason: reason,
      );
      if (record != null) gained[record.skillId] = record.amount;
    }
    return gained;
  }

  CareerFeedback recordCareerFeedback(CareerFeedback feedback) {
    if (feedback.date.isEmpty) return feedback;
    _careerFeedbackHistory
      ..removeWhere((item) => item.date == feedback.date)
      ..insert(0, feedback);
    if (_careerFeedbackHistory.length > 30) {
      _careerFeedbackHistory.removeRange(30, _careerFeedbackHistory.length);
    }
    _latestCareerFeedback = feedback;
    notifyListeners();
    return feedback;
  }

  FriendshipState getFriendshipState(
    String residentId, {
    ResidentRelationshipRecord? relationship,
  }) {
    if (residentId.isEmpty) return FriendshipState.initial('');
    final existing = _friendshipStates[residentId];
    if (existing != null) {
      final cleared =
          existing.clearExpiredCooldowns(_worldClockManager.today().dayCount);
      if (cleared != existing) _friendshipStates[residentId] = cleared;
      return cleared;
    }
    final migrated = relationship == null
        ? FriendshipState.initial(residentId)
        : FriendshipState.fromRelationship(
            residentId: residentId,
            relationshipScore: relationship.relationshipScore,
            relationshipLevel: relationship.relationshipLevel,
            lastChangedAt: relationship.lastChangedAt,
            tags: relationship.tags,
          );
    _friendshipStates[residentId] = migrated;
    return migrated;
  }

  bool hasSocialSource({
    required String sourceType,
    required String sourceId,
    required String residentId,
  }) {
    return _processedSocialSourceIds.contains(
      friendshipSourceKey(
        sourceType: sourceType,
        sourceId: sourceId,
        residentId: residentId,
      ),
    );
  }

  FriendshipChangeRecord? recordFriendshipChange({
    required String residentId,
    required String sourceType,
    required String sourceId,
    int scoreDelta = 0,
    int trustDelta = 0,
    int familiarityDelta = 0,
    String reason = '',
    List<String> tags = const <String>[],
    ResidentRelationshipRecord? relationship,
  }) {
    if (residentId.isEmpty || sourceType.isEmpty || sourceId.isEmpty) {
      return null;
    }
    final key = friendshipSourceKey(
      sourceType: sourceType,
      sourceId: sourceId,
      residentId: residentId,
    );
    if (_processedSocialSourceIds.contains(key)) return null;
    final boundedScore = scoreDelta.clamp(-10, 10).toInt();
    final boundedTrust = trustDelta.clamp(-10, 10).toInt();
    final boundedFamiliarity = familiarityDelta.clamp(-10, 10).toInt();
    if (boundedScore == 0 && boundedTrust == 0 && boundedFamiliarity == 0) {
      return null;
    }
    final now = WorldClockManager.systemNow().toIso8601String();
    final record = FriendshipChangeRecord(
      sourceType: sourceType,
      sourceId: sourceId,
      residentId: residentId,
      scoreDelta: boundedScore,
      trustDelta: boundedTrust,
      familiarityDelta: boundedFamiliarity,
      reason: reason.isEmpty ? sourceType : reason,
      timestamp: now,
      tags: tags,
    );
    final previous = getFriendshipState(
      residentId,
      relationship: relationship,
    );
    final next = previous.applyChange(record);
    _friendshipStates[residentId] = next;
    _processedSocialSourceIds.add(key);
    _socialInteractionHistory.insert(0, record);
    _trimSocialHistory();
    if (next.conflictState != 'none') {
      _conflictStates[residentId] = next.conflictState;
    } else {
      _conflictStates.remove(residentId);
    }
    recordInteraction(
      residentId: residentId,
      dialogueId: '',
      storyId: '',
      tags: <String>[
        'friendship_change',
        sourceType,
        next.stage,
        if (next.conflictState != 'none') next.conflictState,
      ],
    );
    notifyListeners();
    return record;
  }

  FriendshipState setSocialCooldown({
    required String residentId,
    required String interactionType,
    required int durationDays,
    ResidentRelationshipRecord? relationship,
  }) {
    final current = getFriendshipState(
      residentId,
      relationship: relationship,
    );
    if (durationDays <= 0 || interactionType.isEmpty) return current;
    final expiresDay = _worldClockManager.today().dayCount + durationDays;
    final next = current.withCooldown(
      interactionType: interactionType,
      expiresDay: expiresDay,
    );
    _friendshipStates[residentId] = next;
    _socialCooldowns['$residentId::$interactionType'] = expiresDay;
    notifyListeners();
    return next;
  }

  bool isSocialCooldownActive(String residentId, String interactionType) {
    final state = getFriendshipState(residentId);
    final until = state.cooldowns[interactionType] ??
        _socialCooldowns['$residentId::$interactionType'];
    return until != null && until > _worldClockManager.today().dayCount;
  }

  void setDailySocialSummary(Map<String, dynamic> summary) {
    _dailySocialSummary = Map<String, dynamic>.from(summary);
    notifyListeners();
  }

  void setOfficeGroupState({
    Map<String, dynamic> state = const <String, dynamic>{},
    List<OfficeGroup> activeGroups = const <OfficeGroup>[],
    List<OfficeGroup> recentGroups = const <OfficeGroup>[],
    List<OfficeGroup> groupHistory = const <OfficeGroup>[],
  }) {
    _officeGroupState = Map<String, dynamic>.from(state);
    _activeGroups
      ..clear()
      ..addAll(activeGroups.where((group) => group.isValid));
    _recentGroups
      ..clear()
      ..addAll(recentGroups.where((group) => group.isValid).take(30));
    _groupHistory
      ..clear()
      ..addAll(groupHistory.where((group) => group.isValid).take(200));
    notifyListeners();
  }

  void recordOfficeGroup(OfficeGroup group) {
    if (!group.isValid) return;
    _activeGroups.removeWhere((item) => item.groupId == group.groupId);
    _activeGroups.add(group);
    _recentGroups
      ..removeWhere((item) => item.groupId == group.groupId)
      ..insert(0, group);
    _groupHistory
      ..removeWhere((item) => item.groupId == group.groupId)
      ..insert(0, group);
    _trimOfficeGroups();
    notifyListeners();
  }

  OfficeGroup? groupForResident(String residentId) {
    for (final group in _activeGroups) {
      if (group.containsResident(residentId)) return group;
    }
    return null;
  }

  void setLivingOfficeState(LivingOfficeState state) {
    if (state.isEmpty) return;
    if (_livingOfficeState.toJson().toString() == state.toJson().toString()) {
      return;
    }
    _livingOfficeState = state;
    _lastLivingOfficeUpdate = state.lastUpdatedAt;
    notifyListeners();
  }

  void recordOfficeWorldHistory(OfficeWorldHistoryEntry entry) {
    if (entry.date.isEmpty) return;
    _officeWorldHistory
      ..removeWhere((item) => item.date == entry.date)
      ..insert(0, entry);
    _trimOfficeWorldHistory();
    notifyListeners();
  }

  CompanyTimelineEvent? recordCompanyTimelineEvent({
    required String sourceId,
    required String type,
    required String title,
    required String summary,
    String category = '',
    int importance = 50,
    String date = '',
    String weekKey = '',
    String monthKey = '',
    List<String> relatedResidentIds = const <String>[],
    List<String> tags = const <String>[],
    Map<String, dynamic> payload = const <String, dynamic>{},
    bool generateNews = true,
  }) {
    if (sourceId.isEmpty || type.isEmpty || title.isEmpty) return null;
    final existing = _companyTimeline.where(
      (item) => item.sourceId == sourceId,
    );
    if (existing.isNotEmpty) return existing.first;
    final resolvedDate = date.isEmpty ? _currentDateKey() : date;
    final event = CompanyTimelineEvent(
      eventId: 'timeline:$sourceId',
      sourceId: sourceId,
      type: type,
      category: category.isEmpty ? _categoryForTimelineType(type) : category,
      title: title,
      summary: summary,
      importance: importance.clamp(0, 100).toInt(),
      date: resolvedDate,
      weekKey: weekKey.isEmpty ? _weekKeyFor(resolvedDate) : weekKey,
      monthKey: monthKey.isEmpty ? _monthKeyFor(resolvedDate) : monthKey,
      relatedResidentIds:
          relatedResidentIds.where((item) => item.isNotEmpty).toList(),
      tags: tags.where((item) => item.isNotEmpty).toList(),
      payload: payload,
    );
    _companyTimeline
      ..removeWhere((item) => item.sourceId == sourceId)
      ..insert(0, event);
    if (generateNews) {
      _companyNews
        ..removeWhere((item) => item.sourceId == sourceId)
        ..insert(0, event.toNewsItem());
    }
    _trimCompanyTimeline();
    notifyListeners();
    return event;
  }

  CompanyTimelineSnapshot getCompanyTimelineSnapshot({
    String date = '',
    String weekKey = '',
    String monthKey = '',
    int limit = 20,
  }) {
    final boundedLimit = limit.clamp(1, 100).toInt();
    final events = _companyTimeline
        .where((event) {
          if (date.isNotEmpty && event.date != date) return false;
          if (weekKey.isNotEmpty && event.weekKey != weekKey) return false;
          if (monthKey.isNotEmpty && event.monthKey != monthKey) return false;
          return true;
        })
        .take(boundedLimit)
        .toList(growable: false);
    return CompanyTimelineSnapshot(
      news: _companyNews.take(boundedLimit).toList(growable: false),
      events: events,
      dailySummary: _summaryBy(_companyTimeline, (event) => event.date),
      weeklySummary: _summaryBy(_companyTimeline, (event) => event.weekKey),
      monthlySummary: _summaryBy(_companyTimeline, (event) => event.monthKey),
    );
  }

  bool hasProcessedOfficeEvent(String id) {
    if (id.isEmpty) return false;
    return _processedOfficeEventIds.contains(id);
  }

  void markOfficeEventProcessed(String id) {
    if (id.isEmpty || _processedOfficeEventIds.contains(id)) return;
    _processedOfficeEventIds.add(id);
    while (_processedOfficeEventIds.length > 500) {
      _processedOfficeEventIds.remove(_processedOfficeEventIds.first);
    }
    notifyListeners();
  }

  bool isOfficeEventCooldownActive(String id) {
    final until = _officeEventCooldowns[id];
    return until != null && until > _worldClockManager.today().dayCount;
  }

  void setOfficeEventCooldown(String id, int durationDays) {
    if (id.isEmpty || durationDays <= 0) return;
    _officeEventCooldowns[id] =
        _worldClockManager.today().dayCount + durationDays;
    notifyListeners();
  }

  void setPlayerInfluenceContext(PlayerInfluenceContext context) {
    if (_playerInfluenceContext.toJson().toString() ==
        context.toJson().toString()) {
      return;
    }
    _playerInfluenceContext = context;
    _playerOfficeInfluence = context.officeInfluence;
    _officeReputation
      ..clear()
      ..addAll(context.reputation.isEmpty
          ? const <String>['quiet']
          : context.reputation);
    _recentPlayerActions
      ..clear()
      ..addAll(context.recentActions.take(40));
    notifyListeners();
  }

  void setPlayerOfficeInfluence(PlayerOfficeInfluence influence) {
    if (_playerOfficeInfluence.toJson().toString() ==
        influence.toJson().toString()) {
      return;
    }
    _playerOfficeInfluence = influence;
    notifyListeners();
  }

  void setOfficeReputation(List<String> reputation) {
    final next = reputation.where((item) => item.isNotEmpty).toSet();
    if (next.isEmpty) next.add('quiet');
    if (_officeReputation.length == next.length &&
        _officeReputation.containsAll(next)) {
      return;
    }
    _officeReputation
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  void recordPlayerAction(RecentPlayerAction action) {
    if (action.id.isEmpty || action.type.isEmpty) return;
    _recentPlayerActions
      ..removeWhere((item) => item.id == action.id)
      ..insert(0, action);
    while (_recentPlayerActions.length > 40) {
      _recentPlayerActions.removeLast();
    }
    notifyListeners();
  }

  bool hasCareerRewardSource(String sourceId) {
    if (sourceId.isEmpty) return false;
    return _careerRewardHistory.any((record) => record.sourceId == sourceId);
  }

  CareerRewardRecord? recordCareerProgress({
    required String sourceId,
    required String type,
    int experience = 0,
    int performanceDelta = 0,
    int completedTaskDelta = 0,
  }) {
    if (sourceId.isEmpty || hasCareerRewardSource(sourceId)) return null;
    final now = WorldClockManager.systemNow().toIso8601String();
    final record = CareerRewardRecord(
      id: 'career_${WorldClockManager.timestampId()}_$sourceId',
      type: type,
      sourceId: sourceId,
      experience: experience.clamp(0, 1 << 31).toInt(),
      performanceDelta: performanceDelta.clamp(-8, 8).toInt(),
      createdAt: now,
    );
    _careerState = _careerState.withCareerProgress(
      experienceDelta: record.experience,
      performanceDelta: record.performanceDelta,
      completedTaskDelta: completedTaskDelta,
      reason: type,
    );
    _careerRewardHistory
      ..removeWhere((item) => item.id == record.id)
      ..insert(0, record);
    _trimCareerHistory();
    recordInteraction(
      residentId: '',
      dialogueId: '',
      storyId: '',
      tags: <String>['career_progress', type, sourceId],
    );
    notifyListeners();
    return record;
  }

  CareerState settleCareerDay({
    required int dayCount,
    required String dateLabel,
    int experience = 2,
    int performanceDelta = 0,
    int completedTaskDelta = 0,
  }) {
    if (_lastCareerDailySettlement == dayCount) return _careerState;
    _careerState = _careerState.withDailySettlement(
      dateLabel: dateLabel,
      experienceDelta: experience,
      performanceDelta: performanceDelta,
      completedTaskDelta: completedTaskDelta,
    );
    _lastCareerDailySettlement = dayCount;
    final dailySkill = isWeekendDate(dateLabel)
        ? const <String, int>{'observation': 1}
        : const <String, int>{'efficiency': 2, 'observation': 1};
    recordSkillExperienceBatch(
      sourceType: 'daily_career',
      sourceId: 'career_daily_$dayCount',
      skills: dailySkill,
      reason: 'daily_work_summary',
    );
    recordCareerProgress(
      sourceId: 'career_daily_$dayCount',
      type: 'daily_work_summary',
      experience: 0,
      performanceDelta: 0,
    );
    notifyListeners();
    return _careerState;
  }

  bool isSalaryPaidForPeriod(int periodEnd) {
    return _salaryTransactionIds.any((id) => id.contains('_$periodEnd'));
  }

  CareerSalaryPayment? paySalaryForCurrentPeriod({
    required int dayCount,
    required int amount,
    required WalletManagerView wallet,
    required TransactionManagerView transactions,
  }) {
    if (dayCount <= 0 || amount <= 0) return null;
    final periodEnd = dayCount - (dayCount % 7);
    if (periodEnd <= 0 || isSalaryPaidForPeriod(periodEnd)) return null;
    final periodStart = periodEnd - 6;
    final transactionId =
        'salary_${_careerState.careerLevel}_${periodStart}_$periodEnd';
    if (_salaryTransactionIds.contains(transactionId)) return null;
    final now = WorldClockManager.systemNow();
    wallet.add(amount);
    transactions.addRecord(
      TransactionRecord(
        id: transactionId,
        type: 'salary',
        currency: 'fish_coin',
        amount: amount,
        itemId: _careerState.careerLevel,
        itemName: _careerState.jobTitle,
        createdAt: now,
        category: 'income',
        note: '办公室工资 ${_careerState.jobTitle} 第$periodStart-$periodEnd天',
      ),
    );
    _salaryTransactionIds.add(transactionId);
    _careerState = _careerState.withSalaryDate(now.toIso8601String());
    _trimCareerHistory();
    recordInteraction(
      residentId: '',
      dialogueId: '',
      storyId: '',
      tags: <String>['salary_paid', _careerState.careerLevel, transactionId],
    );
    notifyListeners();
    return CareerSalaryPayment(
      transactionId: transactionId,
      careerLevel: _careerState.careerLevel,
      amount: amount,
      periodStart: periodStart,
      periodEnd: periodEnd,
      timestamp: now.toIso8601String(),
      paid: true,
    );
  }

  CareerPromotionResult promoteCareer({
    required int maxRelationshipRank,
    Set<String> unlockedAchievementIds = const <String>{},
  }) {
    final check = getPromotionRequirements(
      maxRelationshipRank: maxRelationshipRank,
      unlockedAchievementIds: unlockedAchievementIds,
    );
    final timestamp = WorldClockManager.systemNow().toIso8601String();
    if (!check.eligible) {
      _careerState = _careerState.withPromotionCheck(check);
      notifyListeners();
      return CareerPromotionResult(
        success: false,
        previousLevel: _careerState.careerLevel,
        newLevel: _careerState.careerLevel,
        newTitle: _careerState.jobTitle,
        reward: 0,
        missingRequirements: check.missingRequirements,
        performanceScore: _careerState.performanceScore,
        timestamp: timestamp,
      );
    }
    final previous = _careerState.careerLevel;
    final next = check.targetLevel;
    final rewardId = CareerState.promotionRewardId(previous, next);
    if (_promotionHistory.any((record) => record.id == rewardId)) {
      return CareerPromotionResult(
        success: false,
        previousLevel: previous,
        newLevel: previous,
        newTitle: _careerState.jobTitle,
        reward: 0,
        missingRequirements: <String>[
          'promotion_reward_already_claimed:$rewardId'
        ],
        performanceScore: _careerState.performanceScore,
        timestamp: timestamp,
      );
    }
    final reward = (CareerState.salaryForLevel(next) * 0.6).round();
    _careerState = _careerState.promote(timestamp);
    _promotionHistory.insert(
      0,
      CareerPromotionRecord(
        id: rewardId,
        previousLevel: previous,
        newLevel: next,
        reward: reward,
        createdAt: timestamp,
      ),
    );
    _trimCareerHistory();
    recordInteraction(
      residentId: '',
      dialogueId: '',
      storyId: '',
      tags: <String>['career_promotion', previous, next],
    );
    notifyListeners();
    return CareerPromotionResult(
      success: true,
      previousLevel: previous,
      newLevel: next,
      newTitle: _careerState.jobTitle,
      reward: reward,
      missingRequirements: const <String>[],
      performanceScore: _careerState.performanceScore,
      timestamp: timestamp,
    );
  }

  void recordTaskReward(TaskRewardRecord record) {
    if (record.id.isEmpty) return;
    _taskRewards.removeWhere((item) => item.id == record.id);
    _taskRewards.add(record);
  }

  void recordInteraction({
    required String residentId,
    required String dialogueId,
    String storyId = '',
    List<String> tags = const <String>[],
  }) {
    final createdAt = WorldClockManager.systemNow().toIso8601String();
    _interactionHistory.add(
      InteractionHistoryRecord(
        id: '${createdAt}_$residentId',
        residentId: residentId,
        dialogueId: dialogueId,
        storyId: storyId,
        createdAt: createdAt,
        tags: tags,
      ),
    );
  }

  WorldSaveData _buildSaveData() {
    return WorldSaveData(
      saveVersion: currentWorldSaveVersion,
      savedAt: WorldClockManager.systemNow().toIso8601String(),
      worldClock: _worldClockManager.clock,
      worldCalendar: _worldClockManager.calendar,
      festivalRuntime: {
        'activeFestivalIds': _festivalRuntimeManager
            .getActiveFestivals()
            .map((festival) => festival.id)
            .toList(growable: false),
        'tags': _festivalRuntimeManager.getFestivalTags(),
      },
      weatherRuntime: {
        'currentWeatherId': _weatherRuntimeManager.getCurrentWeather()?.id,
        'tags': _weatherRuntimeManager.getWeatherTags(),
      },
      rumorRuntime: _rumorRuntimeManager.records,
      residentRuntime: {
        'states': _residentRuntimeManager.residents
            .map((resident) => _residentStateToJson(resident.id))
            .toList(growable: false),
        'organizationMutationHistory': _residentRuntimeManager
            .organizationMutationHistory
            .map((record) => record.toJson())
            .toList(growable: false),
        'processedOrganizationMutationIds':
            _residentRuntimeManager.processedOrganizationMutationIds,
        'officeEconomy': _residentRuntimeManager.officeEconomyState.toJson(),
      },
      residentMemory: _residentMemoryEngine.toConfig(),
      residentRelationship: ResidentRelationshipConfig(
        version: '1.0',
        levels: const [],
        relationships: _residentRelationshipEngine.relationships,
      ),
      finishedStories: _storyRuntimeManager.finishedStoryIds,
      dialogueRuntimeState: {
        'servedNonRepeatableIds':
            _dialogueRuntimeManager.servedNonRepeatableIds,
      },
      dailySimulationState: dailySimulationState,
      questRuntimeState: questRuntimeState,
      economyRuntimeState: economyRuntimeState,
      relationshipRuntimeState: relationshipRuntimeState,
      achievementRuntimeState: achievementRuntimeState,
      dynamicEventRuntimeState: dynamicEventRuntimeState,
      careerState: careerState,
      careerRewardHistory: careerRewardHistory,
      salaryTransactionIds: _salaryTransactionIds.toList(growable: false)
        ..sort(),
      promotionHistory: promotionHistory,
      lastCareerDailySettlement: _lastCareerDailySettlement,
      playerSkillStates: playerSkillStates,
      skillExperienceHistory: skillExperienceHistory,
      processedSkillSourceIds: _processedSkillSourceIds.toList(growable: false)
        ..sort(),
      careerFeedbackHistory: careerFeedbackHistory,
      latestCareerFeedback: _latestCareerFeedback,
      friendshipStates: friendshipStates,
      processedSocialSourceIds:
          _processedSocialSourceIds.toList(growable: false)..sort(),
      socialInteractionHistory: socialInteractionHistory,
      socialCooldowns: socialCooldowns,
      conflictStates: conflictStates,
      dailySocialSummary: dailySocialSummary,
      officeGroupState: officeGroupState,
      activeGroups: activeGroups,
      recentGroups: recentGroups,
      groupHistory: groupHistory,
      livingOfficeState: livingOfficeState,
      officeWorldHistory: officeWorldHistory,
      companyNews: companyNews,
      companyTimeline: companyTimeline,
      lastLivingOfficeUpdate: _lastLivingOfficeUpdate,
      processedOfficeEventIds: _processedOfficeEventIds.toList(growable: false)
        ..sort(),
      officeEventCooldowns: officeEventCooldowns,
      playerInfluenceContext: playerInfluenceContext,
      playerOfficeInfluence: playerOfficeInfluence,
      recentPlayerActions: recentPlayerActions,
      officeReputation: officeReputation,
      taskRewards: taskRewards,
      interactionHistory:
          List<InteractionHistoryRecord>.from(_interactionHistory),
    );
  }

  void _applySaveData(WorldSaveData data) {
    _worldClockManager.setClock(
      data.worldClock,
      calendar: data.worldCalendar,
    );
    _rumorRuntimeManager.loadRecords(data.rumorRuntime);
    _residentMemoryEngine.load(data.residentMemory);
    _residentRelationshipEngine.loadRelationships(
      data.residentRelationship.relationships,
    );
    _residentRuntimeManager.loadRuntimeStates(
      _listOfMaps(data.residentRuntime['states']),
      organizationMutationHistory:
          _listOfMaps(data.residentRuntime['organizationMutationHistory']),
      processedOrganizationMutationIds: _stringList(
        data.residentRuntime['processedOrganizationMutationIds'],
      ),
      officeEconomy: _dynamicMap(data.residentRuntime['officeEconomy']),
    );
    _storyRuntimeManager.loadFinishedStoryIds(data.finishedStories);
    _dialogueRuntimeManager.loadServedNonRepeatableIds(
      _stringList(data.dialogueRuntimeState['servedNonRepeatableIds']),
    );
    _dailySimulationState
      ..clear()
      ..addAll(data.dailySimulationState);
    _questRuntimeState
      ..clear()
      ..addAll(data.questRuntimeState);
    _economyRuntimeState
      ..clear()
      ..addAll(data.economyRuntimeState);
    _relationshipRuntimeState
      ..clear()
      ..addAll(data.relationshipRuntimeState);
    _achievementRuntimeState
      ..clear()
      ..addAll(data.achievementRuntimeState);
    _dynamicEventRuntimeState
      ..clear()
      ..addAll(data.dynamicEventRuntimeState);
    _careerState = data.careerState.normalized();
    _playerSkillStates
      ..clear()
      ..addAll(data.playerSkillStates.isEmpty
          ? _careerState.skillSummary
          : data.playerSkillStates);
    _careerState =
        _careerState.copyWith(skillSummary: _playerSkillStates).normalized();
    _careerRewardHistory
      ..clear()
      ..addAll(data.careerRewardHistory);
    _salaryTransactionIds
      ..clear()
      ..addAll(data.salaryTransactionIds);
    _promotionHistory
      ..clear()
      ..addAll(data.promotionHistory);
    _lastCareerDailySettlement = data.lastCareerDailySettlement;
    _skillExperienceHistory
      ..clear()
      ..addAll(data.skillExperienceHistory);
    _processedSkillSourceIds
      ..clear()
      ..addAll(data.processedSkillSourceIds);
    _careerFeedbackHistory
      ..clear()
      ..addAll(data.careerFeedbackHistory);
    _latestCareerFeedback = data.latestCareerFeedback;
    _friendshipStates
      ..clear()
      ..addAll(data.friendshipStates);
    _processedSocialSourceIds
      ..clear()
      ..addAll(data.processedSocialSourceIds);
    _socialInteractionHistory
      ..clear()
      ..addAll(data.socialInteractionHistory);
    _socialCooldowns
      ..clear()
      ..addAll(data.socialCooldowns);
    _conflictStates
      ..clear()
      ..addAll(data.conflictStates);
    _dailySocialSummary = Map<String, dynamic>.from(data.dailySocialSummary);
    _officeGroupState = Map<String, dynamic>.from(data.officeGroupState);
    _activeGroups
      ..clear()
      ..addAll(data.activeGroups);
    _recentGroups
      ..clear()
      ..addAll(data.recentGroups);
    _groupHistory
      ..clear()
      ..addAll(data.groupHistory);
    _livingOfficeState = data.livingOfficeState;
    _officeWorldHistory
      ..clear()
      ..addAll(data.officeWorldHistory);
    _companyNews
      ..clear()
      ..addAll(data.companyNews.take(companyNewsHistoryLimit));
    _companyTimeline
      ..clear()
      ..addAll(data.companyTimeline.take(companyTimelineHistoryLimit));
    _lastLivingOfficeUpdate = data.lastLivingOfficeUpdate;
    _processedOfficeEventIds
      ..clear()
      ..addAll(data.processedOfficeEventIds);
    _officeEventCooldowns
      ..clear()
      ..addAll(data.officeEventCooldowns);
    _playerInfluenceContext = data.playerInfluenceContext;
    _playerOfficeInfluence = data.playerOfficeInfluence;
    _recentPlayerActions
      ..clear()
      ..addAll(data.recentPlayerActions.take(40));
    _officeReputation
      ..clear()
      ..addAll(data.officeReputation.isEmpty
          ? const <String>['quiet']
          : data.officeReputation);
    _taskRewards
      ..clear()
      ..addAll(data.taskRewards);
    _interactionHistory
      ..clear()
      ..addAll(data.interactionHistory);
  }

  WorldSaveData? _compatibleData(WorldSaveData data) {
    if (data.isCurrentVersion) return data;
    if (data.saveVersion.startsWith('1.')) {
      return data.copyWith(
        saveVersion: currentWorldSaveVersion,
        careerState: data.careerState.normalized(),
        playerSkillStates: data.playerSkillStates.isEmpty
            ? data.careerState.normalized().skillSummary
            : data.playerSkillStates,
        friendshipStates: data.friendshipStates,
        processedSocialSourceIds: data.processedSocialSourceIds,
        socialInteractionHistory: data.socialInteractionHistory,
        socialCooldowns: data.socialCooldowns,
        conflictStates: data.conflictStates,
        dailySocialSummary: data.dailySocialSummary,
        officeGroupState: data.officeGroupState,
        activeGroups: data.activeGroups,
        recentGroups: data.recentGroups,
        groupHistory: data.groupHistory,
        livingOfficeState: data.livingOfficeState,
        officeWorldHistory: data.officeWorldHistory,
        companyNews: data.companyNews,
        companyTimeline: data.companyTimeline,
        lastLivingOfficeUpdate: data.lastLivingOfficeUpdate,
        processedOfficeEventIds: data.processedOfficeEventIds,
        officeEventCooldowns: data.officeEventCooldowns,
        playerInfluenceContext: data.playerInfluenceContext,
        playerOfficeInfluence: data.playerOfficeInfluence,
        recentPlayerActions: data.recentPlayerActions,
        officeReputation: data.officeReputation,
      );
    }
    return null;
  }

  void _trimCareerHistory() {
    if (_careerRewardHistory.length > 100) {
      _careerRewardHistory.removeRange(100, _careerRewardHistory.length);
    }
    if (_promotionHistory.length > careerLevelOrder.length) {
      _promotionHistory.removeRange(
          careerLevelOrder.length, _promotionHistory.length);
    }
    final sortedSalaryIds = _salaryTransactionIds.toList(growable: false)
      ..sort();
    if (sortedSalaryIds.length > 52) {
      _salaryTransactionIds
        ..clear()
        ..addAll(sortedSalaryIds.skip(sortedSalaryIds.length - 52));
    }
  }

  void _trimSkillHistory() {
    if (_skillExperienceHistory.length > 500) {
      _skillExperienceHistory.removeRange(500, _skillExperienceHistory.length);
    }
    final sortedKeys = _processedSkillSourceIds.toList(growable: false)..sort();
    if (sortedKeys.length > 500) {
      _processedSkillSourceIds
        ..clear()
        ..addAll(sortedKeys.skip(sortedKeys.length - 500));
    }
  }

  void _trimSocialHistory() {
    if (_socialInteractionHistory.length > 1000) {
      _socialInteractionHistory.removeRange(
        1000,
        _socialInteractionHistory.length,
      );
    }
    while (_processedSocialSourceIds.length > 1200) {
      _processedSocialSourceIds.remove(_processedSocialSourceIds.first);
    }
  }

  void _trimOfficeGroups() {
    if (_recentGroups.length > 30) {
      _recentGroups.removeRange(30, _recentGroups.length);
    }
    if (_groupHistory.length > 200) {
      _groupHistory.removeRange(200, _groupHistory.length);
    }
  }

  void _trimOfficeWorldHistory() {
    final keepForever =
        _officeWorldHistory.where((entry) => entry.keepForever).toList();
    final normal = _officeWorldHistory
        .where((entry) => !entry.keepForever)
        .take(90)
        .toList(growable: false);
    _officeWorldHistory
      ..clear()
      ..addAll(<OfficeWorldHistoryEntry>[
        ...keepForever,
        ...normal,
      ]);
  }

  void _trimCompanyTimeline() {
    if (_companyNews.length > companyNewsHistoryLimit) {
      _companyNews.removeRange(companyNewsHistoryLimit, _companyNews.length);
    }
    if (_companyTimeline.length > companyTimelineHistoryLimit) {
      _companyTimeline.removeRange(
        companyTimelineHistoryLimit,
        _companyTimeline.length,
      );
    }
  }

  String _currentDateKey() {
    final calendar = _worldClockManager.calendar;
    return 'Y${calendar.year}-M${calendar.month}-D${calendar.day}';
  }

  String _weekKeyFor(String date) {
    if (date.contains('-W')) return date.split('-D').first;
    final day = _worldClockManager.calendar.day;
    final week = ((day - 1) ~/ 7) + 1;
    return '${date.split('-D').first}-W$week';
  }

  String _monthKeyFor(String date) {
    return date.split('-D').first;
  }

  String _categoryForTimelineType(String type) {
    if (type.contains('promotion') ||
        type.contains('transfer') ||
        type.contains('hire') ||
        type.contains('resignation')) {
      return 'career';
    }
    if (type.contains('budget') ||
        type.contains('bonus') ||
        type.contains('economy')) {
      return 'economy';
    }
    if (type.contains('achievement')) return 'achievement';
    if (type.contains('ai_decision')) return 'ai';
    if (type.contains('event')) return 'event';
    return 'company';
  }

  Map<String, int> _summaryBy(
    List<CompanyTimelineEvent> events,
    String Function(CompanyTimelineEvent event) keyOf,
  ) {
    final summary = <String, int>{};
    for (final event in events) {
      final key = keyOf(event);
      if (key.isEmpty) continue;
      summary[key] = (summary[key] ?? 0) + 1;
    }
    return summary;
  }

  String _skillSourceKey({
    required String sourceType,
    required String sourceId,
    required String skillId,
  }) {
    return '$sourceType::$sourceId::$skillId';
  }

  bool isWeekendDate(String dateLabel) {
    return dateLabel.contains('weekend');
  }

  Map<String, dynamic> _residentStateToJson(String residentId) {
    final state = _residentRuntimeManager.getResidentCurrentState(residentId);
    final personality =
        _residentRuntimeManager.getResidentPersonalityContext(residentId);
    final reason = state.scheduleReason;
    return {
      'residentId': state.residentId,
      'scheduleId': state.scheduleId,
      'location': state.location,
      'residentCurrentLocation': state.location,
      'temporaryLocationOverride': state.location,
      'activity': state.activity,
      'mood': state.mood,
      'startTime': state.startTime,
      'endTime': state.endTime,
      'found': state.found,
      'schedulePhase': state.schedulePhase,
      'isWorking': state.isWorking,
      'isOnBreak': state.isOnBreak,
      'isOvertime': state.isOvertime,
      'isWeekend': state.isWeekend,
      'nextLocation': state.nextLocation,
      'nextActivity': state.nextActivity,
      'nextChangeTime': state.nextChangeTime,
      'overrideReason': state.scheduleReason,
      'overrideExpiresAt': state.nextChangeTime,
      'lastScheduleChange': state.startTime,
      'nextScheduleChange': state.nextChangeTime,
      'organization': state.organization.toJson(),
      'career': state.career.toJson(),
      'lastLocationChange': state.startTime,
      'locationVisitHistory': [
        {
          'locationId': state.location,
          'dayCount': _worldClockManager.today().dayCount,
          'time': state.startTime,
          'reason': state.scheduleReason,
        }
      ],
      'recentPersonalityInfluences': reason.startsWith('personality_')
          ? [
              {
                'trait': personality.dominantTrait,
                'reason': reason,
                'dayCount': _worldClockManager.today().dayCount,
                'time': state.startTime,
              }
            ]
          : const <Map<String, dynamic>>[],
      'lastPersonalityDecisionReason':
          reason.startsWith('personality_') ? reason : '',
      'interactionPreferenceOverride': '',
      'dayCount': _worldClockManager.today().dayCount,
      'source': 'resident_runtime',
      'reason': 'world_save',
      'createdMinute':
          _worldClockManager.hour() * 60 + _worldClockManager.minute(),
    };
  }

  List<String> _stringList(Object? value) {
    if (value is! List) return const <String>[];
    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _listOfMaps(Object? value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Map<String, dynamic> _dynamicMap(Object? value) {
    if (value is! Map) return const <String, dynamic>{};
    return Map<String, dynamic>.from(value);
  }

  bool _mapEquals(Map<String, dynamic> current, Map<String, dynamic> next) {
    return jsonEncode(current) == jsonEncode(next);
  }

  String _saveSignature(WorldSaveData data) {
    final json = Map<String, dynamic>.from(data.toJson())..remove('savedAt');
    return jsonEncode(json);
  }
}
