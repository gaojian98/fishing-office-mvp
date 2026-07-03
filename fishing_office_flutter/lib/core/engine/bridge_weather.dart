import 'bridge_calendar.dart';

class BridgeWeather {
  const BridgeWeather();

  BridgeWeatherState resolve({
    required BridgeCalendarState calendar,
  }) {
    final weatherType = calendar.isWeekend ? 'CalmSea' : 'Cloudy';
    return BridgeWeatherState(
      weatherType: weatherType,
      headline: _buildHeadline(calendar),
      context: {
        'weekdayLabel': calendar.weekdayLabel,
        'season': calendar.season,
      },
    );
  }
}

class BridgeWeatherState {
  const BridgeWeatherState({
    required this.weatherType,
    required this.headline,
    required this.context,
  });

  final String weatherType;
  final String headline;
  final Map<String, dynamic> context;
}

String _buildHeadline(BridgeCalendarState calendar) {
  if (calendar.weekdayLabel == 'Friday') return '海风更轻了。';
  if (calendar.isWeekend) return '海面很适合散步。';
  if (calendar.weekdayLabel == 'Monday') return '今天的海很安静。';
  return '今天的海像在呼吸。';
}
