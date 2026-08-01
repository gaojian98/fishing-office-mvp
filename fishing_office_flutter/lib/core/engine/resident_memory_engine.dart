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

  ResidentMemoryConfig toConfig() {
    final items = records..sort((a, b) => a.residentId.compareTo(b.residentId));
    return ResidentMemoryConfig(version: _version, memories: items);
  }

  Map<String, dynamic> toJson() => toConfig().toJson();
}
