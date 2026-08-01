import 'dart:ui';

class LayoutConfig {
  const LayoutConfig({
    required this.designSize,
    required this.elements,
  });

  factory LayoutConfig.fromJson(Map<String, dynamic> json) {
    final size = _readDesignSize(json);
    final elements = _readElements(json);
    return LayoutConfig(
      designSize: Size(
        _readDouble(size['width'], 390),
        _readDouble(size['height'], 844),
      ),
      elements: elements,
    );
  }

  final Size designSize;
  final List<LayoutElement> elements;

  LayoutElement? byId(String id) {
    for (final element in elements) {
      if (element.id == id) return element;
    }
    return null;
  }
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

List<LayoutElement> _readElements(Map<String, dynamic> json) {
  final rawElements = json['elements'];
  if (rawElements is List) {
    return rawElements
        .whereType<Map<String, dynamic>>()
        .map(LayoutElement.fromJson)
        .where((element) => element.enabled)
        .toList(growable: false);
  }

  return _readFishCollectionElements(json);
}

List<LayoutElement> _readFishCollectionElements(Map<String, dynamic> json) {
  final meta = json['meta'];
  if (meta is! Map<String, dynamic> || meta['page'] != 'FishCollection') {
    return const [];
  }

  final elements = <LayoutElement>[];
  void add(String id, Object? value, String type) {
    if (value is! Map<String, dynamic>) return;
    elements.add(
      LayoutElement.fromJson({
        'id': id,
        'type': type,
        'layer': 'fish_collection',
        ...value,
      }),
    );
  }

  add('collection_dialog', json['dialog'], 'panel');

  final dialog = json['dialog'];
  if (dialog is Map<String, dynamic>) {
    elements.add(
      LayoutElement.fromJson({
        'id': 'collection_header',
        'type': 'panel',
        'layer': 'fish_collection',
        'x': dialog['x'],
        'y': dialog['y'],
        'width': dialog['width'],
        'height': 112,
      }),
    );
  }

  final header = json['header'];
  if (header is Map<String, dynamic>) {
    add('collection_title', header['title'], 'text');
    add('collection_close', header['closeButton'], 'button');
  }

  add('collection_stats', json['stats'], 'panel');
  add('collection_sidebar', json['sidebar'], 'panel');
  add('collection_detail', json['detail'], 'panel');
  add('collection_preview', json['preview'], 'panel');
  add('collection_name', json['name'], 'text');
  add('collection_condition', json['condition'], 'text');
  add('collection_story', json['story'], 'text');
  add('collection_footer', json['footer'], 'panel');
  add('collection_prev', json['prevButton'], 'button');
  add('collection_next', json['nextButton'], 'button');

  return elements.where((element) => element.enabled).toList(growable: false);
}
