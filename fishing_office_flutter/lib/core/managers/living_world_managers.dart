import 'package:flutter/foundation.dart';

import '../modules/living_world_modules.dart';
import '../repository/living_world_repository.dart';
import '../repository/resident_life_repository.dart';

class LivingWorldManager extends ChangeNotifier {
  LivingWorldManager({
    required this.worldClockRepository,
    required this.timelineRepository,
    required this.residentLifeRepository,
    required this.memoryRepository,
    required this.relationshipRepository,
    required this.dialogueContextRepository,
    required this.eventTriggerRepository,
  });

  final WorldClockRepository worldClockRepository;
  final WorldTimelineRepository timelineRepository;
  final ResidentLifeRepository residentLifeRepository;
  final MemoryRepository memoryRepository;
  final RelationshipLevelRepository relationshipRepository;
  final DialogueContextRepository dialogueContextRepository;
  final EventTriggerRepository eventTriggerRepository;

  WorldCapabilityModule _world = const WorldCapabilityModule();
  ResidentCapabilityModule _resident = const ResidentCapabilityModule();
  EventCapabilityModule _event = const EventCapabilityModule();
  Object? _error;

  WorldCapabilityModule get world => _world;
  ResidentCapabilityModule get resident => _resident;
  EventCapabilityModule get event => _event;
  Object? get error => _error;
  bool get loaded => _world.loaded || _resident.loaded || _event.loaded;

  Future<void> load() async {
    try {
      final worldConfig = await worldClockRepository.load();
      final timelineConfig = await timelineRepository.load();
      final residentLife = await residentLifeRepository.load();
      final memoryConfig = await memoryRepository.load();
      final relationshipConfig = await relationshipRepository.load();
      final dialogueConfig = await dialogueContextRepository.load();
      final eventConfig = await eventTriggerRepository.load();

      _world = WorldCapabilityModule(
        config: worldConfig,
        clock: WorldClockState.fromConfig(worldConfig.clock),
        timeline: timelineConfig,
      );
      _resident = ResidentCapabilityModule(
        life: residentLife,
        memory: memoryConfig,
        relationship: relationshipConfig,
        dialogue: dialogueConfig,
      );
      _event = EventCapabilityModule(triggers: eventConfig);
      _error = null;

      if (kDebugMode) {
        debugPrint(
          'LivingWorldManager Loaded | time=${_world.clock?.timeLabel ?? '-'} schedules=${_resident.scheduleCount} memories=${_resident.memoryTriggerCount} events=${_event.triggerCount}',
        );
      }
    } catch (error) {
      _error = error;
      if (kDebugMode) {
        debugPrint('LivingWorldManager Load Failed | $error');
      }
    }
    notifyListeners();
  }
}
