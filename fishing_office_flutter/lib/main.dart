import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/animation/animation_manager.dart';
import 'core/app_theme.dart';
import 'core/bootstrap/fishing_office_scope.dart';
import 'core/dialog/dialog_manager.dart';
import 'core/interaction/interaction_manager.dart';
import 'core/navigation/navigation_manager.dart';
import 'core/responsive/responsive_manager.dart';
import 'core/providers/app_providers.dart';
import 'models/routes_config.dart';
import 'pages/home/home_page.dart';
import 'pages/inventory/inventory_page.dart';
import 'pages/json_route_page.dart';
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
          final dialogManager = DialogManager(
            routes: homeBundle.routes,
            dialog: homeBundle.dialog,
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
              animationManagerProvider.overrideWithValue(animationManager),
              dialogManagerProvider.overrideWithValue(dialogManager),
              navigationManagerProvider.overrideWithValue(navigationManager),
              interactionManagerProvider.overrideWithValue(interactionManager),
            ],
            child: MaterialApp(
              title: '上班摸鱼',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              initialRoute: homeBundle.routes.startPath,
              onGenerateRoute: (settings) => _buildRoute(settings, homeBundle.routes),
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

  Route<dynamic> _buildRoute(RouteSettings settings, RoutesConfig routes) {
    if (settings.name == '/wallet') {
      return _pageRoute(
        settings: settings,
        transition: const RouteTransition(type: 'slideLeft', durationMs: 220),
        child: const WalletPage(),
      );
    }

    if (settings.name == '/inventory') {
      return _pageRoute(
        settings: settings,
        transition: const RouteTransition(type: 'slideLeft', durationMs: 220),
        child: const InventoryPage(),
      );
    }

    final appRoute = routes.byPath(settings.name) ?? routes.startRoute;
    if (appRoute == null || appRoute.path == routes.startPath) {
      return _pageRoute(
        settings: settings,
        transition: appRoute == null
            ? const RouteTransition(type: 'fade', durationMs: 200)
            : routes.transitionFor(appRoute),
        child: const HomePage(),
      );
    }

    return _pageRoute(
      settings: settings,
      transition: routes.transitionFor(appRoute),
      child: JsonRoutePage(route: appRoute),
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
