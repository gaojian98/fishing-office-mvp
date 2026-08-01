import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../animation/animation_manager.dart';
import '../dialog/dialog_manager.dart';
import '../interaction/interaction_manager.dart';
import '../managers/app_managers.dart';
import '../navigation/navigation_manager.dart';
import '../providers/app_providers.dart';
import '../../services/home_config_loader.dart';
import '../../models/animation_config.dart';
import '../../models/dialog_config.dart';
import '../../models/fish_collection_config.dart';
import '../../models/honor_config.dart';
import '../../models/inventory_config.dart';
import '../../models/guide_config.dart';
import '../../models/profile_config.dart';
import '../../models/settings_config.dart';
import '../../models/assets_config.dart';
import '../../models/transaction_config.dart';
import '../../models/interaction_config.dart';
import '../../models/layout_config.dart';
import '../../models/routes_config.dart';
import '../../models/store_config.dart';
import '../../models/task_config.dart';

ProviderContainer buildRuntimeContainer({
  required HomeConfigRuntimeBundle home,
  required StoreConfigBundle store,
}) {
  final settingsManager = SettingsManagerView(home.settings);
  final transactionManager =
      TransactionManagerView.fromConfig(home.transactions);
  final animationManager = AnimationManager(home.animation);
  final dialogManager = DialogManager(
    routes: home.routes,
    dialog: home.dialog,
    guide: home.guide,
    guideLayout: home.guideLayout,
    honor: home.honor,
    honorLayout: home.honorLayout,
    inventory: home.inventory,
    inventoryLayout: home.inventoryLayout,
    fishCollection: home.fishCollection,
    fishCollectionLayout: home.fishCollectionLayout,
    profile: home.profile,
    settings: home.settings,
    settingsLayout: home.settingsLayout,
    profileLayout: home.profileLayout,
    profileTransactionsLayout: home.profileTransactionsLayout,
    assets: home.assets,
    transactions: home.transactions,
    task: home.task,
    settingsManager: settingsManager,
    transactionManager: transactionManager,
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
      animationManagerProvider.overrideWith((ref) => animationManager),
      settingsManagerProvider.overrideWith((ref) => settingsManager),
      transactionManagerProvider.overrideWith((ref) => transactionManager),
      dialogManagerProvider.overrideWith((ref) => dialogManager),
      navigationManagerProvider.overrideWith((ref) => navigationManager),
      interactionManagerProvider.overrideWith((ref) => interactionManager),
    ],
  );
}

class HomeConfigRuntimeBundle {
  const HomeConfigRuntimeBundle({
    required this.layout,
    required this.guideLayout,
    required this.interaction,
    required this.animation,
    required this.routes,
    required this.dialog,
    required this.guide,
    required this.honor,
    required this.honorLayout,
    required this.inventory,
    required this.inventoryLayout,
    required this.fishCollection,
    required this.fishCollectionLayout,
    required this.profile,
    required this.settings,
    required this.settingsLayout,
    required this.assets,
    required this.transactions,
    required this.profileLayout,
    required this.profileTransactionsLayout,
    required this.task,
  });

  factory HomeConfigRuntimeBundle.fromHomeBundle(HomeConfigBundle bundle) {
    return HomeConfigRuntimeBundle(
      layout: bundle.layout,
      guideLayout: bundle.guideLayout,
      interaction: bundle.interaction,
      animation: bundle.animation,
      routes: bundle.routes,
      dialog: bundle.dialog,
      guide: bundle.guide,
      honor: bundle.honor,
      honorLayout: bundle.honorLayout,
      inventory: bundle.inventory,
      inventoryLayout: bundle.inventoryLayout,
      fishCollection: bundle.fishCollection,
      fishCollectionLayout: bundle.fishCollectionLayout,
      profile: bundle.profile,
      settings: bundle.settings,
      settingsLayout: bundle.settingsLayout,
      assets: bundle.assets,
      transactions: bundle.transactions,
      profileLayout: bundle.profileLayout,
      profileTransactionsLayout: bundle.profileTransactionsLayout,
      task: bundle.task,
    );
  }

  final LayoutConfig layout;
  final LayoutConfig guideLayout;
  final InteractionConfig interaction;
  final AnimationConfig animation;
  final RoutesConfig routes;
  final DialogConfig dialog;
  final GuideConfig guide;
  final HonorConfig honor;
  final LayoutConfig honorLayout;
  final InventoryConfig inventory;
  final LayoutConfig inventoryLayout;
  final FishCollectionConfig fishCollection;
  final LayoutConfig fishCollectionLayout;
  final ProfileConfig profile;
  final SettingsConfig settings;
  final LayoutConfig settingsLayout;
  final AssetsConfig assets;
  final TransactionConfig transactions;
  final LayoutConfig profileLayout;
  final LayoutConfig profileTransactionsLayout;
  final TaskConfig task;
}
