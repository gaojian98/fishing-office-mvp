import 'career_state.dart';
import 'friendship_state.dart';

class RecentPlayerAction {
  const RecentPlayerAction({
    required this.id,
    required this.type,
    required this.sourceId,
    required this.description,
    required this.createdAt,
    required this.day,
    required this.weight,
    required this.tags,
  });

  factory RecentPlayerAction.fromJson(Map<String, dynamic> json) {
    return RecentPlayerAction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      sourceId: json['sourceId']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      day: _readInt(json['day']),
      weight: _readInt(json['weight'], fallback: 1).clamp(0, 100).toInt(),
      tags: _stringList(json['tags']),
    );
  }

  final String id;
  final String type;
  final String sourceId;
  final String description;
  final String createdAt;
  final int day;
  final int weight;
  final List<String> tags;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'sourceId': sourceId,
      'description': description,
      'createdAt': createdAt,
      'day': day,
      'weight': weight,
      'tags': tags,
    };
  }
}

class PlayerOfficeInfluence {
  const PlayerOfficeInfluence({
    required this.friendshipInfluence,
    required this.careerInfluence,
    required this.socialInfluence,
    required this.rumorInfluence,
    required this.eventInfluence,
    required this.storyInfluence,
    required this.officeTrust,
    required this.officePopularity,
    required this.officeVisibility,
    required this.livingOfficeContribution,
  });

  factory PlayerOfficeInfluence.empty() {
    return const PlayerOfficeInfluence(
      friendshipInfluence: 0,
      careerInfluence: 0,
      socialInfluence: 0,
      rumorInfluence: 0,
      eventInfluence: 0,
      storyInfluence: 0,
      officeTrust: 0,
      officePopularity: 0,
      officeVisibility: 0,
      livingOfficeContribution: 0,
    );
  }

  factory PlayerOfficeInfluence.fromJson(Map<String, dynamic> json) {
    return PlayerOfficeInfluence(
      friendshipInfluence: _readBounded(json['friendshipInfluence']),
      careerInfluence: _readBounded(json['careerInfluence']),
      socialInfluence: _readBounded(json['socialInfluence']),
      rumorInfluence: _readBounded(json['rumorInfluence']),
      eventInfluence: _readBounded(json['eventInfluence']),
      storyInfluence: _readBounded(json['storyInfluence']),
      officeTrust: _readBounded(json['officeTrust']),
      officePopularity: _readBounded(json['officePopularity']),
      officeVisibility: _readBounded(json['officeVisibility']),
      livingOfficeContribution: _readBounded(json['livingOfficeContribution']),
    );
  }

  final int friendshipInfluence;
  final int careerInfluence;
  final int socialInfluence;
  final int rumorInfluence;
  final int eventInfluence;
  final int storyInfluence;
  final int officeTrust;
  final int officePopularity;
  final int officeVisibility;
  final int livingOfficeContribution;

  int get overall {
    return ((friendshipInfluence +
                careerInfluence +
                socialInfluence +
                rumorInfluence +
                eventInfluence +
                storyInfluence +
                officeTrust +
                officePopularity +
                officeVisibility +
                livingOfficeContribution) /
            10)
        .round()
        .clamp(0, 100)
        .toInt();
  }

  Map<String, dynamic> toJson() {
    return {
      'friendshipInfluence': friendshipInfluence,
      'careerInfluence': careerInfluence,
      'socialInfluence': socialInfluence,
      'rumorInfluence': rumorInfluence,
      'eventInfluence': eventInfluence,
      'storyInfluence': storyInfluence,
      'officeTrust': officeTrust,
      'officePopularity': officePopularity,
      'officeVisibility': officeVisibility,
      'livingOfficeContribution': livingOfficeContribution,
    };
  }
}

class PlayerInfluenceContext {
  const PlayerInfluenceContext({
    required this.playerLevel,
    required this.playerCareer,
    required this.playerSkills,
    required this.playerLocation,
    required this.friendCount,
    required this.reputation,
    required this.officeInfluence,
    required this.recentActions,
    required this.recentEvents,
    required this.recentChoices,
    required this.recentAchievements,
    required this.recentQuestResults,
    required this.inventorySummary,
    required this.fishCollectionSummary,
    required this.officeTags,
  });

  factory PlayerInfluenceContext.empty() {
    return PlayerInfluenceContext(
      playerLevel: 1,
      playerCareer: '',
      playerSkills: const <String, int>{},
      playerLocation: 'office',
      friendCount: 0,
      reputation: const <String>['quiet'],
      officeInfluence: PlayerOfficeInfluence.empty(),
      recentActions: const <RecentPlayerAction>[],
      recentEvents: const <String>[],
      recentChoices: const <String>[],
      recentAchievements: const <String>[],
      recentQuestResults: const <String>[],
      inventorySummary: const <String, int>{},
      fishCollectionSummary: const <String, int>{},
      officeTags: const <String>[],
    );
  }

  factory PlayerInfluenceContext.fromJson(Map<String, dynamic> json) {
    return PlayerInfluenceContext(
      playerLevel: _readInt(json['playerLevel'], fallback: 1),
      playerCareer: json['playerCareer']?.toString() ?? '',
      playerSkills: _intMap(json['playerSkills']),
      playerLocation: json['playerLocation']?.toString() ?? 'office',
      friendCount: _readInt(json['friendCount']),
      reputation: _stringList(json['reputation']),
      officeInfluence: json['officeInfluence'] is Map
          ? PlayerOfficeInfluence.fromJson(
              Map<String, dynamic>.from(json['officeInfluence'] as Map),
            )
          : PlayerOfficeInfluence.empty(),
      recentActions: _listOfMaps(json['recentActions'])
          .map(RecentPlayerAction.fromJson)
          .toList(growable: false),
      recentEvents: _stringList(json['recentEvents']),
      recentChoices: _stringList(json['recentChoices']),
      recentAchievements: _stringList(json['recentAchievements']),
      recentQuestResults: _stringList(json['recentQuestResults']),
      inventorySummary: _intMap(json['inventorySummary']),
      fishCollectionSummary: _intMap(json['fishCollectionSummary']),
      officeTags: _stringList(json['officeTags']),
    );
  }

  factory PlayerInfluenceContext.fromRuntime({
    required CareerState careerState,
    required Map<String, PlayerSkillState> skills,
    required Map<String, FriendshipState> friendships,
    required List<RecentPlayerAction> recentActions,
    required List<String> recentEvents,
    required List<String> recentAchievements,
    required List<String> recentQuestResults,
    required List<String> officeTags,
    required int activityLevel,
    required int socialLevel,
    required int productivityLevel,
    required int tensionLevel,
    String playerLocation = 'office',
    Map<String, int> inventorySummary = const <String, int>{},
    Map<String, int> fishCollectionSummary = const <String, int>{},
  }) {
    final friendCount = friendships.values
        .where((item) =>
            _friendshipRank(item.stage) >= _friendshipRank('familiar'))
        .length;
    final trustedCount = friendships.values
        .where((item) =>
            _friendshipRank(item.stage) >= _friendshipRank('trusted_friend'))
        .length;
    final recentTypes = recentActions.map((item) => item.type).toSet();
    final communication = skills['communication']?.level ?? 1;
    final management = skills['management']?.level ?? 1;
    final observation = skills['observation']?.level ?? 1;
    final friendshipInfluence = _bounded(friendCount * 8 + trustedCount * 6);
    final careerInfluence = _bounded(
        careerState.levelIndex * 14 + careerState.performanceScore ~/ 3);
    final socialInfluence = _bounded(
        friendshipInfluence ~/ 2 + communication * 6 + socialLevel ~/ 3);
    final rumorInfluence = _bounded(
      recentEvents.where((item) => item.contains('rumor')).length * 10 +
          observation * 5,
    );
    final eventInfluence =
        _bounded(recentEvents.length * 4 + recentActions.length * 2);
    final storyInfluence = _bounded(
        recentEvents.where((item) => item.contains('story')).length * 12);
    final officeTrust =
        _bounded(trustedCount * 10 + careerState.performanceScore ~/ 2);
    final officePopularity =
        _bounded(friendCount * 7 + socialLevel ~/ 2 + communication * 4);
    final officeVisibility =
        _bounded(activityLevel ~/ 2 + eventInfluence ~/ 2 + management * 4);
    final livingOfficeContribution = _bounded(
      productivityLevel ~/ 3 +
          socialLevel ~/ 3 +
          friendshipInfluence ~/ 3 -
          tensionLevel ~/ 5,
    );
    final influence = PlayerOfficeInfluence(
      friendshipInfluence: friendshipInfluence,
      careerInfluence: careerInfluence,
      socialInfluence: socialInfluence,
      rumorInfluence: rumorInfluence,
      eventInfluence: eventInfluence,
      storyInfluence: storyInfluence,
      officeTrust: officeTrust,
      officePopularity: officePopularity,
      officeVisibility: officeVisibility,
      livingOfficeContribution: livingOfficeContribution,
    );
    final reputation = _reputationFor(
      careerState: careerState,
      skills: skills,
      friendCount: friendCount,
      trustedCount: trustedCount,
      recentTypes: recentTypes,
      influence: influence,
    );
    return PlayerInfluenceContext(
      playerLevel: careerState.levelIndex + 1,
      playerCareer: careerState.careerLevel,
      playerSkills: skills.map((key, value) => MapEntry(key, value.level)),
      playerLocation: playerLocation,
      friendCount: friendCount,
      reputation: reputation,
      officeInfluence: influence,
      recentActions: recentActions,
      recentEvents: recentEvents,
      recentChoices: recentActions
          .where((item) => item.tags.any((tag) => tag.startsWith('choice:')))
          .map((item) => item.sourceId)
          .toList(growable: false),
      recentAchievements: recentAchievements,
      recentQuestResults: recentQuestResults,
      inventorySummary: inventorySummary,
      fishCollectionSummary: fishCollectionSummary,
      officeTags: <String>{
        ...officeTags,
        ...reputation.map((item) => 'player_reputation:$item'),
        if (influence.officeTrust >= 60) 'player_trusted',
        if (influence.officePopularity >= 60) 'player_popular',
        if (influence.officeVisibility >= 60) 'player_visible',
      }.toList(growable: false),
    );
  }

  final int playerLevel;
  final String playerCareer;
  final Map<String, int> playerSkills;
  final String playerLocation;
  final int friendCount;
  final List<String> reputation;
  final PlayerOfficeInfluence officeInfluence;
  final List<RecentPlayerAction> recentActions;
  final List<String> recentEvents;
  final List<String> recentChoices;
  final List<String> recentAchievements;
  final List<String> recentQuestResults;
  final Map<String, int> inventorySummary;
  final Map<String, int> fishCollectionSummary;
  final List<String> officeTags;

  bool hasReputation(String value) => reputation.contains(value);

  Set<String> get recentActionTypes =>
      recentActions.map((item) => item.type).toSet();

  Map<String, dynamic> toJson() {
    return {
      'playerLevel': playerLevel,
      'playerCareer': playerCareer,
      'playerSkills': playerSkills,
      'playerLocation': playerLocation,
      'friendCount': friendCount,
      'reputation': reputation,
      'officeInfluence': officeInfluence.toJson(),
      'recentActions': recentActions
          .map((action) => action.toJson())
          .toList(growable: false),
      'recentEvents': recentEvents,
      'recentChoices': recentChoices,
      'recentAchievements': recentAchievements,
      'recentQuestResults': recentQuestResults,
      'inventorySummary': inventorySummary,
      'fishCollectionSummary': fishCollectionSummary,
      'officeTags': officeTags,
    };
  }
}

List<String> _reputationFor({
  required CareerState careerState,
  required Map<String, PlayerSkillState> skills,
  required int friendCount,
  required int trustedCount,
  required Set<String> recentTypes,
  required PlayerOfficeInfluence influence,
}) {
  final values = <String>{};
  if (careerState.performanceScore >= 75 || influence.officeTrust >= 65) {
    values.add('reliable');
  }
  if (recentTypes.contains('helping') || influence.officeTrust >= 50) {
    values.add('helpful');
  }
  if ((skills['communication']?.level ?? 0) >= 4 ||
      recentTypes.contains('talking')) {
    values.add('funny');
  }
  if (careerState.performanceScore >= 85) values.add('professional');
  if (friendCount >= 5 || influence.officePopularity >= 60) {
    values.add('popular');
  }
  if (recentTypes.isEmpty || recentTypes.contains('idle')) values.add('quiet');
  if (influence.rumorInfluence >= 45 || recentTypes.contains('mystery')) {
    values.add('mysterious');
  }
  if (careerState.consecutiveWorkDays >= 5) values.add('hardworking');
  if (careerState.performanceScore < 35 && recentTypes.contains('idle')) {
    values.add('lazy');
  }
  if (recentTypes.contains('late')) values.add('late_comer');
  if ((skills['fishing']?.level ?? 0) >= 5 || recentTypes.contains('fishing')) {
    values.add('fishing_master');
  }
  if (trustedCount >= 8) values.add('trusted_by_office');
  if (values.isEmpty) values.add('quiet');
  return values.toList(growable: false)..sort();
}

int _friendshipRank(String stage) {
  switch (stage) {
    case 'known':
    case 'acquaintance':
      return 1;
    case 'friend':
    case 'familiar':
      return 2;
    case 'old_friend':
    case 'close_friend':
      return 3;
    case 'trust':
    case 'trusted_friend':
      return 4;
    case 'family':
    case 'family_reserved':
      return 5;
    default:
      return 0;
  }
}

int _readBounded(Object? value) => _readInt(value).clamp(0, 100).toInt();

int _bounded(num value) => value.round().clamp(0, 100).toInt();

int _readInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

Map<String, int> _intMap(Object? value) {
  if (value is! Map) return const <String, int>{};
  return Map<String, dynamic>.from(value).map(
    (key, item) => MapEntry(key, _readInt(item)),
  );
}

List<Map<String, dynamic>> _listOfMaps(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

List<String> _stringList(Object? value) {
  if (value is List) {
    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
  if (value is String && value.isNotEmpty) return <String>[value];
  return const <String>[];
}
