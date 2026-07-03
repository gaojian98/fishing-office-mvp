import 'package:flutter/widgets.dart';

import '../../services/home_config_loader.dart';
import '../interaction/interaction_manager.dart';
import '../responsive/responsive_manager.dart';

class FishingOfficeScope extends InheritedWidget {
  const FishingOfficeScope({
    super.key,
    required this.bundle,
    required this.responsive,
    required this.interactionManager,
    required super.child,
  });

  final HomeConfigBundle bundle;
  final ResponsiveManager responsive;
  final InteractionManager interactionManager;

  static FishingOfficeScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FishingOfficeScope>();
    assert(scope != null, 'FishingOfficeScope not found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(FishingOfficeScope oldWidget) {
    return bundle != oldWidget.bundle ||
        responsive != oldWidget.responsive ||
        interactionManager != oldWidget.interactionManager;
  }
}
