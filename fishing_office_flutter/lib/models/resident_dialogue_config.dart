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
    required this.conditions,
    required this.priority,
    required this.repeatable,
    required this.tags,
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
      conditions:
          ResidentDialogueConditions.fromJson(_mapOf(json['conditions'])),
      priority: _readInt(json['priority']),
      repeatable:
          json['repeatable'] is bool ? json['repeatable'] as bool : true,
      tags: _stringList(json['tags']),
    );
  }

  final String id;
  final String residentId;
  final String text;
  final ResidentDialogueConditions conditions;
  final int priority;
  final bool repeatable;
  final List<String> tags;
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
    required this.memoryTags,
    required this.rumorTags,
    required this.meetCountMin,
    required this.meetCount,
    required this.storyState,
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
      memoryTags: _stringList(json['memoryTags']),
      rumorTags: _stringList(json['rumorTags']),
      meetCountMin: _readInt(json['meetCountMin']),
      meetCount: _readInt(json['meetCount']),
      storyState: json['storyState']?.toString() ?? '',
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
