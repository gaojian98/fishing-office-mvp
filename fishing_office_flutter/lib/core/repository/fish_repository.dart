import 'dart:convert';

import '../../models/fish_catalog_config.dart';
import 'json/json_source.dart';

class FishRepository {
  const FishRepository({
    required this.source,
    this.path = 'assets/config/fish_catalog.json',
  });

  final JsonSource source;
  final String path;

  Future<FishCatalogConfig> load() async {
    final raw = await source.loadString(path);
    return FishCatalogConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
