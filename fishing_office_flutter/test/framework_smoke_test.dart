import 'dart:convert';
import 'dart:io';

import 'package:fishing_office_mvp/core/managers/app_managers.dart';
import 'package:fishing_office_mvp/models/fish_catalog_config.dart';
import 'package:fishing_office_mvp/models/fish_collection_config.dart';
import 'package:fishing_office_mvp/models/festival_config.dart';
import 'package:fishing_office_mvp/models/friendship_state.dart';
import 'package:fishing_office_mvp/models/honor_config.dart';
import 'package:fishing_office_mvp/models/inventory_config.dart';
import 'package:fishing_office_mvp/models/interactive_office.dart';
import 'package:fishing_office_mvp/models/location_context.dart';
import 'package:fishing_office_mvp/models/living_world_config.dart';
import 'package:fishing_office_mvp/models/player_influence.dart';
import 'package:fishing_office_mvp/models/resident_config.dart';
import 'package:fishing_office_mvp/models/resident_dialogue_config.dart';
import 'package:fishing_office_mvp/models/resident_life_config.dart';
import 'package:fishing_office_mvp/models/resident_memory_config.dart';
import 'package:fishing_office_mvp/models/resident_personality_context.dart';
import 'package:fishing_office_mvp/models/resident_relationship_config.dart';
import 'package:fishing_office_mvp/models/resident_story_config.dart';
import 'package:fishing_office_mvp/models/rumor_config.dart';
import 'package:fishing_office_mvp/models/task_config.dart';
import 'package:fishing_office_mvp/models/weather_config.dart';
import 'package:fishing_office_mvp/models/world_save_data.dart';
import 'package:fishing_office_mvp/core/engine/resident_dialogue_engine.dart';
import 'package:fishing_office_mvp/core/engine/resident_memory_engine.dart';
import 'package:fishing_office_mvp/core/engine/resident_relationship_engine.dart';
import 'package:fishing_office_mvp/core/engine/resident_story_engine.dart';
import 'package:fishing_office_mvp/core/engine/second_world_engine.dart';
import 'package:fishing_office_mvp/core/engine/time_manager.dart';
import 'package:fishing_office_mvp/core/engine/today_engine.dart';
import 'package:fishing_office_mvp/core/engine/waiting_engine.dart';
import 'package:fishing_office_mvp/core/engine/weather_system.dart';
import 'package:fishing_office_mvp/core/engine/world_calendar.dart';
import 'package:fishing_office_mvp/core/engine/world_clock.dart';
import 'package:fishing_office_mvp/core/managers/achievement_runtime_manager.dart';
import 'package:fishing_office_mvp/core/managers/daily_simulation_manager.dart';
import 'package:fishing_office_mvp/core/managers/dialogue_runtime_manager.dart';
import 'package:fishing_office_mvp/core/managers/dynamic_event_runtime_manager.dart';
import 'package:fishing_office_mvp/core/managers/economy_runtime_manager.dart';
import 'package:fishing_office_mvp/core/managers/festival_runtime_manager.dart';
import 'package:fishing_office_mvp/core/managers/fish_runtime_manager.dart';
import 'package:fishing_office_mvp/core/managers/quest_runtime_manager.dart';
import 'package:fishing_office_mvp/core/managers/resident_decision_manager.dart';
import 'package:fishing_office_mvp/core/managers/relationship_runtime_manager.dart';
import 'package:fishing_office_mvp/core/managers/resident_life_manager.dart';
import 'package:fishing_office_mvp/core/managers/resident_runtime_manager.dart';
import 'package:fishing_office_mvp/core/managers/rumor_runtime_manager.dart';
import 'package:fishing_office_mvp/core/managers/story_runtime_manager.dart';
import 'package:fishing_office_mvp/core/managers/weather_runtime_manager.dart';
import 'package:fishing_office_mvp/core/managers/world_save_manager.dart';
import 'package:fishing_office_mvp/core/managers/world_tick_manager.dart';
import 'package:fishing_office_mvp/core/managers/world_clock_manager.dart';
import 'package:fishing_office_mvp/core/runtime/app_runtime.dart';
import 'package:fishing_office_mvp/core/repository/json/json_source.dart';
import 'package:fishing_office_mvp/core/repository/resident_life_repository.dart';
import 'package:fishing_office_mvp/core/repository/resident_repository.dart';
import 'package:fishing_office_mvp/core/repository/world_save_repository.dart';
import 'package:fishing_office_mvp/core/services/fairy_event_service.dart';
import 'package:fishing_office_mvp/models/career_state.dart';
import 'package:fishing_office_mvp/models/company_organization.dart';
import 'package:fishing_office_mvp/models/dynamic_event_config.dart';
import 'package:fishing_office_mvp/models/resident_career.dart';
import 'package:fishing_office_mvp/pages/home/widgets/ambient_presentation_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('framework smoke test', () {
    expect(true, isTrue);
  });

  testWidgets('company organization model is widget-test safe', (tester) async {
    final organization = CompanyOrganization.defaultStructure();
    expect(organization.findCompany('fishing_office').name, '上班摸鱼有限公司');
    expect(
      organization.findPosition('team_leader').isTeamLeader,
      isTrue,
    );
    expect(
      organization.findPosition('department_manager').isDepartmentManager,
      isTrue,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('resident organization defaults derive from existing resident fields',
      () async {
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'tech_resident',
          'name': '电脑维修员',
          'job': '电脑维修员',
          'personality': 'practical',
          'location': 'office',
          'enabled': true,
        },
        {
          'id': 'front_resident',
          'name': '前台小妹',
          'job': '前台',
          'personality': 'warm',
          'location': 'reception',
          'enabled': true,
          'organization': {
            'companyId': 'fishing_office',
            'departmentId': 'front_office',
            'teamId': 'office_admin',
            'positionId': 'team_leader',
          },
          'career': {
            'careerLevel': 'leader',
            'hireDate': 'Y1-M01-D02',
            'salaryLevel': 360,
            'performanceScore': 88,
            'capabilityScore': 82,
            'employmentStatus': 'active',
            'promotionHistory': [
              {
                'type': 'promotion',
                'date': 'Y1-M02-D01',
                'fromPositionId': 'staff',
                'toPositionId': 'team_leader',
                'fromCareerLevel': 'regular',
                'toCareerLevel': 'leader',
                'reason': '稳定照顾前台节奏',
              }
            ],
          },
        },
      ],
    });
    final life = ResidentLifeConfig.fromJson(
      scheduleJson: {'version': 'test', 'schedules': []},
      activityJson: {'version': 'test', 'activities': []},
    );
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 1, hour: 9, minute: 0),
      initialCalendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        weekdayIndex: 1,
        month: 1,
        day: 1,
        season: 'spring',
      ),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(life),
      worldClockManager: clock,
    );
    await runtime.load();

    final tech = runtime.getResidentOrganizationContext('tech_resident');
    expect(tech.companyId, 'fishing_office');
    expect(tech.departmentId, 'technology');
    expect(tech.teamId, 'tech_support');
    expect(tech.positionId, 'specialist');
    expect(runtime.getResidentCurrentState('tech_resident').organization.tags,
        contains('department:technology'));

    final front = runtime.getResidentOrganizationContext('front_resident');
    expect(front.departmentId, 'front_office');
    expect(front.teamId, 'office_admin');
    expect(front.isTeamLeader, isTrue);
    expect(runtime.getResidentsByDepartment('front_office').length, 1);
    expect(runtime.getResidentsByTeam('office_admin').length, 1);
    expect(runtime.getTeamLeaders('office_admin').single.id, 'front_resident');

    final techCareer = runtime.getResidentCareerStatus('tech_resident');
    expect(techCareer.careerLevel, 'senior');
    expect(techCareer.employmentStatus, 'active');
    expect(techCareer.promotionHistory.single.type, 'hire');
    expect(
      runtime.getResidentCurrentState('tech_resident').career.tags,
      contains('career:senior'),
    );

    final frontCareer = runtime.getResidentCareerStatus('front_resident');
    expect(frontCareer.careerLevel, 'leader');
    expect(frontCareer.salaryLevel, 360);
    expect(frontCareer.promotionHistory.single.type, 'promotion');
    expect(runtime.getPromotionCandidates().first.residentId, 'front_resident');

    final needs = runtime.getDepartmentRecruitmentNeeds();
    expect(needs.any((need) => need.reason == 'department_manager_vacancy'),
        isTrue);
    expect(needs.any((need) => need.reason == 'team_leader_vacancy'), isTrue);

    final promoted = runtime.applyResidentCareerEvent(
      'tech_resident',
      type: 'promotion',
      reason: '测试晋升候选',
    );
    expect(promoted.careerLevel, 'leader');
    expect(promoted.employmentStatus, 'active');
    expect(promoted.promotionHistory.last.type, 'promotion');
    expect(
      runtime.getResidentCurrentState('tech_resident').career.careerLevel,
      'leader',
    );

    final transferred = runtime.applyResidentCareerEvent(
      'tech_resident',
      type: 'transfer',
      toPositionId: 'staff',
      reason: '测试转岗',
    );
    expect(transferred.employmentStatus, 'transferred');
    expect(transferred.tags, contains('career_event:transfer'));

    final demoted = runtime.applyResidentCareerEvent(
      'tech_resident',
      type: 'demotion',
      reason: '测试降职',
    );
    expect(demoted.employmentStatus, 'demoted');
    expect(demoted.promotionHistory.last.type, 'demotion');

    final resigned = runtime.applyResidentCareerEvent(
      'front_resident',
      type: 'resignation',
      reason: '测试离职',
    );
    expect(resigned.employmentStatus, 'resigned');
    expect(runtime.getResidentCareerStatus('front_resident').isActive, isFalse);

    final recruiting = runtime.applyResidentCareerEvent(
      'front_resident',
      type: 'recruitment',
      reason: '测试招聘',
    );
    expect(recruiting.employmentStatus, 'recruiting');

    runtime.loadRuntimeStates([
      {
        'residentId': 'tech_resident',
        'location': 'office',
        'activity': '恢复职业状态',
        'mood': 'calm',
        'dayCount': 1,
        'career': demoted.toJson(),
      }
    ]);
    final restoredCareer = runtime.getResidentCareerStatus('tech_resident');
    expect(restoredCareer.employmentStatus, 'demoted');
    expect(restoredCareer.promotionHistory.last.reason, '测试降职');
  });

  testWidgets('resident career model is widget-test safe', (tester) async {
    const event = ResidentCareerEvent(
      type: 'hire',
      date: 'Y1-M01-D01',
      fromPositionId: '',
      toPositionId: 'staff',
      fromCareerLevel: '',
      toCareerLevel: 'regular',
      reason: 'test',
    );
    final status = ResidentCareerStatus.fromResidentJson(
      {
        'id': 'career_resident',
        'job': '经理',
        'career': {
          'careerLevel': 'manager',
          'employmentStatus': 'active',
          'promotionHistory': [event.toJson()],
        },
      },
      organization: const OrganizationAssignment(
        companyId: 'fishing_office',
        departmentId: 'management',
        teamId: 'office_management',
        positionId: 'department_manager',
      ),
      residentId: 'career_resident',
    );
    expect(status.displayLevel, '部门负责人');
    expect(status.canBePromoted, isTrue);
    expect(status.tags, contains('career:manager'));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('organization assignment mutations stay transactional and idempotent',
      () async {
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        _organizationResident(
          id: 'tech_staff',
          departmentId: 'technology',
          teamId: 'tech_support',
          positionId: 'staff',
        ),
        _organizationResident(
          id: 'tech_leader',
          departmentId: 'technology',
          teamId: 'tech_support',
          positionId: 'team_leader',
          careerLevel: 'leader',
        ),
        _organizationResident(
          id: 'ops_staff',
          departmentId: 'operations',
          teamId: 'product_ops',
          positionId: 'staff',
        ),
        _organizationResident(
          id: 'commerce_staff',
          departmentId: 'commerce',
          teamId: 'market_services',
          positionId: 'staff',
        ),
      ],
    });
    final life = ResidentLifeConfig.fromJson(
      scheduleJson: {'version': 'test', 'schedules': []},
      activityJson: {'version': 'test', 'activities': []},
    );
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 8, hour: 10, minute: 0),
      initialCalendar: WorldCalendar.initial().copyWith(
        dayCount: 8,
        weekdayIndex: 2,
        month: 1,
        day: 8,
        season: 'spring',
      ),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(life),
      worldClockManager: clock,
    );
    await runtime.load();

    final sameTeamPromotion = runtime.promoteResident(
      'tech_staff',
      toPositionId: 'specialist',
      sourceId: 'mut_same_team',
      reason: 'same_team_growth',
      reportsToResidentId: 'tech_leader',
    );
    expect(sameTeamPromotion.success, isTrue);
    expect(runtime.getResidentOrganization('tech_staff').departmentId,
        'technology');
    expect(
        runtime.getResidentOrganization('tech_staff').teamId, 'tech_support');
    expect(
        runtime.getResidentOrganization('tech_staff').positionId, 'specialist');
    expect(runtime.getResidentOrganization('tech_staff').reportsToResidentId,
        'tech_leader');
    expect(runtime.getResidentCareerStatus('tech_staff').careerLevel, 'senior');

    final duplicatePromotion = runtime.promoteResident(
      'tech_staff',
      toPositionId: 'specialist',
      sourceId: 'mut_same_team',
      reason: 'same_team_growth',
    );
    expect(duplicatePromotion.success, isTrue);
    expect(duplicatePromotion.idempotent, isTrue);
    expect(
      runtime
          .getResidentCareerEvents('tech_staff')
          .where((event) => event.reason == 'same_team_growth')
          .length,
      1,
    );

    final crossTeamPromotion = runtime.promoteResident(
      'ops_staff',
      teamId: 'dock_services',
      toPositionId: 'team_leader',
      sourceId: 'mut_cross_team',
      reason: 'cross_team_growth',
    );
    expect(crossTeamPromotion.success, isTrue);
    expect(runtime.getResidentOrganization('ops_staff').departmentId,
        'operations');
    expect(
        runtime.getResidentOrganization('ops_staff').teamId, 'dock_services');
    expect(
        runtime.getResidentOrganization('ops_staff').positionId, 'team_leader');
    expect(
      runtime.getResidentsByTeam('product_ops').map((resident) => resident.id),
      isNot(contains('ops_staff')),
    );
    expect(
      runtime
          .getResidentsByTeam('dock_services')
          .map((resident) => resident.id),
      contains('ops_staff'),
    );

    final crossDepartmentTransfer = runtime.transferResident(
      'ops_staff',
      teamId: 'market_services',
      toPositionId: 'specialist',
      sourceId: 'mut_cross_department',
      reason: 'cross_department_transfer',
    );
    expect(crossDepartmentTransfer.success, isTrue);
    expect(
        runtime.getResidentOrganization('ops_staff').departmentId, 'commerce');
    expect(
        runtime.getResidentOrganization('ops_staff').teamId, 'market_services');
    expect(
        runtime.getResidentOrganization('ops_staff').positionId, 'specialist');
    expect(
      runtime
          .getResidentsByTeam('dock_services')
          .map((resident) => resident.id),
      isNot(contains('ops_staff')),
    );
    expect(
      runtime
          .getResidentsByTeam('market_services')
          .map((resident) => resident.id),
      contains('ops_staff'),
    );

    final demotion = runtime.demoteResident(
      'ops_staff',
      teamId: 'product_ops',
      toPositionId: 'staff',
      sourceId: 'mut_demotion',
      reason: 'demotion_to_staff',
      reportsToResidentId: 'tech_staff',
    );
    expect(demotion.success, isTrue);
    expect(runtime.getResidentOrganization('ops_staff').departmentId,
        'operations');
    expect(runtime.getResidentOrganization('ops_staff').teamId, 'product_ops');
    expect(runtime.getResidentOrganization('ops_staff').reportsToResidentId,
        'tech_staff');
    expect(runtime.getResidentCareerStatus('ops_staff').employmentStatus,
        'demoted');

    final resignation = runtime.resignResident(
      'commerce_staff',
      sourceId: 'mut_resign',
      reason: 'resignation_test',
    );
    expect(resignation.success, isTrue);
    expect(
        runtime.getResidentOrganization('commerce_staff').isAssigned, isFalse);
    expect(runtime.getResidentsByTeam('market_services'), isEmpty);

    final hire = runtime.assignResident(
      'commerce_staff',
      mutationType: 'hire',
      departmentId: 'commerce',
      teamId: 'market_services',
      positionId: 'staff',
      sourceId: 'mut_hire',
      reason: 'rehire_test',
    );
    expect(hire.success, isTrue);
    expect(
        runtime.getResidentOrganization('commerce_staff').isAssigned, isTrue);
    expect(runtime.getResidentCareerStatus('commerce_staff').employmentStatus,
        'active');

    final beforeFailure = runtime.getResidentOrganization('tech_staff');
    final missingPosition = runtime.promoteResident(
      'tech_staff',
      toPositionId: 'missing_position',
      sourceId: 'mut_missing_position',
    );
    expect(missingPosition.success, isFalse);
    expect(missingPosition.errors.single, startsWith('position_missing'));
    expect(runtime.getResidentOrganization('tech_staff').positionId,
        beforeFailure.positionId);

    final fullPosition = runtime.promoteResident(
      'tech_staff',
      toPositionId: 'team_leader',
      sourceId: 'mut_full_position',
    );
    expect(fullPosition.success, isFalse);
    expect(fullPosition.errors, contains('position_full:team_leader'));
    expect(runtime.getResidentOrganization('tech_staff').positionId,
        beforeFailure.positionId);

    final invalidTeam = runtime.transferResident(
      'tech_staff',
      departmentId: 'operations',
      teamId: 'tech_support',
      toPositionId: 'staff',
      sourceId: 'mut_invalid_team',
    );
    expect(invalidTeam.success, isFalse);
    expect(invalidTeam.errors, contains('team_department_mismatch'));

    final managementCycle = runtime.promoteResident(
      'tech_staff',
      toPositionId: 'department_manager',
      sourceId: 'mut_cycle',
      reportsToResidentId: 'tech_staff',
    );
    expect(managementCycle.success, isFalse);
    expect(managementCycle.errors, contains('management_cycle'));

    final multiLevelCycle = runtime.promoteResident(
      'tech_leader',
      toPositionId: 'team_leader',
      sourceId: 'mut_multi_level_cycle',
      reportsToResidentId: 'ops_staff',
    );
    expect(multiLevelCycle.success, isFalse);
    expect(multiLevelCycle.errors, contains('management_cycle'));

    final crossDepartmentPromotion = runtime.promoteResident(
      'tech_staff',
      teamId: 'market_services',
      toPositionId: 'department_manager',
      toCareerLevel: 'manager',
      sourceId: 'mut_cross_department_promotion',
      reason: 'cross_department_promotion',
    );
    expect(crossDepartmentPromotion.success, isTrue);
    expect(
        runtime.getResidentOrganization('tech_staff').departmentId, 'commerce');
    expect(runtime.getResidentOrganization('tech_staff').teamId,
        'market_services');
    expect(runtime.getResidentOrganization('tech_staff').positionId,
        'department_manager');
    expect(
        runtime.getResidentCareerStatus('tech_staff').careerLevel, 'manager');

    runtime.loadRuntimeStates(
      [
        {
          'residentId': 'ops_staff',
          'organization': runtime.getResidentOrganization('ops_staff').toJson(),
          'career': runtime.getResidentCareerStatus('ops_staff').toJson(),
          'location': 'office',
          'activity': 'restore',
          'mood': 'calm',
          'dayCount': 8,
        },
        {
          'residentId': 'tech_staff',
          'location': 'office',
          'activity': 'old_save_restore',
          'mood': 'calm',
          'dayCount': 8,
        },
      ],
      organizationMutationHistory: runtime.organizationMutationHistory
          .map((record) => record.toJson())
          .toList(growable: false),
      processedOrganizationMutationIds:
          runtime.processedOrganizationMutationIds,
    );
    expect(runtime.getResidentOrganization('ops_staff').teamId, 'product_ops');
    expect(runtime.getResidentOrganization('ops_staff').reportsToResidentId,
        'tech_staff');
    expect(runtime.getResidentCareerStatus('ops_staff').employmentStatus,
        'demoted');
    expect(runtime.getResidentOrganization('tech_staff').departmentId,
        'technology');
    final restoredDuplicate = runtime.demoteResident(
      'ops_staff',
      teamId: 'product_ops',
      toPositionId: 'staff',
      sourceId: 'mut_demotion',
      reason: 'demotion_to_staff',
    );
    expect(restoredDuplicate.success, isTrue);
    expect(restoredDuplicate.idempotent, isTrue);
    expect(
      runtime.organizationMutationHistory
          .where((record) => record.sourceId == 'mut_demotion')
          .length,
      1,
    );

    final bulkResidents = ResidentConfig.fromJson({
      'version': 'bulk',
      'residents': List.generate(
        100,
        (index) => _organizationResident(
          id: 'bulk_$index',
          departmentId: index.isEven ? 'operations' : 'technology',
          teamId: index.isEven ? 'product_ops' : 'tech_support',
          positionId: 'staff',
        ),
      ),
    });
    final bulkRuntime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(bulkResidents),
      lifeRepository: _FakeResidentLifeRepository(life),
      worldClockManager: clock,
    );
    await bulkRuntime.load();
    final startedAt = DateTime.now();
    final states = bulkRuntime.getAllResidentCurrentStates();
    final elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;
    expect(states.length, 100);
    expect(
        states.values.every((state) => state.organization.isAssigned), isTrue);
    expect(elapsedMs < 300, isTrue);
  });

  test('office economy settles payroll budgets idempotently and restores state',
      () async {
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        _organizationResident(
          id: 'payroll_staff',
          departmentId: 'technology',
          teamId: 'tech_support',
          positionId: 'staff',
        ),
        _organizationResident(
          id: 'payroll_leader',
          departmentId: 'technology',
          teamId: 'tech_support',
          positionId: 'team_leader',
          careerLevel: 'leader',
        ),
        _organizationResident(
          id: 'payroll_transfer',
          departmentId: 'technology',
          teamId: 'tech_support',
          positionId: 'staff',
        ),
      ],
    });
    final life = ResidentLifeConfig.fromJson(
      scheduleJson: {'version': 'test', 'schedules': []},
      activityJson: {'version': 'test', 'activities': []},
    );
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 12, hour: 9, minute: 0),
      initialCalendar: WorldCalendar.initial().copyWith(
        dayCount: 12,
        weekdayIndex: 3,
        month: 1,
        day: 12,
        season: 'spring',
      ),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(life),
      worldClockManager: clock,
    );
    await runtime.load();

    final promoted = runtime.promoteResident(
      'payroll_staff',
      toPositionId: 'specialist',
      toCareerLevel: 'senior',
      sourceId: 'payroll_promotion',
    );
    expect(promoted.success, isTrue);
    final transferred = runtime.transferResident(
      'payroll_transfer',
      teamId: 'market_services',
      toPositionId: 'staff',
      sourceId: 'payroll_transfer',
    );
    expect(transferred.success, isTrue);

    final dayOne = runtime.settleOfficeEconomy(
      periodType: 'day',
      periodKey: 'Y1-M1-D12',
      departmentId: 'technology',
      settlementId: 'office_payroll_day_12_tech',
      bonusPool: 90,
      operatingCost: 100,
      projectIncome: 1200,
      reason: 'daily_payroll',
    );
    expect(dayOne.success, isTrue);
    expect(dayOne.idempotent, isFalse);
    expect(dayOne.record!.residentIds, contains('payroll_staff'));
    expect(dayOne.record!.residentIds, contains('payroll_leader'));
    expect(dayOne.record!.residentIds, isNot(contains('payroll_transfer')));
    expect(
      dayOne.record!.payroll,
      residentCareerBaseSalary['senior']! + residentCareerBaseSalary['leader']!,
    );
    expect(dayOne.record!.bonus, 90);
    expect(dayOne.record!.operatingCost, 100);
    expect(dayOne.record!.projectIncome, 1200);
    expect(runtime.officeEconomyState.companyBudget, greaterThan(6000));
    expect(runtime.officeEconomyState.departmentBudgets['technology'],
        dayOne.record!.netChange);

    final duplicate = runtime.settleOfficeEconomy(
      periodType: 'day',
      periodKey: 'Y1-M1-D12',
      departmentId: 'technology',
      settlementId: 'office_payroll_day_12_tech',
      bonusPool: 999,
      operatingCost: 999,
      projectIncome: 999,
    );
    expect(duplicate.success, isTrue);
    expect(duplicate.idempotent, isTrue);
    expect(runtime.officeEconomyState.history.length, 1);

    final resigned = runtime.resignResident(
      'payroll_leader',
      sourceId: 'payroll_resign',
    );
    expect(resigned.success, isTrue);
    final dayTwo = runtime.settleOfficeEconomy(
      periodType: 'day',
      periodKey: 'Y1-M1-D13',
      departmentId: 'technology',
      settlementId: 'office_payroll_day_13_tech',
      operatingCost: 50,
      projectIncome: 500,
    );
    expect(dayTwo.success, isTrue);
    expect(dayTwo.record!.residentIds, contains('payroll_staff'));
    expect(dayTwo.record!.residentIds, isNot(contains('payroll_leader')));
    expect(dayTwo.record!.payroll, residentCareerBaseSalary['senior']);

    final restored = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(life),
      worldClockManager: clock,
    );
    await restored.load();
    restored.loadRuntimeStates(
      runtime.residents
          .map((resident) => <String, dynamic>{
                'residentId': resident.id,
                'organization':
                    runtime.getResidentOrganization(resident.id).toJson(),
                'career': runtime.getResidentCareerStatus(resident.id).toJson(),
                'location': 'office',
                'activity': 'restore',
                'mood': 'calm',
                'dayCount': 12,
              })
          .toList(growable: false),
      organizationMutationHistory: runtime.organizationMutationHistory
          .map((record) => record.toJson())
          .toList(growable: false),
      processedOrganizationMutationIds:
          runtime.processedOrganizationMutationIds,
      officeEconomy: runtime.officeEconomyState.toJson(),
    );
    expect(restored.officeEconomyState.history.length, 2);
    final restoredDuplicate = restored.settleOfficeEconomy(
      periodType: 'day',
      periodKey: 'Y1-M1-D13',
      departmentId: 'technology',
      settlementId: 'office_payroll_day_13_tech',
    );
    expect(restoredDuplicate.idempotent, isTrue);
    expect(restored.officeEconomyState.history.length, 2);

    restored.loadRuntimeStates(const <Map<String, dynamic>>[]);
    expect(restored.officeEconomyState.history, isEmpty);
    expect(restored.officeEconomyState.companyBudget, 6000);

    final bulkResidents = ResidentConfig.fromJson({
      'version': 'bulk',
      'residents': List.generate(
        100,
        (index) => _organizationResident(
          id: 'economy_bulk_$index',
          departmentId: index.isEven ? 'operations' : 'technology',
          teamId: index.isEven ? 'product_ops' : 'tech_support',
          positionId: 'staff',
        ),
      ),
    });
    final bulk = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(bulkResidents),
      lifeRepository: _FakeResidentLifeRepository(life),
      worldClockManager: clock,
    );
    await bulk.load();
    final startedAt = DateTime.now();
    final bulkResult = bulk.settleOfficeEconomy(
      periodType: 'day',
      periodKey: 'Y1-M1-D12',
      settlementId: 'bulk_company_payroll',
      operatingCost: -1,
      projectIncome: -1,
    );
    final elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;
    expect(bulkResult.success, isTrue);
    expect(bulkResult.record!.residentIds.length, 100);
    expect(bulkResult.record!.payroll, greaterThan(0));
    expect(elapsedMs < 300, isTrue);
  });

  test('organization conditions parse for dialogue story and dynamic events',
      () {
    final dialogue = ResidentDialogueConfig.fromJson({
      'fallback': {'text': 'fallback'},
      'dialogues': [
        {
          'id': 'department_dialogue',
          'residentId': '*',
          'text': '技术部今天也在修一点小风。',
          'conditions': {
            'companyId': 'fishing_office',
            'departmentId': 'technology',
            'teamId': 'tech_support',
            'positionId': 'specialist',
            'organizationTags': ['department:technology'],
            'careerLevel': 'senior',
            'employmentStatus': 'active',
            'careerTags': ['career:senior'],
            'salaryLevelMin': 200,
          },
        }
      ],
    }).dialogues.first.conditions;
    expect(dialogue.companyId, 'fishing_office');
    expect(dialogue.departmentId, 'technology');
    expect(dialogue.teamId, 'tech_support');
    expect(dialogue.positionId, 'specialist');
    expect(dialogue.organizationTags, contains('department:technology'));
    expect(dialogue.careerLevel, 'senior');
    expect(dialogue.employmentStatus, 'active');
    expect(dialogue.careerTags, contains('career:senior'));
    expect(dialogue.salaryLevelMin, 200);

    final story = ResidentStoryConfig.fromJson({
      'stories': [
        {
          'id': 'department_story',
          'residentId': '*',
          'title': '技术部的小灯',
          'summary': '有人把坏掉的灯修好了。',
          'conditions': {
            'departmentId': 'technology',
            'organizationTags': ['team:tech_support'],
            'careerLevel': 'senior',
            'employmentStatus': 'active',
            'careerTags': ['career:senior'],
            'salaryLevelMin': 200,
          },
        }
      ],
    }).stories.first.conditions;
    expect(story.departmentId, 'technology');
    expect(story.organizationTags, contains('team:tech_support'));
    expect(story.careerLevel, 'senior');
    expect(story.employmentStatus, 'active');
    expect(story.careerTags, contains('career:senior'));
    expect(story.salaryLevelMin, 200);

    final event = DynamicEventConfig.fromJson({
      'events': [
        {
          'id': 'organization_event',
          'type': 'office',
          'category': 'office',
          'title': '部门里的小波纹',
          'conditions': {
            'companyId': ['fishing_office'],
            'departmentId': ['technology'],
            'teamId': ['tech_support'],
            'positionId': ['specialist'],
            'organizationTags': ['department:technology'],
            'careerLevel': ['senior'],
            'employmentStatus': ['active'],
            'careerTags': ['career:senior'],
            'salaryLevelMin': 200,
          },
        }
      ],
    }).events.first.conditions;
    expect(event.companyId, contains('fishing_office'));
    expect(event.departmentId, contains('technology'));
    expect(event.teamId, contains('tech_support'));
    expect(event.positionId, contains('specialist'));
    expect(event.organizationTags, contains('department:technology'));
    expect(event.careerLevel, contains('senior'));
    expect(event.employmentStatus, contains('active'));
    expect(event.careerTags, contains('career:senior'));
    expect(event.salaryLevelMin, 200);
  });

  test('release readiness json counts fields and references are valid', () {
    final base = Directory('assets/config');
    Map<String, dynamic> load(String file) {
      return jsonDecode(
        File('${base.path}/$file').readAsStringSync(),
      ) as Map<String, dynamic>;
    }

    List<Map<String, dynamic>> list(String file, String key) {
      return (load(file)[key] as List<dynamic>).cast<Map<String, dynamic>>();
    }

    void expectUniqueIds(String file, String key) {
      final ids = list(file, key)
          .map((item) => item['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
      expect(ids.toSet().length, ids.length, reason: '$file duplicate id');
    }

    void expectFields(
      String file,
      String key,
      List<String> fields,
    ) {
      final items = list(file, key);
      for (var i = 0; i < items.length; i += 1) {
        for (final field in fields) {
          expect(
            items[i].containsKey(field),
            isTrue,
            reason: '$file:$key[$i] missing $field',
          );
        }
      }
    }

    final residents = list('resident.json', 'residents');
    final residentMirror = list('residents.json', 'residents');
    final residentIds = residents.map((item) => item['id'].toString()).toSet();
    final residentMirrorIds =
        residentMirror.map((item) => item['id'].toString()).toSet();

    expect(residents.length, 100);
    expect(residentMirror.length, 100);
    expect(residentMirrorIds, residentIds);
    expect(list('fish_catalog.json', 'fish').length, 90);
    expect(list('resident_dialogue.json', 'dialogues').length,
        greaterThanOrEqualTo(2460));
    expect(list('resident_story.json', 'stories').length,
        greaterThanOrEqualTo(1320));
    expect(list('festival.json', 'festivals').length, 50);
    expect(list('weather.json', 'weatherEvents').length, 100);
    expect(list('rumor.json', 'rumors').length, 300);
    expect(list('identity.json', 'identities').length, 100);
    expect(list('legend.json', 'legends').length, 100);

    for (final spec in const [
      ['resident.json', 'residents'],
      ['residents.json', 'residents'],
      ['fish_catalog.json', 'fish'],
      ['resident_dialogue.json', 'dialogues'],
      ['resident_story.json', 'stories'],
      ['festival.json', 'festivals'],
      ['weather.json', 'weatherEvents'],
      ['rumor.json', 'rumors'],
      ['identity.json', 'identities'],
      ['legend.json', 'legends'],
    ]) {
      expectUniqueIds(spec[0], spec[1]);
    }

    expectFields('resident.json', 'residents', const [
      'id',
      'name',
      'nickname',
      'gender',
      'age',
      'job',
      'personality',
      'favoriteFood',
      'favoriteFish',
      'home',
      'workplace',
      'dailyRoute',
      'description',
    ]);
    expectFields('fish_catalog.json', 'fish', const [
      'id',
      'name',
      'nickname',
      'rarity',
      'habitat',
      'favoriteTime',
      'favoriteWeather',
      'favoriteBait',
      'fear',
      'personality',
      'description',
      'story',
      'firstDialogue',
      'catchReaction',
      'waitDialogues',
      'value',
      'weightRange',
      'baitRequired',
      'nextBaitTarget',
    ]);
    expectFields('resident_dialogue.json', 'dialogues', const [
      'id',
      'residentId',
      'text',
      'conditions',
      'priority',
      'repeatable',
      'tags',
    ]);
    expectFields('resident_story.json', 'stories', const [
      'id',
      'residentId',
      'title',
      'summary',
      'dialogueIds',
      'conditions',
      'result',
      'priority',
      'repeatable',
      'tags',
    ]);

    for (final dialogue in list('resident_dialogue.json', 'dialogues')) {
      final residentId = dialogue['residentId']?.toString() ?? '';
      expect(
        residentId == '*' || residentIds.contains(residentId),
        isTrue,
        reason: 'invalid dialogue residentId $residentId',
      );
    }
    for (final story in list('resident_story.json', 'stories')) {
      final residentId = story['residentId']?.toString() ?? '';
      expect(
        residentId == '*' || residentIds.contains(residentId),
        isTrue,
        reason: 'invalid story residentId $residentId',
      );
    }

    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final file in const [
      'assets/config/festival.json',
      'assets/config/weather.json',
      'assets/config/rumor.json',
      'assets/config/legend.json',
    ]) {
      expect(pubspec.contains(file), isTrue, reason: '$file missing asset');
    }
    final store = load('store/store_products.json');
    for (final category in (store['categories'] as List<dynamic>)
        .cast<Map<String, dynamic>>()) {
      final icon = category['icon']?.toString() ?? '';
      expect(
        icon.isEmpty || File(icon).existsSync(),
        isTrue,
        reason: 'missing store category icon $icon',
      );
    }
    for (final product
        in (store['products'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      final image = product['image']?.toString() ?? '';
      expect(
        image.isEmpty || File(image).existsSync(),
        isTrue,
        reason: 'missing store product image $image',
      );
    }
  });

  test('fishing core loop updates wallet inventory and transaction state', () {
    final fishing = FishingProvider();
    final wallet = WalletManagerView(initialFishCoin: 1000);
    final transactions = TransactionManagerView();
    final inventory = InventoryManagerView();
    final memory = MemoryManagerView();

    fishing.throwLine(baitId: 'bait_basic');
    expect(fishing.state, 'waiting');
    expect(fishing.waitingMessages.length, inInclusiveRange(3, 5));
    expect(
      fishing.waitingMessages.toSet().length,
      fishing.waitingMessages.length,
    );
    expect(
      fishing.waitingEvents.any(
        (event) => event.payload['surpriseTier'] == 'surprise',
      ),
      isTrue,
    );
    expect(
      fishing.waitingEvents.any(
        (event) => event.payload['surpriseTier'] == 'unexpected',
      ),
      isTrue,
    );

    fishing.pullLine();
    expect(fishing.result, isNull);

    fishing.markFishHooked();
    expect(fishing.canPullLine, isTrue);
    expect(
      fishing.waitingEvents.last.payload['animationCue'],
      'reserved_float_dip',
    );

    fishing.pullLine();
    final soldResult = fishing.result;
    expect(soldResult, isNotNull);
    expect(soldResult!.metadata['weightKg'], isNotNull);
    expect(soldResult.metadata['animationCue'], 'reserved_line_pull');

    fishing.sellFish(wallet: wallet, transactions: transactions);
    expect(wallet.fishCoin, 1000 + soldResult.value);
    expect(wallet.points, soldResult.points);
    expect(transactions.records.last.type, 'sell_fish');
    expect(fishing.state, 'idle');

    fishing.throwLine(baitId: 'bait_basic');
    fishing.markFishHooked();
    fishing.pullLine();
    final keptResult = fishing.result;
    expect(keptResult, isNotNull);

    fishing.keepFish(inventory: inventory, memory: memory);
    expect(inventory.ownedOf(keptResult!.fishId), 1);
    expect(fishing.state, 'idle');
  });

  test('inventory loads json catalog and supports sell and release actions',
      () {
    final config = InventoryConfig.fromJson({
      'meta': {'version': 'test'},
      'inventory': {
        'title': '我的背包',
        'categories': [
          {'id': 'all', 'label': '全部'},
          {'id': 'fish', 'label': '鱼'},
          {'id': 'bait', 'label': '鱼饵'},
          {'id': 'gear', 'label': '渔具'},
          {'id': 'collection', 'label': '收藏品'},
        ],
        'catalog': [
          {
            'id': 'fish_basa',
            'name': '巴沙鱼',
            'category': 'fish',
            'rarity': 'common',
            'icon': '鱼',
            'description': '测试鱼',
            'usage': '出售或放生',
            'obtainSource': '测试',
            'sellPrice': 18,
            'canUse': true,
            'canSell': true,
            'initialQuantity': 2,
            'sortOrder': 2,
          },
          {
            'id': 'bait_basic',
            'name': '基础鱼饵',
            'category': 'bait',
            'rarity': 'common',
            'icon': '饵',
            'description': '测试饵',
            'usage': '钓鱼',
            'obtainSource': '测试',
            'sellPrice': 0,
            'canUse': true,
            'canSell': false,
            'initialQuantity': 3,
            'sortOrder': 0,
          },
        ],
      },
    });
    final inventory = InventoryManagerView()..ensureCatalogLoaded(config);
    final wallet = WalletManagerView(initialFishCoin: 1000);
    final transactions = TransactionManagerView();

    expect(config.categories.map((item) => item.id),
        containsAll(['fish', 'bait', 'gear', 'collection']));
    expect(inventory.ownedOf('fish_basa'), 2);
    expect(inventory.sortedEntries(config).first.itemId, 'bait_basic');

    final fish = config.itemById('fish_basa')!;
    expect(
        inventory.sellItem(
            item: fish, wallet: wallet, transactions: transactions),
        isTrue);
    expect(wallet.fishCoin, 1018);
    expect(transactions.records.single.type, 'sell_fish');
    expect(inventory.ownedOf('fish_basa'), 1);

    expect(inventory.releaseFish(fish), isTrue);
    expect(inventory.ownedOf('fish_basa'), 0);
  });

  test('fish collection reads json and lights discovered fish', () {
    final config = FishCollectionConfig.fromJson({
      'meta': {'version': 'test'},
      'collection': {
        'title': '海洋图鉴',
        'defaultFishId': 'fish_small',
        'categories': [
          {'id': 'all', 'label': '全部'},
          {'id': 'common', 'label': '普通'},
          {'id': 'rare', 'label': '稀有'},
          {'id': 'epic', 'label': '史诗'},
          {'id': 'legendary', 'label': '传说'},
        ],
        'fishes': [
          {
            'id': 'fish_small',
            'name': '小鱼',
            'category': 'common',
            'rarity': 'common',
            'icon': '鱼',
            'price': 12,
            'averageWeightKg': 0.2,
            'maxWeightKg': 0.4,
            'location': '工位窗外浅海',
            'rarityRate': '45%',
            'story': '第一次遇见的小鱼。',
            'description': '测试鱼',
            'unlockCondition': '钓到一次',
          },
          {
            'id': 'fish_rare',
            'name': '稀有鱼',
            'category': 'rare',
            'rarity': 'rare',
            'icon': '鱼',
            'price': 80,
            'averageWeightKg': 1.2,
            'maxWeightKg': 2.4,
            'location': '远海',
            'rarityRate': '8%',
            'story': '还没有遇见。',
            'description': '测试稀有鱼',
            'unlockCondition': '继续探索',
          },
        ],
      },
    });
    final collection = CollectionManagerView();

    expect(config.categories.map((item) => item.id),
        containsAll(['all', 'common', 'rare', 'epic', 'legendary']));
    expect(config.fishes.length, 2);
    expect(collection.isDiscovered('fish_small'), isFalse);

    collection.discoverFish(
      fishId: 'fish_small',
      fishName: '小鱼',
      rarity: 'common',
      category: 'fish',
    );
    collection.discoverFish(
      fishId: 'fish_small',
      fishName: '小鱼',
      rarity: 'common',
      category: 'fish',
    );

    final discoveredInConfig =
        config.fishes.where((fish) => collection.isDiscovered(fish.id)).length;
    expect(discoveredInConfig, 1);
    expect(collection.recordOf('fish_small')?.catchCount, 2);
    expect(collection.isDiscovered('fish_rare'), isFalse);
  });

  test('daily tasks sync progress and claim json rewards', () {
    final config = TaskConfig.fromJson({
      'meta': {'version': 'test'},
      'tasks': {
        'title': '今日任务',
        'statusLabels': {
          'not_started': '未开始',
          'in_progress': '进行中',
          'claimable': '可领取',
          'completed': '已完成',
        },
        'rewardLabels': {
          'fishCoin': '摸鱼币',
          'exp': '经验',
          'collectionPoint': '图鉴积分',
          'titleId': '称号',
        },
        'categories': [
          {'id': 'daily', 'label': '每日任务', 'enabled': true, 'sortOrder': 1},
        ],
        'items': [
          {
            'id': 'daily_login',
            'title': '看看今天的海',
            'description': '打开第二世界，先慢下来。',
            'category': 'daily',
            'metric': 'login_days',
            'target': 1,
            'progress': 0,
            'reward': {
              'fishCoin': 25,
              'exp': 4,
              'collectionPoint': 0,
              'titleId': '',
            },
            'status': 'not_started',
            'sortOrder': 1,
            'icon': '🌊',
          },
        ],
      },
    });
    final tasks = TaskManagerView();
    final fishing = FishingProvider();
    final inventory = InventoryManagerView();
    final collection = CollectionManagerView();
    final wallet = WalletManagerView(initialFishCoin: 1000);
    final transactions = TransactionManagerView();

    tasks.syncFromState(
      fishing: fishing,
      inventory: inventory,
      collection: collection,
      transactions: transactions,
    );

    final taskView = tasks.visibleTasks(config, 'daily').single;
    expect(taskView.progress, 1);
    expect(taskView.status, 'claimable');

    expect(
      tasks.claimReward(
        task: taskView.config,
        wallet: wallet,
        transactions: transactions,
      ),
      isTrue,
    );
    expect(wallet.fishCoin, 1025);
    expect(wallet.points, 4);
    expect(transactions.records.last.type, 'task_reward');
    expect(tasks.visibleTasks(config, 'daily').single.status, 'completed');
  });

  test('honor manager syncs progress from runtime metrics', () {
    final honor = HonorConfig.fromJson({
      'title': '荣耀大厅',
      'player': {'nickname': 'FishingPro'},
      'statistics': {
        'items': [
          {'label': '累计钓鱼', 'value': '0 条'},
          {'label': '收集率', 'value': '0%'},
          {'label': '连续签到', 'value': '0 天'},
          {'label': '完成任务', 'value': '0 次'},
        ],
      },
      'categories': [
        {'id': 'badge', 'title': '徽章', 'enabled': true, 'sortOrder': 1},
      ],
      'badges': [
        {
          'id': 'first_fishing',
          'title': '初次摸鱼',
          'description': '第一次钓鱼',
          'icon': '🐟',
          'category': 'badge',
          'condition': '累计钓鱼 1 次',
          'metric': 'fishing_count',
          'target': 1,
          'progress': 0,
          'status': 'not_obtained',
          'sortOrder': 1,
        },
        {
          'id': 'daily_done',
          'title': '今日小目标',
          'description': '完成一个今日任务',
          'icon': '🎯',
          'category': 'badge',
          'condition': '完成任务 1 个',
          'metric': 'task_completed',
          'target': 1,
          'progress': 0,
          'status': 'not_obtained',
          'sortOrder': 2,
        },
      ],
    });
    final taskConfig = TaskConfig.fromJson({
      'tasks': {
        'categories': [
          {'id': 'daily', 'label': '每日任务', 'enabled': true, 'sortOrder': 1},
        ],
        'items': [
          {
            'id': 'done_task',
            'title': '已完成任务',
            'description': '测试',
            'category': 'daily',
            'metric': 'login_days',
            'target': 1,
            'progress': 1,
            'reward': {'fishCoin': 0, 'exp': 0},
            'status': 'completed',
            'sortOrder': 1,
            'icon': '✅',
          },
        ],
      },
    });
    final fishCollection = FishCollectionConfig.fromJson({
      'collection': {
        'fishes': [
          {'id': 'fish_small', 'name': '小鱼'},
        ],
      },
    });
    final fishing = FishingProvider();
    final wallet = WalletManagerView(initialFishCoin: 1000)..addPoints(10);
    final inventory = InventoryManagerView();
    final collection = CollectionManagerView();
    final transactions = TransactionManagerView();
    final tasks = TaskManagerView();
    final manager = HonorManagerView();

    fishing.throwLine(baitId: 'bait_basic');
    tasks.syncFromState(
      fishing: fishing,
      inventory: inventory,
      collection: collection,
      transactions: transactions,
    );
    manager.syncFromState(
      honor: honor,
      fishCollection: fishCollection,
      fishing: fishing,
      wallet: wallet,
      inventory: inventory,
      collection: collection,
      transactions: transactions,
      tasks: tasks,
      taskConfig: taskConfig,
    );

    final views = manager.visibleHonors(honor, 'all');
    expect(views.first.config.id, 'first_fishing');
    expect(views.first.progress, 1);
    expect(views.first.status, 'obtained');
    expect(views[1].status, 'obtained');
  });

  test('world clock manager exposes unified second world time', () {
    var current = DateTime.parse('2026-07-05T08:15:00.000');
    final clock = WorldClockManager(realNow: () => current);

    expect(clock.now(), current);
    expect(clock.today().dayCount, 1);
    expect(clock.hour(), 5);
    expect(clock.minute(), 0);
    expect(clock.weekday(), 1);
    expect(clock.season(), 'spring');
    expect(clock.festival().activeFestivals, contains('new_year'));
    expect(clock.weather().description, isNotEmpty);

    clock.tick(const Duration(hours: 1, minutes: 30));
    expect(clock.hour(), 6);
    expect(clock.minute(), 30);

    clock.pause();
    current = current.add(const Duration(hours: 3));
    expect(clock.hour(), 6);
    clock.resume();
    clock.setTimeScale(2);
    clock.tick(const Duration(minutes: 15));
    expect(clock.hour(), 7);
    expect(clock.minute(), 0);
  });

  test('resident life engine resolves current state from world clock',
      () async {
    final config = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_morning',
            'residentId': 'old_fisher',
            'schedule': 'morning',
            'location': 'office_sea_window',
            'activity': '整理鱼竿',
            'activityId': 'prepare_rods',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5],
          },
          {
            'id': 'old_fisher_night',
            'residentId': 'old_fisher',
            'schedule': 'night',
            'location': 'harbor_lamp',
            'activity': '等一条慢鱼',
            'activityId': 'wait_slow_fish',
            'startTime': '18:00',
            'endTime': '06:00',
            'mood': 'peaceful',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'prepare_rods', 'name': '整理鱼竿'},
        ],
      },
    );
    final manager = ResidentLifeManager(_FakeResidentLifeRepository(config));
    await manager.load();

    final morning = manager.getResidentCurrentState(
      'old_fisher',
      clock: const WorldClockConfig(
          hour: 8, minute: 30, weekday: 1, month: 7, season: 'summer'),
    );
    expect(morning.found, isTrue);
    expect(morning.location, 'office_sea_window');
    expect(morning.activity, '整理鱼竿');
    expect(morning.mood, 'calm');

    final night = manager.getResidentCurrentState(
      'old_fisher',
      clock: const WorldClockConfig(
          hour: 23, minute: 10, weekday: 6, month: 7, season: 'summer'),
    );
    expect(night.location, 'harbor_lamp');
    expect(night.activity, '等一条慢鱼');
    expect(night.mood, 'peaceful');

    final missing = manager.getResidentCurrentState(
      'unknown',
      clock: const WorldClockConfig(
          hour: 8, minute: 30, weekday: 1, month: 7, season: 'summer'),
    );
    expect(missing.found, isFalse);
  });

  test('resident runtime manager resolves 100 residents from world clock',
      () async {
    var current = DateTime.parse('2026-07-05T08:00:00.000');
    final clock = WorldClockManager(realNow: () => current);
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': List.generate(100, (index) {
        final id = 'resident_$index';
        return {
          'id': id,
          'name': '居民$index',
          'type': 'resident',
          'personality': 'warm',
          'dialogGroup': id,
          'mood': 'calm',
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'location_$index',
          'enabled': true,
          'home': 'home_$index',
          'workplace': 'workplace_$index',
          'dailyRoute': ['cafe_$index', 'street_$index'],
        };
      }),
    });
    final life = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'resident_0_night',
            'residentId': 'resident_0',
            'schedule': 'night',
            'location': 'night_harbor',
            'activity': '看夜里的灯塔',
            'activityId': 'watch_lighthouse',
            'startTime': '22:00',
            'endTime': '02:00',
            'mood': 'peaceful',
            'weekday': [1],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'watch_lighthouse', 'name': '看灯塔'},
        ],
      },
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(life),
      worldClockManager: clock,
    );
    await runtime.load();
    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 1, hour: 8, minute: 0),
    );

    for (var i = 0; i < 100; i += 1) {
      final id = 'resident_$i';
      expect(runtime.getResidentCurrentLocation(id), isNotEmpty);
      expect(runtime.getResidentCurrentActivity(id), isNotEmpty);
      expect(runtime.getResidentCurrentMood(id), isNotEmpty);
    }

    expect(runtime.getResidentCurrentLocation('resident_1'), 'workstation');
    expect(
        runtime.getResidentsAtLocation('workstation').length, greaterThan(0));

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 1, hour: 23, minute: 30),
    );
    expect(runtime.getResidentCurrentLocation('resident_0'), 'home');
    expect(runtime.getResidentCurrentActivity('resident_0'), '看夜里的灯塔');
    expect(runtime.getResidentCurrentMood('resident_0'), 'calm');

    clock.tick(const Duration(hours: 3));
    expect(clock.hour(), 2);
    expect(runtime.getResidentCurrentLocation('resident_0'),
        isNot('night_harbor'));
  });

  test(
      'office life schedule 2.0 resolves stable weekday weekend and save state',
      () async {
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': List.generate(100, (index) {
        final mood = switch (index) {
          2 => 'tired',
          _ => 'calm',
        };
        final personality = switch (index) {
          1 => 'busy practical',
          2 => 'warm',
          _ => 'warm',
        };
        return {
          'id': 'resident_$index',
          'name': '居民$index',
          'type': 'resident',
          'personality': personality,
          'dialogGroup': 'resident_$index',
          'mood': mood,
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'default_location_$index',
          'enabled': true,
          'home': 'home_$index',
          'workplace': 'workplace_$index',
          'dailyRoute': [
            'workplace_$index',
            'pantry',
            'coffee_shop',
            'park',
            'home_$index',
          ],
        };
      }),
    });
    final life = ResidentLifeConfig.fromJson(
      scheduleJson: {'version': 'test', 'schedules': []},
      activityJson: {'version': 'test', 'activities': []},
    );
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 1, hour: 9, minute: 30),
      initialCalendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        weekdayIndex: 1,
        month: 1,
        day: 1,
        season: 'spring',
      ),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(life),
      worldClockManager: clock,
    );
    await runtime.load();

    final workMorning = runtime.getResidentCurrentState('resident_1');
    expect(workMorning.schedulePhase, 'working');
    expect(workMorning.isWorking, isTrue);
    expect(workMorning.isOnBreak, isFalse);
    expect(workMorning.nextChangeTime, '11:00');

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 1, hour: 12, minute: 30),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        weekdayIndex: 1,
        month: 1,
        day: 1,
        season: 'spring',
      ),
    );
    final lunch = runtime.getResidentCurrentState('resident_1');
    expect(lunch.schedulePhase, 'lunch');
    expect(lunch.isOnBreak, isTrue);
    expect(lunch.nextChangeTime, '14:00');
    expect(lunch.nextLocation, 'coffee_shop');

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 1, hour: 17, minute: 30),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        weekdayIndex: 1,
        month: 1,
        day: 1,
        season: 'spring',
      ),
    );
    final busyOvertime = runtime.getResidentCurrentState('resident_1');
    final tiredOffWork = runtime.getResidentCurrentState('resident_2');
    expect(busyOvertime.schedulePhase, 'overtime');
    expect(busyOvertime.isOvertime, isTrue);
    expect(tiredOffWork.schedulePhase, 'off_work');
    expect(tiredOffWork.isOvertime, isFalse);

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 6, hour: 14, minute: 30),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 6,
        weekdayIndex: 6,
        month: 1,
        day: 6,
        isWeekend: true,
        season: 'spring',
      ),
    );
    final weekend = runtime.getResidentCurrentState('resident_1');
    expect(weekend.schedulePhase, 'weekend');
    expect(weekend.isWeekend, isTrue);
    expect(weekend.isWorking, isFalse);
    expect(weekend.activity, isNot(workMorning.activity));

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 8, hour: 23, minute: 30),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 8,
        weekdayIndex: 1,
        month: 1,
        day: 8,
        season: 'spring',
      ),
    );
    final beforeMidnight = runtime.getResidentCurrentState('resident_1');
    expect(beforeMidnight.schedulePhase, 'sleep');
    expect(beforeMidnight.endTime, '06:00');
    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 9, hour: 1, minute: 30),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 9,
        weekdayIndex: 2,
        month: 1,
        day: 9,
        season: 'spring',
      ),
    );
    expect(
        runtime.getResidentCurrentState('resident_1').schedulePhase, 'sleep');

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 9, hour: 10, minute: 50),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 9,
        weekdayIndex: 2,
        month: 1,
        day: 9,
        season: 'spring',
      ),
    );
    expect(
        runtime.getResidentCurrentState('resident_1').schedulePhase, 'working');
    clock.tick(const Duration(minutes: 10));
    expect(runtime.getResidentCurrentState('resident_1').schedulePhase,
        'coffee_break');

    final stopwatch = Stopwatch()..start();
    final states = runtime.getAllResidentCurrentStates();
    stopwatch.stop();
    expect(states.length, 100);
    for (final state in states.values) {
      expect(state.location, isNotEmpty);
      expect(state.activity, isNotEmpty);
      expect(state.mood, isNotEmpty);
      expect(state.schedulePhase, isNotEmpty);
      expect(state.nextChangeTime, isNotEmpty);
    }
    expect(stopwatch.elapsedMilliseconds, lessThan(250));

    runtime.loadRuntimeStates([
      {
        'residentId': 'resident_1',
        'location': 'legacy_location',
        'activity': '旧存档里的临时活动',
        'mood': 'happy',
        'dayCount': 9,
        'source': 'legacy_save',
      },
    ]);
    final legacy = runtime.getResidentCurrentState('resident_1');
    expect(legacy.location, isNotEmpty);
    expect(
        LocationContext.supportedLocationIds.contains(legacy.location), isTrue);
    expect(legacy.schedulePhase, isNotEmpty);
    expect(legacy.nextChangeTime, isNotEmpty);

    runtime.loadRuntimeStates([
      {
        'residentId': 'resident_1',
        'location': 'workplace_1',
        'activity': '恢复加班收尾',
        'mood': 'busy',
        'dayCount': 9,
        'source': 'world_save',
        'schedulePhase': 'overtime',
        'isWorking': true,
        'isOvertime': true,
        'nextLocation': 'elevator',
        'nextActivity': '准备离开办公室',
        'nextChangeTime': '18:00',
      },
    ]);
    final restored = runtime.getResidentCurrentState('resident_1');
    expect(restored.schedulePhase, 'overtime');
    expect(restored.isWorking, isTrue);
    expect(restored.isOvertime, isTrue);
    expect(restored.nextLocation, 'manager_room');
  });

  test(
      'office locations integration provides context capacity and runtime hooks',
      () async {
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 1, hour: 12, minute: 30),
      initialCalendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        weekdayIndex: 1,
        month: 1,
        day: 1,
        season: 'spring',
      ),
      paused: true,
    );
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': List.generate(20, (index) {
        return {
          'id': 'resident_$index',
          'name': '居民$index',
          'type': 'resident',
          'personality': 'warm',
          'dialogGroup': 'resident_$index',
          'mood': 'calm',
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'workplace_$index',
          'enabled': true,
          'home': 'home_$index',
          'workplace': 'workplace_$index',
          'dailyRoute': ['workplace_$index', 'pantry', 'coffee_shop'],
        };
      }),
    });
    final life = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': List.generate(20, (index) {
          return {
            'id': 'resident_${index}_lunch',
            'residentId': 'resident_$index',
            'schedule': 'lunch',
            'location': 'pantry',
            'activity': '午休时在茶水间听听今天的小传闻',
            'startTime': '12:00',
            'endTime': '14:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5],
          };
        }),
      },
      activityJson: {'version': 'test', 'activities': []},
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(life),
      worldClockManager: clock,
    );
    await runtime.load();

    expect(LocationContext.normalizeId('meetingRoom'), 'meeting_room');
    expect(LocationContext.normalizeId('meeting-room'), 'meeting_room');
    expect(LocationContext.normalizeId('workplace_12'), 'workstation');
    expect(runtime.getLocationContext('meetingRoom').maxCapacity, 8);

    final lunch = runtime.getResidentCurrentState('resident_0');
    expect(lunch.schedulePhase, 'lunch');
    expect(lunch.location, 'pantry');
    expect(runtime.getResidentLocationContext('resident_0').tags,
        containsAll(['break', 'coffee', 'rumor']));

    final states = runtime.getAllResidentCurrentStates();
    final pantryCount =
        states.values.where((state) => state.location == 'pantry').length;
    final coffeeShopCount =
        states.values.where((state) => state.location == 'coffee_shop').length;
    expect(pantryCount, 12);
    expect(coffeeShopCount, 8);
    expect(
      states.values.every((state) => LocationContext.isReasonableForPhase(
            state.location,
            state.schedulePhase,
          )),
      isTrue,
    );

    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [],
      }),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1,
          },
        ],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final festivalRuntime = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({'version': 'test', 'festivals': []}),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weatherRuntime = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({'version': 'test', 'weatherEvents': []}),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final rumorRuntime = RumorRuntimeManager(
      config: RumorConfig.fromJson({'version': 'test', 'rumors': []}),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      residentRuntimeManager: runtime,
    );
    final dialogueRuntime = DialogueRuntimeManager(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天慢一点。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [
          {
            'id': 'pantry_rumor_dialogue',
            'residentId': 'resident_0',
            'text': '茶水间总能听见一点温柔的小八卦。',
            'conditions': {
              'locationTags': ['coffee', 'rumor']
            },
            'priority': 20,
            'repeatable': true,
            'tags': ['pantry'],
          },
          {
            'id': 'meeting_dialogue',
            'residentId': 'resident_0',
            'text': '会议室里的空气有一点认真。',
            'conditions': {'residentLocation': 'meeting_room'},
            'priority': 10,
            'repeatable': true,
            'tags': ['meeting'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    expect(
        dialogueRuntime.getDialogue('resident_0').id, 'pantry_rumor_dialogue');

    final storyRuntime = StoryRuntimeManager(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [
          {
            'id': 'pantry_break_story',
            'residentId': 'resident_0',
            'title': '茶水间的小休息',
            'summary': '午休时的小故事。',
            'dialogueIds': [],
            'conditions': {
              'requiredLocation': 'pantry',
              'locationTags': ['break']
            },
            'result': {
              'memoryTags': ['pantry_story']
            },
            'priority': 20,
            'repeatable': true,
            'tags': ['break_story'],
          },
          {
            'id': 'meeting_story',
            'residentId': 'resident_0',
            'title': '会议室插曲',
            'summary': '只有会议室里才会发生。',
            'dialogueIds': [],
            'conditions': {'requiredLocation': 'meeting_room'},
            'result': {
              'memoryTags': ['meeting_story']
            },
            'priority': 10,
            'repeatable': true,
            'tags': ['meeting_story'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogueRuntime,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    expect(
        storyRuntime.getAvailableStories('resident_0').map((story) => story.id),
        contains('pantry_break_story'));
    expect(
        storyRuntime.getAvailableStories('resident_0').map((story) => story.id),
        isNot(contains('meeting_story')));

    runtime.applyRuntimeOverride(
      ResidentRuntimeOverride(
        residentId: 'resident_0',
        location: 'meetingRoom',
        activity: '参加一个轻轻的会议。',
        mood: 'busy',
        dayCount: clock.today().dayCount,
        source: 'test',
        reason: 'working',
        schedulePhase: 'working',
        isWorking: true,
        nextLocation: 'pantry',
        nextChangeTime: '13:00',
      ),
    );
    expect(
        runtime.getResidentCurrentState('resident_0').location, 'meeting_room');
    expect(dialogueRuntime.getDialogue('resident_0').id, 'meeting_dialogue');
    expect(
        storyRuntime.getAvailableStories('resident_0').map((story) => story.id),
        contains('meeting_story'));

    final lifeManager = ResidentLifeManager(_FakeResidentLifeRepository(life));
    await lifeManager.load();
    final legacyDialogue = ResidentDialogueEngine(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天慢一点。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      lifeManager: lifeManager,
      memoryEngine: memory,
      relationshipEngine: relationship,
    );
    final legacyStory = ResidentStoryEngine(
      config: ResidentStoryConfig.fromJson({'version': 'test', 'stories': []}),
      lifeManager: lifeManager,
      memoryEngine: memory,
      relationshipEngine: relationship,
      dialogueEngine: legacyDialogue,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: lifeManager,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: legacyDialogue,
      residentStoryEngine: legacyStory,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
    );
    final interaction = secondWorld.interactWithResident('resident_0');
    expect(interaction.locationId, 'meeting_room');
    expect(interaction.locationName, isNotEmpty);
    expect(interaction.locationTags, contains('meeting'));
    expect(interaction.availableInteractions, contains('start_story'));

    final saveManager = WorldSaveManager(
      repository: InMemoryWorldSaveRepository(),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      storyRuntimeManager: storyRuntime,
      dialogueRuntimeManager: dialogueRuntime,
    );
    final tick = WorldTickManager(
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
      secondWorldEngine: secondWorld,
    );
    final daily = DailySimulationManager(
      worldTickManager: tick,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
    );
    final quest = QuestRuntimeManager(
      taskConfig: TaskConfig.fromJson({
        'tasks': {
          'items': [
            {
              'id': 'visit_pantry',
              'title': '去茶水间看看',
              'description': '在休息地点遇见居民。',
              'category': 'daily',
              'metric': 'visit_location_pantry',
              'target': 1,
              'reward': {'fishCoin': 1, 'exp': 1},
              'sortOrder': 1,
            },
          ],
        },
      }),
      taskManager: TaskManagerView(),
      worldClockManager: clock,
      dailySimulationManager: daily,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      fishRuntimeManager: FishRuntimeManager(
        config: FishCatalogConfig.fromJson({'version': 'test', 'fish': []}),
        worldClockManager: clock,
        weatherRuntimeManager: weatherRuntime,
        festivalRuntimeManager: festivalRuntime,
        secondWorldEngine: secondWorld,
      ),
      rumorRuntimeManager: rumorRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      worldSaveManager: saveManager,
    );
    quest.recordLocationEvent('visit_location', 'pantry');
    expect(quest.cumulativeMetrics['visit_location_pantry'], 1);

    final saved = await saveManager.saveWorld(force: true, immediate: true);
    expect(
      ((saved.residentRuntime['states'] as List<dynamic>)
              .cast<Map<String, dynamic>>()
              .firstWhere((state) => state['residentId'] == 'resident_0'))[
          'residentCurrentLocation'],
      'meeting_room',
    );

    runtime.loadRuntimeStates([
      {
        'residentId': 'resident_0',
        'location': 'meeting-room',
        'activity': '旧存档会议',
        'mood': 'busy',
        'dayCount': clock.today().dayCount,
        'source': 'legacy',
        'schedulePhase': 'working',
      },
    ]);
    expect(
        runtime.getResidentCurrentState('resident_0').location, 'meeting_room');
  });

  test('resident personality integration influences runtime context safely',
      () async {
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 3, hour: 12, minute: 20),
      initialCalendar: WorldCalendar.initial().copyWith(
        dayCount: 3,
        weekdayIndex: 3,
        month: 4,
        day: 3,
        season: 'spring',
      ),
      paused: true,
    );
    final traits = <String>[
      'outgoing',
      'introverted',
      'hardworking',
      'lazy',
      'gossipy',
      'serious',
      'optimistic',
      'pessimistic',
      'curious',
      'cautious',
      'kind',
      'competitive',
      'playful',
      'calm',
      'sensitive',
    ];
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': List.generate(100, (index) {
        final trait = traits[index % traits.length];
        return {
          'id': 'person_$index',
          'name': '性格居民$index',
          'type': 'resident',
          'personality': index == 98 ? '未知性格' : trait,
          'dialogGroup': 'person_$index',
          'mood': index == 3 ? 'tired' : 'calm',
          'location': 'workplace_$index',
          'enabled': true,
          'home': 'home_$index',
          'workplace': 'workplace_$index',
          'dailyRoute': ['workplace_$index', 'pantry', 'coffee_shop', 'dock'],
        };
      }),
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [],
      },
      activityJson: {'version': 'test', 'activities': []},
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();

    final stopwatch = Stopwatch()..start();
    final personalityContexts = runtime.getAllResidentPersonalityContexts();
    stopwatch.stop();
    expect(personalityContexts.length, 100);
    expect(stopwatch.elapsedMilliseconds, lessThan(250));
    expect(personalityContexts['person_0']!.traits, contains('outgoing'));
    expect(personalityContexts['person_1']!.traits, contains('introverted'));
    expect(personalityContexts['person_2']!.traits, contains('hardworking'));
    expect(personalityContexts['person_3']!.traits, contains('lazy'));
    expect(personalityContexts['person_4']!.traits, contains('gossipy'));
    expect(personalityContexts['person_5']!.traits, contains('serious'));
    expect(personalityContexts['person_8']!.traits, contains('curious'));
    expect(personalityContexts['person_9']!.traits, contains('cautious'));
    expect(personalityContexts['person_10']!.traits, contains('kind'));
    expect(personalityContexts['person_12']!.traits, contains('playful'));
    expect(personalityContexts['person_98']!.traits, contains('calm'));
    expect(ResidentPersonalityContext.normalizeTrait('开朗'), 'outgoing');
    expect(ResidentPersonalityContext.normalizeTrait('未知性格'), 'calm');

    expect(runtime.getResidentCurrentState('person_0').location, 'pantry');
    expect(runtime.getResidentCurrentState('person_1').location, 'balcony');
    expect(runtime.getResidentCurrentState('person_3').isOnBreak, isTrue);
    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 3, hour: 17, minute: 20),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 3,
        weekdayIndex: 3,
        month: 4,
        day: 3,
        season: 'spring',
      ),
    );
    expect(
        runtime.getResidentCurrentState('person_2').schedulePhase, 'overtime');
    expect(
        runtime.getResidentCurrentState('person_3').schedulePhase, 'off_work');
    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 3, hour: 12, minute: 20),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 3,
        weekdayIndex: 3,
        month: 4,
        day: 3,
        season: 'spring',
      ),
    );
    expect(
        runtime.getAllResidentCurrentStates().values.every((state) {
          return LocationContext.isReasonableForPhase(
            state.location,
            state.schedulePhase,
          );
        }),
        isTrue);

    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [],
      }),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {'id': 'stranger', 'minMeetCount': 0, 'enabled': true},
          {'id': 'known', 'minMeetCount': 1, 'enabled': true},
          {'id': 'friend', 'minMeetCount': 5, 'enabled': true},
        ],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final festivalRuntime = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({'version': 'test', 'festivals': []}),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weatherRuntime = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({
        'version': 'test',
        'weatherEvents': [
          {
            'id': 'weather_storm_noon',
            'name': '午间暴雨',
            'type': 'storm',
            'season': ['spring'],
            'timeRange': '12:00-13:00',
            'residentMoodModifier': 'worried',
            'eventTags': ['storm'],
            'enabled': true,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final rumorRuntime = RumorRuntimeManager(
      config: RumorConfig.fromJson({
        'version': 'test',
        'rumors': [
          {
            'id': 'rumor_mystery_printer',
            'title': '打印机旁的小光点',
            'content': '有人说打印机旁出现了一点蓝色小光。',
            'category': 'mystery',
            'source': 'printing_area',
            'rarity': 'common',
            'timeRange': 'noon',
            'tags': ['mystery', 'ocean', 'rumor'],
            'weight': 1,
            'enabled': true,
          },
          {
            'id': 'rumor_office_report',
            'title': '办公室报告',
            'content': '主管说今天报告可以慢慢来。',
            'category': 'office',
            'source': 'office',
            'rarity': 'common',
            'timeRange': 'noon',
            'tags': ['office', 'work'],
            'weight': 1,
            'enabled': true,
          },
        ],
      }),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      residentRuntimeManager: runtime,
    );
    final dialogueRuntime = DialogueRuntimeManager(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '慢慢来。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [
          {
            'id': 'dialogue_gossipy',
            'residentId': 'person_4',
            'text': '我听说打印机旁有一点小传闻。',
            'conditions': {
              'personalityTags': ['gossipy'],
              'rumorTags': ['gossipy']
            },
            'priority': 10,
            'repeatable': true,
            'tags': ['rumor'],
          },
          {
            'id': 'dialogue_serious',
            'residentId': 'person_5',
            'text': '先把手头的工作收好，再看海。',
            'conditions': {
              'personalityTags': ['serious']
            },
            'priority': 10,
            'repeatable': true,
            'tags': ['work'],
          },
          {
            'id': 'dialogue_kind',
            'residentId': 'person_10',
            'text': '需要帮忙的话，叫我一声就好。',
            'conditions': {
              'personalityTags': ['kind']
            },
            'priority': 10,
            'repeatable': true,
            'tags': ['help', 'warm'],
          },
          {
            'id': 'dialogue_introverted',
            'residentId': 'person_1',
            'text': '嗯，今天也挺安静的。',
            'conditions': {
              'personalityTags': ['introverted']
            },
            'priority': 10,
            'repeatable': true,
            'tags': ['short'],
          },
          {
            'id': 'dialogue_playful',
            'residentId': 'person_12',
            'text': '刚才那张报表差点自己去摸鱼了。',
            'conditions': {
              'personalityTags': ['playful']
            },
            'priority': 10,
            'repeatable': true,
            'tags': ['humor'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    expect(dialogueRuntime.getDialogue('person_4').id, 'dialogue_gossipy');
    expect(dialogueRuntime.getDialogue('person_5').id, 'dialogue_serious');
    expect(dialogueRuntime.getDialogue('person_10').id, 'dialogue_kind');
    expect(dialogueRuntime.getDialogue('person_1').id, 'dialogue_introverted');
    expect(dialogueRuntime.getDialogue('person_12').id, 'dialogue_playful');

    final storyRuntime = StoryRuntimeManager(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [
          {
            'id': 'story_curious',
            'residentId': 'person_8',
            'title': '打印机蓝光',
            'summary': '好奇的人想去看看蓝色小光。',
            'dialogueIds': [],
            'conditions': {
              'personalityTags': ['curious']
            },
            'result': {
              'memoryTags': ['discovery']
            },
            'priority': 10,
            'repeatable': true,
            'tags': ['mystery', 'discovery'],
          },
          {
            'id': 'story_playful',
            'residentId': 'person_12',
            'title': '茶水间笑话',
            'summary': '一个轻轻的办公室笑话。',
            'dialogueIds': [],
            'conditions': {
              'personalityTags': ['playful']
            },
            'result': {
              'memoryTags': ['humor']
            },
            'priority': 10,
            'repeatable': true,
            'tags': ['humor'],
          },
          {
            'id': 'story_general',
            'residentId': 'person_8',
            'title': '普通小事',
            'summary': '不挑性格的小故事。',
            'dialogueIds': [],
            'conditions': {},
            'result': {},
            'priority': 1,
            'repeatable': true,
            'tags': ['daily'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogueRuntime,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final curiousStories = storyRuntime.getAvailableStories('person_8');
    expect(curiousStories.first.id, 'story_curious');
    expect(curiousStories.map((story) => story.id), contains('story_general'));
    expect(storyRuntime.getAvailableStories('person_12').first.id,
        'story_playful');

    final lifeManager =
        ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
    await lifeManager.load();
    final fallbackDialogue = ResidentDialogueEngine(
      config: ResidentDialogueConfig.fromJson({
        'fallback': {'id': 'fallback', 'residentId': '*', 'text': '慢慢来。'},
        'dialogues': [],
      }),
      lifeManager: lifeManager,
      memoryEngine: memory,
      relationshipEngine: relationship,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: lifeManager,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: fallbackDialogue,
      residentStoryEngine: ResidentStoryEngine(
        config: ResidentStoryConfig.fromJson({'stories': []}),
        lifeManager: lifeManager,
        memoryEngine: memory,
        relationshipEngine: relationship,
        dialogueEngine: fallbackDialogue,
      ),
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
    );
    final saveManager = WorldSaveManager(
      repository: InMemoryWorldSaveRepository(),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      storyRuntimeManager: storyRuntime,
      dialogueRuntimeManager: dialogueRuntime,
    );
    final tick = WorldTickManager(
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
      secondWorldEngine: secondWorld,
    );
    final daily = DailySimulationManager(
      worldTickManager: tick,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
    );
    final decision = ResidentDecisionManager(
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      weatherRuntimeManager: weatherRuntime,
      festivalRuntimeManager: festivalRuntime,
      rumorRuntimeManager: rumorRuntime,
      worldClockManager: clock,
      secondWorldEngine: secondWorld,
      dailySimulationManager: daily,
      residentMemoryEngine: memory,
    );
    decision.runResidentDecision();
    expect(decision.decisionFor('person_9')!.reason,
        contains('personality_cautious'));
    expect(runtime.getResidentCurrentState('person_9').location,
        isNot(anyOf('dock', 'seaside', 'park')));
    expect(runtime.getResidentCurrentState('person_12').mood,
        isNot(equals('angry')));

    final fishRuntime = FishRuntimeManager(
      config: FishCatalogConfig.fromJson({'version': 'test', 'fish': []}),
      worldClockManager: clock,
      weatherRuntimeManager: weatherRuntime,
      festivalRuntimeManager: festivalRuntime,
      secondWorldEngine: secondWorld,
    );
    final quest = QuestRuntimeManager(
      taskConfig: TaskConfig.fromJson({
        'tasks': {'items': []}
      }),
      taskManager: TaskManagerView(),
      worldClockManager: clock,
      dailySimulationManager: daily,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      fishRuntimeManager: fishRuntime,
      rumorRuntimeManager: rumorRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      worldSaveManager: saveManager,
    );
    final relationshipRuntime = RelationshipRuntimeManager(
      residentRuntimeManager: runtime,
      residentDecisionManager: decision,
      rumorRuntimeManager: rumorRuntime,
      storyRuntimeManager: storyRuntime,
      dailySimulationManager: daily,
      worldSaveManager: saveManager,
      residentRelationshipEngine: relationship,
      secondWorldEngine: secondWorld,
    );
    final achievement = AchievementRuntimeManager(
      honorConfig: HonorConfig.fromJson({'badges': []}),
      identityConfig: const {'identities': []},
      fishCollectionConfig: FishCollectionConfig.fromJson({
        'collection': {'fishes': []}
      }),
      taskConfig: TaskConfig.fromJson({
        'tasks': {'items': []}
      }),
      questRuntimeManager: quest,
      fishRuntimeManager: fishRuntime,
      relationshipRuntimeManager: relationshipRuntime,
      storyRuntimeManager: storyRuntime,
      rumorRuntimeManager: rumorRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      residentRuntimeManager: runtime,
      worldClockManager: clock,
      worldSaveManager: saveManager,
      secondWorldEngine: secondWorld,
    );
    final dynamicEvents = DynamicEventRuntimeManager(
      config: DynamicEventConfig.fromJson({
        'version': 'test',
        'events': [
          {
            'id': 'event_playful_humor',
            'type': 'office_humor',
            'category': 'office',
            'title': '办公室小笑话',
            'conditions': {
              'personalityTags': ['playful']
            },
            'priority': 20,
            'weight': 1,
            'probability': 1,
            'repeatable': true,
            'tags': ['office_humor'],
          },
          {
            'id': 'event_calm_only',
            'type': 'quiet',
            'category': 'resident',
            'title': '安静时刻',
            'conditions': {
              'personalityTags': ['calm'],
              'excludedPersonalityTags': ['playful']
            },
            'priority': 5,
            'weight': 1,
            'probability': 1,
            'repeatable': true,
            'tags': ['quiet'],
          },
        ],
      }),
      worldClockManager: clock,
      dailySimulationManager: daily,
      residentRuntimeManager: runtime,
      residentDecisionManager: decision,
      relationshipRuntimeManager: relationshipRuntime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      fishRuntimeManager: fishRuntime,
      questRuntimeManager: quest,
      achievementRuntimeManager: achievement,
      worldSaveManager: saveManager,
      secondWorldEngine: secondWorld,
      residentMemoryEngine: memory,
    );
    expect(dynamicEvents.getEventContext().personalityTags,
        containsAll(['playful', 'gossipy', 'curious']));
    expect(dynamicEvents.getAvailableEvents().map((event) => event.id),
        contains('event_playful_humor'));

    final gossipyRumors = rumorRuntime.getRumorsForResident('person_4');
    expect(gossipyRumors.first.id, isNotEmpty);
    expect(rumorRuntime.residentRumorContext('person_4').tags,
        contains('gossipy'));

    relationshipRuntime.applyRelationshipChange(
      'person_10',
      'person_25',
      'personality_affinity',
      1,
    );
    expect(
      relationshipRuntime
          .getRelationshipBetweenResidents('person_10', 'person_25')
          .tags,
      contains('personality_affinity'),
    );
    final interaction = secondWorld.interactWithResident('person_10');
    expect(interaction.personalityTags, contains('kind'));
    expect(interaction.interactionWillingness, 'high');
    expect(interaction.preferredTopics, contains('help'));

    await saveManager.saveWorld(force: true, immediate: true);
    final savedState =
        ((saveManager.lastSave!.residentRuntime['states'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .firstWhere((state) => state['residentId'] == 'person_9'));
    expect(savedState.containsKey('recentPersonalityInfluences'), isTrue);
    expect(savedState.containsKey('lastPersonalityDecisionReason'), isTrue);
    runtime.loadRuntimeStates([
      {
        'residentId': 'person_1',
        'location': 'workplace_1',
        'activity': '旧存档恢复',
        'mood': 'calm',
        'dayCount': clock.today().dayCount,
        'source': 'legacy',
      },
    ]);
    expect(runtime.getResidentPersonalityContext('person_1').traits,
        contains('introverted'));
  });

  test('resident memory engine records first and repeat interactions', () {
    final config = ResidentMemoryConfig.fromJson({
      'version': 'test',
      'memories': [
        {
          'residentId': 'old_fisher',
          'firstMeetTime': '',
          'lastMeetTime': '',
          'meetCount': 0,
          'lastInteraction': '',
          'memoryTags': [],
        },
      ],
    });
    final engine = ResidentMemoryEngine(config: config);
    final firstTime = DateTime.parse('2026-07-05T08:00:00.000');
    final secondTime = DateTime.parse('2026-07-05T09:30:00.000');

    final first = engine.recordInteraction(
      'old_fisher',
      'meet',
      time: firstTime,
      tags: const ['office_sea'],
    );
    expect(first.firstMeetTime, firstTime.toIso8601String());
    expect(first.lastMeetTime, firstTime.toIso8601String());
    expect(first.meetCount, 1);
    expect(first.lastInteraction, 'meet');
    expect(first.memoryTags, containsAll(['first_meet', 'meet', 'office_sea']));

    final second = engine.recordInteraction(
      'old_fisher',
      'talk',
      time: secondTime,
    );
    expect(second.firstMeetTime, firstTime.toIso8601String());
    expect(second.lastMeetTime, secondTime.toIso8601String());
    expect(second.meetCount, 2);
    expect(second.lastInteraction, 'talk');
    expect(second.memoryTags,
        containsAll(['first_meet', 'repeat_meet', 'meet', 'talk']));

    final exported = engine.toJson();
    final memories = exported['memories'] as List<dynamic>;
    final exportedRecord = memories
        .cast<Map<String, dynamic>>()
        .firstWhere((item) => item['residentId'] == 'old_fisher');
    expect(exportedRecord['meetCount'], 2);
    expect(exportedRecord['lastInteraction'], 'talk');
  });

  test('resident relationship engine updates levels from memory', () {
    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [
          {
            'residentId': 'old_fisher',
            'firstMeetTime': '',
            'lastMeetTime': '',
            'meetCount': 0,
            'lastInteraction': '',
            'memoryTags': [],
          },
        ],
      }),
    );
    final config = ResidentRelationshipConfig.fromJson({
      'version': 'test',
      'levels': [
        {
          'id': 'stranger',
          'name': '陌生',
          'minMeetCount': 0,
          'enabled': true,
          'sortOrder': 1
        },
        {
          'id': 'known',
          'name': '认识',
          'minMeetCount': 1,
          'enabled': true,
          'sortOrder': 2
        },
        {
          'id': 'friend',
          'name': '朋友',
          'minMeetCount': 5,
          'enabled': true,
          'sortOrder': 3
        },
        {
          'id': 'close_friend',
          'name': '亲近朋友',
          'minMeetCount': 20,
          'enabled': true,
          'sortOrder': 4
        },
        {
          'id': 'family_reserved',
          'name': '家人预留',
          'minMeetCount': 999999,
          'enabled': false,
          'sortOrder': 5
        },
      ],
      'relationships': [
        {
          'residentId': 'old_fisher',
          'relationshipLevel': 'stranger',
          'relationshipScore': 0,
          'lastChangedAt': '',
          'reason': '尚未见面',
          'tags': [],
        },
      ],
    });
    final relationship =
        ResidentRelationshipEngine(config: config, memoryEngine: memory);
    final time = DateTime.parse('2026-07-05T08:00:00.000');

    memory.recordInteraction('old_fisher', 'meet', time: time);
    final known = relationship.updateRelationship('old_fisher', time: time);
    expect(known.relationshipLevel, 'known');
    expect(known.relationshipScore, 1);
    expect(known.reason, contains('第一次见面'));

    for (var i = 0; i < 4; i++) {
      memory.recordInteraction('old_fisher', 'talk',
          time: time.add(Duration(minutes: i + 1)));
    }
    final friend = relationship.updateRelationship('old_fisher',
        time: time.add(const Duration(minutes: 10)));
    expect(friend.relationshipLevel, 'friend');
    expect(friend.reason, contains('朋友'));

    for (var i = 0; i < 15; i++) {
      memory.recordInteraction('old_fisher', 'talk',
          time: time.add(Duration(hours: i + 1)));
    }
    final close = relationship.updateRelationship('old_fisher',
        time: time.add(const Duration(days: 1)));
    expect(close.relationshipLevel, 'close_friend');
    expect(close.reason, contains('亲近'));
    expect(close.tags,
        containsAll(['first_meet', 'repeat_meet', 'talk', 'close_friend']));
  });

  test('resident dialogue engine matches state memory and relationship',
      () async {
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_morning',
            'residentId': 'old_fisher',
            'schedule': 'morning',
            'location': 'office_sea_window',
            'activity': '整理鱼竿',
            'activityId': 'prepare_rods',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'prepare_rods', 'name': '整理鱼竿'},
        ],
      },
    );
    final life = ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
    await life.load();
    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [
          {
            'residentId': 'old_fisher',
            'firstMeetTime': '',
            'lastMeetTime': '',
            'meetCount': 0,
            'lastInteraction': '',
            'memoryTags': [],
          },
        ],
      }),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1
          },
          {
            'id': 'known',
            'name': '认识',
            'minMeetCount': 1,
            'enabled': true,
            'sortOrder': 2
          },
          {
            'id': 'friend',
            'name': '朋友',
            'minMeetCount': 5,
            'enabled': true,
            'sortOrder': 3
          },
        ],
        'relationships': [
          {
            'residentId': 'old_fisher',
            'relationshipLevel': 'stranger',
            'relationshipScore': 0,
            'lastChangedAt': '',
            'reason': '尚未见面',
            'tags': [],
          },
        ],
      }),
      memoryEngine: memory,
    );
    final dialogue = ResidentDialogueEngine(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [
          {
            'id': 'old_fisher_stranger',
            'residentId': 'old_fisher',
            'text': '第一次来吧？别急。',
            'conditions': {
              'relationshipLevel': 'stranger',
              'timeOfDay': 'morning'
            },
            'priority': 10,
            'repeatable': true,
            'tags': ['intro'],
          },
          {
            'id': 'old_fisher_known',
            'residentId': 'old_fisher',
            'text': '又见面了。',
            'conditions': {
              'relationshipLevel': 'known',
              'location': 'office_sea_window',
              'meetCountMin': 1
            },
            'priority': 20,
            'repeatable': true,
            'tags': ['known'],
          },
          {
            'id': 'old_fisher_friend',
            'residentId': 'old_fisher',
            'text': '老朋友，今天也慢慢来。',
            'conditions': {
              'relationshipLevel': 'friend',
              'memoryTags': ['repeat_meet'],
              'meetCountMin': 5
            },
            'priority': 30,
            'repeatable': true,
            'tags': ['friend'],
          },
        ],
      }),
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
    );
    const clock = WorldClockConfig(
        hour: 8, minute: 0, weekday: 1, month: 7, season: 'summer');

    final stranger =
        dialogue.getDialogueForResident('old_fisher', clock: clock);
    expect(stranger.id, 'old_fisher_stranger');

    final time = DateTime.parse('2026-07-05T08:00:00.000');
    memory.recordInteraction('old_fisher', 'meet', time: time);
    relationship.updateRelationship('old_fisher', time: time);
    final known = dialogue.getDialogueForResident('old_fisher', clock: clock);
    expect(known.id, 'old_fisher_known');
    expect(known.text, isNot(stranger.text));

    for (var i = 0; i < 4; i++) {
      memory.recordInteraction('old_fisher', 'talk',
          time: time.add(Duration(minutes: i + 1)));
    }
    relationship.updateRelationship('old_fisher',
        time: time.add(const Duration(minutes: 10)));
    final friend = dialogue.getDialogueForResident('old_fisher', clock: clock);
    expect(friend.id, 'old_fisher_friend');
    expect(friend.text, isNot(known.text));
  });

  test('resident story engine triggers stories from relationship and memory',
      () async {
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_morning',
            'residentId': 'old_fisher',
            'schedule': 'morning',
            'location': 'office_sea_window',
            'activity': '整理鱼竿',
            'activityId': 'prepare_rods',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'prepare_rods', 'name': '整理鱼竿'},
        ],
      },
    );
    final life = ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
    await life.load();
    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [
          {
            'residentId': 'old_fisher',
            'firstMeetTime': '',
            'lastMeetTime': '',
            'meetCount': 0,
            'lastInteraction': '',
            'memoryTags': [],
          },
        ],
      }),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1
          },
          {
            'id': 'known',
            'name': '认识',
            'minMeetCount': 1,
            'enabled': true,
            'sortOrder': 2
          },
          {
            'id': 'friend',
            'name': '朋友',
            'minMeetCount': 5,
            'enabled': true,
            'sortOrder': 3
          },
        ],
        'relationships': [
          {
            'residentId': 'old_fisher',
            'relationshipLevel': 'stranger',
            'relationshipScore': 0,
            'lastChangedAt': '',
            'reason': '尚未见面',
            'tags': [],
          },
        ],
      }),
      memoryEngine: memory,
    );
    final dialogue = ResidentDialogueEngine(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [
          {
            'id': 'old_fisher_stranger',
            'residentId': 'old_fisher',
            'text': '第一次来吧？别急。',
            'conditions': {
              'relationshipLevel': 'stranger',
              'timeOfDay': 'morning'
            },
            'priority': 10,
            'repeatable': true,
            'tags': ['intro'],
          },
          {
            'id': 'old_fisher_known',
            'residentId': 'old_fisher',
            'text': '又见面了。',
            'conditions': {
              'relationshipLevel': 'known',
              'location': 'office_sea_window',
              'meetCountMin': 1
            },
            'priority': 20,
            'repeatable': true,
            'tags': ['known'],
          },
          {
            'id': 'old_fisher_friend',
            'residentId': 'old_fisher',
            'text': '老朋友，今天也慢慢来。',
            'conditions': {
              'relationshipLevel': 'friend',
              'memoryTags': ['repeat_meet'],
              'meetCountMin': 5
            },
            'priority': 30,
            'repeatable': true,
            'tags': ['friend'],
          },
        ],
      }),
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
    );
    final story = ResidentStoryEngine(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [
          {
            'id': 'old_fisher_first_story',
            'residentId': 'old_fisher',
            'title': '第一次听海风',
            'summary': '第一次遇见老渔夫。',
            'dialogueIds': ['old_fisher_stranger'],
            'conditions': {
              'relationshipLevel': 'stranger',
              'timeOfDay': 'morning'
            },
            'result': {
              'memoryTags': ['story_first_sea_wind']
            },
            'priority': 10,
            'repeatable': false,
            'tags': ['first_story'],
          },
          {
            'id': 'old_fisher_known_story',
            'residentId': 'old_fisher',
            'title': '安静的鱼漂',
            'summary': '再次见到老渔夫。',
            'dialogueIds': ['old_fisher_known'],
            'conditions': {'relationshipLevel': 'known', 'meetCountMin': 1},
            'result': {
              'memoryTags': ['story_quiet_float']
            },
            'priority': 20,
            'repeatable': false,
            'tags': ['known_story'],
          },
          {
            'id': 'old_fisher_friend_story',
            'residentId': 'old_fisher',
            'title': '大鱼从不赶时间',
            'summary': '朋友之间的慢钓提醒。',
            'dialogueIds': ['old_fisher_friend'],
            'conditions': {
              'relationshipLevel': 'friend',
              'memoryTags': ['repeat_meet'],
              'meetCountMin': 5
            },
            'result': {
              'memoryTags': ['story_slow_big_fish']
            },
            'priority': 30,
            'repeatable': false,
            'tags': ['friend_story'],
          },
        ],
      }),
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
      dialogueEngine: dialogue,
    );
    const clock = WorldClockConfig(
        hour: 8, minute: 0, weekday: 1, month: 7, season: 'summer');
    final time = DateTime.parse('2026-07-05T08:00:00.000');

    final firstAvailable =
        story.getAvailableStoriesForResident('old_fisher', clock: clock);
    expect(firstAvailable.single.id, 'old_fisher_first_story');
    final firstTriggered = story.triggerResidentStory(
        'old_fisher', 'old_fisher_first_story',
        clock: clock, now: time);
    expect(firstTriggered, isNotNull);
    expect(
        firstTriggered!.memory.memoryTags,
        containsAll([
          'story_triggered',
          'story:old_fisher_first_story',
          'story_first_sea_wind'
        ]));

    relationship.updateRelationship('old_fisher', time: time);
    final knownAvailable =
        story.getAvailableStoriesForResident('old_fisher', clock: clock);
    expect(knownAvailable.single.id, 'old_fisher_known_story');
    final knownTriggered = story.triggerResidentStory(
        'old_fisher', 'old_fisher_known_story',
        clock: clock, now: time.add(const Duration(minutes: 1)));
    expect(knownTriggered!.memory.memoryTags, contains('story_quiet_float'));

    for (var i = 0; i < 4; i++) {
      memory.recordInteraction('old_fisher', 'talk',
          time: time.add(Duration(minutes: i + 2)));
    }
    relationship.updateRelationship('old_fisher',
        time: time.add(const Duration(minutes: 10)));
    final friendAvailable =
        story.getAvailableStoriesForResident('old_fisher', clock: clock);
    expect(friendAvailable.single.id, 'old_fisher_friend_story');
    final friendTriggered = story.triggerResidentStory(
        'old_fisher', 'old_fisher_friend_story',
        clock: clock, now: time.add(const Duration(minutes: 11)));
    expect(friendTriggered!.memory.memoryTags, contains('story_slow_big_fish'));
  });

  test(
      'dialogue runtime manager filters dialogue from world and resident context',
      () async {
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'old_fisher',
          'mood': 'calm',
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'office_sea_window',
          'enabled': true,
        },
      ],
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_morning',
            'residentId': 'old_fisher',
            'schedule': 'morning',
            'location': 'office_sea_window',
            'activity': '整理鱼竿',
            'activityId': 'prepare_rods',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'prepare_rods', 'name': '整理鱼竿'},
        ],
      },
    );
    final clock = WorldClockManager(
      initialClock: WorldClock.initial().copyWith(hour: 8, minute: 0),
      initialCalendar: WorldCalendar.initial(),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [
          {
            'residentId': 'old_fisher',
            'firstMeetTime': '',
            'lastMeetTime': '',
            'meetCount': 0,
            'lastInteraction': '',
            'memoryTags': [],
          },
        ],
      }),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1
          },
          {
            'id': 'known',
            'name': '认识',
            'minMeetCount': 1,
            'enabled': true,
            'sortOrder': 2
          },
          {
            'id': 'friend',
            'name': '朋友',
            'minMeetCount': 5,
            'enabled': true,
            'sortOrder': 3
          },
        ],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final config = ResidentDialogueConfig.fromJson({
      'version': 'test',
      'fallback': {
        'id': 'fallback',
        'residentId': '*',
        'text': '今天风很轻。',
        'conditions': {},
        'priority': 0,
        'repeatable': true,
        'tags': ['fallback'],
      },
      'dialogues': [
        {
          'id': 'old_fisher_stranger_morning',
          'residentId': 'old_fisher',
          'text': '第一次来吧？早上的海风最适合慢慢等。',
          'conditions': {
            'timeOfDay': 'morning',
            'relationshipLevel': 'stranger',
            'residentLocation': 'office_sea_window',
            'residentActivity': '整理鱼竿',
            'residentMood': 'calm'
          },
          'priority': 10,
          'repeatable': true,
          'tags': ['first_meet'],
        },
        {
          'id': 'old_fisher_known_weather',
          'residentId': 'old_fisher',
          'text': '海面很平静，今天适合认识新朋友。',
          'conditions': {
            'weather': 'calmSea',
            'festival': 'new_year',
            'relationshipLevel': 'known',
            'meetCountMin': 1
          },
          'priority': 20,
          'repeatable': true,
          'tags': ['weather', 'festival'],
        },
        {
          'id': 'old_fisher_friend_story_done',
          'residentId': 'old_fisher',
          'text': '上次那个故事，我还记着呢。',
          'conditions': {
            'relationshipLevel': 'friend',
            'memoryTags': ['story:old_fisher_first_story'],
            'storyState': 'completed',
            'meetCountMin': 5
          },
          'priority': 30,
          'repeatable': false,
          'tags': ['story_after'],
        },
      ],
    });
    final dialogueRuntime = DialogueRuntimeManager(
      config: config,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
    );

    expect(dialogueRuntime.getDialogue('old_fisher').id,
        'old_fisher_stranger_morning');

    memory.recordInteraction('old_fisher', 'meet',
        time: DateTime.parse('2026-07-05T08:00:00.000'));
    relationship.updateRelationship('old_fisher');
    expect(dialogueRuntime.getAvailableDialogues('old_fisher').first.id,
        'old_fisher_known_weather');

    for (var i = 0; i < 4; i++) {
      memory.recordInteraction('old_fisher', 'talk',
          time: DateTime.parse('2026-07-05T08:0${i + 1}:00.000'));
    }
    memory.recordInteraction(
      'old_fisher',
      'story_triggered',
      tags: const ['story:old_fisher_first_story'],
    );
    relationship.updateRelationship('old_fisher');
    expect(dialogueRuntime.getDialogue('old_fisher').id,
        'old_fisher_friend_story_done');
    expect(dialogueRuntime.getDialogue('old_fisher').id,
        isNot('old_fisher_friend_story_done'));
  });

  test('festival runtime applies festival context to dialogue and story',
      () async {
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'old_fisher',
          'mood': 'calm',
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'office_sea_window',
          'enabled': true,
        },
      ],
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_morning',
            'residentId': 'old_fisher',
            'schedule': 'morning',
            'location': 'office_sea_window',
            'activity': '整理鱼竿',
            'activityId': 'prepare_rods',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'prepare_rods', 'name': '整理鱼竿'},
        ],
      },
    );
    final clock = WorldClockManager(
      initialClock: WorldClock.initial().copyWith(hour: 8, minute: 0),
      initialCalendar: WorldCalendar.initial().copyWith(month: 1, day: 2),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final festivalRuntime = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({
        'version': 'test',
        'festivals': [
          {
            'id': 'festival_new_year',
            'name': '新年',
            'category': 'real_world',
            'dateType': 'fixed',
            'dateValue': '01-01',
            'season': 'winter',
            'durationDays': 1,
            'mood': 'hopeful',
            'theme': '新年',
            'description': '新的一年从海风开始。',
            'worldEffects': {
              'residentMood': 'hopeful',
              'eventTags': ['festival', 'new_year']
            },
            'hooks': {
              'dialogueTags': ['festival_dialogue'],
              'storyTags': ['festival_story']
            },
            'unlockLevel': 1,
            'repeatable': true,
            'sortOrder': 1,
            'tags': ['festival', 'festival_new_year'],
            'enabled': true,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    expect(festivalRuntime.getActiveFestivals(), isEmpty);
    expect(festivalRuntime.isFestivalActive('festival_new_year'), isFalse);

    clock.setClock(
      WorldClock.initial().copyWith(hour: 8, minute: 0),
      calendar: WorldCalendar.initial().copyWith(month: 1, day: 1),
    );
    expect(festivalRuntime.getTodayFestival()?.id, 'festival_new_year');
    expect(festivalRuntime.isFestivalActive('new_year'), isTrue);
    expect(festivalRuntime.getFestivalTags(),
        containsAll(['festival_new_year', 'new_year', 'festival_dialogue']));

    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [
          {
            'residentId': 'old_fisher',
            'firstMeetTime': '',
            'lastMeetTime': '',
            'meetCount': 0,
            'lastInteraction': '',
            'memoryTags': [],
          },
        ],
      }),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1
          },
          {
            'id': 'known',
            'name': '认识',
            'minMeetCount': 1,
            'enabled': true,
            'sortOrder': 2
          },
        ],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final dialogueConfig = ResidentDialogueConfig.fromJson({
      'version': 'test',
      'fallback': {
        'id': 'fallback',
        'residentId': '*',
        'text': '今天风很轻。',
        'conditions': {},
        'priority': 0,
        'repeatable': true,
        'tags': ['fallback'],
      },
      'dialogues': [
        {
          'id': 'old_fisher_festival_dialogue',
          'residentId': 'old_fisher',
          'text': '新年的海风，会把旧疲惫慢慢吹走。',
          'conditions': {
            'festival': 'festival_new_year',
            'residentMood': 'hopeful',
            'residentActivity': 'festival:festival_new_year'
          },
          'priority': 30,
          'repeatable': true,
          'tags': ['festival_dialogue'],
        },
      ],
    });
    final dialogueRuntime = DialogueRuntimeManager(
      config: dialogueConfig,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
    );
    expect(dialogueRuntime.getDialogue('old_fisher').id,
        'old_fisher_festival_dialogue');

    final storyConfig = ResidentStoryConfig.fromJson({
      'version': 'test',
      'stories': [
        {
          'id': 'old_fisher_festival_story',
          'residentId': 'old_fisher',
          'title': '新年海风',
          'summary': '老渔夫在新年讲了一句很轻的话。',
          'dialogueIds': ['old_fisher_festival_dialogue'],
          'conditions': {
            'festival': 'new_year',
            'residentMood': 'hopeful',
            'residentActivity': 'festival:festival_new_year'
          },
          'result': {
            'memoryTags': ['festival_memory']
          },
          'priority': 40,
          'repeatable': false,
          'tags': ['festival_story'],
        },
      ],
    });
    final storyRuntime = StoryRuntimeManager(
      config: storyConfig,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogueRuntime,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
    );
    expect(storyRuntime.getAvailableStories('old_fisher').single.id,
        'old_fisher_festival_story');

    final life = ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
    await life.load();
    final oldDialogueEngine = ResidentDialogueEngine(
      config: dialogueConfig,
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
      worldClockManager: clock,
    );
    final oldStoryEngine = ResidentStoryEngine(
      config: storyConfig,
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
      dialogueEngine: oldDialogueEngine,
      worldClockManager: clock,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: life,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: oldDialogueEngine,
      residentStoryEngine: oldStoryEngine,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      festivalRuntimeManager: festivalRuntime,
    );
    final context = secondWorld.getResidentContext('old_fisher');
    expect(context.festival?.hasFestival, isTrue);
    expect(context.festival?.residentMood, 'hopeful');
    expect(context.availableStories.single.id, 'old_fisher_festival_story');
  });

  test('weather runtime applies weather context to dialogue and story',
      () async {
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'old_fisher',
          'mood': 'calm',
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'office_sea_window',
          'enabled': true,
        },
      ],
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_morning',
            'residentId': 'old_fisher',
            'schedule': 'morning',
            'location': 'office_sea_window',
            'activity': '整理鱼竿',
            'activityId': 'prepare_rods',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'prepare_rods', 'name': '整理鱼竿'},
        ],
      },
    );
    final clock = WorldClockManager(
      initialClock: WorldClock.initial().copyWith(hour: 8, minute: 0),
      initialCalendar: WorldCalendar.initial().copyWith(month: 1, day: 2),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final weatherRuntime = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({
        'version': 'test',
        'weatherEvents': [
          {
            'id': 'weather_sunny_morning',
            'name': '清晨晴天',
            'type': 'sunny',
            'rarity': 'common',
            'season': ['spring'],
            'timeRange': '06:00-09:00',
            'temperature': {'min': 24, 'max': 28, 'unit': 'celsius'},
            'windLevel': 2,
            'humidity': 45,
            'visibility': 'high',
            'fishBonus': {'activityMultiplier': 1.05},
            'residentMoodModifier': 'bright',
            'dialogueTags': ['weather_dialogue', 'sunny'],
            'storyTags': ['weather_story', 'sunny'],
            'eventTags': ['weather_event'],
            'festivalTags': ['weather'],
            'description': '清晨晴天。',
            'sortOrder': 1,
            'enabled': true,
          },
          {
            'id': 'weather_rain_night',
            'name': '夜雨',
            'type': 'rain',
            'rarity': 'rare',
            'season': ['spring'],
            'timeRange': '20:00-23:00',
            'temperature': {'min': 20, 'max': 23, 'unit': 'celsius'},
            'windLevel': 3,
            'humidity': 80,
            'visibility': 'medium',
            'fishBonus': {'activityMultiplier': 1.1},
            'residentMoodModifier': 'quiet',
            'dialogueTags': ['weather_dialogue', 'rain'],
            'storyTags': ['weather_story', 'rain'],
            'eventTags': ['weather_event'],
            'festivalTags': ['weather'],
            'description': '夜里下雨。',
            'sortOrder': 2,
            'enabled': true,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    expect(weatherRuntime.getCurrentWeather()?.id, 'weather_sunny_morning');
    expect(weatherRuntime.isWeatherActive('sunny'), isTrue);
    expect(weatherRuntime.getWeatherTags(),
        containsAll(['sunny', 'weather_sunny_morning']));

    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [
          {
            'residentId': 'old_fisher',
            'firstMeetTime': '',
            'lastMeetTime': '',
            'meetCount': 0,
            'lastInteraction': '',
            'memoryTags': [],
          },
        ],
      }),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1
          },
        ],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final dialogueConfig = ResidentDialogueConfig.fromJson({
      'version': 'test',
      'fallback': {
        'id': 'fallback',
        'residentId': '*',
        'text': '今天风很轻。',
        'conditions': {},
        'priority': 0,
        'repeatable': true,
        'tags': ['fallback'],
      },
      'dialogues': [
        {
          'id': 'old_fisher_sunny_dialogue',
          'residentId': 'old_fisher',
          'text': '晴天的海像刚刚醒来。',
          'conditions': {
            'weather': 'weather_sunny_morning',
            'residentMood': 'bright',
            'residentActivity': 'weather:weather_sunny_morning'
          },
          'priority': 30,
          'repeatable': true,
          'tags': ['weather_dialogue'],
        },
        {
          'id': 'old_fisher_rain_dialogue',
          'residentId': 'old_fisher',
          'text': '雨夜适合把话说慢一点。',
          'conditions': {
            'weather': 'rain',
            'residentMood': 'quiet',
            'residentActivity': 'weather:weather_rain_night'
          },
          'priority': 40,
          'repeatable': true,
          'tags': ['weather_dialogue'],
        },
      ],
    });
    final dialogueRuntime = DialogueRuntimeManager(
      config: dialogueConfig,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      weatherRuntimeManager: weatherRuntime,
    );
    expect(dialogueRuntime.getDialogue('old_fisher').id,
        'old_fisher_sunny_dialogue');

    final storyConfig = ResidentStoryConfig.fromJson({
      'version': 'test',
      'stories': [
        {
          'id': 'old_fisher_sunny_story',
          'residentId': 'old_fisher',
          'title': '晴天海面',
          'summary': '晴天让故事变得轻。',
          'dialogueIds': ['old_fisher_sunny_dialogue'],
          'conditions': {
            'weather': 'sunny',
            'residentMood': 'bright',
            'residentActivity': 'weather:weather_sunny_morning'
          },
          'result': {
            'memoryTags': ['sunny_memory']
          },
          'priority': 20,
          'repeatable': false,
          'tags': ['weather_story'],
        },
        {
          'id': 'old_fisher_rain_story',
          'residentId': 'old_fisher',
          'title': '夜雨故事',
          'summary': '雨夜的故事。',
          'dialogueIds': ['old_fisher_rain_dialogue'],
          'conditions': {
            'weather': 'weather_rain_night',
            'residentMood': 'quiet',
            'residentActivity': 'weather:weather_rain_night'
          },
          'result': {
            'memoryTags': ['rain_memory']
          },
          'priority': 30,
          'repeatable': false,
          'tags': ['weather_story'],
        },
      ],
    });
    final storyRuntime = StoryRuntimeManager(
      config: storyConfig,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogueRuntime,
      worldClockManager: clock,
      weatherRuntimeManager: weatherRuntime,
    );
    expect(storyRuntime.getAvailableStories('old_fisher').single.id,
        'old_fisher_sunny_story');

    clock.setClock(
      WorldClock.initial().copyWith(hour: 21, minute: 0),
      calendar: WorldCalendar.initial().copyWith(month: 1, day: 2),
    );
    expect(weatherRuntime.getCurrentWeather()?.id, 'weather_rain_night');
    expect(dialogueRuntime.getDialogue('old_fisher').id,
        'old_fisher_rain_dialogue');
    expect(storyRuntime.getAvailableStories('old_fisher').single.id,
        'old_fisher_rain_story');

    final life = ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
    await life.load();
    final oldDialogueEngine = ResidentDialogueEngine(
      config: dialogueConfig,
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
      worldClockManager: clock,
    );
    final oldStoryEngine = ResidentStoryEngine(
      config: storyConfig,
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
      dialogueEngine: oldDialogueEngine,
      worldClockManager: clock,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: life,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: oldDialogueEngine,
      residentStoryEngine: oldStoryEngine,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      weatherRuntimeManager: weatherRuntime,
    );
    final context = secondWorld.getResidentContext('old_fisher');
    expect(context.weather?.hasWeather, isTrue);
    expect(context.weather?.weatherId, 'weather_rain_night');
    expect(context.availableStories.single.id, 'old_fisher_rain_story');
  });

  test('fish runtime filters pool and drives fishing result', () async {
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'old_fisher',
          'mood': 'calm',
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'dock',
          'enabled': true,
        },
      ],
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_day',
            'residentId': 'old_fisher',
            'schedule': 'day',
            'location': 'dock',
            'activity': '看海',
            'activityId': 'watch_sea',
            'startTime': '06:00',
            'endTime': '20:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'watch_sea', 'name': '看海'},
        ],
      },
    );
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 1, hour: 8, minute: 0),
      initialCalendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        month: 1,
        day: 1,
        season: 'spring',
      ),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final festivalRuntime = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({
        'version': 'test',
        'festivals': [],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weatherRuntime = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({
        'version': 'test',
        'weatherEvents': [
          {
            'id': 'weather_sunny_morning',
            'name': '晴朗早晨',
            'type': 'sunny',
            'rarity': 'common',
            'season': ['spring'],
            'timeRange': '06:00-12:00',
            'temperature': {},
            'windLevel': 1,
            'humidity': 50,
            'visibility': 'clear',
            'fishBonus': {},
            'residentMoodModifier': 'bright',
            'dialogueTags': ['sunny'],
            'storyTags': ['sunny_story'],
            'eventTags': ['sunny_event'],
            'festivalTags': [],
            'enabled': true,
            'sortOrder': 1,
          },
          {
            'id': 'weather_rain_night',
            'name': '夜雨',
            'type': 'rain',
            'rarity': 'common',
            'season': ['spring'],
            'timeRange': '20:00-23:59',
            'temperature': {},
            'windLevel': 2,
            'humidity': 80,
            'visibility': 'mist',
            'fishBonus': {},
            'residentMoodModifier': 'quiet',
            'dialogueTags': ['rain'],
            'storyTags': ['rain_story'],
            'eventTags': ['rain_event'],
            'festivalTags': [],
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final fishRuntime = FishRuntimeManager(
      config: FishCatalogConfig.fromJson({
        'version': 'test',
        'fish': [
          {
            'id': 'fish_common_sunny',
            'name': '晨光小鱼',
            'nickname': '早起鱼',
            'rarity': 'common',
            'habitat': '海边',
            'favoriteTime': 'morning',
            'favoriteWeather': 'sunny',
            'favoriteBait': 'basic_bait',
            'fear': '闹钟',
            'personality': '好奇',
            'description': '喜欢早晨阳光的小鱼。',
            'story': '它常常第一个醒来。',
            'firstDialogue': '早呀，今天也慢一点。',
            'catchReaction': '晨光小鱼轻轻点头。',
            'waitDialogues': ['水下有一点晨光晃动。'],
            'value': 40,
            'weightRange': {'min': 1.0, 'max': 2.0, 'unit': 'kg'},
            'baitRequired': 'basic_bait',
            'nextBaitTarget': 'fish_rare_rain',
          },
          {
            'id': 'fish_rare_rain',
            'name': '雨夜蓝鱼',
            'nickname': '夜雨',
            'rarity': 'rare',
            'habitat': '深海',
            'favoriteTime': 'night',
            'favoriteWeather': 'rain',
            'favoriteBait': 'fish_common_sunny',
            'fear': '晴天',
            'personality': '神秘',
            'description': '只在雨夜靠近。',
            'story': '它把雨声藏在鳞片里。',
            'firstDialogue': '你听见雨了吗？',
            'catchReaction': '雨夜蓝鱼带来一小段雨声。',
            'waitDialogues': [
              '雨声下面，好像有蓝色鱼影。',
              '雨声下面，好像有蓝色鱼影。',
            ],
            'value': 180,
            'weightRange': {'min': 3.0, 'max': 6.0, 'unit': 'kg'},
            'baitRequired': 'fish_common_sunny',
            'nextBaitTarget': '',
          },
          {
            'id': 'fish_myth_wrong_bait',
            'name': '神话远鱼',
            'nickname': '远方',
            'rarity': 'myth',
            'habitat': '海边',
            'favoriteTime': 'morning',
            'favoriteWeather': 'sunny',
            'favoriteBait': 'myth_bait',
            'fear': '被催促',
            'personality': '神秘',
            'description': '它只接受传说中的鱼饵。',
            'story': '它远远看着第二世界。',
            'firstDialogue': '现在还不是时候。',
            'catchReaction': '它像梦一样闪了一下。',
            'waitDialogues': ['很远处有一点金色。'],
            'value': 999,
            'weightRange': {'min': 9.0, 'max': 12.0, 'unit': 'kg'},
            'baitRequired': 'myth_bait',
            'nextBaitTarget': '',
          },
        ],
      }),
      worldClockManager: clock,
      weatherRuntimeManager: weatherRuntime,
      festivalRuntimeManager: festivalRuntime,
    );

    expect(
      fishRuntime.getFishPoolByLocation('海边').map((fish) => fish.id),
      contains('fish_common_sunny'),
    );
    expect(
      fishRuntime.getFishPoolByLocation('深海').map((fish) => fish.id),
      isNot(contains('fish_common_sunny')),
    );
    expect(
      fishRuntime.getFishBiteChance('fish_myth_wrong_bait', 'bait_basic'),
      lessThan(
          fishRuntime.getFishBiteChance('fish_common_sunny', 'bait_basic')),
    );

    final morningResult = fishRuntime.selectFishResult(
      const FishRuntimeContext(baitId: 'bait_basic', locationId: '海边'),
    );
    expect(morningResult.fish.id, 'fish_common_sunny');
    expect(morningResult.waitDialogue, '水下有一点晨光晃动。');
    expect(morningResult.catchReaction, '晨光小鱼轻轻点头。');

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 1, hour: 21, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        month: 1,
        day: 1,
        season: 'spring',
      ),
    );
    final rainResult = fishRuntime.selectFishResult(
      const FishRuntimeContext(
        baitId: 'fish_common_sunny',
        locationId: '深海',
      ),
    );
    expect(rainResult.fish.id, 'fish_rare_rain');
    expect(rainResult.biteChance, lessThan(morningResult.biteChance));

    final fishing = FishingProvider(fishRuntimeManager: fishRuntime);
    fishing.throwLine(baitId: 'fish_common_sunny');
    expect(fishing.waitingMessages, contains('雨声下面，好像有蓝色鱼影。'));
    expect(
      fishing.waitingMessages.toSet().length,
      fishing.waitingMessages.length,
    );
    fishing.markFishHooked();
    fishing.pullLine();
    expect(fishing.result?.fishId, 'fish_rare_rain');
    expect(fishing.result?.metadata['catchReaction'], '雨夜蓝鱼带来一小段雨声。');
  });

  test('balance validation keeps fish bait chain ordered and reachable', () {
    final raw = jsonDecode(
      File('assets/config/fish_catalog.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final catalog = FishCatalogConfig.fromJson(raw);
    final byId = {for (final item in catalog.fish) item.id: item};
    int rarityRank(String rarity) {
      switch (rarity) {
        case 'myth':
        case 'mythic':
          return 6;
        case 'legend':
        case 'legendary':
          return 5;
        case 'epic':
          return 4;
        case 'rare':
          return 3;
        case 'good':
        case 'excellent':
          return 2;
        default:
          return 1;
      }
    }

    final missingTargets = <String>[];
    final cycles = <List<String>>[];
    final invalidBaits = <String>[];
    final unusableNonFinalBaits = <String>[];
    for (final item in catalog.fish) {
      final target = item.nextBaitTarget;
      if (target.isNotEmpty && !byId.containsKey(target)) {
        missingTargets.add(item.id);
      }
      final seen = <String>[];
      var current = item.id;
      while (current.isNotEmpty) {
        if (seen.contains(current)) {
          cycles.add([...seen, current]);
          break;
        }
        seen.add(current);
        current = byId[current]?.nextBaitTarget ?? '';
      }
      final bait = byId[item.baitRequired];
      if (bait != null && rarityRank(bait.rarity) >= rarityRank(item.rarity)) {
        invalidBaits.add(item.id);
      }
      if (rarityRank(item.rarity) < 6 && item.nextBaitTarget.isEmpty) {
        unusableNonFinalBaits.add(item.id);
      }
    }

    expect(missingTargets, isEmpty);
    expect(cycles, isEmpty);
    expect(invalidBaits, isEmpty);
    expect(unusableNonFinalBaits, isEmpty);
  });

  test('economy runtime updates market prices and restores save state',
      () async {
    final repository = InMemoryWorldSaveRepository();
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'old_fisher',
          'mood': 'calm',
          'location': 'dock',
          'enabled': true,
        },
      ],
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_morning',
            'residentId': 'old_fisher',
            'schedule': 'morning',
            'location': 'dock',
            'activity': '看海',
            'activityId': 'watch_sea',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'warm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'watch_sea', 'name': '看海'},
        ],
      },
    );
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 1, hour: 8, minute: 0),
      initialCalendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        month: 1,
        day: 1,
        season: 'spring',
      ),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final memory = ResidentMemoryEngine(
      config:
          ResidentMemoryConfig.fromJson({'version': 'test', 'memories': []}),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1,
          },
        ],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final festivalRuntime = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({
        'version': 'test',
        'festivals': [
          {
            'id': 'festival_fish_day',
            'name': '鱼市节',
            'dateType': 'fixed',
            'dateValue': '1-1',
            'durationDays': 1,
            'tags': ['fish_market'],
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weatherRuntime = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({
        'version': 'test',
        'weatherEvents': [
          {
            'id': 'weather_sunny',
            'name': '晴天',
            'type': 'sunny',
            'rarity': 'common',
            'season': ['spring'],
            'timeRange': '06:00-12:00',
            'temperature': {},
            'windLevel': 1,
            'humidity': 50,
            'visibility': 'clear',
            'fishBonus': {},
            'residentMoodModifier': 'bright',
            'dialogueTags': ['sunny'],
            'storyTags': ['sunny_story'],
            'eventTags': ['sunny_event'],
            'enabled': true,
            'sortOrder': 1,
          },
          {
            'id': 'weather_rain',
            'name': '雨天',
            'type': 'rain',
            'rarity': 'common',
            'season': ['spring'],
            'timeRange': '20:00-23:59',
            'temperature': {},
            'windLevel': 2,
            'humidity': 80,
            'visibility': 'mist',
            'fishBonus': {},
            'residentMoodModifier': 'quiet',
            'dialogueTags': ['rain'],
            'storyTags': ['rain_story'],
            'eventTags': ['rain_event'],
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final rumorRuntime = RumorRuntimeManager(
      config: RumorConfig.fromJson({'version': 'test', 'rumors': []}),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      residentRuntimeManager: runtime,
    );
    final dialogueRuntime = DialogueRuntimeManager(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final storyRuntime = StoryRuntimeManager(
      config: ResidentStoryConfig.fromJson({'version': 'test', 'stories': []}),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogueRuntime,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final saveManager = WorldSaveManager(
      repository: repository,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      storyRuntimeManager: storyRuntime,
      dialogueRuntimeManager: dialogueRuntime,
    );
    final legacyLife =
        ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
    await legacyLife.load();
    final legacyDialogue = ResidentDialogueEngine(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      lifeManager: legacyLife,
      memoryEngine: memory,
      relationshipEngine: relationship,
    );
    final legacyStory = ResidentStoryEngine(
      config: ResidentStoryConfig.fromJson({'version': 'test', 'stories': []}),
      lifeManager: legacyLife,
      memoryEngine: memory,
      relationshipEngine: relationship,
      dialogueEngine: legacyDialogue,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: legacyLife,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: legacyDialogue,
      residentStoryEngine: legacyStory,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      worldSaveManager: saveManager,
    );
    final fishRuntime = FishRuntimeManager(
      config: FishCatalogConfig.fromJson({
        'version': 'test',
        'fish': [
          {
            'id': 'fish_common',
            'name': '小鱼',
            'rarity': 'common',
            'habitat': '海边',
            'favoriteTime': 'morning',
            'favoriteWeather': 'sunny',
            'favoriteBait': 'basic_bait',
            'value': 100,
            'weightRange': {'min': 1, 'max': 2},
            'baitRequired': 'basic_bait',
            'nextBaitTarget': '',
            'waitDialogues': ['小鱼靠近了。'],
            'catchReaction': '小鱼上钩了。',
          },
          {
            'id': 'fish_rare',
            'name': '稀有雨鱼',
            'rarity': 'rare',
            'habitat': '海边',
            'favoriteTime': 'night',
            'favoriteWeather': 'rain',
            'favoriteBait': 'basic_bait',
            'value': 200,
            'weightRange': {'min': 2, 'max': 4},
            'baitRequired': 'basic_bait',
            'nextBaitTarget': '',
            'waitDialogues': ['雨鱼靠近了。'],
            'catchReaction': '雨鱼上钩了。',
          },
        ],
      }),
      worldClockManager: clock,
      weatherRuntimeManager: weatherRuntime,
      festivalRuntimeManager: festivalRuntime,
      secondWorldEngine: secondWorld,
    );
    final tick = WorldTickManager(
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
      fishRuntimeManager: fishRuntime,
      secondWorldEngine: secondWorld,
    )..register(secondWorld);
    final daily = DailySimulationManager(
      worldTickManager: tick,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
    );
    final quest = QuestRuntimeManager(
      taskConfig: TaskConfig.fromJson({
        'tasks': {
          'items': [
            {
              'id': 'daily_market',
              'title': '今日鱼市',
              'description': '看看今天鱼市。',
              'category': 'daily',
              'metric': 'today_world_summary',
              'target': 1,
              'progress': 0,
              'reward': {'fishCoin': 100, 'exp': 10},
              'status': 'not_started',
              'sortOrder': 1,
              'icon': '💰',
            },
          ],
        },
      }),
      taskManager: TaskManagerView(),
      worldClockManager: clock,
      dailySimulationManager: daily,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      fishRuntimeManager: fishRuntime,
      rumorRuntimeManager: rumorRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      worldSaveManager: saveManager,
    );
    final economy = EconomyRuntimeManager(
      fishRuntimeManager: fishRuntime,
      questRuntimeManager: quest,
      residentRuntimeManager: runtime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      worldClockManager: clock,
      worldSaveManager: saveManager,
      secondWorldEngine: secondWorld,
    );
    tick
      ..setQuestRuntimeManager(quest)
      ..setEconomyRuntimeManager(economy);

    economy.updateMarket();
    final sunnyFestivalPrice = economy.getFishSellPrice('fish_common');
    final residentDemand = economy.getResidentDemand('old_fisher');
    final reward = economy.calculateReward('daily_market');
    expect(sunnyFestivalPrice, greaterThan(100));
    expect(economy.getFishBuyPrice('fish_common'),
        greaterThan(sunnyFestivalPrice));
    expect(residentDemand, greaterThan(1));
    expect(reward.fishCoin, greaterThan(0));
    expect(saveManager.economyRuntimeState['priceMultiplier'], isNotNull);

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 2, hour: 21, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 2,
        month: 1,
        day: 2,
        season: 'spring',
      ),
    );
    economy.updateMarket();
    final rainyRarePrice = economy.getFishSellPrice('fish_rare');
    expect(rainyRarePrice, greaterThan(sunnyFestivalPrice));
    expect(economy.lastMarketDay, 2);

    final dayTick = await tick.tickDay(advanceClock: false);
    expect(
      dayTick.events
          .where((event) => event.type == TickEventType.beforeTick)
          .map((event) => event.stage),
      orderedEquals([
        'Tick',
        'Clock',
        'Festival',
        'Weather',
        'ResidentDecision',
        'Resident',
        'Rumor',
        'Fish',
        'Economy',
        'Relationship',
        'DynamicEvent',
        'Dialogue',
        'Story',
        'Quest',
        'Achievement',
        'Save',
      ]),
    );
    final saved = await repository.load();
    expect(saved?.economyRuntimeState['priceMultiplier'], isNotNull);
    final restored = EconomyRuntimeManager(
      fishRuntimeManager: fishRuntime,
      questRuntimeManager: quest,
      residentRuntimeManager: runtime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      worldClockManager: clock,
      worldSaveManager: saveManager,
    );
    expect(restored.getMarketMultiplier(), economy.getMarketMultiplier());
  });

  test('relationship runtime evolves residents and restores save state',
      () async {
    final repository = InMemoryWorldSaveRepository();
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'old_fisher',
          'mood': 'calm',
          'location': 'dock',
          'enabled': true,
        },
        {
          'id': 'sleepy_guard',
          'name': '午睡保安',
          'type': 'npc',
          'personality': 'sleepy',
          'dialogGroup': 'sleepy_guard',
          'mood': 'calm',
          'location': 'dock',
          'enabled': true,
        },
        {
          'id': 'front_desk',
          'name': '前台小妹',
          'type': 'npc',
          'personality': 'bright',
          'dialogGroup': 'front_desk',
          'mood': 'bright',
          'location': 'cafe',
          'enabled': true,
        },
      ],
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_morning',
            'residentId': 'old_fisher',
            'schedule': 'morning',
            'location': 'dock',
            'activity': '看海',
            'activityId': 'watch_sea',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
          {
            'id': 'sleepy_guard_morning',
            'residentId': 'sleepy_guard',
            'schedule': 'morning',
            'location': 'dock',
            'activity': '巡逻',
            'activityId': 'patrol',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
          {
            'id': 'front_desk_morning',
            'residentId': 'front_desk',
            'schedule': 'morning',
            'location': 'cafe',
            'activity': '喝咖啡',
            'activityId': 'coffee',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'bright',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'watch_sea', 'name': '看海'},
          {'id': 'patrol', 'name': '巡逻'},
          {'id': 'coffee', 'name': '喝咖啡'},
        ],
      },
    );
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 1, hour: 8, minute: 0),
      initialCalendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        month: 1,
        day: 1,
        season: 'spring',
      ),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final memory = ResidentMemoryEngine(
      config:
          ResidentMemoryConfig.fromJson({'version': 'test', 'memories': []}),
    );
    final playerRelationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1,
          },
          {
            'id': 'known',
            'name': '认识',
            'minMeetCount': 1,
            'enabled': true,
            'sortOrder': 2,
          },
        ],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final festivalRuntime = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({'version': 'test', 'festivals': []}),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weatherRuntime = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({
        'version': 'test',
        'weatherEvents': [
          {
            'id': 'weather_sunny',
            'name': '晴天',
            'type': 'sunny',
            'rarity': 'common',
            'season': ['spring'],
            'timeRange': '06:00-12:00',
            'temperature': {},
            'windLevel': 1,
            'humidity': 50,
            'visibility': 'clear',
            'fishBonus': {},
            'residentMoodModifier': 'bright',
            'dialogueTags': ['sunny'],
            'storyTags': ['sunny_story'],
            'eventTags': ['sunny_event'],
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final rumorRuntime = RumorRuntimeManager(
      config: RumorConfig.fromJson({
        'version': 'test',
        'rumors': [
          {
            'id': 'rumor_coffee',
            'title': '咖啡传闻',
            'content': '有人说今天咖啡店有新点心。',
            'category': 'resident',
            'source': '前台',
            'relatedResidentId': '',
            'relatedFishId': '',
            'relatedWeatherId': '',
            'relatedFestivalId': '',
            'rarity': 'common',
            'unlockCondition': {},
            'timeRange': 'morning',
            'tags': ['coffee_rumor'],
            'repeatable': true,
            'weight': 20,
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      residentRuntimeManager: runtime,
    );
    final dialogueRuntime = DialogueRuntimeManager(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: playerRelationship,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final storyRuntime = StoryRuntimeManager(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [
          {
            'id': 'front_desk_story',
            'residentId': 'front_desk',
            'title': '前台的新点心',
            'summary': '前台把新点心分给大家。',
            'dialogueIds': [],
            'conditions': {},
            'result': {
              'memoryTags': ['snack_story_done'],
            },
            'priority': 10,
            'repeatable': false,
            'tags': ['snack_story'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: playerRelationship,
      dialogueRuntimeManager: dialogueRuntime,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final saveManager = WorldSaveManager(
      repository: repository,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: playerRelationship,
      storyRuntimeManager: storyRuntime,
      dialogueRuntimeManager: dialogueRuntime,
    );
    final legacyLife =
        ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
    await legacyLife.load();
    final legacyDialogue = ResidentDialogueEngine(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      lifeManager: legacyLife,
      memoryEngine: memory,
      relationshipEngine: playerRelationship,
    );
    final legacyStory = ResidentStoryEngine(
      config: ResidentStoryConfig.fromJson({'version': 'test', 'stories': []}),
      lifeManager: legacyLife,
      memoryEngine: memory,
      relationshipEngine: playerRelationship,
      dialogueEngine: legacyDialogue,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: legacyLife,
      residentMemoryEngine: memory,
      residentRelationshipEngine: playerRelationship,
      residentDialogueEngine: legacyDialogue,
      residentStoryEngine: legacyStory,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      worldSaveManager: saveManager,
    );
    final tick = WorldTickManager(
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
      secondWorldEngine: secondWorld,
    )..register(secondWorld);
    final daily = DailySimulationManager(
      worldTickManager: tick,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
    );
    await daily.runDailySimulation();
    final decision = ResidentDecisionManager(
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      weatherRuntimeManager: weatherRuntime,
      festivalRuntimeManager: festivalRuntime,
      rumorRuntimeManager: rumorRuntime,
      worldClockManager: clock,
      secondWorldEngine: secondWorld,
      dailySimulationManager: daily,
    );
    final relationshipRuntime = RelationshipRuntimeManager(
      residentRuntimeManager: runtime,
      residentDecisionManager: decision,
      rumorRuntimeManager: rumorRuntime,
      storyRuntimeManager: storyRuntime,
      dailySimulationManager: daily,
      worldSaveManager: saveManager,
      residentRelationshipEngine: playerRelationship,
      secondWorldEngine: secondWorld,
    );
    tick.setRelationshipRuntimeManager(relationshipRuntime);

    relationshipRuntime.updateResidentRelationships();
    final sameLocation = relationshipRuntime.getRelationshipBetweenResidents(
      'old_fisher',
      'sleepy_guard',
    );
    expect(sameLocation.score, greaterThan(0));
    expect(sameLocation.tags, contains('same_location'));

    final rumorPair = relationshipRuntime.getRelationshipBetweenResidents(
      'old_fisher',
      'front_desk',
    );
    expect(rumorPair.score, greaterThan(0));
    expect(rumorPair.tags, contains('rumor'));

    storyRuntime.finishStory('front_desk_story');
    relationshipRuntime.updateResidentRelationships();
    final storyPair = relationshipRuntime.getRelationshipBetweenResidents(
      'sleepy_guard',
      'front_desk',
    );
    expect(storyPair.tags, contains('story'));

    memory.recordInteraction('old_fisher', 'meet');
    final playerKnown =
        relationshipRuntime.getPlayerRelationshipWithResident('old_fisher');
    expect(playerKnown.relationshipLevel, 'known');

    final beforeAbsence = relationshipRuntime.applyRelationshipChange(
        'old_fisher', 'front_desk', '临时熟悉', 10);
    final afterAbsence = relationshipRuntime.applyRelationshipChange(
      'old_fisher',
      'front_desk',
      '长时间未见，关系稍微变淡。',
      -5,
    );
    expect(afterAbsence.score, lessThan(beforeAbsence.score));
    expect(afterAbsence.tags, contains('long_absence'));

    await saveManager.saveWorld();
    final saved = await repository.load();
    expect(saved?.relationshipRuntimeState['residentRelationships'], isNotNull);
    final restored = RelationshipRuntimeManager(
      residentRuntimeManager: runtime,
      residentDecisionManager: decision,
      rumorRuntimeManager: rumorRuntime,
      storyRuntimeManager: storyRuntime,
      dailySimulationManager: daily,
      worldSaveManager: saveManager,
      residentRelationshipEngine: playerRelationship,
    );
    expect(
      restored
          .getRelationshipBetweenResidents('old_fisher', 'front_desk')
          .score,
      relationshipRuntime
          .getRelationshipBetweenResidents('old_fisher', 'front_desk')
          .score,
    );
  });

  test('rumor runtime spreads rumors and affects dialogue and story', () async {
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'old_fisher',
          'mood': 'calm',
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'office_sea_window',
          'enabled': true,
        },
      ],
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_morning',
            'residentId': 'old_fisher',
            'schedule': 'morning',
            'location': 'office_sea_window',
            'activity': '整理鱼竿',
            'activityId': 'prepare_rods',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'prepare_rods', 'name': '整理鱼竿'},
        ],
      },
    );
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 1, hour: 8, minute: 0),
      initialCalendar: WorldCalendar.initial().copyWith(dayCount: 1),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [
          {
            'residentId': 'old_fisher',
            'firstMeetTime': '',
            'lastMeetTime': '',
            'meetCount': 0,
            'lastInteraction': '',
            'memoryTags': [],
          },
        ],
      }),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1
          },
          {
            'id': 'known',
            'name': '认识',
            'minMeetCount': 1,
            'enabled': true,
            'sortOrder': 2
          },
        ],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final festivalRuntime = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({
        'version': 'test',
        'festivals': [],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weatherRuntime = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({
        'version': 'test',
        'weatherEvents': [
          {
            'id': 'weather_sunny_morning',
            'name': '晴朗早晨',
            'type': 'sunny',
            'rarity': 'common',
            'season': ['spring'],
            'timeRange': '06:00-12:00',
            'temperature': {'min': 18, 'max': 24},
            'windLevel': 2,
            'humidity': 55,
            'visibility': 'clear',
            'fishBonus': {},
            'residentMoodModifier': 'bright',
            'dialogueTags': ['sunny'],
            'storyTags': ['sunny_story'],
            'eventTags': ['sunny_event'],
            'festivalTags': [],
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final rumorRuntime = RumorRuntimeManager(
      config: RumorConfig.fromJson({
        'version': 'test',
        'rumors': [
          {
            'id': 'rumor_old_fisher_net',
            'title': '老渔夫的新网',
            'content': '有人说老渔夫今早把一张会听海风的网挂在窗边。',
            'category': 'resident',
            'source': '码头茶水间',
            'relatedResidentId': 'old_fisher',
            'relatedFishId': '',
            'relatedWeatherId': 'weather_sunny_morning',
            'relatedFestivalId': '',
            'rarity': 'rare',
            'unlockCondition': {
              'level': 1,
              'requiresFestivalId': '',
              'requiresWeatherId': '',
              'requiresResidentId': 'old_fisher',
              'requiresFishId': ''
            },
            'timeRange': 'morning',
            'tags': ['rumor', 'net_story', 'old_fisher_rumor'],
            'repeatable': true,
            'weight': 100,
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      residentRuntimeManager: runtime,
    );
    final dialogueRuntime = DialogueRuntimeManager(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [
          {
            'id': 'old_fisher_rumor_dialogue',
            'residentId': 'old_fisher',
            'text': '那张网啊，只是晒晒太阳，别听他们说得太神。',
            'conditions': {
              'timeOfDay': 'morning',
              'rumorTags': ['net_story']
            },
            'priority': 40,
            'repeatable': true,
            'tags': ['rumor_dialogue'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final storyRuntime = StoryRuntimeManager(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [
          {
            'id': 'old_fisher_rumor_story',
            'residentId': 'old_fisher',
            'title': '会听海风的网',
            'summary': '关于那张网的传闻，让老渔夫讲起了一段旧事。',
            'dialogueIds': ['old_fisher_rumor_dialogue'],
            'conditions': {
              'timeOfDay': 'morning',
              'rumorTags': ['net_story']
            },
            'result': {
              'memoryTags': ['heard_old_fisher_net_story']
            },
            'priority': 50,
            'repeatable': false,
            'tags': ['rumor_story'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogueRuntime,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );

    expect(rumorRuntime.isRumorActive('rumor_old_fisher_net'), isTrue);
    expect(rumorRuntime.getRumorsForResident('old_fisher').single.id,
        'rumor_old_fisher_net');
    rumorRuntime.addRumor('rumor_old_fisher_net');
    expect(rumorRuntime.recordFor('rumor_old_fisher_net')?.lifecycle,
        RumorLifecycle.spreading);
    expect(dialogueRuntime.getDialogue('old_fisher').id,
        'old_fisher_rumor_dialogue');
    expect(storyRuntime.getAvailableStories('old_fisher').single.id,
        'old_fisher_rumor_story');

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 4, hour: 8, minute: 0),
      calendar: WorldCalendar.initial().copyWith(dayCount: 4),
    );
    expect(rumorRuntime.recordFor('rumor_old_fisher_net')?.lifecycle,
        RumorLifecycle.popular);
    expect(rumorRuntime.getRumorTags(), contains('rumor_popular'));

    final life = ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
    await life.load();
    final legacyDialogue = ResidentDialogueEngine(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
    );
    final legacyStory = ResidentStoryEngine(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [],
      }),
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
      dialogueEngine: legacyDialogue,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: life,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: legacyDialogue,
      residentStoryEngine: legacyStory,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final context = secondWorld.getResidentContext('old_fisher');
    expect(context.rumor?.hasRumors, isTrue);
    expect(context.rumor?.tags, contains('net_story'));
    expect(context.dialogue.id, 'old_fisher_rumor_dialogue');
    expect(context.availableStories.single.id, 'old_fisher_rumor_story');

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 7, hour: 8, minute: 0),
      calendar: WorldCalendar.initial().copyWith(dayCount: 7),
    );
    expect(rumorRuntime.recordFor('rumor_old_fisher_net')?.lifecycle,
        RumorLifecycle.expired);
    expect(rumorRuntime.isRumorActive('rumor_old_fisher_net'), isFalse);
    expect(
        rumorRuntime.getRumorTags(), isNot(contains('rumor_old_fisher_net')));
  });

  test('world save manager saves restores migrates and resets runtime state',
      () async {
    final repository = InMemoryWorldSaveRepository();

    Future<Map<String, Object>> createWorld() async {
      final residents = ResidentConfig.fromJson({
        'version': 'test',
        'residents': [
          {
            'id': 'old_fisher',
            'name': '老渔夫',
            'type': 'npc',
            'personality': 'warm',
            'dialogGroup': 'old_fisher',
            'mood': 'calm',
            'friendship': 0,
            'unlockLevel': 1,
            'location': 'office_sea_window',
            'enabled': true,
          },
        ],
      });
      final lifeConfig = ResidentLifeConfig.fromJson(
        scheduleJson: {
          'version': 'test',
          'schedules': [
            {
              'id': 'old_fisher_morning',
              'residentId': 'old_fisher',
              'schedule': 'morning',
              'location': 'office_sea_window',
              'activity': '整理鱼竿',
              'activityId': 'prepare_rods',
              'startTime': '06:00',
              'endTime': '12:00',
              'mood': 'calm',
              'weekday': [1, 2, 3, 4, 5, 6, 7],
            },
          ],
        },
        activityJson: {
          'version': 'test',
          'activities': [
            {'id': 'prepare_rods', 'name': '整理鱼竿'},
          ],
        },
      );
      final clock = WorldClockManager(
        initialClock:
            WorldClock.initial().copyWith(dayCount: 1, hour: 8, minute: 0),
        initialCalendar: WorldCalendar.initial().copyWith(dayCount: 1),
        paused: true,
      );
      final runtime = ResidentRuntimeManager(
        residentRepository: _FakeResidentRepository(residents),
        lifeRepository: _FakeResidentLifeRepository(lifeConfig),
        worldClockManager: clock,
      );
      await runtime.load();
      final memory = ResidentMemoryEngine(
        config: ResidentMemoryConfig.fromJson({
          'version': 'test',
          'memories': [],
        }),
      );
      final relationship = ResidentRelationshipEngine(
        config: ResidentRelationshipConfig.fromJson({
          'version': 'test',
          'levels': [
            {
              'id': 'stranger',
              'name': '陌生',
              'minMeetCount': 0,
              'enabled': true,
              'sortOrder': 1
            },
            {
              'id': 'known',
              'name': '认识',
              'minMeetCount': 1,
              'enabled': true,
              'sortOrder': 2
            },
          ],
          'relationships': [],
        }),
        memoryEngine: memory,
      );
      final festivalRuntime = FestivalRuntimeManager(
        config: FestivalConfig.fromJson({
          'version': 'test',
          'festivals': [],
        }),
        worldClockManager: clock,
        residentRuntimeManager: runtime,
      );
      final weatherRuntime = WeatherRuntimeManager(
        config: WeatherConfig.fromJson({
          'version': 'test',
          'weatherEvents': [
            {
              'id': 'weather_sunny_morning',
              'name': '晴朗早晨',
              'type': 'sunny',
              'rarity': 'common',
              'season': ['spring'],
              'timeRange': '06:00-12:00',
              'temperature': {'min': 18, 'max': 24},
              'windLevel': 2,
              'humidity': 55,
              'visibility': 'clear',
              'fishBonus': {},
              'residentMoodModifier': 'bright',
              'dialogueTags': ['sunny'],
              'storyTags': ['sunny_story'],
              'eventTags': ['sunny_event'],
              'festivalTags': [],
              'enabled': true,
              'sortOrder': 1,
            },
          ],
        }),
        worldClockManager: clock,
        residentRuntimeManager: runtime,
      );
      final rumorRuntime = RumorRuntimeManager(
        config: RumorConfig.fromJson({
          'version': 'test',
          'rumors': [
            {
              'id': 'rumor_save_test',
              'title': '存档传闻',
              'content': '有人说老渔夫把今天的风保存了起来。',
              'category': 'resident',
              'source': '测试港口',
              'relatedResidentId': 'old_fisher',
              'relatedFishId': '',
              'relatedWeatherId': 'weather_sunny_morning',
              'relatedFestivalId': '',
              'rarity': 'rare',
              'unlockCondition': {
                'level': 1,
                'requiresFestivalId': '',
                'requiresWeatherId': '',
                'requiresResidentId': 'old_fisher',
                'requiresFishId': ''
              },
              'timeRange': 'morning',
              'tags': ['save_rumor'],
              'repeatable': true,
              'weight': 100,
              'enabled': true,
              'sortOrder': 1,
            },
          ],
        }),
        worldClockManager: clock,
        festivalRuntimeManager: festivalRuntime,
        weatherRuntimeManager: weatherRuntime,
        residentRuntimeManager: runtime,
      );
      final dialogueRuntime = DialogueRuntimeManager(
        config: ResidentDialogueConfig.fromJson({
          'version': 'test',
          'fallback': {
            'id': 'fallback',
            'residentId': '*',
            'text': '今天风很轻。',
            'conditions': {},
            'priority': 0,
            'repeatable': true,
            'tags': ['fallback'],
          },
          'dialogues': [
            {
              'id': 'old_fisher_save_dialogue',
              'residentId': 'old_fisher',
              'text': '存档里的海风，也会慢慢吹回来。',
              'conditions': {
                'rumorTags': ['save_rumor']
              },
              'priority': 20,
              'repeatable': false,
              'tags': ['save_dialogue'],
            },
          ],
        }),
        residentRuntimeManager: runtime,
        residentMemoryEngine: memory,
        residentRelationshipEngine: relationship,
        worldClockManager: clock,
        festivalRuntimeManager: festivalRuntime,
        weatherRuntimeManager: weatherRuntime,
        rumorRuntimeManager: rumorRuntime,
      );
      final storyRuntime = StoryRuntimeManager(
        config: ResidentStoryConfig.fromJson({
          'version': 'test',
          'stories': [
            {
              'id': 'old_fisher_save_story',
              'residentId': 'old_fisher',
              'title': '被保存的海风',
              'summary': '老渔夫把一段海风讲进了今天的存档。',
              'dialogueIds': ['old_fisher_save_dialogue'],
              'conditions': {
                'rumorTags': ['save_rumor']
              },
              'result': {
                'memoryTags': ['save_story_done']
              },
              'priority': 30,
              'repeatable': false,
              'tags': ['save_story'],
            },
          ],
        }),
        residentRuntimeManager: runtime,
        residentMemoryEngine: memory,
        residentRelationshipEngine: relationship,
        dialogueRuntimeManager: dialogueRuntime,
        worldClockManager: clock,
        festivalRuntimeManager: festivalRuntime,
        weatherRuntimeManager: weatherRuntime,
        rumorRuntimeManager: rumorRuntime,
      );
      final saveManager = WorldSaveManager(
        repository: repository,
        worldClockManager: clock,
        festivalRuntimeManager: festivalRuntime,
        weatherRuntimeManager: weatherRuntime,
        rumorRuntimeManager: rumorRuntime,
        residentRuntimeManager: runtime,
        residentMemoryEngine: memory,
        residentRelationshipEngine: relationship,
        storyRuntimeManager: storyRuntime,
        dialogueRuntimeManager: dialogueRuntime,
      );
      final life = ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
      await life.load();
      final legacyDialogue = ResidentDialogueEngine(
        config: ResidentDialogueConfig.fromJson({
          'version': 'test',
          'fallback': {
            'id': 'fallback',
            'residentId': '*',
            'text': '今天风很轻。',
            'conditions': {},
            'priority': 0,
            'repeatable': true,
            'tags': ['fallback'],
          },
          'dialogues': [],
        }),
        lifeManager: life,
        memoryEngine: memory,
        relationshipEngine: relationship,
      );
      final legacyStory = ResidentStoryEngine(
        config: ResidentStoryConfig.fromJson({
          'version': 'test',
          'stories': [],
        }),
        lifeManager: life,
        memoryEngine: memory,
        relationshipEngine: relationship,
        dialogueEngine: legacyDialogue,
      );
      final secondWorld = SecondWorldEngine(
        residentConfig: residents,
        residentLifeEngine: life,
        residentMemoryEngine: memory,
        residentRelationshipEngine: relationship,
        residentDialogueEngine: legacyDialogue,
        residentStoryEngine: legacyStory,
        dialogueRuntimeManager: dialogueRuntime,
        storyRuntimeManager: storyRuntime,
        festivalRuntimeManager: festivalRuntime,
        weatherRuntimeManager: weatherRuntime,
        rumorRuntimeManager: rumorRuntime,
        worldSaveManager: saveManager,
      );
      return {
        'clock': clock,
        'memory': memory,
        'relationship': relationship,
        'rumor': rumorRuntime,
        'dialogue': dialogueRuntime,
        'story': storyRuntime,
        'save': saveManager,
        'world': secondWorld,
      };
    }

    final first = await createWorld();
    final firstClock = first['clock']! as WorldClockManager;
    final firstRumor = first['rumor']! as RumorRuntimeManager;
    final firstDialogue = first['dialogue']! as DialogueRuntimeManager;
    final firstStory = first['story']! as StoryRuntimeManager;
    final firstSave = first['save']! as WorldSaveManager;
    final firstWorld = first['world']! as SecondWorldEngine;

    firstRumor.addRumor('rumor_save_test');
    final firstStoryResult = firstStory.triggerStory('old_fisher');
    expect(firstStoryResult?.story.id, 'old_fisher_save_story');
    expect(firstStoryResult?.refreshedDialogue.id, 'old_fisher_save_dialogue');
    expect(firstDialogue.servedNonRepeatableIds,
        contains('old_fisher_save_dialogue'));
    firstWorld.interactWithResident('old_fisher');
    firstClock.setClock(
      WorldClock.initial().copyWith(dayCount: 4, hour: 8, minute: 0),
      calendar: WorldCalendar.initial().copyWith(dayCount: 4),
    );
    await firstWorld.saveWorld();
    final saved = firstSave.lastSave;
    expect(saved, isNotNull);
    expect(saved!.saveVersion, currentWorldSaveVersion);
    expect(saved.worldClock.dayCount, 4);
    expect(saved.residentRuntime['states'], isNotEmpty);
    expect(saved.finishedStories, contains('old_fisher_save_story'));
    expect(
      saved.dialogueRuntimeState['servedNonRepeatableIds'],
      contains('old_fisher_save_dialogue'),
    );
    expect(
      saved.interactionHistory
          .where((record) => record.residentId == 'old_fisher'),
      isNotEmpty,
    );

    final second = await createWorld();
    final secondClock = second['clock']! as WorldClockManager;
    final secondMemory = second['memory']! as ResidentMemoryEngine;
    final secondRelationship =
        second['relationship']! as ResidentRelationshipEngine;
    final secondRumor = second['rumor']! as RumorRuntimeManager;
    final secondDialogue = second['dialogue']! as DialogueRuntimeManager;
    final secondStory = second['story']! as StoryRuntimeManager;
    final secondSave = second['save']! as WorldSaveManager;
    final secondWorld = second['world']! as SecondWorldEngine;

    await secondWorld.loadWorld();
    expect(secondClock.clock.dayCount, 4);
    expect(secondRumor.recordFor('rumor_save_test')?.lifecycle,
        RumorLifecycle.popular);
    expect(secondMemory.getResidentMemory('old_fisher').memoryTags,
        contains('save_story_done'));
    expect(secondRelationship.getRelationship('old_fisher').relationshipLevel,
        'known');
    expect(secondStory.finishedStoryIds, contains('old_fisher_save_story'));
    expect(secondDialogue.servedNonRepeatableIds,
        contains('old_fisher_save_dialogue'));
    expect(
      secondSave.interactionHistory
          .where((record) => record.residentId == 'old_fisher'),
      isNotEmpty,
    );

    secondClock.setClock(
      WorldClock.initial().copyWith(dayCount: 5, hour: 8, minute: 0),
      calendar: WorldCalendar.initial().copyWith(dayCount: 5),
    );
    final autoSaved = await secondSave.autoSave();
    expect(autoSaved.worldClock.dayCount, 5);
    expect((await repository.load())?.worldClock.dayCount, 5);

    await repository.save(autoSaved.copyWith(saveVersion: '1.0-legacy'));
    final migrated = await secondSave.loadWorld();
    expect(migrated?.saveVersion, currentWorldSaveVersion);

    await repository.save(autoSaved.copyWith(saveVersion: '9.0'));
    final incompatible = await secondSave.loadWorld();
    expect(incompatible, isNull);
    expect(await repository.load(), isNull);
    expect(secondClock.clock.dayCount, 1);
    expect(secondSave.interactionHistory, isEmpty);
  });

  test('world tick manager drives runtime in stable stage order', () async {
    final repository = InMemoryWorldSaveRepository();
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'old_fisher',
          'mood': 'calm',
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'office_sea_window',
          'enabled': true,
        },
      ],
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_morning',
            'residentId': 'old_fisher',
            'schedule': 'morning',
            'location': 'office_sea_window',
            'activity': '整理鱼竿',
            'activityId': 'prepare_rods',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'prepare_rods', 'name': '整理鱼竿'},
        ],
      },
    );
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 1, hour: 8, minute: 0),
      initialCalendar: WorldCalendar.initial().copyWith(dayCount: 1),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [],
      }),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1
          },
        ],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final festivalRuntime = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({
        'version': 'test',
        'festivals': [],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weatherRuntime = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({
        'version': 'test',
        'weatherEvents': [
          {
            'id': 'weather_sunny_morning',
            'name': '晴朗早晨',
            'type': 'sunny',
            'rarity': 'common',
            'season': ['spring'],
            'timeRange': '06:00-12:00',
            'temperature': {},
            'windLevel': 2,
            'humidity': 55,
            'visibility': 'clear',
            'fishBonus': {},
            'residentMoodModifier': 'bright',
            'dialogueTags': ['sunny'],
            'storyTags': ['sunny_story'],
            'eventTags': ['sunny_event'],
            'festivalTags': [],
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final rumorRuntime = RumorRuntimeManager(
      config: RumorConfig.fromJson({
        'version': 'test',
        'rumors': [],
      }),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      residentRuntimeManager: runtime,
    );
    final dialogueRuntime = DialogueRuntimeManager(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final storyRuntime = StoryRuntimeManager(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogueRuntime,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final saveManager = WorldSaveManager(
      repository: repository,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      storyRuntimeManager: storyRuntime,
      dialogueRuntimeManager: dialogueRuntime,
    );
    final life = ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
    await life.load();
    final legacyDialogue = ResidentDialogueEngine(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
    );
    final legacyStory = ResidentStoryEngine(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [],
      }),
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
      dialogueEngine: legacyDialogue,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: life,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: legacyDialogue,
      residentStoryEngine: legacyStory,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      worldSaveManager: saveManager,
    );
    final tick = WorldTickManager(
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
      secondWorldEngine: secondWorld,
    );
    tick.register(secondWorld);
    expect(tick.registered, isTrue);
    expect(tick.hasSecondWorldEngine, isTrue);

    final minute = await tick.tickMinute();
    expect(minute.tickType, TickType.minuteTick);
    expect(minute.afterClockMinute, 1);
    expect(
      minute.events
          .where((event) => event.type == TickEventType.beforeTick)
          .map((event) => event.stage),
      orderedEquals([
        'Tick',
        'Clock',
        'Festival',
        'Weather',
        'ResidentDecision',
        'Resident',
        'Rumor',
        'Fish',
        'Economy',
        'Relationship',
        'DynamicEvent',
        'Dialogue',
        'Story',
        'Quest',
        'Achievement',
        'Save',
      ]),
    );
    expect(saveManager.lastSave?.worldClock.minute, 1);

    final hour = await tick.tickHour();
    expect(hour.tickType, TickType.hourTick);
    expect(hour.afterClockHour, 9);
    final day = await tick.tickDay();
    expect(day.tickType, TickType.dayTick);
    expect(day.afterClockDay, 2);
    final week = await tick.tickWeek();
    expect(week.tickType, TickType.weekTick);
    expect(week.afterClockDay, 9);
    final month = await tick.tickMonth();
    expect(month.tickType, TickType.monthTick);
    expect(month.afterClockDay, 39);
    expect(tick.history.length, 5);
    expect((await repository.load())?.worldClock.dayCount, 39);

    tick.unregister();
    expect(tick.registered, isFalse);
  });

  test(
      'simulation optimizer caches stages batches residents and isolates errors',
      () async {
    final repository = _CountingWorldSaveRepository();
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': List.generate(100, (index) {
        return {
          'id': 'resident_$index',
          'name': '居民$index',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'resident_$index',
          'mood': 'calm',
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'office_sea_window',
          'enabled': true,
        };
      }),
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': List.generate(100, (index) {
          return {
            'id': 'resident_${index}_morning',
            'residentId': 'resident_$index',
            'schedule': 'morning',
            'location': 'office_sea_window',
            'activity': '看海',
            'activityId': 'watch_sea',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          };
        }),
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'watch_sea', 'name': '看海'},
        ],
      },
    );
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 1, hour: 8, minute: 0),
      initialCalendar: WorldCalendar.initial().copyWith(dayCount: 1),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [],
      }),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1,
          },
        ],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final festivalRuntime = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({
        'version': 'test',
        'festivals': [],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weatherRuntime = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({
        'version': 'test',
        'weatherEvents': [
          {
            'id': 'weather_sunny_morning',
            'name': '晴朗早晨',
            'type': 'sunny',
            'rarity': 'common',
            'season': ['spring'],
            'timeRange': '06:00-12:00',
            'temperature': {},
            'windLevel': 2,
            'humidity': 55,
            'visibility': 'clear',
            'fishBonus': {},
            'residentMoodModifier': 'bright',
            'dialogueTags': ['sunny'],
            'storyTags': ['sunny_story'],
            'eventTags': ['sunny_event'],
            'festivalTags': [],
            'enabled': true,
            'sortOrder': 1,
          },
          {
            'id': 'weather_rain_night',
            'name': '夜雨',
            'type': 'rain',
            'rarity': 'common',
            'season': ['spring'],
            'timeRange': '20:00-23:59',
            'temperature': {},
            'windLevel': 3,
            'humidity': 80,
            'visibility': 'soft',
            'fishBonus': {},
            'residentMoodModifier': 'quiet',
            'dialogueTags': ['rain'],
            'storyTags': ['rain_story'],
            'eventTags': ['rain_event'],
            'festivalTags': [],
            'enabled': true,
            'sortOrder': 2,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final rumorRuntime = RumorRuntimeManager(
      config: RumorConfig.fromJson({
        'version': 'test',
        'rumors': [],
      }),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      residentRuntimeManager: runtime,
    );
    final dialogueRuntime = DialogueRuntimeManager(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final storyRuntime = StoryRuntimeManager(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogueRuntime,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final saveManager = WorldSaveManager(
      repository: repository,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      storyRuntimeManager: storyRuntime,
      dialogueRuntimeManager: dialogueRuntime,
    );
    final tick = WorldTickManager(
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
    );

    expect(runtime.getAllResidentCurrentStates().length, 100);
    final first = await tick.runTick(TickType.minuteTick, advanceClock: false);
    expect(first.afterClockMinute, 0);
    final firstResult = tick.lastResult!;
    expect(firstResult.success, isTrue);
    expect(firstResult.executedStages.toSet().length,
        firstResult.executedStages.length);
    expect(firstResult.executedStages, contains('Resident'));
    expect(firstResult.worldContext.residentStates.length, 100);
    expect(firstResult.worldContext.weatherTags, contains('sunny'));
    expect(firstResult.runtimeResults.map((result) => result.stage),
        containsAll(firstResult.executedStages));
    expect(
        firstResult.runtimeResults.every((result) => result.success), isTrue);
    expect(firstResult.cacheHitRate, 0);
    expect(repository.saveCount, 1);

    await tick.runTick(TickType.minuteTick, advanceClock: false);
    final cached = tick.lastResult!;
    expect(cached.skippedStages, contains('Weather'));
    expect(cached.skippedStages, contains('Resident'));
    expect(cached.skippedStages, contains('Dialogue'));
    expect(cached.cacheHitRate, greaterThan(0));
    expect(repository.saveCount, 1);

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 1, hour: 21, minute: 0),
      calendar: WorldCalendar.initial().copyWith(dayCount: 1),
    );
    weatherRuntime.invalidateCache();
    await tick.runTick(TickType.minuteTick, advanceClock: false);
    expect(tick.lastResult!.executedStages, contains('Weather'));
    expect(weatherRuntime.getCurrentWeather()?.id, 'weather_rain_night');

    await tick.tickDay();
    expect(repository.saveCount, 3);
    expect(tick.profiler.lastProfile?.tickType, TickType.dayTick);
    expect(tick.lastResult?.durationMs, isNonNegative);
    expect(tick.lastResult?.runtimeResults.last.stage, 'Save');
    debugPrint(
      'Release Performance Baseline | minute=${firstResult.durationMs}ms '
      'cachedMinute=${cached.durationMs}ms day=${tick.lastResult!.durationMs}ms '
      'residentBatch=${firstResult.worldContext.residentStates.length} '
      'cacheHitRate=${cached.cacheHitRate.toStringAsFixed(2)} '
      'skipped=${cached.skippedStages.length} mergedSaves=1',
    );

    final failingWeather = _ThrowingWeatherRuntimeManager(
      clock: clock,
      runtime: runtime,
    );
    final failingSave = WorldSaveManager(
      repository: _CountingWorldSaveRepository(),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: failingWeather,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      storyRuntimeManager: storyRuntime,
      dialogueRuntimeManager: dialogueRuntime,
    );
    final failingTick = WorldTickManager(
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: failingWeather,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: failingSave,
    );
    await failingTick.tickMinute();
    expect(failingTick.lastResult?.success, isFalse);
    expect(failingTick.lastResult?.errors.keys, contains('Weather'));
    expect(failingTick.lastResult?.executedStages, contains('Resident'));
    expect(
      failingTick.lastResult?.runtimeResults
          .where((result) => result.stage == 'Weather')
          .single
          .success,
      isFalse,
    );
    expect(failingSave.lastSave, isNull);
  });

  test('daily simulation runs once per day and summarizes world changes',
      () async {
    final repository = InMemoryWorldSaveRepository();
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'old_fisher',
          'mood': 'calm',
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'office_sea_window',
          'enabled': true,
        },
      ],
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_morning',
            'residentId': 'old_fisher',
            'schedule': 'morning',
            'location': 'office_sea_window',
            'activity': '整理鱼竿',
            'activityId': 'prepare_rods',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'prepare_rods', 'name': '整理鱼竿'},
        ],
      },
    );
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 1, hour: 8, minute: 0),
      initialCalendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        month: 1,
        day: 1,
        season: 'spring',
      ),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [],
      }),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1
          },
        ],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final festivalRuntime = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({
        'version': 'test',
        'festivals': [
          {
            'id': 'festival_first_wind',
            'name': '第一阵海风日',
            'category': 'world',
            'dateType': 'fixed',
            'dateValue': '1-1',
            'durationDays': 1,
            'theme': 'sea_wind',
            'mood': 'warm',
            'residentMood': 'warm',
            'tags': ['first_wind'],
            'dialogueTags': ['festival_dialogue'],
            'storyTags': ['festival_story'],
            'eventTags': ['festival_event'],
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weatherRuntime = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({
        'version': 'test',
        'weatherEvents': [
          {
            'id': 'weather_sunny_morning',
            'name': '晴朗早晨',
            'type': 'sunny',
            'rarity': 'common',
            'season': ['spring'],
            'timeRange': '06:00-12:00',
            'temperature': {},
            'windLevel': 2,
            'humidity': 55,
            'visibility': 'clear',
            'fishBonus': {},
            'residentMoodModifier': 'bright',
            'dialogueTags': ['sunny'],
            'storyTags': ['sunny_story'],
            'eventTags': ['sunny_event'],
            'festivalTags': [],
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final rumorRuntime = RumorRuntimeManager(
      config: RumorConfig.fromJson({
        'version': 'test',
        'rumors': [
          {
            'id': 'rumor_daily_wind',
            'title': '窗边的海风传闻',
            'content': '有人说今天的窗边海风会把故事吹进办公室。',
            'category': 'weather',
            'source': '码头公告板',
            'relatedResidentId': 'old_fisher',
            'relatedFishId': '',
            'relatedWeatherId': 'weather_sunny_morning',
            'relatedFestivalId': 'festival_first_wind',
            'rarity': 'rare',
            'unlockCondition': {
              'level': 1,
              'requiresFestivalId': 'festival_first_wind',
              'requiresWeatherId': 'weather_sunny_morning',
              'requiresResidentId': 'old_fisher',
              'requiresFishId': ''
            },
            'timeRange': 'morning',
            'tags': ['daily_wind'],
            'repeatable': true,
            'weight': 100,
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      residentRuntimeManager: runtime,
    );
    final dialogueRuntime = DialogueRuntimeManager(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final storyRuntime = StoryRuntimeManager(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [
          {
            'id': 'old_fisher_daily_story',
            'residentId': 'old_fisher',
            'title': '今天的第一阵风',
            'summary': '老渔夫听见了今天的第一阵海风。',
            'dialogueIds': [],
            'conditions': {
              'weather': 'weather_sunny_morning',
              'festival': 'festival_first_wind',
              'rumorTags': ['daily_wind']
            },
            'result': {
              'memoryTags': ['daily_story_done']
            },
            'priority': 20,
            'repeatable': false,
            'tags': ['daily_story'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogueRuntime,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final saveManager = WorldSaveManager(
      repository: repository,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      storyRuntimeManager: storyRuntime,
      dialogueRuntimeManager: dialogueRuntime,
    );
    final life = ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
    await life.load();
    final legacyDialogue = ResidentDialogueEngine(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
    );
    final legacyStory = ResidentStoryEngine(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [],
      }),
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
      dialogueEngine: legacyDialogue,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: life,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: legacyDialogue,
      residentStoryEngine: legacyStory,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      worldSaveManager: saveManager,
    );
    final tick = WorldTickManager(
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
      secondWorldEngine: secondWorld,
    )..register(secondWorld);
    final daily = DailySimulationManager(
      worldTickManager: tick,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
    );

    await secondWorld.startWorld(dailySimulationManager: daily);
    final firstSummary = daily.getTodayWorldSummary();
    expect(firstSummary, isNotNull);
    expect(firstSummary!.date, contains('#1'));
    expect(firstSummary.weather, '晴朗早晨');
    expect(firstSummary.festival, '第一阵海风日');
    expect(firstSummary.activeRumors, contains('窗边的海风传闻'));
    expect(firstSummary.residentHighlights.single, contains('老渔夫'));
    expect(firstSummary.storyHints, contains('今天的第一阵风'));
    expect(firstSummary.todayMessage, contains('第一阵海风日'));
    expect(firstSummary.currentJobTitle, '实习生');
    expect(daily.hasRunToday(), isTrue);
    expect(daily.getDailyChanges().length, 7);
    expect(
      daily.getDailyChanges().map((change) => change.type),
      contains('living_office'),
    );
    expect(saveManager.lastSave?.dailySimulationState['lastRunDay'], 1);
    expect(tick.lastContext?.afterClockDay, 1);

    await secondWorld.startWorld(dailySimulationManager: daily);
    expect(daily.getDailyChanges().length, 7);
    expect(daily.getTodayWorldSummary()?.date, firstSummary.date);

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 2, hour: 8, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 2,
        month: 1,
        day: 2,
        season: 'spring',
      ),
    );
    await daily.runDailySimulation();
    final secondSummary = daily.getTodayWorldSummary();
    expect(secondSummary?.date, contains('#2'));
    expect(secondSummary?.date, isNot(firstSummary.date));
    expect(daily.getDailyChanges().length, 14);
    expect(saveManager.lastSave?.dailySimulationState['lastRunDay'], 2);
  });

  test('quest runtime syncs tasks from world state and daily refresh',
      () async {
    final repository = InMemoryWorldSaveRepository();
    final taskConfig = TaskConfig.fromJson({
      'tasks': {
        'items': [
          {
            'id': 'daily_fish_once',
            'title': '今日抛线',
            'description': '今天抛一次线。',
            'category': 'daily',
            'metric': 'fishing_count',
            'target': 1,
            'progress': 0,
            'reward': {'fishCoin': 10, 'exp': 2},
            'status': 'not_started',
            'sortOrder': 1,
            'icon': '🎣',
          },
          {
            'id': 'daily_story_once',
            'title': '今日故事',
            'description': '今天遇见一个故事。',
            'category': 'daily',
            'metric': 'story_triggered_count',
            'target': 1,
            'progress': 0,
            'reward': {'fishCoin': 10, 'exp': 2},
            'status': 'not_started',
            'sortOrder': 2,
            'icon': '📖',
          },
          {
            'id': 'growth_resident_chat',
            'title': '认识居民',
            'description': '和居民互动。',
            'category': 'growth',
            'metric': 'resident_interaction_count',
            'target': 1,
            'progress': 0,
            'reward': {'fishCoin': 20, 'exp': 4},
            'status': 'not_started',
            'sortOrder': 3,
            'icon': '👋',
          },
        ],
      },
    });
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'old_fisher',
          'mood': 'calm',
          'location': 'dock',
          'enabled': true,
        },
      ],
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_morning',
            'residentId': 'old_fisher',
            'schedule': 'morning',
            'location': 'dock',
            'activity': '看海',
            'activityId': 'watch_sea',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'watch_sea', 'name': '看海'},
        ],
      },
    );
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 1, hour: 8, minute: 0),
      initialCalendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        month: 1,
        day: 1,
        season: 'spring',
      ),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final memory = ResidentMemoryEngine(
      config:
          ResidentMemoryConfig.fromJson({'version': 'test', 'memories': []}),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1,
          },
        ],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final festivalRuntime = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({
        'version': 'test',
        'festivals': [
          {
            'id': 'festival_first_wind',
            'name': '第一阵海风日',
            'dateType': 'fixed',
            'dateValue': '1-1',
            'durationDays': 1,
            'tags': ['first_wind'],
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weatherRuntime = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({
        'version': 'test',
        'weatherEvents': [
          {
            'id': 'weather_sunny_morning',
            'name': '晴朗早晨',
            'type': 'sunny',
            'rarity': 'common',
            'season': ['spring'],
            'timeRange': '06:00-12:00',
            'temperature': {},
            'windLevel': 1,
            'humidity': 50,
            'visibility': 'clear',
            'fishBonus': {},
            'residentMoodModifier': 'bright',
            'dialogueTags': ['sunny'],
            'storyTags': ['sunny_story'],
            'eventTags': ['sunny_event'],
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final rumorRuntime = RumorRuntimeManager(
      config: RumorConfig.fromJson({
        'version': 'test',
        'rumors': [
          {
            'id': 'rumor_first_wind',
            'title': '海风传闻',
            'content': '今天风很轻。',
            'category': 'weather',
            'source': '码头',
            'relatedResidentId': 'old_fisher',
            'relatedFishId': '',
            'relatedWeatherId': 'weather_sunny_morning',
            'relatedFestivalId': 'festival_first_wind',
            'rarity': 'common',
            'unlockCondition': {},
            'timeRange': 'morning',
            'tags': ['first_wind'],
            'repeatable': true,
            'weight': 10,
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      residentRuntimeManager: runtime,
    );
    final dialogueRuntime = DialogueRuntimeManager(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final storyRuntime = StoryRuntimeManager(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [
          {
            'id': 'old_fisher_story',
            'residentId': 'old_fisher',
            'title': '看海',
            'summary': '老渔夫看着海。',
            'dialogueIds': [],
            'conditions': {},
            'result': {
              'memoryTags': ['story_done'],
            },
            'priority': 10,
            'repeatable': false,
            'tags': ['story'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogueRuntime,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final saveManager = WorldSaveManager(
      repository: repository,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      storyRuntimeManager: storyRuntime,
      dialogueRuntimeManager: dialogueRuntime,
    );
    final legacyLife =
        ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
    await legacyLife.load();
    final legacyDialogue = ResidentDialogueEngine(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      lifeManager: legacyLife,
      memoryEngine: memory,
      relationshipEngine: relationship,
    );
    final legacyStory = ResidentStoryEngine(
      config: ResidentStoryConfig.fromJson({'version': 'test', 'stories': []}),
      lifeManager: legacyLife,
      memoryEngine: memory,
      relationshipEngine: relationship,
      dialogueEngine: legacyDialogue,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: legacyLife,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: legacyDialogue,
      residentStoryEngine: legacyStory,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      worldSaveManager: saveManager,
    );
    final tick = WorldTickManager(
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
      secondWorldEngine: secondWorld,
    )..register(secondWorld);
    final daily = DailySimulationManager(
      worldTickManager: tick,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
    );
    final fishRuntime = FishRuntimeManager(
      config: FishCatalogConfig.fromJson({
        'version': 'test',
        'fish': [
          {
            'id': 'fish_common',
            'name': '小鱼',
            'rarity': 'common',
            'habitat': '海边',
            'favoriteTime': 'morning',
            'favoriteWeather': 'sunny',
            'favoriteBait': 'basic_bait',
            'value': 10,
            'weightRange': {'min': 1, 'max': 2},
            'baitRequired': 'basic_bait',
            'waitDialogues': ['小鱼靠近了。'],
            'catchReaction': '小鱼上钩了。',
          },
        ],
      }),
      worldClockManager: clock,
      weatherRuntimeManager: weatherRuntime,
      festivalRuntimeManager: festivalRuntime,
      secondWorldEngine: secondWorld,
    );
    final taskManager = TaskManagerView();
    final quest = QuestRuntimeManager(
      taskConfig: taskConfig,
      taskManager: taskManager,
      worldClockManager: clock,
      dailySimulationManager: daily,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      fishRuntimeManager: fishRuntime,
      rumorRuntimeManager: rumorRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      worldSaveManager: saveManager,
    );
    final fishing = FishingProvider(fishRuntimeManager: fishRuntime);
    final inventory = InventoryManagerView();
    final collection = CollectionManagerView();
    final transactions = TransactionManagerView();

    await quest.refreshAfterDailySimulation(
      fishing: fishing,
      inventory: inventory,
      collection: collection,
      transactions: transactions,
    );
    expect(daily.hasRunToday(), isTrue);
    expect(quest.visibleTasks('daily').first.progress, 0);

    fishing.throwLine();
    quest.syncFromState(
      fishing: fishing,
      inventory: inventory,
      collection: collection,
      transactions: transactions,
    );
    expect(
      quest
          .visibleTasks('daily')
          .firstWhere((task) => task.config.id == 'daily_fish_once')
          .status,
      'claimable',
    );

    quest.recordResidentInteraction('old_fisher');
    quest.syncFromState(
      fishing: fishing,
      inventory: inventory,
      collection: collection,
      transactions: transactions,
    );
    expect(
      quest
          .visibleTasks('growth')
          .firstWhere((task) => task.config.id == 'growth_resident_chat')
          .status,
      'claimable',
    );

    quest.recordStoryTriggered('old_fisher_story');
    quest.syncFromState(
      fishing: fishing,
      inventory: inventory,
      collection: collection,
      transactions: transactions,
    );
    expect(
      quest
          .visibleTasks('daily')
          .firstWhere((task) => task.config.id == 'daily_story_once')
          .status,
      'claimable',
    );

    final wallet = WalletManagerView(initialFishCoin: 0);
    final claimed = quest.claimReward(
      task: quest.visibleTasks('daily').first.config,
      wallet: wallet,
      transactions: transactions,
    );
    expect(claimed, isTrue);
    expect(saveManager.taskRewards.length, 1);
    expect(saveManager.interactionHistory.last.tags, contains('quest_reward'));

    final beforeChanges = daily.getDailyChanges().length;
    await quest.refreshAfterDailySimulation(
      fishing: fishing,
      inventory: inventory,
      collection: collection,
      transactions: transactions,
    );
    expect(daily.getDailyChanges().length, beforeChanges);

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 2, hour: 8, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 2,
        month: 1,
        day: 2,
        season: 'spring',
      ),
    );
    await quest.refreshAfterDailySimulation(
      fishing: fishing,
      inventory: inventory,
      collection: collection,
      transactions: transactions,
    );
    expect(quest.lastRefreshDay, 2);
    expect(saveManager.questRuntimeState['lastRefreshDay'], 2);
  });

  test('resident decision manager adapts activity from world context',
      () async {
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'old_fisher',
          'mood': 'calm',
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'dock',
          'home': 'old_fisher_home',
          'workplace': 'dock',
          'dailyRoute': ['dock', 'coffee_shop', 'office_lounge'],
          'organization': {
            'companyId': 'fishing_office',
            'departmentId': 'operations',
            'teamId': 'dock_services',
            'positionId': 'staff',
          },
          'career': {
            'hireDate': 'Y1-M01-D01',
            'careerLevel': 'regular',
            'salaryLevel': 180,
            'employmentStatus': 'active',
            'performanceScore': 86,
            'capabilityScore': 82,
            'promotionHistory': [],
          },
          'enabled': true,
        },
        {
          'id': 'front_desk',
          'name': '前台小妹',
          'type': 'resident',
          'personality': 'bright',
          'dialogGroup': 'front_desk',
          'mood': 'happy',
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'coffee_shop',
          'home': 'resident_area',
          'workplace': 'office_front',
          'dailyRoute': ['office_front', 'coffee_shop'],
          'enabled': true,
        },
        {
          'id': 'sleepy_guard',
          'name': '午睡保安',
          'type': 'resident',
          'personality': 'relaxed',
          'dialogGroup': 'sleepy_guard',
          'mood': 'sleepy',
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'office_lounge',
          'home': 'guard_room',
          'workplace': 'office_gate',
          'dailyRoute': ['office_gate', 'office_lounge'],
          'organization': {
            'companyId': 'fishing_office',
            'departmentId': 'front_office',
            'teamId': 'office_admin',
            'positionId': 'staff',
          },
          'career': {
            'hireDate': 'Y1-M01-D01',
            'careerLevel': 'regular',
            'salaryLevel': 180,
            'employmentStatus': 'active',
            'performanceScore': 48,
            'capabilityScore': 42,
            'promotionHistory': [],
          },
          'enabled': true,
        },
      ],
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_day',
            'residentId': 'old_fisher',
            'schedule': 'day',
            'location': 'dock',
            'activity': '看着海面整理鱼线',
            'activityId': 'watch_sea',
            'startTime': '06:00',
            'endTime': '20:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
          {
            'id': 'front_desk_day',
            'residentId': 'front_desk',
            'schedule': 'day',
            'location': 'coffee_shop',
            'activity': '给大家留一杯热咖啡',
            'activityId': 'coffee',
            'startTime': '06:00',
            'endTime': '20:00',
            'mood': 'happy',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
          {
            'id': 'sleepy_guard_day',
            'residentId': 'sleepy_guard',
            'schedule': 'day',
            'location': 'office_lounge',
            'activity': '在门口打一个很轻的盹',
            'activityId': 'nap',
            'startTime': '06:00',
            'endTime': '20:00',
            'mood': 'sleepy',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'watch_sea', 'name': '看海'},
          {'id': 'coffee', 'name': '准备咖啡'},
          {'id': 'nap', 'name': '轻轻打盹'},
        ],
      },
    );
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 1, hour: 8, minute: 0),
      initialCalendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        month: 1,
        day: 1,
        season: 'spring',
      ),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [],
      }),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1
          },
          {
            'id': 'known',
            'name': '认识',
            'minMeetCount': 1,
            'enabled': true,
            'sortOrder': 2
          },
          {
            'id': 'friend',
            'name': '朋友',
            'minMeetCount': 5,
            'enabled': true,
            'sortOrder': 3
          },
        ],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final festivalRuntime = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({
        'version': 'test',
        'festivals': [
          {
            'id': 'festival_first_wind',
            'name': '第一阵海风日',
            'category': 'world',
            'dateType': 'fixed',
            'dateValue': '1-1',
            'durationDays': 1,
            'theme': 'sea_wind',
            'mood': 'warm',
            'residentMood': 'warm',
            'tags': ['first_wind'],
            'dialogueTags': ['festival_dialogue'],
            'storyTags': ['festival_story'],
            'eventTags': ['festival_event'],
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weatherRuntime = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({
        'version': 'test',
        'weatherEvents': [
          {
            'id': 'weather_rain_morning',
            'name': '小雨早晨',
            'type': 'rain',
            'rarity': 'common',
            'season': ['spring'],
            'timeRange': '06:00-12:00',
            'temperature': {},
            'windLevel': 2,
            'humidity': 80,
            'visibility': 'misty',
            'fishBonus': {},
            'residentMoodModifier': 'quiet',
            'dialogueTags': ['rain'],
            'storyTags': ['rain_story'],
            'eventTags': ['rain_event'],
            'festivalTags': [],
            'enabled': true,
            'sortOrder': 1,
          },
          {
            'id': 'weather_sunny_afternoon',
            'name': '晴朗午后',
            'type': 'sunny',
            'rarity': 'common',
            'season': ['spring'],
            'timeRange': '12:00-20:00',
            'temperature': {},
            'windLevel': 1,
            'humidity': 50,
            'visibility': 'clear',
            'fishBonus': {},
            'residentMoodModifier': 'bright',
            'dialogueTags': ['sunny'],
            'storyTags': ['sunny_story'],
            'eventTags': ['sunny_event'],
            'festivalTags': [],
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final rumorRuntime = RumorRuntimeManager(
      config: RumorConfig.fromJson({
        'version': 'test',
        'rumors': [
          {
            'id': 'rumor_afternoon_coffee',
            'title': '咖啡店的摸鱼传闻',
            'content': '有人说今天下午咖啡店会出现一条会讲笑话的鱼。',
            'category': 'resident',
            'source': '咖啡店门口',
            'relatedResidentId': 'old_fisher',
            'relatedFishId': '',
            'relatedWeatherId': 'weather_sunny_afternoon',
            'relatedFestivalId': '',
            'rarity': 'rare',
            'unlockCondition': {
              'level': 1,
              'requiresFestivalId': '',
              'requiresWeatherId': 'weather_sunny_afternoon',
              'requiresResidentId': 'old_fisher',
              'requiresFishId': ''
            },
            'timeRange': 'afternoon',
            'tags': ['coffee_rumor'],
            'repeatable': true,
            'weight': 100,
            'enabled': true,
            'sortOrder': 1,
          },
        ],
      }),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      residentRuntimeManager: runtime,
    );
    final dialogueRuntime = DialogueRuntimeManager(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [
          {
            'id': 'old_fisher_rumor_dialogue',
            'residentId': 'old_fisher',
            'text': '你也听说咖啡店的传闻了吗？',
            'conditions': {
              'rumorTags': ['coffee_rumor']
            },
            'priority': 20,
            'repeatable': true,
            'tags': ['rumor_dialogue'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final storyRuntime = StoryRuntimeManager(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [
          {
            'id': 'old_fisher_sunny_story',
            'residentId': 'old_fisher',
            'title': '咖啡店的鱼影',
            'summary': '老渔夫决定去咖啡店确认传闻。',
            'dialogueIds': [],
            'conditions': {'weather': 'weather_sunny_afternoon'},
            'result': {
              'memoryTags': ['coffee_story_done']
            },
            'priority': 20,
            'repeatable': false,
            'tags': ['coffee_story'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogueRuntime,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final life = ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
    await life.load();
    final legacyDialogue = ResidentDialogueEngine(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
    );
    final legacyStory = ResidentStoryEngine(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [],
      }),
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
      dialogueEngine: legacyDialogue,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: life,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: legacyDialogue,
      residentStoryEngine: legacyStory,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final decision = ResidentDecisionManager(
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      weatherRuntimeManager: weatherRuntime,
      festivalRuntimeManager: festivalRuntime,
      rumorRuntimeManager: rumorRuntime,
      worldClockManager: clock,
      secondWorldEngine: secondWorld,
    );

    decision.runResidentDecision();
    expect(decision.decideNextLocation('old_fisher'), 'balcony');
    expect(runtime.getResidentCurrentMood('old_fisher'), 'happy');

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 2, hour: 8, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 2,
        month: 1,
        day: 2,
        season: 'spring',
      ),
    );
    decision.runResidentDecision();
    expect(decision.decideNextLocation('old_fisher'), 'coffee_shop');
    expect(decision.decideNextActivity('old_fisher'), contains('室内'));

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 2, hour: 14, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 2,
        month: 1,
        day: 2,
        season: 'spring',
      ),
    );
    decision.runResidentDecision();
    expect(decision.decideNextActivity('old_fisher'), contains('传闻'));
    expect(decision.decideNextDialogueTarget('old_fisher'), 'front_desk');
    expect(
        decision.decideNextStoryTarget('old_fisher'), 'old_fisher_sunny_story');

    rumorRuntime.removeRumor('rumor_afternoon_coffee');
    decision.runResidentDecision();
    expect(decision.decideNextActivity('old_fisher'), contains('小故事'));

    storyRuntime.finishStory('old_fisher_sunny_story');
    for (var i = 0; i < 5; i += 1) {
      memory.recordInteraction('old_fisher', 'talk');
    }
    relationship.updateRelationship('old_fisher');
    decision.runResidentDecision();
    expect(decision.decisionFor('old_fisher')?.reason, 'story_finished');
    expect(decision.decideNextActivity('old_fisher'), contains('小故事'));
    expect(decision.decideNextDialogueTarget('old_fisher'), 'sleepy_guard');

    runtime.applyResidentCareerEvent(
      'old_fisher',
      type: 'promotion',
      toPositionId: 'specialist',
      toCareerLevel: 'senior',
      performanceScore: 86,
      capabilityScore: 82,
      reason: 'ai_candidate_setup',
    );
    decision.runResidentDecision();
    final promotionDecision = decision.decisionFor('old_fisher')!;
    expect(promotionDecision.decisionId, contains('promotion_request'));
    expect(promotionDecision.type, 'promotion_request');
    expect(promotionDecision.score, greaterThanOrEqualTo(80));
    expect(promotionDecision.confidence, greaterThanOrEqualTo(70));
    expect(promotionDecision.consequence, 'organization_mutation_required');
    expect(runtime.getResidentOrganization('old_fisher').positionId,
        isNot('department_manager'));
    expect(decision.executeDecision(promotionDecision.decisionId), isTrue);
    expect(decision.executeDecision(promotionDecision.decisionId), isTrue);
    expect(decision.decisionHistory.length, 1);
    expect(
        decision.processedDecisionIds, contains(promotionDecision.decisionId));
    expect(decision.decisionCooldowns['old_fisher'], greaterThan(0));

    runtime.settleOfficeEconomy(
      periodType: 'day',
      periodKey: 'Y1-M1-D02',
      settlementId: 'ai_pressure_budget',
      operatingCost: 5900,
      projectIncome: 0,
    );
    decision.runResidentDecision();
    final pressureDecision = decision.decisionFor('sleepy_guard')!;
    expect(pressureDecision.type, 'resignation_risk');
    expect(pressureDecision.consequence, 'career_runtime_required');
    expect(runtime.getResidentCareerStatus('sleepy_guard').employmentStatus,
        isNot('resigned'));

    final restoredDecision = ResidentDecisionManager(
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      weatherRuntimeManager: weatherRuntime,
      festivalRuntimeManager: festivalRuntime,
      rumorRuntimeManager: rumorRuntime,
      worldClockManager: clock,
      secondWorldEngine: secondWorld,
    )..loadDecisionState(decision.toDecisionStateJson());
    expect(
        restoredDecision.decisionFor('sleepy_guard')!.type, 'resignation_risk');
    expect(restoredDecision.processedDecisionIds,
        contains(promotionDecision.decisionId));
  });

  test('story runtime manager triggers story chain and refreshes dialogue',
      () async {
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'old_fisher',
          'mood': 'calm',
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'office_sea_window',
          'enabled': true,
        },
      ],
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_morning',
            'residentId': 'old_fisher',
            'schedule': 'morning',
            'location': 'office_sea_window',
            'activity': '整理鱼竿',
            'activityId': 'prepare_rods',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'prepare_rods', 'name': '整理鱼竿'},
        ],
      },
    );
    final clock = WorldClockManager(
      initialClock: WorldClock.initial().copyWith(hour: 8, minute: 0),
      initialCalendar: WorldCalendar.initial(),
      paused: true,
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [
          {
            'residentId': 'old_fisher',
            'firstMeetTime': '',
            'lastMeetTime': '',
            'meetCount': 0,
            'lastInteraction': '',
            'memoryTags': [],
          },
        ],
      }),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1
          },
          {
            'id': 'known',
            'name': '认识',
            'minMeetCount': 1,
            'enabled': true,
            'sortOrder': 2
          },
          {
            'id': 'friend',
            'name': '朋友',
            'minMeetCount': 5,
            'enabled': true,
            'sortOrder': 3
          },
        ],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final dialogueRuntime = DialogueRuntimeManager(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [
          {
            'id': 'old_fisher_runtime_intro',
            'residentId': 'old_fisher',
            'text': '先坐下，听听海。',
            'conditions': {
              'relationshipLevel': 'stranger',
              'timeOfDay': 'morning',
              'residentLocation': 'office_sea_window'
            },
            'priority': 10,
            'repeatable': true,
            'tags': ['intro'],
          },
          {
            'id': 'old_fisher_after_story',
            'residentId': 'old_fisher',
            'text': '刚才那个故事，我会替你记着。',
            'conditions': {
              'relationshipLevel': 'known',
              'memoryTags': ['story:first_runtime_story'],
              'storyState': 'completed'
            },
            'priority': 20,
            'repeatable': true,
            'tags': ['after_story'],
          },
          {
            'id': 'old_fisher_chain_ready',
            'residentId': 'old_fisher',
            'text': '有些故事会慢慢接上。',
            'conditions': {
              'relationshipLevel': 'known',
              'memoryTags': ['runtime_first_done']
            },
            'priority': 15,
            'repeatable': true,
            'tags': ['chain'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
    );
    final storyRuntime = StoryRuntimeManager(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [
          {
            'id': 'first_runtime_story',
            'residentId': 'old_fisher',
            'title': '第一阵海风',
            'summary': '老渔夫第一次讲起海风。',
            'dialogueIds': ['old_fisher_runtime_intro'],
            'conditions': {
              'timeOfDay': 'morning',
              'weather': 'calmSea',
              'festival': 'new_year',
              'relationshipLevel': 'stranger',
              'residentMood': 'calm',
              'residentActivity': '整理鱼竿',
              'residentLocation': 'office_sea_window',
              'storyState': 'none'
            },
            'result': {
              'memoryTags': ['runtime_first_done']
            },
            'priority': 30,
            'repeatable': false,
            'tags': ['runtime_story'],
          },
          {
            'id': 'second_runtime_story',
            'residentId': 'old_fisher',
            'title': '接上的故事',
            'summary': '第一个故事之后，新的故事自然出现。',
            'dialogueIds': ['old_fisher_after_story', 'old_fisher_chain_ready'],
            'conditions': {
              'relationshipLevel': 'known',
              'memoryTags': ['runtime_first_done'],
              'requiredStories': ['first_runtime_story'],
              'meetCountMin': 1
            },
            'result': {
              'memoryTags': ['runtime_second_done']
            },
            'priority': 20,
            'repeatable': false,
            'tags': ['runtime_story_chain'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogueRuntime,
      worldClockManager: clock,
    );

    expect(storyRuntime.getAvailableStories('old_fisher').single.id,
        'first_runtime_story');

    final first = storyRuntime.triggerStory('old_fisher');
    expect(first, isNotNull);
    expect(first!.story.id, 'first_runtime_story');
    expect(first.memory.memoryTags, contains('story:first_runtime_story'));
    expect(first.relationship.relationshipLevel, 'known');
    expect(first.refreshedDialogue.id, 'old_fisher_after_story');
    expect(storyRuntime.hasFinishedStory('first_runtime_story'), isTrue);
    expect(
        storyRuntime.getAvailableStories('old_fisher').map((story) => story.id),
        isNot(contains('first_runtime_story')));
    expect(storyRuntime.getAvailableStories('old_fisher').single.id,
        'second_runtime_story');

    final second = storyRuntime.triggerStory('old_fisher');
    expect(second?.story.id, 'second_runtime_story');
    expect(memory.getResidentMemory('old_fisher').memoryTags,
        containsAll(['runtime_first_done', 'runtime_second_done']));
    expect(storyRuntime.triggerStory('old_fisher'), isNull);
  });

  test('second world engine returns resident context and interaction result',
      () async {
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'old_fisher',
          'mood': 'calm',
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'office_sea_window',
          'enabled': true,
        },
      ],
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_morning',
            'residentId': 'old_fisher',
            'schedule': 'morning',
            'location': 'office_sea_window',
            'activity': '整理鱼竿',
            'activityId': 'prepare_rods',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'prepare_rods', 'name': '整理鱼竿'},
        ],
      },
    );
    final life = ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
    await life.load();
    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [
          {
            'residentId': 'old_fisher',
            'firstMeetTime': '',
            'lastMeetTime': '',
            'meetCount': 0,
            'lastInteraction': '',
            'memoryTags': [],
          },
        ],
      }),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1
          },
          {
            'id': 'known',
            'name': '认识',
            'minMeetCount': 1,
            'enabled': true,
            'sortOrder': 2
          },
        ],
        'relationships': [
          {
            'residentId': 'old_fisher',
            'relationshipLevel': 'stranger',
            'relationshipScore': 0,
            'lastChangedAt': '',
            'reason': '尚未见面',
            'tags': [],
          },
        ],
      }),
      memoryEngine: memory,
    );
    final dialogue = ResidentDialogueEngine(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天风很轻。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [
          {
            'id': 'old_fisher_stranger',
            'residentId': 'old_fisher',
            'text': '第一次来吧？别急。',
            'conditions': {
              'relationshipLevel': 'stranger',
              'timeOfDay': 'morning'
            },
            'priority': 10,
            'repeatable': true,
            'tags': ['intro'],
          },
        ],
      }),
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
    );
    final story = ResidentStoryEngine(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [
          {
            'id': 'old_fisher_first_story',
            'residentId': 'old_fisher',
            'title': '第一次听海风',
            'summary': '第一次遇见老渔夫。',
            'dialogueIds': ['old_fisher_stranger'],
            'conditions': {
              'relationshipLevel': 'stranger',
              'timeOfDay': 'morning'
            },
            'result': {
              'memoryTags': ['story_first_sea_wind']
            },
            'priority': 10,
            'repeatable': false,
            'tags': ['first_story'],
          },
        ],
      }),
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
      dialogueEngine: dialogue,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: life,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: dialogue,
      residentStoryEngine: story,
    );
    const clock = WorldClockConfig(
        hour: 8, minute: 0, weekday: 1, month: 7, season: 'summer');
    final time = DateTime.parse('2026-07-05T08:00:00.000');

    final context =
        secondWorld.getResidentContext('old_fisher', clock: clock, now: time);
    expect(context.resident.name, '老渔夫');
    expect(context.life.location, 'office_sea_window');
    expect(context.dialogue.id, 'old_fisher_stranger');
    expect(context.availableStories.single.id, 'old_fisher_first_story');

    final result =
        secondWorld.interactWithResident('old_fisher', clock: clock, now: time);
    expect(result.dialogue.id, 'old_fisher_stranger');
    expect(result.story?.id, 'old_fisher_first_story');
    expect(result.memoryChanged, isTrue);
    expect(result.relationshipChanged, isTrue);
    expect(
        result.tags,
        containsAll([
          'intro',
          'first_story',
          'story_triggered',
          'story_first_sea_wind'
        ]));
    expect(memory.getResidentMemory('old_fisher').memoryTags,
        contains('story:old_fisher_first_story'));
  });

  test('achievement runtime syncs progress unlocks and save state', () async {
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 1, hour: 8, minute: 0),
      initialCalendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        month: 7,
        day: 1,
        season: 'summer',
      ),
    );
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'old_fisher',
          'mood': 'calm',
          'location': 'pier',
          'enabled': true,
        },
        {
          'id': 'front_desk',
          'name': '前台小妹',
          'type': 'npc',
          'personality': 'bright',
          'dialogGroup': 'front_desk',
          'mood': 'happy',
          'location': 'pier',
          'enabled': true,
        },
      ],
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_morning',
            'residentId': 'old_fisher',
            'location': 'pier',
            'activity': '看海',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
          {
            'id': 'front_desk_morning',
            'residentId': 'front_desk',
            'location': 'pier',
            'activity': '整理花瓶',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'happy',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'watch_sea', 'name': '看海'},
        ],
      },
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final life = ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
    await life.load();
    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [
          {
            'residentId': 'old_fisher',
            'firstMeetTime': '',
            'lastMeetTime': '',
            'meetCount': 0,
            'lastInteraction': '',
            'memoryTags': [],
          },
          {
            'residentId': 'front_desk',
            'firstMeetTime': '',
            'lastMeetTime': '',
            'meetCount': 0,
            'lastInteraction': '',
            'memoryTags': [],
          },
        ],
      }),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1,
          },
          {
            'id': 'known',
            'name': '认识',
            'minMeetCount': 1,
            'enabled': true,
            'sortOrder': 2,
          },
          {
            'id': 'friend',
            'name': '朋友',
            'minMeetCount': 5,
            'enabled': true,
            'sortOrder': 3,
          },
        ],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final baseDialogue = ResidentDialogueConfig.fromJson({
      'version': 'test',
      'fallback': {
        'id': 'fallback',
        'residentId': '*',
        'text': '今天慢一点。',
        'conditions': {},
        'priority': 0,
        'repeatable': true,
        'tags': ['fallback'],
      },
      'dialogues': [],
    });
    final dialogueEngine = ResidentDialogueEngine(
      config: baseDialogue,
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
    );
    final storyEngine = ResidentStoryEngine(
      config: ResidentStoryConfig.fromJson({'version': 'test', 'stories': []}),
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
      dialogueEngine: dialogueEngine,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: life,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: dialogueEngine,
      residentStoryEngine: storyEngine,
    );
    final festivalRuntime = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({'version': 'test', 'festivals': []}),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weatherRuntime = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({
        'version': 'test',
        'weatherEvents': [
          {
            'id': 'weather_sunny_morning',
            'name': '晴天',
            'type': 'sunny',
            'rarity': 'common',
            'season': ['summer'],
            'timeRange': '06:00-12:00',
            'temperature': {'min': 22, 'max': 28},
            'windLevel': 2,
            'humidity': 55,
            'visibility': 'good',
            'fishBonus': {},
            'residentMoodModifier': 'happy',
            'dialogueTags': ['sunny'],
            'storyTags': ['sunny_story'],
            'eventTags': ['sunny_event'],
            'enabled': true,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final rumorRuntime = RumorRuntimeManager(
      config: RumorConfig.fromJson({'version': 'test', 'rumors': []}),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      residentRuntimeManager: runtime,
    );
    final dialogueRuntime = DialogueRuntimeManager(
      config: baseDialogue,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final storyRuntime = StoryRuntimeManager(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [
          {
            'id': 'story_first_wind',
            'residentId': 'old_fisher',
            'title': '第一阵风',
            'summary': '老渔夫讲起第一阵海风。',
            'dialogueIds': [],
            'conditions': {},
            'result': {
              'memoryTags': ['first_wind'],
            },
            'priority': 10,
            'repeatable': false,
            'tags': ['story'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogueRuntime,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final saveManager = WorldSaveManager(
      repository: InMemoryWorldSaveRepository(),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      storyRuntimeManager: storyRuntime,
      dialogueRuntimeManager: dialogueRuntime,
    );
    final tick = WorldTickManager(
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
      secondWorldEngine: secondWorld,
    );
    final daily = DailySimulationManager(
      worldTickManager: tick,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
    );
    final fishRuntime = FishRuntimeManager(
      config: FishCatalogConfig.fromJson({
        'version': 'test',
        'fish': [
          {
            'id': 'fish_small',
            'name': '小鱼',
            'rarity': 'common',
            'habitat': 'pier',
            'favoriteTime': 'morning',
            'favoriteWeather': 'sunny',
            'favoriteBait': 'basic_bait',
            'value': 10,
            'weightRange': {'min': 0.4, 'max': 0.8},
            'baitRequired': 'basic_bait',
            'nextBaitTarget': 'fish_rare',
          },
          {
            'id': 'fish_rare',
            'name': '蓝鳞鱼',
            'rarity': 'rare',
            'habitat': 'pier',
            'favoriteTime': 'morning',
            'favoriteWeather': 'sunny',
            'favoriteBait': 'fish_small',
            'value': 80,
            'weightRange': {'min': 1.2, 'max': 2.4},
            'baitRequired': 'fish_small',
            'nextBaitTarget': '',
          },
        ],
      }),
      worldClockManager: clock,
      weatherRuntimeManager: weatherRuntime,
      festivalRuntimeManager: festivalRuntime,
      secondWorldEngine: secondWorld,
    );
    final taskConfig = TaskConfig.fromJson({
      'tasks': {
        'items': [
          {
            'id': 'daily_fishing',
            'title': '今天抛一次线',
            'description': '慢慢来，先抛一线。',
            'category': 'daily',
            'metric': 'fishing_count',
            'target': 1,
            'reward': {'fishCoin': 10, 'exp': 1},
            'sortOrder': 1,
          },
        ],
      },
    });
    final quest = QuestRuntimeManager(
      taskConfig: taskConfig,
      taskManager: TaskManagerView(),
      worldClockManager: clock,
      dailySimulationManager: daily,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      fishRuntimeManager: fishRuntime,
      rumorRuntimeManager: rumorRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      worldSaveManager: saveManager,
    );
    final relationshipRuntime = RelationshipRuntimeManager(
      residentRuntimeManager: runtime,
      residentDecisionManager: ResidentDecisionManager(
        residentRuntimeManager: runtime,
        dialogueRuntimeManager: dialogueRuntime,
        storyRuntimeManager: storyRuntime,
        weatherRuntimeManager: weatherRuntime,
        festivalRuntimeManager: festivalRuntime,
        rumorRuntimeManager: rumorRuntime,
        worldClockManager: clock,
        secondWorldEngine: secondWorld,
      ),
      rumorRuntimeManager: rumorRuntime,
      storyRuntimeManager: storyRuntime,
      dailySimulationManager: daily,
      worldSaveManager: saveManager,
      residentRelationshipEngine: relationship,
      secondWorldEngine: secondWorld,
    );
    final achievement = AchievementRuntimeManager(
      honorConfig: HonorConfig.fromJson({
        'badges': [
          {
            'id': 'ach_fishing_once',
            'name': '第一次抛线',
            'description': '第一次在第二世界抛线。',
            'metric': 'fishing_count',
            'target': 1,
            'status': 'not_obtained',
            'sortOrder': 1,
          },
          {
            'id': 'ach_collection_half',
            'name': '图鉴点亮',
            'description': '点亮图鉴。',
            'metric': 'collection_rate',
            'target': 50,
            'status': 'not_obtained',
            'sortOrder': 2,
          },
          {
            'id': 'ach_relationship_friend',
            'name': '居民朋友',
            'description': '居民之间成为朋友。',
            'metric': 'relationship_stage',
            'target': 2,
            'status': 'not_obtained',
            'sortOrder': 3,
          },
          {
            'id': 'ach_story_once',
            'name': '故事开始',
            'description': '完成一个故事。',
            'metric': 'story_completed',
            'target': 1,
            'status': 'not_obtained',
            'sortOrder': 4,
          },
        ],
      }),
      identityConfig: {
        'identities': [
          {
            'id': 'identity_friend_of_world',
            'name': '世界的朋友',
            'description': '和第二世界的居民建立朋友关系。',
            'unlockCondition': {
              'metric': 'relationship_stage',
              'value': 2,
            },
            'enabled': true,
            'sortOrder': 1,
            'tags': ['identity'],
          }
        ],
      },
      fishCollectionConfig: FishCollectionConfig.fromJson({
        'collection': {
          'fishes': [
            {'id': 'fish_small', 'name': '小鱼'},
            {'id': 'fish_rare', 'name': '蓝鳞鱼'},
          ],
        },
      }),
      taskConfig: taskConfig,
      questRuntimeManager: quest,
      fishRuntimeManager: fishRuntime,
      relationshipRuntimeManager: relationshipRuntime,
      storyRuntimeManager: storyRuntime,
      rumorRuntimeManager: rumorRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      residentRuntimeManager: runtime,
      worldClockManager: clock,
      worldSaveManager: saveManager,
      secondWorldEngine: secondWorld,
    );

    achievement.updateAchievementProgress(
      const AchievementEvent(type: 'fishing_count'),
    );
    expect(achievement.getAchievementProgress('ach_fishing_once')?.status,
        'unlocked');
    achievement.updateAchievementProgress(
      const AchievementEvent(
        type: 'collection_sync',
        amount: 0,
        payload: {'collection_count': 1},
      ),
    );
    expect(achievement.getAchievementProgress('ach_collection_half')?.status,
        'unlocked');
    relationshipRuntime.applyRelationshipChange(
      'old_fisher',
      'front_desk',
      '一起听见海风',
      25,
    );
    achievement.updateAchievementProgress(
      const AchievementEvent(type: 'relationship_changed', amount: 0),
    );
    expect(
      achievement.getAchievementProgress('ach_relationship_friend')?.status,
      'unlocked',
    );
    expect(
      achievement.getAchievementProgress('identity_friend_of_world')?.status,
      'unlocked',
    );
    storyRuntime.finishStory('story_first_wind');
    achievement.updateAchievementProgress(
      const AchievementEvent(type: 'story_finished', amount: 0),
    );
    expect(achievement.getAchievementProgress('ach_story_once')?.status,
        'unlocked');
    final unlockedCount = saveManager.interactionHistory
        .where((record) => record.tags.contains('achievement_unlocked'))
        .length;
    achievement.updateAchievementProgress(
      const AchievementEvent(type: 'story_finished', amount: 0),
    );
    expect(
      saveManager.interactionHistory
          .where((record) => record.tags.contains('achievement_unlocked'))
          .length,
      unlockedCount,
    );
    achievement.equipTitle('identity_friend_of_world');
    expect(achievement.getEquippedTitle()?.id, 'identity_friend_of_world');
    final saved = await saveManager.saveWorld();
    expect(saved.achievementRuntimeState['equippedTitleId'],
        'identity_friend_of_world');
    expect(saveManager.achievementRuntimeState['unlockedAt'], isNotEmpty);
  });

  test('dynamic event runtime filters resolves and restores state', () async {
    final clock = WorldClockManager(
      initialClock:
          WorldClock.initial().copyWith(dayCount: 1, hour: 8, minute: 0),
      initialCalendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        month: 7,
        day: 1,
        season: 'summer',
      ),
    );
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'old_fisher',
          'mood': 'calm',
          'location': 'pier',
          'enabled': true,
        },
        {
          'id': 'front_desk',
          'name': '前台小妹',
          'type': 'npc',
          'personality': 'bright',
          'dialogGroup': 'front_desk',
          'mood': 'happy',
          'location': 'pier',
          'enabled': true,
        },
      ],
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_morning',
            'residentId': 'old_fisher',
            'location': 'pier',
            'activity': '看海',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
          {
            'id': 'front_desk_morning',
            'residentId': 'front_desk',
            'location': 'pier',
            'activity': '整理花瓶',
            'startTime': '06:00',
            'endTime': '12:00',
            'mood': 'happy',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [
          {'id': 'watch_sea', 'name': '看海'},
        ],
      },
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final life = ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
    await life.load();
    final memory = ResidentMemoryEngine(
      config: ResidentMemoryConfig.fromJson({
        'version': 'test',
        'memories': [
          {
            'residentId': 'old_fisher',
            'firstMeetTime': '',
            'lastMeetTime': '',
            'meetCount': 0,
            'lastInteraction': '',
            'memoryTags': [],
          },
          {
            'residentId': 'front_desk',
            'firstMeetTime': '',
            'lastMeetTime': '',
            'meetCount': 0,
            'lastInteraction': '',
            'memoryTags': [],
          },
        ],
      }),
    );
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [
          {
            'id': 'stranger',
            'name': '陌生',
            'minMeetCount': 0,
            'enabled': true,
            'sortOrder': 1,
          },
          {
            'id': 'known',
            'name': '认识',
            'minMeetCount': 1,
            'enabled': true,
            'sortOrder': 2,
          },
          {
            'id': 'friend',
            'name': '朋友',
            'minMeetCount': 5,
            'enabled': true,
            'sortOrder': 3,
          },
        ],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final dialogueConfig = ResidentDialogueConfig.fromJson({
      'version': 'test',
      'fallback': {
        'id': 'fallback',
        'residentId': '*',
        'text': '今天海风很好。',
        'conditions': {},
        'priority': 0,
        'repeatable': true,
        'tags': ['fallback'],
      },
      'dialogues': [],
    });
    final dialogueEngine = ResidentDialogueEngine(
      config: dialogueConfig,
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
    );
    final storyRuntimeConfig = ResidentStoryConfig.fromJson({
      'version': 'test',
      'stories': [
        {
          'id': 'story_event_followup',
          'residentId': 'old_fisher',
          'title': '事件之后',
          'summary': '老渔夫记住了这次事件。',
          'dialogueIds': [],
          'conditions': {},
          'result': {
            'memoryTags': ['event_followup'],
          },
          'priority': 10,
          'repeatable': false,
          'tags': ['story'],
        },
      ],
    });
    final storyEngine = ResidentStoryEngine(
      config: storyRuntimeConfig,
      lifeManager: life,
      memoryEngine: memory,
      relationshipEngine: relationship,
      dialogueEngine: dialogueEngine,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: life,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: dialogueEngine,
      residentStoryEngine: storyEngine,
    );
    final festivalRuntime = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({'version': 'test', 'festivals': []}),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weatherRuntime = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({
        'version': 'test',
        'weatherEvents': [
          {
            'id': 'weather_sunny_morning',
            'name': '晴天',
            'type': 'sunny',
            'rarity': 'common',
            'season': ['summer'],
            'timeRange': '06:00-12:00',
            'temperature': {},
            'windLevel': 2,
            'humidity': 55,
            'visibility': 'good',
            'fishBonus': {},
            'residentMoodModifier': 'happy',
            'dialogueTags': ['sunny'],
            'storyTags': ['sunny_story'],
            'eventTags': ['sunny_event'],
            'enabled': true,
          },
          {
            'id': 'weather_rain_night',
            'name': '小雨',
            'type': 'rain',
            'rarity': 'common',
            'season': ['summer'],
            'timeRange': '20:00-23:00',
            'temperature': {},
            'windLevel': 2,
            'humidity': 80,
            'visibility': 'normal',
            'fishBonus': {},
            'residentMoodModifier': 'quiet',
            'dialogueTags': ['rain'],
            'storyTags': ['rain_story'],
            'eventTags': ['rain_event'],
            'enabled': true,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final rumorRuntime = RumorRuntimeManager(
      config: RumorConfig.fromJson({
        'version': 'test',
        'rumors': [
          {
            'id': 'rumor_event',
            'title': '码头传闻',
            'content': '有人说老渔夫今天捡到一片鱼鳞。',
            'category': 'resident',
            'source': 'pier',
            'rarity': 'common',
            'unlockCondition': {},
            'timeRange': '',
            'tags': ['rumor_event'],
            'repeatable': true,
            'weight': 1,
            'enabled': true,
          },
        ],
      }),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      residentRuntimeManager: runtime,
    );
    final dialogueRuntime = DialogueRuntimeManager(
      config: dialogueConfig,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final storyRuntime = StoryRuntimeManager(
      config: storyRuntimeConfig,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogueRuntime,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final saveManager = WorldSaveManager(
      repository: InMemoryWorldSaveRepository(),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      storyRuntimeManager: storyRuntime,
      dialogueRuntimeManager: dialogueRuntime,
    );
    final tick = WorldTickManager(
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
      secondWorldEngine: secondWorld,
    );
    final daily = DailySimulationManager(
      worldTickManager: tick,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
    );
    final fishRuntime = FishRuntimeManager(
      config: FishCatalogConfig.fromJson({
        'version': 'test',
        'fish': [
          {
            'id': 'fish_small',
            'name': '小鱼',
            'rarity': 'common',
            'habitat': 'pier',
            'favoriteTime': 'morning',
            'favoriteWeather': 'sunny',
            'favoriteBait': 'basic_bait',
            'value': 10,
            'weightRange': {'min': 0.4, 'max': 0.8},
            'baitRequired': 'basic_bait',
            'nextBaitTarget': '',
          },
        ],
      }),
      worldClockManager: clock,
      weatherRuntimeManager: weatherRuntime,
      festivalRuntimeManager: festivalRuntime,
      secondWorldEngine: secondWorld,
    );
    final taskConfig = TaskConfig.fromJson({
      'tasks': {
        'items': [
          {
            'id': 'dynamic_event_task',
            'title': '遇见一件小事',
            'description': '等待第二世界发生一点变化。',
            'category': 'daily',
            'metric': 'dynamic_event',
            'target': 1,
            'reward': {'fishCoin': 5, 'exp': 1},
            'sortOrder': 1,
          },
        ],
      },
    });
    final quest = QuestRuntimeManager(
      taskConfig: taskConfig,
      taskManager: TaskManagerView(),
      worldClockManager: clock,
      dailySimulationManager: daily,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      fishRuntimeManager: fishRuntime,
      rumorRuntimeManager: rumorRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      worldSaveManager: saveManager,
    );
    final relationshipRuntime = RelationshipRuntimeManager(
      residentRuntimeManager: runtime,
      residentDecisionManager: ResidentDecisionManager(
        residentRuntimeManager: runtime,
        dialogueRuntimeManager: dialogueRuntime,
        storyRuntimeManager: storyRuntime,
        weatherRuntimeManager: weatherRuntime,
        festivalRuntimeManager: festivalRuntime,
        rumorRuntimeManager: rumorRuntime,
        worldClockManager: clock,
        secondWorldEngine: secondWorld,
      ),
      rumorRuntimeManager: rumorRuntime,
      storyRuntimeManager: storyRuntime,
      dailySimulationManager: daily,
      worldSaveManager: saveManager,
      residentRelationshipEngine: relationship,
      secondWorldEngine: secondWorld,
    );
    final achievement = AchievementRuntimeManager(
      honorConfig: HonorConfig.fromJson({
        'badges': [
          {
            'id': 'ach_dynamic_event',
            'name': '遇见小事件',
            'description': '第一次遇见动态事件。',
            'metric': 'dynamic_event_seen',
            'target': 1,
            'status': 'not_obtained',
            'sortOrder': 1,
          },
          {
            'id': 'ach_hidden_event',
            'name': '隐藏小事',
            'description': '遇见隐藏事件。',
            'metric': 'hidden_event_seen',
            'target': 1,
            'status': 'not_obtained',
            'sortOrder': 2,
          },
        ],
      }),
      identityConfig: const {'identities': []},
      fishCollectionConfig: FishCollectionConfig.fromJson({
        'collection': {
          'fishes': [
            {'id': 'fish_small', 'name': '小鱼'},
          ],
        },
      }),
      taskConfig: taskConfig,
      questRuntimeManager: quest,
      fishRuntimeManager: fishRuntime,
      relationshipRuntimeManager: relationshipRuntime,
      storyRuntimeManager: storyRuntime,
      rumorRuntimeManager: rumorRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      residentRuntimeManager: runtime,
      worldClockManager: clock,
      worldSaveManager: saveManager,
      secondWorldEngine: secondWorld,
    );
    final dynamic = DynamicEventRuntimeManager(
      config: DynamicEventConfig.fromJson({
        'version': 'test',
        'events': [
          {
            'id': 'event_sunny',
            'type': 'weather_event',
            'category': 'weather',
            'title': '晴天海风',
            'conditions': {'weather': 'sunny'},
            'priority': 10,
            'weight': 1,
            'probability': 1,
            'repeatable': true,
            'tags': ['sunny_event'],
          },
          {
            'id': 'event_location_dock',
            'type': 'dock_encounter',
            'category': 'office',
            'title': '码头旁的小插曲',
            'conditions': {
              'location': ['dock', 'sea']
            },
            'priority': 9,
            'weight': 1,
            'probability': 1,
            'repeatable': true,
            'tags': ['office_event'],
          },
          {
            'id': 'event_rain',
            'type': 'weather_event',
            'category': 'weather',
            'title': '雨夜窗声',
            'conditions': {'weather': 'rain'},
            'priority': 10,
            'weight': 1,
            'probability': 1,
            'repeatable': true,
            'tags': ['rain_event'],
          },
          {
            'id': 'event_friend',
            'type': 'resident_meet',
            'category': 'resident',
            'title': '朋友之间',
            'conditions': {'relationshipLevel': 'friend'},
            'priority': 8,
            'weight': 1,
            'probability': 1,
            'repeatable': true,
          },
          {
            'id': 'event_fish_wait',
            'type': 'fish_talk',
            'category': 'waiting',
            'title': '鱼突然说话',
            'conditions': {'fishId': 'fish_small'},
            'priority': 7,
            'weight': 1,
            'probability': 1,
            'repeatable': true,
          },
          {
            'id': 'event_mother_fish',
            'type': 'mother_fish',
            'category': 'waiting',
            'title': '母鱼轻声请求',
            'priority': 9,
            'weight': 1,
            'probability': 1,
            'repeatable': true,
            'tags': ['fairy', 'fish_help'],
          },
          {
            'id': 'event_bottle',
            'type': 'bottle',
            'category': 'waiting',
            'title': '漂流瓶靠近窗边',
            'priority': 9,
            'weight': 1,
            'probability': 1,
            'repeatable': true,
            'tags': ['mystery', 'ocean'],
          },
          {
            'id': 'event_once',
            'type': 'office',
            'category': 'office',
            'title': '只发生一次',
            'priority': 6,
            'weight': 1,
            'probability': 1,
            'repeatable': false,
          },
          {
            'id': 'event_cooldown',
            'type': 'office',
            'category': 'office',
            'title': '需要冷却',
            'priority': 5,
            'weight': 1,
            'probability': 1,
            'cooldown': 2,
            'repeatable': true,
          },
          {
            'id': 'event_result',
            'type': 'hidden_event',
            'category': 'story',
            'title': '有结果的小事',
            'conditions': {
              'residentId': ['old_fisher', 'front_desk']
            },
            'priority': 20,
            'weight': 1,
            'probability': 1,
            'repeatable': true,
            'result': {
              'memoryTags': ['dynamic_memory'],
              'relationshipChanges': [
                {
                  'source': 'old_fisher',
                  'target': 'front_desk',
                  'amount': 25,
                  'reason': '共同经历动态事件'
                }
              ],
              'rumorIds': ['rumor_event'],
              'storyIds': ['story_event_followup'],
              'questEvents': [
                {'type': 'dynamic_event', 'amount': 1}
              ],
              'achievementEvents': [
                {'type': 'hidden_event_seen', 'amount': 1}
              ],
              'tags': ['resolved_event'],
            },
          },
        ],
      }),
      worldClockManager: clock,
      dailySimulationManager: daily,
      residentRuntimeManager: runtime,
      residentDecisionManager: ResidentDecisionManager(
        residentRuntimeManager: runtime,
        dialogueRuntimeManager: dialogueRuntime,
        storyRuntimeManager: storyRuntime,
        weatherRuntimeManager: weatherRuntime,
        festivalRuntimeManager: festivalRuntime,
        rumorRuntimeManager: rumorRuntime,
        worldClockManager: clock,
        secondWorldEngine: secondWorld,
      ),
      relationshipRuntimeManager: relationshipRuntime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      fishRuntimeManager: fishRuntime,
      questRuntimeManager: quest,
      achievementRuntimeManager: achievement,
      worldSaveManager: saveManager,
      secondWorldEngine: secondWorld,
      residentMemoryEngine: memory,
    );

    expect(dynamic.getAvailableEvents().map((event) => event.id),
        contains('event_sunny'));
    expect(dynamic.getAvailableEvents().map((event) => event.id),
        contains('event_location_dock'));
    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 1, hour: 21, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        month: 7,
        day: 1,
        season: 'summer',
      ),
    );
    expect(dynamic.getAvailableEvents().map((event) => event.id),
        contains('event_rain'));
    for (var i = 0; i < 5; i += 1) {
      memory.recordInteraction('old_fisher', 'talk');
    }
    relationshipRuntime.getPlayerRelationshipWithResident('old_fisher');
    expect(dynamic.getAvailableEvents().map((event) => event.id),
        contains('event_friend'));
    expect(dynamic.getAvailableEvents().map((event) => event.id),
        contains('event_fish_wait'));

    final fairy = FairyEventService(dynamic);
    final lightFairy = secondWorld.selectFairyEvent(
      fairy,
      waitingDuration: const Duration(minutes: 3),
    );
    expect(lightFairy, isNotNull);
    expect(lightFairy!.rhythmTier, 'light');
    final lightRecord = secondWorld.triggerFairyEvent(
      fairy,
      waitingDuration: const Duration(minutes: 3),
    );
    expect(lightRecord, isNotNull);
    expect(fairy.resolveFairyEvent(lightRecord!.eventId), isNotNull);

    final surpriseFairy = secondWorld.selectFairyEvent(
      fairy,
      waitingDuration: const Duration(minutes: 7),
    );
    expect(surpriseFairy, isNotNull);
    expect(surpriseFairy!.rhythmTier, 'surprise');
    final surpriseRecord = secondWorld.triggerFairyEvent(
      fairy,
      waitingDuration: const Duration(minutes: 7),
    );
    expect(surpriseRecord, isNotNull);
    expect(surpriseRecord!.eventId, isNot(lightRecord.eventId));
    expect(fairy.resolveFairyEvent(surpriseRecord.eventId), isNotNull);

    final longWaitFairy = secondWorld.selectFairyEvent(
      fairy,
      waitingDuration: const Duration(minutes: 21),
    );
    expect(longWaitFairy, isNotNull);
    expect(longWaitFairy!.rhythmTier, 'fairy');
    expect(
      <FairyEventCategory>{
        FairyEventCategory.fishCry,
        FairyEventCategory.oceanMystery,
      },
      contains(longWaitFairy.category),
    );
    final longWaitRecord = secondWorld.triggerFairyEvent(
      fairy,
      waitingDuration: const Duration(minutes: 21),
    );
    expect(longWaitRecord, isNotNull);
    expect(fairy.resolveFairyEvent(longWaitRecord!.eventId), isNotNull);
    final fairyStats = fairy.stats();
    expect(fairyStats.triggerCount, 3);
    expect(fairyStats.repeatRate, lessThan(1));
    expect(fairyStats.categoryDistribution.length, greaterThan(1));

    expect(dynamic.triggerEvent('event_once'), isNotNull);
    expect(dynamic.resolveEvent('event_once', ''), isNotNull);
    expect(dynamic.getAvailableEvents().map((event) => event.id),
        isNot(contains('event_once')));

    expect(dynamic.triggerEvent('event_cooldown'), isNotNull);
    expect(dynamic.resolveEvent('event_cooldown', ''), isNotNull);
    expect(dynamic.getAvailableEvents().map((event) => event.id),
        isNot(contains('event_cooldown')));
    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 4, hour: 21, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 4,
        month: 7,
        day: 4,
        season: 'summer',
      ),
    );
    expect(dynamic.getAvailableEvents().map((event) => event.id),
        contains('event_cooldown'));

    expect(dynamic.triggerEvent('event_result'), isNotNull);
    final resolved = dynamic.resolveEvent('event_result', '');
    expect(resolved?.memoryChanged, isTrue);
    expect(resolved?.relationshipChanged, isTrue);
    expect(resolved?.questChanged, isTrue);
    expect(resolved?.achievementChanged, isTrue);
    expect(memory.getResidentMemory('old_fisher').memoryTags,
        contains('dynamic_memory'));
    expect(
      relationshipRuntime
          .getRelationshipBetweenResidents('old_fisher', 'front_desk')
          .level,
      'friend',
    );
    expect(rumorRuntime.isRumorActive('rumor_event'), isTrue);
    expect(storyRuntime.hasFinishedStory('story_event_followup'), isTrue);
    expect(quest.cumulativeMetrics['dynamic_event'], greaterThan(0));
    expect(achievement.getAchievementProgress('ach_hidden_event')?.status,
        'unlocked');
    final saved = await saveManager.saveWorld();
    expect(saved.dynamicEventRuntimeState['finishedEvents'], isNotEmpty);

    final integrationDecision = ResidentDecisionManager(
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      weatherRuntimeManager: weatherRuntime,
      festivalRuntimeManager: festivalRuntime,
      rumorRuntimeManager: rumorRuntime,
      worldClockManager: clock,
      secondWorldEngine: secondWorld,
    );
    final integrationEconomy = EconomyRuntimeManager(
      fishRuntimeManager: fishRuntime,
      residentRuntimeManager: runtime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      worldClockManager: clock,
      worldSaveManager: saveManager,
      questRuntimeManager: quest,
      secondWorldEngine: secondWorld,
    );
    final integrationTick = WorldTickManager(
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      worldSaveManager: saveManager,
      fishRuntimeManager: fishRuntime,
      economyRuntimeManager: integrationEconomy,
      questRuntimeManager: quest,
      relationshipRuntimeManager: relationshipRuntime,
      achievementRuntimeManager: achievement,
      dynamicEventRuntimeManager: dynamic,
      residentDecisionManager: integrationDecision,
      secondWorldEngine: secondWorld,
    );
    final integratedContext = await integrationTick.tickDay();
    final integratedResult = integrationTick.lastResult!;
    expect(integratedContext.tickType, TickType.dayTick);
    expect(integratedResult.success, isTrue);
    expect(
      integratedResult.executedStages,
      orderedEquals([
        'Clock',
        'Festival',
        'Weather',
        'ResidentDecision',
        'Resident',
        'Rumor',
        'Fish',
        'Economy',
        'Relationship',
        'DynamicEvent',
        'Dialogue',
        'Story',
        'Quest',
        'Achievement',
        'Save',
      ]),
    );
    expect(integratedResult.worldContext.weatherTags, isNotEmpty);
    expect(integratedResult.worldContext.residentStates.length, 2);
    expect(integratedResult.worldContext.rumorTags, isNotEmpty);
    expect(integratedResult.worldContext.fishPool, isNotEmpty);
    expect(
        integratedResult.worldContext.quests['dynamic_event'], greaterThan(0));
    expect(integratedResult.worldContext.achievements, isNotEmpty);
    expect(integratedResult.runtimeResults.length,
        integratedResult.executedStages.length);
    expect(integrationTick.profiler.lastProfile?.durationMs, isNonNegative);
    expect(saveManager.lastSave?.worldClock.dayCount, clock.clock.dayCount);

    final restored = DynamicEventRuntimeManager(
      config: DynamicEventConfig.fromJson({
        'version': 'test',
        'events': [
          {
            'id': 'event_once',
            'type': 'office',
            'category': 'office',
            'title': '只发生一次',
            'priority': 6,
            'weight': 1,
            'probability': 1,
            'repeatable': false,
          },
        ],
      }),
      worldClockManager: clock,
      dailySimulationManager: daily,
      residentRuntimeManager: runtime,
      residentDecisionManager: ResidentDecisionManager(
        residentRuntimeManager: runtime,
        dialogueRuntimeManager: dialogueRuntime,
        storyRuntimeManager: storyRuntime,
        weatherRuntimeManager: weatherRuntime,
        festivalRuntimeManager: festivalRuntime,
        rumorRuntimeManager: rumorRuntime,
        worldClockManager: clock,
        secondWorldEngine: secondWorld,
      ),
      relationshipRuntimeManager: relationshipRuntime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      fishRuntimeManager: fishRuntime,
      questRuntimeManager: quest,
      achievementRuntimeManager: achievement,
      worldSaveManager: saveManager,
      secondWorldEngine: secondWorld,
      residentMemoryEngine: memory,
    );
    expect(restored.hasTriggered('event_once'), isTrue);
  });

  test('resident emotion integration affects runtime dialogue story and save',
      () async {
    final clock = WorldClockManager();
    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 2, hour: 9, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 2,
        month: 1,
        day: 2,
        season: 'summer',
      ),
    );
    final residentConfig = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'enabled': true,
          'location': 'dock',
          'home': 'old_house',
          'workplace': 'dock',
          'dailyRoute': ['dock', 'cafe', 'old_house'],
          'mood': 'peaceful',
        },
      ],
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_day',
            'residentId': 'old_fisher',
            'location': 'dock',
            'activity': '看着海面等风来。',
            'startTime': '06:00',
            'endTime': '22:00',
            'mood': 'peaceful',
            'weekday': [1, 2, 3, 4, 5, 6, 7],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [],
      },
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residentConfig),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final lifeManager = ResidentLifeManager(
      _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await lifeManager.load();
    final memory = ResidentMemoryEngine(
      config: const ResidentMemoryConfig(version: 'test', memories: []),
    );
    final relationshipConfig = ResidentRelationshipConfig.fromJson({
      'version': 'test',
      'levels': [
        {'id': 'stranger', 'minMeetCount': 0, 'enabled': true},
        {'id': 'known', 'minMeetCount': 1, 'enabled': true},
        {'id': 'friend', 'minMeetCount': 5, 'enabled': true},
      ],
      'relationships': [],
    });
    final relationship = ResidentRelationshipEngine(
      config: relationshipConfig,
      memoryEngine: memory,
    );
    final festivalRuntime = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({
        'version': 'test',
        'festivals': [
          {
            'id': 'festival_lantern',
            'name': '海灯节',
            'dateValue': '1-1',
            'durationDays': 1,
            'mood': 'bright',
            'worldEffects': {'residentMood': 'excited'},
            'enabled': true,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weatherRuntime = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({
        'version': 'test',
        'weatherEvents': [
          {
            'id': 'weather_sunny',
            'name': '晴天',
            'type': 'sunny',
            'season': ['summer'],
            'timeRange': '08:00-12:00',
            'residentMoodModifier': '',
            'sortOrder': 0,
            'enabled': true,
          },
          {
            'id': 'weather_storm',
            'name': '暴雨',
            'type': 'storm',
            'season': ['summer'],
            'timeRange': '20:00-22:00',
            'residentMoodModifier': 'worried',
            'sortOrder': 1,
            'enabled': true,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final rumorRuntime = RumorRuntimeManager(
      config: RumorConfig.fromJson({
        'version': 'test',
        'rumors': [
          {
            'id': 'rumor_blue_float',
            'title': '蓝色鱼漂',
            'content': '今天有人看见蓝色鱼漂自己动了一下。',
            'category': 'mystery',
            'source': 'dock',
            'relatedResidentId': 'old_fisher',
            'rarity': 'common',
            'timeRange': '23:00-23:30',
            'tags': ['rumor', 'ocean'],
            'enabled': true,
          },
        ],
      }),
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      residentRuntimeManager: runtime,
    );
    final dialogueRuntime = DialogueRuntimeManager(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {'id': 'fallback', 'residentId': '*', 'text': '慢慢来。'},
        'dialogues': [
          {
            'id': 'dialogue_calm',
            'residentId': 'old_fisher',
            'text': '今天风平浪静。',
            'conditions': {'residentMood': 'calm'},
            'priority': 5,
            'repeatable': true,
            'tags': ['calm'],
          },
          {
            'id': 'dialogue_worried',
            'residentId': 'old_fisher',
            'text': '雨有点大，先别急着出门。',
            'conditions': {'residentMood': 'worried'},
            'priority': 5,
            'repeatable': true,
            'tags': ['worried'],
          },
          {
            'id': 'dialogue_excited',
            'residentId': 'old_fisher',
            'text': '海灯节来了，海面像在发光。',
            'conditions': {'residentMood': 'excited'},
            'priority': 5,
            'repeatable': true,
            'tags': ['excited'],
          },
          {
            'id': 'dialogue_grateful',
            'residentId': 'old_fisher',
            'text': '谢谢你，今天这件事我会记住。',
            'conditions': {'residentMood': 'grateful'},
            'priority': 5,
            'repeatable': true,
            'tags': ['grateful'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final storyRuntime = StoryRuntimeManager(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [
          {
            'id': 'story_help_float',
            'residentId': 'old_fisher',
            'title': '帮忙修鱼漂',
            'summary': '你帮老渔夫把鱼漂线理顺了。',
            'conditions': {
              'residentMood': 'calm',
              'memoryTags': ['story_ready'],
            },
            'result': {
              'mood': 'grateful',
              'memoryTags': ['help', 'story_helped'],
            },
            'priority': 10,
            'repeatable': true,
            'tags': ['help'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogueRuntime,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
    );
    final fallbackDialogueEngine = ResidentDialogueEngine(
      config: ResidentDialogueConfig.fromJson({
        'fallback': {'id': 'fallback', 'residentId': '*', 'text': '慢慢来。'},
        'dialogues': [],
      }),
      lifeManager: lifeManager,
      memoryEngine: memory,
      relationshipEngine: relationship,
      worldClockManager: clock,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residentConfig,
      residentLifeEngine: lifeManager,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: fallbackDialogueEngine,
      residentStoryEngine: ResidentStoryEngine(
        config: ResidentStoryConfig.fromJson({'stories': []}),
        lifeManager: lifeManager,
        memoryEngine: memory,
        relationshipEngine: relationship,
        dialogueEngine: fallbackDialogueEngine,
        worldClockManager: clock,
      ),
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
    );
    final saveRepository = _CountingWorldSaveRepository();
    final saveManager = WorldSaveManager(
      repository: saveRepository,
      worldClockManager: clock,
      festivalRuntimeManager: festivalRuntime,
      weatherRuntimeManager: weatherRuntime,
      rumorRuntimeManager: rumorRuntime,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      storyRuntimeManager: storyRuntime,
      dialogueRuntimeManager: dialogueRuntime,
    );
    final decision = ResidentDecisionManager(
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogueRuntime,
      storyRuntimeManager: storyRuntime,
      weatherRuntimeManager: weatherRuntime,
      festivalRuntimeManager: festivalRuntime,
      rumorRuntimeManager: rumorRuntime,
      worldClockManager: clock,
      secondWorldEngine: secondWorld,
      residentMemoryEngine: memory,
    );

    decision.runResidentDecision();
    expect(runtime.getResidentCurrentMood('old_fisher'), 'calm');
    expect(dialogueRuntime.getDialogue('old_fisher').id, 'dialogue_calm');

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 2, hour: 21, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 2,
        month: 1,
        day: 2,
        season: 'summer',
      ),
    );
    decision.runResidentDecision();
    expect(runtime.getResidentCurrentMood('old_fisher'), 'worried');
    expect(dialogueRuntime.getDialogue('old_fisher').id, 'dialogue_worried');

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 1, hour: 9, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        month: 1,
        day: 1,
        season: 'summer',
      ),
    );
    decision.runResidentDecision();
    expect(runtime.getResidentCurrentMood('old_fisher'), 'excited');
    expect(dialogueRuntime.getDialogue('old_fisher').id, 'dialogue_excited');

    runtime.clearRuntimeOverrides();
    memory.load(
      ResidentMemoryConfig(
        version: 'test',
        memories: [
          ResidentMemoryRecord(
            residentId: 'old_fisher',
            firstMeetTime: WorldClockManager.systemNow()
                .subtract(const Duration(days: 8))
                .toIso8601String(),
            lastMeetTime: WorldClockManager.systemNow()
                .subtract(const Duration(days: 8))
                .toIso8601String(),
            meetCount: 1,
            lastInteraction: 'meet',
            memoryTags: const ['first_meet'],
          ),
        ],
      ),
    );
    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 3, hour: 14, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 3,
        month: 1,
        day: 3,
        season: 'summer',
      ),
    );
    decision.runResidentDecision();
    expect(runtime.getResidentCurrentMood('old_fisher'), 'lonely');

    runtime.applyEmotionOverride(
      ResidentRuntimeOverride(
        residentId: 'old_fisher',
        location: 'dock',
        activity: '重新平静地看海。',
        mood: 'calm',
        dayCount: clock.today().dayCount,
        source: 'test',
        reason: 'reset_for_story',
      ),
      reason: 'reset_for_story',
      major: true,
    );
    final story = storyRuntime.finishStory('story_help_float');
    expect(story, isNotNull);
    expect(runtime.getResidentCurrentMood('old_fisher'), 'grateful');
    expect(dialogueRuntime.getDialogue('old_fisher').id, 'dialogue_grateful');
    expect(
      memory.getResidentMemory('old_fisher').emotionHistory.last['newMood'],
      'grateful',
    );
    expect(
      relationship.updateRelationship('old_fisher').reason,
      contains('帮助'),
    );

    final jitter = runtime.applyEmotionOverride(
      ResidentRuntimeOverride(
        residentId: 'old_fisher',
        location: 'dock',
        activity: '短暂皱了皱眉。',
        mood: 'angry',
        dayCount: clock.today().dayCount,
        source: 'test',
        reason: 'minor_noise',
      ),
      reason: 'minor_noise',
    );
    expect(jitter.mood, 'grateful');

    final result = secondWorld.interactWithResident('old_fisher');
    expect(result.currentMood, 'grateful');
    expect(result.moodChangeReason, isNotNull);

    await saveManager.saveWorld(force: true, immediate: true);
    runtime.clearRuntimeOverrides();
    expect(runtime.getResidentCurrentMood('old_fisher'), 'calm');
    await saveManager.loadWorld();
    expect(runtime.getResidentCurrentMood('old_fisher'), 'grateful');
  });

  test('ambient presentation state follows runtime and settings context', () {
    final fishing = FishingProvider();
    fishing.throwLine();
    final runtime = AppRuntime.fromProviders(
      wallet: WalletManagerView(),
      fishing: fishing,
      fishChain: FishChainProvider(),
      inventory: InventoryManagerView(),
      transactions: TransactionManagerView(),
      waiting: WaitingEventManagerView(WaitingEngine()),
      today: TodayManagerView(TodayEngine(timeManager: TimeManager())),
      weather: WeatherManagerView(WeatherSystem()),
    );
    const ui = UiRuntimeSnapshot(
      clockLabel: 'Day 1 19:20',
      timeOfDay: 'dusk',
      weatherLabel: '小雨',
      weatherType: 'lightRain',
      windLevel: 4,
      festivalLabel: '渔民节',
      festivalTags: ['fisher_festival'],
      dailySummary: '今天的海边比昨天更热闹一点。',
      activeEventCount: 1,
      availableEventCount: 3,
      residentContextLabel: '老渔夫 / 海边 / 看海 / calm / known',
      residentActivity: '老渔夫在窗边慢慢整理鱼线。',
      residentDialogue: '慢一点，大鱼不着急。',
    );

    final low = AmbientEnvironmentState.fromRuntime(
      runtime: runtime,
      uiRuntime: ui,
      quality: 'low',
      musicEnabled: false,
      soundEnabled: false,
    );
    expect(low.isFishingWaiting, isTrue);
    expect(low.lowQuality, isTrue);
    expect(low.showBirds, isFalse);
    expect(low.hasFestival, isTrue);
    expect(low.waitingHints.toSet().length, low.waitingHints.length);
    expect(low.fishingAudioCue, isNotEmpty);

    final high = AmbientEnvironmentState.fromRuntime(
      runtime: runtime,
      uiRuntime: ui,
      quality: 'high',
      musicEnabled: true,
      soundEnabled: true,
    );
    expect(high.lowQuality, isFalse);
    expect(high.audioCue, 'ambient_festival_soft');
    expect(high.weatherOverlay, isNot(Colors.transparent));
  });

  test('career state gates promotion and prevents duplicate rewards', () {
    final state = CareerState.initial();
    expect(state.careerLevel, 'intern');
    expect(state.jobTitle, '实习生');
    expect(state.performanceScore, 50);
    expect(state.skill('fishing').level, 1);
    expect(state.skill('communication').experience, 0);

    final blocked = state.checkPromotion();
    expect(blocked.eligible, isFalse);
    expect(blocked.missingRequirements, contains('minimum_work_days:3'));

    final ready = state
        .copyWith(
          consecutiveWorkDays: 3,
          completedCareerTasks: 3,
          performanceScore: 55,
          experience: 20,
        )
        .normalized();
    final allowed = ready.checkPromotion();
    expect(allowed.eligible, isTrue);
    expect(allowed.targetLevel, 'junior_employee');

    final promoted = ready.promote('2026-08-02T00:00:00.000');
    expect(promoted.careerLevel, 'junior_employee');
    expect(promoted.salary, greaterThan(ready.salary));

    final skillGain = state.withSkillExperience(
      record: const SkillExperienceRecord(
        sourceType: 'test',
        sourceId: 'overflow',
        timestamp: '2026-08-02T00:00:00.000',
        skillId: 'fishing',
        amount: 1000,
        reason: 'test_overflow',
      ),
    );
    expect(skillGain.state.skill('fishing').level, greaterThan(2));
    expect(skillGain.levelUps, isNotEmpty);

    final maxLuck = PlayerSkillState.initial('luck').copyWith(
      level: 10,
      experience: 100000,
    );
    final maxSkillGain = state
        .copyWith(skillSummary: <String, PlayerSkillState>{'luck': maxLuck})
        .normalized()
        .withSkillExperience(
          record: const SkillExperienceRecord(
            sourceType: 'test',
            sourceId: 'max_luck',
            timestamp: '2026-08-02T00:00:00.000',
            skillId: 'luck',
            amount: 10000,
            reason: 'test_max',
          ),
        );
    expect(maxSkillGain.state.skill('luck').level, 10);
    expect(maxSkillGain.levelUps, isEmpty);

    final skillBlocked = state
        .copyWith(
          careerLevel: 'senior_employee',
          jobTitle: CareerState.titleForLevel('senior_employee'),
          consecutiveWorkDays: 28,
          completedCareerTasks: 26,
          performanceScore: 70,
          experience: 260,
        )
        .normalized()
        .checkPromotion(maxRelationshipRank: 2);
    expect(skillBlocked.missingRequirements, contains('skill_communication:3'));
    expect(skillBlocked.missingRequirements, contains('skill_efficiency:3'));

    final bounded = promoted.withCareerProgress(
      experienceDelta: 10,
      performanceDelta: 99,
      reason: 'major_story',
    );
    expect(bounded.performanceScore - promoted.performanceScore, 8);
    expect(
      CareerState.fromJson(const <String, dynamic>{}).careerLevel,
      'intern',
    );
  });

  test('friendship state is gradual bounded and save-compatible', () {
    final initial = FriendshipState.initial('old_fisher');
    expect(initial.stage, 'stranger');
    expect(initial.score, 5);
    expect(initial.trust, 0);
    expect(initial.familiarity, 0);

    final ordinary = initial.applyChange(
      const FriendshipChangeRecord(
        sourceType: 'resident_interaction',
        sourceId: 'talk_1',
        residentId: 'old_fisher',
        scoreDelta: 3,
        trustDelta: 0,
        familiarityDelta: 3,
        reason: '日常互动让彼此更熟悉。',
        timestamp: '2026-08-02T00:00:00.000',
        tags: ['communication', 'topic:fishing'],
      ),
    );
    expect(ordinary.score, 8);
    expect(ordinary.stage, 'stranger');
    expect(ordinary.sharedTopics, contains('fishing'));

    final major = ordinary.applyChange(
      const FriendshipChangeRecord(
        sourceType: 'resident_story',
        sourceId: 'story_help',
        residentId: 'old_fisher',
        scoreDelta: 10,
        trustDelta: 8,
        familiarityDelta: 8,
        reason: '重要故事推进。',
        timestamp: '2026-08-02T00:10:00.000',
        tags: ['story', 'help', 'memory:first_help'],
      ),
    );
    expect(friendshipStageRank(major.stage), lessThanOrEqualTo(1));
    expect(major.trust, 8);
    expect(major.sharedMemories, contains('memory:first_help'));

    final highFamiliarity = FriendshipState.initial('guard')
        .copyWith(
          score: 90,
          trust: 5,
          familiarity: 90,
        )
        .normalized();
    expect(highFamiliarity.stage, isNot('trusted_friend'));

    final conflict = ordinary.applyChange(
      const FriendshipChangeRecord(
        sourceType: 'resident_conflict',
        sourceId: 'conflict_1',
        residentId: 'old_fisher',
        scoreDelta: -4,
        trustDelta: -1,
        familiarityDelta: 0,
        reason: '轻微误会。',
        timestamp: '2026-08-02T00:20:00.000',
        tags: ['conflict'],
      ),
    );
    expect(conflict.conflictState, 'conflict');
    final recovering = conflict.applyChange(
      const FriendshipChangeRecord(
        sourceType: 'resolve_conflict',
        sourceId: 'resolve_1',
        residentId: 'old_fisher',
        scoreDelta: 2,
        trustDelta: 1,
        familiarityDelta: 1,
        reason: '慢慢化解误会。',
        timestamp: '2026-08-02T00:30:00.000',
        tags: ['resolve_conflict'],
      ),
    );
    expect(recovering.conflictState, 'recovering');

    final save = WorldSaveData.empty().copyWith(
      friendshipStates: <String, FriendshipState>{'old_fisher': recovering},
      processedSocialSourceIds: const <String>[
        'resolve_conflict::resolve_1::old_fisher',
      ],
      socialInteractionHistory: const <FriendshipChangeRecord>[
        FriendshipChangeRecord(
          sourceType: 'resolve_conflict',
          sourceId: 'resolve_1',
          residentId: 'old_fisher',
          scoreDelta: 2,
          trustDelta: 1,
          familiarityDelta: 1,
          reason: '慢慢化解误会。',
          timestamp: '2026-08-02T00:30:00.000',
          tags: ['resolve_conflict'],
        ),
      ],
    );
    final restored = WorldSaveData.fromJson(save.toJson());
    expect(
        restored.friendshipStates['old_fisher']?.conflictState, 'recovering');
    expect(restored.processedSocialSourceIds, hasLength(1));
    expect(WorldSaveData.fromJson(const <String, dynamic>{}).friendshipStates,
        isEmpty);
  });

  test(
      'career runtime integrates daily save salary quest achievement and engine',
      () async {
    final clock = WorldClockManager();
    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 7, hour: 9, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 7,
        weekdayIndex: 2,
        month: 1,
        day: 7,
        season: 'summer',
      ),
    );
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': [
        {
          'id': 'old_fisher',
          'name': '老渔夫',
          'type': 'npc',
          'personality': 'warm',
          'dialogGroup': 'old_fisher',
          'mood': 'calm',
          'friendship': 0,
          'unlockLevel': 1,
          'location': 'office',
          'enabled': true,
        },
      ],
    });
    final life = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          {
            'id': 'old_fisher_work',
            'residentId': 'old_fisher',
            'schedule': 'working',
            'location': 'office',
            'activity': '整理今天的办公室鱼线。',
            'startTime': '08:00',
            'endTime': '18:00',
            'mood': 'calm',
            'weekday': [1, 2, 3, 4, 5],
          },
        ],
      },
      activityJson: {
        'version': 'test',
        'activities': [],
      },
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(life),
      worldClockManager: clock,
    );
    await runtime.load();
    final memory = ResidentMemoryEngine();
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final festival = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({'version': 'test', 'festivals': []}),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weather = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({'version': 'test', 'weatherEvents': []}),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final rumor = RumorRuntimeManager(
      config: RumorConfig.fromJson({'version': 'test', 'rumors': []}),
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      residentRuntimeManager: runtime,
    );
    final dialogue = DialogueRuntimeManager(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '办公室今天也慢慢来。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
    );
    final story = StoryRuntimeManager(
      config: ResidentStoryConfig.fromJson({'version': 'test', 'stories': []}),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogue,
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
    );
    final lifeManager = ResidentLifeManager(_FakeResidentLifeRepository(life));
    await lifeManager.load();
    final legacyDialogue = ResidentDialogueEngine(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '办公室今天也慢慢来。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      lifeManager: lifeManager,
      memoryEngine: memory,
      relationshipEngine: relationship,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: lifeManager,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: legacyDialogue,
      residentStoryEngine: ResidentStoryEngine(
        config:
            ResidentStoryConfig.fromJson({'version': 'test', 'stories': []}),
        lifeManager: lifeManager,
        memoryEngine: memory,
        relationshipEngine: relationship,
        dialogueEngine: legacyDialogue,
      ),
      dialogueRuntimeManager: dialogue,
      storyRuntimeManager: story,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
      residentRuntimeManager: runtime,
    );
    final repository = _CountingWorldSaveRepository();
    final save = WorldSaveManager(
      repository: repository,
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      storyRuntimeManager: story,
      dialogueRuntimeManager: dialogue,
    );
    final engine = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: lifeManager,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: legacyDialogue,
      residentStoryEngine: ResidentStoryEngine(
        config:
            ResidentStoryConfig.fromJson({'version': 'test', 'stories': []}),
        lifeManager: lifeManager,
        memoryEngine: memory,
        relationshipEngine: relationship,
        dialogueEngine: legacyDialogue,
      ),
      dialogueRuntimeManager: dialogue,
      storyRuntimeManager: story,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
      worldSaveManager: save,
      residentRuntimeManager: runtime,
    );
    final tick = WorldTickManager(
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogue,
      storyRuntimeManager: story,
      worldSaveManager: save,
      secondWorldEngine: engine,
    );
    final daily = DailySimulationManager(
      worldTickManager: tick,
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
      residentRuntimeManager: runtime,
      storyRuntimeManager: story,
      worldSaveManager: save,
    );
    final fish = FishRuntimeManager(
      config: FishCatalogConfig.fromJson({'version': 'test', 'fish': []}),
      worldClockManager: clock,
      weatherRuntimeManager: weather,
      festivalRuntimeManager: festival,
      secondWorldEngine: secondWorld,
    );
    final quest = QuestRuntimeManager(
      taskConfig: TaskConfig.fromJson({
        'tasks': {
          'items': [
            {
              'id': 'career_report',
              'title': '写一份轻松的工作小结',
              'description': '今天办公室也有一点进展。',
              'category': 'career',
              'metric': 'career_task_completed',
              'target': 1,
              'reward': {'fishCoin': 1, 'exp': 5},
              'sortOrder': 1,
            },
            {
              'id': 'fish_daily',
              'title': '普通钓鱼任务',
              'description': '保持摸鱼节奏。',
              'category': 'daily',
              'metric': 'fishing_count',
              'target': 1,
              'reward': {'fishCoin': 1, 'exp': 1},
              'sortOrder': 2,
            },
          ],
        },
      }),
      taskManager: TaskManagerView(),
      worldClockManager: clock,
      dailySimulationManager: daily,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogue,
      storyRuntimeManager: story,
      fishRuntimeManager: fish,
      rumorRuntimeManager: rumor,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      worldSaveManager: save,
    );
    final economy = EconomyRuntimeManager(
      fishRuntimeManager: fish,
      questRuntimeManager: quest,
      residentRuntimeManager: runtime,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      worldClockManager: clock,
      worldSaveManager: save,
      secondWorldEngine: engine,
    );
    daily.setEconomyRuntimeManager(economy);
    final achievement = AchievementRuntimeManager(
      honorConfig: HonorConfig.fromJson({'version': 'test', 'badges': []}),
      identityConfig: const <String, dynamic>{'identities': []},
      fishCollectionConfig:
          FishCollectionConfig.fromJson({'version': 'test', 'fishes': []}),
      taskConfig: TaskConfig.fromJson({
        'tasks': {'items': []}
      }),
      questRuntimeManager: quest,
      fishRuntimeManager: fish,
      relationshipRuntimeManager: RelationshipRuntimeManager(
        residentRuntimeManager: runtime,
        residentDecisionManager: ResidentDecisionManager(
          residentRuntimeManager: runtime,
          dialogueRuntimeManager: dialogue,
          storyRuntimeManager: story,
          weatherRuntimeManager: weather,
          festivalRuntimeManager: festival,
          rumorRuntimeManager: rumor,
          worldClockManager: clock,
          secondWorldEngine: engine,
          residentMemoryEngine: memory,
        ),
        rumorRuntimeManager: rumor,
        storyRuntimeManager: story,
        dailySimulationManager: daily,
        worldSaveManager: save,
        residentRelationshipEngine: relationship,
        secondWorldEngine: engine,
      ),
      storyRuntimeManager: story,
      rumorRuntimeManager: rumor,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      residentRuntimeManager: runtime,
      worldClockManager: clock,
      worldSaveManager: save,
      secondWorldEngine: engine,
    );

    expect(save.careerState.careerLevel, 'intern');
    quest.recordCareerTaskCompleted('career_report');
    quest.recordCareerTaskCompleted('career_report');
    expect(save.careerState.completedCareerTasks, 1);
    expect(save.careerRewardHistory.length, 1);
    expect(save.getSkillState('efficiency').experience, greaterThan(0));
    final skillExperienceAfterTask =
        save.getSkillState('efficiency').experience;
    quest.recordCareerTaskCompleted('career_report');
    expect(
        save.getSkillState('efficiency').experience, skillExperienceAfterTask);
    quest.recordWorldEvent('fishing_count', id: 'fish_1');
    expect(save.careerState.completedCareerTasks, 1);
    expect(save.getSkillState('fishing').experience, greaterThan(0));

    final wallet = WalletManagerView(initialFishCoin: 0);
    final transactions = TransactionManagerView();
    final summary = await daily.runDailySimulation(
      wallet: wallet,
      transactions: transactions,
    );
    expect(summary.currentJobTitle, '实习生');
    expect(summary.careerFeedback, isNotNull);
    expect(summary.skillExperienceGained, contains('efficiency'));
    expect(summary.recommendedActions, isNotEmpty);
    expect(save.careerState.experience, greaterThan(0));
    expect(save.careerState.performanceScore, inInclusiveRange(0, 100));
    expect(wallet.fishCoin, greaterThan(0));
    expect(
      transactions.records.where((record) => record.type == 'salary').length,
      1,
    );
    await daily.runDailySimulation(wallet: wallet, transactions: transactions);
    expect(
      transactions.records.where((record) => record.type == 'salary').length,
      1,
    );
    expect(save.careerFeedbackHistory.length, 1);
    expect(save.latestCareerFeedback?.salaryPaid, wallet.fishCoin);

    final interaction = engine.interactWithResident('old_fisher');
    expect(interaction.skillSummary['communication']?.level, 1);
    expect(interaction.skillGains, contains('communication'));
    expect(save.getSkillState('communication').experience, greaterThan(0));
    expect(interaction.friendshipState, isNotNull);
    expect(interaction.friendshipStage, isNotEmpty);
    expect(save.getFriendshipState('old_fisher').score, greaterThan(5));
    expect(save.getFriendshipState('old_fisher').familiarity, greaterThan(0));
    final friendshipHistoryLength = save.socialInteractionHistory.length;
    final socialRecord = save.recordFriendshipChange(
      residentId: 'old_fisher',
      sourceType: 'manual_social',
      sourceId: 'same_source',
      scoreDelta: 3,
      trustDelta: 1,
      familiarityDelta: 2,
      reason: '测试一次可解释社交互动。',
      tags: const ['communication', 'topic:coffee'],
    );
    final duplicateSocialRecord = save.recordFriendshipChange(
      residentId: 'old_fisher',
      sourceType: 'manual_social',
      sourceId: 'same_source',
      scoreDelta: 3,
      trustDelta: 1,
      familiarityDelta: 2,
      reason: '测试一次可解释社交互动。',
      tags: const ['communication', 'topic:coffee'],
    );
    expect(socialRecord, isNotNull);
    expect(duplicateSocialRecord, isNull);
    expect(save.socialInteractionHistory.length, friendshipHistoryLength + 1);
    save.setSocialCooldown(
      residentId: 'old_fisher',
      interactionType: 'invite_coffee',
      durationDays: 1,
    );
    expect(save.isSocialCooldownActive('old_fisher', 'invite_coffee'), isTrue);

    save.recordCareerProgress(
      sourceId: 'manual_ready',
      type: 'career_task',
      experience: 100,
      performanceDelta: 8,
      completedTaskDelta: 5,
    );
    save.settleCareerDay(
      dayCount: 8,
      dateLabel: 'Y1-M1-D8-#8',
      experience: 0,
      performanceDelta: 0,
    );
    save.settleCareerDay(
      dayCount: 9,
      dateLabel: 'Y1-M1-D9-#9',
      experience: 0,
      performanceDelta: 0,
    );
    final check = engine.getPromotionRequirements();
    expect(check.missingRequirements, isNot(contains('relationship_rank:')));
    final result = engine.promoteCareer(
      wallet: wallet,
      transactions: transactions,
    );
    expect(result.success, isTrue);
    expect(save.careerState.careerLevel, 'junior_employee');
    final duplicate = engine.promoteCareer(
      wallet: wallet,
      transactions: transactions,
    );
    expect(duplicate.success, isFalse);
    achievement.updateAchievementProgress(
      const AchievementEvent(type: 'career_task_count', amount: 0),
    );
    expect(
      achievement
          .getAllAchievements()
          .where((item) => item.metric.startsWith('career'))
          .length,
      0,
    );

    final saved = await save.saveWorld(force: true, immediate: true);
    expect(saved.careerState.careerLevel, 'junior_employee');
    expect(saved.salaryTransactionIds.length, 1);
    expect(
        saved.playerSkillStates['communication']?.experience, greaterThan(0));
    expect(saved.latestCareerFeedback?.salaryPaid, greaterThan(0));
    expect(saved.processedSkillSourceIds.length,
        save.processedSkillSourceIds.length);
    expect(saved.friendshipStates['old_fisher']?.score, greaterThan(5));
    expect(saved.processedSocialSourceIds.length,
        save.processedSocialSourceIds.length);
    await save.resetWorld();
    expect(save.careerState.careerLevel, 'intern');
    repository.data = saved;
    await save.loadWorld();
    expect(save.careerState.careerLevel, 'junior_employee');
    expect(save.salaryTransactionIds.length, 1);
    expect(save.getSkillState('communication').experience, greaterThan(0));
    expect(save.latestCareerFeedback?.salaryPaid, greaterThan(0));
    expect(save.getFriendshipState('old_fisher').score,
        saved.friendshipStates['old_fisher']?.score);
    expect(save.isSocialCooldownActive('old_fisher', 'invite_coffee'), isTrue);
  });

  test('office group behaviour batches residents dialogue story and save',
      () async {
    final clock = WorldClockManager();
    clock.setClock(
      const WorldClock(
        dayCount: 12,
        hour: 12,
        minute: 10,
        period: WorldDayPeriod.noon,
        timeLabel: 'Noon',
      ),
      calendar: const WorldCalendar(
        dayCount: 12,
        weekdayIndex: 3,
        year: 1,
        month: 1,
        day: 12,
        isWeekend: false,
        season: 'summer',
      ),
    );
    final residents = ResidentConfig.fromJson({
      'version': 'test',
      'residents': List.generate(100, (index) {
        final location = index < 18
            ? 'pantry'
            : index < 34
                ? 'meeting_room'
                : index < 50
                    ? 'dock'
                    : 'home';
        final personality = index.isEven ? 'outgoing,kind' : 'serious';
        return {
          'id': 'person_$index',
          'name': '居民$index',
          'type': 'npc',
          'personality': personality,
          'dialogGroup': 'office_group',
          'mood': index % 5 == 0 ? 'happy' : 'calm',
          'friendship': 0,
          'unlockLevel': 1,
          'location': location,
          'enabled': true,
        };
      }),
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          for (var index = 0; index < 100; index += 1)
            {
              'id': 'group_schedule_$index',
              'residentId': 'person_$index',
              'schedule': index < 50 ? 'lunch' : 'home',
              'location': index < 18
                  ? 'pantry'
                  : index < 34
                      ? 'meeting_room'
                      : index < 50
                          ? 'dock'
                          : 'home',
              'activity': index < 18
                  ? 'coffee_break'
                  : index < 34
                      ? 'project_review'
                      : index < 50
                          ? 'weekend_fishing'
                          : 'home',
              'startTime': '11:30',
              'endTime': '13:00',
              'mood': index % 5 == 0 ? 'happy' : 'calm',
              'weekday': [1, 2, 3, 4, 5],
            },
        ],
      },
      activityJson: {'version': 'test', 'activities': []},
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residents),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    for (var index = 80; index < 86; index += 1) {
      runtime.applyRuntimeOverride(
        ResidentRuntimeOverride(
          residentId: 'person_$index',
          location: 'meeting_room',
          activity: 'project_review',
          mood: 'busy',
          dayCount: 12,
          source: 'test',
          reason: 'meeting',
          schedulePhase: 'working',
          isWorking: true,
          nextLocation: 'office',
          nextActivity: 'working',
          nextChangeTime: '13:00',
        ),
      );
    }
    final memory = ResidentMemoryEngine();
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final festival = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({'version': 'test', 'festivals': []}),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weather = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({'version': 'test', 'weatherEvents': []}),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final rumor = RumorRuntimeManager(
      config: RumorConfig.fromJson({'version': 'test', 'rumors': []}),
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      residentRuntimeManager: runtime,
    );
    final dialogue = DialogueRuntimeManager(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天办公室慢慢来。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [
          {
            'id': 'group_coffee_dialogue',
            'residentId': '*',
            'text': '茶水间人多的时候，咖啡也像在开小会。',
            'conditions': {
              'groupSizeMin': 2,
              'groupTopic': 'coffee',
            },
            'priority': 9,
            'repeatable': true,
            'tags': ['office_group', 'topic:coffee'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
    );
    final story = StoryRuntimeManager(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [
          {
            'id': 'coffee_group_story',
            'residentId': '*',
            'title': '茶水间的小圆桌',
            'summary': '几位居民围着咖啡聊起今天的海风。',
            'dialogueIds': [],
            'conditions': {
              'groupSizeMin': 2,
              'groupActivity': 'coffee_break',
            },
            'result': {
              'memoryTags': ['office_group_story'],
            },
            'priority': 8,
            'repeatable': false,
            'tags': ['office_group', 'coffee'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogue,
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
    );
    final lifeManager = ResidentLifeManager(
      _FakeResidentLifeRepository(lifeConfig),
    );
    await lifeManager.load();
    final legacyDialogue = ResidentDialogueEngine(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天办公室慢慢来。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [],
      }),
      lifeManager: lifeManager,
      memoryEngine: memory,
      relationshipEngine: relationship,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residents,
      residentLifeEngine: lifeManager,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: legacyDialogue,
      residentStoryEngine: ResidentStoryEngine(
        config:
            ResidentStoryConfig.fromJson({'version': 'test', 'stories': []}),
        lifeManager: lifeManager,
        memoryEngine: memory,
        relationshipEngine: relationship,
        dialogueEngine: legacyDialogue,
      ),
      dialogueRuntimeManager: dialogue,
      storyRuntimeManager: story,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
      residentRuntimeManager: runtime,
    );
    final repository = _CountingWorldSaveRepository();
    final save = WorldSaveManager(
      repository: repository,
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      storyRuntimeManager: story,
      dialogueRuntimeManager: dialogue,
    );
    final tick = WorldTickManager(
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogue,
      storyRuntimeManager: story,
      worldSaveManager: save,
      secondWorldEngine: secondWorld,
    );
    final daily = DailySimulationManager(
      worldTickManager: tick,
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
      residentRuntimeManager: runtime,
      storyRuntimeManager: story,
      worldSaveManager: save,
    );
    final decision = ResidentDecisionManager(
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogue,
      storyRuntimeManager: story,
      weatherRuntimeManager: weather,
      festivalRuntimeManager: festival,
      rumorRuntimeManager: rumor,
      worldClockManager: clock,
      secondWorldEngine: secondWorld,
      residentMemoryEngine: memory,
    );
    final relationshipRuntime = RelationshipRuntimeManager(
      residentRuntimeManager: runtime,
      residentDecisionManager: decision,
      rumorRuntimeManager: rumor,
      storyRuntimeManager: story,
      dailySimulationManager: daily,
      worldSaveManager: save,
      residentRelationshipEngine: relationship,
      secondWorldEngine: secondWorld,
    );

    final groups = relationshipRuntime.generateOfficeGroups(reason: 'test');
    expect(groups, isNotEmpty);
    expect(groups.every((group) => group.size >= 2 && group.size <= 6), isTrue);
    expect(groups.any((group) => group.activity == 'coffee_break'), isTrue);
    expect(
      groups.any((group) =>
          group.activity == 'meeting' || group.activity == 'project_review'),
      isTrue,
    );
    expect(save.activeGroups.length, groups.length);
    expect(save.activeGroups.length, lessThan(100));
    expect(dialogue.getDialogue('person_0').id, 'group_coffee_dialogue');
    expect(
        story.getAvailableStories('person_0').first.id, 'coffee_group_story');

    final group = groups.firstWhere(
      (item) => item.activity == 'coffee_break',
      orElse: () => groups.first,
    );
    final changed = relationshipRuntime.applyOfficeGroupInteraction(
      group.groupId,
    );
    expect(changed, isTrue);
    for (final member in group.members) {
      expect(save.getFriendshipState(member).score, greaterThan(0));
    }
    expect(save.getSkillState('communication').experience, greaterThan(0));
    expect(save.dailySocialSummary['todaysGroups'], isNotEmpty);
    expect(save.groupForResident(group.members.first)?.groupId, group.groupId);

    final saved = await save.saveWorld(force: true, immediate: true);
    expect(saved.activeGroups, isNotEmpty);
    await save.resetWorld();
    repository.data = saved;
    await save.loadWorld();
    expect(save.activeGroups.length, saved.activeGroups.length);
    expect(save.groupForResident(group.members.first)?.groupId, group.groupId);
  });

  test('living office world integrates shared context summary and save',
      () async {
    final clock = WorldClockManager();
    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 2, hour: 9, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 2,
        weekdayIndex: 2,
        month: 1,
        day: 2,
        season: 'summer',
      ),
    );
    final residentConfig = ResidentConfig.fromJson({
      'version': 'test',
      'residents': List.generate(100, (index) {
        final location = index < 20
            ? 'office'
            : index < 34
                ? 'meeting_room'
                : index < 46
                    ? 'pantry'
                    : index < 58
                        ? 'balcony'
                        : 'home';
        return {
          'id': 'office_person_$index',
          'name': '办公室居民$index',
          'type': 'npc',
          'personality': index.isEven ? 'outgoing,kind' : 'serious,cautious',
          'dialogGroup': 'office',
          'mood': index % 7 == 0 ? 'busy' : 'calm',
          'friendship': 0,
          'unlockLevel': 1,
          'location': location,
          'enabled': true,
        };
      }),
    });
    final lifeConfig = ResidentLifeConfig.fromJson(
      scheduleJson: {
        'version': 'test',
        'schedules': [
          for (var index = 0; index < 100; index += 1)
            {
              'id': 'living_office_schedule_$index',
              'residentId': 'office_person_$index',
              'schedule': index < 58 ? 'working' : 'home',
              'location': index < 20
                  ? 'office'
                  : index < 34
                      ? 'meeting_room'
                      : index < 46
                          ? 'pantry'
                          : index < 58
                              ? 'balcony'
                              : 'home',
              'activity': index < 34
                  ? 'project_review'
                  : index < 46
                      ? 'coffee_break'
                      : index < 58
                          ? 'observe_weather'
                          : 'home',
              'startTime': '08:30',
              'endTime': '18:00',
              'mood': index % 7 == 0 ? 'busy' : 'calm',
              'weekday': [1, 2, 3, 4, 5],
            },
          for (var index = 0; index < 100; index += 1)
            {
              'id': 'living_office_lunch_$index',
              'residentId': 'office_person_$index',
              'schedule': 'lunch',
              'location': index.isEven ? 'pantry' : 'coffee_shop',
              'activity': 'coffee_break',
              'startTime': '12:00',
              'endTime': '13:00',
              'mood': 'happy',
              'weekday': [1, 2, 3, 4, 5],
            },
          for (var index = 0; index < 100; index += 1)
            {
              'id': 'living_office_night_$index',
              'residentId': 'office_person_$index',
              'schedule': 'sleep',
              'location': 'home',
              'activity': 'sleep',
              'startTime': '22:00',
              'endTime': '06:00',
              'mood': 'tired',
              'weekday': [1, 2, 3, 4, 5, 6, 7],
            },
        ],
      },
      activityJson: {'version': 'test', 'activities': []},
    );
    final runtime = ResidentRuntimeManager(
      residentRepository: _FakeResidentRepository(residentConfig),
      lifeRepository: _FakeResidentLifeRepository(lifeConfig),
      worldClockManager: clock,
    );
    await runtime.load();
    final memory = ResidentMemoryEngine();
    final relationship = ResidentRelationshipEngine(
      config: ResidentRelationshipConfig.fromJson({
        'version': 'test',
        'levels': [],
        'relationships': [],
      }),
      memoryEngine: memory,
    );
    final festival = FestivalRuntimeManager(
      config: FestivalConfig.fromJson({
        'version': 'test',
        'festivals': [
          {
            'id': 'festival_lantern',
            'name': '海灯节',
            'dateValue': '1-1',
            'durationDays': 1,
            'mood': 'bright',
            'worldEffects': {'residentMood': 'excited'},
            'enabled': true,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final weather = WeatherRuntimeManager(
      config: WeatherConfig.fromJson({
        'version': 'test',
        'weatherEvents': [
          {
            'id': 'weather_sunny',
            'name': '晴天',
            'type': 'sunny',
            'season': ['summer'],
            'timeRange': '08:00-18:00',
            'residentMoodModifier': '',
            'tags': ['sunny'],
            'sortOrder': 0,
            'enabled': true,
          },
          {
            'id': 'weather_storm',
            'name': '暴雨',
            'type': 'storm',
            'season': ['summer'],
            'timeRange': '20:00-22:00',
            'residentMoodModifier': 'worried',
            'tags': ['storm', 'rain'],
            'sortOrder': 1,
            'enabled': true,
          },
        ],
      }),
      worldClockManager: clock,
      residentRuntimeManager: runtime,
    );
    final rumor = RumorRuntimeManager(
      config: RumorConfig.fromJson({
        'version': 'test',
        'rumors': [
          {
            'id': 'rumor_printer',
            'title': '打印机今天很安静',
            'content': '有人说打印机终于愿意慢慢工作了。',
            'category': 'office',
            'source': 'office',
            'rarity': 'common',
            'timeRange': '08:00-18:00',
            'tags': ['office', 'soft_rumor'],
            'enabled': true,
          },
        ],
      }),
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      residentRuntimeManager: runtime,
    );
    final dialogue = DialogueRuntimeManager(
      config: ResidentDialogueConfig.fromJson({
        'version': 'test',
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '今天办公室也慢慢运转。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
          'tags': ['fallback'],
        },
        'dialogues': [
          {
            'id': 'office_active_dialogue',
            'residentId': '*',
            'text': '今天办公室像一只慢慢醒来的钟。',
            'conditions': {
              'minimumActivityLevel': 35,
              'requiredOfficeTags': ['office_group'],
            },
            'priority': 9,
            'repeatable': true,
            'tags': ['office_life'],
          },
          {
            'id': 'player_helpful_dialogue',
            'residentId': '*',
            'text': '大家都记得你昨天帮过忙。',
            'conditions': {
              'requiredPlayerReputation': ['helpful'],
              'requiredRecentActions': ['helping'],
              'minimumOfficeTrust': 10,
            },
            'priority': 12,
            'repeatable': true,
            'tags': ['helpful'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
    );
    final story = StoryRuntimeManager(
      config: ResidentStoryConfig.fromJson({
        'version': 'test',
        'stories': [
          {
            'id': 'office_active_story',
            'residentId': '*',
            'title': '办公室一起醒来',
            'summary': '大家在各自的位置上，让今天变得有一点不同。',
            'dialogueIds': [],
            'conditions': {
              'minimumActivityLevel': 35,
              'maximumTensionLevel': 80,
              'requiredOfficeTags': ['office_group'],
              'activeGroupCount': 1,
            },
            'result': {
              'memoryTags': ['living_office_seen'],
            },
            'priority': 8,
            'repeatable': false,
            'tags': ['living_office'],
          },
          {
            'id': 'player_helpful_story',
            'residentId': '*',
            'title': '大家把椅子留给你',
            'summary': '有人记得玩家昨天帮过忙，于是午休时多留了一个位置。',
            'dialogueIds': [],
            'conditions': {
              'requiredPlayerReputation': ['helpful'],
              'requiredRecentActions': ['helping'],
              'minimumOfficeInfluence': 10,
            },
            'result': {
              'memoryTags': ['player_helpful_seen'],
            },
            'priority': 12,
            'repeatable': false,
            'tags': ['helpful'],
          },
        ],
      }),
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      dialogueRuntimeManager: dialogue,
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
    );
    final lifeManager =
        ResidentLifeManager(_FakeResidentLifeRepository(lifeConfig));
    await lifeManager.load();
    final legacyDialogue = ResidentDialogueEngine(
      config: ResidentDialogueConfig.fromJson({
        'fallback': {
          'id': 'fallback',
          'residentId': '*',
          'text': '慢慢来。',
          'conditions': {},
          'priority': 0,
          'repeatable': true,
        },
        'dialogues': [],
      }),
      lifeManager: lifeManager,
      memoryEngine: memory,
      relationshipEngine: relationship,
    );
    final save = WorldSaveManager(
      repository: _CountingWorldSaveRepository(),
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
      residentRuntimeManager: runtime,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      storyRuntimeManager: story,
      dialogueRuntimeManager: dialogue,
    );
    final secondWorld = SecondWorldEngine(
      residentConfig: residentConfig,
      residentLifeEngine: lifeManager,
      residentMemoryEngine: memory,
      residentRelationshipEngine: relationship,
      residentDialogueEngine: legacyDialogue,
      residentStoryEngine: ResidentStoryEngine(
        config: ResidentStoryConfig.fromJson({'stories': []}),
        lifeManager: lifeManager,
        memoryEngine: memory,
        relationshipEngine: relationship,
        dialogueEngine: legacyDialogue,
      ),
      dialogueRuntimeManager: dialogue,
      storyRuntimeManager: story,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
      worldSaveManager: save,
      residentRuntimeManager: runtime,
    );
    final inventoryConfig = InventoryConfig.fromJson({
      'inventory': {
        'catalog': [
          {
            'id': 'fish_small',
            'name': '小银鱼',
            'category': 'fish',
            'rarity': 'common',
            'icon': 'fish',
            'description': '一条适合当作轻松话题的小鱼。',
            'initialQuantity': 2,
            'attributes': {
              'nickname': '银色小话题',
              'weightRange': '0.2-0.5 kg',
            },
          },
        ],
      },
    });
    final inventory = InventoryManagerView()
      ..ensureCatalogLoaded(inventoryConfig);
    final baseTick = WorldTickManager(
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogue,
      storyRuntimeManager: story,
      worldSaveManager: save,
      secondWorldEngine: secondWorld,
    );
    final daily = DailySimulationManager(
      worldTickManager: baseTick,
      worldClockManager: clock,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
      residentRuntimeManager: runtime,
      storyRuntimeManager: story,
      worldSaveManager: save,
    );
    final decision = ResidentDecisionManager(
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogue,
      storyRuntimeManager: story,
      weatherRuntimeManager: weather,
      festivalRuntimeManager: festival,
      rumorRuntimeManager: rumor,
      worldClockManager: clock,
      secondWorldEngine: secondWorld,
      residentMemoryEngine: memory,
    );
    final relationshipRuntime = RelationshipRuntimeManager(
      residentRuntimeManager: runtime,
      residentDecisionManager: decision,
      rumorRuntimeManager: rumor,
      storyRuntimeManager: story,
      dailySimulationManager: daily,
      worldSaveManager: save,
      residentRelationshipEngine: relationship,
      secondWorldEngine: secondWorld,
    );
    final fish = FishRuntimeManager(
      config: FishCatalogConfig.fromJson({'version': 'test', 'fish': []}),
      worldClockManager: clock,
      weatherRuntimeManager: weather,
      festivalRuntimeManager: festival,
      secondWorldEngine: secondWorld,
    );
    final quest = QuestRuntimeManager(
      taskConfig: TaskConfig.fromJson({
        'tasks': {'items': []}
      }),
      taskManager: TaskManagerView(),
      worldClockManager: clock,
      dailySimulationManager: daily,
      residentRuntimeManager: runtime,
      dialogueRuntimeManager: dialogue,
      storyRuntimeManager: story,
      fishRuntimeManager: fish,
      rumorRuntimeManager: rumor,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      worldSaveManager: save,
    );
    final achievement = AchievementRuntimeManager(
      honorConfig: HonorConfig.fromJson({'version': 'test', 'badges': []}),
      identityConfig: const <String, dynamic>{'identities': []},
      fishCollectionConfig:
          FishCollectionConfig.fromJson({'version': 'test', 'fishes': []}),
      taskConfig: TaskConfig.fromJson({
        'tasks': {'items': []}
      }),
      questRuntimeManager: quest,
      fishRuntimeManager: fish,
      relationshipRuntimeManager: relationshipRuntime,
      storyRuntimeManager: story,
      rumorRuntimeManager: rumor,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      residentRuntimeManager: runtime,
      worldClockManager: clock,
      worldSaveManager: save,
      secondWorldEngine: secondWorld,
    );
    final dynamicEvents = DynamicEventRuntimeManager(
      config: DynamicEventConfig.fromJson({
        'version': 'test',
        'events': [
          {
            'id': 'living_office_event',
            'type': 'office_rush',
            'category': 'office',
            'title': '办公室轻轻忙起来',
            'conditions': {
              'minimumActivityLevel': 35,
              'requiredOfficeTags': ['office_group'],
            },
            'priority': 9,
            'weight': 1,
            'probability': 1,
            'repeatable': true,
            'cooldown': 1,
          },
          {
            'id': 'player_helpful_event',
            'type': 'office_help',
            'category': 'office',
            'title': '有人轻轻向你招手',
            'conditions': {
              'requiredPlayerReputation': ['helpful'],
              'requiredRecentActions': ['helping'],
              'minimumOfficeTrust': 10,
            },
            'priority': 12,
            'weight': 1,
            'probability': 1,
            'repeatable': true,
            'cooldown': 1,
          },
        ],
      }),
      worldClockManager: clock,
      dailySimulationManager: daily,
      residentRuntimeManager: runtime,
      residentDecisionManager: decision,
      relationshipRuntimeManager: relationshipRuntime,
      dialogueRuntimeManager: dialogue,
      storyRuntimeManager: story,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      rumorRuntimeManager: rumor,
      fishRuntimeManager: fish,
      questRuntimeManager: quest,
      achievementRuntimeManager: achievement,
      worldSaveManager: save,
      secondWorldEngine: secondWorld,
      residentMemoryEngine: memory,
    );
    final economy = EconomyRuntimeManager(
      fishRuntimeManager: fish,
      questRuntimeManager: quest,
      residentRuntimeManager: runtime,
      festivalRuntimeManager: festival,
      weatherRuntimeManager: weather,
      worldClockManager: clock,
      worldSaveManager: save,
      secondWorldEngine: secondWorld,
    );
    secondWorld.bindInteractiveRuntimes(
      relationshipRuntimeManager: relationshipRuntime,
      dynamicEventRuntimeManager: dynamicEvents,
      dailySimulationManager: daily,
      inventoryManager: inventory,
      inventoryConfig: inventoryConfig,
    );
    baseTick
      ..setRelationshipRuntimeManager(relationshipRuntime)
      ..setDynamicEventRuntimeManager(dynamicEvents)
      ..setQuestRuntimeManager(quest)
      ..setAchievementRuntimeManager(achievement)
      ..setEconomyRuntimeManager(economy);

    save.recordFriendshipChange(
      residentId: 'office_person_0',
      sourceType: 'test_help',
      sourceId: 'help_1',
      scoreDelta: 20,
      trustDelta: 10,
      familiarityDelta: 10,
      reason: 'player_helped',
      tags: const <String>['helping', 'communication'],
      relationship: relationship.getRelationship('office_person_0'),
    );
    save.recordPlayerAction(
      RecentPlayerAction(
        id: 'help_action_1',
        type: 'helping',
        sourceId: 'help_1',
        description: 'player_helped_resident',
        createdAt: DateTime.now().toIso8601String(),
        day: clock.today().dayCount,
        weight: 3,
        tags: const <String>['helping', 'choice:help'],
      ),
    );

    final morningStarted = DateTime.now();
    await baseTick.tickHour(advanceClock: false);
    final morningDuration =
        DateTime.now().difference(morningStarted).inMilliseconds;
    final morning = baseTick.lastResult!.worldContext.livingOfficeState;
    final playerInfluence =
        baseTick.lastResult!.worldContext.playerInfluenceContext;
    expect(morning.activeResidentCount, 100);
    expect(morning.workingResidentCount, greaterThan(0));
    expect(morning.activityLevel, greaterThanOrEqualTo(35));
    expect(morning.productivityLevel, inInclusiveRange(0, 100));
    expect(morning.socialLevel, inInclusiveRange(0, 100));
    expect(morning.tensionLevel, inInclusiveRange(0, 100));
    expect(morning.officeMood,
        isIn(<String>['calm', 'busy', 'social', 'cheerful']));
    expect(morning.popularLocations, isNotEmpty);
    expect(morning.worldTags, contains(startsWith('activity:')));
    expect(morningDuration, lessThan(800));
    expect(
      dialogue.getAvailableDialogues('office_person_0').map((item) => item.id),
      contains('office_active_dialogue'),
    );
    expect(story.getAvailableStories('office_person_0').map((item) => item.id),
        contains('office_active_story'));
    expect(dynamicEvents.getAvailableEvents().map((item) => item.id),
        contains('living_office_event'));
    expect(baseTick.lastResult!.worldContext.locationSnapshot.length, 100);
    expect(baseTick.lastResult!.worldContext.personalitySnapshot.length, 100);
    expect(baseTick.lastResult!.worldContext.friendshipSnapshot.length, 100);
    expect(playerInfluence.reputation, contains('helpful'));
    expect(
        playerInfluence.officeInfluence.officeTrust, greaterThanOrEqualTo(10));
    expect(playerInfluence.recentActionTypes, contains('helping'));
    expect(
        dialogue.getDialogue('office_person_0').id, 'player_helpful_dialogue');
    expect(story.getAvailableStories('office_person_0').map((item) => item.id),
        contains('player_helpful_story'));
    expect(dynamicEvents.getActiveEvents().map((item) => item.id),
        contains('player_helpful_event'));
    expect(quest.cumulativeMetrics['office_trust'], greaterThanOrEqualTo(10));
    expect(save.playerInfluenceContext.reputation, contains('helpful'));

    final friendshipBefore = save.getFriendshipState('office_person_0').score;
    await baseTick.tickHour(advanceClock: false);
    expect(save.getFriendshipState('office_person_0').score, friendshipBefore);

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 2, hour: 12, minute: 15),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 2,
        weekdayIndex: 2,
        month: 1,
        day: 2,
        season: 'summer',
      ),
    );
    await baseTick.tickHour(advanceClock: false);
    final lunch = baseTick.lastResult!.worldContext.livingOfficeState;
    expect(lunch.socialLevel, greaterThanOrEqualTo(morning.socialLevel));

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 2, hour: 23, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 2,
        weekdayIndex: 2,
        month: 1,
        day: 2,
        season: 'summer',
      ),
    );
    await baseTick.tickHour(advanceClock: false);
    final night = baseTick.lastResult!.worldContext.livingOfficeState;
    expect(night.activityLevel, lessThan(morning.activityLevel));

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 1, hour: 12, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 1,
        weekdayIndex: 1,
        month: 1,
        day: 1,
        season: 'summer',
      ),
    );
    await baseTick.tickHour(advanceClock: false);
    final festivalState = baseTick.lastResult!.worldContext.livingOfficeState;
    expect(festivalState.currentFestival, isNotEmpty);
    expect(festivalState.worldTags, contains('festival'));

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 3, hour: 21, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 3,
        weekdayIndex: 3,
        month: 1,
        day: 3,
        season: 'summer',
      ),
    );
    await baseTick.tickHour(advanceClock: false);
    final storm = baseTick.lastResult!.worldContext.livingOfficeState;
    expect(storm.worldTags, contains('weather_disruption'));
    expect(
      (storm.tensionLevel - festivalState.tensionLevel).abs(),
      lessThanOrEqualTo(12),
    );

    final interactiveSnapshot = secondWorld.getInteractiveOfficeSnapshot(
      playerLocation: 'office',
      residentLimit: 12,
      historyLimit: 10,
    );
    expect(interactiveSnapshot.availableResidents.length, 12);
    expect(interactiveSnapshot.nearbyResidents, isNotEmpty);
    expect(interactiveSnapshot.activeGroups, isNotEmpty);
    expect(interactiveSnapshot.currentEvents.map((item) => item.id),
        contains('player_helpful_event'));
    expect(interactiveSnapshot.availableActions.map((item) => item.id),
        contains('view_residents'));
    expect(interactiveSnapshot.playerReputation, contains('helpful'));
    expect(interactiveSnapshot.dailySummary['officeMood'], isNotEmpty);
    expect(interactiveSnapshot.residentDetails.length, 12);

    final fullInteractiveSnapshot =
        secondWorld.getInteractiveOfficeSnapshot(playerLocation: 'office');
    expect(fullInteractiveSnapshot.availableResidents.length, 100);
    expect(fullInteractiveSnapshot.residentDetails.length, 100);
    final residentDetail =
        secondWorld.getResidentDetailViewModel('office_person_0');
    expect(residentDetail.residentId, 'office_person_0');
    expect(residentDetail.visibleProfileFields.keys, contains('姓名'));
    expect(residentDetail.visibleProfileFields.keys, contains('当前地点'));
    expect(residentDetail.visibleProfileFields.keys, contains('当前行为'));
    expect(residentDetail.personalitySummary, isNotEmpty);
    expect(residentDetail.availableInteractions.map((item) => item.id),
        contains('talk'));
    expect(residentDetail.availableInteractions.map((item) => item.id),
        contains('share_fish'));
    expect(residentDetail.shareFishOptions.length, 1);
    expect(residentDetail.shareFishOptions.single.available, isTrue);
    expect(
      residentDetail.availableInteractions
          .firstWhere((item) => item.id == 'share_fish')
          .reason,
      contains('话题'),
    );
    expect(residentDetail.recentMemories.length, lessThanOrEqualTo(10));

    final residentAction = PlayerActionRequest(
      actionId: 'interactive_resident_help_1',
      actionType: 'help_work',
      targetResidentId: 'office_person_0',
      targetLocationId: 'office',
      sourcePage: 'resident_detail',
      currentWorldTime: 'Y1-D3 21:00',
      timestamp: DateTime.now().toIso8601String(),
    );
    expect(residentAction.requestId, residentAction.actionId);
    final residentResult = secondWorld.submitPlayerAction(residentAction);
    expect(residentResult.success, isTrue);
    expect(residentResult.dialogue, isNotNull);
    expect(residentResult.friendshipChanges, isNotEmpty);
    expect(residentResult.memoryChanges, isNotEmpty);
    expect(residentResult.resultGroups['positive'], isNotEmpty);
    expect(residentResult.recommendedNextActions, isNotEmpty);
    final updatedResidentDetail =
        secondWorld.getResidentDetailViewModel('office_person_0');
    expect(updatedResidentDetail.recentInteractions, isNotEmpty);
    expect(updatedResidentDetail.relationshipTrend, isNotEmpty);
    expect(updatedResidentDetail.currentCooldowns, isA<List>());
    final duplicateResidentResult =
        secondWorld.submitPlayerAction(residentAction);
    expect(duplicateResidentResult.success, isFalse);
    expect(
      duplicateResidentResult.blockedReasons,
      contains('duplicate_request'),
    );
    final shareFishBlocked = secondWorld.submitPlayerAction(
      PlayerActionRequest(
        actionId: 'interactive_share_fish_missing_1',
        actionType: 'share_fish',
        targetResidentId: 'office_person_0',
        sourcePage: 'resident_detail',
        timestamp: DateTime.now().toIso8601String(),
      ),
    );
    expect(shareFishBlocked.success, isFalse);
    expect(shareFishBlocked.blockedReasons.join(), contains('鱼'));
    expect(inventory.ownedOf('fish_small'), 2);

    final shareFishAction = PlayerActionRequest(
      actionId: 'interactive_share_fish_success_1',
      actionType: 'share_fish',
      targetResidentId: 'office_person_0',
      sourcePage: 'resident_detail',
      metadata: const <String, Object?>{'fishId': 'fish_small'},
      timestamp: DateTime.now().toIso8601String(),
    );
    final shareFishResult = secondWorld.submitPlayerAction(shareFishAction);
    expect(shareFishResult.success, isTrue);
    expect(shareFishResult.inventoryChanges, contains('小银鱼 -1'));
    expect(shareFishResult.friendshipChanges, isNotEmpty);
    expect(shareFishResult.memoryChanges, isNotEmpty);
    expect(inventory.ownedOf('fish_small'), 1);
    final duplicatedShareFish = secondWorld.submitPlayerAction(shareFishAction);
    expect(duplicatedShareFish.success, isFalse);
    expect(inventory.ownedOf('fish_small'), 1);
    final sameDayShareFish = secondWorld.submitPlayerAction(
      PlayerActionRequest(
        actionId: 'interactive_share_fish_success_2',
        actionType: 'share_fish',
        targetResidentId: 'office_person_0',
        sourcePage: 'resident_detail',
        metadata: const <String, Object?>{'fishId': 'fish_small'},
        timestamp: DateTime.now().toIso8601String(),
      ),
    );
    expect(sameDayShareFish.success, isFalse);
    expect(inventory.ownedOf('fish_small'), 1);

    final groupId = interactiveSnapshot.activeGroups.first.group.groupId;
    final groupResult = secondWorld.submitPlayerAction(
      PlayerActionRequest(
        actionId: 'interactive_group_join_1',
        actionType: 'join_group',
        targetGroupId: groupId,
        timestamp: DateTime.now().toIso8601String(),
      ),
    );
    expect(groupResult.success, isTrue);
    expect(groupResult.friendshipChanges, isNotEmpty);
    expect(groupResult.skillChanges, isNotEmpty);

    final eventResult = secondWorld.submitPlayerAction(
      PlayerActionRequest(
        actionId: 'interactive_event_help_1',
        actionType: 'help',
        targetEventId: 'player_helpful_event',
        timestamp: DateTime.now().toIso8601String(),
      ),
    );
    expect(
      eventResult.success,
      isTrue,
      reason: eventResult.blockedReasons.join(','),
    );
    expect(eventResult.eventTriggered?.id, 'player_helpful_event');
    expect(eventResult.positiveChanges, isNotEmpty);

    clock.setClock(
      WorldClock.initial().copyWith(dayCount: 4, hour: 9, minute: 0),
      calendar: WorldCalendar.initial().copyWith(
        dayCount: 4,
        weekdayIndex: 4,
        month: 1,
        day: 4,
        season: 'summer',
      ),
    );
    final summary = await daily.runDailySimulation();
    expect(summary.livingOfficeState, isNotNull);
    expect(summary.dominantOfficeMood, isNotEmpty);
    expect(summary.averageActivityLevel, inInclusiveRange(0, 100));
    expect(summary.importantOfficeEvents, isNotEmpty);
    expect(summary.groupActivities, isNotEmpty);
    expect(summary.popularLocations, isNotEmpty);
    expect(summary.todayPlayerImpact['officeReputation'], contains('helpful'));
    expect(
      summary.todayPlayerImpact['influencedEvents'],
      greaterThanOrEqualTo(1),
    );
    expect(summary.todayPlayerImpact['officeInfluence'], isA<Map>());
    expect(save.officeWorldHistory.length, 1);
    await daily.runDailySimulation();
    expect(save.officeWorldHistory.length, 1);

    for (var day = 5; day < 100; day += 1) {
      final state = secondWorld.buildLivingOfficeState(
        worldDate: 'Y1-M1-D$day-#$day',
        timeOfDay: 'morning',
        weekday: 2,
        season: 'summer',
        weatherContext: weather.getCurrentWeather(),
        festivalContext: null,
        activeRumors: rumor.getActiveRumors(),
        residentSnapshot: runtime.getAllResidentCurrentStates(),
        activeGroups: save.activeGroups,
        activeStories: const <Object?>[],
        activeEvents: const <Object?>[],
        careerContext: save.careerState,
        skillSummary: Map<String, Object?>.from(save.playerSkillStates),
        questSummary: quest.cumulativeMetrics,
        achievementSummary: achievement.getAllAchievements(),
        previousState: save.livingOfficeState,
      );
      save.recordOfficeWorldHistory(
        secondWorld.buildOfficeWorldHistoryEntry(state),
      );
    }
    expect(save.officeWorldHistory.length, lessThanOrEqualTo(90));

    final saved = await save.saveWorld(force: true, immediate: true);
    expect(
        saved.livingOfficeState.officeMood, save.livingOfficeState.officeMood);
    expect(saved.officeWorldHistory, isNotEmpty);
    final restored = WorldSaveData.fromJson(saved.toJson());
    expect(restored.livingOfficeState.officeMood,
        saved.livingOfficeState.officeMood);
    expect(restored.officeWorldHistory.length, saved.officeWorldHistory.length);
    expect(restored.playerInfluenceContext.reputation, contains('helpful'));
    expect(restored.recentPlayerActions.map((item) => item.type),
        contains('helping'));
    final legacy = WorldSaveData.fromJson(const <String, dynamic>{});
    expect(legacy.livingOfficeState.officeMood, 'calm');
    expect(legacy.officeWorldHistory, isEmpty);
    expect(legacy.playerInfluenceContext.reputation, contains('quiet'));
  });
}

Map<String, Object?> _organizationResident({
  required String id,
  required String departmentId,
  required String teamId,
  required String positionId,
  String careerLevel = 'regular',
}) {
  return <String, Object?>{
    'id': id,
    'name': id,
    'job': '居民员工',
    'personality': 'steady',
    'location': 'office',
    'enabled': true,
    'organization': <String, Object?>{
      'companyId': 'fishing_office',
      'departmentId': departmentId,
      'teamId': teamId,
      'positionId': positionId,
    },
    'career': <String, Object?>{
      'careerLevel': careerLevel,
      'hireDate': 'Y1-M01-D01',
      'salaryLevel': residentCareerBaseSalary[careerLevel] ?? 180,
      'performanceScore': 70,
      'capabilityScore': 70,
      'employmentStatus': 'active',
      'promotionHistory': <Map<String, Object?>>[
        <String, Object?>{
          'type': 'hire',
          'date': 'Y1-M01-D01',
          'fromPositionId': '',
          'toPositionId': positionId,
          'fromCareerLevel': '',
          'toCareerLevel': careerLevel,
          'reason': 'test_hire',
        },
      ],
    },
  };
}

class _FakeResidentLifeRepository extends ResidentLifeRepository {
  _FakeResidentLifeRepository(this.config)
      : super(source: const _FakeJsonSource());

  final ResidentLifeConfig config;

  @override
  Future<ResidentLifeConfig> load() async => config;
}

class _FakeJsonSource implements JsonSource {
  const _FakeJsonSource();

  @override
  Future<String> loadString(String path) async => '{}';
}

class _FakeResidentRepository extends ResidentRepository {
  _FakeResidentRepository(this.config) : super(source: const _FakeJsonSource());

  final ResidentConfig config;

  @override
  Future<ResidentConfig> load() async => config;
}

class _CountingWorldSaveRepository implements WorldSaveRepository {
  WorldSaveData? data;
  int saveCount = 0;

  @override
  Future<WorldSaveData?> load() async => data;

  @override
  Future<void> reset() async {
    data = null;
  }

  @override
  Future<void> save(WorldSaveData data) async {
    saveCount += 1;
    this.data = data;
  }
}

class _ThrowingWeatherRuntimeManager extends WeatherRuntimeManager {
  _ThrowingWeatherRuntimeManager({
    required WorldClockManager clock,
    required ResidentRuntimeManager runtime,
  }) : super(
          config: WeatherConfig.fromJson({
            'version': 'test',
            'weatherEvents': [],
          }),
          worldClockManager: clock,
          residentRuntimeManager: runtime,
        );

  @override
  WeatherEntry? getCurrentWeather() {
    throw StateError('weather runtime failed');
  }

  @override
  List<String> getWeatherTags() {
    throw StateError('weather tags failed');
  }
}
