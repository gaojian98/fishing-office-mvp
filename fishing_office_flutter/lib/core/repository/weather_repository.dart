import 'dart:convert';

import '../../models/weather_config.dart';
import 'json/json_source.dart';

class WeatherRepository {
  const WeatherRepository({
    required this.source,
    this.path = 'assets/config/weather.json',
  });

  final JsonSource source;
  final String path;

  Future<WeatherConfig> load() async {
    final raw = await source.loadString(path);
    return WeatherConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
