import '../../models/store_config.dart';
import '../../services/store_config_loader.dart';
import 'repository.dart';
import 'json/json_source.dart';

class StoreRepositoryLoader implements Repository<StoreConfigBundle> {
  const StoreRepositoryLoader();

  @override
  Future<StoreConfigBundle> load() => const StoreConfigLoader().load();
}

class StoreJsonSource implements JsonSource {
  const StoreJsonSource();

  @override
  Future<String> loadString(String path) async {
    throw UnimplementedError('Use StoreConfigLoader for bundled store configs.');
  }
}
