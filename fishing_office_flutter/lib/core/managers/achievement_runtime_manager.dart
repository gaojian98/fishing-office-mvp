import 'package:flutter/foundation.dart';

import '../../models/fish_collection_config.dart';
import '../../models/honor_config.dart';
import '../../models/task_config.dart';
import '../engine/second_world_engine.dart';
import 'festival_runtime_manager.dart';
import 'fish_runtime_manager.dart';
import 'quest_runtime_manager.dart';
import 'relationship_runtime_manager.dart';
import 'resident_runtime_manager.dart';
import 'rumor_runtime_manager.dart';
import 'story_runtime_manager.dart';
import 'weather_runtime_manager.dart';
import 'world_clock_manager.dart';
import 'world_save_manager.dart';

class AchievementEvent {
  const AchievementEvent({
    required this.type,
    this.id = '',
    this.amount = 1,
    this.payload = const <String, dynamic>{},
  });

  final String type;
  final String id;
  final int amount;
  final Map<String, dynamic> payload;
}

class AchievementProgress {
  const AchievementProgress({
    required this.id,
    required this.source,
    required this.title,
    required this.description,
    required this.metric,
    required this.target,
    required this.progress,
    required this.status,
    required this.unlockedAt,
    required this.sortOrder,
    required this.tags,
  });

  final String id;
  final String source;
  final String title;
  final String description;
  final String metric;
  final int target;
  final int progress;
  final String status;
  final String unlockedAt;
  final int sortOrder;
  final List<String> tags;

  int get cappedProgress => target <= 0 ? progress : progress.clamp(0, target);
  bool get unlocked =>
      status == 'unlocked' || status == 'claimed' || status == 'equipped';

  AchievementProgress copyWith({
    int? progress,
    String? status,
    String? unlockedAt,
  }) {
    return AchievementProgress(
      id: id,
      source: source,
      title: title,
      description: description,
      metric: metric,
      target: target,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      sortOrder: sortOrder,
      tags: tags,
    );
  }
}

class AchievementRuntimeManager extends ChangeNotifier {
  AchievementRuntimeManager({
    required HonorConfig honorConfig,
    required Map<String, dynamic> identityConfig,
    required FishCollectionConfig fishCollectionConfig,
    required TaskConfig taskConfig,
    required QuestRuntimeManager questRuntimeManager,
    required FishRuntimeManager fishRuntimeManager,
    required RelationshipRuntimeManager relationshipRuntimeManager,
    required StoryRuntimeManager storyRuntimeManager,
    required RumorRuntimeManager rumorRuntimeManager,
    required FestivalRuntimeManager festivalRuntimeManager,
    required WeatherRuntimeManager weatherRuntimeManager,
    required ResidentRuntimeManager residentRuntimeManager,
    required WorldClockManager worldClockManager,
    required WorldSaveManager worldSaveManager,
    SecondWorldEngine? secondWorldEngine,
  })  : _honorConfig = honorConfig,
        _identityConfig = identityConfig,
        _fishCollectionConfig = fishCollectionConfig,
        _taskConfig = taskConfig,
        _questRuntimeManager = questRuntimeManager,
        _fishRuntimeManager = fishRuntimeManager,
        _relationshipRuntimeManager = relationshipRuntimeManager,
        _storyRuntimeManager = storyRuntimeManager,
        _rumorRuntimeManager = rumorRuntimeManager,
        _festivalRuntimeManager = festivalRuntimeManager,
        _weatherRuntimeManager = weatherRuntimeManager,
        _residentRuntimeManager = residentRuntimeManager,
        _worldClockManager = worldClockManager,
        _worldSaveManager = worldSaveManager,
        _secondWorldEngine = secondWorldEngine {
    _restoreState(worldSaveManager.achievementRuntimeState);
    _rebuild();
  }

  final HonorConfig _honorConfig;
  final Map<String, dynamic> _identityConfig;
  final FishCollectionConfig _fishCollectionConfig;
  final TaskConfig _taskConfig;
  final QuestRuntimeManager _questRuntimeManager;
  final FishRuntimeManager _fishRuntimeManager;
  final RelationshipRuntimeManager _relationshipRuntimeManager;
  final StoryRuntimeManager _storyRuntimeManager;
  final RumorRuntimeManager _rumorRuntimeManager;
  final FestivalRuntimeManager _festivalRuntimeManager;
  final WeatherRuntimeManager _weatherRuntimeManager;
  final ResidentRuntimeManager _residentRuntimeManager;
  final WorldClockManager _worldClockManager;
  final WorldSaveManager _worldSaveManager;
  final SecondWorldEngine? _secondWorldEngine;

  final Map<String, int> _manualCounters = <String, int>{};
  final Map<String, AchievementProgress> _progress =
      <String, AchievementProgress>{};
  final Set<String> _claimedIds = <String>{};
  final Map<String, String> _unlockedAt = <String, String>{};
  String _equippedTitleId = '';

  List<AchievementProgress> getAllAchievements() {
    _rebuild();
    final items = _progress.values.toList(growable: false)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return items;
  }

  AchievementProgress? getAchievementProgress(String id) {
    _rebuild();
    return _progress[id];
  }

  List<AchievementProgress> getUnlockedAchievements() {
    return getAllAchievements()
        .where((item) => item.unlocked)
        .toList(growable: false);
  }

  void updateAchievementProgress(AchievementEvent event) {
    if (event.type.isNotEmpty && event.amount != 0) {
      _manualCounters[event.type] =
          (_manualCounters[event.type] ?? 0) + event.amount;
    }
    for (final entry in event.payload.entries) {
      final value = _readInt(entry.value, fallback: 0);
      if (value > 0) {
        _manualCounters[entry.key] = value;
      }
    }
    _rebuild(notify: true);
  }

  void unlockAchievement(String id) {
    _rebuild();
    if (!_progress.containsKey(id)) return;
    _markUnlocked(id);
    _saveState();
    notifyListeners();
  }

  void equipTitle(String id) {
    _rebuild();
    final item = _progress[id];
    if (item == null || !item.unlocked) return;
    _equippedTitleId = id;
    _progress[id] = item.copyWith(status: 'equipped');
    _saveState();
    notifyListeners();
  }

  AchievementProgress? getEquippedTitle() {
    if (_equippedTitleId.isEmpty) return null;
    return getAchievementProgress(_equippedTitleId);
  }

  void _rebuild({bool notify = false}) {
    final metrics = _collectMetrics();
    final next = <String, AchievementProgress>{};
    for (final item in _buildDefinitions()) {
      final savedStatus = _progress[item.id]?.status;
      final progress = (metrics[item.metric] ?? item.progress)
          .clamp(0, item.target <= 0 ? 999999 : item.target);
      var status = _resolveStatus(item, progress, savedStatus);
      if (_claimedIds.contains(item.id)) status = 'claimed';
      if (_equippedTitleId == item.id) status = 'equipped';
      final updated = item.copyWith(
        progress: progress,
        status: status,
        unlockedAt: _unlockedAt[item.id] ?? item.unlockedAt,
      );
      next[item.id] = updated;
      if (updated.unlocked && !_unlockedAt.containsKey(item.id)) {
        _markUnlocked(item.id, record: true);
      }
    }
    final changed = !_sameProgress(_progress, next);
    _progress
      ..clear()
      ..addAll(next);
    _saveState();
    if (changed && notify) notifyListeners();
  }

  List<AchievementProgress> _buildDefinitions() {
    final items = <AchievementProgress>[];
    for (final badge in _honorConfig.badges) {
      items.add(
        AchievementProgress(
          id: badge.id,
          source: 'honor',
          title: badge.name,
          description: badge.description,
          metric: badge.metric,
          target: badge.target,
          progress: badge.progress,
          status: _normalizeStatus(badge.status),
          unlockedAt: badge.obtainedAt,
          sortOrder: badge.sortOrder,
          tags: <String>['honor', badge.category],
        ),
      );
    }
    var identityOrder = 10000;
    for (final identity in _identityItems()) {
      if (identity['enabled'] == false) continue;
      final condition = _mapOf(identity['unlockCondition']);
      items.add(
        AchievementProgress(
          id: identity['id']?.toString() ?? '',
          source: 'identity',
          title: identity['name']?.toString() ?? '',
          description: identity['description']?.toString() ?? '',
          metric: condition['metric']?.toString() ?? 'login_days',
          target: _readInt(condition['value'], fallback: 1),
          progress: 0,
          status: 'locked',
          unlockedAt: '',
          sortOrder: _readInt(identity['sortOrder'], fallback: identityOrder++),
          tags: _stringList(identity['tags']),
        ),
      );
    }
    var taskOrder = 20000;
    for (final task in _taskConfig.tasks) {
      items.add(
        AchievementProgress(
          id: 'task_${task.id}',
          source: 'task',
          title: task.title,
          description: task.description,
          metric: task.metric,
          target: task.target,
          progress: task.progress,
          status: _normalizeStatus(task.status),
          unlockedAt: '',
          sortOrder: taskOrder++,
          tags: <String>['task', task.category],
        ),
      );
    }
    items.add(
      AchievementProgress(
        id: 'collection_completion',
        source: 'fish_collection',
        title: _fishCollectionConfig.title,
        description: '记录玩家在第二世界发现鱼类的进度。',
        metric: 'collection_count',
        target: _fishCollectionConfig.fishes.length,
        progress: 0,
        status: 'locked',
        unlockedAt: '',
        sortOrder: 30000,
        tags: const <String>['collection', 'fish'],
      ),
    );
    return items.where((item) => item.id.isNotEmpty).toList(growable: false);
  }

  Map<String, int> _collectMetrics() {
    final metrics = <String, int>{};
    metrics.addAll(_questRuntimeManager.cumulativeMetrics);
    metrics.addAll(_manualCounters);
    metrics['login_days'] =
        metrics['login_days'] ?? _worldClockManager.today().dayCount;
    metrics['fishing_count'] =
        (metrics['fishing_count'] ?? 0) + (_manualCounters['fishing'] ?? 0);
    metrics['sell_count'] =
        (metrics['sell_count'] ?? 0) + (_manualCounters['sell_fish'] ?? 0);
    metrics['release_count'] = (metrics['release_count'] ?? 0) +
        (_manualCounters['release_fish'] ?? 0);
    metrics['rare_fish_discovery'] = _manualCounters['rare_fish_discovery'] ??
        _fishRuntimeManager
            .getActiveFishPool()
            .where((fish) => fish.rarity != 'common')
            .length;
    metrics['collection_count'] =
        metrics['collection_count'] ?? _manualCounters['collection_count'] ?? 0;
    final totalFish = _fishCollectionConfig.fishes.length;
    metrics['collection_rate'] = totalFish <= 0
        ? 0
        : ((metrics['collection_count'] ?? 0) / totalFish * 100)
            .clamp(0, 100)
            .round();
    metrics['task_completed'] = _questRuntimeManager
        .visibleTasks('all')
        .where((task) => task.status == 'completed')
        .length;
    metrics['story_completed'] = _storyRuntimeManager.finishedStoryIds.length;
    metrics['rumor_discovered'] = _rumorRuntimeManager.records.length;
    metrics['festival_experienced'] =
        _festivalRuntimeManager.getActiveFestivals().length +
            (_manualCounters['festival_experienced'] ?? 0);
    metrics['weather_experienced'] =
        (_weatherRuntimeManager.getCurrentWeather() == null ? 0 : 1) +
            (_manualCounters['weather_experienced'] ?? 0);
    metrics['resident_count'] = _residentRuntimeManager.residents.length;
    metrics['relationship_stage'] = _maxRelationshipRank();
    metrics['fish_coin_total'] =
        _manualCounters['fish_coin_total'] ?? metrics['fish_coin'] ?? 0;
    metrics['has_second_world_engine'] = _secondWorldEngine == null ? 0 : 1;
    return metrics;
  }

  int _maxRelationshipRank() {
    var rank = 0;
    for (final resident in _residentRuntimeManager.residents) {
      final relationship =
          _relationshipRuntimeManager.getPlayerRelationshipWithResident(
        resident.id,
      );
      rank = rank > _relationshipRank(relationship.relationshipLevel)
          ? rank
          : _relationshipRank(relationship.relationshipLevel);
    }
    for (final relationship
        in _relationshipRuntimeManager.residentRelationships) {
      rank = rank > _relationshipRank(relationship.level)
          ? rank
          : _relationshipRank(relationship.level);
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

  String _resolveStatus(
    AchievementProgress item,
    int progress,
    String? savedStatus,
  ) {
    if (savedStatus == 'equipped' ||
        savedStatus == 'claimed' ||
        savedStatus == 'unlocked') {
      return savedStatus!;
    }
    if (_unlockedAt.containsKey(item.id)) return 'unlocked';
    if (item.status == 'equipped') return 'equipped';
    if (item.status == 'claimed') return 'claimed';
    if (item.status == 'unlocked') return 'unlocked';
    if (item.status == 'obtained') return 'unlocked';
    if (item.target > 0 && progress >= item.target) return 'unlocked';
    if (progress > 0) return 'in_progress';
    return 'locked';
  }

  String _normalizeStatus(String status) {
    if (status == 'obtained') return 'unlocked';
    if (status == 'not_obtained' || status == 'not_started') return 'locked';
    return status;
  }

  void _markUnlocked(String id, {bool record = false}) {
    if (_unlockedAt.containsKey(id)) return;
    final now = WorldClockManager.systemNow().toIso8601String();
    _unlockedAt[id] = now;
    if (record || kDebugMode) {
      _worldSaveManager.recordInteraction(
        residentId: '',
        dialogueId: '',
        storyId: '',
        tags: <String>['achievement_unlocked', id],
      );
    }
  }

  void _saveState() {
    _worldSaveManager.setAchievementRuntimeState({
      'progress': _progress.map(
        (key, value) => MapEntry(key, {
          'progress': value.progress,
          'status': value.status,
          'unlockedAt': _unlockedAt[key] ?? value.unlockedAt,
        }),
      ),
      'unlockedIds': _unlockedAt.keys.toList(growable: false),
      'claimedIds': _claimedIds.toList(growable: false),
      'equippedTitleId': _equippedTitleId,
      'unlockedAt': Map<String, String>.from(_unlockedAt),
      'eventCounters': Map<String, int>.from(_manualCounters),
    });
  }

  void _restoreState(Map<String, dynamic> state) {
    _claimedIds
      ..clear()
      ..addAll(_stringList(state['claimedIds']));
    _equippedTitleId = state['equippedTitleId']?.toString() ?? '';
    _unlockedAt
      ..clear()
      ..addAll(
        _mapOf(state['unlockedAt']).map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    final counters = _mapOf(state['eventCounters']);
    _manualCounters
      ..clear()
      ..addEntries(
        counters.entries.map(
          (entry) => MapEntry(entry.key, _readInt(entry.value, fallback: 0)),
        ),
      );
  }

  bool _sameProgress(
    Map<String, AchievementProgress> a,
    Map<String, AchievementProgress> b,
  ) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      final other = b[entry.key];
      if (other == null ||
          other.progress != entry.value.progress ||
          other.status != entry.value.status ||
          other.unlockedAt != entry.value.unlockedAt) {
        return false;
      }
    }
    return true;
  }

  List<Map<String, dynamic>> _identityItems() {
    final raw = _identityConfig['identities'];
    if (raw is! List) return const <Map<String, dynamic>>[];
    return raw
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

  int _readInt(Object? value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
