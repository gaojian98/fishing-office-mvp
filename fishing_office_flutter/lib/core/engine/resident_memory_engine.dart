import 'package:flutter/foundation.dart';

import '../../models/resident_memory_config.dart';
import '../managers/world_clock_manager.dart';

class ResidentMemoryEngine extends ChangeNotifier {
  ResidentMemoryEngine({ResidentMemoryConfig? config}) {
    if (config != null) {
      load(config);
    }
  }

  String _version = '1.0';
  final Map<String, ResidentMemoryRecord> _records =
      <String, ResidentMemoryRecord>{};
  static const int longTermMemoryLimitPerResident = 60;

  List<ResidentMemoryRecord> get records =>
      _records.values.toList(growable: false);

  void load(ResidentMemoryConfig config) {
    _version = config.version;
    _records
      ..clear()
      ..addEntries(config.memories
          .where((item) => item.residentId.isNotEmpty)
          .map((item) => MapEntry(item.residentId, item)));
    notifyListeners();
  }

  ResidentMemoryRecord getResidentMemory(String id) {
    return _records[id] ?? ResidentMemoryRecord.empty(id);
  }

  ResidentMemoryRecord recordInteraction(
    String id,
    String type, {
    DateTime? time,
    List<String> tags = const [],
  }) {
    final now = (time ?? WorldClockManager.systemNow()).toIso8601String();
    final current = getResidentMemory(id);
    final firstMeet =
        current.firstMeetTime.isEmpty ? now : current.firstMeetTime;
    final nextMeetCount = current.meetCount + 1;
    final nextTags = <String>{
      ...current.memoryTags,
      if (current.meetCount == 0) 'first_meet' else 'repeat_meet',
      if (type.isNotEmpty) type,
      ...tags.where((item) => item.isNotEmpty),
    }.toList(growable: false);
    final updated = current.copyWith(
      residentId: id,
      firstMeetTime: firstMeet,
      lastMeetTime: now,
      meetCount: nextMeetCount,
      lastInteraction: type,
      memoryTags: nextTags,
    );
    _records[id] = updated;
    if (kDebugMode) {
      debugPrint(
          'ResidentMemoryEngine | resident=$id type=$type meetCount=$nextMeetCount');
    }
    notifyListeners();
    return updated;
  }

  ResidentMemoryRecord recordEmotionChange(
    String id, {
    required String previousMood,
    required String newMood,
    required String reason,
    DateTime? time,
    String relatedResidentId = '',
    String relatedStoryId = '',
    String relatedEventId = '',
  }) {
    if (id.isEmpty || newMood.isEmpty || previousMood == newMood) {
      return getResidentMemory(id);
    }
    final now = (time ?? WorldClockManager.systemNow()).toIso8601String();
    final current = getResidentMemory(id);
    final recentDuplicate = current.emotionHistory.any((item) {
      if (item['newMood']?.toString() != newMood ||
          item['reason']?.toString() != reason) {
        return false;
      }
      final recordedAt = DateTime.tryParse(item['timestamp']?.toString() ?? '');
      if (recordedAt == null) return false;
      final diff =
          (time ?? WorldClockManager.systemNow()).difference(recordedAt);
      return diff.inMinutes.abs() < 30;
    });
    if (recentDuplicate) return current;
    final emotion = {
      'residentId': id,
      'previousMood': previousMood,
      'newMood': newMood,
      'reason': reason,
      'timestamp': now,
      'relatedResidentId': relatedResidentId,
      'relatedStoryId': relatedStoryId,
      'relatedEventId': relatedEventId,
    };
    final updated = current.copyWith(
      residentId: id,
      lastMeetTime: current.lastMeetTime.isEmpty ? now : current.lastMeetTime,
      lastInteraction: 'emotion_changed',
      memoryTags: <String>{
        ...current.memoryTags,
        'emotion_changed',
        'mood:$newMood',
        if (reason.isNotEmpty) 'mood_reason:$reason',
      }.toList(growable: false),
      emotionHistory: <Map<String, dynamic>>[
        ...current.emotionHistory,
        emotion,
      ],
    );
    _records[id] = updated;
    if (kDebugMode) {
      debugPrint(
        'ResidentMemoryEngine | resident=$id mood=$previousMood->$newMood reason=$reason',
      );
    }
    notifyListeners();
    return updated;
  }

  LongTermResidentMemory? recordLongTermMemory(
    String residentId, {
    required String type,
    required String sourceId,
    required String summary,
    List<String> participants = const <String>[],
    int importance = 50,
    DateTime? createdAt,
    DateTime? expiresAt,
    Map<String, dynamic> effect = const <String, dynamic>{},
  }) {
    if (residentId.isEmpty || sourceId.isEmpty || summary.isEmpty) {
      return null;
    }
    final current = getResidentMemory(residentId);
    final existing = current.longTermMemories.where(
      (item) => item.sourceId == sourceId,
    );
    if (existing.isNotEmpty) return existing.first;
    final now = createdAt ?? WorldClockManager.systemNow();
    final memory = LongTermResidentMemory(
      memoryId: 'ltm:$residentId:$sourceId',
      residentId: residentId,
      type: type.isEmpty ? 'interaction' : type,
      sourceId: sourceId,
      participants: <String>{
        residentId,
        ...participants.where((item) => item.isNotEmpty),
      }.toList(growable: false),
      summary: summary,
      importance: importance.clamp(0, 100).toInt(),
      createdAt: now.toIso8601String(),
      expiresAt: expiresAt?.toIso8601String() ?? '',
      effect: effect,
    );
    final memories = _boundedLongTermMemories(
      <LongTermResidentMemory>[
        memory,
        ...current.longTermMemories,
      ],
      now: now,
    );
    _records[residentId] = current.copyWith(
      residentId: residentId,
      lastMeetTime: current.lastMeetTime.isEmpty
          ? now.toIso8601String()
          : current.lastMeetTime,
      lastInteraction: type.isEmpty ? current.lastInteraction : type,
      memoryTags: <String>{
        ...current.memoryTags,
        'long_term_memory',
        if (type.isNotEmpty) 'memory_type:$type',
        ..._stringList(effect['tags']),
      }.toList(growable: false),
      longTermMemories: memories,
    );
    notifyListeners();
    return memory;
  }

  List<LongTermResidentMemory> compactLongTermMemories({
    DateTime? now,
  }) {
    final currentTime = now ?? WorldClockManager.systemNow();
    final changed = <LongTermResidentMemory>[];
    var didChange = false;
    for (final entry in _records.entries) {
      final compacted = _boundedLongTermMemories(
        entry.value.longTermMemories
            .where((item) => !item.isExpired(currentTime))
            .map((item) => item.decay(now: currentTime))
            .toList(growable: false),
        now: currentTime,
      );
      if (compacted.length != entry.value.longTermMemories.length ||
          !_sameMemoryImportance(compacted, entry.value.longTermMemories)) {
        _records[entry.key] = entry.value.copyWith(
          longTermMemories: compacted,
        );
        didChange = true;
      }
      changed.addAll(compacted);
    }
    if (didChange) notifyListeners();
    return changed;
  }

  ResidentMemorySummary getResidentMemorySummary(String residentId) {
    final memory = getResidentMemory(residentId);
    final active = _boundedLongTermMemories(
      memory.longTermMemories
          .where((item) => !item.isExpired(WorldClockManager.systemNow()))
          .toList(growable: false),
      now: WorldClockManager.systemNow(),
    );
    final byType = <String, int>{};
    for (final item in active) {
      byType[item.type] = (byType[item.type] ?? 0) + 1;
    }
    return ResidentMemorySummary(
      residentId: residentId,
      total: active.length,
      importantCount: active.where((item) => item.isImportant).length,
      recentSummaries: active
          .take(8)
          .map((item) => item.summary)
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      tags: <String>{
        ...memory.memoryTags,
        ...active.expand((item) => _stringList(item.effect['tags'])),
        ...byType.keys.map((type) => 'memory_type:$type'),
      }.where((item) => item.isNotEmpty).toList(growable: false),
      byType: byType,
    );
  }

  ResidentMemoryConfig toConfig() {
    final items = records..sort((a, b) => a.residentId.compareTo(b.residentId));
    return ResidentMemoryConfig(version: _version, memories: items);
  }

  Map<String, dynamic> toJson() => toConfig().toJson();

  List<LongTermResidentMemory> _boundedLongTermMemories(
    List<LongTermResidentMemory> memories, {
    required DateTime now,
  }) {
    final active =
        memories.where((item) => !item.isExpired(now)).toList(growable: false)
          ..sort((a, b) {
            final important = b.importance.compareTo(a.importance);
            if (important != 0) return important;
            return b.createdAt.compareTo(a.createdAt);
          });
    final important = active.where((item) => item.isImportant).toList();
    final normal = active.where((item) => !item.isImportant).toList();
    return <LongTermResidentMemory>[
      ...important,
      ...normal,
    ].take(longTermMemoryLimitPerResident).toList(growable: false);
  }

  bool _sameMemoryImportance(
    List<LongTermResidentMemory> a,
    List<LongTermResidentMemory> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i += 1) {
      if (a[i].memoryId != b[i].memoryId ||
          a[i].importance != b[i].importance) {
        return false;
      }
    }
    return true;
  }
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return value
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
