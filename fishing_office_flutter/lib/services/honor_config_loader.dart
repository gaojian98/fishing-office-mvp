import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/honor_config.dart';

class HonorConfigLoader {
  const HonorConfigLoader();

  Future<HonorConfig> load() async {
    final raw = await rootBundle.loadString('assets/config/honor.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final honorJson = json['honor'] is Map<String, dynamic>
        ? json['honor'] as Map<String, dynamic>
        : json;
    return HonorConfig.fromJson(honorJson);
  }
}
