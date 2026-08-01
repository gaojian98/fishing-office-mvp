class WeatherConfig {
  const WeatherConfig({
    required this.version,
    required this.weatherEvents,
  });

  factory WeatherConfig.fromJson(Map<String, dynamic> json) {
    return WeatherConfig(
      version: json['version']?.toString() ?? '1.0',
      weatherEvents: _listOfMaps(json['weatherEvents'])
          .map(WeatherEntry.fromJson)
          .toList(growable: false),
    );
  }

  final String version;
  final List<WeatherEntry> weatherEvents;
}

class WeatherEntry {
  const WeatherEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.rarity,
    required this.seasons,
    required this.timeRange,
    required this.temperature,
    required this.windLevel,
    required this.humidity,
    required this.visibility,
    required this.fishBonus,
    required this.residentMoodModifier,
    required this.dialogueTags,
    required this.storyTags,
    required this.eventTags,
    required this.festivalTags,
    required this.description,
    required this.sortOrder,
    required this.enabled,
  });

  factory WeatherEntry.fromJson(Map<String, dynamic> json) {
    return WeatherEntry(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      rarity: json['rarity']?.toString() ?? '',
      seasons: _stringList(json['season']),
      timeRange: json['timeRange']?.toString() ?? '',
      temperature: _mapOf(json['temperature']),
      windLevel: _readInt(json['windLevel']),
      humidity: _readInt(json['humidity']),
      visibility: json['visibility']?.toString() ?? '',
      fishBonus: _mapOf(json['fishBonus']),
      residentMoodModifier: json['residentMoodModifier']?.toString() ?? '',
      dialogueTags: _stringList(json['dialogueTags']),
      storyTags: _stringList(json['storyTags']),
      eventTags: _stringList(json['eventTags']),
      festivalTags: _stringList(json['festivalTags']),
      description: json['description']?.toString() ?? '',
      sortOrder: _readInt(json['sortOrder']),
      enabled: json['enabled'] is bool ? json['enabled'] as bool : true,
    );
  }

  final String id;
  final String name;
  final String type;
  final String rarity;
  final List<String> seasons;
  final String timeRange;
  final Map<String, dynamic> temperature;
  final int windLevel;
  final int humidity;
  final String visibility;
  final Map<String, dynamic> fishBonus;
  final String residentMoodModifier;
  final List<String> dialogueTags;
  final List<String> storyTags;
  final List<String> eventTags;
  final List<String> festivalTags;
  final String description;
  final int sortOrder;
  final bool enabled;
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

int _readInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
