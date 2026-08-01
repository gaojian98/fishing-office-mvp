import 'dart:convert';

import '../../models/resident_dialogue_config.dart';
import 'json/json_source.dart';

class ResidentDialogueRepository {
  const ResidentDialogueRepository({
    required this.source,
    this.path = 'assets/config/resident_dialogue.json',
  });

  final JsonSource source;
  final String path;

  Future<ResidentDialogueConfig> load() async {
    final raw = await source.loadString(path);
    return ResidentDialogueConfig.fromJson(
        jsonDecode(raw) as Map<String, dynamic>);
  }
}
