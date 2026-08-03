import 'company_organization.dart';
import 'resident_career.dart';

class ResidentConfig {
  const ResidentConfig({
    required this.version,
    required this.residents,
  });

  factory ResidentConfig.fromJson(Map<String, dynamic> json) {
    return ResidentConfig(
      version: json['version']?.toString() ?? '1.0',
      residents: _listOfMaps(json['residents'])
          .map(ResidentProfile.fromJson)
          .toList(growable: false),
    );
  }

  final String version;
  final List<ResidentProfile> residents;

  ResidentProfile findResident(String id) {
    for (final resident in residents) {
      if (resident.id == id) return resident;
    }
    return ResidentProfile.empty(id);
  }
}

class ResidentProfile {
  const ResidentProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.personality,
    required this.dialogGroup,
    required this.mood,
    required this.friendship,
    required this.unlockLevel,
    required this.location,
    required this.organization,
    required this.career,
    required this.enabled,
    required this.raw,
  });

  factory ResidentProfile.empty(String id) {
    return ResidentProfile(
      id: id,
      name: id,
      type: '',
      personality: '',
      dialogGroup: '',
      mood: '',
      friendship: 0,
      unlockLevel: 0,
      location: '',
      organization: const OrganizationAssignment.empty(),
      career: const ResidentCareerStatus.empty(),
      enabled: false,
      raw: const <String, dynamic>{},
    );
  }

  factory ResidentProfile.fromJson(Map<String, dynamic> json) {
    final organization = OrganizationAssignment.fromResidentJson(
      json,
      residentId: json['id']?.toString() ?? '',
    );
    return ResidentProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      personality: json['personality']?.toString() ?? '',
      dialogGroup: json['dialogGroup']?.toString() ?? '',
      mood: json['mood']?.toString() ?? '',
      friendship: _readInt(json['friendship']),
      unlockLevel: _readInt(json['unlockLevel']),
      location: json['location']?.toString() ?? '',
      organization: organization,
      career: ResidentCareerStatus.fromResidentJson(
        json,
        organization: organization,
        residentId: json['id']?.toString() ?? '',
      ),
      enabled: json['enabled'] is bool ? json['enabled'] as bool : true,
      raw: Map<String, dynamic>.from(json),
    );
  }

  final String id;
  final String name;
  final String type;
  final String personality;
  final String dialogGroup;
  final String mood;
  final int friendship;
  final int unlockLevel;
  final String location;
  final OrganizationAssignment organization;
  final ResidentCareerStatus career;
  final bool enabled;
  final Map<String, dynamic> raw;
}

List<Map<String, dynamic>> _listOfMaps(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

int _readInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
