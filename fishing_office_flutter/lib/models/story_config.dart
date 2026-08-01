class StoryConfig {
  const StoryConfig({
    required this.version,
    required this.stories,
  });

  final String version;
  final List<Map<String, dynamic>> stories;

  factory StoryConfig.fromJson(Map<String, dynamic> json) {
    return StoryConfig(
      version: json['version']?.toString() ?? '1.0',
      stories: _listOfMaps(json['stories']),
    );
  }

  static List<Map<String, dynamic>> _listOfMaps(Object? value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
}
