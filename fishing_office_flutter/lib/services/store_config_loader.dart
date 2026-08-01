import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/animation_config.dart';
import '../models/dialog_config.dart';
import '../models/interaction_config.dart';
import '../models/routes_config.dart';
import '../models/store_config.dart';

class StoreConfigLoader {
  const StoreConfigLoader();

  Future<StoreConfigBundle> load() async {
    final raw = await Future.wait([
      rootBundle.loadString('assets/config/office_layout.json'),
      rootBundle.loadString('assets/config/office_interaction.json'),
      rootBundle.loadString('assets/config/office_dialog.json'),
      rootBundle.loadString('assets/config/office_animation.json'),
      rootBundle.loadString('assets/config/office_routes.json'),
      rootBundle.loadString('assets/config/store/store_products.json'),
    ]);

    return StoreConfigBundle(
      layout: StoreLayoutConfig.fromJson(
        _decodeSection(raw[0], 'store'),
      ),
      interaction: InteractionConfig.fromJson(
        _decodeSection(raw[1], 'store'),
      ),
      dialog: DialogConfig.fromJson(
        _decodeSection(raw[2], 'store'),
      ),
      animation: AnimationConfig.fromJson(
        _decodeSection(raw[3], 'store'),
      ),
      routes: RoutesConfig.fromJson(
        jsonDecode(raw[4]) as Map<String, dynamic>,
      ),
      data: StoreDataConfig.fromJson(
        jsonDecode(raw[5]) as Map<String, dynamic>,
      ),
    );
  }
}

Map<String, dynamic> _decodeSection(Object raw, String section) {
  final json = jsonDecode(raw.toString()) as Map<String, dynamic>;
  final value = json[section];
  if (value is Map<String, dynamic>) return value;
  return json;
}
