import 'dart:async';

import 'time_manager.dart';
import 'today_mood.dart';
import 'today_news.dart';
import 'today_recommendation.dart';
import 'today_story.dart';

typedef TodayEngineListener = void Function(TodayStory story);

class TodayEngine {
  TodayEngine({
    required this.timeManager,
    List<TodayEngineListener> listeners = const [],
  }) : _listeners = List<TodayEngineListener>.from(listeners);

  final TimeManager timeManager;
  final List<TodayEngineListener> _listeners;
  final StreamController<TodayStory> _storyController =
      StreamController<TodayStory>.broadcast();

  Stream<TodayStory> get stories => _storyController.stream;

  TodayStory generateToday({
    required String worldId,
    List<String> worldEvents = const [],
    List<String> companionStates = const [],
    List<String> fishSignals = const [],
    Map<String, dynamic> worldData = const {},
  }) {
    final festivalState = timeManager.festivalState();
    final mood = TodayMood.resolve(
      timeLabel: timeManager.clock.timeLabel,
      festivalState: festivalState,
      weatherTags: List<String>.from(worldEvents),
      companionStates: companionStates,
      fishSignals: fishSignals,
    );
    final news = TodayNews.generate(
      worldId: worldId,
      mood: mood,
      worldEvents: worldEvents,
      companionStates: companionStates,
      fishSignals: fishSignals,
      festivalState: festivalState,
      worldData: worldData,
    );
    final recommendation = TodayRecommendation.generate(
      mood: mood,
      festivalState: festivalState,
      worldEvents: worldEvents,
      companionStates: companionStates,
      fishSignals: fishSignals,
    );
    final story = TodayStory(
      todayId: DateTime.now().microsecondsSinceEpoch.toString(),
      worldId: worldId,
      timeLabel: timeManager.clock.timeLabel,
      mood: mood,
      news: news,
      recommendation: recommendation,
      worldEvents: worldEvents,
      companionStates: companionStates,
      fishSignals: fishSignals,
      generatedAt: DateTime.now(),
      context: worldData,
    );
    _emit(story);
    return story;
  }

  void _emit(TodayStory story) {
    for (final listener in List<TodayEngineListener>.from(_listeners)) {
      listener(story);
    }
    _storyController.add(story);
  }

  void addListener(TodayEngineListener listener) {
    _listeners.add(listener);
  }

  void removeListener(TodayEngineListener listener) {
    _listeners.remove(listener);
  }

  Future<void> dispose() async {
    await _storyController.close();
  }
}
