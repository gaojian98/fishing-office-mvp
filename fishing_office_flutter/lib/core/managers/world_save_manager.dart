import 'dart:convert';

import 'package:flutter/foundation.dart';

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
      return data.copyWith(saveVersion: currentWorldSaveVersion);
    }
    return null;
  }

  Map<String, dynamic> _residentStateToJson(String residentId) {
    final state = _residentRuntimeManager.getResidentCurrentState(residentId);
    return {
      'residentId': state.residentId,
      'scheduleId': state.scheduleId,
      'location': state.location,
      'activity': state.activity,
      'mood': state.mood,
      'startTime': state.startTime,
      'endTime': state.endTime,
      'found': state.found,
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

  bool _mapEquals(Map<String, dynamic> current, Map<String, dynamic> next) {
    return jsonEncode(current) == jsonEncode(next);
  }

  String _saveSignature(WorldSaveData data) {
    final json = Map<String, dynamic>.from(data.toJson())..remove('savedAt');
    return jsonEncode(json);
  }
}
