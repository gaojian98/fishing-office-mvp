import 'package:flutter/foundation.dart';

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
  int _residentInteractionCount = 0;
  int? _lastRefreshDay;

  Map<String, int> get cumulativeMetrics =>
      Map<String, int>.unmodifiable(_currentCumulativeMetrics());

  Map<String, int> get dailyMetrics =>
      Map<String, int>.unmodifiable(_currentDailyMetrics());

  int? get lastRefreshDay => _lastRefreshDay;

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
    _persistState();
    notifyListeners();
  }

  void recordFestivalParticipation(String festivalId) {
    if (festivalId.isEmpty) return;
    _seenFestivalIds.add(festivalId);
    _persistState();
    notifyListeners();
  }

  void recordWeatherExperienced(String weatherId) {
    if (weatherId.isEmpty) return;
    _seenWeatherIds.add(weatherId);
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
    _persistState();
    notifyListeners();
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
    return <String, int>{
      ..._worldEventCounts,
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
