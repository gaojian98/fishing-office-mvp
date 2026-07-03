class DialogConfig {
  const DialogConfig({
    required this.meta,
    required this.common,
    required this.dialogs,
  });

  factory DialogConfig.fromJson(Map<String, dynamic> json) {
    final rawDialogs = json['dialogs'];
    return DialogConfig(
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : const {},
      common: json['common'] is Map<String, dynamic>
          ? json['common'] as Map<String, dynamic>
          : const {},
      dialogs: rawDialogs is Map<String, dynamic>
          ? rawDialogs.map(
              (key, value) => MapEntry(
                key,
                DialogItem.fromJson(
                  id: key,
                  json: value is Map<String, dynamic> ? value : const {},
                ),
              ),
            )
          : const {},
    );
  }

  final Map<String, dynamic> meta;
  final Map<String, dynamic> common;
  final Map<String, DialogItem> dialogs;

  DialogItem? byId(String id) => dialogs[id];
}

class DialogItem {
  const DialogItem({
    required this.id,
    required this.route,
    required this.title,
    required this.type,
    required this.description,
    required this.contentSource,
    required this.closeable,
    required this.actions,
  });

  factory DialogItem.fromJson({
    required String id,
    required Map<String, dynamic> json,
  }) {
    return DialogItem(
      id: id,
      route: '${json['route'] ?? ''}',
      title: '${json['title'] ?? id}',
      type: '${json['type'] ?? 'medium'}',
      description: '${json['description'] ?? ''}',
      contentSource: '${json['contentSource'] ?? ''}',
      closeable: json['closeable'] != false,
      actions: json['actions'] is List
          ? (json['actions'] as List)
              .whereType<Map<String, dynamic>>()
              .map(DialogAction.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  final String id;
  final String route;
  final String title;
  final String type;
  final String description;
  final String contentSource;
  final bool closeable;
  final List<DialogAction> actions;
}

class DialogAction {
  const DialogAction({
    required this.label,
    required this.action,
  });

  factory DialogAction.fromJson(Map<String, dynamic> json) {
    return DialogAction(
      label: '${json['label'] ?? ''}',
      action: '${json['action'] ?? ''}',
    );
  }

  final String label;
  final String action;
}
