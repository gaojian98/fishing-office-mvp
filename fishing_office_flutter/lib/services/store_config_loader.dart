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
      rootBundle.loadString('assets/config/store/Layout.json'),
      rootBundle.loadString('assets/config/store/Interaction.json'),
      rootBundle.loadString('assets/config/store/Dialog.json'),
      rootBundle.loadString('assets/config/store/Animation.json'),
      rootBundle.loadString('assets/config/store/Routes.json'),
      rootBundle.loadString('assets/config/store/Data.json'),
    ]);

    return StoreConfigBundle(
      layout: StoreLayoutConfig.fromJson(
        jsonDecode(raw[0]) as Map<String, dynamic>,
      ),
      interaction: InteractionConfig.fromJson(
        jsonDecode(raw[1]) as Map<String, dynamic>,
      ),
      dialog: DialogConfig.fromJson(
        jsonDecode(raw[2]) as Map<String, dynamic>,
      ),
      animation: AnimationConfig.fromJson(
        jsonDecode(raw[3]) as Map<String, dynamic>,
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
