import 'package:flutter/foundation.dart';

import '../../models/resident_memory_config.dart';
import '../../models/resident_relationship_config.dart';
import 'resident_memory_engine.dart';
import '../managers/world_clock_manager.dart';

class ResidentRelationshipEngine extends ChangeNotifier {
  ResidentRelationshipEngine({
    required ResidentRelationshipConfig config,
    required ResidentMemoryEngine memoryEngine,
  })  : _memoryEngine = memoryEngine,
        _version = config.version,
        _levelRules = _sortedLevelRules(config.levels) {
    _relationships.addEntries(
      config.relationships
          .where((item) => item.residentId.isNotEmpty)
          .map((item) => MapEntry(item.residentId, item)),
    );
  }

  final ResidentMemoryEngine _memoryEngine;
  final String _version;
  final List<ResidentRelationshipLevelRule> _levelRules;
  final Map<String, ResidentRelationshipRecord> _relationships =
      <String, ResidentRelationshipRecord>{};

  List<ResidentRelationshipRecord> get relationships =>
      _relationships.values.toList(growable: false);

  ResidentRelationshipRecord getRelationship(String id) {
    return _relationships[id] ?? ResidentRelationshipRecord.empty(id);
  }

  void loadRelationships(List<ResidentRelationshipRecord> relationships) {
    _relationships
      ..clear()
      ..addEntries(relationships
          .where((item) => item.residentId.isNotEmpty)
          .map((item) => MapEntry(item.residentId, item)));
    notifyListeners();
  }

  ResidentRelationshipRecord updateRelationship(String id, {DateTime? time}) {
    final memory = _memoryEngine.getResidentMemory(id);
    final current = getRelationship(id);
    final resolvedLevel = _levelForMemory(memory);
    final score = _scoreForMemory(memory);
    final reason = _reasonFor(memory, resolvedLevel);
    final changedAt = (time ?? WorldClockManager.systemNow()).toIso8601String();
    final tags = <String>{
      ...current.tags,
      ...memory.memoryTags,
      resolvedLevel,
    }.where((item) => item.isNotEmpty).toList(growable: false);
    final updated = current.copyWith(
      residentId: id,
      relationshipLevel: resolvedLevel,
      relationshipScore: score,
      lastChangedAt: changedAt,
      reason: reason,
      tags: tags,
    );
    _relationships[id] = updated;
    if (kDebugMode) {
      debugPrint(
          'ResidentRelationshipEngine | resident=$id level=$resolvedLevel score=$score reason=$reason');
    }
    notifyListeners();
    return updated;
  }

  ResidentRelationshipConfig toConfig() {
    final items = relationships
      ..sort((a, b) => a.residentId.compareTo(b.residentId));
    return ResidentRelationshipConfig(
      version: _version,
      levels: _levelRules,
      relationships: items,
    );
  }

  Map<String, dynamic> toJson() => toConfig().toJson();

  String _levelForMemory(ResidentMemoryRecord memory) {
    var selected = 'stranger';
    for (final rule in _levelRules) {
      if (!rule.enabled) continue;
      if (memory.meetCount >= rule.minMeetCount) {
        selected = rule.id;
      }
    }
    return selected;
  }

  int _scoreForMemory(ResidentMemoryRecord memory) {
    var score = memory.meetCount;
    if (memory.lastInteraction.isNotEmpty && memory.lastInteraction != 'meet') {
      score += 1;
    }
    if (memory.memoryTags.contains('help')) {
      score += 2;
    }
    if (memory.memoryTags.contains('mood:grateful')) {
      score += 1;
    }
    return score;
  }

  String _reasonFor(ResidentMemoryRecord memory, String level) {
    if (memory.meetCount <= 0) return '尚未见面';
    if (memory.memoryTags.contains('mood:grateful')) {
      return '居民记得你的帮助，关系温和提升。';
    }
    if (level == 'known') return '第一次见面后，居民开始认识你。';
    if (level == 'friend') return '多次互动后，居民把你当作朋友。';
    if (level == 'close_friend') return '长期陪伴后，关系变得亲近。';
    if (level == 'family_reserved') return '家人关系暂时预留。';
    return '关系根据居民记忆自动计算。';
  }

  static List<ResidentRelationshipLevelRule> _sortedLevelRules(
      List<ResidentRelationshipLevelRule> rules) {
    final normalized = rules.isEmpty
        ? const <ResidentRelationshipLevelRule>[
            ResidentRelationshipLevelRule(
                id: 'stranger',
                name: '陌生',
                minMeetCount: 0,
                enabled: true,
                sortOrder: 1),
            ResidentRelationshipLevelRule(
                id: 'known',
                name: '认识',
                minMeetCount: 1,
                enabled: true,
                sortOrder: 2),
            ResidentRelationshipLevelRule(
                id: 'friend',
                name: '朋友',
                minMeetCount: 5,
                enabled: true,
                sortOrder: 3),
            ResidentRelationshipLevelRule(
                id: 'close_friend',
                name: '亲近的朋友',
                minMeetCount: 20,
                enabled: true,
                sortOrder: 4),
            ResidentRelationshipLevelRule(
                id: 'family_reserved',
                name: '家人（预留）',
                minMeetCount: 999999,
                enabled: false,
                sortOrder: 5),
          ]
        : rules;
    return List<ResidentRelationshipLevelRule>.from(normalized)
      ..sort((a, b) => a.minMeetCount.compareTo(b.minMeetCount));
  }
}
