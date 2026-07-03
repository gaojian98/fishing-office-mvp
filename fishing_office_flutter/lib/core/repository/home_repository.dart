import 'repository.dart';
import '../../services/home_config_loader.dart';

class HomeRepositoryBundle {
  const HomeRepositoryBundle({
    required this.bundle,
  });

  final HomeConfigBundle bundle;
}

class HomeRepositoryLoader implements Repository<HomeRepositoryBundle> {
  const HomeRepositoryLoader();

  @override
  Future<HomeRepositoryBundle> load() async {
    return HomeRepositoryBundle(bundle: await const HomeConfigLoader().load());
  }
}
