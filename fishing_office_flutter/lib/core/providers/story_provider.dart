import 'package:flutter/foundation.dart';

import '../managers/story_manager.dart';

class StoryProvider extends ChangeNotifier {
  StoryProvider(this.manager);

  final StoryManager manager;

  bool get loaded => manager.loaded;
  Object? get error => manager.error;
  int get storyCount => manager.stories.length;

  Future<void> load() => manager.load();
}
