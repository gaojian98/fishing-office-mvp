import 'dart:convert';

import '../../models/living_world_config.dart';
import 'json/json_source.dart';

class WorldClockRepository {
  const WorldClockRepository({
    required this.source,
    this.path = 'assets/config/world.json',
  });

  final JsonSource source;
  final String path;

  Future<WorldConfig> load() async {
    final raw = await source.loadString(path);
    return WorldConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

class MemoryRepository {
  const MemoryRepository({
    required this.source,
    this.path = 'assets/config/memory.json',
  });

  final JsonSource source;
  final String path;

  Future<MemoryConfig> load() async {
    final raw = await source.loadString(path);
    return MemoryConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

class RelationshipLevelRepository {
  const RelationshipLevelRepository({
    required this.source,
    this.path = 'assets/config/relationship.json',
  });

  final JsonSource source;
  final String path;

  Future<RelationshipConfig> load() async {
    final raw = await source.loadString(path);
    return RelationshipConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

class WorldTimelineRepository {
  const WorldTimelineRepository({
    required this.source,
    this.path = 'assets/config/world_timeline.json',
  });

  final JsonSource source;
  final String path;

  Future<WorldTimelineConfig> load() async {
    final raw = await source.loadString(path);
    return WorldTimelineConfig.fromJson(
        jsonDecode(raw) as Map<String, dynamic>);
  }
}

class DialogueContextRepository {
  const DialogueContextRepository({
    required this.source,
    this.path = 'assets/config/dialogue_context.json',
  });

  final JsonSource source;
  final String path;

  Future<DialogueContextConfig> load() async {
    final raw = await source.loadString(path);
    return DialogueContextConfig.fromJson(
        jsonDecode(raw) as Map<String, dynamic>);
  }
}

class EventTriggerRepository {
  const EventTriggerRepository({
    required this.source,
    this.path = 'assets/config/event_trigger.json',
  });

  final JsonSource source;
  final String path;

  Future<EventTriggerConfig> load() async {
    final raw = await source.loadString(path);
    return EventTriggerConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
