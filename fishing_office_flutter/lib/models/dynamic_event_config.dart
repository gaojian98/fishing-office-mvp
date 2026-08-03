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
    required this.friendshipStage,
    required this.friendshipTags,
    required this.minimumFriendshipStage,
    required this.minimumTrust,
    required this.minimumFamiliarity,
    required this.memoryTags,
    required this.rumorTags,
    required this.fishId,
    required this.storyState,
    required this.achievementState,
    required this.requiredEvents,
    required this.excludedEvents,
    required this.personalityTags,
    required this.excludedPersonalityTags,
    required this.groupActivity,
    required this.groupTopic,
    required this.groupLocation,
    required this.groupTags,
    required this.groupSizeMin,
    required this.officeMood,
    required this.minimumActivityLevel,
    required this.maximumTensionLevel,
    required this.requiredOfficeTags,
    required this.excludedOfficeTags,
    required this.requiredPlayerReputation,
    required this.requiredRecentActions,
    required this.minimumOfficeInfluence,
    required this.minimumOfficeTrust,
    required this.companyId,
    required this.departmentId,
    required this.teamId,
    required this.positionId,
    required this.organizationTags,
    required this.careerLevel,
    required this.employmentStatus,
    required this.careerTags,
    required this.salaryLevelMin,
  });

  static const supportedTopLevelKeys = <String>{
    'timeOfDay',
    'weather',
    'festival',
    'location',
    'residentId',
    'relationshipLevel',
    'friendshipStage',
    'friendshipTags',
    'minimumFriendshipStage',
    'minimumTrust',
    'minimumFamiliarity',
    'memoryTags',
    'rumorTags',
    'fishId',
    'storyState',
    'achievementState',
    'requiredEvents',
    'excludedEvents',
    'personalityTags',
    'excludedPersonalityTags',
    'groupActivity',
    'groupTopic',
    'groupLocation',
    'groupTags',
    'groupSizeMin',
    'officeMood',
    'minimumActivityLevel',
    'maximumTensionLevel',
    'requiredOfficeTags',
    'excludedOfficeTags',
    'requiredPlayerReputation',
    'requiredRecentActions',
    'minimumOfficeInfluence',
    'minimumOfficeTrust',
    'companyId',
    'departmentId',
    'teamId',
    'positionId',
    'organizationTags',
    'careerLevel',
    'employmentStatus',
    'careerTags',
    'salaryLevelMin',
  };

  factory DynamicEventConditions.fromJson(Map<String, dynamic> json) {
    return DynamicEventConditions(
      timeOfDay: _stringList(json['timeOfDay']),
      weather: _stringList(json['weather']),
      festival: _stringList(json['festival']),
      location: _stringList(json['location']),
      residentId: _stringList(json['residentId']),
      relationshipLevel: _stringList(json['relationshipLevel']),
      friendshipStage: _stringList(json['friendshipStage']),
      friendshipTags: _stringList(json['friendshipTags']),
      minimumFriendshipStage: json['minimumFriendshipStage']?.toString() ?? '',
      minimumTrust: _readInt(json['minimumTrust'], fallback: 0),
      minimumFamiliarity: _readInt(json['minimumFamiliarity'], fallback: 0),
      memoryTags: _stringList(json['memoryTags']),
      rumorTags: _stringList(json['rumorTags']),
      fishId: _stringList(json['fishId']),
      storyState: _stringList(json['storyState']),
      achievementState: _stringList(json['achievementState']),
      requiredEvents: _stringList(json['requiredEvents']),
      excludedEvents: _stringList(json['excludedEvents']),
      personalityTags: _stringList(json['personalityTags']),
      excludedPersonalityTags: _stringList(json['excludedPersonalityTags']),
      groupActivity: _stringList(json['groupActivity']),
      groupTopic: _stringList(json['groupTopic']),
      groupLocation: _stringList(json['groupLocation']),
      groupTags: _stringList(json['groupTags']),
      groupSizeMin: _readInt(json['groupSizeMin'], fallback: 0),
      officeMood: _stringList(json['officeMood']),
      minimumActivityLevel: _readInt(json['minimumActivityLevel'], fallback: 0),
      maximumTensionLevel: _readInt(json['maximumTensionLevel'], fallback: 0),
      requiredOfficeTags: _stringList(json['requiredOfficeTags']),
      excludedOfficeTags: _stringList(json['excludedOfficeTags']),
      requiredPlayerReputation: _stringList(json['requiredPlayerReputation']),
      requiredRecentActions: _stringList(json['requiredRecentActions']),
      minimumOfficeInfluence:
          _readInt(json['minimumOfficeInfluence'], fallback: 0),
      minimumOfficeTrust: _readInt(json['minimumOfficeTrust'], fallback: 0),
      companyId: _stringList(json['companyId']),
      departmentId: _stringList(json['departmentId']),
      teamId: _stringList(json['teamId']),
      positionId: _stringList(json['positionId']),
      organizationTags: _stringList(json['organizationTags']),
      careerLevel: _stringList(json['careerLevel']),
      employmentStatus: _stringList(json['employmentStatus']),
      careerTags: _stringList(json['careerTags']),
      salaryLevelMin: _readInt(json['salaryLevelMin'], fallback: 0),
    );
  }

  final List<String> timeOfDay;
  final List<String> weather;
  final List<String> festival;
  final List<String> location;
  final List<String> residentId;
  final List<String> relationshipLevel;
  final List<String> friendshipStage;
  final List<String> friendshipTags;
  final String minimumFriendshipStage;
  final int minimumTrust;
  final int minimumFamiliarity;
  final List<String> memoryTags;
  final List<String> rumorTags;
  final List<String> fishId;
  final List<String> storyState;
  final List<String> achievementState;
  final List<String> requiredEvents;
  final List<String> excludedEvents;
  final List<String> personalityTags;
  final List<String> excludedPersonalityTags;
  final List<String> groupActivity;
  final List<String> groupTopic;
  final List<String> groupLocation;
  final List<String> groupTags;
  final int groupSizeMin;
  final List<String> officeMood;
  final int minimumActivityLevel;
  final int maximumTensionLevel;
  final List<String> requiredOfficeTags;
  final List<String> excludedOfficeTags;
  final List<String> requiredPlayerReputation;
  final List<String> requiredRecentActions;
  final int minimumOfficeInfluence;
  final int minimumOfficeTrust;
  final List<String> companyId;
  final List<String> departmentId;
  final List<String> teamId;
  final List<String> positionId;
  final List<String> organizationTags;
  final List<String> careerLevel;
  final List<String> employmentStatus;
  final List<String> careerTags;
  final int salaryLevelMin;
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
    required this.friendshipChanges,
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
      friendshipChanges: _listOfMaps(json['friendshipChanges']),
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
      friendshipChanges: <Map<String, dynamic>>[
        ...friendshipChanges,
        ...other.friendshipChanges,
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
  final List<Map<String, dynamic>> friendshipChanges;
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
