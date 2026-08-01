import 'package:flutter/foundation.dart';

import '../../models/resident_relationship_config.dart';
import '../engine/resident_relationship_engine.dart';
import '../engine/second_world_engine.dart';
import 'daily_simulation_manager.dart';
import 'resident_decision_manager.dart';
import 'resident_runtime_manager.dart';
import 'rumor_runtime_manager.dart';
import 'story_runtime_manager.dart';
import 'world_save_manager.dart';

class RuntimeRelationshipRecord {
  const RuntimeRelationshipRecord({
    required this.sourceId,
    required this.targetId,
    required this.level,
    required this.score,
    required this.lastChangedDay,
    required this.reason,
    required this.tags,
  });

  factory RuntimeRelationshipRecord.fromJson(Map<String, dynamic> json) {
    return RuntimeRelationshipRecord(
      sourceId: json['sourceId']?.toString() ?? '',
      targetId: json['targetId']?.toString() ?? '',
      level: json['level']?.toString() ?? 'stranger',
      score: _readInt(json['score']) ?? 0,
      lastChangedDay: _readInt(json['lastChangedDay']) ?? 0,
      reason: json['reason']?.toString() ?? '',
      tags: _stringList(json['tags']),
    );
  }

  factory RuntimeRelationshipRecord.empty(String sourceId, String targetId) {
    return RuntimeRelationshipRecord(
      sourceId: sourceId,
      targetId: targetId,
      level: 'stranger',
      score: 0,
      lastChangedDay: 0,
      reason: '尚未建立关系',
      tags: const <String>[],
    );
  }

  final String sourceId;
  final String targetId;
  final String level;
  final int score;
  final int lastChangedDay;
  final String reason;
  final List<String> tags;

  RuntimeRelationshipRecord copyWith({
    String? sourceId,
    String? targetId,
    String? level,
    int? score,
    int? lastChangedDay,
    String? reason,
    List<String>? tags,
  }) {
    return RuntimeRelationshipRecord(
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      level: level ?? this.level,
      score: score ?? this.score,
      lastChangedDay: lastChangedDay ?? this.lastChangedDay,
      reason: reason ?? this.reason,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceId': sourceId,
      'targetId': targetId,
      'level': level,
      'score': score,
      'lastChangedDay': lastChangedDay,
      'reason': reason,
      'tags': tags,
    };
  }
}

class RelationshipRuntimeManager extends ChangeNotifier {
  RelationshipRuntimeManager({
    required ResidentRuntimeManager residentRuntimeManager,
    required ResidentDecisionManager residentDecisionManager,
    required RumorRuntimeManager rumorRuntimeManager,
    required StoryRuntimeManager storyRuntimeManager,
    required DailySimulationManager dailySimulationManager,
    required WorldSaveManager worldSaveManager,
    required ResidentRelationshipEngine residentRelationshipEngine,
    SecondWorldEngine? secondWorldEngine,
  })  : _residentRuntimeManager = residentRuntimeManager,
        _residentDecisionManager = residentDecisionManager,
        _rumorRuntimeManager = rumorRuntimeManager,
        _storyRuntimeManager = storyRuntimeManager,
        _dailySimulationManager = dailySimulationManager,
        _worldSaveManager = worldSaveManager,
        _residentRelationshipEngine = residentRelationshipEngine,
        _secondWorldEngine = secondWorldEngine {
    _restoreState(worldSaveManager.relationshipRuntimeState);
  }

  final ResidentRuntimeManager _residentRuntimeManager;
  final ResidentDecisionManager _residentDecisionManager;
  final RumorRuntimeManager _rumorRuntimeManager;
  final StoryRuntimeManager _storyRuntimeManager;
  final DailySimulationManager _dailySimulationManager;
  final WorldSaveManager _worldSaveManager;
  final ResidentRelationshipEngine _residentRelationshipEngine;
  final SecondWorldEngine? _secondWorldEngine;

  final Map<String, RuntimeRelationshipRecord> _residentRelations =
      <String, RuntimeRelationshipRecord>{};
  int? _lastUpdateDay;

  int? get lastUpdateDay => _lastUpdateDay;

  List<RuntimeRelationshipRecord> get residentRelationships {
    final items = _residentRelations.values.toList(growable: false);
    return List<RuntimeRelationshipRecord>.from(items)
      ..sort((a, b) => _pairKey(a.sourceId, a.targetId)
          .compareTo(_pairKey(b.sourceId, b.targetId)));
  }

  void updateResidentRelationships() {
    final day = _today();
    final residents = _residentRuntimeManager.residents
        .where((item) => item.enabled)
        .toList();
    for (var i = 0; i < residents.length; i += 1) {
      for (var j = i + 1; j < residents.length; j += 1) {
        final a = residents[i].id;
        final b = residents[j].id;
        final amount = _dailyRelationshipDelta(a, b);
        final reason = _dailyReason(a, b, amount);
        applyRelationshipChange(a, b, reason, amount);
      }
    }
    for (final resident in residents) {
      _residentRelationshipEngine.updateRelationship(resident.id);
    }
    _lastUpdateDay = day;
    _persistState();
    if (kDebugMode) {
      debugPrint(
        'RelationshipRuntimeManager | day=$day residentPairs=${_residentRelations.length}',
      );
    }
    notifyListeners();
  }

  RuntimeRelationshipRecord getRelationshipBetweenResidents(
    String a,
    String b,
  ) {
    return _residentRelations[_pairKey(a, b)] ??
        RuntimeRelationshipRecord.empty(a, b);
  }

  ResidentRelationshipRecord getPlayerRelationshipWithResident(String id) {
    return _residentRelationshipEngine.updateRelationship(id);
  }

  RuntimeRelationshipRecord applyRelationshipChange(
    String source,
    String target,
    String reason,
    int amount,
  ) {
    if (source.isEmpty || target.isEmpty || source == target) {
      return RuntimeRelationshipRecord.empty(source, target);
    }
    final key = _pairKey(source, target);
    final current = _residentRelations[key] ??
        RuntimeRelationshipRecord.empty(source, target);
    final score = (current.score + amount).clamp(-20, 100).toInt();
    final tags = <String>{
      ...current.tags,
      _reasonTag(reason),
      _levelFor(score),
    }.where((item) => item.isNotEmpty).toList(growable: false);
    final updated = current.copyWith(
      sourceId: _firstId(source, target),
      targetId: _secondId(source, target),
      score: score,
      level: _levelFor(score),
      lastChangedDay: _today(),
      reason: reason,
      tags: tags,
    );
    _residentRelations[key] = updated;
    _persistState();
    return updated;
  }

  int _dailyRelationshipDelta(String a, String b) {
    var delta = 0;
    final stateA = _residentRuntimeManager.getResidentCurrentState(a);
    final stateB = _residentRuntimeManager.getResidentCurrentState(b);
    if (stateA.location == stateB.location && stateA.location.isNotEmpty) {
      delta += 2;
    }
    final decisionA = _residentDecisionManager.decisionFor(a);
    final decisionB = _residentDecisionManager.decisionFor(b);
    if (decisionA?.interactionTarget == b) delta += 2;
    if (decisionB?.interactionTarget == a) delta += 2;
    if (_rumorRuntimeManager.getRumorTags().isNotEmpty) delta += 1;
    if (_storyRuntimeManager.finishedStoryIds.isNotEmpty) delta += 2;
    if (_dailySimulationManager.getTodayWorldSummary()?.festival.isNotEmpty ==
        true) {
      delta += 1;
    }
    final current = getRelationshipBetweenResidents(a, b);
    if (current.lastChangedDay > 0 && _today() - current.lastChangedDay >= 7) {
      delta -= 2;
    }
    return delta == 0 ? -1 : delta;
  }

  String _dailyReason(String a, String b, int delta) {
    final stateA = _residentRuntimeManager.getResidentCurrentState(a);
    final stateB = _residentRuntimeManager.getResidentCurrentState(b);
    if (stateA.location == stateB.location && stateA.location.isNotEmpty) {
      return '共同地点让两位居民更熟悉。';
    }
    if (_storyRuntimeManager.finishedStoryIds.isNotEmpty) {
      return '共同经历故事后，关系推进。';
    }
    if (_rumorRuntimeManager.getRumorTags().isNotEmpty) {
      return '共同听见传闻后，关系发生变化。';
    }
    if (delta < 0) return '长时间未见，关系稍微变淡。';
    return '第二世界的日常让关系自然变化。';
  }

  String _levelFor(int score) {
    if (score <= -8) return 'misunderstanding';
    if (score < 0) return 'distant';
    if (score >= 60) return 'trust';
    if (score >= 40) return 'old_friend';
    if (score >= 20) return 'friend';
    if (score >= 5) return 'known';
    return 'stranger';
  }

  String _reasonTag(String reason) {
    if (reason.contains('传闻')) return 'rumor';
    if (reason.contains('故事')) return 'story';
    if (reason.contains('未见')) return 'long_absence';
    if (reason.contains('共同地点')) return 'same_location';
    if (reason.contains('和解')) return 'reconcile';
    if (reason.contains('误会')) return 'misunderstanding';
    return 'daily';
  }

  void _persistState() {
    _worldSaveManager.setRelationshipRuntimeState({
      'lastUpdateDay': _lastUpdateDay,
      'residentRelationships': residentRelationships
          .map((record) => record.toJson())
          .toList(growable: false),
      'hasSecondWorldEngine': _secondWorldEngine != null,
    });
  }

  void _restoreState(Map<String, dynamic> state) {
    if (state.isEmpty) return;
    _lastUpdateDay = _readInt(state['lastUpdateDay']);
    final records = state['residentRelationships'];
    if (records is List) {
      _residentRelations
        ..clear()
        ..addEntries(
          records.whereType<Map>().map((item) {
            final record = RuntimeRelationshipRecord.fromJson(
              Map<String, dynamic>.from(item),
            );
            return MapEntry(_pairKey(record.sourceId, record.targetId), record);
          }),
        );
    }
  }

  int _today() {
    final summary = _dailySimulationManager.getTodayWorldSummary();
    if (summary == null) return 0;
    return int.tryParse(summary.date.split('#').last) ?? 0;
  }

  String _pairKey(String a, String b) {
    return '${_firstId(a, b)}::${_secondId(a, b)}';
  }

  String _firstId(String a, String b) => a.compareTo(b) <= 0 ? a : b;
  String _secondId(String a, String b) => a.compareTo(b) <= 0 ? b : a;
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '');
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return value
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
