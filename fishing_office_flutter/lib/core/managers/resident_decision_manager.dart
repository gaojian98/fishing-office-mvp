import 'package:flutter/foundation.dart';

import '../engine/resident_memory_engine.dart';
import '../engine/second_world_engine.dart';
import '../utils/resident_mood.dart';
import 'daily_simulation_manager.dart';
import 'dialogue_runtime_manager.dart';
import 'festival_runtime_manager.dart';
import 'resident_runtime_manager.dart';
import 'rumor_runtime_manager.dart';
import 'story_runtime_manager.dart';
import 'weather_runtime_manager.dart';
import 'world_clock_manager.dart';

class ResidentDecision {
  const ResidentDecision({
    required this.residentId,
    required this.activity,
    required this.location,
    required this.mood,
    required this.interactionTarget,
    required this.storyPreference,
    required this.reason,
  });

  final String residentId;
  final String activity;
  final String location;
  final String mood;
  final String interactionTarget;
  final String storyPreference;
  final String reason;
}

class ResidentDecisionManager extends ChangeNotifier {
  ResidentDecisionManager({
    required ResidentRuntimeManager residentRuntimeManager,
    required DialogueRuntimeManager dialogueRuntimeManager,
    required StoryRuntimeManager storyRuntimeManager,
    required WeatherRuntimeManager weatherRuntimeManager,
    required FestivalRuntimeManager festivalRuntimeManager,
    required RumorRuntimeManager rumorRuntimeManager,
    required WorldClockManager worldClockManager,
    required SecondWorldEngine secondWorldEngine,
    DailySimulationManager? dailySimulationManager,
    ResidentMemoryEngine? residentMemoryEngine,
  })  : _residentRuntimeManager = residentRuntimeManager,
        _dialogueRuntimeManager = dialogueRuntimeManager,
        _storyRuntimeManager = storyRuntimeManager,
        _weatherRuntimeManager = weatherRuntimeManager,
        _festivalRuntimeManager = festivalRuntimeManager,
        _rumorRuntimeManager = rumorRuntimeManager,
        _worldClockManager = worldClockManager,
        _secondWorldEngine = secondWorldEngine,
        _dailySimulationManager = dailySimulationManager,
        _residentMemoryEngine = residentMemoryEngine;

  final ResidentRuntimeManager _residentRuntimeManager;
  final DialogueRuntimeManager _dialogueRuntimeManager;
  final StoryRuntimeManager _storyRuntimeManager;
  final WeatherRuntimeManager _weatherRuntimeManager;
  final FestivalRuntimeManager _festivalRuntimeManager;
  final RumorRuntimeManager _rumorRuntimeManager;
  final WorldClockManager _worldClockManager;
  final SecondWorldEngine _secondWorldEngine;
  final DailySimulationManager? _dailySimulationManager;
  final ResidentMemoryEngine? _residentMemoryEngine;
  final Map<String, ResidentDecision> _decisions = <String, ResidentDecision>{};

  List<ResidentDecision> get decisions =>
      List<ResidentDecision>.from(_decisions.values)
        ..sort((a, b) => a.residentId.compareTo(b.residentId));

  ResidentDecision? decisionFor(String residentId) => _decisions[residentId];

  String decideNextActivity(String residentId) {
    return _decide(residentId).activity;
  }

  String decideNextLocation(String residentId) {
    return _decide(residentId).location;
  }

  String decideNextDialogueTarget(String residentId) {
    return _decide(residentId).interactionTarget;
  }

  String decideNextStoryTarget(String residentId) {
    return _decide(residentId).storyPreference;
  }

  void runResidentDecision() {
    for (final resident in _residentRuntimeManager.residents) {
      if (!resident.enabled) continue;
      final before =
          _residentRuntimeManager.getResidentCurrentState(resident.id);
      final decision = _decide(resident.id);
      _decisions[resident.id] = decision;
      final applied = _residentRuntimeManager.applyEmotionOverride(
        ResidentRuntimeOverride(
          residentId: resident.id,
          location: decision.location,
          activity: decision.activity,
          mood: decision.mood,
          dayCount: _worldClockManager.today().dayCount,
          source: 'resident_decision',
          reason: decision.reason,
        ),
        reason: decision.reason,
        major: isMajorMoodReason(decision.reason),
      );
      if (before.mood != applied.mood) {
        _residentMemoryEngine?.recordEmotionChange(
          resident.id,
          previousMood: before.mood,
          newMood: applied.mood,
          reason: decision.reason,
        );
      }
    }
    if (kDebugMode) {
      debugPrint(
        'ResidentDecisionManager | decisions=${_decisions.length}',
      );
    }
    notifyListeners();
  }

  ResidentDecision _decide(String residentId) {
    final context = _secondWorldEngine.getResidentContext(residentId);
    final baseState = context.life;
    final weather = _weatherRuntimeManager.getCurrentWeather();
    final weatherTags = _weatherRuntimeManager.getWeatherTags();
    final festival = _festivalRuntimeManager.getTodayFestival();
    final festivalTags = _festivalRuntimeManager.getFestivalTags();
    final rumorTags = _rumorRuntimeManager.getRumorTags();
    final activeRumors = _rumorRuntimeManager.getRumorsForResident(residentId);
    final stories = _storyRuntimeManager.getAvailableStories(residentId);
    final dialogues = _dialogueRuntimeManager.getAvailableDialogues(residentId);
    final summary = _dailySimulationManager?.getTodayWorldSummary();
    final relationship = context.relationship.relationshipLevel;
    final memoryTags = context.memory.memoryTags;
    final finishedStories = _storyRuntimeManager.finishedStoryIds;

    final route = _routeFor(residentId);
    var location = baseState.location;
    var activity = baseState.activity;
    var mood = normalizeResidentMood(baseState.mood);
    var reason = 'schedule';

    if (festival != null) {
      location = 'festival_square';
      activity = '在节日气氛里慢慢走动。';
      mood = festival.residentMood.isEmpty ? 'excited' : festival.residentMood;
      reason = 'festival_started';
    } else if (_isBadWeather(weather?.type ?? '', weatherTags)) {
      location = _indoorLocation(residentId, baseState.location);
      activity = '避开坏天气，在室内听雨和海风。';
      mood = 'worried';
      reason = 'weather_change';
    } else if (activeRumors.isNotEmpty || rumorTags.isNotEmpty) {
      location = _discussionLocation(residentId, route, baseState.location);
      activity = '和路过的居民聊起今天的小传闻。';
      mood = 'curious';
      reason = 'rumor_heard';
    } else if (finishedStories.isNotEmpty || stories.isNotEmpty) {
      location = _nextRouteLocation(route, baseState.location);
      activity = '想起刚发生过的小故事，换个地方走走。';
      mood = _storyMood(memoryTags);
      reason = 'story_finished';
    } else if (_isFriend(relationship)) {
      location = _nextRouteLocation(route, baseState.location);
      activity = '去容易遇见朋友的地方坐一会儿。';
      mood = 'happy';
      reason = 'relationship';
    } else if (_isNight()) {
      location = _indoorLocation(residentId, baseState.location);
      activity = '夜色慢下来，准备结束今天。';
      mood = 'tired';
      reason = 'time';
    } else if (_longTimeNoMeet(context.memory.lastMeetTime)) {
      location = _indoorLocation(residentId, baseState.location);
      activity = '今天有点想念熟悉的人，慢慢等一个招呼。';
      mood = 'lonely';
      reason = 'long_time_no_meet';
    } else {
      location = _nextRouteLocation(route, baseState.location);
      activity = _activityByMood(baseState.mood, summary?.weather ?? '');
      mood = baseState.mood.isEmpty ? 'calm' : baseState.mood;
      reason = 'daily_route';
    }

    if (location == baseState.location && route.length > 1) {
      location = _nextRouteLocation(route, baseState.location);
    }

    final interactionTarget = _interactionTarget(
      residentId: residentId,
      relationship: relationship,
      rumorTags: rumorTags,
      festivalTags: festivalTags,
      memoryTags: memoryTags,
    );
    final storyPreference = stories.isNotEmpty ? stories.first.id : '';
    final dialogueSignal = dialogues.isNotEmpty ? dialogues.first.id : '';
    return ResidentDecision(
      residentId: residentId,
      activity: activity,
      location: location,
      mood: normalizeResidentMood(mood),
      interactionTarget: interactionTarget,
      storyPreference:
          storyPreference.isEmpty ? dialogueSignal : storyPreference,
      reason: reason,
    );
  }

  List<String> _routeFor(String residentId) {
    final resident = _residentRuntimeManager.residents
        .where((item) => item.id == residentId)
        .cast<dynamic>()
        .firstOrNull;
    if (resident == null) return const <String>[];
    final raw = resident.raw['dailyRoute'];
    if (raw is List) {
      return raw
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    final fallback = <String>[
      resident.raw['workplace']?.toString() ?? '',
      resident.raw['home']?.toString() ?? '',
      resident.location,
    ].where((item) => item.isNotEmpty).toList(growable: false);
    return fallback;
  }

  String _nextRouteLocation(List<String> route, String current) {
    if (route.isEmpty) return current.isEmpty ? 'office_lounge' : current;
    final index = route.indexOf(current);
    if (index < 0 || index >= route.length - 1) return route.first;
    return route[index + 1];
  }

  String _indoorLocation(String residentId, String fallback) {
    final resident = _residentRuntimeManager.residents
        .where((item) => item.id == residentId)
        .cast<dynamic>()
        .firstOrNull;
    final workplace = resident?.raw['workplace']?.toString() ?? '';
    final home = resident?.raw['home']?.toString() ?? '';
    if (workplace.isNotEmpty) return workplace;
    if (home.isNotEmpty) return home;
    return fallback.isEmpty ? 'office_lounge' : fallback;
  }

  String _discussionLocation(
    String residentId,
    List<String> route,
    String fallback,
  ) {
    final cafe = route.firstWhere(
      (item) => item.contains('cafe') || item.contains('coffee'),
      orElse: () => '',
    );
    if (cafe.isNotEmpty) return cafe;
    return _nextRouteLocation(route, fallback);
  }

  String _interactionTarget({
    required String residentId,
    required String relationship,
    required List<String> rumorTags,
    required List<String> festivalTags,
    required List<String> memoryTags,
  }) {
    final candidates = _residentRuntimeManager.residents
        .where((resident) => resident.id != residentId && resident.enabled)
        .toList(growable: false);
    if (candidates.isEmpty) return '';
    if (rumorTags.isNotEmpty) return candidates.first.id;
    if (_isFriend(relationship) && candidates.length > 1) {
      return candidates[1].id;
    }
    if (festivalTags.isNotEmpty && candidates.length > 2) {
      return candidates[2].id;
    }
    if (memoryTags.isNotEmpty) return candidates.last.id;
    return candidates.first.id;
  }

  bool _isBadWeather(String type, List<String> tags) {
    final values = <String>{type, ...tags};
    return values.any((item) =>
        item.contains('rain') ||
        item.contains('storm') ||
        item.contains('typhoon') ||
        item.contains('hurricane') ||
        item.contains('fog'));
  }

  bool _isFriend(String relationship) {
    return relationship == 'friend' ||
        relationship == 'close_friend' ||
        relationship == 'family_reserved';
  }

  bool _isNight() {
    final hour = _worldClockManager.hour();
    return hour >= 20 || hour < 5;
  }

  bool _longTimeNoMeet(String lastMeetTime) {
    final last = DateTime.tryParse(lastMeetTime);
    if (last == null) return false;
    return WorldClockManager.systemNow().difference(last).inDays >= 7;
  }

  String _storyMood(List<String> memoryTags) {
    if (memoryTags.any((tag) => tag.contains('help'))) return 'grateful';
    if (memoryTags.any((tag) => tag.contains('fun') || tag.contains('joke'))) {
      return 'playful';
    }
    return 'curious';
  }

  String _activityByMood(String mood, String weatherName) {
    final normalized = normalizeResidentMood(mood);
    if (normalized == 'tired') return '找个安静的位置休息一会儿。';
    if (normalized == 'curious') return '绕到窗边看看今天的海面。';
    if (normalized == 'happy') return '带着好心情到处打招呼。';
    if (normalized == 'lonely') return '在熟悉的位置等一个轻松的招呼。';
    if (normalized == 'angry') return '少说几句，先让自己安静下来。';
    if (normalized == 'grateful') return '想找机会认真说声谢谢。';
    if (weatherName.isNotEmpty) return '因为$weatherName，临时换了今天的安排。';
    return '按自己的节奏换个地方生活一会儿。';
  }
}
