import 'dart:ui';

class LayoutConfig {
  const LayoutConfig({
    required this.designSize,
    required this.elements,
  });

  factory LayoutConfig.fromJson(Map<String, dynamic> json) {
    final size = _readDesignSize(json);
    final rawElements = json['elements'];
    return LayoutConfig(
      designSize: Size(
        _readDouble(size['width'], 390),
        _readDouble(size['height'], 844),
      ),
      elements: rawElements is List
          ? rawElements
              .whereType<Map<String, dynamic>>()
              .map(LayoutElement.fromJson)
              .where((element) => element.enabled)
              .toList(growable: false)
          : const [],
    );
  }

  final Size designSize;
  final List<LayoutElement> elements;
}

class LayoutElement {
  const LayoutElement({
    required this.id,
    required this.name,
    required this.label,
    required this.type,
    required this.layer,
    required this.action,
    required this.feedback,
    required this.animation,
    required this.zIndex,
    required this.rect,
    required this.enabled,
  });

  factory LayoutElement.fromJson(Map<String, dynamic> json) {
    final rect = json['rect'] as Map<String, dynamic>? ?? const {};
    final name = '${json['name'] ?? json['label'] ?? json['id'] ?? ''}';
    return LayoutElement(
      id: '${json['id'] ?? ''}',
      name: name,
      label: '${json['label'] ?? name}',
      type: '${json['type'] ?? ''}',
      layer: '${json['layer'] ?? ''}',
      action: '${json['action'] ?? ''}',
      feedback: '${json['feedback'] ?? ''}',
      animation: '${json['animation'] ?? ''}',
      zIndex: _readDouble(json['zIndex'], 0),
      rect: Rect.fromLTWH(
        _readDouble(rect['x'] ?? json['x'], 0),
        _readDouble(rect['y'] ?? json['y'], 0),
        _readDouble(rect['width'] ?? json['width'], 0),
        _readDouble(rect['height'] ?? json['height'], 0),
      ),
      enabled: json['enabled'] != false && json['visible'] != false,
    );
  }

  final String id;
  final String name;
  final String label;
  final String type;
  final String layer;
  final String action;
  final String feedback;
  final String animation;
  final double zIndex;
  final Rect rect;
  final bool enabled;

  bool get isButton => type == 'button';

  bool get isAnimatedObject => type == 'animated_object';
}

double _readDouble(Object? value, double fallback) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

Map<String, dynamic> _readDesignSize(Map<String, dynamic> json) {
  final coordinateSystem = json['coordinateSystem'];
  if (coordinateSystem is Map<String, dynamic>) {
    final base = coordinateSystem['base'];
    if (base is Map<String, dynamic>) return base;
  }

  final design = json['design'];
  if (design is Map<String, dynamic>) {
    final targetSize = design['targetSize'];
    if (targetSize is Map<String, dynamic>) return targetSize;
  }

  final meta = json['meta'];
  if (meta is Map<String, dynamic>) {
    final designSize = meta['designSize'];
    if (designSize is Map<String, dynamic>) return designSize;
  }

  final designSize = json['designSize'];
  if (designSize is Map<String, dynamic>) return designSize;

  return const {'width': 390, 'height': 844};
}
