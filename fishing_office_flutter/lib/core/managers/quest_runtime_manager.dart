import 'package:flutter/foundation.dart';

import '../../models/player_influence.dart';
import '../../models/task_config.dart';
import '../../models/world_save_data.dart';
import 'app_managers.dart';
import 'daily_simulation_manager.dart';
import 'dialogue_runtime_manager.dart';
import 'festival_runtime_manager.dart';
import 'fish_runtime_manager.dart';
import 'resident_runtime_manager.dart';
import 'rumor_runtime_manager.dart';
import 'story_runtime_manager.dart';
import 'weather_runtime_manager.dart';
import 'world_clock_manager.dart';
import 'world_save_manager.dart';

class QuestRuntimeManager extends ChangeNotifier {
  QuestRuntimeManager({
    required TaskConfig taskConfig,
    required TaskManagerView taskManager,
    required WorldClockManager worldClockManager,
    required DailySimulationManager dailySimulationManager,
    required ResidentRuntimeManager residentRuntimeManager,
    required DialogueRuntimeManager dialogueRuntimeManager,
    required StoryRuntimeManager storyRuntimeManager,
    required FishRuntimeManager fishRuntimeManager,
    required RumorRuntimeManager rumorRuntimeManager,
    required FestivalRuntimeManager festivalRuntimeManager,
    required WeatherRuntimeManager weatherRuntimeManager,
    required WorldSaveManager worldSaveManager,
  })  : _taskConfig = taskConfig,
        _taskManager = taskManager,
        _worldClockManager = worldClockManager,
        _dailySimulationManager = dailySimulationManager,
        _residentRuntimeManager = residentRuntimeManager,
        _dialogueRuntimeManager = dialogueRuntimeManager,
        _storyRuntimeManager = storyRuntimeManager,
        _fishRuntimeManager = fishRuntimeManager,
        _rumorRuntimeManager = rumorRuntimeManager,
        _festivalRuntimeManager = festivalRuntimeManager,
        _weatherRuntimeManager = weatherRuntimeManager,
        _worldSaveManager = worldSaveManager {
    _restoreState(worldSaveManager.questRuntimeState);
  }

  final TaskConfig _taskConfig;
  final TaskManagerView _taskManager;
  final WorldClockManager _worldClockManager;
  final DailySimulationManager _dailySimulationManager;
  final ResidentRuntimeManager _residentRuntimeManager;
  final DialogueRuntimeManager _dialogueRuntimeManager;
  final StoryRuntimeManager _storyRuntimeManager;
  final FishRuntimeManager _fishRuntimeManager;
  final RumorRuntimeManager _rumorRuntimeManager;
  final FestivalRuntimeManager _festivalRuntimeManager;
  final WeatherRuntimeManager _weatherRuntimeManager;
  final WorldSaveManager _worldSaveManager;

  final Map<String, int> _dailyBaseline = <String, int>{};
  final Set<String> _seenWeatherIds = <String>{};
  final Set<String> _seenFestivalIds = <String>{};
  final Set<String> _seenRumorIds = <String>{};
  final Set<String> _triggeredStoryIds = <String>{};
  final Map<String, int> _worldEventCounts = <String, int>{};
  PlayerInfluenceContext _playerInfluenceContext =
      PlayerInfluenceContext.empty();
  int _residentInteractionCount = 0;
  int? _lastRefreshDay;

  Map<String, int> get cumulativeMetrics =>
      Map<String, int>.unmodifiable(_currentCumulativeMetrics());

  Map<String, int> get dailyMetrics =>
      Map<String, int>.unmodifiable(_currentDailyMetrics());

  int? get lastRefreshDay => _lastRefreshDay;

  List<String> get recommendedQuestTags => <String>{
        ..._playerInfluenceContext.officeTags,
        ..._playerInfluenceContext.reputation.map((item) => 'reputation:$item'),
        if (_playerInfluenceContext.officeInfluence.officeTrust >= 60)
          'help_residents',
        if (_playerInfluenceContext.officeInfluence.officePopularity >= 60)
          'social',
        if (_playerInfluenceContext.officeInfluence.officeVisibility >= 60)
          'office_events',
      }.toList(growable: false);

  void applyPlayerInfluenceContext(PlayerInfluenceContext context) {
    _playerInfluenceContext = context;
    _worldSaveManager.setQuestRuntimeState({
      ..._worldSaveManager.questRuntimeState,
      'recommendedQuestTags': recommendedQuestTags,
      'playerReputation': context.reputation,
      'playerOfficeInfluence': context.officeInfluence.toJson(),
    });
  }

  TaskItemConfig? taskById(String taskId) {
    for (final task in _taskConfig.tasks) {
      if (task.id == taskId) return task;
    }
    return null;
  }

  Future<void> refreshAfterDailySimulation({
    required FishingProvider fishing,
    required InventoryManagerView inventory,
    required CollectionManagerView collection,
    required TransactionManagerView transactions,
  }) async {
    if (!_dailySimulationManager.hasRunToday()) {
      await _dailySimulationManager.runDailySimulation();
    }
    refreshDailyTasks(
      fishing: fishing,
      inventory: inventory,
      collection: collection,
      transactions: transactions,
    );
  }

  void refreshDailyTasks({
    required FishingProvider fishing,
    required InventoryManagerView inventory,
    required CollectionManagerView collection,
    required TransactionManagerView transactions,
  }) {
    _captureWorldContext();
    final cumulative = _currentCumulativeMetrics(
      fishing: fishing,
      inventory: inventory,
      collection: collection,
      transactions: transactions,
    );
    final day = _worldClockManager.today().dayCount;
    if (_lastRefreshDay != day) {
      _lastRefreshDay = day;
      _dailyBaseline
        ..clear()
        ..addAll(cumulative);
    }
    _syncTaskManager(cumulative);
    _persistState();
  }

  void syncFromState({
    required FishingProvider fishing,
    required InventoryManagerView inventory,
    required CollectionManagerView collection,
    required TransactionManagerView transactions,
  }) {
    _captureWorldContext();
    final cumulative = _currentCumulativeMetrics(
      fishing: fishing,
      inventory: inventory,
      collection: collection,
      transactions: transactions,
    );
    if (_lastRefreshDay == null) {
      _lastRefreshDay = _worldClockManager.today().dayCount;
      _dailyBaseline
        ..clear()
        ..addAll(_zeroBaseline(cumulative));
    }
    _syncTaskManager(cumulative);
    _persistState();
  }

  void recordResidentInteraction(String residentId) {
    if (residentId.isEmpty) return;
    _residentInteractionCount += 1;
    final dialogue = _dialogueRuntimeManager.getDialogue(residentId);
    _worldSaveManager.recordSkillExperience(
      sourceType: 'resident_interaction',
      sourceId: residentId,
      skillId: 'communication',
      amount: 8,
      reason: '与居民互动让沟通能力获得成长。',
    );
    _worldSaveManager.recordInteraction(
      residentId: residentId,
      dialogueId: dialogue.id,
      tags: const <String>['quest', 'resident_interaction'],
    );
    _persistState();
    notifyListeners();
  }

  void recordStoryTriggered(String storyId) {
    if (storyId.isEmpty) return;
    _triggeredStoryIds.add(storyId);
    _worldSaveManager.recordSkillExperienceBatch(
      sourceType: 'story_triggered',
      sourceId: storyId,
      skills: const <String, int>{
        'communication': 6,
        'observation': 6,
      },
      reason: '遇见故事后，沟通和观察都多了一点经验。',
    );
    _worldSaveManager.recordInteraction(
      residentId: '',
      dialogueId: '',
      storyId: storyId,
      tags: const <String>['quest', 'story_triggered'],
    );
    _persistState();
    notifyListeners();
  }

  void recordRumorDiscovered(String rumorId) {
    if (rumorId.isEmpty) return;
    _seenRumorIds.add(rumorId);
    _worldSaveManager.recordSkillExperience(
      sourceType: 'rumor_discovered',
      sourceId: rumorId,
      skillId: 'observation',
      amount: 5,
      reason: '发现传闻让观察能力获得成长。',
    );
    _persistState();
    notifyListeners();
  }

  void recordFestivalParticipation(String festivalId) {
    if (festivalId.isEmpty) return;
    _seenFestivalIds.add(festivalId);
    _worldSaveManager.recordSkillExperience(
      sourceType: 'festival_participation',
      sourceId: festivalId,
      skillId: 'observation',
      amount: 4,
      reason: '留意节日变化让观察能力获得成长。',
    );
    _persistState();
    notifyListeners();
  }

  void recordWeatherExperienced(String weatherId) {
    if (weatherId.isEmpty) return;
    _seenWeatherIds.add(weatherId);
    _worldSaveManager.recordSkillExperience(
      sourceType: 'weather_experienced',
      sourceId: weatherId,
      skillId: 'observation',
      amount: 3,
      reason: '观察天气让观察能力获得成长。',
    );
    _persistState();
    notifyListeners();
  }

  void recordWorldEvent(String type, {String id = '', int amount = 1}) {
    if (type.isEmpty || amount == 0) return;
    _worldEventCounts[type] = (_worldEventCounts[type] ?? 0) + amount;
    if (id.isNotEmpty) {
      _worldEventCounts['${type}_$id'] =
          (_worldEventCounts['${type}_$id'] ?? 0) + amount;
    }
    _recordCareerEvent(type, id: id, amount: amount);
    _recordSkillEvent(type, id: id, amount: amount);
    _persistState();
    notifyListeners();
  }

  void recordCareerTaskCompleted(String taskId) {
    if (taskId.isEmpty) return;
    recordWorldEvent('career_task_completed', id: taskId);
  }

  void recordLocationEvent(
    String type,
    String locationId, {
    String residentId = '',
    int amount = 1,
  }) {
    if (locationId.isEmpty) return;
    final normalized =
        _residentRuntimeManager.getLocationContext(locationId).locationId;
    recordWorldEvent(type, id: normalized, amount: amount);
    if (residentId.isNotEmpty) {
      recordWorldEvent('${type}_resident', id: residentId, amount: amount);
    }
  }

  void recordOrganizationEvent(
    String type, {
    required String residentId,
    int amount = 1,
  }) {
    if (residentId.isEmpty) return;
    final organization =
        _residentRuntimeManager.getResidentOrganizationContext(residentId);
    if (!organization.assignment.isAssigned) return;
    recordWorldEvent(type, id: organization.companyId, amount: amount);
    recordWorldEvent('${type}_department',
        id: organization.departmentId, amount: amount);
    recordWorldEvent('${type}_team', id: organization.teamId, amount: amount);
    recordWorldEvent('${type}_position',
        id: organization.positionId, amount: amount);
  }

  bool claimReward({
    required TaskItemConfig task,
    required WalletManagerView wallet,
    required TransactionManagerView transactions,
  }) {
    final success = _taskManager.claimReward(
      task: task,
      wallet: wallet,
      transactions: transactions,
    );
    if (!success) return false;
    final now = WorldClockManager.systemNow().toIso8601String();
    final record = TaskRewardRecord(
      id: 'reward_${WorldClockManager.timestampId()}_${task.id}',
      taskId: task.id,
      taskTitle: task.title,
      fishCoin: task.reward.fishCoin,
      exp: task.reward.exp,
      claimedAt: now,
      tags: <String>['quest_reward', task.category, task.metric],
    );
    _worldSaveManager.recordTaskReward(record);
    if (_isCareerTask(task)) {
      _worldSaveManager.recordCareerProgress(
        sourceId: 'task_claim_${task.id}',
        type: 'career_task',
        experience: (task.reward.exp <= 0 ? 4 : task.reward.exp).clamp(1, 20),
        performanceDelta: 2,
        completedTaskDelta: 1,
      );
      _worldSaveManager.recordSkillExperienceBatch(
        sourceType: 'task_claim',
        sourceId: task.id,
        skills: _skillsForTask(task),
        reason: '完成任务后，对应技能获得成长。',
      );
    }
    _worldSaveManager.recordInteraction(
      residentId: '',
      dialogueId: '',
      storyId: '',
      tags: <String>['quest_reward', task.id],
    );
    _persistState();
    return true;
  }

  List<TaskProgressView> visibleTasks(String categoryId) {
    return _taskManager.visibleTasks(_taskConfig, categoryId);
  }

  void _syncTaskManager(Map<String, int> cumulative) {
    _taskManager.syncFromQuest(
      cumulativeMetrics: cumulative,
      dailyMetrics: _dailyFromCumulative(cumulative),
      dayCount: _worldClockManager.today().dayCount,
      dailyTaskIds: _dailyTaskIds,
    );
    if (kDebugMode) {
      debugPrint(
        'QuestRuntimeManager | day=$_lastRefreshDay cumulative=$cumulative daily=${_dailyFromCumulative(cumulative)}',
      );
    }
    notifyListeners();
  }

  void _captureWorldContext() {
    final weather = _weatherRuntimeManager.getCurrentWeather();
    if (weather != null) _seenWeatherIds.add(weather.id);
    for (final festival in _festivalRuntimeManager.getActiveFestivals()) {
      _seenFestivalIds.add(festival.id);
    }
    for (final rumor in _rumorRuntimeManager.getActiveRumors()) {
      _seenRumorIds.add(rumor.id);
    }
    _triggeredStoryIds.addAll(_storyRuntimeManager.finishedStoryIds);
    _fishRuntimeManager.refresh();
  }

  Map<String, int> _currentCumulativeMetrics({
    FishingProvider? fishing,
    InventoryManagerView? inventory,
    CollectionManagerView? collection,
    TransactionManagerView? transactions,
  }) {
    final taskMetrics = _taskManager.metrics;
    final summary = _dailySimulationManager.getTodayWorldSummary();
    final activeRumors = _rumorRuntimeManager.getActiveRumors();
    final activeFestivals = _festivalRuntimeManager.getActiveFestivals();
    final weather = _weatherRuntimeManager.getCurrentWeather();
    final organizationMetrics = <String, int>{};
    for (final resident in _residentRuntimeManager.residents) {
      if (!resident.enabled) continue;
      final organization = resident.organization;
      final career = resident.career;
      organizationMetrics['company_${organization.companyId}'] =
          (organizationMetrics['company_${organization.companyId}'] ?? 0) + 1;
      organizationMetrics['department_${organization.departmentId}'] =
          (organizationMetrics['department_${organization.departmentId}'] ??
                  0) +
              1;
      organizationMetrics['team_${organization.teamId}'] =
          (organizationMetrics['team_${organization.teamId}'] ?? 0) + 1;
      organizationMetrics['position_${organization.positionId}'] =
          (organizationMetrics['position_${organization.positionId}'] ?? 0) + 1;
      organizationMetrics['career_${career.careerLevel}'] =
          (organizationMetrics['career_${career.careerLevel}'] ?? 0) + 1;
      organizationMetrics['employment_${career.employmentStatus}'] =
          (organizationMetrics['employment_${career.employmentStatus}'] ?? 0) +
              1;
      for (final tag in career.tags) {
        organizationMetrics['career_tag_$tag'] =
            (organizationMetrics['career_tag_$tag'] ?? 0) + 1;
      }
    }
    final recruitmentNeeds =
        _residentRuntimeManager.getDepartmentRecruitmentNeeds();
    final promotionCandidates =
        _residentRuntimeManager.getPromotionCandidates();
    return <String, int>{
      ..._worldEventCounts,
      ...organizationMetrics,
      'recruitment_need_count': recruitmentNeeds.length,
      'promotion_candidate_count': promotionCandidates.length,
      'login_days': _worldClockManager.today().dayCount,
      'consecutive_login': _worldClockManager.today().dayCount,
      'fishing_count': fishing == null
          ? taskMetrics['fishing_count'] ?? 0
          : fishing.fishingEvents
              .where((event) => event.type == 'started')
              .length,
      'sell_count': transactions == null
          ? taskMetrics['sell_count'] ?? 0
          : transactions.records
              .where((record) =>
                  record.type == 'sell_fish' || record.type == 'sell_item')
              .length,
      'release_count': inventory == null
          ? taskMetrics['release_count'] ?? 0
          : inventory.releaseCount,
      'fish_obtained_count': collection == null
          ? taskMetrics['fish_obtained_count'] ?? 0
          : collection.records.fold<int>(
              0,
              (sum, record) => sum + record.catchCount,
            ),
      'inventory_count': inventory == null
          ? taskMetrics['inventory_count'] ?? 0
          : inventory.entries.fold<int>(
              0,
              (sum, entry) => sum + entry.quantity,
            ),
      'collection_count': collection == null
          ? taskMetrics['collection_count'] ?? 0
          : collection.records.length,
      'resident_interaction_count': _residentInteractionCount +
          _worldSaveManager.interactionHistory.length,
      'resident_count': _residentRuntimeManager.residents.length,
      'story_triggered_count': <String>{
        ..._triggeredStoryIds,
        ..._storyRuntimeManager.finishedStoryIds
      }.length,
      'rumor_discovered_count': <String>{
        ..._seenRumorIds,
        ...activeRumors.map((rumor) => rumor.id),
      }.length,
      'festival_participation_count': <String>{
        ..._seenFestivalIds,
        ...activeFestivals.map((festival) => festival.id),
      }.length,
      'weather_experience_count': <String>{
        ..._seenWeatherIds,
        if (weather != null) weather.id,
      }.length,
      'today_world_summary': summary == null ? 0 : 1,
      'today_world_summary_count': summary == null ? 0 : 1,
      'office_trust': _playerInfluenceContext.officeInfluence.officeTrust,
      'office_popularity':
          _playerInfluenceContext.officeInfluence.officePopularity,
      'office_visibility':
          _playerInfluenceContext.officeInfluence.officeVisibility,
      'office_influence': _playerInfluenceContext.officeInfluence.overall,
      'friend_count': _playerInfluenceContext.friendCount,
      for (final reputation in _playerInfluenceContext.reputation)
        'reputation_$reputation': 1,
    };
  }

  Map<String, int> _currentDailyMetrics() {
    return _dailyFromCumulative(_currentCumulativeMetrics());
  }

  Map<String, int> _dailyFromCumulative(Map<String, int> cumulative) {
    if (_dailyBaseline.isEmpty) return cumulative;
    return <String, int>{
      for (final entry in cumulative.entries)
        entry.key: (entry.value - (_dailyBaseline[entry.key] ?? 0))
            .clamp(0, entry.value)
            .toInt(),
      'login_days': 1,
      'consecutive_login': cumulative['consecutive_login'] ?? 1,
      'today_world_summary': cumulative['today_world_summary'] ?? 0,
      'today_world_summary_count': cumulative['today_world_summary_count'] ?? 0,
    };
  }

  Map<String, int> _zeroBaseline(Map<String, int> cumulative) {
    return <String, int>{
      for (final key in cumulative.keys) key: 0,
    };
  }

  Iterable<String> get _dailyTaskIds sync* {
    for (final task in _taskConfig.tasks) {
      if (task.category == 'daily') yield task.id;
    }
  }

  void _recordCareerEvent(
    String type, {
    required String id,
    required int amount,
  }) {
    if (!_isCareerMetric(type)) return;
    final stableId = id.isEmpty
        ? '$type:${_worldClockManager.today().dayCount}'
        : '$type:$id';
    _worldSaveManager.recordCareerProgress(
      sourceId: stableId,
      type: type,
      experience: (amount.abs() * 3).clamp(1, 15),
      performanceDelta: _careerPerformanceDelta(type, amount),
      completedTaskDelta: type.contains('task') ? amount.clamp(0, 99) : 0,
    );
  }

  void _recordSkillEvent(
    String type, {
    required String id,
    required int amount,
  }) {
    final skillId = _skillForMetric(type);
    if (skillId.isEmpty) return;
    final stableId = id.isEmpty
        ? '$type:${_worldClockManager.today().dayCount}'
        : '$type:$id';
    _worldSaveManager.recordSkillExperience(
      sourceType: type,
      sourceId: stableId,
      skillId: skillId,
      amount: (amount.abs() * 4).clamp(1, 20),
      reason: '明确行为 $type 带来技能成长。',
    );
  }

  bool _isCareerTask(TaskItemConfig task) {
    return _isCareerMetric(task.category) || _isCareerMetric(task.metric);
  }

  bool _isCareerMetric(String value) {
    final text = value.toLowerCase();
    return text == 'career' ||
        text == 'work' ||
        text == 'resident_help' ||
        text == 'office_event' ||
        text == 'relationship' ||
        text == 'story' ||
        text.startsWith('career_') ||
        text.startsWith('work_');
  }

  int _careerPerformanceDelta(String type, int amount) {
    final text = type.toLowerCase();
    if (text.contains('failed') || text.contains('ignored')) {
      return (-amount.abs()).clamp(-3, 0);
    }
    if (text.contains('important') || text.contains('story')) {
      return (amount.abs() * 2).clamp(0, 6);
    }
    return amount > 0 ? amount.clamp(0, 3) : amount.clamp(-3, 0);
  }

  Map<String, int> _skillsForTask(TaskItemConfig task) {
    final skill = _skillForMetric(task.metric).isNotEmpty
        ? _skillForMetric(task.metric)
        : _skillForMetric(task.category);
    if (skill.isEmpty) return const <String, int>{'efficiency': 6};
    return <String, int>{skill: 6};
  }

  String _skillForMetric(String value) {
    final text = value.toLowerCase();
    if (text.contains('fish') || text.contains('fishing')) return 'fishing';
    if (text.contains('resident') ||
        text.contains('relationship') ||
        text.contains('dialogue') ||
        text.contains('help')) {
      return 'communication';
    }
    if (text.contains('collection') ||
        text.contains('rumor') ||
        text.contains('weather') ||
        text.contains('festival') ||
        text.contains('discover') ||
        text.contains('story')) {
      return 'observation';
    }
    if (text.contains('task') ||
        text.contains('daily') ||
        text.contains('career') ||
        text.contains('work')) {
      return 'efficiency';
    }
    if (text.contains('team') || text.contains('manage')) return 'management';
    if (text.contains('rare') || text.contains('luck')) return 'luck';
    return '';
  }

  void _persistState() {
    _worldSaveManager.setQuestRuntimeState({
      'lastRefreshDay': _lastRefreshDay,
      'dailyBaseline': _dailyBaseline,
      'seenWeatherIds': _seenWeatherIds.toList(growable: false)..sort(),
      'seenFestivalIds': _seenFestivalIds.toList(growable: false)..sort(),
      'seenRumorIds': _seenRumorIds.toList(growable: false)..sort(),
      'triggeredStoryIds': _triggeredStoryIds.toList(growable: false)..sort(),
      'residentInteractionCount': _residentInteractionCount,
      'worldEventCounts': Map<String, int>.from(_worldEventCounts),
      'recommendedQuestTags': recommendedQuestTags,
      'playerReputation': _playerInfluenceContext.reputation,
      'playerOfficeInfluence': _playerInfluenceContext.officeInfluence.toJson(),
      'taskClaimedIds': _taskManager.claimedTaskIds.toList(growable: false)
        ..sort(),
    });
  }

  void _restoreState(Map<String, dynamic> state) {
    if (state.isEmpty) return;
    _lastRefreshDay = _readInt(state['lastRefreshDay']);
    final baseline = state['dailyBaseline'];
    if (baseline is Map) {
      _dailyBaseline
        ..clear()
        ..addAll(
          baseline.map(
            (key, value) => MapEntry(key.toString(), _readInt(value) ?? 0),
          ),
        );
    }
    _seenWeatherIds.addAll(_stringList(state['seenWeatherIds']));
    _seenFestivalIds.addAll(_stringList(state['seenFestivalIds']));
    _seenRumorIds.addAll(_stringList(state['seenRumorIds']));
    _triggeredStoryIds.addAll(_stringList(state['triggeredStoryIds']));
    final worldEvents = state['worldEventCounts'];
    if (worldEvents is Map) {
      _worldEventCounts
        ..clear()
        ..addAll(
          worldEvents.map(
            (key, value) => MapEntry(key.toString(), _readInt(value) ?? 0),
          ),
        );
    }
    _residentInteractionCount =
        _readInt(state['residentInteractionCount']) ?? 0;
  }

  int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '');
  }

  List<String> _stringList(Object? value) {
    if (value is! List) return const <String>[];
    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
