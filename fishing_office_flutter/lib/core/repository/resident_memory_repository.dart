import 'dart:convert';

import '../../models/resident_memory_config.dart';
import 'json/json_source.dart';

class ResidentMemoryRepository {
  const ResidentMemoryRepository({
    required this.source,
    this.path = 'assets/config/resident_memory.json',
  });

  final JsonSource source;
  final String path;

  Future<ResidentMemoryConfig> load() async {
    final raw = await source.loadString(path);
    return ResidentMemoryConfig.fromJson(
        jsonDecode(raw) as Map<String, dynamic>);
  }
}
