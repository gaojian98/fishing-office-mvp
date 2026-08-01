class SettingsConfig {
  const SettingsConfig({
    required this.meta,
    required this.title,
    required this.closeLabel,
    required this.savedMessage,
    required this.restoredMessage,
    required this.cacheClearedMessage,
    required this.confirmReset,
    required this.confirmClearCache,
    required this.footer,
    required this.items,
  });

  factory SettingsConfig.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return SettingsConfig(
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : const {},
      title: '${json['title'] ?? '设置中心'}',
      closeLabel: '${json['closeLabel'] ?? '关闭'}',
      savedMessage: '${json['savedMessage'] ?? '设置已保存。'}',
      restoredMessage: '${json['restoredMessage'] ?? '已恢复默认设置。'}',
      cacheClearedMessage: '${json['cacheClearedMessage'] ?? '缓存已清除。'}',
      confirmReset: SettingsConfirmText.fromJson(
        json['confirmReset'] is Map<String, dynamic>
            ? json['confirmReset'] as Map<String, dynamic>
            : const {},
      ),
      confirmClearCache: SettingsConfirmText.fromJson(
        json['confirmClearCache'] is Map<String, dynamic>
            ? json['confirmClearCache'] as Map<String, dynamic>
            : const {},
      ),
      footer: SettingsFooter.fromJson(
        json['footer'] is Map<String, dynamic>
            ? json['footer'] as Map<String, dynamic>
            : const {},
      ),
      items: rawItems is List
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(SettingsItem.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  final Map<String, dynamic> meta;
  final String title;
  final String closeLabel;
  final String savedMessage;
  final String restoredMessage;
  final String cacheClearedMessage;
  final SettingsConfirmText confirmReset;
  final SettingsConfirmText confirmClearCache;
  final SettingsFooter footer;
  final List<SettingsItem> items;

  SettingsItem? itemById(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}

class SettingsConfirmText {
  const SettingsConfirmText({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  factory SettingsConfirmText.fromJson(Map<String, dynamic> json) {
    return SettingsConfirmText(
      title: '${json['title'] ?? '确认'}',
      body: '${json['body'] ?? ''}',
      confirmLabel: '${json['confirmLabel'] ?? '确认'}',
      cancelLabel: '${json['cancelLabel'] ?? '取消'}',
    );
  }

  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
}

class SettingsFooter {
  const SettingsFooter({
    required this.saveLabel,
    required this.restoreLabel,
    required this.closeLabel,
  });

  factory SettingsFooter.fromJson(Map<String, dynamic> json) {
    return SettingsFooter(
      saveLabel: '${json['saveLabel'] ?? '保存设置'}',
      restoreLabel: '${json['restoreLabel'] ?? '恢复默认'}',
      closeLabel: '${json['closeLabel'] ?? '关闭'}',
    );
  }

  final String saveLabel;
  final String restoreLabel;
  final String closeLabel;
}

class SettingsItem {
  const SettingsItem({
    required this.id,
    required this.label,
    required this.type,
    required this.help,
    required this.defaultValue,
    required this.onLabel,
    required this.offLabel,
    required this.buttonLabel,
    required this.options,
  });

  factory SettingsItem.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    return SettingsItem(
      id: '${json['id'] ?? ''}',
      label: '${json['label'] ?? ''}',
      type: '${json['type'] ?? 'toggle'}',
      help: '${json['help'] ?? ''}',
      defaultValue: '${json['defaultValue'] ?? json['default'] ?? ''}',
      onLabel: '${json['onLabel'] ?? '开'}',
      offLabel: '${json['offLabel'] ?? '关'}',
      buttonLabel: '${json['buttonLabel'] ?? json['label'] ?? ''}',
      options: rawOptions is List
          ? rawOptions
              .whereType<Map<String, dynamic>>()
              .map(SettingsOption.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  final String id;
  final String label;
  final String type;
  final String help;
  final String defaultValue;
  final String onLabel;
  final String offLabel;
  final String buttonLabel;
  final List<SettingsOption> options;

  bool get isToggle => type == 'toggle';
  bool get isSegment => type == 'segment';
  bool get isAction => type == 'action';
}

class SettingsOption {
  const SettingsOption({
    required this.id,
    required this.label,
  });

  factory SettingsOption.fromJson(Map<String, dynamic> json) {
    return SettingsOption(
      id: '${json['id'] ?? json['value'] ?? ''}',
      label: '${json['label'] ?? ''}',
    );
  }

  final String id;
  final String label;
}
