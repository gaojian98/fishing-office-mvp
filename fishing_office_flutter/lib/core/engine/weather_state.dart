import 'weather_effect.dart';
import 'weather_visual.dart';
import 'world_calendar.dart';
import 'world_clock.dart';

enum WeatherType {
  sunny,
  cloudy,
  lightRain,
  windy,
  misty,
  sunsetGlow,
  calmSea,
  stormComing,
}

class WeatherState {
  const WeatherState({
    required this.weatherType,
    required this.title,
    required this.description,
    required this.intensity,
    required this.startTime,
    required this.endTime,
    required this.effect,
    required this.visual,
    required this.context,
    required this.createdAt,
  });

  factory WeatherState.initial() {
    return WeatherState(
      weatherType: WeatherType.calmSea,
      title: 'CalmSea',
      description: '海面很平静。',
      intensity: 1,
      startTime: WorldClock.initial(),
      endTime: WorldClock.initial().tick(const Duration(hours: 2)),
      effect: WeatherEffect.fromType(WeatherType.calmSea),
      visual: WeatherVisual.fromType(WeatherType.calmSea),
      context: const {},
      createdAt: DateTime.now(),
    );
  }

  final WeatherType weatherType;
  final String title;
  final String description;
  final int intensity;
  final WorldClock startTime;
  final WorldClock endTime;
  final WeatherEffect effect;
  final WeatherVisual visual;
  final Map<String, dynamic> context;
  final DateTime createdAt;

  factory WeatherState.resolve({
    required WorldCalendar calendar,
    required WorldClock clock,
    WeatherEffect? effect,
  }) {
    final weatherType = _resolveType(calendar, clock);
    final resolvedEffect = effect ?? WeatherEffect.fromType(weatherType);
    return WeatherState(
      weatherType: weatherType,
      title: _resolveTitle(weatherType),
      description: _resolveDescription(weatherType),
      intensity: _resolveIntensity(weatherType, clock),
      startTime: clock,
      endTime: clock.tick(const Duration(hours: 3)),
      effect: resolvedEffect,
      visual: WeatherVisual.fromType(weatherType),
      context: {
        'weekdayIndex': calendar.weekdayIndex,
        'season': calendar.season,
        'isWeekend': calendar.isWeekend,
      },
      createdAt: DateTime.now(),
    );
  }

  WeatherState copyWith({
    WeatherType? weatherType,
    String? title,
    String? description,
    int? intensity,
    WorldClock? startTime,
    WorldClock? endTime,
    WeatherEffect? effect,
    WeatherVisual? visual,
    Map<String, dynamic>? context,
    DateTime? createdAt,
  }) {
    return WeatherState(
      weatherType: weatherType ?? this.weatherType,
      title: title ?? this.title,
      description: description ?? this.description,
      intensity: intensity ?? this.intensity,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      effect: effect ?? this.effect,
      visual: visual ?? this.visual,
      context: context ?? this.context,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

WeatherType _resolveType(WorldCalendar calendar, WorldClock clock) {
  if (calendar.isWeekend && clock.hour >= 18) return WeatherType.sunsetGlow;
  if (clock.hour >= 22 || clock.hour < 5) return WeatherType.misty;
  if (clock.hour >= 18) return WeatherType.sunsetGlow;
  if (calendar.season == 'summer' && clock.hour >= 12 && clock.hour < 15) {
    return WeatherType.sunny;
  }
  if (calendar.isWeekend) return WeatherType.cloudy;
  return WeatherType.calmSea;
}

String _resolveTitle(WeatherType type) {
  switch (type) {
    case WeatherType.sunny:
      return 'Sunny';
    case WeatherType.cloudy:
      return 'Cloudy';
    case WeatherType.lightRain:
      return 'LightRain';
    case WeatherType.windy:
      return 'Windy';
    case WeatherType.misty:
      return 'Misty';
    case WeatherType.sunsetGlow:
      return 'SunsetGlow';
    case WeatherType.calmSea:
      return 'CalmSea';
    case WeatherType.stormComing:
      return 'StormComing';
  }
}

String _resolveDescription(WeatherType type) {
  switch (type) {
    case WeatherType.sunny:
      return '海面明亮，世界很轻。';
    case WeatherType.cloudy:
      return '云层很厚，但风很温和。';
    case WeatherType.lightRain:
      return '小雨慢慢落下，海面安静。';
    case WeatherType.windy:
      return '风开始更明显，海水有一点躁动。';
    case WeatherType.misty:
      return '雾气让远处的故事变得神秘。';
    case WeatherType.sunsetGlow:
      return '晚霞把海面染成柔软的颜色。';
    case WeatherType.calmSea:
      return '海面平静，适合耐心等待。';
    case WeatherType.stormComing:
      return '风暴正在靠近，世界屏住了呼吸。';
  }
}

int _resolveIntensity(WeatherType type, WorldClock clock) {
  switch (type) {
    case WeatherType.sunny:
      return 2;
    case WeatherType.cloudy:
      return 3;
    case WeatherType.lightRain:
      return 4;
    case WeatherType.windy:
      return 5;
    case WeatherType.misty:
      return 4;
    case WeatherType.sunsetGlow:
      return 3;
    case WeatherType.calmSea:
      return 1;
    case WeatherType.stormComing:
      return 8;
  }
}
