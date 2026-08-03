import 'dart:async';

import 'package:fishing_office_mvp/core/providers/app_providers.dart';
import 'package:fishing_office_mvp/models/career_state.dart';
import 'package:fishing_office_mvp/models/interactive_office.dart';
import 'package:fishing_office_mvp/models/living_office_state.dart';
import 'package:fishing_office_mvp/models/office_group.dart';
import 'package:fishing_office_mvp/models/player_influence.dart';
import 'package:fishing_office_mvp/models/resident_career.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fishing_office_mvp/widgets/office/office_hub_dialog.dart';

void main() {
  testWidgets('resident detail opens and closes without overlay lock',
      (tester) async {
    _useDesignSize(tester);
    var actions = 0;
    final completer = Completer<PlayerActionResult>();
    await tester.pumpWidget(_officeHarness(
      snapshot: _sampleSnapshot(residentCount: 12),
      onAction: (_) async {
        actions += 1;
        return completer.future;
      },
    ));
    await tester.pumpAndSettle();

    expect(find.text('今日办公室'), findsOneWidget);
    await tester.tap(find.text('居民'));
    await tester.pumpAndSettle();
    expect(find.textContaining('办公室居民 0'), findsWidgets);
    expect(find.text('职业'), findsWidgets);
    expect(find.textContaining('正式居民员工'), findsOneWidget);
    expect(find.textContaining('雇佣状态：在职'), findsOneWidget);
    await tester.ensureVisible(find.text('聊一会'));
    await tester.pumpAndSettle();
    expect(find.text('聊一会'), findsOneWidget);

    await tester.tap(find.text('聊一会'));
    await tester.tap(find.text('聊一会'));
    expect(actions, 1);
    completer.complete(_successResult('互动完成'));
    await tester.pumpAndSettle();
    expect(find.textContaining('互动完成'), findsOneWidget);

    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();
    expect(find.text('今日办公室'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(_officeHarness(
      snapshot: _sampleSnapshot(residentCount: 12),
      onAction: (_) async => _successResult('再次打开正常'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('今日办公室'), findsOneWidget);
  });

  testWidgets('resident list handles 100 residents and filter controls',
      (tester) async {
    _useDesignSize(tester);
    await tester.pumpWidget(_officeHarness(
      snapshot: _sampleSnapshot(residentCount: 100),
      onAction: (_) async => _successResult('完成'),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('居民'));
    await tester.pumpAndSettle();
    expect(find.text('全部'), findsOneWidget);
    expect(find.text('可互动'), findsOneWidget);
    expect(find.byType(ListView), findsWidgets);

    await tester.tap(find.text('附近'));
    await tester.pumpAndSettle();
    expect(find.textContaining('办公室居民'), findsWidgets);

    await tester.tap(find.text('排序：友情'));
    await tester.pumpAndSettle();
    expect(find.text('排序：姓名'), findsOneWidget);
  });

  testWidgets('share fish selector confirms once and keeps failures safe',
      (tester) async {
    _useDesignSize(tester);
    final requests = <PlayerActionRequest>[];
    final completer = Completer<PlayerActionResult>();
    await tester.pumpWidget(_officeHarness(
      snapshot: _sampleSnapshot(residentCount: 12),
      onAction: (request) async {
        requests.add(request);
        return completer.future;
      },
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('居民'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('聊聊鱼'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('聊聊鱼'));
    await tester.pumpAndSettle();

    expect(find.text('选择一条鱼获'), findsOneWidget);
    expect(find.textContaining('小银鱼'), findsWidgets);

    await tester.tap(find.text('确认分享'));
    await tester.tap(find.text('确认分享'));

    expect(requests.length, 1);
    expect(requests.single.actionType, 'share_fish');
    expect(requests.single.metadata['fishId'], 'fish_small');
    completer.complete(_successResult('鱼获已经变成今天的小话题'));
    await tester.pumpAndSettle();
    expect(find.textContaining('鱼获已经变成今天的小话题'), findsOneWidget);
  });

  testWidgets(
      'office hub overview shows metrics recommendations and reputation',
      (tester) async {
    _useDesignSize(tester);
    await tester.pumpWidget(_officeHarness(
      snapshot: _sampleSnapshot(residentCount: 12, includeOfficeContent: true),
      onAction: (_) async => _successResult('完成'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('当前办公室状态'), findsOneWidget);
    expect(find.text('活跃度'), findsOneWidget);
    expect(find.text('生产力'), findsOneWidget);
    expect(find.text('今日建议'), findsOneWidget);
    expect(find.textContaining('看看居民'), findsWidgets);
    expect(find.text('办公室评价'), findsOneWidget);
  });

  testWidgets('office hub groups events career and history have readable cards',
      (tester) async {
    _useDesignSize(tester);
    await tester.pumpWidget(_officeHarness(
      snapshot: _sampleSnapshot(residentCount: 12, includeOfficeContent: true),
      onAction: (_) async => _successResult('完成'),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('群体'));
    await tester.pumpAndSettle();
    expect(find.text('午休咖啡小队'), findsOneWidget);
    expect(find.text('可加入'), findsOneWidget);

    await tester.tap(find.text('事件'));
    await tester.pumpAndSettle();
    expect(find.text('打印机旁的小会议'), findsOneWidget);
    expect(find.text('重要事件'), findsOneWidget);

    await tester.tap(find.text('职业'));
    await tester.pumpAndSettle();
    expect(find.text('职业反馈'), findsOneWidget);
    expect(find.textContaining('晋升'), findsWidgets);
    expect(find.text('技能'), findsOneWidget);

    await tester.tap(find.text('历史'));
    await tester.pumpAndSettle();
    expect(find.text('Day 0'), findsOneWidget);
    expect(find.textContaining('玩家影响'), findsWidgets);
  });

  testWidgets('office hub remains usable across target responsive sizes',
      (tester) async {
    for (final size in const [
      Size(360, 800),
      Size(390, 844),
      Size(412, 915),
      Size(768, 1024),
      Size(1440, 900),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(_officeHarness(
        snapshot:
            _sampleSnapshot(residentCount: 20, includeOfficeContent: true),
        onAction: (_) async => _successResult('完成'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('今日办公室'), findsOneWidget);
      expect(find.text('关闭'), findsOneWidget);
      await tester.tap(find.text('居民'));
      await tester.pumpAndSettle();
      expect(find.text('全部'), findsOneWidget);
      await tester.tap(find.text('关闭'));
      await tester.pumpAndSettle();
      expect(find.text('今日办公室'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void _useDesignSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Widget _officeHarness({
  required InteractiveOfficeSnapshot snapshot,
  required Future<PlayerActionResult> Function(PlayerActionRequest) onAction,
}) {
  return ProviderScope(
    overrides: [
      interactiveOfficeSnapshotProvider.overrideWith((ref) async => snapshot),
      residentInteractionProvider.overrideWith((ref, request) async {
        return onAction(request);
      }),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: OfficeHubDialog(),
      ),
    ),
  );
}

InteractiveOfficeSnapshot _sampleSnapshot({
  required int residentCount,
  bool includeOfficeContent = false,
}) {
  final residents = List<ResidentOfficeView>.generate(
    residentCount,
    (index) => ResidentOfficeView(
      id: 'resident_$index',
      name: '办公室居民 $index',
      nickname: '同事$index',
      locationId: index.isEven ? 'office' : 'pantry',
      locationName: index.isEven ? '办公区' : '茶水间',
      activity: index.isEven ? '整理资料' : '喝水休息',
      mood: index.isEven ? 'calm' : 'happy',
      relationshipLevel: 'known',
      friendshipStage: index == 0 ? 'friend' : 'acquaintance',
      friendshipScore: index == 0 ? 32 : 8,
      trust: index == 0 ? 22 : 5,
      familiarity: index == 0 ? 25 : 6,
      personalitySummary: '温和 / 好奇',
      recentInteraction: '',
      availableActions: const ['talk', 'share_fish'],
      visibleDetails: const <String, Object?>{},
    ),
  );
  final details = residents.map((resident) {
    final shareOptions = resident.id == 'resident_0'
        ? const <FishShareOptionView>[
            FishShareOptionView(
              fishId: 'fish_small',
              name: '小银鱼',
              nickname: '银色小话题',
              rarity: 'common',
              weightLabel: '0.2-0.5 kg',
              quantity: 2,
              sharable: true,
              residentPreference: '可以当作今天的小话题',
              preferenceScore: 20,
              alreadySharedToday: false,
              dailyLimitReached: false,
              unavailableReason: '',
            ),
          ]
        : const <FishShareOptionView>[];
    return ResidentDetailViewModel(
      residentId: resident.id,
      name: resident.name,
      nickname: resident.nickname,
      gender: '',
      age: '',
      job: '行政同事',
      description: '每天都会让办公室多一点生活气。',
      avatarAsset: '',
      currentLocation: resident.locationName,
      currentActivity: resident.activity,
      currentMood: resident.mood,
      schedulePhase: 'working',
      isWorking: true,
      isOnBreak: false,
      isOvertime: false,
      isWeekend: false,
      nextLocation: '茶水间',
      nextActivity: '休息一下',
      nextChangeTime: '12:00',
      scheduleReason: '按今日办公室节奏行动',
      careerLevel: 'regular',
      careerLevelName: '正式居民员工',
      employmentStatus: 'active',
      hireDate: 'Y1-M01-D01',
      salaryLevel: 180,
      officeEconomyLines: const [],
      performanceScore: 62,
      capabilityScore: 58,
      promotionHistory: const [
        ResidentCareerEvent(
          type: 'hire',
          date: 'Y1-M01-D01',
          fromPositionId: '',
          toPositionId: 'staff',
          fromCareerLevel: '',
          toCareerLevel: 'regular',
          reason: 'test_hire',
        ),
      ],
      careerTags: const ['career:regular', 'employment:active'],
      personalityTraits: const ['calm', 'curious'],
      dominantPersonality: 'calm',
      personalitySummary: '温和，好奇',
      friendshipStage: resident.friendshipStage,
      friendshipScore: resident.friendshipScore,
      trust: resident.trust,
      familiarity: resident.familiarity,
      relationshipTags: const ['topic:coffee'],
      relationshipTrend: 'stable',
      sharedTopics: const ['咖啡'],
      sharedMemories: const [],
      recentMemories: const [],
      recentInteractions: const [],
      recentStories: const [],
      recentRumors: const [],
      recentEvents: const [],
      currentCooldowns: const [],
      shareFishOptions: shareOptions,
      availableInteractions: const [
        ResidentInteractionView(
          id: 'talk',
          label: '聊一会',
          description: '坐下来聊几句。',
          available: true,
          reason: '当前状态适合这个互动。',
          cooldownText: '可用',
          impactHint: '可能改善熟悉度。',
          tags: [],
        ),
        ResidentInteractionView(
          id: 'share_fish',
          label: '聊聊鱼',
          description: '把鱼获变成轻松的话题。',
          available: true,
          reason: '当前状态适合这个互动。',
          cooldownText: '可用',
          impactHint: '可能形成共同话题。',
          tags: [],
        ),
      ],
      blockedInteractions: const [],
      visibleProfileFields: const {'姓名': '办公室居民', '当前地点': '办公区'},
      privateProfileFields: const {},
      storyHints: const [],
      recommendedActions: const [],
      conflictState: 'none',
      active: true,
      lastUpdatedAt: '2026-08-02T12:00:00',
    );
  }).toList(growable: false);
  return InteractiveOfficeSnapshot(
    date: 'Day 1',
    timeOfDay: 'morning',
    officeState: includeOfficeContent
        ? LivingOfficeState(
            date: 'Day 1',
            timeOfDay: 'morning',
            officeMood: 'social',
            activityLevel: 68,
            productivityLevel: 72,
            socialLevel: 80,
            tensionLevel: 28,
            activeResidentCount: residentCount,
            workingResidentCount: 8,
            breakResidentCount: 3,
            overtimeResidentCount: 0,
            activeGroupCount: 1,
            activeEventCount: 1,
            activeStoryCount: 1,
            popularLocations: const ['pantry'],
            popularTopics: const ['coffee'],
            dominantRumors: const ['rumor_test'],
            currentWeather: '晴天',
            currentFestival: '无节日',
            importantChanges: const ['办公室午休更热闹了。'],
            worldTags: const ['social'],
            lastUpdatedAt: '2026-08-02T12:00:00',
          )
        : LivingOfficeState.empty(),
    playerInfluence: PlayerInfluenceContext.empty(),
    playerCareer: includeOfficeContent
        ? CareerState.initial().copyWith(
            performanceScore: 72,
            experience: 160,
            promotionProgress: 48,
            salary: 120,
          )
        : CareerState.initial(),
    playerSkills: includeOfficeContent
        ? const <String, PlayerSkillState>{
            'communication': PlayerSkillState(
              skillId: 'communication',
              level: 2,
              experience: 120,
              experienceToNextLevel: 250,
              progress: 48,
              lastGainReason: '和居民交流',
              lastGainSourceId: 'test',
              recentGainHistory: [],
              unlockedMilestones: [],
            ),
          }
        : const <String, PlayerSkillState>{},
    playerReputation:
        includeOfficeContent ? const ['helpful'] : const ['quiet'],
    currentEvents: includeOfficeContent
        ? const [
            OfficeEventView(
              id: 'event_print_meeting',
              title: '打印机旁的小会议',
              summary: '大家在打印机旁讨论一个不太紧急的问题。',
              locationId: 'printing_area',
              residentIds: ['resident_0', 'resident_1'],
              importance: 86,
              availableActions: ['participate', 'observe'],
              possibleImpact: '可能改善群体气氛。',
            ),
          ]
        : const [],
    activeGroups: includeOfficeContent
        ? const [
            OfficeGroupView(
              group: OfficeGroup(
                groupId: 'group_coffee',
                locationId: 'pantry',
                members: ['resident_0', 'resident_1', 'resident_2'],
                leaderId: 'resident_0',
                topic: '午休咖啡小队',
                mood: 'happy',
                activity: 'Coffee Break',
                startTime: '12:00',
                expectedEndTime: '12:30',
                createdReason: '午休',
                importance: 65,
                tags: ['coffee'],
              ),
              memberNames: ['办公室居民 0', '办公室居民 1', '办公室居民 2'],
              canJoin: true,
              joinCondition: '你们已经有共同话题。',
              possibleImpact: '可能带来轻松的午休对话。',
            ),
          ]
        : const [],
    availableResidents: residents,
    nearbyResidents: residents.take(8).toList(growable: false),
    availableActions: const [
      OfficeActionView(
        id: 'view_residents',
        label: '看看居民',
        targetType: 'office',
        reason: '今天有居民正在办公室活动。',
      ),
    ],
    residentDetails: details,
    dailySummary: const {'todayMessage': '今天办公室也慢慢运转。'},
    recentStories: const [],
    recentRumors: const [],
    recentAchievements: const [],
    recentChanges: const [],
    officeWorldHistory: includeOfficeContent
        ? const [
            OfficeHistoryView(
              date: 'Day 0',
              mood: 'calm',
              summary: '办公室安静地完成了一天。',
              playerImpact: '你和几位居民打过招呼。',
            ),
          ]
        : const [],
  );
}

PlayerActionResult _successResult(String message) {
  return PlayerActionResult(
    success: true,
    actionId: 'test_action',
    actionType: 'talk',
    message: message,
    positiveChanges: const ['互动已记录。'],
    timestamp: '2026-08-02T12:00:00',
  );
}
