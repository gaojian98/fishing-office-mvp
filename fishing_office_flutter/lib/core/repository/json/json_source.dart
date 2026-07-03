import 'package:flutter/services.dart';

abstract class JsonSource {
  Future<String> loadString(String path);
}

class AssetJsonSource implements JsonSource {
  const AssetJsonSource();

  @override
  Future<String> loadString(String path) => rootBundle.loadString(path);
}

