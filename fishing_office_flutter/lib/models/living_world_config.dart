class WorldClockConfig {
  const WorldClockConfig({
    required this.hour,
    required this.minute,
    required this.weekday,
    required this.month,
    required this.season,
  });

  final int hour;
  final int minute;
  final int weekday;
  final int month;
  final String season;

  factory WorldClockConfig.fromJson(Map<String, dynamic> json) {
    return WorldClockConfig(
      hour: _intValue(json['hour']),
      minute: _intValue(json['minute']),
      weekday: _intValue(json['weekday'], fallback: 1),
      month: _intValue(json['month'], fallback: 1),
      season: json['season']?.toString() ?? 'reserved',
    );
  }

  static int _intValue(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class WorldConfig {
  const WorldConfig({
    required this.version,
    required this.worldName,
    required this.clock,
  });

  final String version;
  final String worldName;
  final WorldClockConfig clock;

  factory WorldConfig.fromJson(Map<String, dynamic> json) {
    return WorldConfig(
      version: json['version']?.toString() ?? '1.0',
      worldName: json['worldName']?.toString() ?? '第二世界',
      clock: WorldClockConfig.fromJson(_mapValue(json['clock'])),
    );
  }
}

class MemoryTriggerConfig {
  const MemoryTriggerConfig({
    required this.id,
    required this.type,
    required this.condition,
    required this.raw,
  });

  final String id;
  final String type;
  final String condition;
  final Map<String, dynamic> raw;

  factory MemoryTriggerConfig.fromJson(Map<String, dynamic> json) {
    return MemoryTriggerConfig(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      condition: json['condition']?.toString() ?? '',
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class MemoryConfig {
  const MemoryConfig({
    required this.version,
    required this.triggers,
    required this.memories,
  });

  final String version;
  final List<MemoryTriggerConfig> triggers;
  final List<Map<String, dynamic>> memories;

  factory MemoryConfig.fromJson(Map<String, dynamic> json) {
    return MemoryConfig(
      version: json['version']?.toString() ?? '1.0',
      triggers: _listOfMaps(json['triggers'])
          .map(MemoryTriggerConfig.fromJson)
          .toList(growable: false),
      memories: _listOfMaps(json['memories']),
    );
  }
}

class RelationshipRuleConfig {
  const RelationshipRuleConfig({
    required this.id,
    required this.level,
    required this.behavior,
    required this.raw,
  });

  final String id;
  final String level;
  final String behavior;
  final Map<String, dynamic> raw;

  factory RelationshipRuleConfig.fromJson(Map<String, dynamic> json) {
    return RelationshipRuleConfig(
      id: json['id']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      behavior: json['behavior']?.toString() ?? '',
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class RelationshipConfig {
  const RelationshipConfig({
    required this.version,
    required this.levels,
    required this.rules,
  });

  final String version;
  final List<String> levels;
  final List<RelationshipRuleConfig> rules;

  factory RelationshipConfig.fromJson(Map<String, dynamic> json) {
    return RelationshipConfig(
      version: json['version']?.toString() ?? '1.0',
      levels: _stringList(json['levels']),
      rules: _listOfMaps(json['rules'])
          .map(RelationshipRuleConfig.fromJson)
          .toList(growable: false),
    );
  }
}

class WorldTimelineConfig {
  const WorldTimelineConfig({
    required this.version,
    required this.milestones,
  });

  final String version;
  final List<Map<String, dynamic>> milestones;

  factory WorldTimelineConfig.fromJson(Map<String, dynamic> json) {
    return WorldTimelineConfig(
      version: json['version']?.toString() ?? '1.0',
      milestones: _listOfMaps(json['milestones']),
    );
  }
}

class DialogueContextConfig {
  const DialogueContextConfig({
    required this.version,
    required this.contexts,
  });

  final String version;
  final List<Map<String, dynamic>> contexts;

  factory DialogueContextConfig.fromJson(Map<String, dynamic> json) {
    return DialogueContextConfig(
      version: json['version']?.toString() ?? '1.0',
      contexts: _listOfMaps(json['contexts']),
    );
  }
}

class EventTriggerConfig {
  const EventTriggerConfig({
    required this.version,
    required this.triggers,
  });

  final String version;
  final List<Map<String, dynamic>> triggers;

  factory EventTriggerConfig.fromJson(Map<String, dynamic> json) {
    return EventTriggerConfig(
      version: json['version']?.toString() ?? '1.0',
      triggers: _listOfMaps(json['triggers']),
    );
  }
}

Map<String, dynamic> _mapValue(Object? value) {
  return value is Map
      ? Map<String, dynamic>.from(value)
      : const <String, dynamic>{};
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
