import 'dart:async';

import 'bridge_calendar.dart';
import 'bridge_dialogue.dart';
import 'bridge_festival.dart';
import 'bridge_weather.dart';
import 'time_manager.dart';

typedef FirstWorldBridgeListener = void Function(BridgeDialogue dialogue);

class FirstWorldBridge {
  FirstWorldBridge({
    required this.timeManager,
    BridgeCalendar? calendar,
    BridgeFestival? festival,
    BridgeWeather? weather,
    List<FirstWorldBridgeListener> listeners = const [],
  })  : calendar = calendar ?? const BridgeCalendar(),
        festival = festival ?? const BridgeFestival(),
        weather = weather ?? const BridgeWeather(),
        _listeners = List<FirstWorldBridgeListener>.from(listeners);

  final TimeManager timeManager;
  final BridgeCalendar calendar;
  final BridgeFestival festival;
  final BridgeWeather weather;
  final List<FirstWorldBridgeListener> _listeners;
  final StreamController<BridgeDialogue> _dialogueController =
      StreamController<BridgeDialogue>.broadcast();

  Stream<BridgeDialogue> get dialogues => _dialogueController.stream;

  BridgeDialogue buildDialogue({
    required String playerId,
    Map<String, dynamic> publicContext = const {},
  }) {
    final bridgeCalendar = calendar.resolve(timeManager: timeManager);
    final bridgeFestival = festival.resolve(calendar: bridgeCalendar);
    final bridgeWeather = weather.resolve(calendar: bridgeCalendar);
    final dialogue = BridgeDialogue.fromContext(
      playerId: playerId,
      calendar: bridgeCalendar,
      festival: bridgeFestival,
      weather: bridgeWeather,
      publicContext: publicContext,
    );
    _emit(dialogue);
    return dialogue;
  }

  void _emit(BridgeDialogue dialogue) {
    for (final listener in List<FirstWorldBridgeListener>.from(_listeners)) {
      listener(dialogue);
    }
    _dialogueController.add(dialogue);
  }

  void addListener(FirstWorldBridgeListener listener) {
    _listeners.add(listener);
  }

  void removeListener(FirstWorldBridgeListener listener) {
    _listeners.remove(listener);
  }

  Future<void> dispose() async {
    await _dialogueController.close();
  }
}
