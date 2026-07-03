import 'world_clock.dart';
import 'world_news.dart';

class WorldState {
  const WorldState({
    required this.worldId,
    required this.clock,
    required this.weather,
    required this.worldData,
    required this.citizens,
    required this.companions,
    required this.events,
    required this.generatedNews,
    required this.updatedAt,
  });

  factory WorldState.initial() {
    return WorldState(
      worldId: 'second_world',
      clock: WorldClock.initial(),
      weather: const ['calm'],
      worldData: const {},
      citizens: const [],
      companions: const [],
      events: const [],
      generatedNews: const [],
      updatedAt: DateTime.now(),
    );
  }

  final String worldId;
  final WorldClock clock;
  final List<String> weather;
  final Map<String, dynamic> worldData;
  final List<String> citizens;
  final List<String> companions;
  final List<String> events;
  final List<WorldNews> generatedNews;
  final DateTime updatedAt;

  WorldState copyWith({
    String? worldId,
    WorldClock? clock,
    List<String>? weather,
    Map<String, dynamic>? worldData,
    List<String>? citizens,
    List<String>? companions,
    List<String>? events,
    List<WorldNews>? generatedNews,
    DateTime? updatedAt,
  }) {
    return WorldState(
      worldId: worldId ?? this.worldId,
      clock: clock ?? this.clock,
      weather: weather ?? this.weather,
      worldData: worldData ?? this.worldData,
      citizens: citizens ?? this.citizens,
      companions: companions ?? this.companions,
      events: events ?? this.events,
      generatedNews: generatedNews ?? this.generatedNews,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
