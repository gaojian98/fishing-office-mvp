import '../../models/living_world_config.dart';
import '../../models/resident_life_config.dart';

class WorldClockState {
  const WorldClockState({
    required this.hour,
    required this.minute,
    required this.weekday,
    required this.month,
    required this.season,
  });

  final int hour;
  final int minute;
  final int weekday;
  final int month;
  final String season;

  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  factory WorldClockState.fromConfig(WorldClockConfig config) {
    return WorldClockState(
      hour: config.hour,
      minute: config.minute,
      weekday: config.weekday,
      month: config.month,
      season: config.season,
    );
  }
}

class DialogueContext {
  const DialogueContext({
    required this.weather,
    required this.time,
    required this.residentMood,
    required this.relationship,
    required this.memoryIds,
  });

  final String weather;
  final String time;
  final String residentMood;
  final String relationship;
  final List<String> memoryIds;
}

class WorldCapabilityModule {
  const WorldCapabilityModule({
    this.config,
    this.clock,
    this.timeline,
  });

  final WorldConfig? config;
  final WorldClockState? clock;
  final WorldTimelineConfig? timeline;

  bool get loaded => config != null || timeline != null;
  int get timelineCount => timeline?.milestones.length ?? 0;

  WorldCapabilityModule copyWith({
    WorldConfig? config,
    WorldClockState? clock,
    WorldTimelineConfig? timeline,
  }) {
    return WorldCapabilityModule(
      config: config ?? this.config,
      clock: clock ?? this.clock,
      timeline: timeline ?? this.timeline,
    );
  }
}

class ResidentCapabilityModule {
  const ResidentCapabilityModule({
    this.life,
    this.memory,
    this.relationship,
    this.dialogue,
  });

  final ResidentLifeConfig? life;
  final MemoryConfig? memory;
  final RelationshipConfig? relationship;
  final DialogueContextConfig? dialogue;

  bool get loaded =>
      life != null ||
      memory != null ||
      relationship != null ||
      dialogue != null;
  int get scheduleCount => life?.schedules.length ?? 0;
  int get activityCount => life?.activities.length ?? 0;
  int get memoryTriggerCount => memory?.triggers.length ?? 0;
  int get relationshipRuleCount => relationship?.rules.length ?? 0;
  List<String> get relationshipLevels => relationship?.levels.isNotEmpty == true
      ? relationship!.levels
      : const <String>['Stranger', 'Known', 'Friend', 'Close Friend', 'Family'];

  DialogueContext buildDialogueContext({
    String weather = '',
    String time = '',
    String residentMood = '',
    String relationship = '',
    List<String> memoryIds = const <String>[],
  }) {
    return DialogueContext(
      weather: weather,
      time: time,
      residentMood: residentMood,
      relationship: relationship,
      memoryIds: List<String>.unmodifiable(memoryIds),
    );
  }

  ResidentCapabilityModule copyWith({
    ResidentLifeConfig? life,
    MemoryConfig? memory,
    RelationshipConfig? relationship,
    DialogueContextConfig? dialogue,
  }) {
    return ResidentCapabilityModule(
      life: life ?? this.life,
      memory: memory ?? this.memory,
      relationship: relationship ?? this.relationship,
      dialogue: dialogue ?? this.dialogue,
    );
  }
}

class EventCapabilityModule {
  const EventCapabilityModule({this.triggers});

  final EventTriggerConfig? triggers;

  bool get loaded => triggers != null;
  int get triggerCount => triggers?.triggers.length ?? 0;

  EventCapabilityModule copyWith({EventTriggerConfig? triggers}) {
    return EventCapabilityModule(triggers: triggers ?? this.triggers);
  }
}
