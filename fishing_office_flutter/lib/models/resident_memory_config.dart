class ResidentMemoryConfig {
  const ResidentMemoryConfig({
    required this.version,
    required this.memories,
  });

  factory ResidentMemoryConfig.fromJson(Map<String, dynamic> json) {
    return ResidentMemoryConfig(
      version: json['version']?.toString() ?? '1.0',
      memories: _listOfMaps(json['memories'])
          .map(ResidentMemoryRecord.fromJson)
          .toList(growable: false),
    );
  }

  final String version;
  final List<ResidentMemoryRecord> memories;

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'memories': memories.map((item) => item.toJson()).toList(growable: false),
    };
  }
}

class ResidentMemoryRecord {
  const ResidentMemoryRecord({
    required this.residentId,
    required this.firstMeetTime,
    required this.lastMeetTime,
    required this.meetCount,
    required this.lastInteraction,
    required this.memoryTags,
    this.emotionHistory = const <Map<String, dynamic>>[],
  });

  factory ResidentMemoryRecord.empty(String residentId) {
    return ResidentMemoryRecord(
      residentId: residentId,
      firstMeetTime: '',
      lastMeetTime: '',
      meetCount: 0,
      lastInteraction: '',
      memoryTags: const [],
      emotionHistory: const <Map<String, dynamic>>[],
    );
  }

  factory ResidentMemoryRecord.fromJson(Map<String, dynamic> json) {
    return ResidentMemoryRecord(
      residentId: json['residentId']?.toString() ?? '',
      firstMeetTime: json['firstMeetTime']?.toString() ?? '',
      lastMeetTime: json['lastMeetTime']?.toString() ?? '',
      meetCount: _readInt(json['meetCount']),
      lastInteraction: json['lastInteraction']?.toString() ?? '',
      memoryTags: _stringList(json['memoryTags']),
      emotionHistory: _listOfMaps(json['emotionHistory']),
    );
  }

  final String residentId;
  final String firstMeetTime;
  final String lastMeetTime;
  final int meetCount;
  final String lastInteraction;
  final List<String> memoryTags;
  final List<Map<String, dynamic>> emotionHistory;

  ResidentMemoryRecord copyWith({
    String? residentId,
    String? firstMeetTime,
    String? lastMeetTime,
    int? meetCount,
    String? lastInteraction,
    List<String>? memoryTags,
    List<Map<String, dynamic>>? emotionHistory,
  }) {
    return ResidentMemoryRecord(
      residentId: residentId ?? this.residentId,
      firstMeetTime: firstMeetTime ?? this.firstMeetTime,
      lastMeetTime: lastMeetTime ?? this.lastMeetTime,
      meetCount: meetCount ?? this.meetCount,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      memoryTags: memoryTags ?? this.memoryTags,
      emotionHistory: emotionHistory ?? this.emotionHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'residentId': residentId,
      'firstMeetTime': firstMeetTime,
      'lastMeetTime': lastMeetTime,
      'meetCount': meetCount,
      'lastInteraction': lastInteraction,
      'memoryTags': memoryTags,
      'emotionHistory': emotionHistory,
    };
  }
}

List<Map<String, dynamic>> _listOfMaps(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return value
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
