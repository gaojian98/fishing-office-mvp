import 'dart:async';

import 'ocean_ecology.dart';
import 'ocean_memory.dart';
import 'ocean_mood.dart';
import 'ocean_state.dart';

typedef OceanEngineListener = void Function(OceanState state);

class OceanEngine {
  OceanEngine({
    OceanState? initialState,
    List<OceanEngineListener> listeners = const [],
  })  : _state = initialState ?? OceanState.initial(),
        _listeners = List<OceanEngineListener>.from(listeners);

  OceanState _state;
  final List<OceanEngineListener> _listeners;
  final StreamController<OceanState> _stateController =
      StreamController<OceanState>.broadcast();

  OceanState get state => _state;
  Stream<OceanState> get states => _stateController.stream;

  void addListener(OceanEngineListener listener) {
    _listeners.add(listener);
  }

  void removeListener(OceanEngineListener listener) {
    _listeners.remove(listener);
  }

  void emit(OceanState state) {
    _state = state;
    for (final listener in List<OceanEngineListener>.from(_listeners)) {
      listener(state);
    }
    _stateController.add(state);
  }

  OceanState update({
    OceanMood? mood,
    OceanEcology? ecology,
    Map<String, dynamic>? seaData,
    List<String>? weatherTags,
    List<String>? memoryTags,
    List<String>? newsTags,
  }) {
    final updated = _state.copyWith(
      mood: mood,
      ecology: ecology,
      seaData: seaData,
      weatherTags: weatherTags,
      memoryTags: memoryTags,
      newsTags: newsTags,
    );
    emit(updated);
    return updated;
  }

  OceanMemory recordMemory({
    required String memoryType,
    required String description,
    Map<String, dynamic> payload = const {},
  }) {
    final memory = OceanMemory(
      memoryId: DateTime.now().microsecondsSinceEpoch.toString(),
      memoryType: memoryType,
      description: description,
      payload: payload,
      createdAt: DateTime.now(),
    );
    _state = _state.copyWith(
      memoryTags: [..._state.memoryTags, memory.memoryType],
    );
    emit(_state);
    return memory;
  }

  OceanMood resolveMood() => _state.mood;

  OceanEcology resolveEcology() => _state.ecology;

  Future<void> dispose() async {
    await _stateController.close();
  }
}
