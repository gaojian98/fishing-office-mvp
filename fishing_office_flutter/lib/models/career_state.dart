const List<String> careerLevelOrder = <String>[
  'intern',
  'junior_employee',
  'employee',
  'senior_employee',
  'team_lead',
  'supervisor',
  'manager',
  'senior_manager',
  'director',
];

const Map<String, String> careerLevelTitles = <String, String>{
  'intern': '实习生',
  'junior_employee': '初级员工',
  'employee': '正式员工',
  'senior_employee': '资深员工',
  'team_lead': '组长',
  'supervisor': '主管',
  'manager': '经理',
  'senior_manager': '高级经理',
  'director': '总监',
};

const Map<String, int> careerLevelSalary = <String, int>{
  'intern': 120,
  'junior_employee': 180,
  'employee': 260,
  'senior_employee': 380,
  'team_lead': 520,
  'supervisor': 700,
  'manager': 920,
  'senior_manager': 1180,
  'director': 1500,
};

const List<String> playerSkillIds = <String>[
  'fishing',
  'communication',
  'observation',
  'efficiency',
  'management',
  'luck',
];

const Map<int, int> playerSkillExperienceCurve = <int, int>{
  1: 100,
  2: 250,
  3: 500,
  4: 900,
  5: 1400,
  6: 2100,
  7: 3000,
  8: 4200,
  9: 6000,
  10: 6000,
};

class CareerState {
  const CareerState({
    required this.careerLevel,
    required this.jobTitle,
    required this.departmentId,
    required this.performanceScore,
    required this.experience,
    required this.salary,
    required this.promotionProgress,
    required this.promotionEligible,
    required this.lastSalaryDate,
    required this.lastPromotionDate,
    required this.consecutiveWorkDays,
    required this.completedCareerTasks,
    required this.careerTags,
    required this.recentCareerChanges,
    required this.skillSummary,
    required this.careerRecommendedSkills,
    required this.promotionSkillRequirements,
    required this.recentSkillGrowth,
  });

  factory CareerState.initial() {
    return CareerState(
      careerLevel: 'intern',
      jobTitle: '实习生',
      departmentId: 'office',
      performanceScore: 50,
      experience: 0,
      salary: 120,
      promotionProgress: 0,
      promotionEligible: false,
      lastSalaryDate: '',
      lastPromotionDate: '',
      consecutiveWorkDays: 0,
      completedCareerTasks: 0,
      careerTags: const <String>['career:intern'],
      recentCareerChanges: const <String>[],
      skillSummary: <String, PlayerSkillState>{
        for (final skillId in playerSkillIds)
          skillId: PlayerSkillState.initial(skillId)
      },
      careerRecommendedSkills: const <String>['fishing', 'communication'],
      promotionSkillRequirements: const <String, int>{},
      recentSkillGrowth: const <SkillExperienceRecord>[],
    );
  }

  factory CareerState.fromJson(Map<String, dynamic> json) {
    final level = _normalizeLevel(json['careerLevel']?.toString() ?? '');
    return CareerState(
      careerLevel: level,
      jobTitle: json['jobTitle']?.toString().isNotEmpty == true
          ? json['jobTitle'].toString()
          : titleForLevel(level),
      departmentId: json['departmentId']?.toString().isNotEmpty == true
          ? json['departmentId'].toString()
          : 'office',
      performanceScore: _readInt(json['performanceScore'], fallback: 50)
          .clamp(0, 100)
          .toInt(),
      experience: _readInt(json['experience']).clamp(0, 1 << 31).toInt(),
      salary: _readInt(
        json['salary'],
        fallback: salaryForLevel(level),
      ).clamp(0, 1 << 31).toInt(),
      promotionProgress:
          _readInt(json['promotionProgress']).clamp(0, 100).toInt(),
      promotionEligible: json['promotionEligible'] == true,
      lastSalaryDate: json['lastSalaryDate']?.toString() ?? '',
      lastPromotionDate: json['lastPromotionDate']?.toString() ?? '',
      consecutiveWorkDays:
          _readInt(json['consecutiveWorkDays']).clamp(0, 1 << 31).toInt(),
      completedCareerTasks:
          _readInt(json['completedCareerTasks']).clamp(0, 1 << 31).toInt(),
      careerTags: _stringList(json['careerTags']),
      recentCareerChanges: _stringList(json['recentCareerChanges']),
      skillSummary: _skillSummaryFromJson(json['skillSummary']),
      careerRecommendedSkills: _stringList(json['careerRecommendedSkills']),
      promotionSkillRequirements:
          _skillRequirementMap(json['promotionSkillRequirements']),
      recentSkillGrowth: _listOfMaps(json['recentSkillGrowth'])
          .map(SkillExperienceRecord.fromJson)
          .toList(growable: false),
    ).normalized();
  }

  final String careerLevel;
  final String jobTitle;
  final String departmentId;
  final int performanceScore;
  final int experience;
  final int salary;
  final int promotionProgress;
  final bool promotionEligible;
  final String lastSalaryDate;
  final String lastPromotionDate;
  final int consecutiveWorkDays;
  final int completedCareerTasks;
  final List<String> careerTags;
  final List<String> recentCareerChanges;
  final Map<String, PlayerSkillState> skillSummary;
  final List<String> careerRecommendedSkills;
  final Map<String, int> promotionSkillRequirements;
  final List<SkillExperienceRecord> recentSkillGrowth;

  int get levelIndex => careerLevelOrder.indexOf(careerLevel).clamp(0, 999);
  bool get isMaxLevel => levelIndex >= careerLevelOrder.length - 1;
  String get nextCareerLevel =>
      isMaxLevel ? careerLevel : careerLevelOrder[levelIndex + 1];

  CareerState normalized() {
    final tags = <String>{
      ...careerTags,
      'career:$careerLevel',
      'department:$departmentId',
    }.where((item) => item.isNotEmpty).toList(growable: false);
    return copyWith(
      careerLevel: _normalizeLevel(careerLevel),
      jobTitle: jobTitle.isEmpty ? titleForLevel(careerLevel) : jobTitle,
      salary: salary <= 0 ? salaryForLevel(careerLevel) : salary,
      performanceScore: performanceScore.clamp(0, 100),
      experience: experience.clamp(0, 1 << 31),
      promotionProgress: promotionProgress.clamp(0, 100),
      careerTags: tags,
      recentCareerChanges: _limitStrings(recentCareerChanges, 20),
      skillSummary: _normalizedSkills(skillSummary),
      careerRecommendedSkills:
          _recommendedSkillsForLevel(nextCareerLevel, skillSummary),
      promotionSkillRequirements:
          CareerPromotionRequirement.forTarget(nextCareerLevel).requiredSkills,
      recentSkillGrowth: _limitSkillRecords(recentSkillGrowth, 50),
    );
  }

  CareerState copyWith({
    String? careerLevel,
    String? jobTitle,
    String? departmentId,
    int? performanceScore,
    int? experience,
    int? salary,
    int? promotionProgress,
    bool? promotionEligible,
    String? lastSalaryDate,
    String? lastPromotionDate,
    int? consecutiveWorkDays,
    int? completedCareerTasks,
    List<String>? careerTags,
    List<String>? recentCareerChanges,
    Map<String, PlayerSkillState>? skillSummary,
    List<String>? careerRecommendedSkills,
    Map<String, int>? promotionSkillRequirements,
    List<SkillExperienceRecord>? recentSkillGrowth,
  }) {
    return CareerState(
      careerLevel: careerLevel ?? this.careerLevel,
      jobTitle: jobTitle ?? this.jobTitle,
      departmentId: departmentId ?? this.departmentId,
      performanceScore: performanceScore ?? this.performanceScore,
      experience: experience ?? this.experience,
      salary: salary ?? this.salary,
      promotionProgress: promotionProgress ?? this.promotionProgress,
      promotionEligible: promotionEligible ?? this.promotionEligible,
      lastSalaryDate: lastSalaryDate ?? this.lastSalaryDate,
      lastPromotionDate: lastPromotionDate ?? this.lastPromotionDate,
      consecutiveWorkDays: consecutiveWorkDays ?? this.consecutiveWorkDays,
      completedCareerTasks: completedCareerTasks ?? this.completedCareerTasks,
      careerTags: careerTags ?? this.careerTags,
      recentCareerChanges: recentCareerChanges ?? this.recentCareerChanges,
      skillSummary: skillSummary ?? this.skillSummary,
      careerRecommendedSkills:
          careerRecommendedSkills ?? this.careerRecommendedSkills,
      promotionSkillRequirements:
          promotionSkillRequirements ?? this.promotionSkillRequirements,
      recentSkillGrowth: recentSkillGrowth ?? this.recentSkillGrowth,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'careerLevel': careerLevel,
      'jobTitle': jobTitle,
      'departmentId': departmentId,
      'performanceScore': performanceScore,
      'experience': experience,
      'salary': salary,
      'promotionProgress': promotionProgress,
      'promotionEligible': promotionEligible,
      'lastSalaryDate': lastSalaryDate,
      'lastPromotionDate': lastPromotionDate,
      'consecutiveWorkDays': consecutiveWorkDays,
      'completedCareerTasks': completedCareerTasks,
      'careerTags': careerTags,
      'recentCareerChanges': recentCareerChanges,
      'skillSummary':
          skillSummary.map((key, value) => MapEntry(key, value.toJson())),
      'careerRecommendedSkills': careerRecommendedSkills,
      'promotionSkillRequirements': promotionSkillRequirements,
      'recentSkillGrowth':
          recentSkillGrowth.map((record) => record.toJson()).toList(),
    };
  }

  PlayerSkillState skill(String skillId) {
    return skillSummary[skillId] ?? PlayerSkillState.initial(skillId);
  }

  CareerPromotionRequirement nextRequirement() {
    return CareerPromotionRequirement.forTarget(nextCareerLevel);
  }

  CareerPromotionCheck checkPromotion({
    int maxRelationshipRank = 0,
    Set<String> unlockedAchievementIds = const <String>{},
    Set<String> claimedPromotionRewards = const <String>{},
  }) {
    if (isMaxLevel) {
      return CareerPromotionCheck(
        eligible: false,
        currentLevel: careerLevel,
        targetLevel: careerLevel,
        targetTitle: jobTitle,
        progress: 100,
        missingRequirements: const <String>['already_max_level'],
        requirement: CareerPromotionRequirement.forTarget(careerLevel),
      );
    }
    final requirement = nextRequirement();
    final missing = <String>[];
    if (consecutiveWorkDays < requirement.minimumWorkDays) {
      missing.add('minimum_work_days:${requirement.minimumWorkDays}');
    }
    if (completedCareerTasks < requirement.requiredCareerTasks) {
      missing.add('career_task_completion:${requirement.requiredCareerTasks}');
    }
    if (performanceScore < requirement.minimumPerformance) {
      missing.add('performance_score:${requirement.minimumPerformance}');
    }
    if (experience < requirement.requiredExperience) {
      missing.add('career_experience:${requirement.requiredExperience}');
    }
    if (maxRelationshipRank < requirement.minimumRelationshipRank) {
      missing.add('relationship_rank:${requirement.minimumRelationshipRank}');
    }
    if (requirement.requiredAchievementId.isNotEmpty &&
        !unlockedAchievementIds.contains(requirement.requiredAchievementId)) {
      missing.add('required_achievement:${requirement.requiredAchievementId}');
    }
    for (final entry in requirement.requiredSkills.entries) {
      if (skill(entry.key).level < entry.value) {
        missing.add('skill_${entry.key}:${entry.value}');
      }
    }
    final rewardId = promotionRewardId(careerLevel, requirement.targetLevel);
    if (claimedPromotionRewards.contains(rewardId)) {
      missing.add('promotion_reward_already_claimed:$rewardId');
    }
    final progress = requirement.progressFor(
      workDays: consecutiveWorkDays,
      careerTasks: completedCareerTasks,
      performance: performanceScore,
      experience: experience,
      relationshipRank: maxRelationshipRank,
      hasAchievement: requirement.requiredAchievementId.isEmpty ||
          unlockedAchievementIds.contains(requirement.requiredAchievementId),
      skills: skillSummary,
    );
    return CareerPromotionCheck(
      eligible: missing.isEmpty,
      currentLevel: careerLevel,
      targetLevel: requirement.targetLevel,
      targetTitle: titleForLevel(requirement.targetLevel),
      progress: progress,
      missingRequirements: missing,
      requirement: requirement,
    );
  }

  CareerState withPromotionCheck(CareerPromotionCheck check) {
    return copyWith(
      promotionEligible: check.eligible,
      promotionProgress: check.progress,
    ).normalized();
  }

  CareerState withCareerProgress({
    required int experienceDelta,
    required int performanceDelta,
    int completedTaskDelta = 0,
    String reason = '',
  }) {
    final boundedPerformanceDelta = performanceDelta.clamp(-8, 8).toInt();
    final nextChanges = <String>[
      if (reason.isNotEmpty) reason,
      ...recentCareerChanges,
    ];
    return copyWith(
      experience: experience + experienceDelta.clamp(0, 1 << 31).toInt(),
      performanceScore:
          (performanceScore + boundedPerformanceDelta).clamp(0, 100).toInt(),
      completedCareerTasks:
          completedCareerTasks + completedTaskDelta.clamp(0, 1 << 31).toInt(),
      recentCareerChanges: _limitStrings(nextChanges, 20),
    ).normalized();
  }

  CareerSkillGainResult withSkillExperience({
    required SkillExperienceRecord record,
  }) {
    final current = skill(record.skillId);
    final updated = current.addExperience(
      amount: record.amount,
      reason: record.reason,
      sourceId: record.sourceId,
    );
    final nextSkills = <String, PlayerSkillState>{
      ..._normalizedSkills(skillSummary),
      record.skillId: updated.skill,
    };
    final nextRecord = record.copyWith(
      levelBefore: current.level,
      levelAfter: updated.skill.level,
    );
    return CareerSkillGainResult(
      state: copyWith(
        skillSummary: nextSkills,
        recentSkillGrowth: _limitSkillRecords(
          <SkillExperienceRecord>[nextRecord, ...recentSkillGrowth],
          50,
        ),
      ).normalized(),
      record: nextRecord,
      levelUps: updated.levelUps,
    );
  }

  CareerState withDailySettlement({
    required String dateLabel,
    int experienceDelta = 2,
    int performanceDelta = 0,
    int completedTaskDelta = 0,
    String reason = 'career_daily_settlement',
  }) {
    final regression = _performanceRegression(performanceScore);
    return withCareerProgress(
      experienceDelta: experienceDelta,
      performanceDelta: (performanceDelta + regression).clamp(-3, 3).toInt(),
      completedTaskDelta: completedTaskDelta,
      reason: '$reason:$dateLabel',
    )
        .copyWith(
          consecutiveWorkDays: consecutiveWorkDays + 1,
        )
        .normalized();
  }

  CareerState promote(String timestamp) {
    if (isMaxLevel) return this;
    final next = nextCareerLevel;
    return copyWith(
      careerLevel: next,
      jobTitle: titleForLevel(next),
      salary: salaryForLevel(next),
      promotionEligible: false,
      promotionProgress: 0,
      lastPromotionDate: timestamp,
      careerTags: <String>{
        ...careerTags,
        'career:$next',
        'promoted',
      }.toList(growable: false),
      recentCareerChanges: _limitStrings(
        <String>['promotion:$careerLevel->$next', ...recentCareerChanges],
        20,
      ),
    ).normalized();
  }

  CareerState withSalaryDate(String salaryDate) {
    return copyWith(lastSalaryDate: salaryDate).normalized();
  }

  static String titleForLevel(String level) =>
      careerLevelTitles[_normalizeLevel(level)] ?? '实习生';

  static int salaryForLevel(String level) =>
      careerLevelSalary[_normalizeLevel(level)] ?? 120;

  static String promotionRewardId(String fromLevel, String toLevel) {
    return 'promotion_${_normalizeLevel(fromLevel)}_to_${_normalizeLevel(toLevel)}';
  }
}

class CareerPromotionRequirement {
  const CareerPromotionRequirement({
    required this.targetLevel,
    required this.minimumWorkDays,
    required this.requiredCareerTasks,
    required this.minimumPerformance,
    required this.requiredExperience,
    required this.minimumRelationshipRank,
    required this.requiredAchievementId,
    required this.requiredSkills,
  });

  factory CareerPromotionRequirement.forTarget(String targetLevel) {
    switch (_normalizeLevel(targetLevel)) {
      case 'junior_employee':
        return const CareerPromotionRequirement(
          targetLevel: 'junior_employee',
          minimumWorkDays: 3,
          requiredCareerTasks: 3,
          minimumPerformance: 55,
          requiredExperience: 20,
          minimumRelationshipRank: 0,
          requiredAchievementId: '',
          requiredSkills: <String, int>{},
        );
      case 'employee':
        return const CareerPromotionRequirement(
          targetLevel: 'employee',
          minimumWorkDays: 7,
          requiredCareerTasks: 8,
          minimumPerformance: 60,
          requiredExperience: 60,
          minimumRelationshipRank: 0,
          requiredAchievementId: '',
          requiredSkills: <String, int>{},
        );
      case 'senior_employee':
        return const CareerPromotionRequirement(
          targetLevel: 'senior_employee',
          minimumWorkDays: 15,
          requiredCareerTasks: 15,
          minimumPerformance: 65,
          requiredExperience: 130,
          minimumRelationshipRank: 2,
          requiredAchievementId: '',
          requiredSkills: <String, int>{},
        );
      case 'team_lead':
        return const CareerPromotionRequirement(
          targetLevel: 'team_lead',
          minimumWorkDays: 28,
          requiredCareerTasks: 26,
          minimumPerformance: 70,
          requiredExperience: 260,
          minimumRelationshipRank: 2,
          requiredAchievementId: '',
          requiredSkills: <String, int>{
            'communication': 3,
            'efficiency': 3,
          },
        );
      case 'supervisor':
        return const CareerPromotionRequirement(
          targetLevel: 'supervisor',
          minimumWorkDays: 45,
          requiredCareerTasks: 42,
          minimumPerformance: 74,
          requiredExperience: 430,
          minimumRelationshipRank: 3,
          requiredAchievementId: '',
          requiredSkills: <String, int>{
            'communication': 4,
            'efficiency': 3,
          },
        );
      case 'manager':
        return const CareerPromotionRequirement(
          targetLevel: 'manager',
          minimumWorkDays: 70,
          requiredCareerTasks: 65,
          minimumPerformance: 78,
          requiredExperience: 700,
          minimumRelationshipRank: 3,
          requiredAchievementId: 'career_employee',
          requiredSkills: <String, int>{
            'communication': 5,
            'management': 4,
          },
        );
      case 'senior_manager':
        return const CareerPromotionRequirement(
          targetLevel: 'senior_manager',
          minimumWorkDays: 100,
          requiredCareerTasks: 92,
          minimumPerformance: 82,
          requiredExperience: 1080,
          minimumRelationshipRank: 4,
          requiredAchievementId: 'career_manager',
          requiredSkills: <String, int>{
            'management': 5,
            'observation': 4,
          },
        );
      case 'director':
        return const CareerPromotionRequirement(
          targetLevel: 'director',
          minimumWorkDays: 150,
          requiredCareerTasks: 135,
          minimumPerformance: 86,
          requiredExperience: 1600,
          minimumRelationshipRank: 4,
          requiredAchievementId: 'high_performance',
          requiredSkills: <String, int>{
            'management': 7,
            'observation': 6,
          },
        );
      default:
        return const CareerPromotionRequirement(
          targetLevel: 'intern',
          minimumWorkDays: 0,
          requiredCareerTasks: 0,
          minimumPerformance: 0,
          requiredExperience: 0,
          minimumRelationshipRank: 0,
          requiredAchievementId: '',
          requiredSkills: <String, int>{},
        );
    }
  }

  final String targetLevel;
  final int minimumWorkDays;
  final int requiredCareerTasks;
  final int minimumPerformance;
  final int requiredExperience;
  final int minimumRelationshipRank;
  final String requiredAchievementId;
  final Map<String, int> requiredSkills;

  int progressFor({
    required int workDays,
    required int careerTasks,
    required int performance,
    required int experience,
    required int relationshipRank,
    required bool hasAchievement,
    Map<String, PlayerSkillState> skills = const <String, PlayerSkillState>{},
  }) {
    final parts = <double>[
      _ratio(workDays, minimumWorkDays),
      _ratio(careerTasks, requiredCareerTasks),
      _ratio(performance, minimumPerformance),
      _ratio(experience, requiredExperience),
      _ratio(relationshipRank, minimumRelationshipRank),
      hasAchievement ? 1 : 0,
      ...requiredSkills.entries.map(
        (entry) => _ratio(
          (skills[entry.key] ?? PlayerSkillState.initial(entry.key)).level,
          entry.value,
        ),
      ),
    ];
    return (parts.fold<double>(0, (sum, item) => sum + item) /
            parts.length *
            100)
        .clamp(0, 100)
        .round();
  }

  Map<String, dynamic> toJson() {
    return {
      'targetLevel': targetLevel,
      'minimumWorkDays': minimumWorkDays,
      'requiredCareerTasks': requiredCareerTasks,
      'minimumPerformance': minimumPerformance,
      'requiredExperience': requiredExperience,
      'minimumRelationshipRank': minimumRelationshipRank,
      'requiredAchievementId': requiredAchievementId,
      'requiredSkills': requiredSkills,
    };
  }
}

class CareerPromotionCheck {
  const CareerPromotionCheck({
    required this.eligible,
    required this.currentLevel,
    required this.targetLevel,
    required this.targetTitle,
    required this.progress,
    required this.missingRequirements,
    required this.requirement,
  });

  final bool eligible;
  final String currentLevel;
  final String targetLevel;
  final String targetTitle;
  final int progress;
  final List<String> missingRequirements;
  final CareerPromotionRequirement requirement;
}

class CareerPromotionResult {
  const CareerPromotionResult({
    required this.success,
    required this.previousLevel,
    required this.newLevel,
    required this.newTitle,
    required this.reward,
    required this.missingRequirements,
    required this.performanceScore,
    required this.timestamp,
  });

  final bool success;
  final String previousLevel;
  final String newLevel;
  final String newTitle;
  final int reward;
  final List<String> missingRequirements;
  final int performanceScore;
  final String timestamp;
}

class CareerRewardRecord {
  const CareerRewardRecord({
    required this.id,
    required this.type,
    required this.sourceId,
    required this.experience,
    required this.performanceDelta,
    required this.createdAt,
  });

  factory CareerRewardRecord.fromJson(Map<String, dynamic> json) {
    return CareerRewardRecord(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      sourceId: json['sourceId']?.toString() ?? '',
      experience: _readInt(json['experience']),
      performanceDelta: _readInt(json['performanceDelta']),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  final String id;
  final String type;
  final String sourceId;
  final int experience;
  final int performanceDelta;
  final String createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'sourceId': sourceId,
      'experience': experience,
      'performanceDelta': performanceDelta,
      'createdAt': createdAt,
    };
  }
}

class CareerPromotionRecord {
  const CareerPromotionRecord({
    required this.id,
    required this.previousLevel,
    required this.newLevel,
    required this.reward,
    required this.createdAt,
  });

  factory CareerPromotionRecord.fromJson(Map<String, dynamic> json) {
    return CareerPromotionRecord(
      id: json['id']?.toString() ?? '',
      previousLevel: json['previousLevel']?.toString() ?? '',
      newLevel: json['newLevel']?.toString() ?? '',
      reward: _readInt(json['reward']),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  final String id;
  final String previousLevel;
  final String newLevel;
  final int reward;
  final String createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'previousLevel': previousLevel,
      'newLevel': newLevel,
      'reward': reward,
      'createdAt': createdAt,
    };
  }
}

class CareerSalaryPayment {
  const CareerSalaryPayment({
    required this.transactionId,
    required this.careerLevel,
    required this.amount,
    required this.periodStart,
    required this.periodEnd,
    required this.timestamp,
    required this.paid,
  });

  final String transactionId;
  final String careerLevel;
  final int amount;
  final int periodStart;
  final int periodEnd;
  final String timestamp;
  final bool paid;

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'careerLevel': careerLevel,
      'amount': amount,
      'periodStart': periodStart,
      'periodEnd': periodEnd,
      'timestamp': timestamp,
      'paid': paid,
    };
  }
}

class PlayerSkillState {
  const PlayerSkillState({
    required this.skillId,
    required this.level,
    required this.experience,
    required this.experienceToNextLevel,
    required this.progress,
    required this.lastGainReason,
    required this.lastGainSourceId,
    required this.recentGainHistory,
    required this.unlockedMilestones,
  });

  factory PlayerSkillState.initial(String skillId) {
    return PlayerSkillState(
      skillId: _normalizeSkillId(skillId),
      level: 1,
      experience: 0,
      experienceToNextLevel: playerSkillExperienceCurve[1] ?? 100,
      progress: 0,
      lastGainReason: '',
      lastGainSourceId: '',
      recentGainHistory: const <String>[],
      unlockedMilestones: const <String>[],
    );
  }

  factory PlayerSkillState.fromJson(Map<String, dynamic> json) {
    final skillId = _normalizeSkillId(json['skillId']?.toString() ?? '');
    final level = _readInt(json['level'], fallback: 1).clamp(1, 10).toInt();
    final experience = _readInt(json['experience']).clamp(0, 1 << 31).toInt();
    return PlayerSkillState(
      skillId: skillId,
      level: level,
      experience: experience,
      experienceToNextLevel: _experienceToNext(level),
      progress: _skillProgress(level, experience),
      lastGainReason: json['lastGainReason']?.toString() ?? '',
      lastGainSourceId: json['lastGainSourceId']?.toString() ?? '',
      recentGainHistory:
          _limitStrings(_stringList(json['recentGainHistory']), 20),
      unlockedMilestones: _stringList(json['unlockedMilestones']),
    ).normalized();
  }

  final String skillId;
  final int level;
  final int experience;
  final int experienceToNextLevel;
  final int progress;
  final String lastGainReason;
  final String lastGainSourceId;
  final List<String> recentGainHistory;
  final List<String> unlockedMilestones;

  bool get isMaxLevel => level >= 10;

  PlayerSkillState normalized() {
    return copyWith(
      skillId: _normalizeSkillId(skillId),
      level: level.clamp(1, 10),
      experience: experience.clamp(0, 1 << 31),
      experienceToNextLevel: _experienceToNext(level.clamp(1, 10)),
      progress: _skillProgress(level.clamp(1, 10), experience),
      recentGainHistory: _limitStrings(recentGainHistory, 20),
      unlockedMilestones: _skillMilestones(level, unlockedMilestones),
    );
  }

  PlayerSkillLevelUpResult addExperience({
    required int amount,
    required String reason,
    required String sourceId,
  }) {
    final bounded = amount.clamp(0, 1000000).toInt();
    var nextLevel = level;
    final nextExperience = experience + bounded;
    final levelUps = <String>[];
    while (nextLevel < 10 &&
        nextExperience >= (playerSkillExperienceCurve[nextLevel] ?? 6000)) {
      nextLevel += 1;
      levelUps.add('$skillId:$nextLevel');
    }
    final next = copyWith(
      level: nextLevel,
      experience: nextExperience,
      experienceToNextLevel: _experienceToNext(nextLevel),
      progress: _skillProgress(nextLevel, nextExperience),
      lastGainReason: reason,
      lastGainSourceId: sourceId,
      recentGainHistory: _limitStrings(
        <String>['$sourceId:+$bounded', ...recentGainHistory],
        20,
      ),
      unlockedMilestones: _skillMilestones(nextLevel, unlockedMilestones),
    ).normalized();
    return PlayerSkillLevelUpResult(skill: next, levelUps: levelUps);
  }

  PlayerSkillState copyWith({
    String? skillId,
    int? level,
    int? experience,
    int? experienceToNextLevel,
    int? progress,
    String? lastGainReason,
    String? lastGainSourceId,
    List<String>? recentGainHistory,
    List<String>? unlockedMilestones,
  }) {
    return PlayerSkillState(
      skillId: skillId ?? this.skillId,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      experienceToNextLevel:
          experienceToNextLevel ?? this.experienceToNextLevel,
      progress: progress ?? this.progress,
      lastGainReason: lastGainReason ?? this.lastGainReason,
      lastGainSourceId: lastGainSourceId ?? this.lastGainSourceId,
      recentGainHistory: recentGainHistory ?? this.recentGainHistory,
      unlockedMilestones: unlockedMilestones ?? this.unlockedMilestones,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skillId': skillId,
      'level': level,
      'experience': experience,
      'experienceToNextLevel': experienceToNextLevel,
      'progress': progress,
      'lastGainReason': lastGainReason,
      'lastGainSourceId': lastGainSourceId,
      'recentGainHistory': recentGainHistory,
      'unlockedMilestones': unlockedMilestones,
    };
  }
}

class PlayerSkillLevelUpResult {
  const PlayerSkillLevelUpResult({
    required this.skill,
    required this.levelUps,
  });

  final PlayerSkillState skill;
  final List<String> levelUps;
}

class CareerSkillGainResult {
  const CareerSkillGainResult({
    required this.state,
    required this.record,
    required this.levelUps,
  });

  final CareerState state;
  final SkillExperienceRecord record;
  final List<String> levelUps;
}

class SkillExperienceRecord {
  const SkillExperienceRecord({
    required this.sourceType,
    required this.sourceId,
    required this.timestamp,
    required this.skillId,
    required this.amount,
    required this.reason,
    this.levelBefore = 1,
    this.levelAfter = 1,
  });

  factory SkillExperienceRecord.fromJson(Map<String, dynamic> json) {
    return SkillExperienceRecord(
      sourceType: json['sourceType']?.toString() ?? '',
      sourceId: json['sourceId']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      skillId: _normalizeSkillId(json['skillId']?.toString() ?? ''),
      amount: _readInt(json['amount']).clamp(0, 1000000).toInt(),
      reason: json['reason']?.toString() ?? '',
      levelBefore:
          _readInt(json['levelBefore'], fallback: 1).clamp(1, 10).toInt(),
      levelAfter:
          _readInt(json['levelAfter'], fallback: 1).clamp(1, 10).toInt(),
    );
  }

  final String sourceType;
  final String sourceId;
  final String timestamp;
  final String skillId;
  final int amount;
  final String reason;
  final int levelBefore;
  final int levelAfter;

  String get dedupeKey => '$sourceType::$sourceId::$skillId';

  SkillExperienceRecord copyWith({
    int? levelBefore,
    int? levelAfter,
  }) {
    return SkillExperienceRecord(
      sourceType: sourceType,
      sourceId: sourceId,
      timestamp: timestamp,
      skillId: skillId,
      amount: amount,
      reason: reason,
      levelBefore: levelBefore ?? this.levelBefore,
      levelAfter: levelAfter ?? this.levelAfter,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceType': sourceType,
      'sourceId': sourceId,
      'timestamp': timestamp,
      'skillId': skillId,
      'amount': amount,
      'reason': reason,
      'levelBefore': levelBefore,
      'levelAfter': levelAfter,
    };
  }
}

class CareerFeedback {
  const CareerFeedback({
    required this.date,
    required this.currentJobTitle,
    required this.performanceScore,
    required this.performanceChange,
    required this.careerExperienceGained,
    required this.salaryPaid,
    required this.promotionProgress,
    required this.promotionEligible,
    required this.skillsGained,
    required this.skillLevelUps,
    required this.completedCareerTasks,
    required this.positiveReasons,
    required this.warningReasons,
    required this.recommendedActions,
  });

  factory CareerFeedback.empty() {
    final state = CareerState.initial();
    return CareerFeedback(
      date: '',
      currentJobTitle: state.jobTitle,
      performanceScore: state.performanceScore,
      performanceChange: 0,
      careerExperienceGained: 0,
      salaryPaid: 0,
      promotionProgress: 0,
      promotionEligible: false,
      skillsGained: const <String, int>{},
      skillLevelUps: const <String>[],
      completedCareerTasks: 0,
      positiveReasons: const <String>[],
      warningReasons: const <String>[],
      recommendedActions: const <String>[],
    );
  }

  factory CareerFeedback.fromJson(Map<String, dynamic> json) {
    return CareerFeedback(
      date: json['date']?.toString() ?? '',
      currentJobTitle: json['currentJobTitle']?.toString() ?? '',
      performanceScore: _readInt(json['performanceScore'], fallback: 50)
          .clamp(0, 100)
          .toInt(),
      performanceChange:
          _readInt(json['performanceChange']).clamp(-20, 20).toInt(),
      careerExperienceGained:
          _readInt(json['careerExperienceGained']).clamp(0, 1 << 31).toInt(),
      salaryPaid: _readInt(json['salaryPaid']).clamp(0, 1 << 31).toInt(),
      promotionProgress:
          _readInt(json['promotionProgress']).clamp(0, 100).toInt(),
      promotionEligible: json['promotionEligible'] == true,
      skillsGained: _intMap(json['skillsGained']),
      skillLevelUps: _stringList(json['skillLevelUps']),
      completedCareerTasks: _readInt(json['completedCareerTasks']),
      positiveReasons: _stringList(json['positiveReasons']),
      warningReasons: _stringList(json['warningReasons']),
      recommendedActions: _stringList(json['recommendedActions']),
    );
  }

  final String date;
  final String currentJobTitle;
  final int performanceScore;
  final int performanceChange;
  final int careerExperienceGained;
  final int salaryPaid;
  final int promotionProgress;
  final bool promotionEligible;
  final Map<String, int> skillsGained;
  final List<String> skillLevelUps;
  final int completedCareerTasks;
  final List<String> positiveReasons;
  final List<String> warningReasons;
  final List<String> recommendedActions;

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'currentJobTitle': currentJobTitle,
      'performanceScore': performanceScore,
      'performanceChange': performanceChange,
      'careerExperienceGained': careerExperienceGained,
      'salaryPaid': salaryPaid,
      'promotionProgress': promotionProgress,
      'promotionEligible': promotionEligible,
      'skillsGained': skillsGained,
      'skillLevelUps': skillLevelUps,
      'completedCareerTasks': completedCareerTasks,
      'positiveReasons': positiveReasons,
      'warningReasons': warningReasons,
      'recommendedActions': recommendedActions,
    };
  }
}

String _normalizeLevel(String value) {
  if (careerLevelOrder.contains(value)) return value;
  return 'intern';
}

int _performanceRegression(int current) {
  if (current >= 86) return -2;
  if (current >= 74) return -1;
  if (current <= 24) return 2;
  if (current <= 38) return 1;
  return 0;
}

double _ratio(int value, int target) {
  if (target <= 0) return 1;
  return (value / target).clamp(0, 1).toDouble();
}

List<String> _limitStrings(List<String> values, int max) {
  return values
      .where((item) => item.isNotEmpty)
      .take(max)
      .toList(growable: false);
}

List<SkillExperienceRecord> _limitSkillRecords(
  List<SkillExperienceRecord> values,
  int max,
) {
  return values.take(max).toList(growable: false);
}

Map<String, PlayerSkillState> _normalizedSkills(
  Map<String, PlayerSkillState> values,
) {
  return <String, PlayerSkillState>{
    for (final skillId in playerSkillIds)
      skillId:
          (values[skillId] ?? PlayerSkillState.initial(skillId)).normalized(),
  };
}

Map<String, PlayerSkillState> _skillSummaryFromJson(Object? value) {
  if (value is! Map) {
    return <String, PlayerSkillState>{
      for (final skillId in playerSkillIds)
        skillId: PlayerSkillState.initial(skillId),
    };
  }
  final result = <String, PlayerSkillState>{};
  for (final entry in value.entries) {
    if (entry.value is Map) {
      result[_normalizeSkillId(entry.key.toString())] =
          PlayerSkillState.fromJson(Map<String, dynamic>.from(entry.value));
    }
  }
  return _normalizedSkills(result);
}

Map<String, int> _skillRequirementMap(Object? value) {
  if (value is! Map) return const <String, int>{};
  return value.map(
    (key, amount) => MapEntry(
      _normalizeSkillId(key.toString()),
      _readInt(amount).clamp(1, 10).toInt(),
    ),
  )..removeWhere((key, value) => key.isEmpty);
}

List<Map<String, dynamic>> _listOfMaps(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

Map<String, int> _intMap(Object? value) {
  if (value is! Map) return const <String, int>{};
  return value.map(
    (key, amount) => MapEntry(key.toString(), _readInt(amount)),
  );
}

String _normalizeSkillId(String value) {
  if (playerSkillIds.contains(value)) return value;
  return playerSkillIds.contains(value.toLowerCase())
      ? value.toLowerCase()
      : 'fishing';
}

int _experienceToNext(int level) {
  if (level >= 10) return 0;
  return playerSkillExperienceCurve[level.clamp(1, 10)] ?? 6000;
}

int _skillProgress(int level, int experience) {
  if (level >= 10) return 100;
  final next = _experienceToNext(level);
  if (next <= 0) return 100;
  return (experience / next * 100).clamp(0, 100).round();
}

List<String> _skillMilestones(int level, List<String> existing) {
  final milestones = <String>{...existing};
  if (level >= 2) milestones.add('first_skill_level_up');
  if (level >= 5) milestones.add('skill_level_5');
  if (level >= 10) milestones.add('skill_level_10');
  return milestones.toList(growable: false)..sort();
}

List<String> _recommendedSkillsForLevel(
  String targetLevel,
  Map<String, PlayerSkillState> skills,
) {
  final required =
      CareerPromotionRequirement.forTarget(targetLevel).requiredSkills;
  if (required.isNotEmpty) {
    final missing = required.entries
        .where((entry) =>
            (skills[entry.key] ?? PlayerSkillState.initial(entry.key)).level <
            entry.value)
        .map((entry) => entry.key)
        .toList(growable: false);
    if (missing.isNotEmpty) return missing;
    return required.keys.toList(growable: false);
  }
  return const <String>['fishing', 'communication', 'efficiency'];
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
