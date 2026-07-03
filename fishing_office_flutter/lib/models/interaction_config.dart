class InteractionConfig {
  const InteractionConfig({
    required this.defaultFeedback,
    required this.actions,
    required this.fishingStateMachine,
  });

  factory InteractionConfig.fromJson(Map<String, dynamic> json) {
    final rawActions = json['actions'];
    final actions = <String, InteractionAction>{};
    if (rawActions is List) {
      for (final item in rawActions.whereType<Map<String, dynamic>>()) {
        final action = InteractionAction.fromJson(item);
        if (action.target.isNotEmpty) actions[action.target] = action;
      }
    } else if (rawActions is Map<String, dynamic>) {
      rawActions.forEach((key, value) {
        actions[key] = InteractionAction.fromJson(
          value is Map<String, dynamic> ? value : const {},
          fallbackAction: key,
        );
      });
    }

    return InteractionConfig(
      defaultFeedback: InteractionFeedback.fromJson(
        json['defaultFeedback'] is Map<String, dynamic>
            ? json['defaultFeedback'] as Map<String, dynamic>
            : const {},
      ),
      actions: actions,
      fishingStateMachine: FishingStateMachine.fromJson(
        json['fishingStateMachine'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  final InteractionFeedback defaultFeedback;
  final Map<String, InteractionAction> actions;
  final FishingStateMachine fishingStateMachine;
}

class InteractionFeedback {
  const InteractionFeedback({
    required this.pressScale,
    required this.durationMs,
  });

  factory InteractionFeedback.fromJson(Map<String, dynamic> json) {
    return InteractionFeedback(
      pressScale: _readDouble(json['pressScale'], .95),
      durationMs: _readInt(json['durationMs'], 150),
    );
  }

  final double pressScale;
  final int durationMs;
}

class InteractionAction {
  const InteractionAction({
    required this.type,
    required this.target,
    required this.event,
    required this.action,
    required this.note,
    required this.params,
  });

  factory InteractionAction.fromJson(
    Map<String, dynamic> json, {
    String fallbackAction = '',
  }) {
    return InteractionAction(
      type: '${json['type'] ?? json['action'] ?? fallbackAction}',
      target: '${json['target'] ?? ''}',
      event: '${json['event'] ?? ''}',
      action: '${json['action'] ?? fallbackAction}',
      note: '${json['note'] ?? ''}',
      params: json['params'] is Map<String, dynamic>
          ? json['params'] as Map<String, dynamic>
          : const {},
    );
  }

  final String type;
  final String target;
  final String event;
  final String action;
  final String note;
  final Map<String, dynamic> params;
}

class FishingStateMachine {
  const FishingStateMachine({
    required this.initial,
    required this.transitions,
  });

  factory FishingStateMachine.fromJson(Map<String, dynamic> json) {
    final rawTransitions = json['transitions'];
    return FishingStateMachine(
      initial: '${json['initial'] ?? 'idle'}',
      transitions: rawTransitions is List
          ? rawTransitions
              .whereType<Map<String, dynamic>>()
              .map(FishingTransition.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  final String initial;
  final List<FishingTransition> transitions;
}

class FishingTransition {
  const FishingTransition({
    required this.from,
    required this.event,
    required this.to,
  });

  factory FishingTransition.fromJson(Map<String, dynamic> json) {
    return FishingTransition(
      from: '${json['from'] ?? ''}',
      event: '${json['event'] ?? ''}',
      to: '${json['to'] ?? ''}',
    );
  }

  final String from;
  final String event;
  final String to;
}

double _readDouble(Object? value, double fallback) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

int _readInt(Object? value, int fallback) {
  if (value is num) return value.round();
  return int.tryParse('$value') ?? fallback;
}
