class InventoryConfig {
  const InventoryConfig({
    required this.meta,
    required this.title,
    required this.capacity,
    required this.categories,
    required this.footer,
    required this.emptyState,
    required this.detail,
    required this.catalog,
  });

  factory InventoryConfig.fromJson(Map<String, dynamic> json) {
    final source = json['inventory'] is Map<String, dynamic>
        ? json['inventory'] as Map<String, dynamic>
        : json;
    return InventoryConfig(
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : const {},
      title: '${source['title'] ?? '我的背包'}',
      capacity: InventoryCapacity.fromJson(
        source['capacity'] is Map<String, dynamic>
            ? source['capacity'] as Map<String, dynamic>
            : const {},
      ),
      categories: source['categories'] is List
          ? (source['categories'] as List)
              .whereType<Map<String, dynamic>>()
              .map(InventoryCategory.fromJson)
              .toList(growable: false)
          : const [],
      footer: source['footer'] is Map<String, dynamic>
          ? source['footer'] as Map<String, dynamic>
          : const {},
      emptyState: source['emptyState'] is Map<String, dynamic>
          ? source['emptyState'] as Map<String, dynamic>
          : const {},
      detail: source['detail'] is Map<String, dynamic>
          ? source['detail'] as Map<String, dynamic>
          : const {},
      catalog: source['catalog'] is List
          ? (source['catalog'] as List)
              .whereType<Map<String, dynamic>>()
              .map(InventoryCatalogItem.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  final Map<String, dynamic> meta;
  final String title;
  final InventoryCapacity capacity;
  final List<InventoryCategory> categories;
  final Map<String, dynamic> footer;
  final Map<String, dynamic> emptyState;
  final Map<String, dynamic> detail;
  final List<InventoryCatalogItem> catalog;

  InventoryCatalogItem? itemById(String id) {
    for (final item in catalog) {
      if (item.id == id) return item;
    }
    return null;
  }
}

class InventoryCapacity {
  const InventoryCapacity({
    required this.currentLabel,
    required this.maxLabel,
    required this.organizeLabel,
    required this.filterLabel,
  });

  factory InventoryCapacity.fromJson(Map<String, dynamic> json) {
    return InventoryCapacity(
      currentLabel: '${json['currentLabel'] ?? '容量'}',
      maxLabel: '${json['maxLabel'] ?? '300'}',
      organizeLabel: '${json['organizeLabel'] ?? '整理'}',
      filterLabel: '${json['filterLabel'] ?? '筛选'}',
    );
  }

  final String currentLabel;
  final String maxLabel;
  final String organizeLabel;
  final String filterLabel;
}

class InventoryCategory {
  const InventoryCategory({
    required this.id,
    required this.label,
  });

  factory InventoryCategory.fromJson(Map<String, dynamic> json) {
    return InventoryCategory(
      id: '${json['id'] ?? ''}',
      label: '${json['label'] ?? ''}',
    );
  }

  final String id;
  final String label;
}

class InventoryCatalogItem {
  const InventoryCatalogItem({
    required this.id,
    required this.name,
    required this.category,
    required this.rarity,
    required this.icon,
    required this.description,
    required this.usage,
    required this.obtainSource,
    required this.sellPrice,
    required this.canUse,
    required this.canSell,
    required this.badge,
    required this.initialQuantity,
    required this.sortOrder,
    required this.attributes,
  });

  factory InventoryCatalogItem.fromJson(Map<String, dynamic> json) {
    return InventoryCatalogItem(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      category: '${json['category'] ?? ''}',
      rarity: '${json['rarity'] ?? 'common'}',
      icon: '${json['icon'] ?? '📦'}',
      description: '${json['description'] ?? ''}',
      usage: '${json['usage'] ?? ''}',
      obtainSource: '${json['obtainSource'] ?? ''}',
      sellPrice: _readInt(json['sellPrice'], 0),
      canUse: json['canUse'] == true,
      canSell: json['canSell'] != false,
      badge: '${json['badge'] ?? ''}',
      initialQuantity: _readInt(
          json['initialQuantity'] ?? json['quantity'] ?? json['owned'], 0),
      sortOrder: _readInt(json['sortOrder'], 999),
      attributes: json['attributes'] is Map<String, dynamic>
          ? json['attributes'] as Map<String, dynamic>
          : const {},
    );
  }

  final String id;
  final String name;
  final String category;
  final String rarity;
  final String icon;
  final String description;
  final String usage;
  final String obtainSource;
  final int sellPrice;
  final bool canUse;
  final bool canSell;
  final String badge;
  final int initialQuantity;
  final int sortOrder;
  final Map<String, dynamic> attributes;
}

int _readInt(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}
