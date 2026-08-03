import 'company_organization.dart';

const List<String> residentCareerLevelOrder = <String>[
  'trainee',
  'junior',
  'regular',
  'senior',
  'leader',
  'manager',
  'director',
];

const Map<String, String> residentCareerLevelNames = <String, String>{
  'trainee': '试用居民',
  'junior': '初级居民员工',
  'regular': '正式居民员工',
  'senior': '资深居民员工',
  'leader': '小组负责人',
  'manager': '部门负责人',
  'director': '办公室决策者',
};

const Map<String, int> residentCareerBaseSalary = <String, int>{
  'trainee': 80,
  'junior': 120,
  'regular': 180,
  'senior': 260,
  'leader': 360,
  'manager': 520,
  'director': 760,
};

class ResidentCareerStatus {
  const ResidentCareerStatus({
    required this.hireDate,
    required this.careerLevel,
    required this.promotionHistory,
    required this.salaryLevel,
    required this.employmentStatus,
    required this.performanceScore,
    required this.capabilityScore,
    required this.tags,
  });

  const ResidentCareerStatus.empty()
      : hireDate = '',
        careerLevel = '',
        promotionHistory = const <ResidentCareerEvent>[],
        salaryLevel = 0,
        employmentStatus = '',
        performanceScore = 0,
        capabilityScore = 0,
        tags = const <String>[];

  factory ResidentCareerStatus.fromResidentJson(
    Map<String, dynamic> json, {
    required OrganizationAssignment organization,
    required String residentId,
  }) {
    final nested = _mapOf(json['career']);
    final level = _normalizeCareerLevel(
      _firstString(
        nested,
        json,
        const <String>['careerLevel', 'career'],
        fallback: _careerLevelForPosition(organization.positionId),
      ),
    );
    final status = _normalizeEmploymentStatus(
      _firstString(
        nested,
        json,
        const <String>['employmentStatus', 'status'],
        fallback: 'active',
      ),
    );
    final performance = _readInt(
      nested['performanceScore'] ?? json['performanceScore'],
      fallback: _defaultPerformance(json, organization),
    ).clamp(0, 100).toInt();
    final capability = _readInt(
      nested['capabilityScore'] ?? json['capabilityScore'],
      fallback: _defaultCapability(json, organization),
    ).clamp(0, 100).toInt();
    final history = _listOfMaps(nested['promotionHistory'])
        .map(ResidentCareerEvent.fromJson)
        .where((event) => event.type.isNotEmpty)
        .toList(growable: false);
    final hireDate = _firstString(
      nested,
      json,
      const <String>['hireDate', 'joinDate'],
      fallback: _defaultHireDate(residentId),
    );
    return ResidentCareerStatus(
      hireDate: hireDate,
      careerLevel: level,
      promotionHistory: history.isEmpty
          ? <ResidentCareerEvent>[
              ResidentCareerEvent(
                type: 'hire',
                date: hireDate,
                fromPositionId: '',
                toPositionId: organization.positionId,
                fromCareerLevel: '',
                toCareerLevel: level,
                reason: 'default_hire',
              ),
            ]
          : history,
      salaryLevel: _readInt(
        nested['salaryLevel'] ?? json['salaryLevel'],
        fallback: residentCareerBaseSalary[level] ?? 120,
      ).clamp(0, 1 << 31).toInt(),
      employmentStatus: status,
      performanceScore: performance,
      capabilityScore: capability,
      tags: <String>{
        'career:$level',
        'employment:$status',
        'salary:${residentCareerBaseSalary[level] ?? 120}',
        if (organization.isTeamLeader) 'career:leader',
        if (organization.isDepartmentManager) 'career:manager',
        ..._stringList(nested['tags']),
        ..._stringList(json['careerTags']),
      }.where((tag) => !tag.endsWith(':')).toList(growable: false),
    );
  }

  final String hireDate;
  final String careerLevel;
  final List<ResidentCareerEvent> promotionHistory;
  final int salaryLevel;
  final String employmentStatus;
  final int performanceScore;
  final int capabilityScore;
  final List<String> tags;

  bool get isActive =>
      employmentStatus == 'active' ||
      employmentStatus == 'probation' ||
      employmentStatus == 'transferred' ||
      employmentStatus == 'demoted';
  bool get isResigned => employmentStatus == 'resigned';
  int get careerRank =>
      residentCareerLevelOrder.indexOf(careerLevel).clamp(0, 999);
  bool get canBePromoted =>
      isActive && careerRank < residentCareerLevelOrder.length - 1;
  String get displayLevel =>
      residentCareerLevelNames[careerLevel] ??
      residentCareerLevelNames['regular']!;

  String get nextCareerLevel {
    if (!canBePromoted) return careerLevel;
    return residentCareerLevelOrder[careerRank + 1];
  }

  ResidentCareerStatus applyEvent(
    ResidentCareerEvent event, {
    int? salaryLevel,
    int? performanceScore,
    int? capabilityScore,
    List<String> extraTags = const <String>[],
  }) {
    final type = _normalizeCareerEventType(event.type);
    final nextCareerLevel = _normalizeCareerLevel(
      event.toCareerLevel.isEmpty ? careerLevel : event.toCareerLevel,
    );
    final nextStatus = _employmentStatusForEvent(type, employmentStatus);
    final nextSalary = salaryLevel ??
        residentCareerBaseSalary[nextCareerLevel] ??
        this.salaryLevel;
    final nextTags = <String>{
      ...tags.where((tag) =>
          !tag.startsWith('career:') &&
          !tag.startsWith('employment:') &&
          !tag.startsWith('salary:')),
      'career:$nextCareerLevel',
      'employment:$nextStatus',
      'salary:$nextSalary',
      if (type.isNotEmpty) 'career_event:$type',
      ...extraTags,
    }.where((tag) => tag.isNotEmpty && !tag.endsWith(':')).toList();
    return ResidentCareerStatus(
      hireDate: hireDate.isEmpty && type == 'hire' ? event.date : hireDate,
      careerLevel: nextCareerLevel,
      promotionHistory: <ResidentCareerEvent>[
        ...promotionHistory,
        event,
      ],
      salaryLevel: nextSalary,
      employmentStatus: nextStatus,
      performanceScore:
          (performanceScore ?? this.performanceScore).clamp(0, 100).toInt(),
      capabilityScore:
          (capabilityScore ?? this.capabilityScore).clamp(0, 100).toInt(),
      tags: nextTags,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'hireDate': hireDate,
      'careerLevel': careerLevel,
      'promotionHistory':
          promotionHistory.map((event) => event.toJson()).toList(),
      'salaryLevel': salaryLevel,
      'employmentStatus': employmentStatus,
      'performanceScore': performanceScore,
      'capabilityScore': capabilityScore,
      'tags': tags,
    };
  }
}

String _employmentStatusForEvent(String type, String fallback) {
  switch (type) {
    case 'hire':
      return 'active';
    case 'promotion':
      return 'active';
    case 'transfer':
      return 'transferred';
    case 'demotion':
      return 'demoted';
    case 'resignation':
      return 'resigned';
    case 'recruitment':
      return 'recruiting';
    default:
      return _normalizeEmploymentStatus(fallback);
  }
}

class ResidentCareerEvent {
  const ResidentCareerEvent({
    required this.type,
    required this.date,
    required this.fromPositionId,
    required this.toPositionId,
    required this.fromCareerLevel,
    required this.toCareerLevel,
    required this.reason,
  });

  factory ResidentCareerEvent.fromJson(Map<String, dynamic> json) {
    return ResidentCareerEvent(
      type: _normalizeCareerEventType(json['type']?.toString() ?? ''),
      date: json['date']?.toString() ?? '',
      fromPositionId: json['fromPositionId']?.toString() ?? '',
      toPositionId: json['toPositionId']?.toString() ?? '',
      fromCareerLevel: _normalizeCareerLevel(
        json['fromCareerLevel']?.toString() ?? '',
      ),
      toCareerLevel: _normalizeCareerLevel(
        json['toCareerLevel']?.toString() ?? '',
      ),
      reason: json['reason']?.toString() ?? '',
    );
  }

  final String type;
  final String date;
  final String fromPositionId;
  final String toPositionId;
  final String fromCareerLevel;
  final String toCareerLevel;
  final String reason;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'date': date,
      'fromPositionId': fromPositionId,
      'toPositionId': toPositionId,
      'fromCareerLevel': fromCareerLevel,
      'toCareerLevel': toCareerLevel,
      'reason': reason,
    };
  }
}

class RecruitmentNeed {
  const RecruitmentNeed({
    required this.departmentId,
    required this.teamId,
    required this.positionId,
    required this.vacancyCount,
    required this.priority,
    required this.reason,
    required this.tags,
  });

  final String departmentId;
  final String teamId;
  final String positionId;
  final int vacancyCount;
  final int priority;
  final String reason;
  final List<String> tags;
}

class PromotionCandidate {
  const PromotionCandidate({
    required this.residentId,
    required this.departmentId,
    required this.teamId,
    required this.currentPositionId,
    required this.targetPositionId,
    required this.currentCareerLevel,
    required this.targetCareerLevel,
    required this.score,
    required this.reason,
  });

  final String residentId;
  final String departmentId;
  final String teamId;
  final String currentPositionId;
  final String targetPositionId;
  final String currentCareerLevel;
  final String targetCareerLevel;
  final int score;
  final String reason;
}

String _careerLevelForPosition(String positionId) {
  switch (positionId) {
    case 'director':
      return 'director';
    case 'department_manager':
      return 'manager';
    case 'team_leader':
      return 'leader';
    case 'specialist':
      return 'senior';
    case 'staff':
    default:
      return 'regular';
  }
}

String _normalizeCareerLevel(String value) {
  final normalized = value.trim().toLowerCase();
  if (residentCareerLevelOrder.contains(normalized)) return normalized;
  switch (normalized) {
    case 'intern':
    case 'probation':
    case 'trainee_employee':
      return 'trainee';
    case 'junior_employee':
      return 'junior';
    case 'employee':
    case 'staff':
      return 'regular';
    case 'senior_employee':
    case 'specialist':
      return 'senior';
    case 'team_lead':
    case 'team_leader':
      return 'leader';
    case 'department_manager':
    case 'senior_manager':
      return 'manager';
    default:
      return 'regular';
  }
}

String _normalizeEmploymentStatus(String value) {
  final normalized = value.trim().toLowerCase();
  switch (normalized) {
    case 'probation':
    case 'active':
    case 'transferred':
    case 'demoted':
    case 'resigned':
    case 'recruiting':
      return normalized;
    case 'leave':
    case 'left':
    case 'resignation':
      return 'resigned';
    default:
      return 'active';
  }
}

String _normalizeCareerEventType(String value) {
  final normalized = value.trim().toLowerCase();
  switch (normalized) {
    case 'hire':
    case 'promotion':
    case 'transfer':
    case 'demotion':
    case 'resignation':
    case 'recruitment':
      return normalized;
    default:
      return normalized;
  }
}

String _defaultHireDate(String residentId) {
  final seed = residentId.codeUnits.fold<int>(0, (sum, item) => sum + item);
  final month = (seed % 12) + 1;
  final day = (seed % 27) + 1;
  return 'Y1-M${month.toString().padLeft(2, '0')}-D${day.toString().padLeft(2, '0')}';
}

int _defaultPerformance(
  Map<String, dynamic> json,
  OrganizationAssignment organization,
) {
  var score = 48 + organization.positionId.length % 18;
  final text = _residentText(json);
  if (text.contains('主管') || text.contains('经理') || text.contains('老板')) {
    score += 18;
  }
  if (text.contains('维修') || text.contains('专员') || text.contains('工程')) {
    score += 10;
  }
  if (text.contains('迟到')) score -= 8;
  if (text.contains('午睡')) score -= 4;
  return score;
}

int _defaultCapability(
  Map<String, dynamic> json,
  OrganizationAssignment organization,
) {
  var score = 46 + organization.departmentId.length % 20;
  final text = _residentText(json);
  if (text.contains('主管') || text.contains('经理') || text.contains('老板')) {
    score += 20;
  }
  if (text.contains('维修') || text.contains('技术') || text.contains('老渔夫')) {
    score += 12;
  }
  if (text.contains('前台') || text.contains('文件')) score += 6;
  return score;
}

Map<String, dynamic> _mapOf(Object? value) {
  if (value is! Map) return const <String, dynamic>{};
  return Map<String, dynamic>.from(value);
}

List<Map<String, dynamic>> _listOfMaps(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

String _firstString(
  Map<String, dynamic> nested,
  Map<String, dynamic> root,
  List<String> keys, {
  required String fallback,
}) {
  for (final key in keys) {
    final nestedValue = nested[key];
    if (nestedValue != null && nestedValue.toString().isNotEmpty) {
      return nestedValue.toString();
    }
    final rootValue = root[key];
    if (rootValue != null && rootValue.toString().isNotEmpty) {
      return rootValue.toString();
    }
  }
  return fallback;
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
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

String _residentText(Map<String, dynamic> json) {
  return [
    json['name'],
    json['nickname'],
    json['job'],
    json['role'],
    json['personality'],
    json['workplace'],
    json['description'],
  ].whereType<Object>().map((item) => item.toString()).join('|');
}
