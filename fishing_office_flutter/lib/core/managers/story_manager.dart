import 'package:flutter/foundation.dart';

import '../../models/story_config.dart';
import '../repository/story_repository.dart';

class StoryManager extends ChangeNotifier {
  StoryManager(this.repository);

  final StoryRepository repository;
  StoryConfig? _config;
  bool _loaded = false;
  Object? _error;

  StoryConfig? get config => _config;
  bool get loaded => _loaded;
  Object? get error => _error;
  List<Map<String, dynamic>> get stories =>
      _config?.stories ?? const <Map<String, dynamic>>[];

  Future<void> load() async {
    try {
      _config = await repository.load();
      _loaded = true;
      _error = null;
      if (kDebugMode) {
        debugPrint('StoryManager Loaded | stories=${stories.length}');
      }
    } catch (error) {
      _loaded = false;
      _error = error;
      if (kDebugMode) {
        debugPrint('StoryManager Load Failed | $error');
      }
    }
    notifyListeners();
  }
}
