import 'package:flutter/material.dart';

import '../../models/routes_config.dart';
import '../dialog/dialog_manager.dart';
import '../managers/app_managers.dart';

class AppRouter {
  const AppRouter({
    required this.routes,
    required this.dialogManager,
    required this.guard,
  });

  final RoutesConfig routes;
  final DialogManager dialogManager;
  final RouteGuard guard;

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final route = routes.byPath(settings.name) ?? routes.startRoute;
    if (route == null) return null;
    if (!guard.allow(route.path)) return null;
    if (route.type == 'dialog') {
      return PageRouteBuilder<void>(
        settings: settings,
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => const SizedBox.shrink(),
      );
    }
    if (route.path == routes.startPath) {
      return null;
    }
    return null;
  }
}
