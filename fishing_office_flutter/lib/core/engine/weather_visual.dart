import 'weather_state.dart';

class WeatherVisual {
  const WeatherVisual({
    required this.weatherType,
    required this.skyTone,
    required this.seaTone,
    required this.lightTone,
    required this.audioTone,
    required this.overlayHints,
  });

  final WeatherType weatherType;
  final String skyTone;
  final String seaTone;
  final String lightTone;
  final String audioTone;
  final List<String> overlayHints;

  factory WeatherVisual.fromType(WeatherType type) {
    switch (type) {
      case WeatherType.sunny:
        return const WeatherVisual(
          weatherType: WeatherType.sunny,
          skyTone: 'bright_blue',
          seaTone: 'sparkle',
          lightTone: 'strong',
          audioTone: 'clear',
          overlayHints: ['sun_glow'],
        );
      case WeatherType.cloudy:
        return const WeatherVisual(
          weatherType: WeatherType.cloudy,
          skyTone: 'soft_gray',
          seaTone: 'flat',
          lightTone: 'soft',
          audioTone: 'muted',
          overlayHints: ['cloud_layers'],
        );
      case WeatherType.lightRain:
        return const WeatherVisual(
          weatherType: WeatherType.lightRain,
          skyTone: 'cool_gray',
          seaTone: 'quiet',
          lightTone: 'soft',
          audioTone: 'rain',
          overlayHints: ['fine_rain'],
        );
      case WeatherType.windy:
        return const WeatherVisual(
          weatherType: WeatherType.windy,
          skyTone: 'moving',
          seaTone: 'choppy',
          lightTone: 'dynamic',
          audioTone: 'wind',
          overlayHints: ['moving_grass', 'fish_float_motion'],
        );
      case WeatherType.misty:
        return const WeatherVisual(
          weatherType: WeatherType.misty,
          skyTone: 'foggy',
          seaTone: 'blurred',
          lightTone: 'diffused',
          audioTone: 'soft',
          overlayHints: ['fog_overlay'],
        );
      case WeatherType.sunsetGlow:
        return const WeatherVisual(
          weatherType: WeatherType.sunsetGlow,
          skyTone: 'orange_pink',
          seaTone: 'warm_gold',
          lightTone: 'golden',
          audioTone: 'warm',
          overlayHints: ['sunset_bloom'],
        );
      case WeatherType.calmSea:
        return const WeatherVisual(
          weatherType: WeatherType.calmSea,
          skyTone: 'clear',
          seaTone: 'smooth',
          lightTone: 'balanced',
          audioTone: 'calm',
          overlayHints: ['soft_wave'],
        );
      case WeatherType.stormComing:
        return const WeatherVisual(
          weatherType: WeatherType.stormComing,
          skyTone: 'dark',
          seaTone: 'heavy',
          lightTone: 'dramatic',
          audioTone: 'storm',
          overlayHints: ['storm_clouds'],
        );
    }
  }
}
