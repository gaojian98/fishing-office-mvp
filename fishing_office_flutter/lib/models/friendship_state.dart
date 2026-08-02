const friendshipStages = <String>[
  'stranger',
  'acquaintance',
  'familiar',
  'friend',
  'close_friend',
  'trusted_friend',
];

class FriendshipState {
  const FriendshipState({
    required this.residentId,
    required this.score,
    required this.stage,
    required this.trust,
    required this.familiarity,
    required this.sharedMemories,
    required this.sharedTopics,
    required this.lastInteractionTime,
    required this.lastPositiveInteractionTime,
    required this.lastConflictTime,
    required this.interactionCount,
    required this.positiveInteractionCount,
    required this.negativeInteractionCount,
    required this.recentInteractionIds,
    required this.relationshipTags,
    required this.cooldowns,
    required this.conflictState,
  });

  factory FriendshipState.initial(String residentId) {
    return FriendshipState(
      residentId: residentId,
      score: 5,
      stage: 'stranger',
      trust: 0,
      familiarity: 0,
      sharedMemories: const <String>[],
      sharedTopics: const <String>[],
      lastInteractionTime: '',
      lastPositiveInteractionTime: '',
      lastConflictTime: '',
      interactionCount: 0,
      positiveInteractionCount: 0,
      negativeInteractionCount: 0,
      recentInteractionIds: const <String>[],
      relationshipTags: const <String>['friendship:stranger'],
      cooldowns: const <String, int>{},
      conflictState: 'none',
    );
  }

  factory FriendshipState.fromRelationship({
    required String residentId,
    required int relationshipScore,
    required String relationshipLevel,
    String lastChangedAt = '',
    List<String> tags = const <String>[],
  }) {
    final score =
        relationshipScore <= 0 ? 5 : relationshipScore.clamp(5, 70).toInt();
    final trust = relationshipLevel == 'trust' ? 20 : (score / 4).floor();
    final familiarity = relationshipLevel == 'stranger'
        ? 0
        : (score / 2).floor().clamp(0, 80).toInt();
    return FriendshipState.initial(residentId).copyWith(
      score: score,
      stage: stageFor(score, trust: trust, familiarity: familiarity),
      trust: trust,
      familiarity: familiarity,
      lastInteractionTime: lastChangedAt,
      relationshipTags: <String>{
        ...tags,
        'friendship:${stageFor(score, trust: trust, familiarity: familiarity)}',
        if (relationshipLevel.isNotEmpty) 'legacy:$relationshipLevel',
      }.where((item) => item.isNotEmpty).toList(growable: false),
    );
  }

  factory FriendshipState.fromJson(Map<String, dynamic> json) {
    final score = _readInt(json['score'], fallback: 5).clamp(0, 100).toInt();
    final trust = _readInt(json['trust']).clamp(0, 100).toInt();
    final familiarity = _readInt(json['familiarity']).clamp(0, 100).toInt();
    return FriendshipState(
      residentId: json['residentId']?.toString() ?? '',
      score: score,
      stage: _normalizeStage(
        json['stage']?.toString() ??
            stageFor(score, trust: trust, familiarity: familiarity),
      ),
      trust: trust,
      familiarity: familiarity,
      sharedMemories: _stringList(json['sharedMemories']),
      sharedTopics: _stringList(json['sharedTopics']),
      lastInteractionTime: json['lastInteractionTime']?.toString() ?? '',
      lastPositiveInteractionTime:
          json['lastPositiveInteractionTime']?.toString() ?? '',
      lastConflictTime: json['lastConflictTime']?.toString() ?? '',
      interactionCount: _readInt(json['interactionCount']),
      positiveInteractionCount: _readInt(json['positiveInteractionCount']),
      negativeInteractionCount: _readInt(json['negativeInteractionCount']),
      recentInteractionIds: _stringList(json['recentInteractionIds']),
      relationshipTags: _stringList(json['relationshipTags']),
      cooldowns: _intMap(json['cooldowns']),
      conflictState: _normalizeConflict(json['conflictState']?.toString()),
    ).normalized();
  }

  final String residentId;
  final int score;
  final String stage;
  final int trust;
  final int familiarity;
  final List<String> sharedMemories;
  final List<String> sharedTopics;
  final String lastInteractionTime;
  final String lastPositiveInteractionTime;
  final String lastConflictTime;
  final int interactionCount;
  final int positiveInteractionCount;
  final int negativeInteractionCount;
  final List<String> recentInteractionIds;
  final List<String> relationshipTags;
  final Map<String, int> cooldowns;
  final String conflictState;

  bool get hasRecentConflict =>
      conflictState == 'minor_tension' ||
      conflictState == 'conflict' ||
      conflictState == 'recovering';

  FriendshipState applyChange(FriendshipChangeRecord record) {
    final existingIndex = friendshipStages.indexOf(stage);
    final rawScore = (score + record.scoreDelta).clamp(0, 100).toInt();
    final cappedScore = _limitSingleStageJump(score, rawScore, existingIndex);
    final nextTrust = (trust + record.trustDelta).clamp(0, 100).toInt();
    final nextFamiliarity =
        (familiarity + record.familiarityDelta).clamp(0, 100).toInt();
    final nextStage = stageFor(
      cappedScore,
      trust: nextTrust,
      familiarity: nextFamiliarity,
    );
    final positive = record.scoreDelta > 0 ||
        record.trustDelta > 0 ||
        record.familiarityDelta > 0;
    final negative = record.scoreDelta < 0 ||
        record.trustDelta < 0 ||
        record.familiarityDelta < 0;
    final nextConflict =
        _conflictAfter(record, current: conflictState, positive: positive);
    return copyWith(
      score: cappedScore,
      stage: nextStage,
      trust: nextTrust,
      familiarity: nextFamiliarity,
      sharedMemories: <String>{
        ...sharedMemories,
        ...record.tags.where((tag) => tag.startsWith('memory:')),
      }.toList(growable: false),
      sharedTopics: <String>{
        ...sharedTopics,
        ...record.tags.where((tag) => tag.startsWith('topic:')).map(
              (tag) => tag.substring('topic:'.length),
            ),
      }.toList(growable: false),
      lastInteractionTime: record.timestamp,
      lastPositiveInteractionTime:
          positive ? record.timestamp : lastPositiveInteractionTime,
      lastConflictTime: negative || nextConflict == 'conflict'
          ? record.timestamp
          : lastConflictTime,
      interactionCount: interactionCount + 1,
      positiveInteractionCount:
          positive ? positiveInteractionCount + 1 : positiveInteractionCount,
      negativeInteractionCount:
          negative ? negativeInteractionCount + 1 : negativeInteractionCount,
      recentInteractionIds: _boundedList(
        <String>[record.stableKey, ...recentInteractionIds],
        50,
      ),
      relationshipTags: <String>{
        ...relationshipTags,
        'friendship:$nextStage',
        if (positive) 'positive_interaction',
        if (negative) 'negative_interaction',
        if (nextConflict != 'none') 'conflict:$nextConflict',
        ...record.tags.where((tag) => tag.isNotEmpty),
      }.toList(growable: false),
      conflictState: nextConflict,
    ).normalized();
  }

  FriendshipState withCooldown({
    required String interactionType,
    required int expiresDay,
  }) {
    if (interactionType.isEmpty || expiresDay <= 0) return this;
    return copyWith(
      cooldowns: <String, int>{...cooldowns, interactionType: expiresDay},
    );
  }

  FriendshipState clearExpiredCooldowns(int currentDay) {
    if (currentDay <= 0 || cooldowns.isEmpty) return this;
    final next = <String, int>{...cooldowns}
      ..removeWhere((_, value) => value <= currentDay);
    if (next.length == cooldowns.length) return this;
    return copyWith(cooldowns: next);
  }

  FriendshipState normalized() {
    final normalizedStage = stageFor(
      score,
      trust: trust,
      familiarity: familiarity,
    );
    return copyWith(
      stage: normalizedStage,
      relationshipTags: <String>{
        ...relationshipTags.where((tag) => !tag.startsWith('friendship:')),
        'friendship:$normalizedStage',
      }.where((item) => item.isNotEmpty).toList(growable: false),
      conflictState: _normalizeConflict(conflictState),
      recentInteractionIds: _boundedList(recentInteractionIds, 50),
      cooldowns: Map<String, int>.from(cooldowns),
    );
  }

  FriendshipState copyWith({
    String? residentId,
    int? score,
    String? stage,
    int? trust,
    int? familiarity,
    List<String>? sharedMemories,
    List<String>? sharedTopics,
    String? lastInteractionTime,
    String? lastPositiveInteractionTime,
    String? lastConflictTime,
    int? interactionCount,
    int? positiveInteractionCount,
    int? negativeInteractionCount,
    List<String>? recentInteractionIds,
    List<String>? relationshipTags,
    Map<String, int>? cooldowns,
    String? conflictState,
  }) {
    return FriendshipState(
      residentId: residentId ?? this.residentId,
      score: (score ?? this.score).clamp(0, 100).toInt(),
      stage: _normalizeStage(stage ?? this.stage),
      trust: (trust ?? this.trust).clamp(0, 100).toInt(),
      familiarity: (familiarity ?? this.familiarity).clamp(0, 100).toInt(),
      sharedMemories: sharedMemories ?? this.sharedMemories,
      sharedTopics: sharedTopics ?? this.sharedTopics,
      lastInteractionTime: lastInteractionTime ?? this.lastInteractionTime,
      lastPositiveInteractionTime:
          lastPositiveInteractionTime ?? this.lastPositiveInteractionTime,
      lastConflictTime: lastConflictTime ?? this.lastConflictTime,
      interactionCount: interactionCount ?? this.interactionCount,
      positiveInteractionCount:
          positiveInteractionCount ?? this.positiveInteractionCount,
      negativeInteractionCount:
          negativeInteractionCount ?? this.negativeInteractionCount,
      recentInteractionIds: recentInteractionIds ?? this.recentInteractionIds,
      relationshipTags: relationshipTags ?? this.relationshipTags,
      cooldowns: cooldowns ?? this.cooldowns,
      conflictState: conflictState ?? this.conflictState,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'residentId': residentId,
      'score': score,
      'stage': stage,
      'trust': trust,
      'familiarity': familiarity,
      'sharedMemories': sharedMemories,
      'sharedTopics': sharedTopics,
      'lastInteractionTime': lastInteractionTime,
      'lastPositiveInteractionTime': lastPositiveInteractionTime,
      'lastConflictTime': lastConflictTime,
      'interactionCount': interactionCount,
      'positiveInteractionCount': positiveInteractionCount,
      'negativeInteractionCount': negativeInteractionCount,
      'recentInteractionIds': recentInteractionIds,
      'relationshipTags': relationshipTags,
      'cooldowns': cooldowns,
      'conflictState': conflictState,
    };
  }
}

class FriendshipChangeRecord {
  const FriendshipChangeRecord({
    required this.sourceType,
    required this.sourceId,
    required this.residentId,
    required this.scoreDelta,
    required this.trustDelta,
    required this.familiarityDelta,
    required this.reason,
    required this.timestamp,
    required this.tags,
  });

  factory FriendshipChangeRecord.fromJson(Map<String, dynamic> json) {
    return FriendshipChangeRecord(
      sourceType: json['sourceType']?.toString() ?? '',
      sourceId: json['sourceId']?.toString() ?? '',
      residentId: json['residentId']?.toString() ?? '',
      scoreDelta: _readInt(json['scoreDelta']),
      trustDelta: _readInt(json['trustDelta']),
      familiarityDelta: _readInt(json['familiarityDelta']),
      reason: json['reason']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      tags: _stringList(json['tags']),
    );
  }

  final String sourceType;
  final String sourceId;
  final String residentId;
  final int scoreDelta;
  final int trustDelta;
  final int familiarityDelta;
  final String reason;
  final String timestamp;
  final List<String> tags;

  String get stableKey => friendshipSourceKey(
        sourceType: sourceType,
        sourceId: sourceId,
        residentId: residentId,
      );

  Map<String, dynamic> toJson() {
    return {
      'sourceType': sourceType,
      'sourceId': sourceId,
      'residentId': residentId,
      'scoreDelta': scoreDelta,
      'trustDelta': trustDelta,
      'familiarityDelta': familiarityDelta,
      'reason': reason,
      'timestamp': timestamp,
      'tags': tags,
    };
  }
}

class SocialInteractionOption {
  const SocialInteractionOption({
    required this.id,
    required this.label,
    required this.available,
    required this.reason,
    required this.weight,
    required this.cooldownUntilDay,
    required this.tags,
  });

  final String id;
  final String label;
  final bool available;
  final String reason;
  final int weight;
  final int cooldownUntilDay;
  final List<String> tags;
}

String friendshipSourceKey({
  required String sourceType,
  required String sourceId,
  required String residentId,
}) {
  return '$sourceType::$sourceId::$residentId';
}

String stageFor(int score, {int trust = 0, int familiarity = 0}) {
  if (score >= 85 && trust >= 40 && familiarity >= 60) {
    return 'trusted_friend';
  }
  if (score >= 65 && trust >= 24 && familiarity >= 45) {
    return 'close_friend';
  }
  if (score >= 45 && familiarity >= 25) return 'friend';
  if (score >= 25) return 'familiar';
  if (score >= 10) return 'acquaintance';
  return 'stranger';
}

int friendshipStageRank(String stage) {
  final index = friendshipStages.indexOf(_normalizeStage(stage));
  return index < 0 ? 0 : index;
}

String _normalizeStage(String value) {
  if (friendshipStages.contains(value)) return value;
  switch (value) {
    case 'known':
      return 'acquaintance';
    case 'old_friend':
      return 'close_friend';
    case 'trust':
      return 'trusted_friend';
    default:
      return 'stranger';
  }
}

String _normalizeConflict(String? value) {
  switch (value) {
    case 'minor_tension':
    case 'conflict':
    case 'recovering':
      return value!;
    default:
      return 'none';
  }
}

String _conflictAfter(
  FriendshipChangeRecord record, {
  required String current,
  required bool positive,
}) {
  if (record.tags.contains('resolve_conflict') ||
      record.sourceType == 'resolve_conflict') {
    return 'recovering';
  }
  if (record.tags.contains('apologize') || record.sourceType == 'apologize') {
    return current == 'conflict' ? 'recovering' : 'none';
  }
  if (record.scoreDelta <= -4 || record.tags.contains('conflict')) {
    return 'conflict';
  }
  if (record.scoreDelta < 0 || record.tags.contains('minor_tension')) {
    return current == 'conflict' ? 'conflict' : 'minor_tension';
  }
  if (positive && current == 'recovering') return 'none';
  return current;
}

int _limitSingleStageJump(int oldScore, int rawScore, int oldStageIndex) {
  if (rawScore <= oldScore) return rawScore;
  final nextStageIndex =
      (oldStageIndex + 1).clamp(0, friendshipStages.length - 1);
  final maxStage = friendshipStages[nextStageIndex];
  final maxScore = _stageMaxScore(maxStage);
  return rawScore.clamp(0, maxScore).toInt();
}

int _stageMaxScore(String stage) {
  switch (stage) {
    case 'stranger':
      return 9;
    case 'acquaintance':
      return 24;
    case 'familiar':
      return 44;
    case 'friend':
      return 64;
    case 'close_friend':
      return 84;
    default:
      return 100;
  }
}

List<String> _boundedList(List<String> values, int limit) {
  final result = <String>[];
  for (final value in values) {
    if (value.isEmpty || result.contains(value)) continue;
    result.add(value);
    if (result.length >= limit) break;
  }
  return result;
}

Map<String, int> _intMap(Object? value) {
  if (value is! Map) return const <String, int>{};
  return value.map((key, item) => MapEntry(key.toString(), _readInt(item)));
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return value
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

int _readInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
