import 'interaction_config.dart';
import 'dialog_config.dart';
import 'animation_config.dart';
import 'routes_config.dart';

class StoreConfigBundle {
  const StoreConfigBundle({
    required this.layout,
    required this.interaction,
    required this.dialog,
    required this.animation,
    required this.routes,
    required this.data,
  });

  final StoreLayoutConfig layout;
  final InteractionConfig interaction;
  final DialogConfig dialog;
  final AnimationConfig animation;
  final RoutesConfig routes;
  final StoreDataConfig data;
}

class StoreLayoutConfig {
  const StoreLayoutConfig({
    required this.meta,
    required this.dialog,
    required this.header,
    required this.tabs,
    required this.shelf,
    required this.productCard,
    required this.footer,
  });

  factory StoreLayoutConfig.fromJson(Map<String, dynamic> json) {
    return StoreLayoutConfig(
      meta: json['meta'] as Map<String, dynamic>? ?? const {},
      dialog: RectSpec.fromJson(json['dialog'] as Map<String, dynamic>? ?? const {}),
      header: StoreHeaderLayout.fromJson(
        json['header'] as Map<String, dynamic>? ?? const {},
      ),
      tabs: StoreTabsLayout.fromJson(json['tabs'] as Map<String, dynamic>? ?? const {}),
      shelf: StoreShelfLayout.fromJson(json['shelf'] as Map<String, dynamic>? ?? const {}),
      productCard: StoreProductCardLayout.fromJson(
        json['productCard'] as Map<String, dynamic>? ?? const {},
      ),
      footer: StoreFooterLayout.fromJson(
        json['footer'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  final Map<String, dynamic> meta;
  final RectSpec dialog;
  final StoreHeaderLayout header;
  final StoreTabsLayout tabs;
  final StoreShelfLayout shelf;
  final StoreProductCardLayout productCard;
  final StoreFooterLayout footer;
}

class RectSpec {
  const RectSpec({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.radius,
    required this.overlay,
  });

  factory RectSpec.fromJson(Map<String, dynamic> json) {
    return RectSpec(
      x: _readDouble(json['x']),
      y: _readDouble(json['y']),
      width: _readDouble(json['width']),
      height: _readDouble(json['height']),
      radius: _readDouble(json['radius'], 0),
      overlay: '${json['overlay'] ?? ''}',
    );
  }

  final double x;
  final double y;
  final double width;
  final double height;
  final double radius;
  final String overlay;
}

class StoreHeaderLayout {
  const StoreHeaderLayout({required this.title, required this.closeButton});
  factory StoreHeaderLayout.fromJson(Map<String, dynamic> json) {
    return StoreHeaderLayout(
      title: RectSpec.fromJson(json['title'] as Map<String, dynamic>? ?? const {}),
      closeButton: RectSpec.fromJson(
        json['closeButton'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
  final RectSpec title;
  final RectSpec closeButton;
}

class StoreTabsLayout {
  const StoreTabsLayout({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.itemWidth,
    required this.itemHeight,
    required this.gap,
  });
  factory StoreTabsLayout.fromJson(Map<String, dynamic> json) {
    return StoreTabsLayout(
      x: _readDouble(json['x']),
      y: _readDouble(json['y']),
      width: _readDouble(json['width']),
      height: _readDouble(json['height']),
      itemWidth: _readDouble(json['itemWidth']),
      itemHeight: _readDouble(json['itemHeight']),
      gap: _readDouble(json['gap']),
    );
  }
  final double x;
  final double y;
  final double width;
  final double height;
  final double itemWidth;
  final double itemHeight;
  final double gap;
}

class StoreShelfLayout {
  const StoreShelfLayout({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.columns,
    required this.rows,
    required this.cellWidth,
    required this.cellHeight,
    required this.gapX,
    required this.gapY,
  });
  factory StoreShelfLayout.fromJson(Map<String, dynamic> json) {
    return StoreShelfLayout(
      x: _readDouble(json['x']),
      y: _readDouble(json['y']),
      width: _readDouble(json['width']),
      height: _readDouble(json['height']),
      columns: _readInt(json['columns']),
      rows: _readInt(json['rows']),
      cellWidth: _readDouble(json['cellWidth']),
      cellHeight: _readDouble(json['cellHeight']),
      gapX: _readDouble(json['gapX']),
      gapY: _readDouble(json['gapY']),
    );
  }
  final double x;
  final double y;
  final double width;
  final double height;
  final int columns;
  final int rows;
  final double cellWidth;
  final double cellHeight;
  final double gapX;
  final double gapY;
}

class StoreProductCardLayout {
  const StoreProductCardLayout({
    required this.image,
    required this.name,
    required this.priceTag,
  });
  factory StoreProductCardLayout.fromJson(Map<String, dynamic> json) {
    return StoreProductCardLayout(
      image: RectSpec.fromJson(json['image'] as Map<String, dynamic>? ?? const {}),
      name: RectSpec.fromJson(json['name'] as Map<String, dynamic>? ?? const {}),
      priceTag: RectSpec.fromJson(json['priceTag'] as Map<String, dynamic>? ?? const {}),
    );
  }
  final RectSpec image;
  final RectSpec name;
  final RectSpec priceTag;
}

class StoreFooterLayout {
  const StoreFooterLayout({
    required this.coinInfo,
    required this.walletButton,
    required this.refreshButton,
  });
  factory StoreFooterLayout.fromJson(Map<String, dynamic> json) {
    return StoreFooterLayout(
      coinInfo: RectSpec.fromJson(json['coinInfo'] as Map<String, dynamic>? ?? const {}),
      walletButton: RectSpec.fromJson(
        json['walletButton'] as Map<String, dynamic>? ?? const {},
      ),
      refreshButton: RectSpec.fromJson(
        json['refreshButton'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
  final RectSpec coinInfo;
  final RectSpec walletButton;
  final RectSpec refreshButton;
}

class StoreDataConfig {
  const StoreDataConfig({
    required this.currency,
    required this.categories,
    required this.items,
    required this.purchaseRules,
  });

  factory StoreDataConfig.fromJson(Map<String, dynamic> json) {
    return StoreDataConfig(
      currency: StoreCurrency.fromJson(
        json['currency'] as Map<String, dynamic>? ?? const {},
      ),
      categories: json['categories'] is List
          ? (json['categories'] as List)
              .whereType<Map<String, dynamic>>()
              .map(StoreCategory.fromJson)
              .toList(growable: false)
          : const [],
      items: json['items'] is List
          ? (json['items'] as List)
              .whereType<Map<String, dynamic>>()
              .map(StoreItem.fromJson)
              .toList(growable: false)
          : const [],
      purchaseRules: StorePurchaseRules.fromJson(
        json['purchaseRules'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  final StoreCurrency currency;
  final List<StoreCategory> categories;
  final List<StoreItem> items;
  final StorePurchaseRules purchaseRules;
}

class StoreCurrency {
  const StoreCurrency({
    required this.primary,
    required this.displayName,
  });

  factory StoreCurrency.fromJson(Map<String, dynamic> json) {
    return StoreCurrency(
      primary: '${json['primary'] ?? ''}',
      displayName: '${json['displayName'] ?? ''}',
    );
  }

  final String primary;
  final String displayName;
}

class StoreCategory {
  const StoreCategory({
    required this.id,
    required this.name,
  });

  factory StoreCategory.fromJson(Map<String, dynamic> json) {
    return StoreCategory(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
    );
  }

  final String id;
  final String name;
}

class StoreItem {
  const StoreItem({
    required this.id,
    required this.name,
    required this.category,
    required this.rarity,
    required this.price,
    required this.currency,
    required this.owned,
    required this.icon,
    required this.description,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      category: '${json['category'] ?? ''}',
      rarity: '${json['rarity'] ?? ''}',
      price: _readInt(json['price']),
      currency: '${json['currency'] ?? ''}',
      owned: _readInt(json['owned']),
      icon: '${json['icon'] ?? ''}',
      description: '${json['description'] ?? ''}',
    );
  }

  final String id;
  final String name;
  final String category;
  final String rarity;
  final int price;
  final String currency;
  final int owned;
  final String icon;
  final String description;
}

class StorePurchaseRules {
  const StorePurchaseRules({
    required this.tapOnceBuyOne,
    required this.confirmBeforePurchase,
    required this.insufficientCurrencyAction,
    required this.insufficientCurrencyTarget,
    required this.successDialog,
  });

  factory StorePurchaseRules.fromJson(Map<String, dynamic> json) {
    return StorePurchaseRules(
      tapOnceBuyOne: json['tapOnceBuyOne'] != false,
      confirmBeforePurchase: json['confirmBeforePurchase'] != false,
      insufficientCurrencyAction: '${json['insufficientCurrencyAction'] ?? ''}',
      insufficientCurrencyTarget: '${json['insufficientCurrencyTarget'] ?? ''}',
      successDialog: '${json['successDialog'] ?? ''}',
    );
  }

  final bool tapOnceBuyOne;
  final bool confirmBeforePurchase;
  final String insufficientCurrencyAction;
  final String insufficientCurrencyTarget;
  final String successDialog;
}

double _readDouble(Object? value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

int _readInt(Object? value) {
  if (value is num) return value.round();
  return int.tryParse('$value') ?? 0;
}
