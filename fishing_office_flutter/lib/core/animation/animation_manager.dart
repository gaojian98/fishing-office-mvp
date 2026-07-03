import 'package:flutter/material.dart';

import '../../models/animation_config.dart';

class AnimationManager {
  const AnimationManager(this.config);

  final AnimationConfig config;

  AnimationSpec? preset(String id) => config.animations[id];

  AnimationSpec? forElement(String elementId, String explicitId) {
    return config.specForElement(elementId, explicitId);
  }

  AnimationSpec buttonPress() => preset('button_press') ??
      const AnimationSpec(
        type: 'scale',
        scale: 0.95,
        distance: 0,
        durationMs: 150,
        curve: 'easeOut',
      );

  Curve curveOf(String name) {
    switch (name) {
      case 'easeIn':
        return Curves.easeIn;
      case 'easeOut':
        return Curves.easeOut;
      case 'easeInOut':
        return Curves.easeInOut;
      case 'linear':
        return Curves.linear;
      default:
        return Curves.easeOut;
    }
  }

  Duration durationOf(String presetId, {int fallbackMs = 180}) {
    return Duration(milliseconds: preset(presetId)?.durationMs ?? fallbackMs);
  }

  double scaleOf(String presetId, {double fallback = 0.95}) {
    return preset(presetId)?.scale ?? fallback;
  }

  double distanceOf(String presetId, {double fallback = 0}) {
    return preset(presetId)?.distance ?? fallback;
  }

  double randomSeed(String key) {
    return (key.hashCode.abs() % 1000) / 1000.0;
  }
}
