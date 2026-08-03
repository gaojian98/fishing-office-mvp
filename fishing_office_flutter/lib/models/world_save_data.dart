import '../core/engine/world_calendar.dart';
import '../core/engine/world_clock.dart';
import 'career_state.dart';
import 'friendship_state.dart';
import 'living_office_state.dart';
import 'office_group.dart';
import 'player_influence.dart';
import 'resident_memory_config.dart';
import 'resident_relationship_config.dart';
import 'rumor_config.dart';

const currentWorldSaveVersion = '1.1';

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
    required this.careerState,
    required this.careerRewardHistory,
    required this.salaryTransactionIds,
    required this.promotionHistory,
    required this.lastCareerDailySettlement,
    required this.playerSkillStates,
    required this.skillExperienceHistory,
    required this.processedSkillSourceIds,
    required this.careerFeedbackHistory,
    required this.latestCareerFeedback,
    required this.friendshipStates,
    required this.processedSocialSourceIds,
    required this.socialInteractionHistory,
    required this.socialCooldowns,
    required this.conflictStates,
    required this.dailySocialSummary,
    required this.officeGroupState,
    required this.activeGroups,
    required this.recentGroups,
    required this.groupHistory,
    required this.livingOfficeState,
    required this.officeWorldHistory,
    required this.companyNews,
    required this.companyTimeline,
    required this.lastLivingOfficeUpdate,
    required this.processedOfficeEventIds,
    required this.officeEventCooldowns,
    required this.playerInfluenceContext,
    required this.playerOfficeInfluence,
    required this.recentPlayerActions,
    required this.officeReputation,
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
      careerState: CareerState.initial(),
      careerRewardHistory: const <CareerRewardRecord>[],
      salaryTransactionIds: const <String>[],
      promotionHistory: const <CareerPromotionRecord>[],
      lastCareerDailySettlement: null,
      playerSkillStates: CareerState.initial().skillSummary,
      skillExperienceHistory: const <SkillExperienceRecord>[],
      processedSkillSourceIds: const <String>[],
      careerFeedbackHistory: const <CareerFeedback>[],
      latestCareerFeedback: null,
      friendshipStates: const <String, FriendshipState>{},
      processedSocialSourceIds: const <String>[],
      socialInteractionHistory: const <FriendshipChangeRecord>[],
      socialCooldowns: const <String, int>{},
      conflictStates: const <String, String>{},
      dailySocialSummary: const <String, dynamic>{},
      officeGroupState: const <String, dynamic>{},
      activeGroups: const <OfficeGroup>[],
      recentGroups: const <OfficeGroup>[],
      groupHistory: const <OfficeGroup>[],
      livingOfficeState: LivingOfficeState.empty(),
      officeWorldHistory: const <OfficeWorldHistoryEntry>[],
      companyNews: const <CompanyNewsItem>[],
      companyTimeline: const <CompanyTimelineEvent>[],
      lastLivingOfficeUpdate: '',
      processedOfficeEventIds: const <String>[],
      officeEventCooldowns: const <String, int>{},
      playerInfluenceContext: PlayerInfluenceContext.empty(),
      playerOfficeInfluence: PlayerOfficeInfluence.empty(),
      recentPlayerActions: const <RecentPlayerAction>[],
      officeReputation: const <String>['quiet'],
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
      careerState: CareerState.fromJson(_mapOf(json['careerState'])),
      careerRewardHistory: _listOfMaps(json['careerRewardHistory'])
          .map(CareerRewardRecord.fromJson)
          .toList(growable: false),
      salaryTransactionIds: _stringList(json['salaryTransactionIds']),
      promotionHistory: _listOfMaps(json['promotionHistory'])
          .map(CareerPromotionRecord.fromJson)
          .toList(growable: false),
      lastCareerDailySettlement: _nullableInt(
        json['lastCareerDailySettlement'],
      ),
      playerSkillStates: _skillStateMap(json['playerSkillStates']),
      skillExperienceHistory: _listOfMaps(json['skillExperienceHistory'])
          .map(SkillExperienceRecord.fromJson)
          .toList(growable: false),
      processedSkillSourceIds: _stringList(json['processedSkillSourceIds']),
      careerFeedbackHistory: _listOfMaps(json['careerFeedbackHistory'])
          .map(CareerFeedback.fromJson)
          .toList(growable: false),
      latestCareerFeedback: json['latestCareerFeedback'] is Map
          ? CareerFeedback.fromJson(
              Map<String, dynamic>.from(json['latestCareerFeedback'] as Map),
            )
          : null,
      friendshipStates: _friendshipStateMap(json['friendshipStates']),
      processedSocialSourceIds: _stringList(json['processedSocialSourceIds']),
      socialInteractionHistory: _listOfMaps(json['socialInteractionHistory'])
          .map(FriendshipChangeRecord.fromJson)
          .toList(growable: false),
      socialCooldowns: _intMap(json['socialCooldowns']),
      conflictStates: _stringMap(json['conflictStates']),
      dailySocialSummary: _mapOf(json['dailySocialSummary']),
      officeGroupState: _mapOf(json['officeGroupState']),
      activeGroups: officeGroupsFromJsonList(json['activeGroups']),
      recentGroups: officeGroupsFromJsonList(json['recentGroups']),
      groupHistory: officeGroupsFromJsonList(json['groupHistory']),
      livingOfficeState: json['livingOfficeState'] is Map
          ? LivingOfficeState.fromJson(
              Map<String, dynamic>.from(json['livingOfficeState'] as Map),
            )
          : LivingOfficeState.empty(),
      officeWorldHistory:
          officeWorldHistoryFromJsonList(json['officeWorldHistory']),
      companyNews: companyNewsFromJsonList(json['companyNews']),
      companyTimeline: companyTimelineFromJsonList(json['companyTimeline']),
      lastLivingOfficeUpdate: json['lastLivingOfficeUpdate']?.toString() ?? '',
      processedOfficeEventIds: _stringList(json['processedOfficeEventIds']),
      officeEventCooldowns: _intMap(json['officeEventCooldowns']),
      playerInfluenceContext: json['playerInfluenceContext'] is Map
          ? PlayerInfluenceContext.fromJson(
              Map<String, dynamic>.from(
                json['playerInfluenceContext'] as Map,
              ),
            )
          : PlayerInfluenceContext.empty(),
      playerOfficeInfluence: json['playerOfficeInfluence'] is Map
          ? PlayerOfficeInfluence.fromJson(
              Map<String, dynamic>.from(
                json['playerOfficeInfluence'] as Map,
              ),
            )
          : PlayerOfficeInfluence.empty(),
      recentPlayerActions: _listOfMaps(json['recentPlayerActions'])
          .map(RecentPlayerAction.fromJson)
          .toList(growable: false),
      officeReputation: _stringList(json['officeReputation']).isEmpty
          ? const <String>['quiet']
          : _stringList(json['officeReputation']),
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
  final CareerState careerState;
  final List<CareerRewardRecord> careerRewardHistory;
  final List<String> salaryTransactionIds;
  final List<CareerPromotionRecord> promotionHistory;
  final int? lastCareerDailySettlement;
  final Map<String, PlayerSkillState> playerSkillStates;
  final List<SkillExperienceRecord> skillExperienceHistory;
  final List<String> processedSkillSourceIds;
  final List<CareerFeedback> careerFeedbackHistory;
  final CareerFeedback? latestCareerFeedback;
  final Map<String, FriendshipState> friendshipStates;
  final List<String> processedSocialSourceIds;
  final List<FriendshipChangeRecord> socialInteractionHistory;
  final Map<String, int> socialCooldowns;
  final Map<String, String> conflictStates;
  final Map<String, dynamic> dailySocialSummary;
  final Map<String, dynamic> officeGroupState;
  final List<OfficeGroup> activeGroups;
  final List<OfficeGroup> recentGroups;
  final List<OfficeGroup> groupHistory;
  final LivingOfficeState livingOfficeState;
  final List<OfficeWorldHistoryEntry> officeWorldHistory;
  final List<CompanyNewsItem> companyNews;
  final List<CompanyTimelineEvent> companyTimeline;
  final String lastLivingOfficeUpdate;
  final List<String> processedOfficeEventIds;
  final Map<String, int> officeEventCooldowns;
  final PlayerInfluenceContext playerInfluenceContext;
  final PlayerOfficeInfluence playerOfficeInfluence;
  final List<RecentPlayerAction> recentPlayerActions;
  final List<String> officeReputation;
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
      'careerState': careerState.toJson(),
      'careerRewardHistory': careerRewardHistory
          .map((record) => record.toJson())
          .toList(growable: false),
      'salaryTransactionIds': salaryTransactionIds,
      'promotionHistory': promotionHistory
          .map((record) => record.toJson())
          .toList(growable: false),
      'lastCareerDailySettlement': lastCareerDailySettlement,
      'playerSkillStates':
          playerSkillStates.map((key, value) => MapEntry(key, value.toJson())),
      'skillExperienceHistory': skillExperienceHistory
          .map((record) => record.toJson())
          .toList(growable: false),
      'processedSkillSourceIds': processedSkillSourceIds,
      'careerFeedbackHistory': careerFeedbackHistory
          .map((feedback) => feedback.toJson())
          .toList(growable: false),
      'latestCareerFeedback': latestCareerFeedback?.toJson(),
      'friendshipStates':
          friendshipStates.map((key, value) => MapEntry(key, value.toJson())),
      'processedSocialSourceIds': processedSocialSourceIds,
      'socialInteractionHistory': socialInteractionHistory
          .map((record) => record.toJson())
          .toList(growable: false),
      'socialCooldowns': socialCooldowns,
      'conflictStates': conflictStates,
      'dailySocialSummary': dailySocialSummary,
      'officeGroupState': officeGroupState,
      'activeGroups':
          activeGroups.map((group) => group.toJson()).toList(growable: false),
      'recentGroups':
          recentGroups.map((group) => group.toJson()).toList(growable: false),
      'groupHistory':
          groupHistory.map((group) => group.toJson()).toList(growable: false),
      'livingOfficeState': livingOfficeState.toJson(),
      'officeWorldHistory': officeWorldHistory
          .map((entry) => entry.toJson())
          .toList(growable: false),
      'companyNews':
          companyNews.map((item) => item.toJson()).toList(growable: false),
      'companyTimeline':
          companyTimeline.map((item) => item.toJson()).toList(growable: false),
      'lastLivingOfficeUpdate': lastLivingOfficeUpdate,
      'processedOfficeEventIds': processedOfficeEventIds,
      'officeEventCooldowns': officeEventCooldowns,
      'playerInfluenceContext': playerInfluenceContext.toJson(),
      'playerOfficeInfluence': playerOfficeInfluence.toJson(),
      'recentPlayerActions': recentPlayerActions
          .map((action) => action.toJson())
          .toList(growable: false),
      'officeReputation': officeReputation,
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
    CareerState? careerState,
    List<CareerRewardRecord>? careerRewardHistory,
    List<String>? salaryTransactionIds,
    List<CareerPromotionRecord>? promotionHistory,
    int? lastCareerDailySettlement,
    Map<String, PlayerSkillState>? playerSkillStates,
    List<SkillExperienceRecord>? skillExperienceHistory,
    List<String>? processedSkillSourceIds,
    List<CareerFeedback>? careerFeedbackHistory,
    CareerFeedback? latestCareerFeedback,
    Map<String, FriendshipState>? friendshipStates,
    List<String>? processedSocialSourceIds,
    List<FriendshipChangeRecord>? socialInteractionHistory,
    Map<String, int>? socialCooldowns,
    Map<String, String>? conflictStates,
    Map<String, dynamic>? dailySocialSummary,
    Map<String, dynamic>? officeGroupState,
    List<OfficeGroup>? activeGroups,
    List<OfficeGroup>? recentGroups,
    List<OfficeGroup>? groupHistory,
    LivingOfficeState? livingOfficeState,
    List<OfficeWorldHistoryEntry>? officeWorldHistory,
    List<CompanyNewsItem>? companyNews,
    List<CompanyTimelineEvent>? companyTimeline,
    String? lastLivingOfficeUpdate,
    List<String>? processedOfficeEventIds,
    Map<String, int>? officeEventCooldowns,
    PlayerInfluenceContext? playerInfluenceContext,
    PlayerOfficeInfluence? playerOfficeInfluence,
    List<RecentPlayerAction>? recentPlayerActions,
    List<String>? officeReputation,
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
      careerState: careerState ?? this.careerState,
      careerRewardHistory: careerRewardHistory ?? this.careerRewardHistory,
      salaryTransactionIds: salaryTransactionIds ?? this.salaryTransactionIds,
      promotionHistory: promotionHistory ?? this.promotionHistory,
      lastCareerDailySettlement:
          lastCareerDailySettlement ?? this.lastCareerDailySettlement,
      playerSkillStates: playerSkillStates ?? this.playerSkillStates,
      skillExperienceHistory:
          skillExperienceHistory ?? this.skillExperienceHistory,
      processedSkillSourceIds:
          processedSkillSourceIds ?? this.processedSkillSourceIds,
      careerFeedbackHistory:
          careerFeedbackHistory ?? this.careerFeedbackHistory,
      latestCareerFeedback: latestCareerFeedback ?? this.latestCareerFeedback,
      friendshipStates: friendshipStates ?? this.friendshipStates,
      processedSocialSourceIds:
          processedSocialSourceIds ?? this.processedSocialSourceIds,
      socialInteractionHistory:
          socialInteractionHistory ?? this.socialInteractionHistory,
      socialCooldowns: socialCooldowns ?? this.socialCooldowns,
      conflictStates: conflictStates ?? this.conflictStates,
      dailySocialSummary: dailySocialSummary ?? this.dailySocialSummary,
      officeGroupState: officeGroupState ?? this.officeGroupState,
      activeGroups: activeGroups ?? this.activeGroups,
      recentGroups: recentGroups ?? this.recentGroups,
      groupHistory: groupHistory ?? this.groupHistory,
      livingOfficeState: livingOfficeState ?? this.livingOfficeState,
      officeWorldHistory: officeWorldHistory ?? this.officeWorldHistory,
      companyNews: companyNews ?? this.companyNews,
      companyTimeline: companyTimeline ?? this.companyTimeline,
      lastLivingOfficeUpdate:
          lastLivingOfficeUpdate ?? this.lastLivingOfficeUpdate,
      processedOfficeEventIds:
          processedOfficeEventIds ?? this.processedOfficeEventIds,
      officeEventCooldowns: officeEventCooldowns ?? this.officeEventCooldowns,
      playerInfluenceContext:
          playerInfluenceContext ?? this.playerInfluenceContext,
      playerOfficeInfluence:
          playerOfficeInfluence ?? this.playerOfficeInfluence,
      recentPlayerActions: recentPlayerActions ?? this.recentPlayerActions,
      officeReputation: officeReputation ?? this.officeReputation,
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

Map<String, PlayerSkillState> _skillStateMap(Object? value) {
  final initial = CareerState.initial().skillSummary;
  if (value is! Map) return initial;
  final result = <String, PlayerSkillState>{};
  for (final entry in value.entries) {
    if (entry.value is Map) {
      final skill = PlayerSkillState.fromJson(
        Map<String, dynamic>.from(entry.value as Map),
      );
      result[skill.skillId] = skill;
    }
  }
  return CareerState.initial()
      .copyWith(skillSummary: result)
      .normalized()
      .skillSummary;
}

Map<String, FriendshipState> _friendshipStateMap(Object? value) {
  if (value is! Map) return const <String, FriendshipState>{};
  final result = <String, FriendshipState>{};
  for (final entry in value.entries) {
    if (entry.value is Map) {
      final state = FriendshipState.fromJson(
        Map<String, dynamic>.from(entry.value as Map),
      );
      if (state.residentId.isNotEmpty) result[state.residentId] = state;
    }
  }
  return result;
}

Map<String, int> _intMap(Object? value) {
  if (value is! Map) return const <String, int>{};
  return value.map(
    (key, item) => MapEntry(key.toString(), _readInt(item)),
  );
}

Map<String, String> _stringMap(Object? value) {
  if (value is! Map) return const <String, String>{};
  return value.map(
    (key, item) => MapEntry(key.toString(), item.toString()),
  );
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

int? _nullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value.toString());
}
