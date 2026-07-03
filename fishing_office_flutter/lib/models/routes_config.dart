class RoutesConfig {
  const RoutesConfig({
    required this.defaultRoute,
    required this.routes,
    required this.transitions,
    required this.unknownRoute,
  });

  factory RoutesConfig.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    final rawRoutes = json['routes'];
    final rawTransitions = json['transitions'];

    return RoutesConfig(
      defaultRoute: '${meta['defaultRoute'] ?? ''}',
      routes: rawRoutes is List
          ? rawRoutes
              .whereType<Map<String, dynamic>>()
              .map(AppRoute.fromJson)
              .toList(growable: false)
          : const [],
      transitions: rawTransitions is Map<String, dynamic>
          ? rawTransitions.map(
              (key, value) => MapEntry(
                key,
                RouteTransition.fromJson(
                  value is Map<String, dynamic> ? value : const {},
                ),
              ),
            )
          : const {},
      unknownRoute: UnknownRoute.fromJson(
        json['unknownRoute'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  final String defaultRoute;
  final List<AppRoute> routes;
  final Map<String, RouteTransition> transitions;
  final UnknownRoute unknownRoute;

  String get startPath {
    if (defaultRoute.isNotEmpty) return defaultRoute;
    if (routes.isNotEmpty) return routes.first.path;
    return '/';
  }

  AppRoute? get startRoute => byPath(startPath);

  AppRoute? byPath(String? path) {
    if (path == null || path.isEmpty) return null;
    for (final route in routes) {
      if (route.path == path) return route;
    }
    return null;
  }

  AppRoute? byPage(String? page) {
    if (page == null || page.isEmpty) return null;
    for (final route in routes) {
      if (route.page == page) return route;
    }
    return null;
  }

  AppRoute? firstByType(String type) {
    for (final route in routes) {
      if (route.type == type) return route;
    }
    return null;
  }

  RouteTransition transitionFor(AppRoute route) {
    return transitions[route.transition] ??
        const RouteTransition(type: 'fade', durationMs: 200);
  }
}

class AppRoute {
  const AppRoute({
    required this.path,
    required this.page,
    required this.type,
    required this.transition,
  });

  factory AppRoute.fromJson(Map<String, dynamic> json) {
    return AppRoute(
      path: '${json['path'] ?? ''}',
      page: '${json['page'] ?? ''}',
      type: '${json['type'] ?? ''}',
      transition: '${json['transition'] ?? ''}',
    );
  }

  final String path;
  final String page;
  final String type;
  final String transition;
}

class RouteTransition {
  const RouteTransition({
    required this.type,
    required this.durationMs,
  });

  factory RouteTransition.fromJson(Map<String, dynamic> json) {
    return RouteTransition(
      type: '${json['type'] ?? 'fade'}',
      durationMs: _readInt(json['duration'] ?? json['durationMs'], 200),
    );
  }

  final String type;
  final int durationMs;
}

class UnknownRoute {
  const UnknownRoute({
    required this.action,
    required this.title,
    required this.message,
  });

  factory UnknownRoute.fromJson(Map<String, dynamic> json) {
    return UnknownRoute(
      action: '${json['action'] ?? 'showDialog'}',
      title: '${json['title'] ?? 'Coming Soon'}',
      message: '${json['message'] ?? 'This page is under development.'}',
    );
  }

  final String action;
  final String title;
  final String message;
}

int _readInt(Object? value, int fallback) {
  if (value is num) return value.round();
  return int.tryParse('$value') ?? fallback;
}
