import 'career_state.dart';
import '../core/managers/resident_life_manager.dart';
import 'dynamic_event_config.dart';
import 'friendship_state.dart';
import 'living_office_state.dart';
import 'office_group.dart';
import 'player_influence.dart';
import 'resident_config.dart';
import 'resident_career.dart';
import 'resident_dialogue_config.dart';
import 'resident_personality_context.dart';
import 'resident_story_config.dart';

class InteractiveOfficeSnapshot {
  const InteractiveOfficeSnapshot({
    required this.date,
    required this.timeOfDay,
    required this.officeState,
    required this.playerInfluence,
    required this.playerCareer,
    required this.playerSkills,
    required this.playerReputation,
    required this.currentEvents,
    required this.activeGroups,
    required this.availableResidents,
    required this.nearbyResidents,
    required this.availableActions,
    required this.residentDetails,
    required this.dailySummary,
    required this.recentStories,
    required this.recentRumors,
    required this.recentAchievements,
    required this.recentChanges,
    required this.officeWorldHistory,
  });

  factory InteractiveOfficeSnapshot.empty() {
    return InteractiveOfficeSnapshot(
      date: '',
      timeOfDay: '',
      officeState: LivingOfficeState.empty(),
      playerInfluence: PlayerInfluenceContext.empty(),
      playerCareer: CareerState.initial(),
      playerSkills: const <String, PlayerSkillState>{},
      playerReputation: const <String>['quiet'],
      currentEvents: const <OfficeEventView>[],
      activeGroups: const <OfficeGroupView>[],
      availableResidents: const <ResidentOfficeView>[],
      nearbyResidents: const <ResidentOfficeView>[],
      availableActions: const <OfficeActionView>[],
      residentDetails: const <ResidentDetailViewModel>[],
      dailySummary: const <String, Object?>{},
      recentStories: const <OfficeStoryView>[],
      recentRumors: const <OfficeRumorView>[],
      recentAchievements: const <String>[],
      recentChanges: const <String>[],
      officeWorldHistory: const <OfficeHistoryView>[],
    );
  }

  final String date;
  final String timeOfDay;
  final LivingOfficeState officeState;
  final PlayerInfluenceContext playerInfluence;
  final CareerState playerCareer;
  final Map<String, PlayerSkillState> playerSkills;
  final List<String> playerReputation;
  final List<OfficeEventView> currentEvents;
  final List<OfficeGroupView> activeGroups;
  final List<ResidentOfficeView> availableResidents;
  final List<ResidentOfficeView> nearbyResidents;
  final List<OfficeActionView> availableActions;
  final List<ResidentDetailViewModel> residentDetails;
  final Map<String, Object?> dailySummary;
  final List<OfficeStoryView> recentStories;
  final List<OfficeRumorView> recentRumors;
  final List<String> recentAchievements;
  final List<String> recentChanges;
  final List<OfficeHistoryView> officeWorldHistory;

  bool get isEmpty =>
      officeState.isEmpty &&
      availableResidents.isEmpty &&
      activeGroups.isEmpty &&
      currentEvents.isEmpty;
}

class PlayerActionRequest {
  const PlayerActionRequest({
    required this.actionId,
    required this.actionType,
    this.targetResidentId = '',
    this.targetGroupId = '',
    this.targetEventId = '',
    this.targetLocationId = '',
    this.sourcePage = 'office_hub',
    this.currentWorldTime = '',
    this.metadata = const <String, Object?>{},
    this.timestamp = '',
  });

  final String actionId;
  final String actionType;
  final String targetResidentId;
  final String targetGroupId;
  final String targetEventId;
  final String targetLocationId;
  final String sourcePage;
  final String currentWorldTime;
  final Map<String, Object?> metadata;
  final String timestamp;

  String get requestId => actionId;
}

class PlayerActionResult {
  const PlayerActionResult({
    required this.success,
    required this.actionId,
    required this.actionType,
    required this.message,
    this.dialogue,
    this.storyTriggered,
    this.eventTriggered,
    this.questChanges = const <String>[],
    this.achievementChanges = const <String>[],
    this.friendshipChanges = const <String>[],
    this.careerChanges = const <String>[],
    this.skillChanges = const <String>[],
    this.economyChanges = const <String>[],
    this.inventoryChanges = const <String>[],
    this.officeInfluenceChanges = const <String>[],
    this.reputationChanges = const <String>[],
    this.worldStateChanges = const <String>[],
    this.memoryChanges = const <String>[],
    this.cooldownChanges = const <String>[],
    this.resultGroups = const <String, List<String>>{},
    this.positiveChanges = const <String>[],
    this.negativeChanges = const <String>[],
    this.neutralChanges = const <String>[],
    this.blockedReasons = const <String>[],
    this.recommendedNextActions = const <String>[],
    this.warnings = const <String>[],
    this.timestamp = '',
  });

  factory PlayerActionResult.blocked({
    required PlayerActionRequest request,
    required String reason,
    String message = '现在还不能这样做。',
  }) {
    return PlayerActionResult(
      success: false,
      actionId: request.actionId,
      actionType: request.actionType,
      message: message,
      blockedReasons: <String>[reason],
      warnings: <String>[reason],
      timestamp: request.timestamp,
    );
  }

  final bool success;
  final String actionId;
  final String actionType;
  final String message;
  final ResidentDialogueEntry? dialogue;
  final ResidentStoryEntry? storyTriggered;
  final DynamicEventEntry? eventTriggered;
  final List<String> questChanges;
  final List<String> achievementChanges;
  final List<String> friendshipChanges;
  final List<String> careerChanges;
  final List<String> skillChanges;
  final List<String> economyChanges;
  final List<String> inventoryChanges;
  final List<String> officeInfluenceChanges;
  final List<String> reputationChanges;
  final List<String> worldStateChanges;
  final List<String> memoryChanges;
  final List<String> cooldownChanges;
  final Map<String, List<String>> resultGroups;
  final List<String> positiveChanges;
  final List<String> negativeChanges;
  final List<String> neutralChanges;
  final List<String> blockedReasons;
  final List<String> recommendedNextActions;
  final List<String> warnings;
  final String timestamp;
}

class ResidentDetailViewModel {
  const ResidentDetailViewModel({
    required this.residentId,
    required this.name,
    required this.nickname,
    required this.gender,
    required this.age,
    required this.job,
    required this.description,
    required this.avatarAsset,
    required this.currentLocation,
    required this.currentActivity,
    required this.currentMood,
    required this.schedulePhase,
    required this.isWorking,
    required this.isOnBreak,
    required this.isOvertime,
    required this.isWeekend,
    required this.nextLocation,
    required this.nextActivity,
    required this.nextChangeTime,
    required this.scheduleReason,
    required this.careerLevel,
    required this.careerLevelName,
    required this.employmentStatus,
    required this.hireDate,
    required this.salaryLevel,
    required this.officeEconomyLines,
    required this.performanceScore,
    required this.capabilityScore,
    required this.promotionHistory,
    required this.careerTags,
    required this.personalityTraits,
    required this.dominantPersonality,
    required this.personalitySummary,
    required this.friendshipStage,
    required this.friendshipScore,
    required this.trust,
    required this.familiarity,
    required this.relationshipTags,
    required this.relationshipTrend,
    required this.sharedTopics,
    required this.sharedMemories,
    required this.recentMemories,
    required this.recentInteractions,
    required this.recentStories,
    required this.recentRumors,
    required this.recentEvents,
    required this.currentCooldowns,
    required this.shareFishOptions,
    required this.availableInteractions,
    required this.blockedInteractions,
    required this.visibleProfileFields,
    required this.privateProfileFields,
    required this.storyHints,
    required this.recommendedActions,
    required this.conflictState,
    required this.active,
    required this.lastUpdatedAt,
  });

  factory ResidentDetailViewModel.empty(String id) {
    return ResidentDetailViewModel(
      residentId: id,
      name: id,
      nickname: id,
      gender: '',
      age: '',
      job: '',
      description: '暂时没有读到这位居民的资料。',
      avatarAsset: '',
      currentLocation: '',
      currentActivity: '',
      currentMood: '',
      schedulePhase: '',
      isWorking: false,
      isOnBreak: false,
      isOvertime: false,
      isWeekend: false,
      nextLocation: '',
      nextActivity: '',
      nextChangeTime: '',
      scheduleReason: '',
      careerLevel: '',
      careerLevelName: '',
      employmentStatus: '',
      hireDate: '',
      salaryLevel: 0,
      officeEconomyLines: const <String>[],
      performanceScore: 0,
      capabilityScore: 0,
      promotionHistory: const <ResidentCareerEvent>[],
      careerTags: const <String>[],
      personalityTraits: const <String>[],
      dominantPersonality: '',
      personalitySummary: '还不太了解。',
      friendshipStage: 'stranger',
      friendshipScore: 0,
      trust: 0,
      familiarity: 0,
      relationshipTags: const <String>[],
      relationshipTrend: 'stable',
      sharedTopics: const <String>[],
      sharedMemories: const <String>[],
      recentMemories: const <ResidentMemoryView>[],
      recentInteractions: const <ResidentMemoryView>[],
      recentStories: const <OfficeStoryView>[],
      recentRumors: const <OfficeRumorView>[],
      recentEvents: const <OfficeEventView>[],
      currentCooldowns: const <InteractionCooldownView>[],
      shareFishOptions: const <FishShareOptionView>[],
      availableInteractions: const <ResidentInteractionView>[],
      blockedInteractions: const <ResidentInteractionView>[],
      visibleProfileFields: const <String, String>{},
      privateProfileFields: const <String, String>{},
      storyHints: const <String>[],
      recommendedActions: const <OfficeActionView>[],
      conflictState: 'none',
      active: false,
      lastUpdatedAt: '',
    );
  }

  final String residentId;
  final String name;
  final String nickname;
  final String gender;
  final String age;
  final String job;
  final String description;
  final String avatarAsset;
  final String currentLocation;
  final String currentActivity;
  final String currentMood;
  final String schedulePhase;
  final bool isWorking;
  final bool isOnBreak;
  final bool isOvertime;
  final bool isWeekend;
  final String nextLocation;
  final String nextActivity;
  final String nextChangeTime;
  final String scheduleReason;
  final String careerLevel;
  final String careerLevelName;
  final String employmentStatus;
  final String hireDate;
  final int salaryLevel;
  final List<String> officeEconomyLines;
  final int performanceScore;
  final int capabilityScore;
  final List<ResidentCareerEvent> promotionHistory;
  final List<String> careerTags;
  final List<String> personalityTraits;
  final String dominantPersonality;
  final String personalitySummary;
  final String friendshipStage;
  final int friendshipScore;
  final int trust;
  final int familiarity;
  final List<String> relationshipTags;
  final String relationshipTrend;
  final List<String> sharedTopics;
  final List<String> sharedMemories;
  final List<ResidentMemoryView> recentMemories;
  final List<ResidentMemoryView> recentInteractions;
  final List<OfficeStoryView> recentStories;
  final List<OfficeRumorView> recentRumors;
  final List<OfficeEventView> recentEvents;
  final List<InteractionCooldownView> currentCooldowns;
  final List<FishShareOptionView> shareFishOptions;
  final List<ResidentInteractionView> availableInteractions;
  final List<ResidentInteractionView> blockedInteractions;
  final Map<String, String> visibleProfileFields;
  final Map<String, String> privateProfileFields;
  final List<String> storyHints;
  final List<OfficeActionView> recommendedActions;
  final String conflictState;
  final bool active;
  final String lastUpdatedAt;
}

class FishShareOptionView {
  const FishShareOptionView({
    required this.fishId,
    required this.name,
    required this.nickname,
    required this.rarity,
    required this.weightLabel,
    required this.quantity,
    required this.sharable,
    required this.residentPreference,
    required this.preferenceScore,
    required this.alreadySharedToday,
    required this.dailyLimitReached,
    required this.unavailableReason,
  });

  final String fishId;
  final String name;
  final String nickname;
  final String rarity;
  final String weightLabel;
  final int quantity;
  final bool sharable;
  final String residentPreference;
  final int preferenceScore;
  final bool alreadySharedToday;
  final bool dailyLimitReached;
  final String unavailableReason;

  bool get available =>
      sharable && quantity > 0 && !alreadySharedToday && !dailyLimitReached;
}

class ResidentInteractionView {
  const ResidentInteractionView({
    required this.id,
    required this.label,
    required this.description,
    required this.available,
    required this.reason,
    required this.cooldownText,
    required this.impactHint,
    required this.tags,
  });

  final String id;
  final String label;
  final String description;
  final bool available;
  final String reason;
  final String cooldownText;
  final String impactHint;
  final List<String> tags;
}

class InteractionCooldownView {
  const InteractionCooldownView({
    required this.interactionId,
    required this.label,
    required this.remainingText,
    required this.reason,
  });

  final String interactionId;
  final String label;
  final String remainingText;
  final String reason;
}

class ResidentMemoryView {
  const ResidentMemoryView({
    required this.time,
    required this.type,
    required this.summary,
    required this.source,
    required this.important,
  });

  final String time;
  final String type;
  final String summary;
  final String source;
  final bool important;
}

class ResidentOfficeView {
  const ResidentOfficeView({
    required this.id,
    required this.name,
    required this.nickname,
    required this.locationId,
    required this.locationName,
    required this.activity,
    required this.mood,
    required this.relationshipLevel,
    required this.friendshipStage,
    required this.friendshipScore,
    required this.trust,
    required this.familiarity,
    required this.personalitySummary,
    required this.recentInteraction,
    required this.availableActions,
    required this.visibleDetails,
  });

  factory ResidentOfficeView.fromRuntime({
    required ResidentProfile resident,
    required ResidentCurrentState state,
    required String locationName,
    required String relationshipLevel,
    required FriendshipState friendship,
    required ResidentPersonalityContext personality,
    required List<String> availableActions,
    required String recentInteraction,
  }) {
    final visible =
        friendshipStageRank(friendship.stage) >= friendshipStageRank('familiar')
            ? <String, Object?>{
                'trust': friendship.trust,
                'familiarity': friendship.familiarity,
                'tags':
                    friendship.relationshipTags.take(6).toList(growable: false),
              }
            : <String, Object?>{
                'hint': '关系更熟之后，会了解更多关于 ${resident.name} 的事。',
              };
    return ResidentOfficeView(
      id: resident.id,
      name: resident.name,
      nickname: resident.raw['nickname']?.toString() ?? resident.name,
      locationId: state.location,
      locationName: locationName,
      activity: state.activity,
      mood: state.mood,
      relationshipLevel: relationshipLevel,
      friendshipStage: friendship.stage,
      friendshipScore: friendship.score,
      trust: friendship.trust,
      familiarity: friendship.familiarity,
      personalitySummary: personality.traits.take(4).join(' / '),
      recentInteraction: recentInteraction,
      availableActions: availableActions,
      visibleDetails: visible,
    );
  }

  final String id;
  final String name;
  final String nickname;
  final String locationId;
  final String locationName;
  final String activity;
  final String mood;
  final String relationshipLevel;
  final String friendshipStage;
  final int friendshipScore;
  final int trust;
  final int familiarity;
  final String personalitySummary;
  final String recentInteraction;
  final List<String> availableActions;
  final Map<String, Object?> visibleDetails;
}

class OfficeGroupView {
  const OfficeGroupView({
    required this.group,
    required this.memberNames,
    required this.canJoin,
    required this.joinCondition,
    required this.possibleImpact,
  });

  final OfficeGroup group;
  final List<String> memberNames;
  final bool canJoin;
  final String joinCondition;
  final String possibleImpact;
}

class OfficeEventView {
  const OfficeEventView({
    required this.id,
    required this.title,
    required this.summary,
    required this.locationId,
    required this.residentIds,
    required this.importance,
    required this.availableActions,
    required this.possibleImpact,
  });

  final String id;
  final String title;
  final String summary;
  final String locationId;
  final List<String> residentIds;
  final int importance;
  final List<String> availableActions;
  final String possibleImpact;
}

class OfficeStoryView {
  const OfficeStoryView({
    required this.id,
    required this.title,
    required this.summary,
    required this.residentId,
    required this.publicHint,
  });

  final String id;
  final String title;
  final String summary;
  final String residentId;
  final String publicHint;
}

class OfficeRumorView {
  const OfficeRumorView({
    required this.id,
    required this.title,
    required this.status,
    required this.tags,
  });

  final String id;
  final String title;
  final String status;
  final List<String> tags;
}

class OfficeHistoryView {
  const OfficeHistoryView({
    required this.date,
    required this.mood,
    required this.summary,
    required this.playerImpact,
  });

  final String date;
  final String mood;
  final String summary;
  final String playerImpact;
}

class OfficeActionView {
  const OfficeActionView({
    required this.id,
    required this.label,
    required this.targetType,
    this.targetId = '',
    this.available = true,
    this.reason = '',
  });

  final String id;
  final String label;
  final String targetType;
  final String targetId;
  final bool available;
  final String reason;
}

class InteractiveOfficeLabels {
  const InteractiveOfficeLabels._();

  static String reputation(String id) {
    return const <String, String>{
          'reliable': '值得信赖',
          'helpful': '热心帮手',
          'funny': '办公室开心果',
          'professional': '专业靠谱',
          'popular': '办公室红人',
          'quiet': '安静摸鱼员',
          'mysterious': '神秘同事',
          'hardworking': '认真工作者',
          'relaxed': '轻松生活家',
          'lazy': '慢慢来的人',
          'late_comer': '迟到边缘人',
          'fishing_master': '摸鱼大师',
          'rumor_keeper': '传闻守护者',
          'team_player': '团队同行者',
          'problem_solver': '问题解决者',
          'trusted_friend': '值得托付的朋友',
          'trusted_by_office': '大家放心的人',
        }[id] ??
        id;
  }

  static String skill(String id) {
    return const <String, String>{
          'fishing': '钓鱼',
          'communication': '沟通',
          'observation': '观察',
          'efficiency': '效率',
          'management': '管理',
          'luck': '运气',
        }[id] ??
        id;
  }

  static String rarity(String id) {
    return const <String, String>{
          'common': '普通',
          'uncommon': '优秀',
          'rare': '稀有',
          'epic': '史诗',
          'legend': '传说',
          'legendary': '传说',
          'mythic': '神话',
          'mythical': '神话',
        }[id] ??
        id;
  }

  static String action(String id) {
    return const <String, String>{
          'talk': '聊一会',
          'short_talk': '打个招呼',
          'invite_coffee': '请喝咖啡',
          'help_work': '帮忙处理工作',
          'join_break': '一起休息',
          'comfort': '安慰一下',
          'share_rumor': '分享传闻',
          'ask_about_rumor': '询问传闻',
          'verify_rumor': '确认传闻',
          'share_fish': '聊聊鱼',
          'remember_preference': '记住偏好',
          'apologize': '认真道歉',
          'resolve_conflict': '化解误会',
          'observe': '观察一下',
          'start_story': '听听故事',
          'join_group': '加入活动',
          'observe_group': '旁听一下',
          'talk_in_group': '参与聊天',
          'help_group': '帮大家一把',
          'participate': '参与事件',
          'ignore': '先不打扰',
        }[id] ??
        id;
  }

  static String mood(String id) {
    return const <String, String>{
          'calm': '平静',
          'happy': '开心',
          'curious': '好奇',
          'excited': '兴奋',
          'tired': '疲惫',
          'busy': '忙碌',
          'lonely': '有点孤单',
          'worried': '担心',
          'sad': '低落',
          'angry': '不太高兴',
          'grateful': '感激',
          'playful': '想开玩笑',
          'festive': '有节日感',
          'social': '热闹',
          'tense': '紧张',
          'stormy': '受天气影响',
          'cheerful': '轻松',
          'quiet': '安静',
        }[id] ??
        id;
  }

  static String actionDescription(String id) {
    return const <String, String>{
          'talk': '坐下来聊几句，看看今天的心情。',
          'short_talk': '轻轻打个招呼，不打扰对方。',
          'invite_coffee': '在休息时间请对方喝杯咖啡。',
          'help_work': '帮对方处理一点手边的工作。',
          'join_break': '一起休息一会儿，让办公室慢下来。',
          'comfort': '在对方低落时安静陪一会儿。',
          'share_rumor': '分享一条你知道的办公室消息。',
          'ask_about_rumor': '问问对方最近听到了什么。',
          'verify_rumor': '和居民一起确认一条传闻是否可靠。',
          'share_fish': '把鱼获变成轻松的话题。',
          'remember_preference': '记住对方提过的小偏好。',
          'apologize': '为之前的不愉快慢慢修复关系。',
          'resolve_conflict': '尝试把误会说清楚。',
          'observe': '先观察，不急着打扰。',
          'start_story': '听听对方愿意讲的小故事。',
        }[id] ??
        '和居民进行一次轻互动。';
  }

  static String actionImpact(String id) {
    return const <String, String>{
          'talk': '可能改善熟悉度，并获得一点沟通经验。',
          'short_talk': '保持轻松联系，不制造压力。',
          'invite_coffee': '可能改善友情、信任和沟通经验。',
          'help_work': '可能提升信任、职业反馈和效率经验。',
          'join_break': '可能改善熟悉度和办公室氛围。',
          'comfort': '可能改善信任，并留下温情记忆。',
          'share_rumor': '可能影响传闻热度和玩家声誉。',
          'ask_about_rumor': '可能获得传闻线索。',
          'verify_rumor': '可能让传闻更清楚，也可能让关系更谨慎。',
          'share_fish': '可能形成共同话题，并影响任务/成就摘要。',
          'remember_preference': '可能让后续对白更贴近对方。',
          'apologize': '可能缓慢修复当前冲突。',
          'resolve_conflict': '可能让紧张状态进入恢复。',
          'observe': '可能获得观察经验，不打扰对方。',
          'start_story': '可能触发一个居民故事。',
        }[id] ??
        '可能轻微影响关系、记忆或办公室状态。';
  }

  static String friendshipStage(String id) {
    return const <String, String>{
          'stranger': '刚认识',
          'acquaintance': '点头之交',
          'familiar': '熟悉',
          'friend': '朋友',
          'close_friend': '老朋友',
          'trusted_friend': '值得托付',
        }[id] ??
        id;
  }

  static String schedulePhase(String id) {
    return const <String, String>{
          'morning': '清晨',
          'commute': '通勤',
          'work_start': '准备上班',
          'working': '工作中',
          'coffee_break': '咖啡休息',
          'lunch': '午休',
          'afternoon_work': '下午工作',
          'overtime': '加班',
          'off_work': '下班',
          'evening': '傍晚',
          'home': '在家',
          'sleep': '休息',
          'weekend': '周末',
          'holiday': '节日',
        }[id] ??
        (id.isEmpty ? '暂无日程' : id);
  }

  static String personality(String id) {
    return const <String, String>{
          'outgoing': '喜欢热闹交流',
          'introverted': '更喜欢安静、短时间交流',
          'hardworking': '更重视工作节奏',
          'lazy': '偏爱轻松节奏',
          'gossipy': '对办公室消息更敏感',
          'serious': '做事谨慎认真',
          'curious': '对新鲜事很有兴趣',
          'calm': '情绪稳定温和',
          'playful': '喜欢轻松开玩笑',
          'kind': '容易照顾别人',
          'competitive': '喜欢把事情做好',
          'cautious': '更谨慎地参与社交',
          'sensitive': '更在意细微情绪',
        }[id] ??
        id;
  }

  static String relationshipTag(String id) {
    final raw =
        id.startsWith('friendship:') ? id.substring('friendship:'.length) : id;
    if (id.startsWith('topic:')) return '共同话题：${id.substring(6)}';
    if (id.startsWith('memory:')) return '共同记忆';
    if (id.startsWith('conflict:')) {
      return '关系状态：${conflict(id.substring('conflict:'.length))}';
    }
    return friendshipStages.contains(raw) ? friendshipStage(raw) : id;
  }

  static String conflict(String id) {
    return const <String, String>{
          'none': '没有冲突',
          'minor_tension': '有一点小别扭',
          'conflict': '有误会需要慢慢修复',
          'recovering': '正在恢复',
        }[id] ??
        id;
  }

  static String trend(String id) {
    return const <String, String>{
          'up': '上升',
          'down': '下降',
          'stable': '稳定',
        }[id] ??
        '稳定';
  }

  static String statusReason(String id) {
    return const <String, String>{
          'schedule_working': '正在按日程工作',
          'schedule_break': '到了休息时间',
          'schedule_weekend': '今天按周末节奏生活',
          'schedule_overtime': '今天有一点加班',
          'personality_introverted': '更倾向安静独处',
          'personality_outgoing': '更愿意和大家待在一起',
          'weather_rain': '天气影响了外出计划',
          'festival_gathering': '正在参加节日活动',
        }[id] ??
        (id.isEmpty ? '按当前世界状态自然行动' : id);
  }
}
