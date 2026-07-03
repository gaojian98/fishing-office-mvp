import 'dart:async';

import 'weather_dialogue_hint.dart';
import 'weather_effect.dart';
import 'weather_state.dart';
import 'world_calendar.dart';
import 'world_clock.dart';

typedef WeatherSystemListener = void Function(WeatherState state);

class WeatherSystem {
  WeatherSystem({
    WeatherState? initialState,
    List<WeatherSystemListener> listeners = const [],
  })  : _state = initialState ?? WeatherState.initial(),
        _listeners = List<WeatherSystemListener>.from(listeners);

  WeatherState _state;
  final List<WeatherSystemListener> _listeners;
  final StreamController<WeatherState> _stateController =
      StreamController<WeatherState>.broadcast();

  WeatherState get state => _state;
  Stream<WeatherState> get states => _stateController.stream;

  void addListener(WeatherSystemListener listener) {
    _listeners.add(listener);
  }

  void removeListener(WeatherSystemListener listener) {
    _listeners.remove(listener);
  }

  void emit(WeatherState state) {
    _state = state;
    for (final listener in List<WeatherSystemListener>.from(_listeners)) {
      listener(state);
    }
    _stateController.add(state);
  }

  WeatherState resolve({
    required WorldCalendar calendar,
    required WorldClock clock,
    WeatherEffect? effect,
  }) {
    final next = WeatherState.resolve(
      calendar: calendar,
      clock: clock,
      effect: effect,
    );
    emit(next);
    return next;
  }

  WeatherDialogueHint buildDialogueHint() {
    return WeatherDialogueHint.fromState(_state);
  }

  Future<void> dispose() async {
    await _stateController.close();
  }
}
