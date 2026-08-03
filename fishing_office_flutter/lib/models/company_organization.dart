class CompanyOrganization {
  const CompanyOrganization({
    required this.companies,
    required this.departments,
    required this.teams,
    required this.positions,
  });

  factory CompanyOrganization.defaultStructure() {
    return const CompanyOrganization(
      companies: <Company>[
        Company(
          id: 'fishing_office',
          name: '上班摸鱼有限公司',
          description: '一间靠近海风、咖啡和鱼漂运行的小公司。',
        ),
      ],
      departments: <Department>[
        Department(
          id: 'management',
          companyId: 'fishing_office',
          name: '管理部',
          managerPositionId: 'department_manager',
        ),
        Department(
          id: 'operations',
          companyId: 'fishing_office',
          name: '运营部',
          managerPositionId: 'department_manager',
        ),
        Department(
          id: 'technology',
          companyId: 'fishing_office',
          name: '技术部',
          managerPositionId: 'department_manager',
        ),
        Department(
          id: 'front_office',
          companyId: 'fishing_office',
          name: '前台与行政部',
          managerPositionId: 'department_manager',
        ),
        Department(
          id: 'commerce',
          companyId: 'fishing_office',
          name: '商业与后勤部',
          managerPositionId: 'department_manager',
        ),
      ],
      teams: <Team>[
        Team(
          id: 'office_admin',
          departmentId: 'front_office',
          name: '办公室行政组',
          leaderPositionId: 'team_leader',
        ),
        Team(
          id: 'product_ops',
          departmentId: 'operations',
          name: '产品运营组',
          leaderPositionId: 'team_leader',
        ),
        Team(
          id: 'tech_support',
          departmentId: 'technology',
          name: '技术支持组',
          leaderPositionId: 'team_leader',
        ),
        Team(
          id: 'dock_services',
          departmentId: 'operations',
          name: '码头服务组',
          leaderPositionId: 'team_leader',
        ),
        Team(
          id: 'market_services',
          departmentId: 'commerce',
          name: '商业服务组',
          leaderPositionId: 'team_leader',
        ),
        Team(
          id: 'office_management',
          departmentId: 'management',
          name: '办公室管理组',
          leaderPositionId: 'team_leader',
        ),
      ],
      positions: <Position>[
        Position(
          id: 'staff',
          name: '居民员工',
          level: 1,
          rank: 'staff',
        ),
        Position(
          id: 'specialist',
          name: '专员',
          level: 2,
          rank: 'specialist',
        ),
        Position(
          id: 'team_leader',
          name: '小组长',
          level: 3,
          rank: 'team_leader',
        ),
        Position(
          id: 'department_manager',
          name: '部门经理',
          level: 4,
          rank: 'department_manager',
        ),
        Position(
          id: 'director',
          name: '主管',
          level: 5,
          rank: 'director',
        ),
      ],
    );
  }

  final List<Company> companies;
  final List<Department> departments;
  final List<Team> teams;
  final List<Position> positions;

  bool hasCompany(String id) => companies.any((item) => item.id == id);
  bool hasDepartment(String id) => departments.any((item) => item.id == id);
  bool hasTeam(String id) => teams.any((item) => item.id == id);
  bool hasPosition(String id) => positions.any((item) => item.id == id);

  Company findCompany(String id) {
    return companies.firstWhere(
      (item) => item.id == id,
      orElse: () => companies.first,
    );
  }

  Department findDepartment(String id) {
    return departments.firstWhere(
      (item) => item.id == id,
      orElse: () => departments.first,
    );
  }

  Team findTeam(String id) {
    return teams.firstWhere(
      (item) => item.id == id,
      orElse: () => teams.first,
    );
  }

  Position findPosition(String id) {
    return positions.firstWhere(
      (item) => item.id == id,
      orElse: () => positions.first,
    );
  }
}

class Company {
  const Company({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}

class Department {
  const Department({
    required this.id,
    required this.companyId,
    required this.name,
    required this.managerPositionId,
  });

  final String id;
  final String companyId;
  final String name;
  final String managerPositionId;
}

class Team {
  const Team({
    required this.id,
    required this.departmentId,
    required this.name,
    required this.leaderPositionId,
  });

  final String id;
  final String departmentId;
  final String name;
  final String leaderPositionId;
}

class Position {
  const Position({
    required this.id,
    required this.name,
    required this.level,
    required this.rank,
  });

  final String id;
  final String name;
  final int level;
  final String rank;

  bool get isTeamLeader => id == 'team_leader' || level >= 3;
  bool get isDepartmentManager => id == 'department_manager' || level >= 4;
}

class OrganizationAssignment {
  const OrganizationAssignment({
    required this.companyId,
    required this.departmentId,
    required this.teamId,
    required this.positionId,
    this.tags = const <String>[],
    this.active = true,
  });

  const OrganizationAssignment.empty()
      : companyId = '',
        departmentId = '',
        teamId = '',
        positionId = '',
        tags = const <String>[],
        active = false;

  factory OrganizationAssignment.fromResidentJson(
    Map<String, dynamic> json, {
    required String residentId,
  }) {
    final nested = _mapOf(json['organization']);
    final companyId = _firstString(
      nested,
      json,
      const <String>['companyId', 'company'],
      fallback: 'fishing_office',
    );
    final departmentId = _firstString(
      nested,
      json,
      const <String>['departmentId', 'department'],
      fallback: _deriveDepartment(json),
    );
    final teamId = _firstString(
      nested,
      json,
      const <String>['teamId', 'team'],
      fallback: _deriveTeam(json, departmentId),
    );
    final positionId = _firstString(
      nested,
      json,
      const <String>['positionId', 'position'],
      fallback: _derivePosition(json, residentId),
    );
    return OrganizationAssignment(
      companyId: companyId,
      departmentId: departmentId,
      teamId: teamId,
      positionId: positionId,
      tags: <String>{
        'company:$companyId',
        'department:$departmentId',
        'team:$teamId',
        'position:$positionId',
        ..._stringList(nested['tags']),
        ..._stringList(json['organizationTags']),
      }.where((item) => !item.endsWith(':')).toList(growable: false),
      active: _readBool(
        nested['active'] ?? json['organizationActive'],
        fallback: true,
      ),
    );
  }

  factory OrganizationAssignment.fromJson(Map<String, dynamic> json) {
    final companyId = json['companyId']?.toString() ?? '';
    final departmentId = json['departmentId']?.toString() ?? '';
    final teamId = json['teamId']?.toString() ?? '';
    final positionId = json['positionId']?.toString() ?? '';
    if (companyId.isEmpty ||
        departmentId.isEmpty ||
        teamId.isEmpty ||
        positionId.isEmpty) {
      return const OrganizationAssignment.empty();
    }
    return OrganizationAssignment(
      companyId: companyId,
      departmentId: departmentId,
      teamId: teamId,
      positionId: positionId,
      tags: <String>{
        'company:$companyId',
        'department:$departmentId',
        'team:$teamId',
        'position:$positionId',
        ..._stringList(json['tags']),
      }.where((item) => !item.endsWith(':')).toList(growable: false),
      active: _readBool(json['active'], fallback: true),
    );
  }

  final String companyId;
  final String departmentId;
  final String teamId;
  final String positionId;
  final List<String> tags;
  final bool active;

  bool get isAssigned => active && companyId.isNotEmpty;

  bool get isTeamLeader =>
      positionId == 'team_leader' ||
      positionId == 'department_manager' ||
      positionId == 'director';

  bool get isDepartmentManager =>
      positionId == 'department_manager' || positionId == 'director';

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'companyId': companyId,
      'departmentId': departmentId,
      'teamId': teamId,
      'positionId': positionId,
      'tags': tags,
      'active': active,
    };
  }

  OrganizationAssignment copyWith({
    String? companyId,
    String? departmentId,
    String? teamId,
    String? positionId,
    List<String>? tags,
    bool? active,
  }) {
    final nextCompanyId = companyId ?? this.companyId;
    final nextDepartmentId = departmentId ?? this.departmentId;
    final nextTeamId = teamId ?? this.teamId;
    final nextPositionId = positionId ?? this.positionId;
    return OrganizationAssignment(
      companyId: nextCompanyId,
      departmentId: nextDepartmentId,
      teamId: nextTeamId,
      positionId: nextPositionId,
      tags: tags ??
          <String>{
            'company:$nextCompanyId',
            'department:$nextDepartmentId',
            'team:$nextTeamId',
            'position:$nextPositionId',
            ...this.tags.where((tag) =>
                !tag.startsWith('company:') &&
                !tag.startsWith('department:') &&
                !tag.startsWith('team:') &&
                !tag.startsWith('position:')),
          }.where((item) => !item.endsWith(':')).toList(growable: false),
      active: active ?? this.active,
    );
  }
}

class OrganizationMutationRequest {
  const OrganizationMutationRequest({
    required this.residentId,
    required this.mutationType,
    required this.targetCompanyId,
    required this.targetDepartmentId,
    required this.targetTeamId,
    required this.targetPositionId,
    required this.reason,
    required this.effectiveDate,
    required this.sourceId,
    this.targetReportsToResidentId = '',
    this.targetCareerLevel = '',
  });

  final String residentId;
  final String mutationType;
  final String targetCompanyId;
  final String targetDepartmentId;
  final String targetTeamId;
  final String targetPositionId;
  final String reason;
  final String effectiveDate;
  final String sourceId;
  final String targetReportsToResidentId;
  final String targetCareerLevel;
}

class OrganizationMutationResult {
  const OrganizationMutationResult({
    required this.success,
    required this.idempotent,
    required this.errors,
    required this.record,
    required this.assignment,
  });

  factory OrganizationMutationResult.failure(List<String> errors) {
    return OrganizationMutationResult(
      success: false,
      idempotent: false,
      errors: errors,
      record: null,
      assignment: const OrganizationAssignment.empty(),
    );
  }

  final bool success;
  final bool idempotent;
  final List<String> errors;
  final OrganizationMutationRecord? record;
  final OrganizationAssignment assignment;
}

class OrganizationMutationRecord {
  const OrganizationMutationRecord({
    required this.residentId,
    required this.previousCompanyId,
    required this.previousDepartmentId,
    required this.previousTeamId,
    required this.previousPositionId,
    required this.targetCompanyId,
    required this.targetDepartmentId,
    required this.targetTeamId,
    required this.targetPositionId,
    required this.mutationType,
    required this.reason,
    required this.effectiveDate,
    required this.sourceId,
    this.previousReportsToResidentId = '',
    this.targetReportsToResidentId = '',
  });

  factory OrganizationMutationRecord.fromJson(Map<String, dynamic> json) {
    return OrganizationMutationRecord(
      residentId: json['residentId']?.toString() ?? '',
      previousCompanyId: json['previousCompanyId']?.toString() ?? '',
      previousDepartmentId: json['previousDepartmentId']?.toString() ?? '',
      previousTeamId: json['previousTeamId']?.toString() ?? '',
      previousPositionId: json['previousPositionId']?.toString() ?? '',
      targetCompanyId: json['targetCompanyId']?.toString() ?? '',
      targetDepartmentId: json['targetDepartmentId']?.toString() ?? '',
      targetTeamId: json['targetTeamId']?.toString() ?? '',
      targetPositionId: json['targetPositionId']?.toString() ?? '',
      mutationType: json['mutationType']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      effectiveDate: json['effectiveDate']?.toString() ?? '',
      sourceId: json['sourceId']?.toString() ?? '',
      previousReportsToResidentId:
          json['previousReportsToResidentId']?.toString() ?? '',
      targetReportsToResidentId:
          json['targetReportsToResidentId']?.toString() ?? '',
    );
  }

  final String residentId;
  final String previousCompanyId;
  final String previousDepartmentId;
  final String previousTeamId;
  final String previousPositionId;
  final String targetCompanyId;
  final String targetDepartmentId;
  final String targetTeamId;
  final String targetPositionId;
  final String mutationType;
  final String reason;
  final String effectiveDate;
  final String sourceId;
  final String previousReportsToResidentId;
  final String targetReportsToResidentId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'residentId': residentId,
      'previousCompanyId': previousCompanyId,
      'previousDepartmentId': previousDepartmentId,
      'previousTeamId': previousTeamId,
      'previousPositionId': previousPositionId,
      'targetCompanyId': targetCompanyId,
      'targetDepartmentId': targetDepartmentId,
      'targetTeamId': targetTeamId,
      'targetPositionId': targetPositionId,
      'mutationType': mutationType,
      'reason': reason,
      'effectiveDate': effectiveDate,
      'sourceId': sourceId,
      'previousReportsToResidentId': previousReportsToResidentId,
      'targetReportsToResidentId': targetReportsToResidentId,
    };
  }
}

class ResidentOrganizationContext {
  const ResidentOrganizationContext({
    required this.assignment,
    required this.company,
    required this.department,
    required this.team,
    required this.position,
  });

  factory ResidentOrganizationContext.empty() {
    final organization = CompanyOrganization.defaultStructure();
    return ResidentOrganizationContext(
      assignment: const OrganizationAssignment.empty(),
      company: organization.companies.first,
      department: organization.departments.first,
      team: organization.teams.first,
      position: organization.positions.first,
    );
  }

  factory ResidentOrganizationContext.resolve(
    OrganizationAssignment assignment, {
    CompanyOrganization organization = const CompanyOrganization(
      companies: <Company>[
        Company(
          id: 'fishing_office',
          name: '上班摸鱼有限公司',
          description: '一间靠近海风、咖啡和鱼漂运行的小公司。',
        ),
      ],
      departments: <Department>[
        Department(
          id: 'management',
          companyId: 'fishing_office',
          name: '管理部',
          managerPositionId: 'department_manager',
        ),
      ],
      teams: <Team>[
        Team(
          id: 'office_management',
          departmentId: 'management',
          name: '办公室管理组',
          leaderPositionId: 'team_leader',
        ),
      ],
      positions: <Position>[
        Position(
          id: 'staff',
          name: '居民员工',
          level: 1,
          rank: 'staff',
        ),
      ],
    ),
  }) {
    return ResidentOrganizationContext(
      assignment: assignment,
      company: organization.findCompany(assignment.companyId),
      department: organization.findDepartment(assignment.departmentId),
      team: organization.findTeam(assignment.teamId),
      position: organization.findPosition(assignment.positionId),
    );
  }

  final OrganizationAssignment assignment;
  final Company company;
  final Department department;
  final Team team;
  final Position position;

  String get companyId => assignment.companyId;
  String get departmentId => assignment.departmentId;
  String get teamId => assignment.teamId;
  String get positionId => assignment.positionId;
  bool get isTeamLeader => assignment.isTeamLeader;
  bool get isDepartmentManager => assignment.isDepartmentManager;
  List<String> get tags => assignment.tags;
}

Map<String, dynamic> _mapOf(Object? value) {
  if (value is! Map) return const <String, dynamic>{};
  return Map<String, dynamic>.from(value);
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

bool _readBool(Object? value, {required bool fallback}) {
  if (value is bool) return value;
  final text = value?.toString().trim().toLowerCase() ?? '';
  if (text == 'true' || text == '1' || text == 'yes') return true;
  if (text == 'false' || text == '0' || text == 'no') return false;
  return fallback;
}

String _deriveDepartment(Map<String, dynamic> json) {
  final text = _residentText(json);
  if (text.contains('维修') || text.contains('技术') || text.contains('电脑')) {
    return 'technology';
  }
  if (text.contains('前台') || text.contains('行政') || text.contains('文件')) {
    return 'front_office';
  }
  if (text.contains('老板') ||
      text.contains('主管') ||
      text.contains('经理') ||
      text.contains('管理')) {
    return 'management';
  }
  if (text.contains('咖啡') ||
      text.contains('商店') ||
      text.contains('便利') ||
      text.contains('市场') ||
      text.contains('银行')) {
    return 'commerce';
  }
  return 'operations';
}

String _deriveTeam(Map<String, dynamic> json, String departmentId) {
  final text = _residentText(json);
  if (text.contains('码头') || text.contains('海边') || text.contains('渔')) {
    return 'dock_services';
  }
  if (departmentId == 'technology') return 'tech_support';
  if (departmentId == 'front_office') return 'office_admin';
  if (departmentId == 'commerce') return 'market_services';
  if (departmentId == 'management') return 'office_management';
  return 'product_ops';
}

String _derivePosition(Map<String, dynamic> json, String residentId) {
  final text = _residentText(json);
  if (text.contains('老板') || text.contains('主管') || text.contains('总监')) {
    return 'director';
  }
  if (text.contains('经理') || text.contains('店长')) {
    return 'department_manager';
  }
  if (text.contains('组长') || text.contains('队长') || residentId.endsWith('0')) {
    return 'team_leader';
  }
  if (text.contains('专员') || text.contains('工程') || text.contains('维修')) {
    return 'specialist';
  }
  return 'staff';
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
