class FishCollectionConfig {
  const FishCollectionConfig({
    required this.meta,
    required this.title,
    required this.labels,
    required this.stats,
    required this.footer,
    required this.emptyState,
    required this.lockedState,
    required this.categories,
    required this.fishes,
    required this.defaultFishId,
  });

  factory FishCollectionConfig.fromJson(Map<String, dynamic> json) {
    final source = json['collection'] is Map<String, dynamic>
        ? json['collection'] as Map<String, dynamic>
        : json;
    return FishCollectionConfig(
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : const {},
      title: '${source['title'] ?? '海洋图鉴'}',
      labels: source['labels'] is Map<String, dynamic>
          ? source['labels'] as Map<String, dynamic>
          : const {},
      stats: FishCollectionStats.fromJson(
        source['stats'] is Map<String, dynamic>
            ? source['stats'] as Map<String, dynamic>
            : const {},
      ),
      footer: FishCollectionFooter.fromJson(
        source['footer'] is Map<String, dynamic>
            ? source['footer'] as Map<String, dynamic>
            : const {},
      ),
      emptyState: FishCollectionEmptyState.fromJson(
        source['emptyState'] is Map<String, dynamic>
            ? source['emptyState'] as Map<String, dynamic>
            : const {},
      ),
      lockedState: FishCollectionLockedState.fromJson(
        source['lockedState'] is Map<String, dynamic>
            ? source['lockedState'] as Map<String, dynamic>
            : const {},
      ),
      categories: source['categories'] is List
          ? (source['categories'] as List)
              .whereType<Map<String, dynamic>>()
              .map(FishCollectionCategory.fromJson)
              .toList(growable: false)
          : const [],
      fishes: source['fishes'] is List
          ? (source['fishes'] as List)
              .whereType<Map<String, dynamic>>()
              .map(FishCollectionFish.fromJson)
              .toList(growable: false)
          : const [],
      defaultFishId:
          '${source['defaultFishId'] ?? json['defaultFishId'] ?? ''}',
    );
  }

  final Map<String, dynamic> meta;
  final String title;
  final Map<String, dynamic> labels;
  final FishCollectionStats stats;
  final FishCollectionFooter footer;
  final FishCollectionEmptyState emptyState;
  final FishCollectionLockedState lockedState;
  final List<FishCollectionCategory> categories;
  final List<FishCollectionFish> fishes;
  final String defaultFishId;

  FishCollectionFish? fishById(String id) {
    for (final fish in fishes) {
      if (fish.id == id) return fish;
    }
    return null;
  }
}

class FishCollectionStats {
  const FishCollectionStats({
    required this.collectedLabel,
    required this.completionLabel,
    required this.totalWeightLabel,
    required this.heaviestLabel,
  });

  factory FishCollectionStats.fromJson(Map<String, dynamic> json) {
    return FishCollectionStats(
      collectedLabel: '${json['collectedLabel'] ?? '已收集'}',
      completionLabel: '${json['completionLabel'] ?? '完成度'}',
      totalWeightLabel: '${json['totalWeightLabel'] ?? '总重量'}',
      heaviestLabel: '${json['heaviestLabel'] ?? '最重鱼'}',
    );
  }

  final String collectedLabel;
  final String completionLabel;
  final String totalWeightLabel;
  final String heaviestLabel;
}

class FishCollectionFooter {
  const FishCollectionFooter({
    required this.previousLabel,
    required this.nextLabel,
    required this.closeLabel,
  });

  factory FishCollectionFooter.fromJson(Map<String, dynamic> json) {
    return FishCollectionFooter(
      previousLabel: '${json['previousLabel'] ?? '上一条'}',
      nextLabel: '${json['nextLabel'] ?? '下一条'}',
      closeLabel: '${json['closeLabel'] ?? '关闭'}',
    );
  }

  final String previousLabel;
  final String nextLabel;
  final String closeLabel;
}

class FishCollectionEmptyState {
  const FishCollectionEmptyState({
    required this.title,
    required this.message,
    required this.buttonLabel,
  });

  factory FishCollectionEmptyState.fromJson(Map<String, dynamic> json) {
    return FishCollectionEmptyState(
      title: '${json['title'] ?? '📖'}',
      message: '${json['message'] ?? '你的图鉴还是空的。\\n快去钓第一条鱼吧！'}',
      buttonLabel: '${json['buttonLabel'] ?? '开始钓鱼'}',
    );
  }

  final String title;
  final String message;
  final String buttonLabel;
}

class FishCollectionLockedState {
  const FishCollectionLockedState({
    required this.imageLabel,
    required this.name,
    required this.description,
    required this.condition,
    required this.placeholder,
  });

  factory FishCollectionLockedState.fromJson(Map<String, dynamic> json) {
    return FishCollectionLockedState(
      imageLabel: '${json['imageLabel'] ?? '黑色剪影'}',
      name: '${json['name'] ?? '？？？'}',
      description: '${json['description'] ?? '尚未发现'}',
      condition: '${json['condition'] ?? '继续探索第二世界……'}',
      placeholder: '${json['placeholder'] ?? '--'}',
    );
  }

  final String imageLabel;
  final String name;
  final String description;
  final String condition;
  final String placeholder;
}

class FishCollectionCategory {
  const FishCollectionCategory({
    required this.id,
    required this.label,
  });

  factory FishCollectionCategory.fromJson(Map<String, dynamic> json) {
    return FishCollectionCategory(
      id: '${json['id'] ?? ''}',
      label: '${json['label'] ?? ''}',
    );
  }

  final String id;
  final String label;
}

class FishCollectionFish {
  const FishCollectionFish({
    required this.id,
    required this.name,
    required this.category,
    required this.rarity,
    required this.icon,
    required this.price,
    required this.averageWeightKg,
    required this.maxWeightKg,
    required this.location,
    required this.rarityRate,
    required this.story,
    required this.description,
    required this.unlockCondition,
    required this.weatherRequirement,
    required this.timeRequirement,
    required this.reward,
  });

  factory FishCollectionFish.fromJson(Map<String, dynamic> json) {
    return FishCollectionFish(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      category: '${json['category'] ?? ''}',
      rarity: '${json['rarity'] ?? 'common'}',
      icon: '${json['icon'] ?? '🐟'}',
      price: _readInt(json['price'], 0),
      averageWeightKg: _readDouble(json['averageWeightKg'], 0),
      maxWeightKg: _readDouble(json['maxWeightKg'], 0),
      location: '${json['location'] ?? ''}',
      rarityRate: '${json['rarityRate'] ?? ''}',
      story: '${json['story'] ?? ''}',
      description: '${json['description'] ?? ''}',
      unlockCondition: '${json['unlockCondition'] ?? ''}',
      weatherRequirement: '${json['weatherRequirement'] ?? ''}',
      timeRequirement: '${json['timeRequirement'] ?? ''}',
      reward: '${json['reward'] ?? ''}',
    );
  }

  final String id;
  final String name;
  final String category;
  final String rarity;
  final String icon;
  final int price;
  final double averageWeightKg;
  final double maxWeightKg;
  final String location;
  final String rarityRate;
  final String story;
  final String description;
  final String unlockCondition;
  final String weatherRequirement;
  final String timeRequirement;
  final String reward;
}

int _readInt(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

double _readDouble(Object? value, double fallback) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}
