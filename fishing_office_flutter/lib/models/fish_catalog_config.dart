class FishCatalogConfig {
  const FishCatalogConfig({
    required this.version,
    required this.fish,
  });

  factory FishCatalogConfig.fromJson(Map<String, dynamic> json) {
    return FishCatalogConfig(
      version: json['version']?.toString() ?? '1.0',
      fish: _listOfMaps(json['fish'])
          .map(FishCatalogEntry.fromJson)
          .where((entry) => entry.id.isNotEmpty)
          .toList(growable: false),
    );
  }

  final String version;
  final List<FishCatalogEntry> fish;

  FishCatalogEntry? findFish(String id) {
    for (final entry in fish) {
      if (entry.id == id) return entry;
    }
    return null;
  }
}

class FishCatalogEntry {
  const FishCatalogEntry({
    required this.id,
    required this.name,
    required this.nickname,
    required this.rarity,
    required this.habitat,
    required this.favoriteTime,
    required this.favoriteWeather,
    required this.favoriteBait,
    required this.fear,
    required this.personality,
    required this.description,
    required this.story,
    required this.firstDialogue,
    required this.catchReaction,
    required this.waitDialogues,
    required this.value,
    required this.weightRange,
    required this.baitRequired,
    required this.nextBaitTarget,
    required this.raw,
  });

  factory FishCatalogEntry.fromJson(Map<String, dynamic> json) {
    return FishCatalogEntry(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      rarity: json['rarity']?.toString() ?? 'common',
      habitat: json['habitat']?.toString() ?? '',
      favoriteTime: json['favoriteTime']?.toString() ?? '',
      favoriteWeather: json['favoriteWeather']?.toString() ?? '',
      favoriteBait: json['favoriteBait']?.toString() ?? '',
      fear: json['fear']?.toString() ?? '',
      personality: json['personality']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      story: json['story']?.toString() ?? '',
      firstDialogue: json['firstDialogue']?.toString() ?? '',
      catchReaction: json['catchReaction']?.toString() ?? '',
      waitDialogues: _stringList(json['waitDialogues']),
      value: _readInt(json['value']),
      weightRange: FishWeightRange.fromJson(_mapOf(json['weightRange'])),
      baitRequired: json['baitRequired']?.toString() ?? '',
      nextBaitTarget: json['nextBaitTarget']?.toString() ?? '',
      raw: Map<String, dynamic>.from(json),
    );
  }

  final String id;
  final String name;
  final String nickname;
  final String rarity;
  final String habitat;
  final String favoriteTime;
  final String favoriteWeather;
  final String favoriteBait;
  final String fear;
  final String personality;
  final String description;
  final String story;
  final String firstDialogue;
  final String catchReaction;
  final List<String> waitDialogues;
  final int value;
  final FishWeightRange weightRange;
  final String baitRequired;
  final String nextBaitTarget;
  final Map<String, dynamic> raw;
}

class FishWeightRange {
  const FishWeightRange({
    required this.min,
    required this.max,
    required this.unit,
  });

  factory FishWeightRange.fromJson(Map<String, dynamic> json) {
    return FishWeightRange(
      min: _readDouble(json['min'], fallback: 0.4),
      max: _readDouble(json['max'], fallback: 1.0),
      unit: json['unit']?.toString() ?? 'kg',
    );
  }

  final double min;
  final double max;
  final String unit;
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
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _readDouble(Object? value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
