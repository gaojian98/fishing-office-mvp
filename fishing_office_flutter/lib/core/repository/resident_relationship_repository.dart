import 'dart:convert';

import '../../models/resident_relationship_config.dart';
import 'json/json_source.dart';

class ResidentRelationshipRepository {
  const ResidentRelationshipRepository({
    required this.source,
    this.path = 'assets/config/resident_relationship.json',
  });

  final JsonSource source;
  final String path;

  Future<ResidentRelationshipConfig> load() async {
    final raw = await source.loadString(path);
    return ResidentRelationshipConfig.fromJson(
        jsonDecode(raw) as Map<String, dynamic>);
  }
}
