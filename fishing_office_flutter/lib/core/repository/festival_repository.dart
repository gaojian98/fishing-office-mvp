import 'dart:convert';

import '../../models/festival_config.dart';
import 'json/json_source.dart';

class FestivalRepository {
  const FestivalRepository({
    required this.source,
    this.path = 'assets/config/festival.json',
  });

  final JsonSource source;
  final String path;

  Future<FestivalConfig> load() async {
    final raw = await source.loadString(path);
    return FestivalConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
