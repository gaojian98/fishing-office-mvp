import 'package:flutter/foundation.dart';

import '../../models/career_state.dart';
import '../../models/living_office_state.dart';
import '../../models/rumor_config.dart';
import '../../models/resident_story_config.dart';
import 'app_managers.dart';
import 'economy_runtime_manager.dart';
import 'festival_runtime_manager.dart';
import 'resident_runtime_manager.dart';
import 'rumor_runtime_manager.dart';
import 'story_runtime_manager.dart';
import 'weather_runtime_manager.dart';
import 'world_clock_manager.dart';
import 'world_save_manager.dart';
import 'world_tick_manager.dart';

class DailyWorldSummary {
  const DailyWorldSummary({
    required this.date,
    required this.weather,
    required this.festival,
    required this.activeRumors,
    required this.residentHighlights,
    required this.storyHints,
    required this.todayMessage,
    this.currentJobTitle = '',
    this.performanceChange = 0,
    this.careerExperienceGained = 0,
    this.salaryPaid = 0,
    this.promotionAvailable = false,
    this.careerFeedback,
    this.skillExperienceGained = const <String, int>{},
    this.skillLevelUps = const <String>[],
    this.promotionMissingRequirements = const <String>[],
    this.recommendedActions = const <String>[],
    this.livingOfficeState,
    this.dominantOfficeMood = '',
    this.averageActivityLevel = 0,
    this.averageProductivityLevel = 0,
    this.averageSocialLevel = 0,
    this.averageTensionLevel = 0,
    this.importantOfficeEvents = const <String>[],
    this.groupActivities = const <String>[],
    this.relationshipChanges = const <String>[],
    this.popularLocations = const <String>[],
    this.popularTopics = const <String>[],
    this.rumorSummary = const <String>[],
    this.storySummary = const <String>[],
    this.careerSummary = const <String>[],
    this.recommendedPlayerActions = const <String>[],
    this.todayPlayerImpact = const <String, dynamic>{},
  });

  factory DailyWorldSummary.fromJson(Map<String, dynamic> json) {
    return DailyWorldSummary(
      date: json['date']?.toString() ?? '',
      weather: json['weather']?.toString() ?? '',
      festival: json['festival']?.toString() ?? '',
      activeRumors: _stringList(json['activeRumors']),
      residentHighlights: _stringList(json['residentHighlights']),
      storyHints: _stringList(json['storyHints']),
      todayMessage: json['todayMessage']?.toString() ?? '',
      currentJobTitle: json['currentJobTitle']?.toString() ?? '',
      performanceChange: _readIntValue(json['performanceChange']) ?? 0,
      careerExperienceGained:
          _readIntValue(json['careerExperienceGained']) ?? 0,
      salaryPaid: _readIntValue(json['salaryPaid']) ?? 0,
      promotionAvailable: json['promotionAvailable'] == true,
      careerFeedback: json['careerFeedback'] is Map
          ? CareerFeedback.fromJson(
              Map<String, dynamic>.from(json['careerFeedback'] as Map),
            )
          : null,
      skillExperienceGained: _intMap(json['skillExperienceGained']),
      skillLevelUps: _stringList(json['skillLevelUps']),
      promotionMissingRequirements:
          _stringList(json['promotionMissingRequirements']),
      recommendedActions: _stringList(json['recommendedActions']),
      livingOfficeState: json['livingOfficeState'] is Map
          ? LivingOfficeState.fromJson(
              Map<String, dynamic>.from(json['livingOfficeState'] as Map),
            )
          : null,
      dominantOfficeMood: json['dominantOfficeMood']?.toString() ?? '',
      averageActivityLevel: _readIntValue(json['averageActivityLevel']) ?? 0,
      averageProductivityLevel:
          _readIntValue(json['averageProductivityLevel']) ?? 0,
      averageSocialLevel: _readIntValue(json['averageSocialLevel']) ?? 0,
      averageTensionLevel: _readIntValue(json['averageTensionLevel']) ?? 0,
      importantOfficeEvents: _stringList(json['importantOfficeEvents']),
      groupActivities: _stringList(json['groupActivities']),
      relationshipChanges: _stringList(json['relationshipChanges']),
      popularLocations: _stringList(json['popularLocations']),
      popularTopics: _stringList(json['popularTopics']),
      rumorSummary: _stringList(json['rumorSummary']),
      storySummary: _stringList(json['storySummary']),
      careerSummary: _stringList(json['careerSummary']),
      recommendedPlayerActions: _stringList(json['recommendedPlayerActions']),
      todayPlayerImpact: _mapOf(json['todayPlayerImpact']),
    );
  }

  final String date;
  final String weather;
  final String festival;
  final List<String> activeRumors;
  final List<String> residentHighlights;
  final List<String> storyHints;
  final String todayMessage;
  final String currentJobTitle;
  final int performanceChange;
  final int careerExperienceGained;
  final int salaryPaid;
  final bool promotionAvailable;
  final CareerFeedback? careerFeedback;
  final Map<String, int> skillExperienceGained;
  final List<String> skillLevelUps;
  final List<String> promotionMissingRequirements;
  final List<String> recommendedActions;
  final LivingOfficeState? livingOfficeState;
  final String dominantOfficeMood;
  final int averageActivityLevel;
  final int averageProductivityLevel;
  final int averageSocialLevel;
  final int averageTensionLevel;
  final List<String> importantOfficeEvents;
  final List<String> groupActivities;
  final List<String> relationshipChanges;
  final List<String> popularLocations;
  final List<String> popularTopics;
  final List<String> rumorSummary;
  final List<String> storySummary;
  final List<String> careerSummary;
  final List<String> recommendedPlayerActions;
  final Map<String, dynamic> todayPlayerImpact;

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'weather': weather,
      'festival': festival,
      'activeRumors': activeRumors,
      'residentHighlights': residentHighlights,
      'storyHints': storyHints,
      'todayMessage': todayMessage,
      'currentJobTitle': currentJobTitle,
      'performanceChange': performanceChange,
      'careerExperienceGained': careerExperienceGained,
      'salaryPaid': salaryPaid,
      'promotionAvailable': promotionAvailable,
      'careerFeedback': careerFeedback?.toJson(),
      'skillExperienceGained': skillExperienceGained,
      'skillLevelUps': skillLevelUps,
      'promotionMissingRequirements': promotionMissingRequirements,
      'recommendedActions': recommendedActions,
      'livingOfficeState': livingOfficeState?.toJson(),
      'dominantOfficeMood': dominantOfficeMood,
      'averageActivityLevel': averageActivityLevel,
      'averageProductivityLevel': averageProductivityLevel,
      'averageSocialLevel': averageSocialLevel,
      'averageTensionLevel': averageTensionLevel,
      'importantOfficeEvents': importantOfficeEvents,
      'groupActivities': groupActivities,
      'relationshipChanges': relationshipChanges,
      'popularLocations': popularLocations,
      'popularTopics': popularTopics,
      'rumorSummary': rumorSummary,
      'storySummary': storySummary,
      'careerSummary': careerSummary,
      'recommendedPlayerActions': recommendedPlayerActions,
      'todayPlayerImpact': todayPlayerImpact,
    };
  }
}

class DailyChange {
  const DailyChange({
    required this.id,
    required this.date,
    required this.type,
    required this.description,
  });

  factory DailyChange.fromJson(Map<String, dynamic> json) {
    return DailyChange(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  final String id;
  final String date;
  final String type;
  final String description;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'type': type,
      'description': description,
    };
  }
}

class DailySimulationManager extends ChangeNotifier {
  DailySimulationManager({
    required WorldTickManager worldTickManager,
    required WorldClockManager worldClockManager,
    required FestivalRuntimeManager festivalRuntimeManager,
    required WeatherRuntimeManager weatherRuntimeManager,
    required RumorRuntimeManager rumorRuntimeManager,
    required ResidentRuntimeManager residentRuntimeManager,
    required StoryRuntimeManager storyRuntimeManager,
    required WorldSaveManager worldSaveManager,
  })  : _worldTickManager = worldTickManager,
        _worldClockManager = worldClockManager,
        _festivalRuntimeManager = festivalRuntimeManager,
        _weatherRuntimeManager = weatherRuntimeManager,
        _rumorRuntimeManager = rumorRuntimeManager,
        _residentRuntimeManager = residentRuntimeManager,
        _storyRuntimeManager = storyRuntimeManager,
        _worldSaveManager = worldSaveManager {
    _restoreState(worldSaveManager.dailySimulationState);
  }

  final WorldTickManager _worldTickManager;
  final WorldClockManager _worldClockManager;
  final FestivalRuntimeManager _festivalRuntimeManager;
  final WeatherRuntimeManager _weatherRuntimeManager;
  final RumorRuntimeManager _rumorRuntimeManager;
  final ResidentRuntimeManager _residentRuntimeManager;
  final StoryRuntimeManager _storyRuntimeManager;
  final WorldSaveManager _worldSaveManager;

  int? _lastRunDay;
  DailyWorldSummary? _todaySummary;
  final List<DailyChange> _changes = <DailyChange>[];
  EconomyRuntimeManager? _economyRuntimeManager;
  int _lastCareerSettlementDurationMs = 0;
  int _lastCareerPerformanceChange = 0;
  int _lastCareerExperienceGained = 0;
  int _lastSalaryPaid = 0;
  CareerFeedback? _lastCareerFeedback;

  bool hasRunToday() => _lastRunDay == _worldClockManager.today().dayCount;

  DailyWorldSummary? getTodayWorldSummary() => _todaySummary;

  List<DailyChange> getDailyChanges() => List<DailyChange>.from(_changes);

  int get lastCareerSettlementDurationMs => _lastCareerSettlementDurationMs;

  void setEconomyRuntimeManager(EconomyRuntimeManager manager) {
    _economyRuntimeManager = manager;
  }

  Future<DailyWorldSummary> runDailySimulation({
    WalletManagerView? wallet,
    TransactionManagerView? transactions,
  }) async {
    if (hasRunToday() && _todaySummary != null) {
      return _todaySummary!;
    }

    await _worldTickManager.runTick(
      TickType.dayTick,
      advanceClock: false,
    );
    _runCareerDailySettlement(
      wallet: wallet,
      transactions: transactions,
    );

    final summary = _buildSummary();
    _lastRunDay = _worldClockManager.today().dayCount;
    _todaySummary = summary;
    _recordChanges(summary);
    _persistState();
    await _worldSaveManager.autoSave();

    if (kDebugMode) {
      debugPrint(
        'DailySimulationManager | date=${summary.date} weather=${summary.weather} festival=${summary.festival}',
      );
    }
    notifyListeners();
    return summary;
  }

  DailyWorldSummary _buildSummary() {
    final calendar = _worldClockManager.today();
    final weather = _weatherRuntimeManager.getCurrentWeather();
    final festival = _festivalRuntimeManager.getTodayFestival();
    final rumors = _rumorRuntimeManager.getActiveRumors();
    final residentHighlights =
        _residentRuntimeManager.residents.take(5).map((resident) {
      final state =
          _residentRuntimeManager.getResidentCurrentState(resident.id);
      return '${resident.name}：${state.location} / ${state.activity} / ${state.mood}';
    }).toList(growable: false);
    final storyHints = _storyHints();
    final date = _dateLabel();
    final career = _worldSaveManager.careerState;
    final promotion = _worldSaveManager.getPromotionRequirements();
    final feedback =
        _lastCareerFeedback ?? _worldSaveManager.latestCareerFeedback;
    final livingOffice = _worldSaveManager.livingOfficeState;
    final playerInfluence = _worldSaveManager.playerInfluenceContext;
    final groups = _worldSaveManager.activeGroups;
    return DailyWorldSummary(
      date: date,
      weather: weather?.name ?? '',
      festival: festival?.name ?? '',
      activeRumors: rumors
          .take(5)
          .map(_rumorLabel)
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      residentHighlights: residentHighlights,
      storyHints: storyHints,
      todayMessage: _todayMessage(
        weatherName: weather?.name ?? '',
        festivalName: festival?.name ?? '',
        rumorCount: rumors.length,
        dayCount: calendar.dayCount,
      ),
      currentJobTitle: career.jobTitle,
      performanceChange: _lastCareerPerformanceChange,
      careerExperienceGained: _lastCareerExperienceGained,
      salaryPaid: _lastSalaryPaid,
      promotionAvailable: career.promotionEligible,
      careerFeedback: feedback,
      skillExperienceGained: feedback?.skillsGained ?? const <String, int>{},
      skillLevelUps: feedback?.skillLevelUps ?? const <String>[],
      promotionMissingRequirements: promotion.missingRequirements,
      recommendedActions: feedback?.recommendedActions ??
          _recommendedActions(career, promotion),
      livingOfficeState: livingOffice.isEmpty ? null : livingOffice,
      dominantOfficeMood: livingOffice.officeMood,
      averageActivityLevel: livingOffice.activityLevel,
      averageProductivityLevel: livingOffice.productivityLevel,
      averageSocialLevel: livingOffice.socialLevel,
      averageTensionLevel: livingOffice.tensionLevel,
      importantOfficeEvents: livingOffice.importantChanges,
      groupActivities:
          groups.map((group) => group.activity).toSet().toList(growable: false),
      relationshipChanges: _worldSaveManager.socialInteractionHistory
          .take(5)
          .map((record) => '${record.residentId}:${record.reason}')
          .toList(growable: false),
      popularLocations: livingOffice.popularLocations,
      popularTopics: livingOffice.popularTopics,
      rumorSummary: livingOffice.dominantRumors,
      storySummary: storyHints,
      careerSummary: <String>[
        career.jobTitle,
        if (_lastCareerPerformanceChange != 0)
          'performance:$_lastCareerPerformanceChange',
        if (_lastCareerExperienceGained > 0)
          'experience:$_lastCareerExperienceGained',
      ],
      recommendedPlayerActions: feedback?.recommendedActions ??
          _recommendedActions(career, promotion),
      todayPlayerImpact: <String, dynamic>{
        'helpedCount': playerInfluence.recentActions
            .where((action) => action.type == 'helping')
            .length,
        'friendCount': playerInfluence.friendCount,
        'influencedEvents': playerInfluence.recentEvents.length,
        'officeReputation': playerInfluence.reputation,
        'officeInfluence': playerInfluence.officeInfluence.toJson(),
      },
    );
  }

  List<String> _storyHints() {
    final hints = <String>[];
    for (final resident in _residentRuntimeManager.residents) {
      final stories = _storyRuntimeManager.getAvailableStories(resident.id);
      for (final story in stories.take(2)) {
        hints.add(_storyLabel(story));
        if (hints.length >= 5) return hints;
      }
    }
    return hints;
  }

  void _recordChanges(DailyWorldSummary summary) {
    final date = summary.date;
    final next = <DailyChange>[
      DailyChange(
        id: '${date}_weather',
        date: date,
        type: 'weather',
        description: summary.weather.isEmpty
            ? '今天的天气保持安静。'
            : '今天的天气是：${summary.weather}。',
      ),
      DailyChange(
        id: '${date}_festival',
        date: date,
        type: 'festival',
        description: summary.festival.isEmpty
            ? '今天没有特别节日。'
            : '今天的节日是：${summary.festival}。',
      ),
      DailyChange(
        id: '${date}_rumor',
        date: date,
        type: 'rumor',
        description: '今天有 ${summary.activeRumors.length} 条传闻正在流动。',
      ),
      DailyChange(
        id: '${date}_resident',
        date: date,
        type: 'resident',
        description: '今天记录了 ${summary.residentHighlights.length} 位居民的状态。',
      ),
      DailyChange(
        id: '${date}_story',
        date: date,
        type: 'story',
        description: '今天有 ${summary.storyHints.length} 条故事线索。',
      ),
      DailyChange(
        id: '${date}_career',
        date: date,
        type: 'career',
        description: summary.salaryPaid > 0
            ? '今天发放了 ${summary.salaryPaid} 枚摸鱼币工资。'
            : '今天的办公室节奏继续慢慢前进。',
      ),
      DailyChange(
        id: '${date}_living_office',
        date: date,
        type: 'living_office',
        description:
            '今天办公室整体氛围是 ${summary.dominantOfficeMood}，活跃度 ${summary.averageActivityLevel}。',
      ),
    ];
    _changes
      ..removeWhere((change) => change.date == date)
      ..addAll(next);
  }

  void _restoreState(Map<String, dynamic> state) {
    if (state.isEmpty) return;
    _lastRunDay = _readInt(state['lastRunDay']);
    final summary = state['todaySummary'];
    if (summary is Map) {
      _todaySummary = DailyWorldSummary.fromJson(
        Map<String, dynamic>.from(summary),
      );
    }
    final changes = state['dailyChanges'];
    if (changes is List) {
      _changes
        ..clear()
        ..addAll(
          changes.whereType<Map>().map(
                (item) => DailyChange.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              ),
        );
    }
  }

  void _persistState() {
    _worldSaveManager.setDailySimulationState({
      'lastRunDay': _lastRunDay,
      'todaySummary': _todaySummary?.toJson(),
      'dailyChanges':
          _changes.map((change) => change.toJson()).toList(growable: false),
      'lastCareerSettlementDurationMs': _lastCareerSettlementDurationMs,
    });
  }

  void _runCareerDailySettlement({
    WalletManagerView? wallet,
    TransactionManagerView? transactions,
  }) {
    final startedAt = DateTime.now();
    final before = _worldSaveManager.careerState;
    final beforeSkillHistory = _worldSaveManager.skillExperienceHistory.length;
    final day = _worldClockManager.today().dayCount;
    final isWeekend = _worldClockManager.today().isWeekend;
    final hasFestival = _festivalRuntimeManager.getActiveFestivals().isNotEmpty;
    final performanceDelta = isWeekend
        ? 0
        : hasFestival
            ? 1
            : 0;
    final experience = isWeekend ? 1 : 2;
    final settled = _worldSaveManager.settleCareerDay(
      dayCount: day,
      dateLabel: _dateLabel(),
      experience: experience,
      performanceDelta: performanceDelta,
    );
    _lastCareerPerformanceChange =
        settled.performanceScore - before.performanceScore;
    _lastCareerExperienceGained = settled.experience - before.experience;
    _lastSalaryPaid = 0;
    if (wallet != null && transactions != null && day % 7 == 0) {
      final amount = _economyRuntimeManager?.getSalaryForCareerState(settled) ??
          settled.salary;
      final salary = _worldSaveManager.paySalaryForCurrentPeriod(
        dayCount: day,
        amount: amount,
        wallet: wallet,
        transactions: transactions,
      );
      _lastSalaryPaid = salary?.amount ?? 0;
    }
    final promotion = _worldSaveManager.getPromotionRequirements();
    final newSkillRecords = _worldSaveManager.skillExperienceHistory
        .take(_worldSaveManager.skillExperienceHistory.length -
            beforeSkillHistory)
        .toList(growable: false);
    final skillsGained = <String, int>{};
    final levelUps = <String>[];
    for (final record in newSkillRecords) {
      skillsGained[record.skillId] =
          (skillsGained[record.skillId] ?? 0) + record.amount;
      if (record.levelAfter > record.levelBefore) {
        levelUps.add('${record.skillId}:${record.levelAfter}');
      }
    }
    _lastCareerFeedback = _worldSaveManager.recordCareerFeedback(
      CareerFeedback(
        date: _dateLabel(),
        currentJobTitle: settled.jobTitle,
        performanceScore: settled.performanceScore,
        performanceChange: _lastCareerPerformanceChange,
        careerExperienceGained: _lastCareerExperienceGained,
        salaryPaid: _lastSalaryPaid,
        promotionProgress: promotion.progress,
        promotionEligible: promotion.eligible,
        skillsGained: skillsGained,
        skillLevelUps: levelUps,
        completedCareerTasks:
            settled.completedCareerTasks - before.completedCareerTasks,
        positiveReasons: _positiveReasons(
          performanceChange: _lastCareerPerformanceChange,
          skillRecords: newSkillRecords,
          salaryPaid: _lastSalaryPaid,
        ),
        warningReasons: _warningReasons(promotion),
        recommendedActions: _recommendedActions(settled, promotion),
      ),
    );
    _lastCareerSettlementDurationMs =
        DateTime.now().difference(startedAt).inMilliseconds;
  }

  List<String> _positiveReasons({
    required int performanceChange,
    required List<SkillExperienceRecord> skillRecords,
    required int salaryPaid,
  }) {
    final reasons = <String>[];
    if (performanceChange > 0) reasons.add('今天完成了工作节奏，绩效小幅提升。');
    if (skillRecords.isNotEmpty) {
      reasons.add('今天有 ${skillRecords.length} 次明确行为带来了技能成长。');
    }
    if (salaryPaid > 0) reasons.add('本周期工资已发放，资产记录同步完成。');
    if (reasons.isEmpty) reasons.add('今天的办公室生活平稳推进。');
    return reasons;
  }

  List<String> _warningReasons(CareerPromotionCheck promotion) {
    if (promotion.eligible || promotion.missingRequirements.isEmpty) {
      return const <String>[];
    }
    return promotion.missingRequirements.take(3).map((item) {
      if (item.startsWith('skill_')) {
        return '下一职位还需要补齐 ${item.replaceFirst('skill_', '')}。';
      }
      if (item.startsWith('career_task_completion:')) {
        return '距离晋升还需要更多职业任务经验。';
      }
      if (item.startsWith('performance_score:')) {
        return '绩效还需要一点稳定成长。';
      }
      return '晋升条件仍在慢慢积累。';
    }).toList(growable: false);
  }

  List<String> _recommendedActions(
    CareerState career,
    CareerPromotionCheck promotion,
  ) {
    if (promotion.eligible) return const <String>['可以考虑申请下一次晋升。'];
    final actions = <String>[];
    for (final skillId in career.careerRecommendedSkills.take(2)) {
      actions.add('多做与 $skillId 相关的小事，慢慢积累能力。');
    }
    if (actions.isEmpty) actions.add('保持今天的节奏，慢慢观察第二世界。');
    return actions;
  }

  String _dateLabel() {
    final calendar = _worldClockManager.today();
    return 'Y${calendar.year}-M${calendar.month}-D${calendar.day}-#${calendar.dayCount}';
  }

  String _todayMessage({
    required String weatherName,
    required String festivalName,
    required int rumorCount,
    required int dayCount,
  }) {
    if (festivalName.isNotEmpty) {
      return '今天是$festivalName，第二世界比平时更热闹一点。';
    }
    if (weatherName.isNotEmpty) {
      return '第$dayCount天，$weatherName让海边多了一点新的气息。';
    }
    if (rumorCount > 0) {
      return '第$dayCount天，有些小消息正在居民之间慢慢传开。';
    }
    return '第$dayCount天，第二世界安静地醒来了。';
  }

  String _rumorLabel(RumorEntry rumor) {
    if (rumor.title.isNotEmpty) return rumor.title;
    return rumor.id;
  }

  String _storyLabel(ResidentStoryEntry story) {
    if (story.title.isNotEmpty) return story.title;
    return story.id;
  }

  int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '');
  }
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return value
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

int? _readIntValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '');
}

Map<String, int> _intMap(Object? value) {
  if (value is! Map) return const <String, int>{};
  return value.map(
    (key, amount) => MapEntry(key.toString(), _readIntValue(amount) ?? 0),
  );
}

Map<String, dynamic> _mapOf(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}
