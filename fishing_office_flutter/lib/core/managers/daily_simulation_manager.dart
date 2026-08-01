import 'package:flutter/foundation.dart';

import '../../models/rumor_config.dart';
import '../../models/resident_story_config.dart';
import 'festival_runtime_manager.dart';
import 'resident_runtime_manager.dart';
import 'rumor_runtime_manager.dart';
import 'story_runtime_manager.dart';
import 'weather_runtime_manager.dart';
import 'world_clock_manager.dart';
import 'world_save_manager.dart';
import 'world_tick_manager.dart';

class DailyWorldSummary {
  const DailyWorldSummary({
    required this.date,
    required this.weather,
    required this.festival,
    required this.activeRumors,
    required this.residentHighlights,
    required this.storyHints,
    required this.todayMessage,
  });

  factory DailyWorldSummary.fromJson(Map<String, dynamic> json) {
    return DailyWorldSummary(
      date: json['date']?.toString() ?? '',
      weather: json['weather']?.toString() ?? '',
      festival: json['festival']?.toString() ?? '',
      activeRumors: _stringList(json['activeRumors']),
      residentHighlights: _stringList(json['residentHighlights']),
      storyHints: _stringList(json['storyHints']),
      todayMessage: json['todayMessage']?.toString() ?? '',
    );
  }

  final String date;
  final String weather;
  final String festival;
  final List<String> activeRumors;
  final List<String> residentHighlights;
  final List<String> storyHints;
  final String todayMessage;

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'weather': weather,
      'festival': festival,
      'activeRumors': activeRumors,
      'residentHighlights': residentHighlights,
      'storyHints': storyHints,
      'todayMessage': todayMessage,
    };
  }
}

class DailyChange {
  const DailyChange({
    required this.id,
    required this.date,
    required this.type,
    required this.description,
  });

  factory DailyChange.fromJson(Map<String, dynamic> json) {
    return DailyChange(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  final String id;
  final String date;
  final String type;
  final String description;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'type': type,
      'description': description,
    };
  }
}

class DailySimulationManager extends ChangeNotifier {
  DailySimulationManager({
    required WorldTickManager worldTickManager,
    required WorldClockManager worldClockManager,
    required FestivalRuntimeManager festivalRuntimeManager,
    required WeatherRuntimeManager weatherRuntimeManager,
    required RumorRuntimeManager rumorRuntimeManager,
    required ResidentRuntimeManager residentRuntimeManager,
    required StoryRuntimeManager storyRuntimeManager,
    required WorldSaveManager worldSaveManager,
  })  : _worldTickManager = worldTickManager,
        _worldClockManager = worldClockManager,
        _festivalRuntimeManager = festivalRuntimeManager,
        _weatherRuntimeManager = weatherRuntimeManager,
        _rumorRuntimeManager = rumorRuntimeManager,
        _residentRuntimeManager = residentRuntimeManager,
        _storyRuntimeManager = storyRuntimeManager,
        _worldSaveManager = worldSaveManager {
    _restoreState(worldSaveManager.dailySimulationState);
  }

  final WorldTickManager _worldTickManager;
  final WorldClockManager _worldClockManager;
  final FestivalRuntimeManager _festivalRuntimeManager;
  final WeatherRuntimeManager _weatherRuntimeManager;
  final RumorRuntimeManager _rumorRuntimeManager;
  final ResidentRuntimeManager _residentRuntimeManager;
  final StoryRuntimeManager _storyRuntimeManager;
  final WorldSaveManager _worldSaveManager;

  int? _lastRunDay;
  DailyWorldSummary? _todaySummary;
  final List<DailyChange> _changes = <DailyChange>[];

  bool hasRunToday() => _lastRunDay == _worldClockManager.today().dayCount;

  DailyWorldSummary? getTodayWorldSummary() => _todaySummary;

  List<DailyChange> getDailyChanges() => List<DailyChange>.from(_changes);

  Future<DailyWorldSummary> runDailySimulation() async {
    if (hasRunToday() && _todaySummary != null) {
      return _todaySummary!;
    }

    await _worldTickManager.runTick(
      TickType.dayTick,
      advanceClock: false,
    );

    final summary = _buildSummary();
    _lastRunDay = _worldClockManager.today().dayCount;
    _todaySummary = summary;
    _recordChanges(summary);
    _persistState();
    await _worldSaveManager.autoSave();

    if (kDebugMode) {
      debugPrint(
        'DailySimulationManager | date=${summary.date} weather=${summary.weather} festival=${summary.festival}',
      );
    }
    notifyListeners();
    return summary;
  }

  DailyWorldSummary _buildSummary() {
    final calendar = _worldClockManager.today();
    final weather = _weatherRuntimeManager.getCurrentWeather();
    final festival = _festivalRuntimeManager.getTodayFestival();
    final rumors = _rumorRuntimeManager.getActiveRumors();
    final residentHighlights =
        _residentRuntimeManager.residents.take(5).map((resident) {
      final state =
          _residentRuntimeManager.getResidentCurrentState(resident.id);
      return '${resident.name}：${state.location} / ${state.activity} / ${state.mood}';
    }).toList(growable: false);
    final storyHints = _storyHints();
    final date = _dateLabel();
    return DailyWorldSummary(
      date: date,
      weather: weather?.name ?? '',
      festival: festival?.name ?? '',
      activeRumors: rumors
          .take(5)
          .map(_rumorLabel)
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      residentHighlights: residentHighlights,
      storyHints: storyHints,
      todayMessage: _todayMessage(
        weatherName: weather?.name ?? '',
        festivalName: festival?.name ?? '',
        rumorCount: rumors.length,
        dayCount: calendar.dayCount,
      ),
    );
  }

  List<String> _storyHints() {
    final hints = <String>[];
    for (final resident in _residentRuntimeManager.residents) {
      final stories = _storyRuntimeManager.getAvailableStories(resident.id);
      for (final story in stories.take(2)) {
        hints.add(_storyLabel(story));
        if (hints.length >= 5) return hints;
      }
    }
    return hints;
  }

  void _recordChanges(DailyWorldSummary summary) {
    final date = summary.date;
    final next = <DailyChange>[
      DailyChange(
        id: '${date}_weather',
        date: date,
        type: 'weather',
        description: summary.weather.isEmpty
            ? '今天的天气保持安静。'
            : '今天的天气是：${summary.weather}。',
      ),
      DailyChange(
        id: '${date}_festival',
        date: date,
        type: 'festival',
        description: summary.festival.isEmpty
            ? '今天没有特别节日。'
            : '今天的节日是：${summary.festival}。',
      ),
      DailyChange(
        id: '${date}_rumor',
        date: date,
        type: 'rumor',
        description: '今天有 ${summary.activeRumors.length} 条传闻正在流动。',
      ),
      DailyChange(
        id: '${date}_resident',
        date: date,
        type: 'resident',
        description: '今天记录了 ${summary.residentHighlights.length} 位居民的状态。',
      ),
      DailyChange(
        id: '${date}_story',
        date: date,
        type: 'story',
        description: '今天有 ${summary.storyHints.length} 条故事线索。',
      ),
    ];
    _changes
      ..removeWhere((change) => change.date == date)
      ..addAll(next);
  }

  void _restoreState(Map<String, dynamic> state) {
    if (state.isEmpty) return;
    _lastRunDay = _readInt(state['lastRunDay']);
    final summary = state['todaySummary'];
    if (summary is Map) {
      _todaySummary = DailyWorldSummary.fromJson(
        Map<String, dynamic>.from(summary),
      );
    }
    final changes = state['dailyChanges'];
    if (changes is List) {
      _changes
        ..clear()
        ..addAll(
          changes.whereType<Map>().map(
                (item) => DailyChange.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              ),
        );
    }
  }

  void _persistState() {
    _worldSaveManager.setDailySimulationState({
      'lastRunDay': _lastRunDay,
      'todaySummary': _todaySummary?.toJson(),
      'dailyChanges':
          _changes.map((change) => change.toJson()).toList(growable: false),
    });
  }

  String _dateLabel() {
    final calendar = _worldClockManager.today();
    return 'Y${calendar.year}-M${calendar.month}-D${calendar.day}-#${calendar.dayCount}';
  }

  String _todayMessage({
    required String weatherName,
    required String festivalName,
    required int rumorCount,
    required int dayCount,
  }) {
    if (festivalName.isNotEmpty) {
      return '今天是$festivalName，第二世界比平时更热闹一点。';
    }
    if (weatherName.isNotEmpty) {
      return '第$dayCount天，$weatherName让海边多了一点新的气息。';
    }
    if (rumorCount > 0) {
      return '第$dayCount天，有些小消息正在居民之间慢慢传开。';
    }
    return '第$dayCount天，第二世界安静地醒来了。';
  }

  String _rumorLabel(RumorEntry rumor) {
    if (rumor.title.isNotEmpty) return rumor.title;
    return rumor.id;
  }

  String _storyLabel(ResidentStoryEntry story) {
    if (story.title.isNotEmpty) return story.title;
    return story.id;
  }

  int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '');
  }
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return value
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
