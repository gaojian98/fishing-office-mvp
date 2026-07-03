import 'dart:async';

import 'world_clock.dart';
import 'world_news.dart';
import 'world_state.dart';

typedef WorldEngineListener = void Function(WorldState state);

class WorldEngine {
  WorldEngine({
    WorldState? initialState,
    List<WorldEngineListener> listeners = const [],
  })  : _state = initialState ?? WorldState.initial(),
        _listeners = List<WorldEngineListener>.from(listeners);

  WorldState _state;
  final List<WorldEngineListener> _listeners;
  final StreamController<WorldState> _stateController =
      StreamController<WorldState>.broadcast();
  final StreamController<WorldNews> _newsController =
      StreamController<WorldNews>.broadcast();

  WorldState get state => _state;
  WorldClock get clock => _state.clock;

  Stream<WorldState> get states => _stateController.stream;
  Stream<WorldNews> get news => _newsController.stream;

  void addListener(WorldEngineListener listener) {
    _listeners.add(listener);
  }

  void removeListener(WorldEngineListener listener) {
    _listeners.remove(listener);
  }

  void emit(WorldState state) {
    _state = state;
    for (final listener in List<WorldEngineListener>.from(_listeners)) {
      listener(state);
    }
    _stateController.add(state);
  }

  WorldState updateState({
    WorldClock? clock,
    List<String>? weather,
    Map<String, dynamic>? worldData,
    List<String>? citizens,
    List<String>? companions,
    List<String>? events,
    List<WorldNews>? generatedNews,
  }) {
    final updated = _state.copyWith(
      clock: clock,
      weather: weather,
      worldData: worldData,
      citizens: citizens,
      companions: companions,
      events: events,
      generatedNews: generatedNews,
    );
    emit(updated);
    return updated;
  }

  WorldNews publishNews({
    required String title,
    required String summary,
    Map<String, dynamic> context = const {},
  }) {
    final item = WorldNews(
      newsId: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      summary: summary,
      time: clock,
      context: context,
      createdAt: DateTime.now(),
    );
    _state = _state.copyWith(
      generatedNews: [..._state.generatedNews, item],
    );
    _newsController.add(item);
    emit(_state);
    return item;
  }

  WorldState tick({
    WorldClock? clock,
    List<String>? weather,
    Map<String, dynamic>? worldData,
    List<String>? citizens,
    List<String>? companions,
    List<String>? events,
  }) {
    final updated = _state.copyWith(
      clock: clock ?? _state.clock.tick(),
      weather: weather ?? _state.weather,
      worldData: worldData ?? _state.worldData,
      citizens: citizens ?? _state.citizens,
      companions: companions ?? _state.companions,
      events: events ?? _state.events,
      generatedNews: _state.generatedNews,
    );
    emit(updated);
    return updated;
  }

  Future<void> dispose() async {
    await _stateController.close();
    await _newsController.close();
  }
}
