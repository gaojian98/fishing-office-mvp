import 'weather_state.dart';

class WeatherDialogueHint {
  const WeatherDialogueHint({
    required this.weatherType,
    required this.hint,
    required this.tags,
  });

  final WeatherType weatherType;
  final String hint;
  final List<String> tags;

  factory WeatherDialogueHint.fromState(WeatherState state) {
    return WeatherDialogueHint(
      weatherType: state.weatherType,
      hint: _buildHint(state.weatherType),
      tags: [
        state.title,
        state.visual.skyTone,
        state.effect.fishMood,
      ],
    );
  }
}

String _buildHint(WeatherType type) {
  switch (type) {
    case WeatherType.sunny:
      return '今天海面很亮，适合看看远方。';
    case WeatherType.cloudy:
      return '云层柔软，世界很安静。';
    case WeatherType.lightRain:
      return '小雨落下，海会变得很安静。';
    case WeatherType.windy:
      return '风开始变强，注意等待节奏。';
    case WeatherType.misty:
      return '雾气很重，今天适合留意细节。';
    case WeatherType.sunsetGlow:
      return '晚霞很美，今天适合慢一点。';
    case WeatherType.calmSea:
      return '海面平静，适合耐心等待。';
    case WeatherType.stormComing:
      return '风暴正在靠近，世界屏住了呼吸。';
  }
}
