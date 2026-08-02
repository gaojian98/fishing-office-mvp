class ResidentDialogueConfig {
  const ResidentDialogueConfig({
    required this.version,
    required this.fallback,
    required this.dialogues,
  });

  factory ResidentDialogueConfig.fromJson(Map<String, dynamic> json) {
    return ResidentDialogueConfig(
      version: json['version']?.toString() ?? '1.0',
      fallback: ResidentDialogueEntry.fromJson(
        _mapOf(json['fallback']),
        fallbackId: 'fallback_default',
        fallbackResidentId: '*',
      ),
      dialogues: _listOfMaps(json['dialogues'])
          .map(ResidentDialogueEntry.fromJson)
          .toList(growable: false),
    );
  }

  final String version;
  final ResidentDialogueEntry fallback;
  final List<ResidentDialogueEntry> dialogues;
}

class ResidentDialogueEntry {
  const ResidentDialogueEntry({
    required this.id,
    required this.residentId,
    required this.text,
    required this.actionType,
    required this.response,
    required this.conditions,
    required this.priority,
    required this.repeatable,
    required this.tags,
    required this.cooldownGroup,
    required this.weight,
  });

  factory ResidentDialogueEntry.fromJson(
    Map<String, dynamic> json, {
    String fallbackId = '',
    String fallbackResidentId = '',
  }) {
    return ResidentDialogueEntry(
      id: json['id']?.toString() ?? fallbackId,
      residentId: json['residentId']?.toString() ?? fallbackResidentId,
      text: json['text']?.toString() ?? '',
      actionType: json['actionType']?.toString() ?? '',
      response: json['response']?.toString() ?? '',
      conditions:
          ResidentDialogueConditions.fromJson(_mapOf(json['conditions'])),
      priority: _readInt(json['priority']),
      repeatable:
          json['repeatable'] is bool ? json['repeatable'] as bool : true,
      tags: _stringList(json['tags']),
      cooldownGroup: json['cooldownGroup']?.toString() ?? '',
      weight: _readInt(json['weight'], fallback: 1),
    );
  }

  final String id;
  final String residentId;
  final String text;
  final String actionType;
  final String response;
  final ResidentDialogueConditions conditions;
  final int priority;
  final bool repeatable;
  final List<String> tags;
  final String cooldownGroup;
  final int weight;
}

class ResidentDialogueConditions {
  const ResidentDialogueConditions({
    required this.timeOfDay,
    required this.weather,
    required this.festival,
    required this.location,
    required this.activity,
    required this.mood,
    required this.residentLocation,
    required this.residentActivity,
    required this.residentMood,
    required this.relationshipLevel,
    required this.friendshipStage,
    required this.friendshipScoreMin,
    required this.minimumFriendshipStage,
    required this.minimumTrust,
    required this.minimumFamiliarity,
    required this.sharedTopics,
    required this.lastInteractionType,
    required this.recentConflict,
    required this.recentConflictResolved,
    required this.memoryTags,
    required this.rumorTags,
    required this.meetCountMin,
    required this.meetCount,
    required this.storyState,
    required this.locationTags,
    required this.personalityTags,
    required this.excludedPersonalityTags,
    required this.groupActivity,
    required this.groupTopic,
    required this.groupMood,
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
  });

  factory ResidentDialogueConditions.fromJson(Map<String, dynamic> json) {
    final location =
        _readFirstString(json, const ['residentLocation', 'location']);
    final activity =
        _readFirstString(json, const ['residentActivity', 'activity']);
    final mood = _readFirstString(json, const ['residentMood', 'mood']);
    return ResidentDialogueConditions(
      timeOfDay: json['timeOfDay']?.toString() ?? '',
      weather: json['weather']?.toString() ?? '',
      festival: json['festival']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      activity: json['activity']?.toString() ?? '',
      mood: json['mood']?.toString() ?? '',
      residentLocation: location,
      residentActivity: activity,
      residentMood: mood,
      relationshipLevel: json['relationshipLevel']?.toString() ?? '',
      friendshipStage: json['friendshipStage']?.toString() ?? '',
      friendshipScoreMin: _readInt(json['friendshipScoreMin']),
      minimumFriendshipStage: json['minimumFriendshipStage']?.toString() ?? '',
      minimumTrust: _readInt(json['minimumTrust']),
      minimumFamiliarity: _readInt(json['minimumFamiliarity']),
      sharedTopics: _stringList(json['sharedTopics']),
      lastInteractionType: json['lastInteractionType']?.toString() ?? '',
      recentConflict: json['recentConflict'] is bool
          ? json['recentConflict'] as bool
          : null,
      recentConflictResolved: json['recentConflictResolved'] is bool
          ? json['recentConflictResolved'] as bool
          : null,
      memoryTags: _stringList(json['memoryTags']),
      rumorTags: _stringList(json['rumorTags']),
      meetCountMin: _readInt(json['meetCountMin']),
      meetCount: _readInt(json['meetCount']),
      storyState: json['storyState']?.toString() ?? '',
      locationTags: _stringList(json['locationTags']),
      personalityTags: _stringList(json['personalityTags']),
      excludedPersonalityTags: _stringList(json['excludedPersonalityTags']),
      groupActivity: json['groupActivity']?.toString() ?? '',
      groupTopic: json['groupTopic']?.toString() ?? '',
      groupMood: json['groupMood']?.toString() ?? '',
      groupTags: _stringList(json['groupTags']),
      groupSizeMin: _readInt(json['groupSizeMin']),
      officeMood: json['officeMood']?.toString() ?? '',
      minimumActivityLevel: _readInt(json['minimumActivityLevel']),
      maximumTensionLevel: _readInt(json['maximumTensionLevel']),
      requiredOfficeTags: _stringList(json['requiredOfficeTags']),
      excludedOfficeTags: _stringList(json['excludedOfficeTags']),
      requiredPlayerReputation: _stringList(json['requiredPlayerReputation']),
      requiredRecentActions: _stringList(json['requiredRecentActions']),
      minimumOfficeInfluence: _readInt(json['minimumOfficeInfluence']),
      minimumOfficeTrust: _readInt(json['minimumOfficeTrust']),
    );
  }

  final String timeOfDay;
  final String weather;
  final String festival;
  final String location;
  final String activity;
  final String mood;
  final String residentLocation;
  final String residentActivity;
  final String residentMood;
  final String relationshipLevel;
  final String friendshipStage;
  final int friendshipScoreMin;
  final String minimumFriendshipStage;
  final int minimumTrust;
  final int minimumFamiliarity;
  final List<String> sharedTopics;
  final String lastInteractionType;
  final bool? recentConflict;
  final bool? recentConflictResolved;
  final List<String> memoryTags;
  final List<String> rumorTags;
  final int meetCountMin;
  final int meetCount;
  final String storyState;
  final List<String> locationTags;
  final List<String> personalityTags;
  final List<String> excludedPersonalityTags;
  final String groupActivity;
  final String groupTopic;
  final String groupMood;
  final List<String> groupTags;
  final int groupSizeMin;
  final String officeMood;
  final int minimumActivityLevel;
  final int maximumTensionLevel;
  final List<String> requiredOfficeTags;
  final List<String> excludedOfficeTags;
  final List<String> requiredPlayerReputation;
  final List<String> requiredRecentActions;
  final int minimumOfficeInfluence;
  final int minimumOfficeTrust;
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

String _readFirstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().isNotEmpty) {
      return value.toString();
    }
  }
  return '';
}

int _readInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
