import 'package:flutter/foundation.dart';

import '../../models/friendship_state.dart';
import '../../models/office_group.dart';
import '../../models/resident_relationship_config.dart';
import '../engine/resident_relationship_engine.dart';
import '../engine/second_world_engine.dart';
import '../utils/runtime_debug.dart';
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

  List<OfficeGroup> getActiveOfficeGroups() {
    final saved = _worldSaveManager.activeGroups;
    if (saved.isNotEmpty) return saved;
    return generateOfficeGroups(reason: 'runtime_probe');
  }

  List<OfficeGroup> getGroupsForResident(String residentId) {
    return getActiveOfficeGroups()
        .where((group) => group.containsResident(residentId))
        .toList(growable: false);
  }

  OfficeGroup? getPrimaryGroupForResident(String residentId) {
    final groups = getGroupsForResident(residentId);
    if (groups.isEmpty) return null;
    return groups.first;
  }

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
    final groups = generateOfficeGroups(reason: 'daily_relationship');
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
    for (final group in groups.take(8)) {
      applyOfficeGroupInteraction(
        group.groupId,
        sourceType: 'daily_office_group',
      );
    }
    _lastUpdateDay = day;
    _worldSaveManager.setDailySocialSummary(_buildDailySocialSummary(day));
    _persistState();
    RuntimeDebug.log(
      'RelationshipRuntimeManager | day=$day residentPairs=${_residentRelations.length}',
    );
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

  List<OfficeGroup> generateOfficeGroups({String reason = 'runtime'}) {
    final buckets = <String, List<String>>{};
    final states = _residentRuntimeManager.getAllResidentCurrentStates();
    for (final resident in _residentRuntimeManager.residents) {
      if (!resident.enabled) continue;
      final state = states[resident.id];
      if (state == null || !_isGroupableState(state.location, state.activity)) {
        continue;
      }
      final locationId = _normalizeGroupLocation(state.location);
      buckets.putIfAbsent(locationId, () => <String>[]).add(resident.id);
    }
    final groups = <OfficeGroup>[];
    final nowLabel = _timeLabel();
    final endLabel = _timeLabel(offsetMinutes: 45);
    final sortedLocations = buckets.keys.toList(growable: false)..sort();
    final scoreCache = <String, int>{};
    int scoreFor(String residentId) {
      return scoreCache.putIfAbsent(
        residentId,
        () => _groupCandidateScore(residentId),
      );
    }

    for (final locationId in sortedLocations) {
      final members = buckets[locationId]!;
      if (members.length < 2) continue;
      members.sort((a, b) {
        final score = scoreFor(b).compareTo(scoreFor(a));
        if (score != 0) return score;
        return a.compareTo(b);
      });
      for (var index = 0; index < members.length; index += 6) {
        final slice = members.skip(index).take(6).toList(growable: false);
        if (slice.length < 2) continue;
        final activity = _groupActivityFor(locationId, slice);
        final topic = _groupTopicFor(locationId, activity);
        final mood = _groupMoodFor(slice);
        final leader =
            slice.reduce((a, b) => scoreFor(a) >= scoreFor(b) ? a : b);
        groups.add(
          OfficeGroup(
            groupId: _groupId(
              locationId: locationId,
              members: slice,
              activity: activity,
            ),
            locationId: locationId,
            members: slice,
            leaderId: leader,
            topic: topic,
            mood: mood,
            activity: activity,
            startTime: nowLabel,
            expectedEndTime: endLabel,
            createdReason: reason,
            importance: _groupImportance(slice, activity),
            tags: _groupTags(locationId, activity, topic, mood),
          ),
        );
      }
    }
    final bounded = groups.take(18).toList(growable: false);
    _worldSaveManager.setOfficeGroupState(
      state: <String, dynamic>{
        'lastGeneratedDay': _today(),
        'lastGeneratedAt': nowLabel,
        'groupCount': bounded.length,
        'reason': reason,
      },
      activeGroups: bounded,
      recentGroups: <OfficeGroup>[
        ...bounded,
        ..._worldSaveManager.recentGroups,
      ],
      groupHistory: <OfficeGroup>[
        ...bounded,
        ..._worldSaveManager.groupHistory,
      ],
    );
    return bounded;
  }

  FriendshipState getFriendshipState(String residentId) {
    final relationship = getPlayerRelationshipWithResident(residentId);
    return _worldSaveManager.getFriendshipState(
      residentId,
      relationship: relationship,
    );
  }

  List<FriendshipState> getAllFriendshipStates() {
    return _residentRuntimeManager.residents
        .where((resident) => resident.enabled)
        .map((resident) => _worldSaveManager.getFriendshipState(resident.id))
        .toList(growable: false);
  }

  FriendshipChangeRecord? applyFriendshipChange({
    required String residentId,
    required String sourceType,
    required String sourceId,
    int scoreDelta = 0,
    int trustDelta = 0,
    int familiarityDelta = 0,
    String reason = '',
    List<String> tags = const <String>[],
    String interactionType = '',
  }) {
    if (residentId.isEmpty || sourceType.isEmpty || sourceId.isEmpty) {
      return null;
    }
    if (interactionType.isNotEmpty &&
        _worldSaveManager.isSocialCooldownActive(
          residentId,
          interactionType,
        )) {
      return null;
    }
    final adjusted = _socialAdjustedDeltas(
      residentId: residentId,
      reason: reason,
      tags: tags,
      scoreDelta: scoreDelta,
      trustDelta: trustDelta,
      familiarityDelta: familiarityDelta,
    );
    final relationship = getPlayerRelationshipWithResident(residentId);
    final record = _worldSaveManager.recordFriendshipChange(
      residentId: residentId,
      sourceType: sourceType,
      sourceId: sourceId,
      scoreDelta: adjusted.scoreDelta,
      trustDelta: adjusted.trustDelta,
      familiarityDelta: adjusted.familiarityDelta,
      reason: reason,
      tags: <String>{
        ...tags,
        if (interactionType.isNotEmpty) 'interaction:$interactionType',
        _reasonTag(reason),
      }.where((tag) => tag.isNotEmpty).toList(growable: false),
      relationship: relationship,
    );
    if (record == null) return null;
    if (interactionType.isNotEmpty) {
      _worldSaveManager.setSocialCooldown(
        residentId: residentId,
        interactionType: interactionType,
        durationDays: _cooldownDaysFor(interactionType),
        relationship: relationship,
      );
    }
    notifyListeners();
    return record;
  }

  List<SocialInteractionOption> getAvailableInteractions(String residentId) {
    final friendship = _worldSaveManager.getFriendshipState(residentId);
    final state = _residentRuntimeManager.getResidentCurrentState(residentId);
    final location = _residentRuntimeManager.getResidentLocationContext(
      residentId,
    );
    final stageRank = friendshipStageRank(friendship.stage);
    final mood = state.mood;
    final options = <SocialInteractionOption>[
      _interactionOption(
        residentId,
        id: 'talk',
        label: '聊两句',
        available: true,
        reason: '日常短交流。',
        baseWeight: 8,
        tags: const <String>['daily', 'communication'],
      ),
      _interactionOption(
        residentId,
        id: 'short_talk',
        label: '简单问候',
        available: true,
        reason: '不打扰对方的问候。',
        baseWeight: 7,
        tags: const <String>['daily'],
      ),
      _interactionOption(
        residentId,
        id: 'invite_coffee',
        label: '请喝咖啡',
        available: stageRank >= friendshipStageRank('acquaintance') &&
            location.tags.contains('break'),
        reason: '熟悉之后，茶水间和咖啡店更适合慢慢聊。',
        baseWeight: 5,
        tags: const <String>['coffee', 'topic:coffee'],
      ),
      _interactionOption(
        residentId,
        id: 'help_work',
        label: '帮个小忙',
        available:
            location.tags.contains('work') || state.activity.contains('work'),
        reason: '工作场景适合自然协作。',
        baseWeight: 6,
        tags: const <String>['work', 'help'],
      ),
      _interactionOption(
        residentId,
        id: 'join_break',
        label: '一起休息',
        available: state.activity.contains('break') ||
            location.locationId == 'pantry' ||
            location.locationId == 'balcony',
        reason: '休息时更适合轻松相处。',
        baseWeight: 6,
        tags: const <String>['break', 'companionship'],
      ),
      _interactionOption(
        residentId,
        id: 'comfort',
        label: '安慰一下',
        available: mood == 'sad' || mood == 'worried' || mood == 'lonely',
        reason: '情绪低落时，陪伴比建议更重要。',
        baseWeight: 5,
        tags: const <String>['comfort'],
      ),
      _interactionOption(
        residentId,
        id: 'share_rumor',
        label: '聊传闻',
        available: _rumorRuntimeManager.getRumorTags().isNotEmpty &&
            stageRank >= friendshipStageRank('familiar'),
        reason: '更熟之后才会交换一点传闻。',
        baseWeight: 4,
        tags: const <String>['rumor', 'topic:rumor'],
      ),
      _interactionOption(
        residentId,
        id: 'share_fish',
        label: '分享鱼获',
        available: stageRank >= friendshipStageRank('acquaintance'),
        reason: '把钓鱼变成共同话题。',
        baseWeight: 4,
        tags: const <String>['fish', 'topic:fishing'],
      ),
      _interactionOption(
        residentId,
        id: 'resolve_conflict',
        label: '化解误会',
        available: friendship.hasRecentConflict,
        reason: '冲突可以慢慢修复。',
        baseWeight: 7,
        tags: const <String>['resolve_conflict'],
      ),
      _interactionOption(
        residentId,
        id: 'start_story',
        label: '听故事',
        available: stageRank >= friendshipStageRank('familiar') &&
            _storyRuntimeManager.getAvailableStories(residentId).isNotEmpty,
        reason: '足够熟悉之后，故事会自然发生。',
        baseWeight: 5,
        tags: const <String>['story'],
      ),
    ];
    return options.where((option) => option.available).toList(growable: false)
      ..sort((a, b) => b.weight.compareTo(a.weight));
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
    final score = (current.score + _skillAdjustedAmount(reason, amount))
        .clamp(-20, 100)
        .toInt();
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

  bool applyOfficeGroupInteraction(
    String groupId, {
    String sourceType = 'office_group',
  }) {
    if (groupId.isEmpty) return false;
    final group = getActiveOfficeGroups().firstWhere(
      (item) => item.groupId == groupId,
      orElse: () => const OfficeGroup(
        groupId: '',
        locationId: '',
        members: <String>[],
        leaderId: '',
        topic: '',
        mood: 'calm',
        activity: '',
        startTime: '',
        expectedEndTime: '',
        createdReason: '',
        importance: 0,
        tags: <String>[],
      ),
    );
    if (!group.isValid) return false;
    var changed = false;
    final tags = <String>{
      'office_group',
      'group:${group.activity}',
      'topic:${group.topic}',
      'location:${group.locationId}',
      ...group.tags,
    }.toList(growable: false);
    for (final member in group.members) {
      final record = applyFriendshipChange(
        residentId: member,
        sourceType: sourceType,
        sourceId: '${group.groupId}_$member',
        scoreDelta: _groupFriendshipDelta(group),
        trustDelta: _groupTrustDelta(group),
        familiarityDelta: 2,
        reason: '办公室群体活动让彼此更熟悉。',
        tags: tags,
        interactionType: group.activity,
      );
      changed = changed || record != null;
    }
    for (var i = 0; i < group.members.length - 1; i += 1) {
      applyRelationshipChange(
        group.members[i],
        group.members[i + 1],
        '办公室群体活动带来轻微关系变化。',
        group.importance >= 4 ? 2 : 1,
      );
    }
    final skills = <String, int>{
      'communication': 4,
      'observation': 2,
      if (_isMeetingActivity(group.activity)) 'management': 3,
    };
    final skillGain = _worldSaveManager.recordSkillExperienceBatch(
      sourceType: sourceType,
      sourceId: group.groupId,
      skills: skills,
      reason: '参与办公室群体活动。',
    );
    changed = changed || skillGain.isNotEmpty;
    if (changed) {
      _worldSaveManager.recordOfficeGroup(group);
      _worldSaveManager.setDailySocialSummary(_buildDailySocialSummary(
        _today(),
      ));
      _persistState();
      notifyListeners();
    }
    return changed;
  }

  int _skillAdjustedAmount(String reason, int amount) {
    if (amount <= 0) return amount;
    final skill = _relationshipSkillFor(reason);
    if (skill.isEmpty) return amount;
    final level = _secondWorldEngine?.getSkillState(skill).level ?? 1;
    final bonus = ((level - 1) / 3).floor().clamp(0, 2).toInt();
    return amount + bonus;
  }

  String _relationshipSkillFor(String reason) {
    if (reason.contains('帮助') ||
        reason.contains('互动') ||
        reason.contains('共同') ||
        reason.contains('relationship')) {
      return 'communication';
    }
    if (reason.contains('团队') || reason.contains('管理')) {
      return 'management';
    }
    if (reason.contains('观察') || reason.contains('传闻')) {
      return 'observation';
    }
    return '';
  }

  _SocialDelta _socialAdjustedDeltas({
    required String residentId,
    required String reason,
    required List<String> tags,
    required int scoreDelta,
    required int trustDelta,
    required int familiarityDelta,
  }) {
    var nextScore = scoreDelta.clamp(-10, 10).toInt();
    var nextTrust = trustDelta.clamp(-10, 10).toInt();
    var nextFamiliarity = familiarityDelta.clamp(-10, 10).toInt();
    final personality = _residentRuntimeManager.getResidentPersonalityContext(
      residentId,
    );
    final state = _residentRuntimeManager.getResidentCurrentState(residentId);
    if (nextScore > 0) {
      final communication =
          _secondWorldEngine?.getSkillState('communication').level ?? 1;
      final observation =
          _secondWorldEngine?.getSkillState('observation').level ?? 1;
      final management =
          _secondWorldEngine?.getSkillState('management').level ?? 1;
      if (communication >= 4 && tags.contains('communication')) nextScore += 1;
      if (observation >= 4 &&
          (tags.contains('comfort') || tags.contains('rumor'))) {
        nextFamiliarity += 1;
      }
      if (management >= 4 && tags.contains('work')) nextTrust += 1;
    }
    if (personality.hasTrait('kind') && tags.contains('help')) {
      nextScore += 1;
    }
    if (personality.hasTrait('cautious') && nextTrust > 0) {
      nextTrust -= 1;
    }
    if (personality.hasTrait('introverted')) {
      nextFamiliarity =
          nextFamiliarity <= 0 ? nextFamiliarity : nextFamiliarity + 1;
    }
    if (state.mood == 'happy' || state.mood == 'grateful') {
      nextScore += nextScore > 0 ? 1 : 0;
    }
    if (state.mood == 'angry' && tags.contains('daily')) {
      nextScore =
          nextScore > 0 ? (nextScore - 1).clamp(0, 10).toInt() : nextScore;
    }
    return _SocialDelta(
      scoreDelta: nextScore.clamp(-10, 10).toInt(),
      trustDelta: nextTrust.clamp(-10, 10).toInt(),
      familiarityDelta: nextFamiliarity.clamp(-10, 10).toInt(),
    );
  }

  SocialInteractionOption _interactionOption(
    String residentId, {
    required String id,
    required String label,
    required bool available,
    required String reason,
    required int baseWeight,
    required List<String> tags,
  }) {
    final cooldownActive = _worldSaveManager.isSocialCooldownActive(
      residentId,
      id,
    );
    final state = getFriendshipState(residentId);
    return SocialInteractionOption(
      id: id,
      label: label,
      available: available && !cooldownActive,
      reason: cooldownActive ? '互动还在冷却中，慢一点。' : reason,
      weight: _interactionWeight(id, baseWeight, residentId),
      cooldownUntilDay: state.cooldowns[id] ?? 0,
      tags: tags,
    );
  }

  int _interactionWeight(String id, int baseWeight, String residentId) {
    final personality = _residentRuntimeManager.getResidentPersonalityContext(
      residentId,
    );
    final state = _residentRuntimeManager.getResidentCurrentState(residentId);
    var weight = baseWeight;
    if (personality.hasTrait('outgoing')) weight += 2;
    if (personality.hasTrait('introverted')) weight -= 1;
    if (personality.hasTrait('serious') && id == 'help_work') weight += 2;
    if (personality.hasTrait('playful') && id == 'talk') weight += 2;
    if (state.mood == 'happy') weight += 1;
    if (state.mood == 'sad' && id == 'comfort') weight += 3;
    if (state.mood == 'angry' && id == 'talk') weight -= 2;
    return weight.clamp(1, 20).toInt();
  }

  int _cooldownDaysFor(String interactionType) {
    switch (interactionType) {
      case 'talk':
      case 'short_talk':
        return 0;
      case 'invite_coffee':
      case 'help_work':
      case 'join_break':
      case 'share_rumor':
        return 1;
      case 'comfort':
      case 'share_fish':
      case 'resolve_conflict':
        return 2;
      default:
        return 1;
    }
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
    delta += _personalityDelta(a, b);
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

  bool _isGroupableState(String locationId, String activity) {
    final normalized = _normalizeGroupLocation(locationId);
    if (normalized.isEmpty || normalized == 'home') return false;
    if (activity == 'sleep' || activity == 'home') return false;
    const allowed = <String>{
      'pantry',
      'coffee_shop',
      'meeting_room',
      'balcony',
      'office',
      'dock',
      'sea',
      'seaside',
      'workstation',
      'restaurant',
      'park',
    };
    return allowed.contains(normalized);
  }

  String _normalizeGroupLocation(String locationId) {
    switch (locationId) {
      case 'coffee':
      case 'cafe':
        return 'coffee_shop';
      case 'meeting':
        return 'meeting_room';
      case 'desk':
      case 'work_area':
        return 'workstation';
      default:
        return locationId;
    }
  }

  int _groupCandidateScore(String residentId) {
    final state = _residentRuntimeManager.getResidentCurrentState(residentId);
    final personality =
        _residentRuntimeManager.getResidentPersonalityContext(residentId);
    final friendship = getFriendshipState(residentId);
    var score = 10 + friendship.familiarity ~/ 12 + friendship.trust ~/ 18;
    if (personality.hasTrait('outgoing')) score += 5;
    if (personality.hasTrait('kind')) score += 3;
    if (personality.hasTrait('introverted')) score -= 2;
    if (state.mood == 'happy' || state.mood == 'excited') score += 3;
    if (state.mood == 'tired' || state.mood == 'busy') score -= 1;
    if (state.activity.contains('break') || state.activity.contains('lunch')) {
      score += 4;
    }
    final communication =
        _secondWorldEngine?.getSkillState('communication').level ?? 1;
    final management =
        _secondWorldEngine?.getSkillState('management').level ?? 1;
    score += (communication / 4).floor();
    if (state.location == 'meeting_room') score += (management / 3).floor();
    return score.clamp(1, 40).toInt();
  }

  String _groupActivityFor(String locationId, List<String> members) {
    final hourActivity =
        _residentRuntimeManager.getResidentCurrentState(members.first).activity;
    final festival =
        _dailySimulationManager.getTodayWorldSummary()?.festival ?? '';
    if (festival.isNotEmpty) return 'festival_gathering';
    if (locationId == 'meeting_room') return 'meeting';
    if (locationId == 'pantry' || locationId == 'coffee_shop') {
      return hourActivity.contains('lunch') ? 'lunch' : 'coffee_break';
    }
    if (locationId == 'dock' ||
        locationId == 'sea' ||
        locationId == 'seaside') {
      return 'weekend_fishing';
    }
    if (_rumorRuntimeManager.getRumorTags().isNotEmpty) {
      return 'rumor_discussion';
    }
    if (hourActivity.contains('review')) return 'project_review';
    return 'office_chat';
  }

  String _groupTopicFor(String locationId, String activity) {
    if (activity == 'festival_gathering') return 'festival';
    if (activity == 'rumor_discussion') return 'rumor';
    if (activity == 'meeting' || activity == 'project_review') {
      return 'project_review';
    }
    if (activity == 'weekend_fishing') return 'fishing';
    if (activity == 'lunch') return 'lunch';
    if (locationId == 'coffee_shop' || locationId == 'pantry') return 'coffee';
    return 'office_life';
  }

  String _groupMoodFor(List<String> members) {
    final counts = <String, int>{};
    for (final member in members) {
      final mood = _residentRuntimeManager.getResidentCurrentState(member).mood;
      counts[mood] = (counts[mood] ?? 0) + 1;
    }
    final sorted = counts.entries.toList(growable: false)
      ..sort((a, b) {
        final count = b.value.compareTo(a.value);
        if (count != 0) return count;
        return a.key.compareTo(b.key);
      });
    return sorted.isEmpty ? 'calm' : sorted.first.key;
  }

  int _groupImportance(List<String> members, String activity) {
    var importance = members.length >= 4 ? 3 : 2;
    if (_isMeetingActivity(activity)) importance += 1;
    if (activity == 'festival_gathering') importance += 2;
    return importance.clamp(1, 5).toInt();
  }

  List<String> _groupTags(
    String locationId,
    String activity,
    String topic,
    String mood,
  ) {
    return <String>{
      'office_group',
      activity,
      'topic:$topic',
      'location:$locationId',
      'mood:$mood',
      if (_isMeetingActivity(activity)) 'management',
      if (activity == 'coffee_break') 'coffee',
      if (activity == 'rumor_discussion') 'rumor',
      if (activity == 'weekend_fishing') 'fish',
    }.where((item) => item.isNotEmpty).toList(growable: false);
  }

  String _groupId({
    required String locationId,
    required List<String> members,
    required String activity,
  }) {
    final prefix = members.take(3).join('_');
    return 'office_group_${_today()}_${_timeLabel()}_${locationId}_${activity}_$prefix'
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]+'), '_');
  }

  String _timeLabel({int offsetMinutes = 0}) {
    final minute = offsetMinutes.clamp(0, 1439).toInt();
    final hourLabel = (minute ~/ 60).toString().padLeft(2, '0');
    final minuteLabel = (minute % 60).toString().padLeft(2, '0');
    return '${_today()}:$hourLabel:$minuteLabel';
  }

  bool _isMeetingActivity(String activity) {
    return activity == 'meeting' ||
        activity == 'project_review' ||
        activity == 'emergency_meeting';
  }

  int _groupFriendshipDelta(OfficeGroup group) {
    if (group.activity == 'meeting' || group.activity == 'project_review') {
      return 1;
    }
    if (group.activity == 'birthday' || group.activity == 'celebration') {
      return 3;
    }
    return 2;
  }

  int _groupTrustDelta(OfficeGroup group) {
    if (_isMeetingActivity(group.activity)) return 2;
    if (group.activity == 'festival_gathering') return 1;
    return 0;
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
    final personalityReason = _personalityReason(a, b);
    if (personalityReason.isNotEmpty) return personalityReason;
    if (delta < 0) return '长时间未见，关系稍微变淡。';
    return '第二世界的日常让关系自然变化。';
  }

  int _personalityDelta(String a, String b) {
    final aContext = _residentRuntimeManager.getResidentPersonalityContext(a);
    final bContext = _residentRuntimeManager.getResidentPersonalityContext(b);
    final shared =
        aContext.traits.toSet().intersection(bContext.traits.toSet());
    if (shared.isNotEmpty) return 1;
    if (aContext.hasTrait('kind') || bContext.hasTrait('kind')) return 1;
    if (aContext.socialPreference == bContext.socialPreference) return 1;
    if (aContext.hasTrait('competitive') && bContext.hasTrait('competitive')) {
      return 0;
    }
    return 0;
  }

  String _personalityReason(String a, String b) {
    final aContext = _residentRuntimeManager.getResidentPersonalityContext(a);
    final bContext = _residentRuntimeManager.getResidentPersonalityContext(b);
    final shared =
        aContext.traits.toSet().intersection(bContext.traits.toSet());
    if (shared.isNotEmpty) return 'personality_affinity';
    if (aContext.hasTrait('kind') || bContext.hasTrait('kind')) {
      return 'shared_interest';
    }
    if (aContext.socialPreference == bContext.socialPreference) {
      return 'interaction_style_match';
    }
    return '';
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
    if (reason.contains('personality_affinity')) return 'personality_affinity';
    if (reason.contains('personality_difference')) {
      return 'personality_difference';
    }
    if (reason.contains('shared_interest')) return 'shared_interest';
    if (reason.contains('interaction_style_match')) {
      return 'interaction_style_match';
    }
    if (reason.contains('interaction_style_conflict')) {
      return 'interaction_style_conflict';
    }
    if (reason.contains('和解')) return 'reconcile';
    if (reason.contains('误会')) return 'misunderstanding';
    return 'daily';
  }

  Map<String, dynamic> _buildDailySocialSummary(int day) {
    final states = getAllFriendshipStates();
    final stageChanges = _worldSaveManager.socialInteractionHistory
        .where((record) => record.timestamp.isNotEmpty)
        .take(20)
        .map((record) => {
              'residentId': record.residentId,
              'sourceType': record.sourceType,
              'sourceId': record.sourceId,
              'scoreDelta': record.scoreDelta,
              'trustDelta': record.trustDelta,
              'familiarityDelta': record.familiarityDelta,
              'reason': record.reason,
            })
        .toList(growable: false);
    return {
      'day': day,
      'newFriends': states
          .where((state) => state.stage == 'friend')
          .map((state) => state.residentId)
          .toList(growable: false),
      'friendshipStageChanges': stageChanges,
      'importantInteractions': _worldSaveManager.socialInteractionHistory
          .where((record) => record.trustDelta.abs() >= 2)
          .take(10)
          .map((record) => record.toJson())
          .toList(growable: false),
      'resolvedConflicts': states
          .where((state) => state.conflictState == 'recovering')
          .map((state) => state.residentId)
          .toList(growable: false),
      'sharedStories': _storyRuntimeManager.finishedStoryIds.take(10).toList(),
      'todayOfficeEvents': _worldSaveManager.activeGroups
          .map((group) => group.activity)
          .toSet()
          .toList(growable: false),
      'todaysGroups': _worldSaveManager.activeGroups
          .map((group) => group.toJson())
          .toList(growable: false),
      'todaysConversations': _worldSaveManager.activeGroups
          .map((group) => group.topic)
          .toSet()
          .toList(growable: false),
      'todaysGatherings': _worldSaveManager.activeGroups
          .where((group) => group.size >= 3)
          .map((group) => group.groupId)
          .toList(growable: false),
      'socialSkillExperience':
          _secondWorldEngine?.getSkillState('communication').experience ?? 0,
      'residentsNotSeenRecently': states
          .where((state) => state.interactionCount == 0)
          .map((state) => state.residentId)
          .take(20)
          .toList(growable: false),
    };
  }

  void _persistState() {
    _worldSaveManager.setRelationshipRuntimeState({
      'lastUpdateDay': _lastUpdateDay,
      'residentRelationships': residentRelationships
          .map((record) => record.toJson())
          .toList(growable: false),
      'friendshipStateCount': _worldSaveManager.friendshipStates.length,
      'dailySocialSummary': _worldSaveManager.dailySocialSummary,
      'activeOfficeGroupCount': _worldSaveManager.activeGroups.length,
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

class _SocialDelta {
  const _SocialDelta({
    required this.scoreDelta,
    required this.trustDelta,
    required this.familiarityDelta,
  });

  final int scoreDelta;
  final int trustDelta;
  final int familiarityDelta;
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
