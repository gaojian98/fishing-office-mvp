import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/fish_collection_config.dart';

class FishCollectionConfigLoader {
  const FishCollectionConfigLoader();

  Future<FishCollectionConfig> load() async {
    final raw =
        await rootBundle.loadString('assets/config/fish_collection.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final collectionJson = decoded['collection'] is Map<String, dynamic>
        ? decoded['collection'] as Map<String, dynamic>
        : decoded;
    return FishCollectionConfig.fromJson(collectionJson);
  }
}
