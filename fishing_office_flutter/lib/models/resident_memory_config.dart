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
    this.longTermMemories = const <LongTermResidentMemory>[],
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
      longTermMemories: const <LongTermResidentMemory>[],
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
      longTermMemories: _listOfMaps(json['longTermMemories'])
          .map(LongTermResidentMemory.fromJson)
          .where((item) => item.memoryId.isNotEmpty)
          .toList(growable: false),
    );
  }

  final String residentId;
  final String firstMeetTime;
  final String lastMeetTime;
  final int meetCount;
  final String lastInteraction;
  final List<String> memoryTags;
  final List<Map<String, dynamic>> emotionHistory;
  final List<LongTermResidentMemory> longTermMemories;

  ResidentMemoryRecord copyWith({
    String? residentId,
    String? firstMeetTime,
    String? lastMeetTime,
    int? meetCount,
    String? lastInteraction,
    List<String>? memoryTags,
    List<Map<String, dynamic>>? emotionHistory,
    List<LongTermResidentMemory>? longTermMemories,
  }) {
    return ResidentMemoryRecord(
      residentId: residentId ?? this.residentId,
      firstMeetTime: firstMeetTime ?? this.firstMeetTime,
      lastMeetTime: lastMeetTime ?? this.lastMeetTime,
      meetCount: meetCount ?? this.meetCount,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      memoryTags: memoryTags ?? this.memoryTags,
      emotionHistory: emotionHistory ?? this.emotionHistory,
      longTermMemories: longTermMemories ?? this.longTermMemories,
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
      'longTermMemories':
          longTermMemories.map((item) => item.toJson()).toList(),
    };
  }
}

class LongTermResidentMemory {
  const LongTermResidentMemory({
    required this.memoryId,
    required this.residentId,
    required this.type,
    required this.sourceId,
    required this.participants,
    required this.summary,
    required this.importance,
    required this.createdAt,
    required this.expiresAt,
    required this.effect,
  });

  factory LongTermResidentMemory.fromJson(Map<String, dynamic> json) {
    return LongTermResidentMemory(
      memoryId: json['memoryId']?.toString() ?? '',
      residentId: json['residentId']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      sourceId: json['sourceId']?.toString() ?? '',
      participants: _stringList(json['participants']),
      summary: json['summary']?.toString() ?? '',
      importance: _readInt(json['importance']).clamp(0, 100).toInt(),
      createdAt: json['createdAt']?.toString() ?? '',
      expiresAt: json['expiresAt']?.toString() ?? '',
      effect: _mapOf(json['effect']),
    );
  }

  final String memoryId;
  final String residentId;
  final String type;
  final String sourceId;
  final List<String> participants;
  final String summary;
  final int importance;
  final String createdAt;
  final String expiresAt;
  final Map<String, dynamic> effect;

  bool get isImportant => importance >= 80;

  bool isExpired(DateTime now) {
    final expires = DateTime.tryParse(expiresAt);
    return expires != null && !isImportant && !expires.isAfter(now);
  }

  LongTermResidentMemory decay({
    required DateTime now,
    int amount = 5,
  }) {
    if (isImportant) return this;
    final created = DateTime.tryParse(createdAt);
    if (created == null || now.difference(created).inDays < 7) return this;
    return LongTermResidentMemory(
      memoryId: memoryId,
      residentId: residentId,
      type: type,
      sourceId: sourceId,
      participants: participants,
      summary: summary,
      importance: (importance - amount).clamp(0, 100).toInt(),
      createdAt: createdAt,
      expiresAt: expiresAt,
      effect: <String, dynamic>{...effect, 'decayed': true},
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'memoryId': memoryId,
      'residentId': residentId,
      'type': type,
      'sourceId': sourceId,
      'participants': participants,
      'summary': summary,
      'importance': importance,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      'effect': effect,
    };
  }
}

class ResidentMemorySummary {
  const ResidentMemorySummary({
    required this.residentId,
    required this.total,
    required this.importantCount,
    required this.recentSummaries,
    required this.tags,
    required this.byType,
  });

  final String residentId;
  final int total;
  final int importantCount;
  final List<String> recentSummaries;
  final List<String> tags;
  final Map<String, int> byType;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'residentId': residentId,
      'total': total,
      'importantCount': importantCount,
      'recentSummaries': recentSummaries,
      'tags': tags,
      'byType': byType,
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

Map<String, dynamic> _mapOf(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
