class ResidentRelationshipConfig {
  const ResidentRelationshipConfig({
    required this.version,
    required this.levels,
    required this.relationships,
  });

  factory ResidentRelationshipConfig.fromJson(Map<String, dynamic> json) {
    return ResidentRelationshipConfig(
      version: json['version']?.toString() ?? '1.0',
      levels: _listOfMaps(json['levels'])
          .map(ResidentRelationshipLevelRule.fromJson)
          .toList(growable: false),
      relationships: _listOfMaps(json['relationships'])
          .map(ResidentRelationshipRecord.fromJson)
          .toList(growable: false),
    );
  }

  final String version;
  final List<ResidentRelationshipLevelRule> levels;
  final List<ResidentRelationshipRecord> relationships;

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'levels': levels.map((item) => item.toJson()).toList(growable: false),
      'relationships':
          relationships.map((item) => item.toJson()).toList(growable: false),
    };
  }
}

class ResidentRelationshipLevelRule {
  const ResidentRelationshipLevelRule({
    required this.id,
    required this.name,
    required this.minMeetCount,
    required this.enabled,
    required this.sortOrder,
  });

  factory ResidentRelationshipLevelRule.fromJson(Map<String, dynamic> json) {
    return ResidentRelationshipLevelRule(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      minMeetCount: _readInt(json['minMeetCount']),
      enabled: json['enabled'] != false,
      sortOrder: _readInt(json['sortOrder']),
    );
  }

  final String id;
  final String name;
  final int minMeetCount;
  final bool enabled;
  final int sortOrder;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'minMeetCount': minMeetCount,
      'enabled': enabled,
      'sortOrder': sortOrder,
    };
  }
}

class ResidentRelationshipRecord {
  const ResidentRelationshipRecord({
    required this.residentId,
    required this.relationshipLevel,
    required this.relationshipScore,
    required this.lastChangedAt,
    required this.reason,
    required this.tags,
  });

  factory ResidentRelationshipRecord.empty(String residentId) {
    return ResidentRelationshipRecord(
      residentId: residentId,
      relationshipLevel: 'stranger',
      relationshipScore: 0,
      lastChangedAt: '',
      reason: '尚未见面',
      tags: const [],
    );
  }

  factory ResidentRelationshipRecord.fromJson(Map<String, dynamic> json) {
    return ResidentRelationshipRecord(
      residentId: json['residentId']?.toString() ?? '',
      relationshipLevel: json['relationshipLevel']?.toString() ?? 'stranger',
      relationshipScore: _readInt(json['relationshipScore']),
      lastChangedAt: json['lastChangedAt']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      tags: _stringList(json['tags']),
    );
  }

  final String residentId;
  final String relationshipLevel;
  final int relationshipScore;
  final String lastChangedAt;
  final String reason;
  final List<String> tags;

  ResidentRelationshipRecord copyWith({
    String? residentId,
    String? relationshipLevel,
    int? relationshipScore,
    String? lastChangedAt,
    String? reason,
    List<String>? tags,
  }) {
    return ResidentRelationshipRecord(
      residentId: residentId ?? this.residentId,
      relationshipLevel: relationshipLevel ?? this.relationshipLevel,
      relationshipScore: relationshipScore ?? this.relationshipScore,
      lastChangedAt: lastChangedAt ?? this.lastChangedAt,
      reason: reason ?? this.reason,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'residentId': residentId,
      'relationshipLevel': relationshipLevel,
      'relationshipScore': relationshipScore,
      'lastChangedAt': lastChangedAt,
      'reason': reason,
      'tags': tags,
    };
  }
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

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
