import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/animation_config.dart';
import '../models/dialog_config.dart';
import '../models/interaction_config.dart';
import '../models/layout_config.dart';
import '../models/routes_config.dart';
import '../models/store_config.dart';
import 'store_config_loader.dart';

class HomeConfigBundle {
  const HomeConfigBundle({
    required this.layout,
    required this.interaction,
    required this.animation,
    required this.routes,
    required this.dialog,
    required this.store,
  });

  final LayoutConfig layout;
  final InteractionConfig interaction;
  final AnimationConfig animation;
  final RoutesConfig routes;
  final DialogConfig dialog;
  final StoreConfigBundle store;
}

class HomeConfigLoader {
  const HomeConfigLoader();

  Future<HomeConfigBundle> load() async {
    final raw = await Future.wait<Object>([
      rootBundle.loadString('assets/config/Layout.json'),
      rootBundle.loadString('assets/config/Interaction.json'),
      rootBundle.loadString('assets/config/Animation.json'),
      rootBundle.loadString('assets/config/Routes.json'),
      rootBundle.loadString('assets/config/Dialog.json'),
      const StoreConfigLoader().load(),
    ]);

    final storeBundle = raw[5] as StoreConfigBundle;
    return HomeConfigBundle(
      layout: LayoutConfig.fromJson(
        jsonDecode(raw[0] as String) as Map<String, dynamic>,
      ),
      interaction: InteractionConfig.fromJson(
        jsonDecode(raw[1] as String) as Map<String, dynamic>,
      ),
      animation: AnimationConfig.fromJson(
        jsonDecode(raw[2] as String) as Map<String, dynamic>,
      ),
      routes: RoutesConfig.fromJson(
        jsonDecode(raw[3] as String) as Map<String, dynamic>,
      ),
      dialog: DialogConfig.fromJson(
        jsonDecode(raw[4] as String) as Map<String, dynamic>,
      ),
      store: storeBundle,
    );
  }
}
