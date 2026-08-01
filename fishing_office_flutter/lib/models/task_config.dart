class TaskConfig {
  const TaskConfig({
    required this.meta,
    required this.title,
    required this.categories,
    required this.statusLabels,
    required this.rewardLabels,
    required this.uiLabels,
    required this.emptyMessage,
    required this.claimSuccessMessage,
    required this.tasks,
  });

  factory TaskConfig.fromJson(Map<String, dynamic> json) {
    final source = json['tasks'] is Map<String, dynamic>
        ? json['tasks'] as Map<String, dynamic>
        : json;
    return TaskConfig(
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : const {},
      title: '${source['title'] ?? '今日任务'}',
      categories: source['categories'] is List
          ? (source['categories'] as List)
              .whereType<Map<String, dynamic>>()
              .map(TaskCategoryConfig.fromJson)
              .toList(growable: false)
          : const [],
      statusLabels: source['statusLabels'] is Map<String, dynamic>
          ? source['statusLabels'] as Map<String, dynamic>
          : const {},
      rewardLabels: source['rewardLabels'] is Map<String, dynamic>
          ? source['rewardLabels'] as Map<String, dynamic>
          : const {},
      uiLabels: source['uiLabels'] is Map<String, dynamic>
          ? source['uiLabels'] as Map<String, dynamic>
          : const {},
      emptyMessage: '${source['emptyMessage'] ?? '今天先慢慢来。'}',
      claimSuccessMessage: '${source['claimSuccessMessage'] ?? '奖励已领取。'}',
      tasks: source['items'] is List
          ? (source['items'] as List)
              .whereType<Map<String, dynamic>>()
              .map(TaskItemConfig.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  final Map<String, dynamic> meta;
  final String title;
  final List<TaskCategoryConfig> categories;
  final Map<String, dynamic> statusLabels;
  final Map<String, dynamic> rewardLabels;
  final Map<String, dynamic> uiLabels;
  final String emptyMessage;
  final String claimSuccessMessage;
  final List<TaskItemConfig> tasks;

  String statusLabel(String status) => '${statusLabels[status] ?? status}';
  String uiLabel(String id, String fallback) => '${uiLabels[id] ?? fallback}';
}

class TaskCategoryConfig {
  const TaskCategoryConfig(
      {required this.id,
      required this.label,
      required this.enabled,
      required this.sortOrder});

  factory TaskCategoryConfig.fromJson(Map<String, dynamic> json) {
    return TaskCategoryConfig(
      id: '${json['id'] ?? ''}',
      label: '${json['label'] ?? ''}',
      enabled: json['enabled'] != false,
      sortOrder: _readInt(json['sortOrder'], 999),
    );
  }

  final String id;
  final String label;
  final bool enabled;
  final int sortOrder;
}

class TaskItemConfig {
  const TaskItemConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.metric,
    required this.target,
    required this.progress,
    required this.reward,
    required this.status,
    required this.sortOrder,
    required this.icon,
  });

  factory TaskItemConfig.fromJson(Map<String, dynamic> json) {
    return TaskItemConfig(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      description: '${json['description'] ?? ''}',
      category: '${json['category'] ?? ''}',
      metric: '${json['metric'] ?? ''}',
      target: _readInt(json['target'], 1),
      progress: _readInt(json['progress'], 0),
      reward: TaskRewardConfig.fromJson(
        json['reward'] is Map<String, dynamic>
            ? json['reward'] as Map<String, dynamic>
            : const {},
      ),
      status: '${json['status'] ?? 'not_started'}',
      sortOrder: _readInt(json['sortOrder'], 999),
      icon: '${json['icon'] ?? '📋'}',
    );
  }

  final String id;
  final String title;
  final String description;
  final String category;
  final String metric;
  final int target;
  final int progress;
  final TaskRewardConfig reward;
  final String status;
  final int sortOrder;
  final String icon;
}

class TaskRewardConfig {
  const TaskRewardConfig({
    required this.fishCoin,
    required this.exp,
    required this.collectionPoint,
    required this.titleId,
  });

  factory TaskRewardConfig.fromJson(Map<String, dynamic> json) {
    return TaskRewardConfig(
      fishCoin: _readInt(json['fishCoin'], 0),
      exp: _readInt(json['exp'], 0),
      collectionPoint: _readInt(json['collectionPoint'], 0),
      titleId: '${json['titleId'] ?? ''}',
    );
  }

  final int fishCoin;
  final int exp;
  final int collectionPoint;
  final String titleId;
}

int _readInt(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}
