import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/layout_config.dart';

class LayoutLoader {
  const LayoutLoader();

  Future<LayoutConfig> load() async {
    final raw = await rootBundle.loadString('assets/config/office_layout.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final home = json['home'] is Map<String, dynamic>
        ? json['home'] as Map<String, dynamic>
        : json;
    return LayoutConfig.fromJson(home);
  }
}
