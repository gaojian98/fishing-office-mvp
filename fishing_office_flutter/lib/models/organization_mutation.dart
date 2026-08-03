part of 'company_organization.dart';

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
