import 'dart:convert';

import '../../models/rumor_config.dart';
import 'json/json_source.dart';

class RumorRepository {
  const RumorRepository({
    required this.source,
    this.path = 'assets/config/rumor.json',
  });

  final JsonSource source;
  final String path;

  Future<RumorConfig> load() async {
    final raw = await source.loadString(path);
    return RumorConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
