import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/animation_config.dart';
import '../models/honor_config.dart';
import '../models/inventory_config.dart';
import '../models/guide_config.dart';
import '../models/dialog_config.dart';
import '../models/fish_collection_config.dart';
import '../models/profile_config.dart';
import '../models/settings_config.dart';
import '../models/assets_config.dart';
import '../models/transaction_config.dart';
import '../models/interaction_config.dart';
import '../models/layout_config.dart';
import '../models/routes_config.dart';
import '../models/store_config.dart';
import '../models/task_config.dart';
import 'store_config_loader.dart';

class HomeConfigBundle {
  const HomeConfigBundle({
    required this.layout,
    required this.guideLayout,
    required this.honorLayout,
    required this.inventoryLayout,
    required this.fishCollectionLayout,
    required this.profileLayout,
    required this.profileTransactionsLayout,
    required this.interaction,
    required this.animation,
    required this.routes,
    required this.dialog,
    required this.guide,
    required this.honor,
    required this.inventory,
    required this.fishCollection,
    required this.profile,
    required this.settingsLayout,
    required this.settings,
    required this.assets,
    required this.transactions,
    required this.task,
    required this.store,
  });

  final LayoutConfig layout;
  final LayoutConfig guideLayout;
  final LayoutConfig honorLayout;
  final LayoutConfig inventoryLayout;
  final LayoutConfig fishCollectionLayout;
  final LayoutConfig profileLayout;
  final LayoutConfig profileTransactionsLayout;
  final InteractionConfig interaction;
  final AnimationConfig animation;
  final RoutesConfig routes;
  final DialogConfig dialog;
  final GuideConfig guide;
  final HonorConfig honor;
  final InventoryConfig inventory;
  final FishCollectionConfig fishCollection;
  final ProfileConfig profile;
  final LayoutConfig settingsLayout;
  final SettingsConfig settings;
  final AssetsConfig assets;
  final TransactionConfig transactions;
  final TaskConfig task;
  final StoreConfigBundle store;
}

class HomeConfigLoader {
  const HomeConfigLoader();

  Future<HomeConfigBundle> load() async {
    final raw = await Future.wait<Object>([
      rootBundle.loadString('assets/config/office_layout.json'),
      rootBundle.loadString('assets/config/office_interaction.json'),
      rootBundle.loadString('assets/config/office_animation.json'),
      rootBundle.loadString('assets/config/office_routes.json'),
      rootBundle.loadString('assets/config/office_dialog.json'),
      rootBundle.loadString('assets/config/guide.json'),
      rootBundle.loadString('assets/config/honor.json'),
      rootBundle.loadString('assets/config/inventory.json'),
      rootBundle.loadString('assets/config/fish_collection.json'),
      rootBundle.loadString('assets/config/profile.json'),
      rootBundle.loadString('assets/config/settings.json'),
      rootBundle.loadString('assets/config/assets.json'),
      rootBundle.loadString('assets/config/transaction.json'),
      rootBundle.loadString('assets/config/task.json'),
      const StoreConfigLoader().load(),
    ]);

    final storeBundle = raw[14] as StoreConfigBundle;
    final layoutJson = _decodeSection(raw[0] as String, 'home');
    final guideLayoutJson = _decodeSection(raw[0] as String, 'guide');
    final honorLayoutJson = _decodeSection(raw[0] as String, 'honor');
    final inventoryLayoutJson = _decodeSection(raw[0] as String, 'inventory');
    final fishCollectionLayoutJson =
        _decodeSection(raw[0] as String, 'fish_collection');
    final profileLayoutJson = _decodeSection(raw[0] as String, 'profile');
    final profileTransactionsLayoutJson =
        _decodeSection(raw[0] as String, 'profile_transactions');
    final interactionJson = _decodeSection(raw[1] as String, 'home');
    final animationJson = _decodeSection(raw[2] as String, 'home');
    final routesJson = jsonDecode(raw[3] as String) as Map<String, dynamic>;
    final dialogJson = _decodeSection(raw[4] as String, 'home');
    final guideJson = jsonDecode(raw[5] as String) as Map<String, dynamic>;
    final honorJson = jsonDecode(raw[6] as String) as Map<String, dynamic>;
    final inventoryJson = jsonDecode(raw[7] as String) as Map<String, dynamic>;
    final fishCollectionJson =
        jsonDecode(raw[8] as String) as Map<String, dynamic>;
    final profileJson = jsonDecode(raw[9] as String) as Map<String, dynamic>;
    final settingsJson = jsonDecode(raw[10] as String) as Map<String, dynamic>;
    final assetsJson = jsonDecode(raw[11] as String) as Map<String, dynamic>;
    final transactionJson =
        jsonDecode(raw[12] as String) as Map<String, dynamic>;
    final taskJson = jsonDecode(raw[13] as String) as Map<String, dynamic>;
    return HomeConfigBundle(
      layout: LayoutConfig.fromJson(
        layoutJson,
      ),
      guideLayout: LayoutConfig.fromJson(
        guideLayoutJson,
      ),
      honorLayout: LayoutConfig.fromJson(
        honorLayoutJson,
      ),
      inventoryLayout: LayoutConfig.fromJson(
        inventoryLayoutJson,
      ),
      fishCollectionLayout: LayoutConfig.fromJson(
        fishCollectionLayoutJson,
      ),
      profileLayout: LayoutConfig.fromJson(
        profileLayoutJson,
      ),
      profileTransactionsLayout: LayoutConfig.fromJson(
        profileTransactionsLayoutJson,
      ),
      interaction: InteractionConfig.fromJson(
        interactionJson,
      ),
      animation: AnimationConfig.fromJson(
        animationJson,
      ),
      routes: RoutesConfig.fromJson(
        routesJson,
      ),
      dialog: DialogConfig.fromJson(
        dialogJson,
      ),
      guide: GuideConfig.fromJson(
        guideJson['guide'] is Map<String, dynamic>
            ? guideJson['guide'] as Map<String, dynamic>
            : guideJson,
      ),
      honor: HonorConfig.fromJson(
        honorJson['honor'] is Map<String, dynamic>
            ? honorJson['honor'] as Map<String, dynamic>
            : honorJson,
      ),
      inventory: InventoryConfig.fromJson(
        inventoryJson['inventory'] is Map<String, dynamic>
            ? inventoryJson['inventory'] as Map<String, dynamic>
            : inventoryJson,
      ),
      fishCollection: FishCollectionConfig.fromJson(
        fishCollectionJson['collection'] is Map<String, dynamic>
            ? fishCollectionJson['collection'] as Map<String, dynamic>
            : fishCollectionJson,
      ),
      profile: ProfileConfig.fromJson(
        profileJson['profile'] is Map<String, dynamic>
            ? profileJson['profile'] as Map<String, dynamic>
            : profileJson,
      ),
      settingsLayout: LayoutConfig.fromJson(
        _decodeSection(raw[0] as String, 'settings'),
      ),
      settings: SettingsConfig.fromJson(
        settingsJson['settings'] is Map<String, dynamic>
            ? settingsJson['settings'] as Map<String, dynamic>
            : settingsJson,
      ),
      assets: AssetsConfig.fromJson(
        assetsJson['assets'] is Map<String, dynamic>
            ? assetsJson['assets'] as Map<String, dynamic>
            : assetsJson,
      ),
      transactions: TransactionConfig.fromJson(
        transactionJson['transactions'] is Map<String, dynamic>
            ? transactionJson['transactions'] as Map<String, dynamic>
            : transactionJson,
      ),
      task: TaskConfig.fromJson(taskJson),
      store: storeBundle,
    );
  }
}

Map<String, dynamic> _decodeSection(String raw, String section) {
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final value = json[section];
  if (value is Map<String, dynamic>) return value;
  return json;
}
