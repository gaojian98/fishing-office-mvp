import 'package:flutter/foundation.dart';

import '../../models/weather_config.dart';
import 'resident_runtime_manager.dart';
import 'world_clock_manager.dart';

class WeatherRuntimeManager {
  WeatherRuntimeManager({
    required WeatherConfig config,
    required WorldClockManager worldClockManager,
    required ResidentRuntimeManager residentRuntimeManager,
  })  : _config = config,
        _worldClockManager = worldClockManager,
        _residentRuntimeManager = residentRuntimeManager;

  final WeatherConfig _config;
  final WorldClockManager _worldClockManager;
  final ResidentRuntimeManager _residentRuntimeManager;
  String _cachedWeatherKey = '';
  WeatherEntry? _cachedWeather;
  String _cachedTagsKey = '';
  List<String> _cachedTags = const <String>[];

  WeatherEntry? getCurrentWeather() {
    final key = _weatherCacheKey();
    if (key == _cachedWeatherKey) return _cachedWeather;
    final clock = _worldClockManager.clock;
    final season = _worldClockManager.season();
    final current = clock.hour * 60 + clock.minute;
    final matches = _config.weatherEvents
        .where((weather) => weather.enabled)
        .where((weather) =>
            weather.seasons.isEmpty || weather.seasons.contains(season))
        .where((weather) => _matchesTimeRange(weather.timeRange, current))
        .toList(growable: false);
    if (matches.isEmpty) {
      _cachedWeatherKey = key;
      _cachedWeather = _fallbackWeather(season);
      return _cachedWeather;
    }
    final sorted = List<WeatherEntry>.from(matches)
      ..sort((a, b) {
        final sort = a.sortOrder.compareTo(b.sortOrder);
        if (sort != 0) return sort;
        return a.id.compareTo(b.id);
      });
    final selected = sorted.first;
    if (kDebugMode) {
      debugPrint(
        'WeatherRuntimeManager | weather=${selected.id} type=${selected.type} season=$season hour=${clock.hour}',
      );
    }
    _cachedWeatherKey = key;
    _cachedWeather = selected;
    return selected;
  }

  List<String> getWeatherTags() {
    final key = _weatherCacheKey();
    if (key == _cachedTagsKey) return _cachedTags;
    final weather = getCurrentWeather();
    if (weather == null) return const <String>[];
    final tags = <String>{
      weather.id,
      weather.type,
      weather.rarity,
      ...weather.dialogueTags,
      ...weather.storyTags,
      ...weather.eventTags,
      ...weather.festivalTags,
    };
    _cachedTagsKey = key;
    _cachedTags = tags.where((item) => item.isNotEmpty).toList(growable: false);
    return _cachedTags;
  }

  void invalidateCache() {
    _cachedWeatherKey = '';
    _cachedWeather = null;
    _cachedTagsKey = '';
    _cachedTags = const <String>[];
  }

  bool isWeatherActive(String weatherId) {
    if (weatherId.isEmpty) return false;
    final weather = getCurrentWeather();
    if (weather == null) return false;
    final expected = _weatherAliases(weatherId);
    final active = <String>{
      ..._weatherAliases(weather.id),
      weather.type,
      ...getWeatherTags(),
    };
    return expected.any(active.contains);
  }

  WeatherContext applyWeatherContext(Map<String, dynamic> context) {
    final weather = getCurrentWeather();
    final currentMood = context['residentMood']?.toString() ??
        context['mood']?.toString() ??
        '';
    final currentActivity = context['residentActivity']?.toString() ??
        context['activity']?.toString() ??
        '';
    if (weather == null) {
      return WeatherContext(
        weather: null,
        tags: const <String>[],
        residentMood: currentMood,
        residentActivity: currentActivity,
        raw: Map<String, dynamic>.from(context),
      );
    }
    final mood = weather.residentMoodModifier.isEmpty
        ? currentMood
        : weather.residentMoodModifier;
    final activity = 'weather:${weather.id}';
    final raw = Map<String, dynamic>.from(context)
      ..['weatherId'] = weather.id
      ..['weatherType'] = weather.type
      ..['weatherTags'] = getWeatherTags()
      ..['residentMood'] = mood
      ..['residentActivity'] = activity;
    return WeatherContext(
      weather: weather,
      tags: getWeatherTags(),
      residentMood: mood,
      residentActivity: activity,
      raw: raw,
    );
  }

  WeatherContext residentWeatherContext(String residentId) {
    final state = _residentRuntimeManager.getResidentCurrentState(residentId);
    return applyWeatherContext({
      'residentId': residentId,
      'residentMood': state.mood,
      'residentActivity': state.activity,
      'residentLocation': state.location,
    });
  }

  bool _matchesTimeRange(String range, int current) {
    final parts = range.split('-');
    if (parts.length < 2) return true;
    final start = _parseMinutes(parts[0]);
    final end = _parseMinutes(parts[1]);
    if (start == end) return true;
    if (start < end) return current >= start && current < end;
    return current >= start || current < end;
  }

  int _parseMinutes(String value) {
    final parts = value.trim().split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return hour.clamp(0, 23) * 60 + minute.clamp(0, 59);
  }

  WeatherEntry? _fallbackWeather(String season) {
    final enabled = _config.weatherEvents
        .where((weather) => weather.enabled)
        .where((weather) =>
            weather.seasons.isEmpty || weather.seasons.contains(season))
        .toList(growable: false);
    if (enabled.isEmpty) return null;
    enabled.sort((a, b) {
      final sort = a.sortOrder.compareTo(b.sortOrder);
      if (sort != 0) return sort;
      return a.id.compareTo(b.id);
    });
    return enabled.first;
  }

  String _weatherCacheKey() {
    final clock = _worldClockManager.clock;
    return '${clock.dayCount}:${clock.hour}:${clock.minute}:${_worldClockManager.season()}';
  }

  Set<String> _weatherAliases(String id) {
    final aliases = <String>{id};
    if (id.startsWith('weather_')) {
      aliases.add(id.substring('weather_'.length));
    } else {
      aliases.add('weather_$id');
    }
    return aliases;
  }
}

class WeatherContext {
  const WeatherContext({
    required this.weather,
    required this.tags,
    required this.residentMood,
    required this.residentActivity,
    required this.raw,
  });

  final WeatherEntry? weather;
  final List<String> tags;
  final String residentMood;
  final String residentActivity;
  final Map<String, dynamic> raw;

  bool get hasWeather => weather != null;
  String get weatherId => weather?.id ?? '';
  String get weatherType => weather?.type ?? '';
}
