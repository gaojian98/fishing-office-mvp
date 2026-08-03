import 'package:flutter/foundation.dart';

import '../../models/career_state.dart';
import '../../models/company_organization.dart';
import '../../models/dynamic_event_config.dart';
import '../../models/friendship_state.dart';
import '../../models/interactive_office.dart';
import '../../models/inventory_config.dart';
import '../../models/living_office_state.dart';
import '../../models/living_world_config.dart';
import '../../models/location_context.dart';
import '../../models/office_group.dart';
import '../../models/office_economy.dart';
import '../../models/player_influence.dart';
import '../../models/resident_config.dart';
import '../../models/resident_career.dart';
import '../../models/resident_dialogue_config.dart';
import '../../models/resident_memory_config.dart';
import '../../models/resident_personality_context.dart';
import '../../models/resident_relationship_config.dart';
import '../../models/resident_story_config.dart';
import '../managers/dialogue_runtime_manager.dart';
import '../managers/daily_simulation_manager.dart';
import '../managers/dynamic_event_runtime_manager.dart';
import '../managers/app_managers.dart';
import '../managers/festival_runtime_manager.dart';
import '../managers/resident_runtime_manager.dart';
import '../managers/resident_life_manager.dart';
import '../managers/rumor_runtime_manager.dart';
import '../managers/relationship_runtime_manager.dart';
import '../managers/story_runtime_manager.dart';
import '../managers/weather_runtime_manager.dart';
import '../managers/world_clock_manager.dart';
import '../managers/world_save_manager.dart';
import '../services/fairy_event_service.dart';
import 'resident_dialogue_engine.dart';
import 'resident_memory_engine.dart';
import 'resident_relationship_engine.dart';
import 'resident_story_engine.dart';

class SecondWorldEngine {
  SecondWorldEngine({
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
    InventoryManagerView? inventoryManager,
    InventoryConfig? inventoryConfig,
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
        _residentRuntimeManager = residentRuntimeManager,
        _inventoryManager = inventoryManager,
        _inventoryConfig = inventoryConfig;

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
  InventoryManagerView? _inventoryManager;
  InventoryConfig? _inventoryConfig;
  RelationshipRuntimeManager? _relationshipRuntimeManager;
  DynamicEventRuntimeManager? _dynamicEventRuntimeManager;
  DailySimulationManager? _dailySimulationManager;

  CompanyOrganization getCompanyOrganization() {
    return _residentRuntimeManager?.companyOrganization ??
        CompanyOrganization.defaultStructure();
  }

  ResidentOrganizationContext getResidentOrganizationContext(String id) {
    final runtime = _residentRuntimeManager;
    if (runtime != null) {
      return runtime.getResidentOrganizationContext(id);
    }
    return ResidentOrganizationContext.resolve(
      _residentConfig.findResident(id).organization,
      organization: getCompanyOrganization(),
    );
  }

  ResidentCareerStatus getResidentCareerStatus(String id) {
    return _residentRuntimeManager?.getResidentCareerStatus(id) ??
        _residentConfig.findResident(id).career;
  }

  List<ResidentCareerEvent> getResidentCareerEvents(String id) {
    return getResidentCareerStatus(id).promotionHistory;
  }

  OfficeEconomyState getOfficeEconomyState() {
    return _residentRuntimeManager?.officeEconomyState ??
        const OfficeEconomyState.empty();
  }

  OfficeEconomySettlementResult settleOfficeEconomy({
    required String periodType,
    required String periodKey,
    String departmentId = '',
    String settlementId = '',
    int bonusPool = 0,
    int operatingCost = 0,
    int projectIncome = 0,
    String reason = '',
  }) {
    return _residentRuntimeManager?.settleOfficeEconomy(
          periodType: periodType,
          periodKey: periodKey,
          departmentId: departmentId,
          settlementId: settlementId,
          bonusPool: bonusPool,
          operatingCost: operatingCost,
          projectIncome: projectIncome,
          reason: reason,
        ) ??
        const OfficeEconomySettlementResult.failure(
          <String>['resident_runtime_missing'],
        );
  }

  ResidentCareerStatus applyResidentCareerEvent(
    String residentId, {
    required String type,
    String date = '',
    String fromPositionId = '',
    String toPositionId = '',
    String fromCareerLevel = '',
    String toCareerLevel = '',
    String reason = '',
    int? salaryLevel,
    int? performanceScore,
    int? capabilityScore,
    List<String> tags = const <String>[],
  }) {
    return _residentRuntimeManager?.applyResidentCareerEvent(
          residentId,
          type: type,
          date: date,
          fromPositionId: fromPositionId,
          toPositionId: toPositionId,
          fromCareerLevel: fromCareerLevel,
          toCareerLevel: toCareerLevel,
          reason: reason,
          salaryLevel: salaryLevel,
          performanceScore: performanceScore,
          capabilityScore: capabilityScore,
          tags: tags,
        ) ??
        getResidentCareerStatus(residentId);
  }

  OrganizationMutationResult assignResidentOrganization(
    String residentId, {
    String mutationType = 'hire',
    String date = '',
    String companyId = '',
    String departmentId = '',
    String teamId = '',
    String positionId = '',
    String reason = '',
    String sourceId = '',
    String reportsToResidentId = '',
    String careerLevel = '',
  }) {
    return _residentRuntimeManager?.assignResident(
          residentId,
          mutationType: mutationType,
          date: date,
          companyId: companyId,
          departmentId: departmentId,
          teamId: teamId,
          positionId: positionId,
          reason: reason,
          sourceId: sourceId,
          reportsToResidentId: reportsToResidentId,
          careerLevel: careerLevel,
        ) ??
        OrganizationMutationResult.failure(
            <String>['resident_runtime_missing']);
  }

  OrganizationMutationResult resignResidentOrganization(
    String residentId, {
    String date = '',
    String reason = '',
    String sourceId = '',
  }) {
    return _residentRuntimeManager?.resignResident(
          residentId,
          date: date,
          reason: reason,
          sourceId: sourceId,
        ) ??
        OrganizationMutationResult.failure(
            <String>['resident_runtime_missing']);
  }

  List<RecruitmentNeed> getDepartmentRecruitmentNeeds() {
    return _residentRuntimeManager?.getDepartmentRecruitmentNeeds() ??
        const <RecruitmentNeed>[];
  }

  List<PromotionCandidate> getPromotionCandidates({
    String departmentId = '',
    String teamId = '',
  }) {
    return _residentRuntimeManager?.getPromotionCandidates(
          departmentId: departmentId,
          teamId: teamId,
        ) ??
        const <PromotionCandidate>[];
  }

  List<ResidentProfile> getDepartmentManagers(String departmentId) {
    return _residentRuntimeManager?.getDepartmentManagers(departmentId) ??
        const <ResidentProfile>[];
  }

  List<ResidentProfile> getTeamLeaders(String teamId) {
    return _residentRuntimeManager?.getTeamLeaders(teamId) ??
        const <ResidentProfile>[];
  }

  void bindInteractiveRuntimes({
    RelationshipRuntimeManager? relationshipRuntimeManager,
    DynamicEventRuntimeManager? dynamicEventRuntimeManager,
    DailySimulationManager? dailySimulationManager,
    InventoryManagerView? inventoryManager,
    InventoryConfig? inventoryConfig,
  }) {
    _relationshipRuntimeManager =
        relationshipRuntimeManager ?? _relationshipRuntimeManager;
    _dynamicEventRuntimeManager =
        dynamicEventRuntimeManager ?? _dynamicEventRuntimeManager;
    _dailySimulationManager = dailySimulationManager ?? _dailySimulationManager;
    _inventoryManager = inventoryManager ?? _inventoryManager;
    _inventoryConfig = inventoryConfig ?? _inventoryConfig;
  }

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

  CareerState getCareerState() {
    return _worldSaveManager?.careerState ?? CareerState.initial();
  }

  CareerPromotionCheck getPromotionRequirements() {
    final save = _worldSaveManager;
    if (save == null) {
      return CareerState.initial().checkPromotion(
        maxRelationshipRank: _maxPlayerRelationshipRank(),
      );
    }
    return save.getPromotionRequirements(
      maxRelationshipRank: _maxPlayerRelationshipRank(),
      unlockedAchievementIds: const <String>{},
    );
  }

  PlayerSkillState getSkillState(String skillId) {
    return _worldSaveManager?.getSkillState(skillId) ??
        PlayerSkillState.initial(skillId);
  }

  FriendshipState getFriendshipState(String residentId) {
    return _worldSaveManager?.getFriendshipState(
          residentId,
          relationship: _residentRelationshipEngine.getRelationship(residentId),
        ) ??
        FriendshipState.initial(residentId);
  }

  Map<String, PlayerSkillState> getSkillSummary() {
    return _worldSaveManager?.playerSkillStates ??
        CareerState.initial().skillSummary;
  }

  CareerFeedback? getLatestCareerFeedback() {
    return _worldSaveManager?.latestCareerFeedback;
  }

  InteractiveOfficeSnapshot getInteractiveOfficeSnapshot({
    String playerLocation = 'office',
    int residentLimit = 100,
    int historyLimit = 30,
  }) {
    final officeState = getLivingOfficeState();
    final playerInfluence = getPlayerInfluenceContext();
    final save = _worldSaveManager;
    final runtime = _residentRuntimeManager;
    final residents = runtime == null
        ? const <ResidentOfficeView>[]
        : _residentConfig.residents
            .where((resident) => resident.enabled)
            .map((resident) {
              final state = runtime.getResidentCurrentState(resident.id);
              final location = runtime.getResidentLocationContext(resident.id);
              final personality =
                  runtime.getResidentPersonalityContext(resident.id);
              final relationship =
                  _residentRelationshipEngine.getRelationship(resident.id);
              final friendship = getFriendshipState(resident.id);
              return ResidentOfficeView.fromRuntime(
                resident: resident,
                state: state,
                locationName: location.displayName,
                relationshipLevel: relationship.relationshipLevel,
                friendship: friendship,
                personality: personality,
                availableActions: _availableSocialInteractions(
                  getResidentContext(resident.id),
                  friendship,
                ),
                recentInteraction: _recentInteractionFor(resident.id),
              );
            })
            .take(residentLimit)
            .toList(growable: false);
    final details = residents
        .map((resident) => getResidentDetailViewModel(resident.id))
        .toList(growable: false);
    final nearby = residents
        .where((resident) =>
            resident.locationId == playerLocation ||
            resident.locationId == 'office' ||
            resident.locationId == 'pantry')
        .take(8)
        .toList(growable: false);
    final groups = (save?.activeGroups ?? const <OfficeGroup>[])
        .map(_groupView)
        .toList(growable: false);
    final activeEvents = _dynamicEventRuntimeManager
            ?.getActiveEvents()
            .map(_eventView)
            .toList(growable: false) ??
        const <OfficeEventView>[];
    final availableEvents = _dynamicEventRuntimeManager
            ?.getAvailableEvents()
            .take(4)
            .map(_eventView)
            .toList(growable: false) ??
        const <OfficeEventView>[];
    final stories = residents
        .expand((resident) => getResidentContext(resident.id)
            .availableStories
            .take(2)
            .map((story) => OfficeStoryView(
                  id: story.id,
                  title: story.title,
                  summary: story.summary,
                  residentId: resident.id,
                  publicHint: _storyPublicHint(resident, story),
                )))
        .take(12)
        .toList(growable: false);
    final rumors = _rumorRuntimeManager
            ?.getActiveRumors()
            .take(12)
            .map((rumor) => OfficeRumorView(
                  id: rumor.id,
                  title: rumor.title,
                  status: 'spreading',
                  tags: rumor.allTags.take(6).toList(growable: false),
                ))
            .toList(growable: false) ??
        const <OfficeRumorView>[];
    final dailySummary = Map<String, Object?>.from(save?.dailySimulationState ??
        _dailySimulationManager?.getTodayWorldSummary()?.toJson() ??
        const <String, Object?>{});
    dailySummary.putIfAbsent('officeMood', () => officeState.officeMood);
    dailySummary.putIfAbsent(
      'activityLevel',
      () => officeState.activityLevel,
    );
    dailySummary.putIfAbsent('todayMessage', () => '今天办公室也在慢慢发生一点变化。');
    return InteractiveOfficeSnapshot(
      date: officeState.date,
      timeOfDay: officeState.timeOfDay,
      officeState: officeState,
      playerInfluence: playerInfluence,
      playerCareer: getCareerState(),
      playerSkills: getSkillSummary(),
      playerReputation: playerInfluence.reputation,
      currentEvents: <OfficeEventView>[...activeEvents, ...availableEvents]
          .fold<Map<String, OfficeEventView>>(
            <String, OfficeEventView>{},
            (items, event) => items..putIfAbsent(event.id, () => event),
          )
          .values
          .toList(growable: false),
      activeGroups: groups,
      availableResidents: residents,
      nearbyResidents: nearby,
      availableActions: _hubActions(
        hasResidents: residents.isNotEmpty,
        hasGroups: groups.isNotEmpty,
        hasEvents: activeEvents.isNotEmpty || availableEvents.isNotEmpty,
      ),
      residentDetails: details,
      dailySummary: dailySummary,
      recentStories: stories,
      recentRumors: rumors,
      recentAchievements: playerInfluence.recentAchievements,
      recentChanges: <String>{
        ...officeState.importantChanges,
        ...playerInfluence.recentEvents.take(6),
      }.toList(growable: false),
      officeWorldHistory:
          (save?.officeWorldHistory ?? const <OfficeWorldHistoryEntry>[])
              .take(historyLimit)
              .map((entry) => OfficeHistoryView(
                    date: entry.date,
                    mood: entry.dominantMood,
                    summary: <String>[
                      if (entry.importantGroups.isNotEmpty)
                        '群体活动 ${entry.importantGroups.length}',
                      if (entry.importantStories.isNotEmpty)
                        '故事 ${entry.importantStories.length}',
                      if (entry.importantRumors.isNotEmpty)
                        '传闻 ${entry.importantRumors.length}',
                      if (entry.importantEvents.isNotEmpty)
                        '事件 ${entry.importantEvents.length}',
                    ].join(' · '),
                    playerImpact: entry.tags
                        .where((tag) => tag.contains('player'))
                        .take(3)
                        .join(' · '),
                  ))
              .toList(growable: false),
    );
  }

  ResidentDetailViewModel getResidentDetailViewModel(String residentId) {
    if (residentId.isEmpty) return ResidentDetailViewModel.empty('');
    final context = getResidentContext(residentId);
    if (!context.resident.enabled && context.resident.name == residentId) {
      return ResidentDetailViewModel.empty(residentId);
    }
    final relationshipRuntime = _relationshipRuntimeManager;
    final runtimeOptions =
        relationshipRuntime?.getAvailableInteractions(residentId) ??
            const <SocialInteractionOption>[];
    final optionById = <String, SocialInteractionOption>{
      for (final option in runtimeOptions) option.id: option,
    };
    final shareFishOptions = _shareFishOptions(context);
    final interactions =
        _detailInteractions(context, optionById, shareFishOptions);
    final available =
        interactions.where((item) => item.available).toList(growable: false);
    final blocked =
        interactions.where((item) => !item.available).toList(growable: false);
    final cooldowns = _detailCooldowns(context.friendship);
    final recentInteractions = _recentInteractionViews(residentId, limit: 10);
    final recentMemories = _recentMemoryViews(context, limit: 10);
    final stories = context.availableStories
        .take(8)
        .map((story) => OfficeStoryView(
              id: story.id,
              title: story.title,
              summary: story.summary,
              residentId: residentId,
              publicHint: _storyPublicHint(
                ResidentOfficeView.fromRuntime(
                  resident: context.resident,
                  state: context.life,
                  locationName: context.location.displayName,
                  relationshipLevel: context.relationship.relationshipLevel,
                  friendship: context.friendship,
                  personality: context.personality,
                  availableActions: _availableSocialInteractions(
                    context,
                    context.friendship,
                  ),
                  recentInteraction: _recentInteractionFor(residentId),
                ),
                story,
              ),
            ))
        .toList(growable: false);
    final rumors = _rumorRuntimeManager
            ?.getRumorsForResident(residentId)
            .take(8)
            .map((rumor) => OfficeRumorView(
                  id: rumor.id,
                  title: rumor.title,
                  status: context.friendship.trust >= 10 ? '愿意聊' : '需要更高信任',
                  tags: rumor.allTags.take(6).toList(growable: false),
                ))
            .toList(growable: false) ??
        const <OfficeRumorView>[];
    final events = _dynamicEventRuntimeManager
            ?.getAvailableEvents()
            .where((event) =>
                event.conditions.residentId.isEmpty ||
                event.conditions.residentId.contains(residentId))
            .take(6)
            .map(_eventView)
            .toList(growable: false) ??
        const <OfficeEventView>[];
    return ResidentDetailViewModel(
      residentId: residentId,
      name: context.resident.name,
      nickname: _rawString(context.resident, 'nickname', context.resident.name),
      gender: _rawString(context.resident, 'gender', '未知'),
      age: _rawString(context.resident, 'age', ''),
      job: _rawString(context.resident, 'job', context.resident.type),
      description: _rawString(context.resident, 'description', '这位居民还保持着一点神秘。'),
      avatarAsset: _rawString(context.resident, 'avatarAsset', ''),
      currentLocation: context.location.displayName,
      currentActivity: context.life.activity,
      currentMood: context.life.mood,
      schedulePhase: context.life.schedulePhase,
      isWorking: context.life.isWorking,
      isOnBreak: context.life.isOnBreak,
      isOvertime: context.life.isOvertime,
      isWeekend: context.life.isWeekend,
      nextLocation: context.life.nextLocation,
      nextActivity: context.life.nextActivity,
      nextChangeTime: context.life.nextChangeTime,
      scheduleReason: _statusReasonFor(context),
      careerLevel: context.career.careerLevel,
      careerLevelName: context.career.displayLevel,
      employmentStatus: context.career.employmentStatus,
      hireDate: context.career.hireDate,
      salaryLevel: context.career.salaryLevel,
      officeEconomyLines: _officeEconomyLinesFor(context),
      performanceScore: context.career.performanceScore,
      capabilityScore: context.career.capabilityScore,
      promotionHistory: context.career.promotionHistory,
      careerTags: context.career.tags.take(10).toList(growable: false),
      personalityTraits: context.personality.traits,
      dominantPersonality: context.personality.dominantTrait,
      personalitySummary: _personalitySummary(context.personality),
      friendshipStage: context.friendship.stage,
      friendshipScore: context.friendship.score,
      trust: context.friendship.trust,
      familiarity: context.friendship.familiarity,
      relationshipTags: context.friendship.relationshipTags.take(10).toList(),
      relationshipTrend: _relationshipTrend(context.friendship),
      sharedTopics: context.friendship.sharedTopics.take(10).toList(),
      sharedMemories: context.friendship.sharedMemories.take(10).toList(),
      recentMemories: recentMemories,
      recentInteractions: recentInteractions,
      recentStories: stories,
      recentRumors: rumors,
      recentEvents: events,
      currentCooldowns: cooldowns,
      shareFishOptions: shareFishOptions,
      availableInteractions: available,
      blockedInteractions: blocked,
      visibleProfileFields: _visibleProfileFields(context),
      privateProfileFields: _privateProfileFields(context),
      storyHints: stories.map((story) => story.publicHint).take(6).toList(),
      recommendedActions: available
          .take(4)
          .map((action) => OfficeActionView(
                id: action.id,
                label: action.label,
                targetType: 'resident',
                targetId: residentId,
              ))
          .toList(growable: false),
      conflictState: context.friendship.conflictState,
      active: context.life.found,
      lastUpdatedAt: WorldClockManager.systemNow().toIso8601String(),
    );
  }

  List<String> _officeEconomyLinesFor(ResidentContext context) {
    final state = getOfficeEconomyState();
    final departmentId = context.organization.departmentId;
    final departmentBudget = state.departmentBudgets[departmentId];
    return <String>[
      '公司预算：${state.companyBudget}',
      if (departmentBudget != null) '部门预算：$departmentBudget',
      if (state.lastSettlementId.isNotEmpty) '最近结算：${state.lastSettlementId}',
      if (state.budgetWarnings.isNotEmpty)
        '预算提醒：${state.budgetWarnings.take(2).join(' / ')}',
    ];
  }

  PlayerActionResult submitPlayerAction(PlayerActionRequest request) {
    final duplicate = _isDuplicatePlayerAction(request);
    if (duplicate) {
      return PlayerActionResult.blocked(
        request: request,
        reason: 'duplicate_request',
        message: '这个动作已经处理过了，先看看世界的反馈吧。',
      );
    }
    switch (request.actionType) {
      case 'talk':
      case 'short_talk':
      case 'invite_coffee':
      case 'help_work':
      case 'join_break':
      case 'comfort':
      case 'share_rumor':
      case 'ask_about_rumor':
      case 'verify_rumor':
      case 'share_fish':
      case 'remember_preference':
      case 'apologize':
      case 'resolve_conflict':
      case 'observe':
      case 'start_story':
        return _submitResidentAction(request);
      case 'join_group':
      case 'observe_group':
      case 'talk_in_group':
      case 'help_group':
      case 'leave_group':
        return _submitGroupAction(request);
      case 'participate':
      case 'help':
      case 'resolve':
      case 'report':
      case 'ignore':
        return _submitEventAction(request);
      case 'promote_career':
        return _submitPromotionAction(request);
      default:
        return PlayerActionResult.blocked(
          request: request,
          reason: 'unsupported_action',
          message: '这个行动入口还没有准备好。',
        );
    }
  }

  bool _isDuplicatePlayerAction(PlayerActionRequest request) {
    if (request.actionId.isEmpty) return false;
    return _worldSaveManager?.hasProcessedOfficeEvent(
          'player_action:${request.actionId}',
        ) ??
        false;
  }

  void _markPlayerActionProcessed(PlayerActionRequest request) {
    if (request.actionId.isEmpty) return;
    _worldSaveManager?.markOfficeEventProcessed(
      'player_action:${request.actionId}',
    );
  }

  int _currentWorldDay() {
    final manager = _worldSaveManager;
    if (manager == null) return 0;
    return manager.lastSave?.worldCalendar.dayCount ?? 0;
  }

  PlayerActionResult _submitResidentAction(PlayerActionRequest request) {
    if (request.targetResidentId.isEmpty) {
      return PlayerActionResult.blocked(
        request: request,
        reason: 'missing_resident',
        message: '还没有选中要互动的居民。',
      );
    }
    final context = getResidentContext(request.targetResidentId);
    final allowed = <String>{
      ...context.location.availableActivities,
      ..._availableSocialInteractions(context, context.friendship),
      'talk',
      'short_talk',
      'observe',
      'start_story',
      'verify_rumor',
    };
    final selectedFishId = request.metadata['fishId']?.toString() ?? '';
    if (request.actionType == 'share_fish' && selectedFishId.isEmpty) {
      return PlayerActionResult.blocked(
        request: request,
        reason: '当前没有选择可分享的鱼获。',
        message: '分享鱼获需要先从背包选择一条鱼。',
      );
    }
    if (!allowed.contains(request.actionType)) {
      return PlayerActionResult.blocked(
        request: request,
        reason: 'action_unavailable',
        message: '现在不太适合这样互动。',
      );
    }
    if (request.actionType == 'share_fish') {
      return _submitShareFishAction(request, context);
    }
    final beforeFriendship = context.friendship;
    final beforeInfluence = getPlayerInfluenceContext();
    final contentFeedback = _dialogueRuntimeManager?.getInteractionFeedback(
      request.targetResidentId,
      request.actionType,
    );
    final interaction = interactWithResident(request.targetResidentId);
    _applyRumorInteractionContent(request, context);
    final afterInfluence = getPlayerInfluenceContext();
    _worldSaveManager?.recordPlayerAction(
      RecentPlayerAction(
        id: request.actionId,
        type: _interactiveActionType(request.actionType),
        sourceId: request.targetResidentId,
        description: request.actionType,
        createdAt: request.timestamp.isEmpty
            ? WorldClockManager.systemNow().toIso8601String()
            : request.timestamp,
        day: _currentWorldDay(),
        weight: request.actionType == 'help_work' ||
                request.actionType == 'comfort' ||
                request.actionType == 'start_story'
            ? 3
            : 1,
        tags: <String>[
          'interactive_office',
          'resident_action',
          request.actionType,
          request.targetResidentId,
        ],
      ),
    );
    _markPlayerActionProcessed(request);
    _refreshPlayerInfluence();
    final afterFriendship = getFriendshipState(request.targetResidentId);
    final friendshipChanges = <String>[
      if (afterFriendship.score != beforeFriendship.score)
        '友情 ${beforeFriendship.score} -> ${afterFriendship.score}',
      if (afterFriendship.trust != beforeFriendship.trust)
        '信任 ${beforeFriendship.trust} -> ${afterFriendship.trust}',
      if (afterFriendship.familiarity != beforeFriendship.familiarity)
        '熟悉 ${beforeFriendship.familiarity} -> ${afterFriendship.familiarity}',
      if (afterFriendship.stage != beforeFriendship.stage)
        '阶段 ${beforeFriendship.stage} -> ${afterFriendship.stage}',
    ];
    return PlayerActionResult(
      success: true,
      actionId: request.actionId,
      actionType: request.actionType,
      message: contentFeedback?.response.ifEmpty(contentFeedback.text) ??
          _residentActionMessage(request.actionType, context.resident.name),
      dialogue: interaction.dialogue,
      storyTriggered: interaction.story,
      friendshipChanges: friendshipChanges,
      skillChanges: interaction.skillGains.entries
          .map((entry) =>
              '${InteractiveOfficeLabels.skill(entry.key)} +${entry.value}')
          .toList(growable: false),
      officeInfluenceChanges: _influenceDelta(beforeInfluence, afterInfluence),
      reputationChanges: _reputationDelta(beforeInfluence, afterInfluence),
      worldStateChanges: interaction.tags.take(6).toList(growable: false),
      memoryChanges: interaction.memoryChanged
          ? const <String>['共同记忆已更新。']
          : const <String>[],
      cooldownChanges: _cooldownResultChanges(afterFriendship),
      resultGroups: <String, List<String>>{
        'positive': <String>[
          if (friendshipChanges.isNotEmpty) '居民关系有了轻微变化。',
          if (interaction.skillGains.isNotEmpty) '玩家能力获得一点成长。',
          if (interaction.story != null) '触发了一个居民故事。',
        ],
        'neutral': <String>[
          if (contentFeedback != null) contentFeedback.text,
          '居民回应：${interaction.dialogue.text}',
          if (interaction.friendshipChangeReason.isNotEmpty)
            interaction.friendshipChangeReason,
        ],
        'blocked': const <String>[],
      },
      positiveChanges: <String>[
        if (friendshipChanges.isNotEmpty) '居民关系有了轻微变化。',
        if (interaction.skillGains.isNotEmpty) '玩家能力获得一点成长。',
        if (interaction.story != null) '触发了一个居民故事。',
      ],
      neutralChanges: <String>[
        if (contentFeedback != null) contentFeedback.text,
        '居民回应：${interaction.dialogue.text}',
        if (interaction.friendshipChangeReason.isNotEmpty)
          interaction.friendshipChangeReason,
      ],
      recommendedNextActions: _recommendedAfterResidentAction(interaction),
      timestamp: WorldClockManager.systemNow().toIso8601String(),
    );
  }

  PlayerActionResult _submitShareFishAction(
    PlayerActionRequest request,
    ResidentContext context,
  ) {
    final inventory = _inventoryManager;
    final config = _inventoryConfig;
    final fishId = request.metadata['fishId']?.toString() ?? '';
    if (inventory == null || config == null) {
      return PlayerActionResult.blocked(
        request: request,
        reason: 'inventory_unavailable',
        message: '背包还没有准备好，稍后再和居民聊鱼吧。',
      );
    }
    final option = _shareFishOptions(context).firstWhere(
      (item) => item.fishId == fishId,
      orElse: () => FishShareOptionView(
        fishId: fishId,
        name: fishId,
        nickname: fishId,
        rarity: 'common',
        weightLabel: '重量待记录',
        quantity: 0,
        sharable: false,
        residentPreference: '',
        preferenceScore: 0,
        alreadySharedToday: false,
        dailyLimitReached: false,
        unavailableReason: '背包里没有这条鱼。',
      ),
    );
    if (!option.available) {
      return PlayerActionResult.blocked(
        request: request,
        reason: option.unavailableReason.ifEmpty('这条鱼现在不适合分享。'),
        message: option.unavailableReason.ifEmpty('这条鱼现在不适合分享。'),
      );
    }
    final day = _currentWorldDay();
    final dailyKey = _shareFishDailyKey(
      day: day,
      residentId: context.resident.id,
      fishId: fishId,
    );
    if (_worldSaveManager?.hasProcessedOfficeEvent(dailyKey) == true) {
      return PlayerActionResult.blocked(
        request: request,
        reason: '今天已经分享过这条鱼。',
        message: '今天已经和这位居民聊过这条鱼了。',
      );
    }
    final beforeFriendship = context.friendship;
    final beforeInfluence = getPlayerInfluenceContext();
    final removed = inventory.removeOne(fishId);
    if (!removed) {
      return PlayerActionResult.blocked(
        request: request,
        reason: '背包里没有可分享的鱼获。',
        message: '背包里没有可分享的鱼获。',
      );
    }
    final preferenceBonus = option.preferenceScore >= 100 ? 2 : 0;
    _worldSaveManager?.recordFriendshipChange(
      residentId: context.resident.id,
      sourceType: 'share_fish',
      sourceId: dailyKey,
      scoreDelta: 3 + preferenceBonus,
      trustDelta: 1 + preferenceBonus,
      familiarityDelta: 2,
      reason: '分享鱼获让彼此多了一个轻松话题',
      tags: <String>[
        'share_fish',
        fishId,
        'topic:fish',
        if (option.preferenceScore >= 100) 'favorite_fish',
      ],
      relationship:
          _residentRelationshipEngine.getRelationship(context.resident.id),
    );
    final skillGains = _worldSaveManager?.recordSkillExperienceBatch(
          sourceType: 'share_fish',
          sourceId: dailyKey,
          skills: const <String, int>{'communication': 2, 'fishing': 1},
          reason: '用鱼获和居民自然聊天',
        ) ??
        const <String, int>{};
    _residentMemoryEngine.recordInteraction(
      context.resident.id,
      'share_fish',
      tags: <String>[
        fishId,
        'topic:fish',
        if (option.preferenceScore >= 100) 'favorite_fish',
      ],
    );
    _worldSaveManager?.recordPlayerAction(
      RecentPlayerAction(
        id: request.actionId,
        type: 'fishing',
        sourceId: fishId,
        description: '和${context.resident.name}分享了${option.name}',
        createdAt: request.timestamp.isEmpty
            ? WorldClockManager.systemNow().toIso8601String()
            : request.timestamp,
        day: day,
        weight: option.preferenceScore >= 100 ? 3 : 2,
        tags: <String>[
          'interactive_office',
          'resident_action',
          'share_fish',
          context.resident.id,
          fishId,
        ],
      ),
    );
    _markPlayerActionProcessed(request);
    _worldSaveManager?.markOfficeEventProcessed(dailyKey);
    _refreshPlayerInfluence();
    final afterFriendship = getFriendshipState(context.resident.id);
    final afterInfluence = getPlayerInfluenceContext();
    return PlayerActionResult(
      success: true,
      actionId: request.actionId,
      actionType: request.actionType,
      message: option.preferenceScore >= 100
          ? '${context.resident.name}很喜欢你分享的${option.name}。'
          : '你把${option.name}当成今天的小话题，和${context.resident.name}聊了一会儿。',
      friendshipChanges: <String>[
        if (afterFriendship.score != beforeFriendship.score)
          '友情 ${beforeFriendship.score} -> ${afterFriendship.score}',
        if (afterFriendship.trust != beforeFriendship.trust)
          '信任 ${beforeFriendship.trust} -> ${afterFriendship.trust}',
        if (afterFriendship.familiarity != beforeFriendship.familiarity)
          '熟悉 ${beforeFriendship.familiarity} -> ${afterFriendship.familiarity}',
      ],
      skillChanges: skillGains.entries
          .map((entry) =>
              '${InteractiveOfficeLabels.skill(entry.key)} +${entry.value}')
          .toList(growable: false),
      inventoryChanges: <String>[
        '${option.name} -1',
        '背包剩余 ${option.quantity - 1}'
      ],
      officeInfluenceChanges: _influenceDelta(beforeInfluence, afterInfluence),
      reputationChanges: _reputationDelta(beforeInfluence, afterInfluence),
      memoryChanges: const <String>['这次鱼获分享已被居民记住。'],
      resultGroups: <String, List<String>>{
        'positive': <String>[
          '鱼获变成了一个轻松话题。',
          if (option.preferenceScore >= 100) '你记住了对方喜欢的鱼。',
        ],
        'neutral': <String>[
          option.residentPreference,
          '背包已扣除 1 条鱼获。',
        ],
        'blocked': const <String>[],
      },
      positiveChanges: <String>[
        '鱼获变成了一个轻松话题。',
        if (option.preferenceScore >= 100) '对方很喜欢这条鱼。',
      ],
      neutralChanges: <String>[option.residentPreference],
      recommendedNextActions: const <String>['看看居民记忆', '稍后再聊别的话题'],
      timestamp: WorldClockManager.systemNow().toIso8601String(),
    );
  }

  PlayerActionResult _submitGroupAction(PlayerActionRequest request) {
    final groupId = request.targetGroupId;
    final relationshipRuntime = _relationshipRuntimeManager;
    if (groupId.isEmpty || relationshipRuntime == null) {
      return PlayerActionResult.blocked(
        request: request,
        reason: 'group_unavailable',
        message: '现在没有可以参与的群体活动。',
      );
    }
    final group = _worldSaveManager?.activeGroups.firstWhere(
      (item) => item.groupId == groupId,
      orElse: () => const OfficeGroup(
        groupId: '',
        locationId: '',
        members: <String>[],
        leaderId: '',
        topic: '',
        mood: 'calm',
        activity: '',
        startTime: '',
        expectedEndTime: '',
        createdReason: '',
        importance: 0,
        tags: <String>[],
      ),
    );
    if (group == null || !group.isValid) {
      return PlayerActionResult.blocked(
        request: request,
        reason: 'group_not_found',
        message: '这个群体活动已经结束了。',
      );
    }
    final mutate = request.actionType != 'observe_group' &&
        request.actionType != 'leave_group';
    final beforeInfluence = getPlayerInfluenceContext();
    final changed = mutate
        ? relationshipRuntime.applyOfficeGroupInteraction(
            groupId,
            sourceType: 'interactive_${request.actionType}',
          )
        : false;
    _worldSaveManager?.recordPlayerAction(
      RecentPlayerAction(
        id: request.actionId,
        type: mutate ? 'meeting' : 'idle',
        sourceId: groupId,
        description: request.actionType,
        createdAt: request.timestamp.isEmpty
            ? WorldClockManager.systemNow().toIso8601String()
            : request.timestamp,
        day: _currentWorldDay(),
        weight: mutate ? 3 : 1,
        tags: <String>['interactive_office', 'office_group', group.activity],
      ),
    );
    _markPlayerActionProcessed(request);
    _refreshPlayerInfluence();
    final afterInfluence = getPlayerInfluenceContext();
    return PlayerActionResult(
      success: true,
      actionId: request.actionId,
      actionType: request.actionType,
      message: mutate ? '你参与了${group.topic}。' : '你安静地观察了${group.topic}。',
      friendshipChanges: changed ? <String>['群体成员关系小幅推进。'] : const <String>[],
      skillChanges:
          mutate ? const <String>['沟通 +4', '观察 +2'] : const <String>['观察 +1'],
      officeInfluenceChanges: _influenceDelta(beforeInfluence, afterInfluence),
      positiveChanges:
          changed ? const <String>['办公室社交氛围轻轻变热闹了。'] : const <String>[],
      neutralChanges: <String>[
        '地点：${group.locationId}',
        '成员：${group.members.length} 人'
      ],
      recommendedNextActions: const <String>['看看今日摘要', '和附近居民聊聊'],
      timestamp: WorldClockManager.systemNow().toIso8601String(),
    );
  }

  PlayerActionResult _submitEventAction(PlayerActionRequest request) {
    final dynamicRuntime = _dynamicEventRuntimeManager;
    if (dynamicRuntime == null) {
      return PlayerActionResult.blocked(
        request: request,
        reason: 'event_runtime_unavailable',
        message: '办公室事件系统还没有准备好。',
      );
    }
    final eventId = request.targetEventId.isNotEmpty
        ? request.targetEventId
        : _firstAvailableEventId(dynamicRuntime);
    if (eventId.isEmpty) {
      return PlayerActionResult.blocked(
        request: request,
        reason: 'no_event',
        message: '现在办公室很安静，没有需要响应的事件。',
      );
    }
    final beforeInfluence = getPlayerInfluenceContext();
    final active =
        dynamicRuntime.getActiveEvents().any((event) => event.id == eventId);
    final triggered = active ? null : dynamicRuntime.triggerEvent(eventId);
    final resolved = dynamicRuntime.resolveEvent(eventId, request.actionType);
    final event =
        resolved?.event ?? _findAvailableEvent(dynamicRuntime, eventId);
    _worldSaveManager?.recordPlayerAction(
      RecentPlayerAction(
        id: request.actionId,
        type: 'helping',
        sourceId: eventId,
        description: request.actionType,
        createdAt: request.timestamp.isEmpty
            ? WorldClockManager.systemNow().toIso8601String()
            : request.timestamp,
        day: _currentWorldDay(),
        weight: 4,
        tags: <String>['interactive_office', 'dynamic_event', eventId],
      ),
    );
    _markPlayerActionProcessed(request);
    _refreshPlayerInfluence();
    final afterInfluence = getPlayerInfluenceContext();
    return PlayerActionResult(
      success: triggered != null || resolved != null || active,
      actionId: request.actionId,
      actionType: request.actionType,
      message: resolved == null ? '你注意到了这个办公室事件。' : '你回应了办公室事件。',
      eventTriggered: event,
      questChanges: resolved?.questChanged == true
          ? const <String>['任务进度已同步']
          : const <String>[],
      achievementChanges: resolved?.achievementChanged == true
          ? const <String>['成就进度已同步']
          : const <String>[],
      friendshipChanges: resolved?.relationshipChanged == true
          ? const <String>['关系产生轻微变化']
          : const <String>[],
      officeInfluenceChanges: _influenceDelta(beforeInfluence, afterInfluence),
      reputationChanges: _reputationDelta(beforeInfluence, afterInfluence),
      positiveChanges: const <String>['事件结果已交给现有 Runtime 结算。'],
      neutralChanges: <String>[
        event?.title.isNotEmpty == true ? event!.title : eventId
      ],
      recommendedNextActions: const <String>['查看办公室评价', '看看居民对白是否变化'],
      timestamp: WorldClockManager.systemNow().toIso8601String(),
    );
  }

  PlayerActionResult _submitPromotionAction(PlayerActionRequest request) {
    final before = getCareerState();
    final promotion = promoteCareer();
    _markPlayerActionProcessed(request);
    if (!promotion.success) {
      return PlayerActionResult.blocked(
        request: request,
        reason: promotion.missingRequirements.join(','),
        message: '现在还不到晋升的时候。',
      );
    }
    _refreshPlayerInfluence();
    return PlayerActionResult(
      success: true,
      actionId: request.actionId,
      actionType: request.actionType,
      message: '职位从 ${before.jobTitle} 变成了 ${promotion.newTitle}。',
      careerChanges: <String>[
        '${promotion.previousLevel} -> ${promotion.newLevel}',
        if (promotion.reward > 0) '晋升奖励 ${promotion.reward}',
      ],
      positiveChanges: const <String>['职业状态已由 Runtime 校验并更新。'],
      recommendedNextActions: const <String>['查看职业反馈', '看看办公室评价变化'],
      timestamp: promotion.timestamp,
    );
  }

  String _firstAvailableEventId(DynamicEventRuntimeManager runtime) {
    final available = runtime.getAvailableEvents();
    return available.isEmpty ? '' : available.first.id;
  }

  DynamicEventEntry? _findAvailableEvent(
    DynamicEventRuntimeManager runtime,
    String id,
  ) {
    for (final event in runtime.getAvailableEvents()) {
      if (event.id == id) return event;
    }
    for (final event in runtime.getActiveEvents()) {
      if (event.id == id) return event;
    }
    return null;
  }

  void _refreshPlayerInfluence() {
    final influence = buildPlayerInfluenceContext(
      livingOfficeState: getLivingOfficeState(),
      activeRumors:
          _rumorRuntimeManager?.getActiveRumors() ?? const <Object?>[],
      activeEvents:
          _dynamicEventRuntimeManager?.getActiveEvents() ?? const <Object?>[],
    );
    _worldSaveManager?.setPlayerInfluenceContext(influence);
  }

  OfficeGroupView _groupView(OfficeGroup group) {
    return OfficeGroupView(
      group: group,
      memberNames: group.members
          .map((id) => _residentConfig.findResident(id).name)
          .where((name) => name.isNotEmpty)
          .toList(growable: false),
      canJoin: group.isValid,
      joinCondition: group.isValid ? '可以轻轻加入，不会打断大家。' : '活动已经结束。',
      possibleImpact: _groupImpact(group),
    );
  }

  OfficeEventView _eventView(DynamicEventEntry event) {
    final firstLine = event.dialog.isEmpty ? '' : event.dialog.first.text;
    return OfficeEventView(
      id: event.id,
      title: event.title.isEmpty ? event.id : event.title,
      summary: firstLine.isEmpty ? event.category : firstLine,
      locationId: event.conditions.location.isEmpty
          ? ''
          : event.conditions.location.first,
      residentIds: event.conditions.residentId.take(6).toList(growable: false),
      importance: event.priority.clamp(0, 10).toInt(),
      availableActions: event.choices.isEmpty
          ? const <String>['participate', 'observe', 'ignore']
          : event.choices.map((choice) => choice.id).toList(growable: false),
      possibleImpact: '可能影响关系、传闻、任务或办公室氛围。',
    );
  }

  List<OfficeActionView> _hubActions({
    required bool hasResidents,
    required bool hasGroups,
    required bool hasEvents,
  }) {
    return <OfficeActionView>[
      OfficeActionView(
        id: 'view_residents',
        label: '查看附近居民',
        targetType: 'resident',
        available: hasResidents,
        reason: hasResidents ? '' : '现在没有可互动居民。',
      ),
      OfficeActionView(
        id: 'view_groups',
        label: '查看群体活动',
        targetType: 'group',
        available: hasGroups,
        reason: hasGroups ? '' : '现在办公室暂时没有群体活动。',
      ),
      OfficeActionView(
        id: 'view_events',
        label: '查看办公室事件',
        targetType: 'event',
        available: hasEvents,
        reason: hasEvents ? '' : '当前没有需要响应的办公室事件。',
      ),
      const OfficeActionView(
        id: 'view_career',
        label: '查看职业与技能',
        targetType: 'career',
      ),
      const OfficeActionView(
        id: 'view_reputation',
        label: '查看办公室评价',
        targetType: 'player_influence',
      ),
      const OfficeActionView(
        id: 'view_summary',
        label: '查看今日摘要',
        targetType: 'summary',
      ),
      const OfficeActionView(
        id: 'view_history',
        label: '查看世界历史',
        targetType: 'history',
      ),
    ];
  }

  String _recentInteractionFor(String residentId) {
    final history = _worldSaveManager?.interactionHistory ?? const [];
    for (final item in history.reversed) {
      if (item.residentId == residentId) {
        return item.tags.isEmpty
            ? item.createdAt
            : item.tags.take(3).join(' / ');
      }
    }
    return '还没有最近互动。';
  }

  String _storyPublicHint(
    ResidentOfficeView resident,
    ResidentStoryEntry story,
  ) {
    if (story.tags.contains('hidden')) return '需要更多线索。';
    final conditions = story.conditions;
    if (conditions.minimumFriendshipStage.isNotEmpty &&
        friendshipStageRank(resident.friendshipStage) <
            friendshipStageRank(conditions.minimumFriendshipStage)) {
      return '你们似乎还不够熟悉。';
    }
    if (conditions.friendshipScoreMin > resident.friendshipScore) {
      return '先和居民多聊几次，这段故事会更自然。';
    }
    if (conditions.minimumTrust > resident.trust) {
      return '你们之间还需要更多信任，才能聊到这个话题。';
    }
    if (conditions.requiredLocation.isNotEmpty ||
        conditions.residentLocation.isNotEmpty) {
      return '也许在合适的地点再来找对方。';
    }
    if (conditions.timeOfDay.isNotEmpty && conditions.timeOfDay != 'any') {
      return '换个时间，也许这件小事会自然发生。';
    }
    if (conditions.weather.isNotEmpty && conditions.weather != 'any') {
      return '这件事可能和今天的天气有关。';
    }
    if (conditions.festival.isNotEmpty && conditions.festival != 'any') {
      return '等节日气氛到了，故事会更容易出现。';
    }
    if (conditions.rumorTags.isNotEmpty) {
      return '这件事可能与最近的传闻有关。';
    }
    if (conditions.requiredStories.isNotEmpty ||
        conditions.finishedStories.isNotEmpty) {
      return '需要先遇见另一段故事。';
    }
    if (resident.friendshipScore < 5) return '先和居民熟悉一点。';
    return '当前条件看起来合适。';
  }

  void _applyRumorInteractionContent(
    PlayerActionRequest request,
    ResidentContext context,
  ) {
    if (request.actionType != 'share_rumor' &&
        request.actionType != 'ask_about_rumor' &&
        request.actionType != 'verify_rumor') {
      return;
    }
    final rumorRuntime = _rumorRuntimeManager;
    if (rumorRuntime == null) return;
    final residentRumors = rumorRuntime.getRumorsForResident(
      context.resident.id,
    );
    final fallbackRumorId =
        residentRumors.isEmpty ? '' : residentRumors.first.id;
    final rumorId = request.metadata['rumorId']?.toString() ?? fallbackRumorId;
    if (rumorId.isEmpty) return;
    rumorRuntime.addRumor(rumorId);
    _residentMemoryEngine.recordInteraction(
      context.resident.id,
      request.actionType,
      tags: <String>[
        request.actionType,
        'rumor:$rumorId',
        'topic:rumor',
        if (request.actionType == 'verify_rumor') 'rumor_verified',
      ],
    );
  }

  String _groupImpact(OfficeGroup group) {
    if (group.activity.contains('meeting') ||
        group.activity.contains('review')) {
      return '可能提升管理、信任和职业反馈。';
    }
    if (group.activity.contains('coffee') || group.topic.contains('coffee')) {
      return '可能提升熟悉度和沟通。';
    }
    if (group.activity.contains('rumor')) {
      return '可能改变传闻热度。';
    }
    return '可能轻微影响友情、技能和办公室氛围。';
  }

  String _interactiveActionType(String actionType) {
    switch (actionType) {
      case 'help_work':
      case 'comfort':
      case 'resolve_conflict':
        return 'helping';
      case 'share_rumor':
      case 'ask_about_rumor':
        return 'talking';
      case 'share_fish':
        return 'fishing';
      case 'observe':
        return 'idle';
      default:
        return 'talking';
    }
  }

  String _residentActionMessage(String actionType, String residentName) {
    final label = InteractiveOfficeLabels.action(actionType);
    return '$label：你和$residentName有了一次办公室里的小互动。';
  }

  List<String> _influenceDelta(
    PlayerInfluenceContext before,
    PlayerInfluenceContext after,
  ) {
    final changes = <String>[];
    void add(String label, int a, int b) {
      if (a != b) changes.add('$label $a -> $b');
    }

    add('办公室信任', before.officeInfluence.officeTrust,
        after.officeInfluence.officeTrust);
    add('办公室知名度', before.officeInfluence.officeVisibility,
        after.officeInfluence.officeVisibility);
    add('社交影响', before.officeInfluence.socialInfluence,
        after.officeInfluence.socialInfluence);
    add('故事影响', before.officeInfluence.storyInfluence,
        after.officeInfluence.storyInfluence);
    return changes;
  }

  List<String> _reputationDelta(
    PlayerInfluenceContext before,
    PlayerInfluenceContext after,
  ) {
    final beforeSet = before.reputation.toSet();
    return after.reputation
        .where((item) => !beforeSet.contains(item))
        .map((item) => InteractiveOfficeLabels.reputation(item))
        .toList(growable: false);
  }

  List<String> _recommendedAfterResidentAction(InteractionResult result) {
    return <String>[
      if (result.story != null) '查看最近故事',
      if (result.friendshipChanged) '查看居民详情',
      if (result.skillGains.isNotEmpty) '查看技能反馈',
      '看看今日办公室摘要',
    ].take(4).toList(growable: false);
  }

  List<ResidentInteractionView> _detailInteractions(
    ResidentContext context,
    Map<String, SocialInteractionOption> availableOptions,
    List<FishShareOptionView> shareFishOptions,
  ) {
    const ids = <String>[
      'talk',
      'short_talk',
      'invite_coffee',
      'help_work',
      'join_break',
      'comfort',
      'share_rumor',
      'ask_about_rumor',
      'verify_rumor',
      'share_fish',
      'remember_preference',
      'apologize',
      'resolve_conflict',
      'observe',
      'start_story',
    ];
    final runtimeAvailable = _availableSocialInteractions(
      context,
      context.friendship,
    ).toSet();
    final hasShareableFish = shareFishOptions.any((item) => item.available);
    return ids.map((id) {
      final option = availableOptions[id];
      final hasCooldown = context.friendship.cooldowns.containsKey(id);
      final fishBlocked = id == 'share_fish' && !hasShareableFish;
      final available = !fishBlocked &&
          (option?.available == true ||
              (runtimeAvailable.contains(id) && !hasCooldown));
      final reason = available
          ? (option?.reason ?? '当前状态适合这个互动。')
          : _blockedInteractionReason(
              id,
              context,
              optionReason: option?.reason ?? '',
            );
      return ResidentInteractionView(
        id: id,
        label: option?.label ?? InteractiveOfficeLabels.action(id),
        description: InteractiveOfficeLabels.actionDescription(id),
        available: available,
        reason: reason,
        cooldownText: hasCooldown
            ? _cooldownText(context.friendship.cooldowns[id]!)
            : '可用',
        impactHint: InteractiveOfficeLabels.actionImpact(id),
        tags: option?.tags ?? const <String>[],
      );
    }).toList(growable: false);
  }

  List<FishShareOptionView> _shareFishOptions(ResidentContext context) {
    final inventory = _inventoryManager;
    final config = _inventoryConfig;
    if (inventory == null || config == null) {
      return const <FishShareOptionView>[];
    }
    final favoriteFish =
        _rawString(context.resident, 'favoriteFish', '').toLowerCase();
    final day = _currentWorldDay();
    final options = inventory.entries
        .where((entry) => entry.quantity > 0 && entry.category == 'fish')
        .map((entry) {
      final catalog = config.itemById(entry.itemId);
      final name =
          catalog?.name.isNotEmpty == true ? catalog!.name : entry.name;
      final rarity =
          catalog?.rarity.isNotEmpty == true ? catalog!.rarity : entry.rarity;
      final nickname = _stringAttr(catalog?.attributes['nickname'], name);
      final weight = _weightLabel(catalog?.attributes);
      final prefers = favoriteFish.isNotEmpty &&
          (favoriteFish == entry.itemId.toLowerCase() ||
              favoriteFish == name.toLowerCase() ||
              name.toLowerCase().contains(favoriteFish));
      final dailyKey = _shareFishDailyKey(
          day: day, residentId: context.resident.id, fishId: entry.itemId);
      final alreadyShared =
          _worldSaveManager?.hasProcessedOfficeEvent(dailyKey) ?? false;
      final sharable = entry.quantity > 0 && entry.category == 'fish';
      return FishShareOptionView(
        fishId: entry.itemId,
        name: name,
        nickname: nickname,
        rarity: rarity,
        weightLabel: weight,
        quantity: entry.quantity,
        sharable: sharable,
        residentPreference: prefers ? '正好是对方喜欢聊的鱼' : '可以当作今天的小话题',
        preferenceScore: prefers ? 100 : _rarityPreferenceScore(rarity),
        alreadySharedToday: alreadyShared,
        dailyLimitReached: alreadyShared,
        unavailableReason: !sharable
            ? '这件物品不能分享。'
            : alreadyShared
                ? '今天已经和这位居民聊过这条鱼了。'
                : '',
      );
    }).toList(growable: true);
    options.sort((a, b) {
      final preference = b.preferenceScore.compareTo(a.preferenceScore);
      if (preference != 0) return preference;
      final rarity = _rarityPreferenceScore(b.rarity)
          .compareTo(_rarityPreferenceScore(a.rarity));
      if (rarity != 0) return rarity;
      return a.name.compareTo(b.name);
    });
    return options;
  }

  String _shareFishDailyKey({
    required int day,
    required String residentId,
    required String fishId,
  }) {
    return 'share_fish_daily:$day:$residentId:$fishId';
  }

  String _stringAttr(Object? value, String fallback) {
    final text = value?.toString() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _weightLabel(Map<String, dynamic>? attributes) {
    if (attributes == null || attributes.isEmpty) return '重量待记录';
    final exact = attributes['weight']?.toString() ?? '';
    if (exact.isNotEmpty) return exact;
    final min = attributes['minWeight'] ?? attributes['weightMin'];
    final max = attributes['maxWeight'] ?? attributes['weightMax'];
    if (min != null && max != null) return '$min-$max kg';
    final range = attributes['weightRange']?.toString() ?? '';
    return range.isEmpty ? '重量待记录' : range;
  }

  int _rarityPreferenceScore(String rarity) {
    return const <String, int>{
          'mythic': 60,
          'mythical': 60,
          'legendary': 50,
          'legend': 50,
          'epic': 40,
          'rare': 30,
          'uncommon': 20,
          'common': 10,
        }[rarity] ??
        10;
  }

  String _blockedInteractionReason(
    String id,
    ResidentContext context, {
    String optionReason = '',
  }) {
    if (context.friendship.cooldowns.containsKey(id)) {
      return '互动仍在冷却，${_cooldownText(context.friendship.cooldowns[id]!)}。';
    }
    if (id == 'share_fish') return '需要先从背包选择当前可分享的鱼获。';
    if (id == 'ask_about_rumor' || id == 'share_rumor') {
      final hasRumor = _rumorRuntimeManager?.getRumorTags().isNotEmpty ?? false;
      if (!hasRumor) return '当前没有可讨论的传闻。';
      if (friendshipStageRank(context.friendship.stage) <
          friendshipStageRank('familiar')) {
        return '需要更高友情，居民才愿意聊传闻。';
      }
    }
    if (id == 'invite_coffee' &&
        !(context.location.tags.contains('break') ||
            context.location.locationId == 'coffee_shop' ||
            context.location.locationId == 'pantry')) {
      return '当前地点不适合请咖啡。';
    }
    if (id == 'help_work' &&
        !(context.location.tags.contains('work') ||
            context.life.activity.contains('work'))) {
      return '居民现在不在工作场景。';
    }
    if (id == 'comfort' && !context.currentMoodIsHelpful) {
      return '当前心情不需要安慰，先轻轻聊聊就好。';
    }
    if ((id == 'apologize' || id == 'resolve_conflict') &&
        !context.friendship.hasRecentConflict) {
      return '目前没有需要修复的误会。';
    }
    if (id == 'start_story' && context.availableStories.isEmpty) {
      return '当前没有可触发的居民故事。';
    }
    return optionReason.isEmpty ? '当前时间、地点或关系阶段还不合适。' : optionReason;
  }

  List<InteractionCooldownView> _detailCooldowns(FriendshipState friendship) {
    final day = _currentWorldDay();
    return friendship.cooldowns.entries
        .where((entry) => entry.value > day)
        .map((entry) => InteractionCooldownView(
              interactionId: entry.key,
              label: InteractiveOfficeLabels.action(entry.key),
              remainingText: _cooldownText(entry.value),
              reason: '慢一点，关系需要一点间隔。',
            ))
        .toList(growable: false);
  }

  String _cooldownText(int untilDay) {
    final remaining = (untilDay - _currentWorldDay()).clamp(0, 999).toInt();
    if (remaining <= 0) return '可用';
    if (remaining == 1) return '剩余 1 天';
    return '剩余 $remaining 天';
  }

  List<String> _cooldownResultChanges(FriendshipState friendship) {
    return _detailCooldowns(friendship)
        .map((item) => '${item.label}：${item.remainingText}')
        .take(4)
        .toList(growable: false);
  }

  List<ResidentMemoryView> _recentInteractionViews(
    String residentId, {
    int limit = 10,
  }) {
    final history = _worldSaveManager?.interactionHistory ?? const [];
    return history
        .where((item) => item.residentId == residentId)
        .take(limit)
        .map((item) => ResidentMemoryView(
              time: item.createdAt,
              type: item.storyId.isNotEmpty ? 'story' : 'interaction',
              summary: item.storyId.isNotEmpty
                  ? '发生了故事 ${item.storyId}'
                  : item.tags.take(3).join(' / '),
              source: item.dialogueId.isNotEmpty ? item.dialogueId : 'world',
              important: item.storyId.isNotEmpty ||
                  item.tags.any((tag) => tag.contains('important')),
            ))
        .toList(growable: false);
  }

  List<ResidentMemoryView> _recentMemoryViews(
    ResidentContext context, {
    int limit = 10,
  }) {
    final memory = context.memory;
    final items = <ResidentMemoryView>[
      if (memory.firstMeetTime.isNotEmpty)
        ResidentMemoryView(
          time: memory.firstMeetTime,
          type: 'first_meet',
          summary: '第一次在第二世界遇见。',
          source: 'resident_memory',
          important: true,
        ),
      if (memory.lastMeetTime.isNotEmpty)
        ResidentMemoryView(
          time: memory.lastMeetTime,
          type: memory.lastInteraction.isEmpty
              ? 'recent_meet'
              : memory.lastInteraction,
          summary:
              memory.meetCount <= 1 ? '刚刚开始认识。' : '已经见过 ${memory.meetCount} 次。',
          source: 'resident_memory',
          important: memory.meetCount == 1,
        ),
      ...context.friendship.sharedMemories
          .take(8)
          .map((tag) => ResidentMemoryView(
                time: context.friendship.lastInteractionTime,
                type: 'shared_memory',
                summary: InteractiveOfficeLabels.relationshipTag(tag),
                source: 'friendship',
                important: tag.contains('story') || tag.contains('important'),
              )),
    ];
    return items.take(limit).toList(growable: false);
  }

  Map<String, String> _visibleProfileFields(ResidentContext context) {
    final rank = friendshipStageRank(context.friendship.stage);
    final fields = <String, String>{
      '姓名': context.resident.name,
      '昵称': _rawString(context.resident, 'nickname', context.resident.name),
      '职业': _rawString(context.resident, 'job', context.resident.type),
      '当前地点': context.location.displayName,
      '当前行为': context.life.activity,
      '当前心情': InteractiveOfficeLabels.mood(context.life.mood),
      '性格摘要': _personalitySummary(context.personality),
    };
    if (rank >= friendshipStageRank('acquaintance')) {
      fields['一般兴趣'] = _rawString(context.resident, 'favoriteFood', '慢慢了解中');
      fields['最近话题'] =
          context.friendship.sharedTopics.take(3).join(' / ').ifEmpty('暂无共同话题');
    }
    if (rank >= friendshipStageRank('familiar')) {
      fields['共同记忆'] = context.friendship.sharedMemories
          .take(3)
          .map(InteractiveOfficeLabels.relationshipTag)
          .join(' / ')
          .ifEmpty('还没有特别记忆');
    }
    if (rank >= friendshipStageRank('friend')) {
      fields['私人偏好'] = _rawString(context.resident, 'favoriteFish', '还没告诉你');
      fields['信任摘要'] = _trustLabel(context.friendship.trust);
    }
    if (rank >= friendshipStageRank('close_friend')) {
      fields['重要关系变化'] =
          InteractiveOfficeLabels.trend(_relationshipTrend(context.friendship));
      fields['特殊互动'] = context.friendship.relationshipTags
          .where((tag) => tag.contains('story') || tag.contains('memory'))
          .take(4)
          .join(' / ')
          .ifEmpty('等待新的故事');
    }
    return fields;
  }

  Map<String, String> _privateProfileFields(ResidentContext context) {
    final hidden = <String, String>{};
    final rank = friendshipStageRank(context.friendship.stage);
    if (rank < friendshipStageRank('friend')) {
      hidden['私人偏好'] = '成为朋友后会慢慢了解。';
    }
    if (rank < friendshipStageRank('close_friend')) {
      hidden['深层记忆'] = '关系更深之后才会自然出现。';
    }
    if (rank < friendshipStageRank('trusted_friend')) {
      hidden['特殊互动'] = '需要更高信任。';
    }
    return hidden;
  }

  String _rawString(
    ResidentProfile resident,
    String key,
    String fallback,
  ) {
    final value = resident.raw[key]?.toString() ?? '';
    return value.isEmpty ? fallback : value;
  }

  String _personalitySummary(ResidentPersonalityContext personality) {
    final traits = personality.traits
        .take(4)
        .map(InteractiveOfficeLabels.personality)
        .toList(growable: false);
    return traits.isEmpty ? '性格温和，还需要慢慢了解。' : traits.join('，');
  }

  String _relationshipTrend(FriendshipState friendship) {
    if (friendship.lastPositiveInteractionTime.isNotEmpty &&
        friendship.lastConflictTime.isEmpty) {
      return 'up';
    }
    if (friendship.conflictState == 'conflict' ||
        friendship.conflictState == 'minor_tension') {
      return 'down';
    }
    return 'stable';
  }

  String _trustLabel(int trust) {
    if (trust >= 70) return '很高';
    if (trust >= 40) return '较高';
    if (trust >= 15) return '正在建立';
    return '还需要时间';
  }

  String _statusReasonFor(ResidentContext context) {
    if (context.life.scheduleReason.isNotEmpty) {
      return InteractiveOfficeLabels.statusReason(context.life.scheduleReason);
    }
    if (context.life.isWeekend) {
      return InteractiveOfficeLabels.statusReason('schedule_weekend');
    }
    if (context.life.isOvertime) {
      return InteractiveOfficeLabels.statusReason('schedule_overtime');
    }
    if (context.life.isOnBreak) {
      return InteractiveOfficeLabels.statusReason('schedule_break');
    }
    if (context.life.isWorking) {
      return InteractiveOfficeLabels.statusReason('schedule_working');
    }
    return '按当前世界状态自然行动';
  }

  LivingOfficeState getLivingOfficeState() {
    final saveState = _worldSaveManager?.livingOfficeState;
    if (saveState != null && !saveState.isEmpty) return saveState;
    final runtime = _residentRuntimeManager;
    return buildLivingOfficeState(
      worldDate: _dateLabel(),
      timeOfDay: _timeOfDayLabel(),
      weekday: 0,
      season: '',
      weatherContext: _weatherRuntimeManager?.getCurrentWeather(),
      festivalContext: _festivalRuntimeManager?.getTodayFestival(),
      activeRumors:
          _rumorRuntimeManager?.getActiveRumors() ?? const <Object?>[],
      residentSnapshot:
          runtime?.getAllResidentCurrentStates() ?? const <String, Object?>{},
      activeGroups: _worldSaveManager?.activeGroups ?? const <OfficeGroup>[],
      activeStories: const <Object?>[],
      activeEvents: const <Object?>[],
      careerContext: _worldSaveManager?.careerState,
      skillSummary: _worldSaveManager?.playerSkillStates ?? const {},
      questSummary: const <String, Object?>{},
      achievementSummary: const <Object?>[],
      previousState: saveState,
    );
  }

  LivingOfficeState buildLivingOfficeState({
    required String worldDate,
    required String timeOfDay,
    required int weekday,
    required String season,
    required Object? weatherContext,
    required Object? festivalContext,
    required List<Object?> activeRumors,
    required Map<String, Object?> residentSnapshot,
    required List<OfficeGroup> activeGroups,
    required List<Object?> activeStories,
    required List<Object?> activeEvents,
    required Object? careerContext,
    required Map<String, Object?> skillSummary,
    required Map<String, Object?> questSummary,
    required List<Object?> achievementSummary,
    LivingOfficeState? previousState,
  }) {
    final residents = residentSnapshot.values
        .whereType<ResidentCurrentState>()
        .where((state) => state.found)
        .toList(growable: false);
    final activeCount = residents.length;
    final workingCount = residents.where((state) => state.isWorking).length;
    final breakCount = residents.where((state) => state.isOnBreak).length;
    final overtimeCount = residents.where((state) => state.isOvertime).length;
    final outdoorCount =
        residents.where((state) => _isOutdoorLocation(state.location)).length;
    final negativeMoodCount = residents
        .where((state) => _negativeMoodSet.contains(state.mood))
        .length;
    final happyMoodCount = residents
        .where((state) => _positiveMoodSet.contains(state.mood))
        .length;
    final conflictCount = _worldSaveManager?.conflictStates.length ?? 0;
    final hasFestival = _objectId(festivalContext).isNotEmpty ||
        _objectName(festivalContext).isNotEmpty;
    final weatherTags = _objectTags(weatherContext);
    final weatherSignal = <String>[
      _objectId(weatherContext),
      _objectName(weatherContext),
      _objectType(weatherContext),
      ...weatherTags,
    ].join('|').toLowerCase();
    final severeWeather = weatherSignal.contains('storm') ||
        weatherSignal.contains('rain') ||
        weatherSignal.contains('typhoon') ||
        weatherSignal.contains('thunder') ||
        weatherSignal.contains('暴雨') ||
        weatherSignal.contains('雷') ||
        weatherSignal.contains('雨');
    final isNight = timeOfDay == 'night' || timeOfDay == 'late_night';
    final groupCount = activeGroups.length;
    final activityLevel = _boundedLevel(
      12 +
          workingCount * 2 +
          breakCount +
          groupCount * 6 +
          activeEvents.length * 4 +
          activeStories.length * 3 +
          (hasFestival ? 12 : 0) +
          (severeWeather ? -6 : 0) +
          (isNight ? -24 : 0),
    );
    final productivityLevel = _boundedLevel(
      18 +
          workingCount * 3 +
          groupCount * 2 +
          overtimeCount * 2 -
          negativeMoodCount * 4 -
          conflictCount * 8 +
          (hasFestival ? -4 : 0) +
          (overtimeCount > activeCount / 3 ? -8 : 0),
    );
    final socialLevel = _boundedLevel(
      10 +
          breakCount * 3 +
          groupCount * 9 +
          activeRumors.length * 2 +
          happyMoodCount * 2 +
          (hasFestival ? 15 : 0) -
          conflictCount * 3,
    );
    final targetTension = _boundedLevel(
      8 +
          conflictCount * 12 +
          negativeMoodCount * 4 +
          overtimeCount * 4 +
          activeEvents.length * 2 +
          (severeWeather ? 10 : 0) -
          (hasFestival ? 4 : 0),
    );
    final tensionLevel = previousState == null || previousState.isEmpty
        ? targetTension
        : _smooth(previousState.tensionLevel, targetTension, maxStep: 12);
    final officeMood = _dominantOfficeMood(
      timeOfDay: timeOfDay,
      hasFestival: hasFestival,
      severeWeather: severeWeather,
      socialLevel: socialLevel,
      activityLevel: activityLevel,
      productivityLevel: productivityLevel,
      tensionLevel: tensionLevel,
      activeResidentCount: activeCount,
    );
    final locationCounts = <String, int>{};
    for (final state in residents) {
      if (state.location.isEmpty) continue;
      locationCounts[state.location] =
          (locationCounts[state.location] ?? 0) + 1;
    }
    final popularLocations = _topKeys(locationCounts, 5);
    final topicCounts = <String, int>{};
    for (final group in activeGroups) {
      if (group.topic.isNotEmpty) {
        topicCounts[group.topic] = (topicCounts[group.topic] ?? 0) + 1;
      }
      for (final tag in group.tags) {
        if (tag.startsWith('topic:')) {
          topicCounts[tag.replaceFirst('topic:', '')] =
              (topicCounts[tag.replaceFirst('topic:', '')] ?? 0) + 1;
        }
      }
    }
    final popularTopics = _topKeys(topicCounts, 5);
    final changes = <String>[
      if (officeMood != previousState?.officeMood) 'office_mood:$officeMood',
      if (hasFestival) 'festival:${_objectName(festivalContext)}',
      if (severeWeather) 'weather:${_objectName(weatherContext)}',
      if (groupCount > 0) 'groups:$groupCount',
      if (conflictCount > 0) 'conflicts:$conflictCount',
      if (activeEvents.isNotEmpty) 'events:${activeEvents.length}',
    ];
    final tags = <String>{
      officeMood,
      'activity:${_levelTag(activityLevel)}',
      'productivity:${_levelTag(productivityLevel)}',
      'social:${_levelTag(socialLevel)}',
      'tension:${_levelTag(tensionLevel)}',
      if (hasFestival) 'festival',
      if (severeWeather) 'weather_disruption',
      if (groupCount > 0) 'office_group',
      if (breakCount > workingCount / 2) 'break_time',
      if (outdoorCount > activeCount / 4) 'outdoor',
      ...weatherTags.take(4),
    }.where((tag) => tag.isNotEmpty).toList(growable: false);
    return LivingOfficeState(
      date: worldDate,
      timeOfDay: timeOfDay,
      officeMood: officeMood,
      activityLevel: activityLevel,
      productivityLevel: productivityLevel,
      socialLevel: socialLevel,
      tensionLevel: tensionLevel,
      activeResidentCount: activeCount,
      workingResidentCount: workingCount,
      breakResidentCount: breakCount,
      overtimeResidentCount: overtimeCount,
      activeGroupCount: groupCount,
      activeEventCount: activeEvents.length,
      activeStoryCount: activeStories.length,
      popularLocations: popularLocations,
      popularTopics: popularTopics,
      dominantRumors: activeRumors
          .take(5)
          .map(_objectNameOrId)
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      currentFestival: _objectName(festivalContext),
      currentWeather: _objectName(weatherContext),
      importantChanges: changes.take(8).toList(growable: false),
      worldTags: tags,
      lastUpdatedAt: WorldClockManager.systemNow().toIso8601String(),
    );
  }

  OfficeWorldHistoryEntry buildOfficeWorldHistoryEntry(
    LivingOfficeState state,
  ) {
    return OfficeWorldHistoryEntry(
      date: state.date,
      dominantMood: state.officeMood,
      activityLevel: state.activityLevel,
      productivityLevel: state.productivityLevel,
      socialLevel: state.socialLevel,
      tensionLevel: state.tensionLevel,
      importantEvents: state.importantChanges
          .where((item) => item.startsWith('events:'))
          .toList(growable: false),
      importantStories: state.activeStoryCount > 0
          ? <String>['stories:${state.activeStoryCount}']
          : const <String>[],
      importantGroups: state.activeGroupCount > 0
          ? <String>['groups:${state.activeGroupCount}']
          : const <String>[],
      importantRumors: state.dominantRumors,
      importantRelationshipChanges: state.importantChanges
          .where((item) => item.contains('conflict'))
          .toList(
            growable: false,
          ),
      tags: state.worldTags,
      keepForever: state.worldTags.contains('festival'),
    );
  }

  PlayerInfluenceContext getPlayerInfluenceContext() {
    final save = _worldSaveManager;
    if (save == null) return PlayerInfluenceContext.empty();
    final stored = save.playerInfluenceContext;
    if (stored.officeInfluence.overall > 0 ||
        stored.recentActions.isNotEmpty ||
        stored.reputation.isNotEmpty && !stored.hasReputation('quiet')) {
      return stored;
    }
    return buildPlayerInfluenceContext(
      livingOfficeState: getLivingOfficeState(),
    );
  }

  PlayerInfluenceContext buildPlayerInfluenceContext({
    required LivingOfficeState livingOfficeState,
    Map<String, Object?> questSummary = const <String, Object?>{},
    List<Object?> achievementSummary = const <Object?>[],
    List<Object?> activeRumors = const <Object?>[],
    List<Object?> activeEvents = const <Object?>[],
  }) {
    final save = _worldSaveManager;
    if (save == null) return PlayerInfluenceContext.empty();
    final recentActions = _recentPlayerActionsFromSave(save);
    final recentEvents = <String>{
      ...activeEvents.map(_objectNameOrId).where((item) => item.isNotEmpty),
      ...activeRumors.map((item) => 'rumor:${_objectNameOrId(item)}').where(
            (item) => item != 'rumor:',
          ),
      ...save.interactionHistory
          .take(12)
          .expand((record) => record.tags)
          .where((tag) => tag.contains('story') || tag.contains('event')),
    }.toList(growable: false);
    final recentAchievements = achievementSummary
        .map(_objectNameOrId)
        .where((item) => item.isNotEmpty)
        .take(12)
        .toList(growable: false);
    final recentQuestResults = questSummary.entries
        .where((entry) => entry.value.toString().isNotEmpty)
        .map((entry) => '${entry.key}:${entry.value}')
        .take(12)
        .toList(growable: false);
    return PlayerInfluenceContext.fromRuntime(
      careerState: save.careerState,
      skills: save.playerSkillStates,
      friendships: save.friendshipStates,
      recentActions: recentActions,
      recentEvents: recentEvents,
      recentAchievements: recentAchievements,
      recentQuestResults: recentQuestResults,
      officeTags: livingOfficeState.worldTags,
      activityLevel: livingOfficeState.activityLevel,
      socialLevel: livingOfficeState.socialLevel,
      productivityLevel: livingOfficeState.productivityLevel,
      tensionLevel: livingOfficeState.tensionLevel,
      playerLocation: 'office',
      inventorySummary: const <String, int>{},
      fishCollectionSummary: const <String, int>{},
    );
  }

  List<RecentPlayerAction> _recentPlayerActionsFromSave(
    WorldSaveManager save,
  ) {
    final explicit = save.recentPlayerActions;
    final converted = <RecentPlayerAction>[...explicit];
    for (final record in save.interactionHistory.take(20)) {
      final actionType = _playerActionTypeFor(record.tags);
      if (actionType.isEmpty) continue;
      converted.add(
        RecentPlayerAction(
          id: 'interaction_${record.id}',
          type: actionType,
          sourceId: record.storyId.isNotEmpty
              ? record.storyId
              : record.dialogueId.isNotEmpty
                  ? record.dialogueId
                  : record.residentId,
          description: actionType,
          createdAt: record.createdAt,
          day: 0,
          weight: record.tags.contains('story') ? 3 : 1,
          tags: record.tags,
        ),
      );
    }
    final seen = <String>{};
    return converted.where((action) => seen.add(action.id)).take(40).toList(
          growable: false,
        );
  }

  String _playerActionTypeFor(List<String> tags) {
    final normalized = tags.map((tag) => tag.toLowerCase()).toSet();
    if (normalized.any((tag) => tag.contains('fishing'))) return 'fishing';
    if (normalized.any((tag) => tag.contains('help') || tag == 'comfort')) {
      return 'helping';
    }
    if (normalized
        .any((tag) => tag.contains('talk') || tag == 'communication')) {
      return 'talking';
    }
    if (normalized
        .any((tag) => tag.contains('trade') || tag.contains('sell'))) {
      return 'trading';
    }
    if (normalized.any((tag) => tag.contains('quest'))) return 'quest';
    if (normalized.any((tag) => tag.contains('achievement'))) {
      return 'achievement';
    }
    if (normalized.any((tag) => tag.contains('meeting'))) return 'meeting';
    if (normalized.any((tag) => tag.contains('idle'))) return 'idle';
    if (normalized.contains('resident_interaction')) return 'talking';
    return '';
  }

  SkillExperienceRecord? recordSkillExperience({
    required String sourceType,
    required String sourceId,
    required String skillId,
    required int amount,
    String reason = '',
  }) {
    return _worldSaveManager?.recordSkillExperience(
      sourceType: sourceType,
      sourceId: sourceId,
      skillId: skillId,
      amount: amount,
      reason: reason,
    );
  }

  CareerPromotionResult promoteCareer({
    WalletManagerView? wallet,
    TransactionManagerView? transactions,
  }) {
    final save = _worldSaveManager;
    if (save == null) {
      final state = CareerState.initial();
      return CareerPromotionResult(
        success: false,
        previousLevel: state.careerLevel,
        newLevel: state.careerLevel,
        newTitle: state.jobTitle,
        reward: 0,
        missingRequirements: const <String>['world_save_unavailable'],
        performanceScore: state.performanceScore,
        timestamp: '',
      );
    }
    final result = save.promoteCareer(
      maxRelationshipRank: _maxPlayerRelationshipRank(),
    );
    if (result.success && result.reward > 0) {
      wallet?.add(result.reward);
      transactions?.addRecord(
        TransactionRecord(
          id: 'career_${result.previousLevel}_${result.newLevel}_${result.timestamp}',
          type: 'promotion',
          currency: 'fish_coin',
          amount: result.reward,
          itemId: result.newLevel,
          itemName: result.newTitle,
          createdAt: WorldClockManager.systemNow(),
          category: 'reward',
          note: '职位晋升 ${result.previousLevel} -> ${result.newLevel}',
        ),
      );
    }
    return result;
  }

  CareerSalaryPayment? claimDueSalary({
    required int dayCount,
    required int amount,
    required WalletManagerView wallet,
    required TransactionManagerView transactions,
  }) {
    return _worldSaveManager?.paySalaryForCurrentPeriod(
      dayCount: dayCount,
      amount: amount,
      wallet: wallet,
      transactions: transactions,
    );
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
    final location = clock == null && now == null && runtime != null
        ? runtime.getResidentLocationContext(id)
        : LocationContext.fromId(life.location);
    final personality = clock == null && now == null && runtime != null
        ? runtime.getResidentPersonalityContext(id)
        : ResidentPersonalityContext.fromResident(resident);
    final organization = clock == null && now == null && runtime != null
        ? runtime.getResidentOrganizationContext(id)
        : ResidentOrganizationContext.resolve(
            resident.organization,
            organization: getCompanyOrganization(),
          );
    final career = clock == null && now == null && runtime != null
        ? runtime.getResidentCareerStatus(id)
        : resident.career;
    final friendship = getFriendshipState(id);
    final officeGroup = _worldSaveManager?.groupForResident(id);
    return ResidentContext(
      resident: resident,
      life: life,
      location: location,
      organization: organization,
      career: career,
      personality: personality,
      memory: memory,
      relationship: relationship,
      friendship: friendship,
      dialogue: dialogue,
      availableStories: availableStories,
      festival: festival,
      weather: weather,
      rumor: rumor,
      officeGroup: officeGroup,
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
    final officeGroup = context.officeGroup;
    final currentMood = context.life.mood;
    final moodChanged = beforeMood != currentMood;
    final moodChangeReason = _moodChangeReason(afterMemory, currentMood);
    final tags = <String>{
      ...dialogue.tags,
      if (story != null) ...story.tags,
      ...afterMemory.memoryTags,
    }.where((item) => item.isNotEmpty).toList(growable: false);
    final skillGains = _recordResidentInteractionSkills(
      residentId: id,
      memory: afterMemory,
      story: story,
      relationshipChanged: beforeRelationship.relationshipScore !=
          afterRelationship.relationshipScore,
    );
    final beforeFriendship = getFriendshipState(id);
    final friendshipChange = _recordFriendshipForInteraction(
      context: context,
      story: story,
      sourceId: 'resident_${id}_${afterMemory.meetCount}',
      relationship: afterRelationship,
      skillGains: skillGains,
    );
    final afterFriendship = getFriendshipState(id);
    _worldSaveManager?.recordPlayerAction(
      RecentPlayerAction(
        id: 'resident_${id}_${afterMemory.meetCount}',
        type: story == null ? 'talking' : 'helping',
        sourceId: story?.id ?? id,
        description: story == null ? 'resident_interaction' : 'resident_story',
        createdAt: WorldClockManager.systemNow().toIso8601String(),
        day: 0,
        weight: story == null ? 1 : 3,
        tags: tags,
      ),
    );
    final playerInfluence = buildPlayerInfluenceContext(
      livingOfficeState: getLivingOfficeState(),
    );
    _worldSaveManager?.setPlayerInfluenceContext(playerInfluence);
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
      locationId: context.location.locationId,
      locationName: context.location.displayName,
      locationTags: context.location.tags,
      nearbyResidentIds: _nearbyResidentIds(id, context.location.locationId),
      availableInteractions: context.location.availableActivities,
      personalityTags: context.personality.traits,
      interactionPreference: context.personality.socialPreference,
      interactionWillingness: _interactionWillingness(context.personality),
      preferredTopics: _preferredTopics(context.personality),
      avoidedTopics: _avoidedTopics(context.personality),
      playerCareerLevel: getCareerState().careerLevel,
      playerJobTitle: getCareerState().jobTitle,
      recentPromotion: getCareerState().recentCareerChanges.any(
            (item) => item.startsWith('promotion:'),
          ),
      skillSummary: getSkillSummary(),
      skillGains: skillGains,
      latestCareerFeedback: getLatestCareerFeedback(),
      friendshipState: afterFriendship,
      friendshipChanged: friendshipChange != null &&
          (beforeFriendship.score != afterFriendship.score ||
              beforeFriendship.trust != afterFriendship.trust ||
              beforeFriendship.familiarity != afterFriendship.familiarity ||
              beforeFriendship.stage != afterFriendship.stage ||
              beforeFriendship.conflictState != afterFriendship.conflictState),
      friendshipChangeReason: friendshipChange?.reason ?? '',
      friendshipStage: afterFriendship.stage,
      friendshipScore: afterFriendship.score,
      trust: afterFriendship.trust,
      familiarity: afterFriendship.familiarity,
      conflictState: afterFriendship.conflictState,
      availableSocialInteractions: _availableSocialInteractions(
        context,
        afterFriendship,
      ),
      officeGroup: officeGroup,
      officeGroupId: officeGroup?.groupId ?? '',
      officeGroupTopic: officeGroup?.topic ?? '',
      officeGroupActivity: officeGroup?.activity ?? '',
      officeGroupMembers: officeGroup?.members ?? const <String>[],
      playerReputation: playerInfluence.reputation,
      officeInfluence: playerInfluence.officeInfluence,
      recentPlayerActions:
          playerInfluence.recentActions.map((item) => item.type).toList(),
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

  Map<String, int> _recordResidentInteractionSkills({
    required String residentId,
    required ResidentMemoryRecord memory,
    required ResidentStoryEntry? story,
    required bool relationshipChanged,
  }) {
    final save = _worldSaveManager;
    if (save == null) return const <String, int>{};
    final sourceId = 'resident_${residentId}_${memory.meetCount}';
    final skills = <String, int>{
      'communication': relationshipChanged ? 10 : 6,
      'observation': story == null ? 2 : 5,
      if (story?.tags.any((tag) => tag.contains('team')) == true)
        'management': 4,
    };
    return save.recordSkillExperienceBatch(
      sourceType: 'resident_interaction',
      sourceId: sourceId,
      skills: skills,
      reason: '与居民互动后，办公室能力获得一点成长。',
    );
  }

  FriendshipChangeRecord? _recordFriendshipForInteraction({
    required ResidentContext context,
    required ResidentStoryEntry? story,
    required String sourceId,
    required ResidentRelationshipRecord relationship,
    required Map<String, int> skillGains,
  }) {
    final save = _worldSaveManager;
    if (save == null) return null;
    final delta = _friendshipDeltaFor(
      context: context,
      story: story,
      skillGains: skillGains,
    );
    return save.recordFriendshipChange(
      residentId: context.resident.id,
      sourceType: story == null ? 'resident_interaction' : 'resident_story',
      sourceId: story?.id ?? sourceId,
      scoreDelta: delta.scoreDelta,
      trustDelta: delta.trustDelta,
      familiarityDelta: delta.familiarityDelta,
      reason: delta.reason,
      tags: delta.tags,
      relationship: relationship,
    );
  }

  _FriendshipDelta _friendshipDeltaFor({
    required ResidentContext context,
    required ResidentStoryEntry? story,
    required Map<String, int> skillGains,
  }) {
    var score = story == null ? 2 : 4;
    var trust = story == null ? 0 : 2;
    var familiarity = story == null ? 3 : 4;
    final tags = <String>{
      'communication',
      'topic:${context.personality.storyPreference}',
      ...context.location.tags.take(3),
      ...context.personality.traits.take(3),
      if (story != null) 'story',
      if (context.currentMoodIsHelpful) 'comfort',
    };
    if (context.location.tags.contains('break') ||
        context.location.locationId == 'pantry' ||
        context.location.locationId == 'coffee_shop') {
      familiarity += 1;
      tags.add('topic:coffee');
    }
    if (context.location.tags.contains('work')) {
      trust += 1;
      tags.add('work');
    }
    if (context.life.mood == 'grateful') {
      score += 1;
      trust += 1;
    }
    if (context.life.mood == 'angry') {
      score -= 1;
    }
    if (context.personality.hasTrait('kind')) score += 1;
    if (context.personality.hasTrait('cautious') && trust > 0) trust -= 1;
    if ((skillGains['communication'] ?? 0) > 0) score += 1;
    if ((skillGains['observation'] ?? 0) > 0) familiarity += 1;
    if ((skillGains['management'] ?? 0) > 0) trust += 1;
    return _FriendshipDelta(
      scoreDelta: score.clamp(-3, story == null ? 3 : 8).toInt(),
      trustDelta: trust.clamp(0, story == null ? 2 : 6).toInt(),
      familiarityDelta: familiarity.clamp(1, story == null ? 5 : 8).toInt(),
      reason: story == null ? '日常互动让彼此更熟悉。' : '共同经历故事后，友情慢慢推进。',
      tags: tags.where((tag) => tag.isNotEmpty).toList(growable: false),
    );
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

  List<String> _nearbyResidentIds(String residentId, String locationId) {
    final runtime = _residentRuntimeManager;
    if (runtime == null || locationId.isEmpty) return const <String>[];
    return runtime
        .getResidentsAtLocation(locationId)
        .map((resident) => resident.id)
        .where((id) => id != residentId)
        .toList(growable: false);
  }

  String _interactionWillingness(ResidentPersonalityContext personality) {
    if (personality.hasTrait('outgoing') ||
        personality.hasTrait('kind') ||
        personality.hasTrait('playful')) {
      return 'high';
    }
    if (personality.hasTrait('introverted') ||
        personality.hasTrait('cautious')) {
      return 'low';
    }
    return 'medium';
  }

  List<String> _preferredTopics(ResidentPersonalityContext personality) {
    final topics = <String>{};
    if (personality.hasTrait('gossipy')) topics.add('rumor');
    if (personality.hasTrait('serious')) topics.add('work');
    if (personality.hasTrait('kind')) topics.add('help');
    if (personality.hasTrait('competitive')) topics.add('task');
    if (personality.hasTrait('playful')) topics.add('office_humor');
    if (personality.hasTrait('curious')) topics.add('mystery');
    if (topics.isEmpty) topics.add('daily_life');
    return topics.toList(growable: false);
  }

  List<String> _avoidedTopics(ResidentPersonalityContext personality) {
    final topics = <String>[];
    if (personality.hasTrait('introverted')) topics.add('crowd');
    if (personality.hasTrait('cautious')) topics.add('unverified_rumor');
    if (personality.hasTrait('kind')) topics.add('malicious_rumor');
    if (personality.hasTrait('pessimistic')) topics.add('pressure');
    return topics;
  }

  List<String> _availableSocialInteractions(
    ResidentContext context,
    FriendshipState friendship,
  ) {
    final stageRank = friendshipStageRank(friendship.stage);
    final interactions = <String>{
      'talk',
      'short_talk',
      'observe',
      if (stageRank >= friendshipStageRank('acquaintance')) 'share_fish',
      if (stageRank >= friendshipStageRank('familiar')) 'share_rumor',
      if (context.location.tags.contains('break')) 'join_break',
      if (context.location.locationId == 'pantry' ||
          context.location.locationId == 'coffee_shop')
        'invite_coffee',
      if (context.location.tags.contains('work')) 'help_work',
      if (context.currentMoodIsHelpful) 'comfort',
      if (friendship.hasRecentConflict) 'apologize',
      if (friendship.hasRecentConflict) 'resolve_conflict',
      if (context.availableStories.isNotEmpty) 'start_story',
    };
    return interactions
        .where((id) => !friendship.cooldowns.containsKey(id))
        .toList(
          growable: false,
        );
  }

  int _maxPlayerRelationshipRank() {
    var rank = 0;
    for (final resident in _residentConfig.residents) {
      final relationship = _residentRelationshipEngine.getRelationship(
        resident.id,
      );
      final value = _relationshipRank(relationship.relationshipLevel);
      if (value > rank) rank = value;
    }
    return rank;
  }

  int _relationshipRank(String level) {
    switch (level) {
      case 'known':
        return 1;
      case 'friend':
        return 2;
      case 'old_friend':
      case 'close_friend':
        return 3;
      case 'trust':
        return 4;
      case 'family':
      case 'family_reserved':
        return 5;
      default:
        return 0;
    }
  }

  String _dateLabel() {
    final save = _worldSaveManager;
    if (save?.lastSave != null) {
      final calendar = save!.lastSave!.worldCalendar;
      return 'Y${calendar.year}-M${calendar.month}-D${calendar.day}-#${calendar.dayCount}';
    }
    return '';
  }

  String _timeOfDayLabel() {
    final runtime = _residentRuntimeManager;
    if (runtime == null) return '';
    final states = runtime.getAllResidentCurrentStates().values;
    if (states.any((state) => state.schedulePhase == 'lunch')) return 'noon';
    if (states.any((state) => state.schedulePhase == 'evening')) {
      return 'evening';
    }
    return '';
  }

  int _boundedLevel(num value) => value.round().clamp(0, 100).toInt();

  int _smooth(int previous, int target, {required int maxStep}) {
    final delta = target - previous;
    if (delta.abs() <= maxStep) return target;
    return previous + (delta.isNegative ? -maxStep : maxStep);
  }

  String _dominantOfficeMood({
    required String timeOfDay,
    required bool hasFestival,
    required bool severeWeather,
    required int socialLevel,
    required int activityLevel,
    required int productivityLevel,
    required int tensionLevel,
    required int activeResidentCount,
  }) {
    if (hasFestival && tensionLevel < 55) return 'festive';
    if (tensionLevel >= 70) return severeWeather ? 'stormy' : 'tense';
    if (timeOfDay == 'night' || activeResidentCount < 4) return 'quiet';
    if (socialLevel >= 68) return 'social';
    if (activityLevel >= 70 && productivityLevel >= 45) return 'busy';
    if (socialLevel >= 50 && tensionLevel < 40) return 'cheerful';
    if (productivityLevel < 30 && activityLevel < 40) return 'tired';
    return 'calm';
  }

  bool _isOutdoorLocation(String location) {
    return location == 'park' ||
        location == 'seaside' ||
        location == 'sea' ||
        location == 'dock' ||
        location == 'balcony';
  }

  String _levelTag(int value) {
    if (value >= 70) return 'high';
    if (value >= 35) return 'medium';
    return 'low';
  }

  List<String> _topKeys(Map<String, int> counts, int limit) {
    final entries = counts.entries.toList(growable: false)
      ..sort((a, b) {
        final count = b.value.compareTo(a.value);
        if (count != 0) return count;
        return a.key.compareTo(b.key);
      });
    return entries
        .take(limit)
        .map((entry) => entry.key)
        .toList(growable: false);
  }

  String _objectNameOrId(Object? value) {
    final name = _objectName(value);
    if (name.isNotEmpty) return name;
    return _objectId(value);
  }

  String _objectName(Object? value) {
    if (value == null) return '';
    try {
      final dynamic item = value;
      final name = item.name?.toString() ?? '';
      if (name.isNotEmpty) return name;
    } catch (_) {}
    return '';
  }

  String _objectId(Object? value) {
    if (value == null) return '';
    try {
      final dynamic item = value;
      final id = item.id?.toString() ?? '';
      if (id.isNotEmpty) return id;
    } catch (_) {}
    return '';
  }

  String _objectType(Object? value) {
    if (value == null) return '';
    try {
      final dynamic item = value;
      final type = item.type?.toString() ?? '';
      if (type.isNotEmpty) return type;
    } catch (_) {}
    return '';
  }

  List<String> _objectTags(Object? value) {
    if (value == null) return const <String>[];
    try {
      final dynamic item = value;
      final tags = item.tags;
      if (tags is List) {
        return tags.map((tag) => tag.toString()).toList(growable: false);
      }
    } catch (_) {}
    return const <String>[];
  }

  static const Set<String> _negativeMoodSet = <String>{
    'tired',
    'worried',
    'sad',
    'angry',
    'busy',
  };

  static const Set<String> _positiveMoodSet = <String>{
    'happy',
    'curious',
    'excited',
    'grateful',
    'playful',
  };
}

extension _OfficeStringX on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

class ResidentContext {
  const ResidentContext({
    required this.resident,
    required this.life,
    required this.location,
    required this.organization,
    required this.career,
    required this.personality,
    required this.memory,
    required this.relationship,
    required this.friendship,
    required this.dialogue,
    required this.availableStories,
    this.festival,
    this.weather,
    this.rumor,
    this.officeGroup,
  });

  final ResidentProfile resident;
  final ResidentCurrentState life;
  final LocationContext location;
  final ResidentOrganizationContext organization;
  final ResidentCareerStatus career;
  final ResidentPersonalityContext personality;
  final ResidentMemoryRecord memory;
  final ResidentRelationshipRecord relationship;
  final FriendshipState friendship;
  final ResidentDialogueEntry dialogue;
  final List<ResidentStoryEntry> availableStories;
  final FestivalContext? festival;
  final WeatherContext? weather;
  final RumorContext? rumor;
  final OfficeGroup? officeGroup;

  bool get currentMoodIsHelpful =>
      life.mood == 'sad' || life.mood == 'worried' || life.mood == 'lonely';
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
    this.locationId = '',
    this.locationName = '',
    this.locationTags = const <String>[],
    this.nearbyResidentIds = const <String>[],
    this.availableInteractions = const <String>[],
    this.personalityTags = const <String>[],
    this.interactionPreference = '',
    this.interactionWillingness = '',
    this.preferredTopics = const <String>[],
    this.avoidedTopics = const <String>[],
    this.playerCareerLevel = '',
    this.playerJobTitle = '',
    this.recentPromotion = false,
    this.skillSummary = const <String, PlayerSkillState>{},
    this.skillGains = const <String, int>{},
    this.latestCareerFeedback,
    this.friendshipState,
    this.friendshipChanged = false,
    this.friendshipChangeReason = '',
    this.friendshipStage = '',
    this.friendshipScore = 0,
    this.trust = 0,
    this.familiarity = 0,
    this.conflictState = 'none',
    this.availableSocialInteractions = const <String>[],
    this.officeGroup,
    this.officeGroupId = '',
    this.officeGroupTopic = '',
    this.officeGroupActivity = '',
    this.officeGroupMembers = const <String>[],
    this.playerReputation = const <String>[],
    this.officeInfluence,
    this.recentPlayerActions = const <String>[],
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
  final String locationId;
  final String locationName;
  final List<String> locationTags;
  final List<String> nearbyResidentIds;
  final List<String> availableInteractions;
  final List<String> personalityTags;
  final String interactionPreference;
  final String interactionWillingness;
  final List<String> preferredTopics;
  final List<String> avoidedTopics;
  final String playerCareerLevel;
  final String playerJobTitle;
  final bool recentPromotion;
  final Map<String, PlayerSkillState> skillSummary;
  final Map<String, int> skillGains;
  final CareerFeedback? latestCareerFeedback;
  final FriendshipState? friendshipState;
  final bool friendshipChanged;
  final String friendshipChangeReason;
  final String friendshipStage;
  final int friendshipScore;
  final int trust;
  final int familiarity;
  final String conflictState;
  final List<String> availableSocialInteractions;
  final OfficeGroup? officeGroup;
  final String officeGroupId;
  final String officeGroupTopic;
  final String officeGroupActivity;
  final List<String> officeGroupMembers;
  final List<String> playerReputation;
  final PlayerOfficeInfluence? officeInfluence;
  final List<String> recentPlayerActions;
}

class _FriendshipDelta {
  const _FriendshipDelta({
    required this.scoreDelta,
    required this.trustDelta,
    required this.familiarityDelta,
    required this.reason,
    required this.tags,
  });

  final int scoreDelta;
  final int trustDelta;
  final int familiarityDelta;
  final String reason;
  final List<String> tags;
}
