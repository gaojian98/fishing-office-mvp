import 'dart:convert';

import '../../models/story_config.dart';
import 'json/json_source.dart';

class StoryRepository {
  const StoryRepository({
    required this.source,
    this.path = 'assets/config/story.json',
  });

  final JsonSource source;
  final String path;

  Future<StoryConfig> load() async {
    final raw = await source.loadString(path);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return StoryConfig.fromJson(json);
  }
}
