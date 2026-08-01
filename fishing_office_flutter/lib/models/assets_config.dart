class AssetsConfig {
  const AssetsConfig({
    required this.title,
    required this.summaryTitle,
    required this.summaryCards,
    required this.statisticsTitle,
    required this.statistics,
  });

  factory AssetsConfig.fromJson(Map<String, dynamic> json) {
    final summaryCardsJson = json['summaryCards'];
    final statisticsJson = json['statistics'];
    return AssetsConfig(
      title: '${json['title'] ?? '资产中心'}',
      summaryTitle: '${json['summaryTitle'] ?? '资产概览'}',
      summaryCards: summaryCardsJson is List
          ? summaryCardsJson
              .whereType<Map<String, dynamic>>()
              .map(AssetMetric.fromJson)
              .toList(growable: false)
          : const [],
      statisticsTitle: '${json['statisticsTitle'] ?? '资产统计'}',
      statistics: statisticsJson is List
          ? statisticsJson
              .whereType<Map<String, dynamic>>()
              .map(AssetStatistic.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  final String title;
  final String summaryTitle;
  final List<AssetMetric> summaryCards;
  final String statisticsTitle;
  final List<AssetStatistic> statistics;
}

class AssetMetric {
  const AssetMetric({
    required this.id,
    required this.label,
    required this.value,
    required this.icon,
  });

  factory AssetMetric.fromJson(Map<String, dynamic> json) {
    return AssetMetric(
      id: '${json['id'] ?? ''}',
      label: '${json['label'] ?? ''}',
      value: '${json['value'] ?? ''}',
      icon: '${json['icon'] ?? ''}',
    );
  }

  final String id;
  final String label;
  final String value;
  final String icon;
}

class AssetStatistic {
  const AssetStatistic({
    required this.id,
    required this.label,
    required this.value,
  });

  factory AssetStatistic.fromJson(Map<String, dynamic> json) {
    return AssetStatistic(
      id: '${json['id'] ?? ''}',
      label: '${json['label'] ?? ''}',
      value: '${json['value'] ?? ''}',
    );
  }

  final String id;
  final String label;
  final String value;
}
