class RumorConfig {
  const RumorConfig({
    required this.version,
    required this.rumors,
  });

  factory RumorConfig.fromJson(Map<String, dynamic> json) {
    return RumorConfig(
      version: json['version']?.toString() ?? '1.0',
      rumors: _listOfMaps(json['rumors'])
          .map(RumorEntry.fromJson)
          .toList(growable: false),
    );
  }

  final String version;
  final List<RumorEntry> rumors;

  RumorEntry? findRumor(String id) {
    for (final rumor in rumors) {
      if (rumor.id == id) return rumor;
    }
    return null;
  }
}

class RumorEntry {
  const RumorEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.source,
    required this.relatedResidentId,
    required this.relatedFishId,
    required this.relatedWeatherId,
    required this.relatedFestivalId,
    required this.rarity,
    required this.unlockCondition,
    required this.timeRange,
    required this.tags,
    required this.repeatable,
    required this.weight,
    required this.enabled,
    required this.sortOrder,
  });

  factory RumorEntry.fromJson(Map<String, dynamic> json) {
    return RumorEntry(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      relatedResidentId: json['relatedResidentId']?.toString() ?? '',
      relatedFishId: json['relatedFishId']?.toString() ?? '',
      relatedWeatherId: json['relatedWeatherId']?.toString() ?? '',
      relatedFestivalId: json['relatedFestivalId']?.toString() ?? '',
      rarity: json['rarity']?.toString() ?? '',
      unlockCondition:
          RumorUnlockCondition.fromJson(_mapOf(json['unlockCondition'])),
      timeRange: json['timeRange']?.toString() ?? '',
      tags: _stringList(json['tags']),
      repeatable:
          json['repeatable'] is bool ? json['repeatable'] as bool : true,
      weight: _readInt(json['weight'], fallback: 1),
      enabled: json['enabled'] is bool ? json['enabled'] as bool : true,
      sortOrder: _readInt(json['sortOrder']),
    );
  }

  final String id;
  final String title;
  final String content;
  final String category;
  final String source;
  final String relatedResidentId;
  final String relatedFishId;
  final String relatedWeatherId;
  final String relatedFestivalId;
  final String rarity;
  final RumorUnlockCondition unlockCondition;
  final String timeRange;
  final List<String> tags;
  final bool repeatable;
  final int weight;
  final bool enabled;
  final int sortOrder;

  List<String> get allTags {
    return <String>{
      id,
      category,
      rarity,
      relatedResidentId,
      relatedFishId,
      relatedWeatherId,
      relatedFestivalId,
      ...tags,
    }.where((item) => item.isNotEmpty).toList(growable: false);
  }
}

class RumorUnlockCondition {
  const RumorUnlockCondition({
    required this.level,
    required this.requiresFestivalId,
    required this.requiresWeatherId,
    required this.requiresResidentId,
    required this.requiresFishId,
  });

  factory RumorUnlockCondition.fromJson(Map<String, dynamic> json) {
    return RumorUnlockCondition(
      level: _readInt(json['level']),
      requiresFestivalId: json['requiresFestivalId']?.toString() ?? '',
      requiresWeatherId: json['requiresWeatherId']?.toString() ?? '',
      requiresResidentId: json['requiresResidentId']?.toString() ?? '',
      requiresFishId: json['requiresFishId']?.toString() ?? '',
    );
  }

  final int level;
  final String requiresFestivalId;
  final String requiresWeatherId;
  final String requiresResidentId;
  final String requiresFishId;
}

enum RumorLifecycle {
  waiting,
  spreading,
  popular,
  expired,
  archived,
}

class RumorRuntimeRecord {
  const RumorRuntimeRecord({
    required this.rumorId,
    required this.lifecycle,
    required this.startedDay,
    required this.lastUpdatedDay,
    required this.spreadCount,
    required this.scope,
    required this.probability,
    required this.expiresAfterDays,
  });

  final String rumorId;
  final RumorLifecycle lifecycle;
  final int startedDay;
  final int lastUpdatedDay;
  final int spreadCount;
  final String scope;
  final double probability;
  final int expiresAfterDays;

  factory RumorRuntimeRecord.fromJson(Map<String, dynamic> json) {
    return RumorRuntimeRecord(
      rumorId: json['rumorId']?.toString() ?? '',
      lifecycle: _lifecycleFromString(json['lifecycle']?.toString() ?? ''),
      startedDay: _readInt(json['startedDay']),
      lastUpdatedDay: _readInt(json['lastUpdatedDay']),
      spreadCount: _readInt(json['spreadCount']),
      scope: json['scope']?.toString() ?? '',
      probability: _readDouble(json['probability']),
      expiresAfterDays: _readInt(json['expiresAfterDays']),
    );
  }

  RumorRuntimeRecord copyWith({
    RumorLifecycle? lifecycle,
    int? lastUpdatedDay,
    int? spreadCount,
    String? scope,
    double? probability,
    int? expiresAfterDays,
  }) {
    return RumorRuntimeRecord(
      rumorId: rumorId,
      lifecycle: lifecycle ?? this.lifecycle,
      startedDay: startedDay,
      lastUpdatedDay: lastUpdatedDay ?? this.lastUpdatedDay,
      spreadCount: spreadCount ?? this.spreadCount,
      scope: scope ?? this.scope,
      probability: probability ?? this.probability,
      expiresAfterDays: expiresAfterDays ?? this.expiresAfterDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rumorId': rumorId,
      'lifecycle': lifecycle.name,
      'startedDay': startedDay,
      'lastUpdatedDay': lastUpdatedDay,
      'spreadCount': spreadCount,
      'scope': scope,
      'probability': probability,
      'expiresAfterDays': expiresAfterDays,
    };
  }
}

RumorLifecycle _lifecycleFromString(String value) {
  for (final lifecycle in RumorLifecycle.values) {
    if (lifecycle.name == value) return lifecycle;
  }
  return RumorLifecycle.waiting;
}

List<Map<String, dynamic>> _listOfMaps(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

Map<String, dynamic> _mapOf(Object? value) {
  if (value is! Map) return const <String, dynamic>{};
  return Map<String, dynamic>.from(value);
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

double _readDouble(Object? value, {double fallback = 0}) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
