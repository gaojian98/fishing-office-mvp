import 'dart:convert';

import '../../models/dynamic_event_config.dart';
import 'json/json_source.dart';

class DynamicEventRepository {
  const DynamicEventRepository({
    required this.source,
    this.path = 'assets/config/events.json',
  });

  final JsonSource source;
  final String path;

  Future<DynamicEventConfig> load() async {
    final raw = await source.loadString(path);
    return DynamicEventConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
