import 'package:flutter/material.dart';

import '../../models/routes_config.dart';
import '../dialog/dialog_manager.dart';

class NavigationManager {
  NavigationManager({
    required this.routes,
    required this.dialogManager,
  });

  final RoutesConfig routes;
  final DialogManager dialogManager;

  AppRoute? routeByPath(String path) => routes.byPath(path);

  AppRoute? routeByPage(String page) => routes.byPage(page);

  bool openRoute(BuildContext context, String routePath) {
    final route = routes.byPath(routePath);
    if (route == null) {
      dialogManager.showUnknownRoute(context);
      return false;
    }
    if (route.type == 'dialog') {
      dialogManager.openByRoute(context, route);
      return false;
    }
    if (route.type == 'state') return false;
    Navigator.of(context).pushNamed(route.path);
    return true;
  }

  bool openPage(BuildContext context, String routePath) =>
      openRoute(context, routePath);

  void openDialog(BuildContext context, String dialogPage) {
    final route = routes.byPage(dialogPage);
    if (route == null) {
      dialogManager.showUnknownRoute(context);
      return;
    }
    dialogManager.openByRoute(context, route);
  }

  void goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> handleDeepLink(BuildContext context, String path) async {
    openRoute(context, path);
  }
}
