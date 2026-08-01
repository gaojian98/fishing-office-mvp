class DynamicEventConfig {
  const DynamicEventConfig({
    required this.version,
    required this.events,
  });

  factory DynamicEventConfig.fromJson(Map<String, dynamic> json) {
    return DynamicEventConfig(
      version: json['version']?.toString() ?? '1.0',
      events: _listOfMaps(json['events'])
          .map(DynamicEventEntry.fromJson)
          .where((event) => event.id.isNotEmpty)
          .toList(growable: false),
    );
  }

  final String version;
  final List<DynamicEventEntry> events;

  DynamicEventEntry? findEvent(String id) {
    for (final event in events) {
      if (event.id == id) return event;
    }
    return null;
  }
}

class DynamicEventEntry {
  const DynamicEventEntry({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.dialog,
    required this.choices,
    required this.result,
    required this.conditions,
    required this.priority,
    required this.weight,
    required this.probability,
    required this.cooldown,
    required this.unlockLevel,
    required this.repeatable,
    required this.nextEvent,
    required this.tags,
    required this.enabled,
    required this.raw,
  });

  factory DynamicEventEntry.fromJson(Map<String, dynamic> json) {
    final conditions = _mapOf(json['conditions']);
    return DynamicEventEntry(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      dialog: _listOfMaps(json['dialog'])
          .map(DynamicEventDialogLine.fromJson)
          .toList(growable: false),
      choices: _listOfMaps(json['choices'])
          .map(DynamicEventChoice.fromJson)
          .toList(growable: false),
      result: DynamicEventResult.fromJson(_mapOf(json['result'])),
      conditions: DynamicEventConditions.fromJson(
        <String, dynamic>{
          ...conditions,
          for (final key in DynamicEventConditions.supportedTopLevelKeys)
            if (json.containsKey(key)) key: json[key],
        },
      ),
      priority: _readInt(json['priority'], fallback: 0),
      weight: _readInt(json['weight'], fallback: 1),
      probability: _readDouble(json['probability'], fallback: 1),
      cooldown: _readInt(json['cooldown'], fallback: 0),
      unlockLevel: _readInt(json['unlockLevel'], fallback: 1),
      repeatable:
          json['repeatable'] is bool ? json['repeatable'] as bool : true,
      nextEvent: json['nextEvent']?.toString() ?? '',
      tags: _stringList(json['tags']),
      enabled: json['enabled'] is bool ? json['enabled'] as bool : true,
      raw: Map<String, dynamic>.from(json),
    );
  }

  final String id;
  final String type;
  final String category;
  final String title;
  final List<DynamicEventDialogLine> dialog;
  final List<DynamicEventChoice> choices;
  final DynamicEventResult result;
  final DynamicEventConditions conditions;
  final int priority;
  final int weight;
  final double probability;
  final int cooldown;
  final int unlockLevel;
  final bool repeatable;
  final String nextEvent;
  final List<String> tags;
  final bool enabled;
  final Map<String, dynamic> raw;
}

class DynamicEventConditions {
  const DynamicEventConditions({
    required this.timeOfDay,
    required this.weather,
    required this.festival,
    required this.location,
    required this.residentId,
    required this.relationshipLevel,
    required this.memoryTags,
    required this.rumorTags,
    required this.fishId,
    required this.storyState,
    required this.achievementState,
    required this.requiredEvents,
    required this.excludedEvents,
  });

  static const supportedTopLevelKeys = <String>{
    'timeOfDay',
    'weather',
    'festival',
    'location',
    'residentId',
    'relationshipLevel',
    'memoryTags',
    'rumorTags',
    'fishId',
    'storyState',
    'achievementState',
    'requiredEvents',
    'excludedEvents',
  };

  factory DynamicEventConditions.fromJson(Map<String, dynamic> json) {
    return DynamicEventConditions(
      timeOfDay: _stringList(json['timeOfDay']),
      weather: _stringList(json['weather']),
      festival: _stringList(json['festival']),
      location: _stringList(json['location']),
      residentId: _stringList(json['residentId']),
      relationshipLevel: _stringList(json['relationshipLevel']),
      memoryTags: _stringList(json['memoryTags']),
      rumorTags: _stringList(json['rumorTags']),
      fishId: _stringList(json['fishId']),
      storyState: _stringList(json['storyState']),
      achievementState: _stringList(json['achievementState']),
      requiredEvents: _stringList(json['requiredEvents']),
      excludedEvents: _stringList(json['excludedEvents']),
    );
  }

  final List<String> timeOfDay;
  final List<String> weather;
  final List<String> festival;
  final List<String> location;
  final List<String> residentId;
  final List<String> relationshipLevel;
  final List<String> memoryTags;
  final List<String> rumorTags;
  final List<String> fishId;
  final List<String> storyState;
  final List<String> achievementState;
  final List<String> requiredEvents;
  final List<String> excludedEvents;
}

class DynamicEventDialogLine {
  const DynamicEventDialogLine({
    required this.speaker,
    required this.text,
    required this.image,
  });

  factory DynamicEventDialogLine.fromJson(Map<String, dynamic> json) {
    return DynamicEventDialogLine(
      speaker: json['speaker']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }

  final String speaker;
  final String text;
  final String image;
}

class DynamicEventChoice {
  const DynamicEventChoice({
    required this.id,
    required this.text,
    required this.result,
  });

  factory DynamicEventChoice.fromJson(Map<String, dynamic> json) {
    return DynamicEventChoice(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      result: DynamicEventResult.fromJson(_mapOf(json['result'])),
    );
  }

  final String id;
  final String text;
  final DynamicEventResult result;
}

class DynamicEventResult {
  const DynamicEventResult({
    required this.memoryTags,
    required this.relationshipChanges,
    required this.rumorIds,
    required this.storyIds,
    required this.questEvents,
    required this.achievementEvents,
    required this.fishIds,
    required this.tags,
    required this.raw,
  });

  factory DynamicEventResult.fromJson(Map<String, dynamic> json) {
    return DynamicEventResult(
      memoryTags: _stringList(json['memoryTags']),
      relationshipChanges: _listOfMaps(json['relationshipChanges']),
      rumorIds: _stringList(json['rumorIds']),
      storyIds: _stringList(json['storyIds']),
      questEvents: _listOfMaps(json['questEvents']),
      achievementEvents: _listOfMaps(json['achievementEvents']),
      fishIds: _stringList(json['fishIds']),
      tags: _stringList(json['tags']),
      raw: Map<String, dynamic>.from(json),
    );
  }

  DynamicEventResult merge(DynamicEventResult other) {
    return DynamicEventResult(
      memoryTags: <String>{...memoryTags, ...other.memoryTags}.toList(),
      relationshipChanges: <Map<String, dynamic>>[
        ...relationshipChanges,
        ...other.relationshipChanges,
      ],
      rumorIds: <String>{...rumorIds, ...other.rumorIds}.toList(),
      storyIds: <String>{...storyIds, ...other.storyIds}.toList(),
      questEvents: <Map<String, dynamic>>[
        ...questEvents,
        ...other.questEvents,
      ],
      achievementEvents: <Map<String, dynamic>>[
        ...achievementEvents,
        ...other.achievementEvents,
      ],
      fishIds: <String>{...fishIds, ...other.fishIds}.toList(),
      tags: <String>{...tags, ...other.tags}.toList(),
      raw: <String, dynamic>{...raw, ...other.raw},
    );
  }

  final List<String> memoryTags;
  final List<Map<String, dynamic>> relationshipChanges;
  final List<String> rumorIds;
  final List<String> storyIds;
  final List<Map<String, dynamic>> questEvents;
  final List<Map<String, dynamic>> achievementEvents;
  final List<String> fishIds;
  final List<String> tags;
  final Map<String, dynamic> raw;
}

List<Map<String, dynamic>> _listOfMaps(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

Map<String, dynamic> _mapOf(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

List<String> _stringList(Object? value) {
  if (value == null) return const <String>[];
  if (value is List) {
    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
  final text = value.toString();
  if (text.isEmpty) return const <String>[];
  return text
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

int _readInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _readDouble(Object? value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
