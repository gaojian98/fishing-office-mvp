class AnimationConfig {
  const AnimationConfig({
    required this.animations,
    required this.bindings,
  });

  factory AnimationConfig.fromJson(Map<String, dynamic> json) {
    final rawAnimations = json['animations'] ?? json['presets'];
    final rawBindings = json['bindings'];
    return AnimationConfig(
      animations: rawAnimations is Map<String, dynamic>
          ? rawAnimations.map(
              (key, value) => MapEntry(
                key,
                AnimationSpec.fromJson(
                  value is Map<String, dynamic> ? value : const {},
                ),
              ),
            )
          : const {},
      bindings: rawBindings is List
          ? rawBindings
              .whereType<Map<String, dynamic>>()
              .map(AnimationBinding.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  final Map<String, AnimationSpec> animations;
  final List<AnimationBinding> bindings;

  AnimationSpec? specForElement(String elementId, String explicitId) {
    if (explicitId.isNotEmpty) return animations[explicitId];
    for (final binding in bindings) {
      if (binding.target == elementId && binding.on == 'load') {
        return animations[binding.preset];
      }
    }
    return null;
  }
}

class AnimationSpec {
  const AnimationSpec({
    required this.type,
    required this.scale,
    required this.distance,
    required this.durationMs,
    required this.curve,
  });

  factory AnimationSpec.fromJson(Map<String, dynamic> json) {
    final compoundTranslate = _firstTranslateY(json['animations']);
    return AnimationSpec(
      type: '${json['type'] ?? ''}',
      scale: _readDouble(json['scale'], .95),
      distance: _readDouble(
        json['distance'] ?? json['to'] ?? compoundTranslate?['to'],
        0,
      ),
      durationMs: _readInt(
        json['durationMs'] ?? compoundTranslate?['durationMs'],
        1000,
      ),
      curve: '${json['curve'] ?? 'easeOut'}',
    );
  }

  final String type;
  final double scale;
  final double distance;
  final int durationMs;
  final String curve;
}

class AnimationBinding {
  const AnimationBinding({
    required this.target,
    required this.on,
    required this.preset,
  });

  factory AnimationBinding.fromJson(Map<String, dynamic> json) {
    return AnimationBinding(
      target: '${json['target'] ?? ''}',
      on: '${json['on'] ?? ''}',
      preset: '${json['preset'] ?? ''}',
    );
  }

  final String target;
  final String on;
  final String preset;
}

double _readDouble(Object? value, double fallback) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

int _readInt(Object? value, int fallback) {
  if (value is num) return value.round();
  return int.tryParse('$value') ?? fallback;
}

Map<String, dynamic>? _firstTranslateY(Object? rawAnimations) {
  if (rawAnimations is! List) return null;
  for (final item in rawAnimations) {
    if (item is Map<String, dynamic> && item['type'] == 'translateY') {
      return item;
    }
  }
  return null;
}
