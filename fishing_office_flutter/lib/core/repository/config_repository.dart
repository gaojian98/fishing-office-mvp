import 'dart:convert';

import '../../models/animation_config.dart';
import '../../models/dialog_config.dart';
import '../../models/interaction_config.dart';
import '../../models/layout_config.dart';
import '../../models/routes_config.dart';
import 'repository.dart';
import 'json/json_source.dart';

class JsonConfigRepository<T> implements Repository<T> {
  JsonConfigRepository({
    required this.source,
    required this.path,
    required this.parse,
  });

  final JsonSource source;
  final String path;
  final T Function(Map<String, dynamic>) parse;

  @override
  Future<T> load() async {
    final raw = await source.loadString(path);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return parse(json);
  }
}

class LayoutRepository extends JsonConfigRepository<LayoutConfig> {
  LayoutRepository({required super.source, required super.path})
      : super(parse: LayoutConfig.fromJson);
}

class InteractionRepository extends JsonConfigRepository<InteractionConfig> {
  InteractionRepository({required super.source, required super.path})
      : super(parse: InteractionConfig.fromJson);
}

class AnimationRepository extends JsonConfigRepository<AnimationConfig> {
  AnimationRepository({required super.source, required super.path})
      : super(parse: AnimationConfig.fromJson);
}

class RoutesRepository extends JsonConfigRepository<RoutesConfig> {
  RoutesRepository({required super.source, required super.path})
      : super(parse: RoutesConfig.fromJson);
}

class DialogRepository extends JsonConfigRepository<DialogConfig> {
  DialogRepository({required super.source, required super.path})
      : super(parse: DialogConfig.fromJson);
}
