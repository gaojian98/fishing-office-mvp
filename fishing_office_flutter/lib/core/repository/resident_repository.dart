import 'dart:convert';

import '../../models/resident_config.dart';
import 'json/json_source.dart';

class ResidentRepository {
  const ResidentRepository({
    required this.source,
    this.path = 'assets/config/resident.json',
  });

  final JsonSource source;
  final String path;

  Future<ResidentConfig> load() async {
    final raw = await source.loadString(path);
    return ResidentConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
