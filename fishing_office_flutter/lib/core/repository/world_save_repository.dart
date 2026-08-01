import '../../models/world_save_data.dart';

abstract class WorldSaveRepository {
  Future<void> save(WorldSaveData data);
  Future<WorldSaveData?> load();
  Future<void> reset();
}

class InMemoryWorldSaveRepository implements WorldSaveRepository {
  WorldSaveData? _data;

  @override
  Future<void> save(WorldSaveData data) async {
    _data = data;
  }

  @override
  Future<WorldSaveData?> load() async {
    return _data;
  }

  @override
  Future<void> reset() async {
    _data = null;
  }
}
