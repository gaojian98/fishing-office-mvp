import 'dart:convert';

import '../../models/resident_story_config.dart';
import 'json/json_source.dart';

class ResidentStoryRepository {
  const ResidentStoryRepository({
    required this.source,
    this.path = 'assets/config/resident_story.json',
  });

  final JsonSource source;
  final String path;

  Future<ResidentStoryConfig> load() async {
    final raw = await source.loadString(path);
    return ResidentStoryConfig.fromJson(
        jsonDecode(raw) as Map<String, dynamic>);
  }
}
