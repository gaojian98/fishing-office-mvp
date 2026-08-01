import '../core/managers/world_clock_manager.dart';

class TransactionConfig {
  const TransactionConfig({
    required this.title,
    required this.subtitle,
    required this.pageSize,
    required this.pageInfoTemplate,
    required this.filters,
    required this.columns,
    required this.records,
    required this.footer,
    required this.emptyState,
  });

  factory TransactionConfig.fromJson(Map<String, dynamic> json) {
    final filtersJson = json['filters'] as Map<String, dynamic>? ?? const {};
    final columnsJson = json['columns'] as Map<String, dynamic>? ?? const {};
    final recordsJson = json['records'];
    final footerJson = json['footer'] as Map<String, dynamic>? ?? const {};
    final emptyStateJson =
        json['emptyState'] as Map<String, dynamic>? ?? const {};
    return TransactionConfig(
      title: '${json['title'] ?? '交易记录'}',
      subtitle: '${json['subtitle'] ?? '最近记录'}',
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
      pageInfoTemplate:
          '${json['pageInfoTemplate'] ?? '页码 {current} / {total}'}',
      filters: TransactionFilterConfig.fromJson(filtersJson),
      columns: TransactionColumns.fromJson(columnsJson),
      records: recordsJson is List
          ? recordsJson
              .whereType<Map<String, dynamic>>()
              .map(TransactionRecordItem.fromJson)
              .toList(growable: false)
          : const [],
      footer: TransactionFooter.fromJson(footerJson),
      emptyState: TransactionEmptyState.fromJson(emptyStateJson),
    );
  }

  final String title;
  final String subtitle;
  final int pageSize;
  final String pageInfoTemplate;
  final TransactionFilterConfig filters;
  final TransactionColumns columns;
  final List<TransactionRecordItem> records;
  final TransactionFooter footer;
  final TransactionEmptyState emptyState;

  int get pageCount =>
      records.isEmpty ? 1 : ((records.length - 1) ~/ pageSize) + 1;

  String pageInfoLabel(int current, int total) {
    return pageInfoTemplate
        .replaceAll('{current}', current.toString())
        .replaceAll('{total}', total.toString());
  }
}

class TransactionFilterConfig {
  const TransactionFilterConfig({
    required this.items,
  });

  factory TransactionFilterConfig.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    return TransactionFilterConfig(
      items: itemsJson is List
          ? itemsJson
              .whereType<Map<String, dynamic>>()
              .map(TransactionFilterItem.fromJson)
              .toList(growable: false)
          : const [
              TransactionFilterItem(id: 'all', label: '全部'),
              TransactionFilterItem(id: 'income', label: '收入'),
              TransactionFilterItem(id: 'expense', label: '支出'),
              TransactionFilterItem(id: 'reward', label: '奖励'),
              TransactionFilterItem(id: 'purchase', label: '购买'),
            ],
    );
  }

  final List<TransactionFilterItem> items;
}

class TransactionFilterItem {
  const TransactionFilterItem({
    required this.id,
    required this.label,
  });

  factory TransactionFilterItem.fromJson(Map<String, dynamic> json) {
    return TransactionFilterItem(
      id: '${json['id'] ?? ''}',
      label: '${json['label'] ?? ''}',
    );
  }

  final String id;
  final String label;
}

class TransactionColumns {
  const TransactionColumns({
    required this.timeLabel,
    required this.typeLabel,
    required this.amountLabel,
    required this.balanceLabel,
    required this.noteLabel,
  });

  factory TransactionColumns.fromJson(Map<String, dynamic> json) {
    return TransactionColumns(
      timeLabel: '${json['timeLabel'] ?? '时间'}',
      typeLabel: '${json['typeLabel'] ?? '类型'}',
      amountLabel: '${json['amountLabel'] ?? '金额'}',
      balanceLabel: '${json['balanceLabel'] ?? '余额变化'}',
      noteLabel: '${json['noteLabel'] ?? '备注'}',
    );
  }

  final String timeLabel;
  final String typeLabel;
  final String amountLabel;
  final String balanceLabel;
  final String noteLabel;
}

class TransactionRecordItem {
  const TransactionRecordItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.note,
    required this.time,
    this.category = '',
    this.currency = 'fish_coin',
    this.itemId = '',
    this.itemName = '',
  });

  factory TransactionRecordItem.fromJson(Map<String, dynamic> json) {
    return TransactionRecordItem(
      id: '${json['id'] ?? ''}',
      type: '${json['type'] ?? ''}',
      category: '${json['category'] ?? ''}',
      currency: '${json['currency'] ?? 'fish_coin'}',
      amount: _parseAmount(json['amount']),
      note: '${json['note'] ?? ''}',
      time: '${json['time'] ?? ''}',
      itemId: '${json['itemId'] ?? ''}',
      itemName: '${json['itemName'] ?? ''}',
    );
  }

  final String id;
  final String type;
  final String category;
  final String currency;
  final String amount;
  final String note;
  final String time;
  final String itemId;
  final String itemName;

  int get parsedAmount {
    return _parseSignedInt(amount);
  }

  DateTime get parsedCreatedAt =>
      DateTime.tryParse(time.replaceFirst(' ', 'T')) ??
      WorldClockManager.systemNow();

  static String _parseAmount(Object? value) {
    if (value == null) return '0';
    return '$value';
  }

  static int _parseSignedInt(String value) {
    final sanitized = value.replaceAll(',', '').trim();
    if (sanitized.isEmpty) return 0;
    return int.tryParse(sanitized) ?? 0;
  }
}

class TransactionFooter {
  const TransactionFooter({
    required this.prevLabel,
    required this.nextLabel,
    required this.closeLabel,
  });

  factory TransactionFooter.fromJson(Map<String, dynamic> json) {
    return TransactionFooter(
      prevLabel: '${json['prevLabel'] ?? '上一页'}',
      nextLabel: '${json['nextLabel'] ?? '下一页'}',
      closeLabel: '${json['closeLabel'] ?? '关闭'}',
    );
  }

  final String prevLabel;
  final String nextLabel;
  final String closeLabel;
}

class TransactionEmptyState {
  const TransactionEmptyState({
    required this.title,
    required this.body,
    required this.buttonLabel,
  });

  factory TransactionEmptyState.fromJson(Map<String, dynamic> json) {
    return TransactionEmptyState(
      title: '${json['title'] ?? '暂无交易记录'}',
      body: '${json['body'] ?? '这里还没有任何交易。'}',
      buttonLabel: '${json['buttonLabel'] ?? '开始钓鱼'}',
    );
  }

  final String title;
  final String body;
  final String buttonLabel;
}
