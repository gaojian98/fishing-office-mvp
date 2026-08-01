class ResidentStoryConfig {
  const ResidentStoryConfig({
    required this.version,
    required this.stories,
  });

  factory ResidentStoryConfig.fromJson(Map<String, dynamic> json) {
    return ResidentStoryConfig(
      version: json['version']?.toString() ?? '1.0',
      stories: _listOfMaps(json['stories'])
          .map(ResidentStoryEntry.fromJson)
          .toList(growable: false),
    );
  }

  final String version;
  final List<ResidentStoryEntry> stories;
}

class ResidentStoryEntry {
  const ResidentStoryEntry({
    required this.id,
    required this.residentId,
    required this.title,
    required this.summary,
    required this.dialogueIds,
    required this.conditions,
    required this.result,
    required this.priority,
    required this.repeatable,
    required this.tags,
  });

  factory ResidentStoryEntry.fromJson(Map<String, dynamic> json) {
    return ResidentStoryEntry(
      id: json['id']?.toString() ?? '',
      residentId: json['residentId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      dialogueIds: _stringList(json['dialogueIds']),
      conditions: ResidentStoryConditions.fromJson(_mapOf(json['conditions'])),
      result: Map<String, dynamic>.from(_mapOf(json['result'])),
      priority: _readInt(json['priority']),
      repeatable:
          json['repeatable'] is bool ? json['repeatable'] as bool : true,
      tags: _stringList(json['tags']),
    );
  }

  final String id;
  final String residentId;
  final String title;
  final String summary;
  final List<String> dialogueIds;
  final ResidentStoryConditions conditions;
  final Map<String, dynamic> result;
  final int priority;
  final bool repeatable;
  final List<String> tags;

  List<String> get resultMemoryTags => _stringList(result['memoryTags']);
}

class ResidentStoryConditions {
  const ResidentStoryConditions({
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
    required this.memoryTags,
    required this.rumorTags,
    required this.meetCountMin,
    required this.meetCount,
    required this.storyState,
    required this.finishedStories,
    required this.requiredStories,
  });

  factory ResidentStoryConditions.fromJson(Map<String, dynamic> json) {
    final location =
        _readFirstString(json, const ['residentLocation', 'location']);
    final activity =
        _readFirstString(json, const ['residentActivity', 'activity']);
    final mood = _readFirstString(json, const ['residentMood', 'mood']);
    return ResidentStoryConditions(
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
      memoryTags: _stringList(json['memoryTags']),
      rumorTags: _stringList(json['rumorTags']),
      meetCountMin: _readInt(json['meetCountMin']),
      meetCount: _readInt(json['meetCount']),
      storyState: json['storyState']?.toString() ?? '',
      finishedStories: _stringList(json['finishedStories']),
      requiredStories: _stringList(json['requiredStories']),
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
  final List<String> memoryTags;
  final List<String> rumorTags;
  final int meetCountMin;
  final int meetCount;
  final String storyState;
  final List<String> finishedStories;
  final List<String> requiredStories;
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

int _readInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
