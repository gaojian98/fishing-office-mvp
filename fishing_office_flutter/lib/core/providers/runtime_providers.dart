import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../animation/animation_manager.dart';
import '../dialog/dialog_manager.dart';
import '../interaction/interaction_manager.dart';
import '../navigation/navigation_manager.dart';
import '../providers/app_providers.dart';
import '../../services/home_config_loader.dart';
import '../../models/animation_config.dart';
import '../../models/dialog_config.dart';
import '../../models/interaction_config.dart';
import '../../models/layout_config.dart';
import '../../models/routes_config.dart';
import '../../models/store_config.dart';

ProviderContainer buildRuntimeContainer({
  required HomeConfigRuntimeBundle home,
  required StoreConfigBundle store,
}) {
  final animationManager = AnimationManager(home.animation);
  final dialogManager = DialogManager(
    routes: home.routes,
    dialog: home.dialog,
    animationManager: animationManager,
  );
  final navigationManager = NavigationManager(
    routes: home.routes,
    dialogManager: dialogManager,
  );
  final interactionManager = InteractionManager(
    config: home.interaction,
    navigationManager: navigationManager,
    dialogManager: dialogManager,
  );

  return ProviderContainer(
    overrides: [
      animationManagerProvider.overrideWithValue(animationManager),
      dialogManagerProvider.overrideWithValue(dialogManager),
      navigationManagerProvider.overrideWithValue(navigationManager),
      interactionManagerProvider.overrideWithValue(interactionManager),
    ],
  );
}

class HomeConfigRuntimeBundle {
  const HomeConfigRuntimeBundle({
    required this.layout,
    required this.interaction,
    required this.animation,
    required this.routes,
    required this.dialog,
  });

  factory HomeConfigRuntimeBundle.fromHomeBundle(HomeConfigBundle bundle) {
    return HomeConfigRuntimeBundle(
      layout: bundle.layout,
      interaction: bundle.interaction,
      animation: bundle.animation,
      routes: bundle.routes,
      dialog: bundle.dialog,
    );
  }

  final LayoutConfig layout;
  final InteractionConfig interaction;
  final AnimationConfig animation;
  final RoutesConfig routes;
  final DialogConfig dialog;
}
