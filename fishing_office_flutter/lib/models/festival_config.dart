class FestivalConfig {
  const FestivalConfig({
    required this.version,
    required this.festivals,
  });

  factory FestivalConfig.fromJson(Map<String, dynamic> json) {
    return FestivalConfig(
      version: json['version']?.toString() ?? '1.0',
      festivals: _listOfMaps(json['festivals'])
          .map(FestivalEntry.fromJson)
          .toList(growable: false),
    );
  }

  final String version;
  final List<FestivalEntry> festivals;
}

class FestivalEntry {
  const FestivalEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.dateType,
    required this.dateValue,
    required this.season,
    required this.durationDays,
    required this.mood,
    required this.theme,
    required this.description,
    required this.worldEffects,
    required this.hooks,
    required this.unlockLevel,
    required this.repeatable,
    required this.sortOrder,
    required this.tags,
    required this.enabled,
  });

  factory FestivalEntry.fromJson(Map<String, dynamic> json) {
    return FestivalEntry(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      dateType: json['dateType']?.toString() ?? '',
      dateValue: json['dateValue']?.toString() ?? '',
      season: json['season']?.toString() ?? '',
      durationDays: _readInt(json['durationDays'], fallback: 1),
      mood: json['mood']?.toString() ?? '',
      theme: json['theme']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      worldEffects: _mapOf(json['worldEffects']),
      hooks: _mapOf(json['hooks']),
      unlockLevel: _readInt(json['unlockLevel']),
      repeatable:
          json['repeatable'] is bool ? json['repeatable'] as bool : true,
      sortOrder: _readInt(json['sortOrder']),
      tags: _stringList(json['tags']),
      enabled: json['enabled'] is bool ? json['enabled'] as bool : true,
    );
  }

  final String id;
  final String name;
  final String category;
  final String dateType;
  final String dateValue;
  final String season;
  final int durationDays;
  final String mood;
  final String theme;
  final String description;
  final Map<String, dynamic> worldEffects;
  final Map<String, dynamic> hooks;
  final int unlockLevel;
  final bool repeatable;
  final int sortOrder;
  final List<String> tags;
  final bool enabled;

  String get residentMood {
    final value = worldEffects['residentMood'];
    if (value != null && value.toString().isNotEmpty) {
      return value.toString();
    }
    return mood;
  }

  List<String> get dialogueTags => _stringList(hooks['dialogueTags']);
  List<String> get storyTags => _stringList(hooks['storyTags']);
  List<String> get eventTags => _stringList(worldEffects['eventTags']);
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
