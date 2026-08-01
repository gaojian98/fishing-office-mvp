import 'package:flutter/foundation.dart';

import '../managers/living_world_managers.dart';
import '../modules/living_world_modules.dart';

class LivingWorldProvider extends ChangeNotifier {
  LivingWorldProvider(this.manager);

  final LivingWorldManager manager;

  bool get loaded => manager.loaded;
  Object? get error => manager.error;
  WorldCapabilityModule get world => manager.world;
  ResidentCapabilityModule get resident => manager.resident;
  EventCapabilityModule get event => manager.event;

  Future<void> load() => manager.load();
}
