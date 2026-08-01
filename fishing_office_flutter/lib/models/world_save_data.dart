import '../core/engine/world_calendar.dart';
import '../core/engine/world_clock.dart';
import 'resident_memory_config.dart';
import 'resident_relationship_config.dart';
import 'rumor_config.dart';

const currentWorldSaveVersion = '1.0';

class WorldSaveData {
  const WorldSaveData({
    required this.saveVersion,
    required this.savedAt,
    required this.worldClock,
    required this.worldCalendar,
    required this.festivalRuntime,
    required this.weatherRuntime,
    required this.rumorRuntime,
    required this.residentRuntime,
    required this.residentMemory,
    required this.residentRelationship,
    required this.finishedStories,
    required this.dialogueRuntimeState,
    required this.dailySimulationState,
    required this.questRuntimeState,
    required this.economyRuntimeState,
    required this.relationshipRuntimeState,
    required this.achievementRuntimeState,
    required this.dynamicEventRuntimeState,
    required this.taskRewards,
    required this.interactionHistory,
  });

  factory WorldSaveData.empty() {
    return WorldSaveData(
      saveVersion: currentWorldSaveVersion,
      savedAt: '',
      worldClock: WorldClock.initial(),
      worldCalendar: WorldCalendar.initial(),
      festivalRuntime: const <String, dynamic>{},
      weatherRuntime: const <String, dynamic>{},
      rumorRuntime: const <RumorRuntimeRecord>[],
      residentRuntime: const <String, dynamic>{},
      residentMemory: const ResidentMemoryConfig(version: '1.0', memories: []),
      residentRelationship: const ResidentRelationshipConfig(
        version: '1.0',
        levels: [],
        relationships: [],
      ),
      finishedStories: const <String>[],
      dialogueRuntimeState: const <String, dynamic>{},
      dailySimulationState: const <String, dynamic>{},
      questRuntimeState: const <String, dynamic>{},
      economyRuntimeState: const <String, dynamic>{},
      relationshipRuntimeState: const <String, dynamic>{},
      achievementRuntimeState: const <String, dynamic>{},
      dynamicEventRuntimeState: const <String, dynamic>{},
      taskRewards: const <TaskRewardRecord>[],
      interactionHistory: const <InteractionHistoryRecord>[],
    );
  }

  factory WorldSaveData.fromJson(Map<String, dynamic> json) {
    return WorldSaveData(
      saveVersion: json['saveVersion']?.toString() ?? '0.0',
      savedAt: json['savedAt']?.toString() ?? '',
      worldClock: _worldClockFromJson(_mapOf(json['worldClock'])),
      worldCalendar: _worldCalendarFromJson(_mapOf(json['worldCalendar'])),
      festivalRuntime: _mapOf(json['festivalRuntime']),
      weatherRuntime: _mapOf(json['weatherRuntime']),
      rumorRuntime: _listOfMaps(json['rumorRuntime'])
          .map(RumorRuntimeRecord.fromJson)
          .toList(growable: false),
      residentRuntime: _mapOf(json['residentRuntime']),
      residentMemory:
          ResidentMemoryConfig.fromJson(_mapOf(json['residentMemory'])),
      residentRelationship: ResidentRelationshipConfig.fromJson(
        _mapOf(json['residentRelationship']),
      ),
      finishedStories: _stringList(json['finishedStories']),
      dialogueRuntimeState: _mapOf(json['dialogueRuntimeState']),
      dailySimulationState: _mapOf(json['dailySimulationState']),
      questRuntimeState: _mapOf(json['questRuntimeState']),
      economyRuntimeState: _mapOf(json['economyRuntimeState']),
      relationshipRuntimeState: _mapOf(json['relationshipRuntimeState']),
      achievementRuntimeState: _mapOf(json['achievementRuntimeState']),
      dynamicEventRuntimeState: _mapOf(json['dynamicEventRuntimeState']),
      taskRewards: _listOfMaps(json['taskRewards'])
          .map(TaskRewardRecord.fromJson)
          .toList(growable: false),
      interactionHistory: _listOfMaps(json['interactionHistory'])
          .map(InteractionHistoryRecord.fromJson)
          .toList(growable: false),
    );
  }

  final String saveVersion;
  final String savedAt;
  final WorldClock worldClock;
  final WorldCalendar worldCalendar;
  final Map<String, dynamic> festivalRuntime;
  final Map<String, dynamic> weatherRuntime;
  final List<RumorRuntimeRecord> rumorRuntime;
  final Map<String, dynamic> residentRuntime;
  final ResidentMemoryConfig residentMemory;
  final ResidentRelationshipConfig residentRelationship;
  final List<String> finishedStories;
  final Map<String, dynamic> dialogueRuntimeState;
  final Map<String, dynamic> dailySimulationState;
  final Map<String, dynamic> questRuntimeState;
  final Map<String, dynamic> economyRuntimeState;
  final Map<String, dynamic> relationshipRuntimeState;
  final Map<String, dynamic> achievementRuntimeState;
  final Map<String, dynamic> dynamicEventRuntimeState;
  final List<TaskRewardRecord> taskRewards;
  final List<InteractionHistoryRecord> interactionHistory;

  bool get isCurrentVersion => saveVersion == currentWorldSaveVersion;

  Map<String, dynamic> toJson() {
    return {
      'saveVersion': saveVersion,
      'savedAt': savedAt,
      'worldClock': _worldClockToJson(worldClock),
      'worldCalendar': _worldCalendarToJson(worldCalendar),
      'festivalRuntime': festivalRuntime,
      'weatherRuntime': weatherRuntime,
      'rumorRuntime':
          rumorRuntime.map((record) => record.toJson()).toList(growable: false),
      'residentRuntime': residentRuntime,
      'residentMemory': residentMemory.toJson(),
      'residentRelationship': residentRelationship.toJson(),
      'finishedStories': finishedStories,
      'dialogueRuntimeState': dialogueRuntimeState,
      'dailySimulationState': dailySimulationState,
      'questRuntimeState': questRuntimeState,
      'economyRuntimeState': economyRuntimeState,
      'relationshipRuntimeState': relationshipRuntimeState,
      'achievementRuntimeState': achievementRuntimeState,
      'dynamicEventRuntimeState': dynamicEventRuntimeState,
      'taskRewards':
          taskRewards.map((record) => record.toJson()).toList(growable: false),
      'interactionHistory': interactionHistory
          .map((record) => record.toJson())
          .toList(growable: false),
    };
  }

  WorldSaveData copyWith({
    String? saveVersion,
    String? savedAt,
    WorldClock? worldClock,
    WorldCalendar? worldCalendar,
    Map<String, dynamic>? festivalRuntime,
    Map<String, dynamic>? weatherRuntime,
    List<RumorRuntimeRecord>? rumorRuntime,
    Map<String, dynamic>? residentRuntime,
    ResidentMemoryConfig? residentMemory,
    ResidentRelationshipConfig? residentRelationship,
    List<String>? finishedStories,
    Map<String, dynamic>? dialogueRuntimeState,
    Map<String, dynamic>? dailySimulationState,
    Map<String, dynamic>? questRuntimeState,
    Map<String, dynamic>? economyRuntimeState,
    Map<String, dynamic>? relationshipRuntimeState,
    Map<String, dynamic>? achievementRuntimeState,
    Map<String, dynamic>? dynamicEventRuntimeState,
    List<TaskRewardRecord>? taskRewards,
    List<InteractionHistoryRecord>? interactionHistory,
  }) {
    return WorldSaveData(
      saveVersion: saveVersion ?? this.saveVersion,
      savedAt: savedAt ?? this.savedAt,
      worldClock: worldClock ?? this.worldClock,
      worldCalendar: worldCalendar ?? this.worldCalendar,
      festivalRuntime: festivalRuntime ?? this.festivalRuntime,
      weatherRuntime: weatherRuntime ?? this.weatherRuntime,
      rumorRuntime: rumorRuntime ?? this.rumorRuntime,
      residentRuntime: residentRuntime ?? this.residentRuntime,
      residentMemory: residentMemory ?? this.residentMemory,
      residentRelationship: residentRelationship ?? this.residentRelationship,
      finishedStories: finishedStories ?? this.finishedStories,
      dialogueRuntimeState: dialogueRuntimeState ?? this.dialogueRuntimeState,
      dailySimulationState: dailySimulationState ?? this.dailySimulationState,
      questRuntimeState: questRuntimeState ?? this.questRuntimeState,
      economyRuntimeState: economyRuntimeState ?? this.economyRuntimeState,
      relationshipRuntimeState:
          relationshipRuntimeState ?? this.relationshipRuntimeState,
      achievementRuntimeState:
          achievementRuntimeState ?? this.achievementRuntimeState,
      dynamicEventRuntimeState:
          dynamicEventRuntimeState ?? this.dynamicEventRuntimeState,
      taskRewards: taskRewards ?? this.taskRewards,
      interactionHistory: interactionHistory ?? this.interactionHistory,
    );
  }
}

class TaskRewardRecord {
  const TaskRewardRecord({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.fishCoin,
    required this.exp,
    required this.claimedAt,
    required this.tags,
  });

  factory TaskRewardRecord.fromJson(Map<String, dynamic> json) {
    return TaskRewardRecord(
      id: json['id']?.toString() ?? '',
      taskId: json['taskId']?.toString() ?? '',
      taskTitle: json['taskTitle']?.toString() ?? '',
      fishCoin: _readInt(json['fishCoin']),
      exp: _readInt(json['exp']),
      claimedAt: json['claimedAt']?.toString() ?? '',
      tags: _stringList(json['tags']),
    );
  }

  final String id;
  final String taskId;
  final String taskTitle;
  final int fishCoin;
  final int exp;
  final String claimedAt;
  final List<String> tags;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'fishCoin': fishCoin,
      'exp': exp,
      'claimedAt': claimedAt,
      'tags': tags,
    };
  }
}

class InteractionHistoryRecord {
  const InteractionHistoryRecord({
    required this.id,
    required this.residentId,
    required this.dialogueId,
    required this.storyId,
    required this.createdAt,
    required this.tags,
  });

  factory InteractionHistoryRecord.fromJson(Map<String, dynamic> json) {
    return InteractionHistoryRecord(
      id: json['id']?.toString() ?? '',
      residentId: json['residentId']?.toString() ?? '',
      dialogueId: json['dialogueId']?.toString() ?? '',
      storyId: json['storyId']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      tags: _stringList(json['tags']),
    );
  }

  final String id;
  final String residentId;
  final String dialogueId;
  final String storyId;
  final String createdAt;
  final List<String> tags;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'residentId': residentId,
      'dialogueId': dialogueId,
      'storyId': storyId,
      'createdAt': createdAt,
      'tags': tags,
    };
  }
}

Map<String, dynamic> _worldClockToJson(WorldClock clock) {
  return {
    'dayCount': clock.dayCount,
    'hour': clock.hour,
    'minute': clock.minute,
    'period': clock.period.name,
    'timeLabel': clock.timeLabel,
  };
}

WorldClock _worldClockFromJson(Map<String, dynamic> json) {
  return WorldClock(
    dayCount: _readInt(json['dayCount'], fallback: 1),
    hour: _readInt(json['hour'], fallback: 5),
    minute: _readInt(json['minute']),
    period: _periodFromString(json['period']?.toString() ?? ''),
    timeLabel: json['timeLabel']?.toString() ?? '',
  );
}

Map<String, dynamic> _worldCalendarToJson(WorldCalendar calendar) {
  return {
    'dayCount': calendar.dayCount,
    'weekdayIndex': calendar.weekdayIndex,
    'year': calendar.year,
    'month': calendar.month,
    'day': calendar.day,
    'isWeekend': calendar.isWeekend,
    'season': calendar.season,
  };
}

WorldCalendar _worldCalendarFromJson(Map<String, dynamic> json) {
  return WorldCalendar(
    dayCount: _readInt(json['dayCount'], fallback: 1),
    weekdayIndex: _readInt(json['weekdayIndex'], fallback: 1),
    year: _readInt(json['year'], fallback: 1),
    month: _readInt(json['month'], fallback: 1),
    day: _readInt(json['day'], fallback: 1),
    isWeekend: json['isWeekend'] == true,
    season: json['season']?.toString() ?? 'spring',
  );
}

WorldDayPeriod _periodFromString(String value) {
  for (final period in WorldDayPeriod.values) {
    if (period.name == value) return period;
  }
  return WorldDayPeriod.dawn;
}

List<Map<String, dynamic>> _listOfMaps(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

Map<String, dynamic> _mapOf(Object? value) {
  if (value is! Map) return const <String, dynamic>{};
  return Map<String, dynamic>.from(value);
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return value
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

int _readInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
