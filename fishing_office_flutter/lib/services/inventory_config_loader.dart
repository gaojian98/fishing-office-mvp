import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/inventory_config.dart';

class InventoryConfigLoader {
  const InventoryConfigLoader();

  Future<InventoryConfig> load() async {
    final raw = await rootBundle.loadString('assets/config/inventory.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final inventoryJson = json['inventory'] is Map<String, dynamic>
        ? json['inventory'] as Map<String, dynamic>
        : json;
    return InventoryConfig.fromJson(inventoryJson);
  }
}
