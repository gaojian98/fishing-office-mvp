import 'dart:convert';

import 'json/json_source.dart';

class ContentDocument {
  const ContentDocument({
    required this.path,
    required this.version,
    required this.items,
    required this.raw,
  });

  final String path;
  final String version;
  final List<Map<String, dynamic>> items;
  final Map<String, dynamic> raw;

  factory ContentDocument.fromJson({
    required String path,
    required Map<String, dynamic> json,
  }) {
    return ContentDocument(
      path: path,
      version: json['version']?.toString() ?? '1.0',
      items: _listOfMaps(json['items']),
      raw: Map<String, dynamic>.from(json),
    );
  }

  static List<Map<String, dynamic>> _listOfMaps(Object? value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
}

class ContentRepository {
  const ContentRepository({
    required this.source,
    this.basePath = '05_Content',
  });

  final JsonSource source;
  final String basePath;

  Future<ContentDocument> loadSample(String section) {
    return loadDocument('$basePath/$section/sample.json');
  }

  Future<ContentDocument> loadDocument(String path) async {
    final raw = await source.loadString(path);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return ContentDocument.fromJson(path: path, json: json);
  }
}
