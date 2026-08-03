import 'resident_career.dart';

const int officeEconomyHistoryLimit = 90;

class OfficeEconomyState {
  const OfficeEconomyState({
    required this.companyId,
    required this.companyBudget,
    required this.departmentBudgets,
    required this.departmentCosts,
    required this.departmentIncome,
    required this.payrollTotal,
    required this.bonusTotal,
    required this.operatingCostTotal,
    required this.projectIncomeTotal,
    required this.settledSettlementIds,
    required this.history,
    required this.budgetWarnings,
    required this.lastSettlementId,
  });

  const OfficeEconomyState.empty()
      : companyId = 'fishing_office',
        companyBudget = 0,
        departmentBudgets = const <String, int>{},
        departmentCosts = const <String, int>{},
        departmentIncome = const <String, int>{},
        payrollTotal = 0,
        bonusTotal = 0,
        operatingCostTotal = 0,
        projectIncomeTotal = 0,
        settledSettlementIds = const <String>[],
        history = const <OfficeEconomyRecord>[],
        budgetWarnings = const <String>[],
        lastSettlementId = '';

  factory OfficeEconomyState.fromJson(Map<String, dynamic> json) {
    final records = _listOfMaps(json['history'])
        .map(OfficeEconomyRecord.fromJson)
        .where((record) => record.settlementId.isNotEmpty)
        .toList(growable: false);
    return OfficeEconomyState(
      companyId: json['companyId']?.toString() ?? 'fishing_office',
      companyBudget: _readInt(json['companyBudget']),
      departmentBudgets: _intMap(json['departmentBudgets']),
      departmentCosts: _intMap(json['departmentCosts']),
      departmentIncome: _intMap(json['departmentIncome']),
      payrollTotal: _readInt(json['payrollTotal']),
      bonusTotal: _readInt(json['bonusTotal']),
      operatingCostTotal: _readInt(json['operatingCostTotal']),
      projectIncomeTotal: _readInt(json['projectIncomeTotal']),
      settledSettlementIds: _stringList(json['settledSettlementIds']),
      history: records.take(officeEconomyHistoryLimit).toList(growable: false),
      budgetWarnings: _stringList(json['budgetWarnings']),
      lastSettlementId: json['lastSettlementId']?.toString() ?? '',
    ).normalized();
  }

  final String companyId;
  final int companyBudget;
  final Map<String, int> departmentBudgets;
  final Map<String, int> departmentCosts;
  final Map<String, int> departmentIncome;
  final int payrollTotal;
  final int bonusTotal;
  final int operatingCostTotal;
  final int projectIncomeTotal;
  final List<String> settledSettlementIds;
  final List<OfficeEconomyRecord> history;
  final List<String> budgetWarnings;
  final String lastSettlementId;

  bool hasSettled(String settlementId) =>
      settledSettlementIds.contains(settlementId);

  OfficeEconomyState normalized() {
    final historyTrimmed =
        history.take(officeEconomyHistoryLimit).toList(growable: false);
    final ids = <String>{
      ...settledSettlementIds.where((id) => id.isNotEmpty),
      ...historyTrimmed.map((record) => record.settlementId),
    }.toList(growable: false)
      ..sort();
    return copyWith(
      companyBudget: companyBudget.clamp(0, 1 << 31).toInt(),
      payrollTotal: payrollTotal.clamp(0, 1 << 31).toInt(),
      bonusTotal: bonusTotal.clamp(0, 1 << 31).toInt(),
      operatingCostTotal: operatingCostTotal.clamp(0, 1 << 31).toInt(),
      projectIncomeTotal: projectIncomeTotal.clamp(0, 1 << 31).toInt(),
      departmentBudgets: _normalizeIntMap(departmentBudgets),
      departmentCosts: _normalizeIntMap(departmentCosts),
      departmentIncome: _normalizeIntMap(departmentIncome),
      settledSettlementIds: ids,
      history: historyTrimmed,
      budgetWarnings:
          budgetWarnings.where((warning) => warning.isNotEmpty).toList(),
    );
  }

  OfficeEconomyState applyRecord(OfficeEconomyRecord record) {
    if (record.settlementId.isEmpty || hasSettled(record.settlementId)) {
      return this;
    }
    final nextDepartmentBudgets = Map<String, int>.from(departmentBudgets);
    final nextDepartmentCosts = Map<String, int>.from(departmentCosts);
    final nextDepartmentIncome = Map<String, int>.from(departmentIncome);
    if (record.departmentId.isNotEmpty) {
      nextDepartmentCosts[record.departmentId] =
          (nextDepartmentCosts[record.departmentId] ?? 0) + record.totalCost;
      nextDepartmentIncome[record.departmentId] =
          (nextDepartmentIncome[record.departmentId] ?? 0) +
              record.projectIncome;
      nextDepartmentBudgets[record.departmentId] =
          (nextDepartmentBudgets[record.departmentId] ?? 0) +
              record.projectIncome -
              record.totalCost;
    }
    final nextBudget = companyBudget + record.projectIncome - record.totalCost;
    final nextWarnings = <String>{
      ...budgetWarnings,
      if (record.departmentId.isNotEmpty &&
          (nextDepartmentBudgets[record.departmentId] ?? 0) < 0)
        'budget_warning:${record.departmentId}',
      if (nextBudget < 1200) 'company_budget_low',
    }.toList(growable: false);
    return copyWith(
      companyBudget: nextBudget,
      departmentBudgets: nextDepartmentBudgets,
      departmentCosts: nextDepartmentCosts,
      departmentIncome: nextDepartmentIncome,
      payrollTotal: payrollTotal + record.payroll,
      bonusTotal: bonusTotal + record.bonus,
      operatingCostTotal: operatingCostTotal + record.operatingCost,
      projectIncomeTotal: projectIncomeTotal + record.projectIncome,
      settledSettlementIds: <String>[
        ...settledSettlementIds,
        record.settlementId,
      ],
      history: <OfficeEconomyRecord>[
        record,
        ...history,
      ].take(officeEconomyHistoryLimit).toList(growable: false),
      budgetWarnings: nextWarnings,
      lastSettlementId: record.settlementId,
    ).normalized();
  }

  OfficeEconomyState copyWith({
    String? companyId,
    int? companyBudget,
    Map<String, int>? departmentBudgets,
    Map<String, int>? departmentCosts,
    Map<String, int>? departmentIncome,
    int? payrollTotal,
    int? bonusTotal,
    int? operatingCostTotal,
    int? projectIncomeTotal,
    List<String>? settledSettlementIds,
    List<OfficeEconomyRecord>? history,
    List<String>? budgetWarnings,
    String? lastSettlementId,
  }) {
    return OfficeEconomyState(
      companyId: companyId ?? this.companyId,
      companyBudget: companyBudget ?? this.companyBudget,
      departmentBudgets: departmentBudgets ?? this.departmentBudgets,
      departmentCosts: departmentCosts ?? this.departmentCosts,
      departmentIncome: departmentIncome ?? this.departmentIncome,
      payrollTotal: payrollTotal ?? this.payrollTotal,
      bonusTotal: bonusTotal ?? this.bonusTotal,
      operatingCostTotal: operatingCostTotal ?? this.operatingCostTotal,
      projectIncomeTotal: projectIncomeTotal ?? this.projectIncomeTotal,
      settledSettlementIds: settledSettlementIds ?? this.settledSettlementIds,
      history: history ?? this.history,
      budgetWarnings: budgetWarnings ?? this.budgetWarnings,
      lastSettlementId: lastSettlementId ?? this.lastSettlementId,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'companyId': companyId,
      'companyBudget': companyBudget,
      'departmentBudgets': departmentBudgets,
      'departmentCosts': departmentCosts,
      'departmentIncome': departmentIncome,
      'payrollTotal': payrollTotal,
      'bonusTotal': bonusTotal,
      'operatingCostTotal': operatingCostTotal,
      'projectIncomeTotal': projectIncomeTotal,
      'settledSettlementIds': settledSettlementIds,
      'history': history.map((record) => record.toJson()).toList(),
      'budgetWarnings': budgetWarnings,
      'lastSettlementId': lastSettlementId,
    };
  }
}

class OfficeEconomyRecord {
  const OfficeEconomyRecord({
    required this.settlementId,
    required this.periodType,
    required this.periodKey,
    required this.departmentId,
    required this.residentIds,
    required this.payroll,
    required this.bonus,
    required this.operatingCost,
    required this.projectIncome,
    required this.reason,
    required this.createdAt,
  });

  factory OfficeEconomyRecord.fromJson(Map<String, dynamic> json) {
    return OfficeEconomyRecord(
      settlementId: json['settlementId']?.toString() ?? '',
      periodType: json['periodType']?.toString() ?? '',
      periodKey: json['periodKey']?.toString() ?? '',
      departmentId: json['departmentId']?.toString() ?? '',
      residentIds: _stringList(json['residentIds']),
      payroll: _readInt(json['payroll']),
      bonus: _readInt(json['bonus']),
      operatingCost: _readInt(json['operatingCost']),
      projectIncome: _readInt(json['projectIncome']),
      reason: json['reason']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  final String settlementId;
  final String periodType;
  final String periodKey;
  final String departmentId;
  final List<String> residentIds;
  final int payroll;
  final int bonus;
  final int operatingCost;
  final int projectIncome;
  final String reason;
  final String createdAt;

  int get totalCost => payroll + bonus + operatingCost;
  int get netChange => projectIncome - totalCost;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'settlementId': settlementId,
      'periodType': periodType,
      'periodKey': periodKey,
      'departmentId': departmentId,
      'residentIds': residentIds,
      'payroll': payroll,
      'bonus': bonus,
      'operatingCost': operatingCost,
      'projectIncome': projectIncome,
      'reason': reason,
      'createdAt': createdAt,
      'netChange': netChange,
    };
  }
}

class OfficeEconomySettlementResult {
  const OfficeEconomySettlementResult({
    required this.success,
    required this.idempotent,
    required this.record,
    required this.state,
    required this.errors,
  });

  const OfficeEconomySettlementResult.failure(this.errors)
      : success = false,
        idempotent = false,
        record = null,
        state = const OfficeEconomyState.empty();

  final bool success;
  final bool idempotent;
  final OfficeEconomyRecord? record;
  final OfficeEconomyState state;
  final List<String> errors;
}

int salaryForCareer(ResidentCareerStatus career) {
  if (!career.isActive) return 0;
  if (career.salaryLevel > 0) return career.salaryLevel;
  return residentCareerBaseSalary[career.careerLevel] ?? 120;
}

List<Map<String, dynamic>> _listOfMaps(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
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

Map<String, int> _intMap(Object? value) {
  if (value is! Map) return const <String, int>{};
  return value.map((key, value) => MapEntry(key.toString(), _readInt(value)));
}

Map<String, int> _normalizeIntMap(Map<String, int> value) {
  return value.map(
    (key, value) => MapEntry(key, value.clamp(0, 1 << 31).toInt()),
  );
}
