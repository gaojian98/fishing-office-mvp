import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/layout_config.dart';

class LayoutLoader {
  const LayoutLoader();

  Future<LayoutConfig> load() async {
    final raw = await rootBundle.loadString('assets/config/Layout.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return LayoutConfig.fromJson(json);
  }
}
