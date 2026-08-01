class HonorConfig {
  const HonorConfig({
    required this.meta,
    required this.title,
    required this.player,
    required this.statistics,
    required this.footer,
    required this.statusLabels,
    required this.categories,
    required this.badges,
  });

  factory HonorConfig.fromJson(Map<String, dynamic> json) {
    return HonorConfig(
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : const {},
      title: '${json['title'] ?? '荣耀大厅'}',
      player: HonorPlayer.fromJson(
        json['player'] is Map<String, dynamic>
            ? json['player'] as Map<String, dynamic>
            : const {},
      ),
      statistics: HonorStatistics.fromJson(
        json['statistics'] is Map<String, dynamic>
            ? json['statistics'] as Map<String, dynamic>
            : const {},
      ),
      footer: json['footer'] is Map<String, dynamic>
          ? json['footer'] as Map<String, dynamic>
          : const {},
      statusLabels: json['statusLabels'] is Map<String, dynamic>
          ? (json['statusLabels'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, '$value'))
          : const {'not_obtained': '未获得', 'obtained': '已获得', 'equipped': '已佩戴'},
      categories: json['categories'] is List
          ? (json['categories'] as List)
              .whereType<Map<String, dynamic>>()
              .map(HonorCategory.fromJson)
              .toList(growable: false)
          : const [],
      badges: json['badges'] is List
          ? (json['badges'] as List)
              .whereType<Map<String, dynamic>>()
              .map(HonorBadge.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  final Map<String, dynamic> meta;
  final String title;
  final HonorPlayer player;
  final HonorStatistics statistics;
  final Map<String, dynamic> footer;
  final Map<String, String> statusLabels;
  final List<HonorCategory> categories;
  final List<HonorBadge> badges;

  HonorBadge? badgeById(String id) {
    for (final badge in badges) {
      if (badge.id == id) return badge;
    }
    return null;
  }
}

class HonorPlayer {
  const HonorPlayer({
    required this.avatarLabel,
    required this.nickname,
    required this.levelLabel,
    required this.honorValueLabel,
    required this.titleLabel,
  });

  factory HonorPlayer.fromJson(Map<String, dynamic> json) {
    return HonorPlayer(
      avatarLabel: '${json['avatarLabel'] ?? '头像'}',
      nickname: '${json['nickname'] ?? 'FishingPro'}',
      levelLabel: '${json['levelLabel'] ?? 'Lv.1'}',
      honorValueLabel: '${json['honorValueLabel'] ?? '0'}',
      titleLabel: '${json['titleLabel'] ?? '初级摸鱼员'}',
    );
  }

  final String avatarLabel;
  final String nickname;
  final String levelLabel;
  final String honorValueLabel;
  final String titleLabel;
}

class HonorStatistics {
  const HonorStatistics({
    required this.items,
  });

  factory HonorStatistics.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return HonorStatistics(
      items: rawItems is List
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(HonorStatItem.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  final List<HonorStatItem> items;
}

class HonorStatItem {
  const HonorStatItem({
    required this.label,
    required this.value,
  });

  factory HonorStatItem.fromJson(Map<String, dynamic> json) {
    return HonorStatItem(
      label: '${json['label'] ?? ''}',
      value: '${json['value'] ?? ''}',
    );
  }

  final String label;
  final String value;
}

class HonorCategory {
  const HonorCategory({
    required this.id,
    required this.title,
    required this.sortOrder,
    required this.enabled,
  });

  factory HonorCategory.fromJson(Map<String, dynamic> json) {
    return HonorCategory(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? json['label'] ?? ''}',
      sortOrder: _readInt(json['sortOrder']),
      enabled: json['enabled'] != false,
    );
  }

  final String id;
  final String title;
  final int sortOrder;
  final bool enabled;
}

class HonorBadge {
  const HonorBadge({
    required this.id,
    required this.icon,
    required this.name,
    required this.description,
    required this.category,
    required this.metric,
    required this.target,
    required this.progress,
    required this.status,
    required this.sortOrder,
    required this.equipped,
    required this.obtainedAt,
    required this.condition,
    required this.story,
    required this.reward,
    required this.obtained,
    required this.detailTitle,
  });

  factory HonorBadge.fromJson(Map<String, dynamic> json) {
    return HonorBadge(
      id: '${json['id'] ?? ''}',
      icon: '${json['icon'] ?? ''}',
      name: '${json['title'] ?? json['name'] ?? ''}',
      description: '${json['description'] ?? ''}',
      category: '${json['category'] ?? 'badge'}',
      metric: '${json['metric'] ?? ''}',
      target: _readInt(json['target']),
      progress: _readInt(json['progress']),
      status:
          '${json['status'] ?? (json['obtained'] == true ? 'obtained' : 'not_obtained')}',
      sortOrder: _readInt(json['sortOrder']),
      equipped: json['equipped'] == true,
      obtainedAt: '${json['obtainedAt'] ?? ''}',
      condition: '${json['condition'] ?? ''}',
      story: '${json['story'] ?? ''}',
      reward: '${json['reward'] ?? ''}',
      obtained: json['obtained'] == true ||
          json['status'] == 'obtained' ||
          json['status'] == 'equipped',
      detailTitle:
          '${json['detailTitle'] ?? json['title'] ?? json['name'] ?? ''}',
    );
  }

  final String id;
  final String icon;
  final String name;
  final String description;
  final String category;
  final String metric;
  final int target;
  final int progress;
  final String status;
  final int sortOrder;
  final bool equipped;
  final String obtainedAt;
  final String condition;
  final String story;
  final String reward;
  final bool obtained;
  final String detailTitle;
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse('$value') ?? 0;
}
