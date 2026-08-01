import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/guide_config.dart';

class GuideConfigLoader {
  const GuideConfigLoader();

  Future<GuideConfig> load() async {
    final raw = await rootBundle.loadString('assets/config/guide.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final value = json['guide'];
    if (value is Map<String, dynamic>) return GuideConfig.fromJson(value);
    return GuideConfig.fromJson(json);
  }
}
