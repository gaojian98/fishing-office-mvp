import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/animation/animation_manager.dart';
import 'core/app_theme.dart';
import 'core/bootstrap/fishing_office_scope.dart';
import 'core/dialog/dialog_manager.dart';
import 'core/interaction/interaction_manager.dart';
import 'core/managers/achievement_runtime_manager.dart';
import 'core/managers/app_managers.dart';
import 'core/navigation/navigation_manager.dart';
import 'core/responsive/responsive_manager.dart';
import 'core/providers/app_providers.dart';
import 'services/home_config_loader.dart';
import 'models/routes_config.dart';
import 'pages/home/home_page.dart';
import 'pages/fishing/fishing_page.dart';
import 'pages/collection/fish_collection_dialog_page.dart';
import 'pages/inventory/inventory_dialog_page.dart';
import 'pages/profile/settings_dialog_page.dart';
import 'pages/result/result_page.dart';
import 'pages/store/store_dialog_page.dart';
import 'pages/wallet/wallet_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const ProviderScope(child: FishingOfficeApp()));
}

class FishingOfficeApp extends ConsumerWidget {
  const FishingOfficeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeConfigBundleProvider);
    final storeAsync = ref.watch(storeConfigBundleProvider);
    return homeAsync.when(
      data: (homeBundle) => storeAsync.when(
        data: (storeBundle) {
          final animationManager = AnimationManager(homeBundle.animation);
          final settingsManager = SettingsManagerView(homeBundle.settings);
          final transactionManager =
              TransactionManagerView.fromConfig(homeBundle.transactions);
          final dialogManager = DialogManager(
            routes: homeBundle.routes,
            dialog: homeBundle.dialog,
            guide: homeBundle.guide,
            guideLayout: homeBundle.guideLayout,
            honor: homeBundle.honor,
            honorLayout: homeBundle.honorLayout,
            inventory: homeBundle.inventory,
            inventoryLayout: homeBundle.inventoryLayout,
            fishCollection: homeBundle.fishCollection,
            fishCollectionLayout: homeBundle.fishCollectionLayout,
            profile: homeBundle.profile,
            settings: homeBundle.settings,
            settingsLayout: homeBundle.settingsLayout,
            profileLayout: homeBundle.profileLayout,
            profileTransactionsLayout: homeBundle.profileTransactionsLayout,
            assets: homeBundle.assets,
            transactions: homeBundle.transactions,
            task: homeBundle.task,
            settingsManager: settingsManager,
            transactionManager: transactionManager,
            animationManager: animationManager,
          );
          final navigationManager = NavigationManager(
            routes: homeBundle.routes,
            dialogManager: dialogManager,
          );
          final interactionManager = InteractionManager(
            config: homeBundle.interaction,
            navigationManager: navigationManager,
            dialogManager: dialogManager,
          );

          return ProviderScope(
            overrides: [
              animationManagerProvider.overrideWith((ref) => animationManager),
              settingsManagerProvider.overrideWith((ref) => settingsManager),
              transactionManagerProvider
                  .overrideWith((ref) => transactionManager),
              dialogManagerProvider.overrideWith((ref) => dialogManager),
              navigationManagerProvider
                  .overrideWith((ref) => navigationManager),
              interactionManagerProvider
                  .overrideWith((ref) => interactionManager),
            ],
            child: _RuntimeSyncBridge(
              child: MaterialApp(
                title: '上班摸鱼',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(),
                initialRoute: homeBundle.routes.startPath,
                onGenerateRoute: (settings) => _buildRoute(
                  settings,
                  homeBundle.routes,
                  homeBundle,
                  dialogManager,
                ),
                builder: (context, child) {
                  final responsive = ResponsiveManager.fromContext(context);
                  return FishingOfficeScope(
                    bundle: homeBundle,
                    responsive: responsive,
                    interactionManager: interactionManager,
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              ),
            ),
          );
        },
        loading: () => const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: ColoredBox(color: Colors.black),
        ),
        error: (error, stackTrace) => MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: Center(child: Text('加载失败: $error'))),
        ),
      ),
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ColoredBox(color: Colors.black),
      ),
      error: (error, stackTrace) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: Text('加载失败: $error')),
        ),
      ),
    );
  }

  Route<dynamic> _buildRoute(
    RouteSettings settings,
    RoutesConfig routes,
    HomeConfigBundle homeBundle,
    DialogManager dialogManager,
  ) {
    if (settings.name == '/home' ||
        settings.name == '/' ||
        settings.name == null) {
      return _pageRoute(
        settings: settings,
        transition: const RouteTransition(type: 'fade', durationMs: 180),
        child: const HomePage(),
      );
    }

    if (settings.name == '/store') {
      return _pageRoute(
        settings: settings,
        transition: const RouteTransition(type: 'slideLeft', durationMs: 220),
        child: StoreDialogPage(dialogManager: dialogManager),
      );
    }

    if (settings.name == '/wallet') {
      return _pageRoute(
        settings: settings,
        transition: const RouteTransition(type: 'slideLeft', durationMs: 220),
        child: const WalletPage(),
      );
    }

    if (settings.name == '/bag') {
      return _pageRoute(
        settings: settings,
        transition: const RouteTransition(type: 'slideLeft', durationMs: 220),
        child: InventoryDialogPage(
          inventory: homeBundle.inventory,
          layout: homeBundle.inventoryLayout,
          dialogManager: dialogManager,
        ),
      );
    }

    if (settings.name == '/settings') {
      return _pageRoute(
        settings: settings,
        transition: const RouteTransition(type: 'fade', durationMs: 200),
        child: SettingsDialogPage(
          settings: homeBundle.settings,
          layout: homeBundle.settingsLayout,
          manager: dialogManager.settingsManager,
          dialogManager: dialogManager,
        ),
      );
    }

    if (settings.name == '/collection') {
      return _pageRoute(
        settings: settings,
        transition: const RouteTransition(type: 'fade', durationMs: 180),
        child: FishCollectionDialogPage(
          collection: homeBundle.fishCollection,
          layout: homeBundle.fishCollectionLayout,
        ),
      );
    }

    if (settings.name == '/fishing') {
      return _pageRoute(
        settings: settings,
        transition: const RouteTransition(type: 'fade', durationMs: 200),
        child: const FishingPage(),
      );
    }

    if (settings.name == '/result') {
      return _pageRoute(
        settings: settings,
        transition: const RouteTransition(type: 'fade', durationMs: 180),
        child: const ResultPage(),
      );
    }

    return _pageRoute(
      settings: settings,
      transition: const RouteTransition(type: 'fade', durationMs: 180),
      child: const HomePage(),
    );
  }

  PageRouteBuilder<dynamic> _pageRoute({
    required RouteSettings settings,
    required RouteTransition transition,
    required Widget child,
  }) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: Duration(milliseconds: transition.durationMs),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (transition.type == 'slideLeft') {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        }
        if (transition.type == 'slideRight') {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        }
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

class _RuntimeSyncBridge extends ConsumerWidget {
  const _RuntimeSyncBridge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(fishingProvider);
    ref.watch(walletManagerProvider);
    ref.watch(inventoryManagerProvider);
    ref.watch(collectionManagerProvider);
    ref.watch(transactionManagerProvider);
    ref.watch(taskManagerProvider);
    final questRuntime = ref.watch(questRuntimeManagerProvider);
    final achievementRuntime = ref.watch(achievementRuntimeManagerProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quest = questRuntime.valueOrNull;
      if (quest != null) {
        quest.syncFromState(
          fishing: ref.read(fishingProvider),
          inventory: ref.read(inventoryManagerProvider),
          collection: ref.read(collectionManagerProvider),
          transactions: ref.read(transactionManagerProvider),
        );
      }
      final achievement = achievementRuntime.valueOrNull;
      if (achievement != null) {
        final fishing = ref.read(fishingProvider);
        final inventory = ref.read(inventoryManagerProvider);
        final collection = ref.read(collectionManagerProvider);
        final transactions = ref.read(transactionManagerProvider);
        final wallet = ref.read(walletManagerProvider);
        final sellCount = transactions.records
            .where((record) =>
                record.type == 'sell_fish' || record.type == 'sell_item')
            .length;
        achievement.updateAchievementProgress(
          AchievementEvent(
            type: 'ui_runtime_sync',
            amount: 0,
            payload: {
              'fishing_count': fishing.fishingEvents
                  .where((event) => event.type == 'started')
                  .length,
              'sell_count': sellCount,
              'release_count': inventory.releaseCount,
              'inventory_count': inventory.entries.fold<int>(
                0,
                (sum, entry) => sum + entry.quantity,
              ),
              'collection_count': collection.records.length,
              'fish_coin_total': wallet.fishCoin,
            },
          ),
        );
      }
    });

    return child;
  }
}
