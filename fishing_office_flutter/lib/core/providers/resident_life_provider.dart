import 'package:flutter/foundation.dart';

import '../../models/living_world_config.dart';
import '../managers/resident_life_manager.dart';

class ResidentLifeProvider extends ChangeNotifier {
  ResidentLifeProvider(this.manager);

  final ResidentLifeManager manager;

  bool get loaded => manager.loaded;
  Object? get error => manager.error;
  int get scheduleCount => manager.schedules.length;
  int get activityCount => manager.activities.length;

  ResidentCurrentState getResidentCurrentState(
    String id, {
    WorldClockConfig? clock,
    DateTime? now,
  }) {
    return manager.getResidentCurrentState(id, clock: clock, now: now);
  }

  Future<void> load() => manager.load();
}
