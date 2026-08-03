import '../../models/resident_personality_context.dart';
import '../../models/rumor_config.dart';
import '../utils/runtime_debug.dart';
import 'festival_runtime_manager.dart';
import 'resident_runtime_manager.dart';
import 'weather_runtime_manager.dart';
import 'world_clock_manager.dart';

class RumorRuntimeManager {
  RumorRuntimeManager({
    required RumorConfig config,
    required WorldClockManager worldClockManager,
    required FestivalRuntimeManager festivalRuntimeManager,
    required WeatherRuntimeManager weatherRuntimeManager,
    required ResidentRuntimeManager residentRuntimeManager,
  })  : _config = config,
        _worldClockManager = worldClockManager,
        _festivalRuntimeManager = festivalRuntimeManager,
        _weatherRuntimeManager = weatherRuntimeManager,
        _residentRuntimeManager = residentRuntimeManager;

  final RumorConfig _config;
  final WorldClockManager _worldClockManager;
  final FestivalRuntimeManager _festivalRuntimeManager;
  final WeatherRuntimeManager _weatherRuntimeManager;
  final ResidentRuntimeManager _residentRuntimeManager;
  final Map<String, RumorRuntimeRecord> _records =
      <String, RumorRuntimeRecord>{};

  List<RumorEntry> getActiveRumors() {
    _refreshDaily();
    final contextual = _config.rumors
        .where((rumor) => rumor.enabled)
        .where(_isRumorContextAvailable)
        .where((rumor) => !_isArchivedOrExpired(rumor.id))
        .toList(growable: false);
    final manual = _records.values
        .where((record) =>
            record.lifecycle != RumorLifecycle.expired &&
            record.lifecycle != RumorLifecycle.archived)
        .map((record) => _config.findRumor(record.rumorId))
        .whereType<RumorEntry>()
        .where((rumor) => rumor.enabled)
        .toList(growable: false);
    final merged = <String, RumorEntry>{
      for (final rumor in contextual) rumor.id: rumor,
      for (final rumor in manual) rumor.id: rumor,
    }.values.toList(growable: false);
    merged.sort((a, b) {
      final weight = b.weight.compareTo(a.weight);
      if (weight != 0) return weight;
      final sort = a.sortOrder.compareTo(b.sortOrder);
      if (sort != 0) return sort;
      return a.id.compareTo(b.id);
    });
    RuntimeDebug.log(
      'RumorRuntimeManager | active=${merged.map((item) => item.id).join(',')}',
    );
    return merged;
  }

  List<RumorEntry> getRumorsForResident(String residentId) {
    final personality =
        _residentRuntimeManager.getResidentPersonalityContext(residentId);
    final rumors = getActiveRumors().where((rumor) {
      final related = rumor.relatedResidentId;
      final required = rumor.unlockCondition.requiresResidentId;
      final relatedMatches = related.isEmpty || related == residentId;
      final requiredMatches = required.isEmpty || required == residentId;
      return relatedMatches && requiredMatches;
    }).toList(growable: false);
    final sorted = List<RumorEntry>.from(rumors)
      ..sort((a, b) {
        final score = _personalityRumorScore(b, personality)
            .compareTo(_personalityRumorScore(a, personality));
        if (score != 0) return score;
        return b.weight.compareTo(a.weight);
      });
    return sorted;
  }

  void addRumor(String rumorId) {
    final rumor = _config.findRumor(rumorId);
    if (rumor == null || !rumor.enabled) return;
    final day = _worldClockManager.today().dayCount;
    _records[rumorId] = RumorRuntimeRecord(
      rumorId: rumorId,
      lifecycle: RumorLifecycle.spreading,
      startedDay: day,
      lastUpdatedDay: day,
      spreadCount: 1,
      scope: _initialScope(rumor),
      probability: _probabilityFor(rumor),
      expiresAfterDays: _expiresAfterDaysFor(rumor),
    );
    RuntimeDebug.log('RumorRuntimeManager | add=$rumorId lifecycle=spreading');
  }

  void removeRumor(String rumorId) {
    final current = _records[rumorId];
    if (current == null) {
      final day = _worldClockManager.today().dayCount;
      _records[rumorId] = RumorRuntimeRecord(
        rumorId: rumorId,
        lifecycle: RumorLifecycle.archived,
        startedDay: day,
        lastUpdatedDay: day,
        spreadCount: 0,
        scope: 'none',
        probability: 0,
        expiresAfterDays: 0,
      );
      return;
    }
    _records[rumorId] = current.copyWith(
      lifecycle: RumorLifecycle.archived,
      lastUpdatedDay: _worldClockManager.today().dayCount,
    );
  }

  bool isRumorActive(String rumorId) {
    if (rumorId.isEmpty) return false;
    final aliases = _rumorAliases(rumorId);
    return getActiveRumors().any((rumor) {
      final tags = <String>{..._rumorAliases(rumor.id), ...rumor.allTags};
      return aliases.any(tags.contains);
    });
  }

  List<String> getRumorTags() {
    final tags = <String>{};
    for (final rumor in getActiveRumors()) {
      tags
        ..addAll(_rumorAliases(rumor.id))
        ..addAll(rumor.allTags)
        ..add(_lifecycleTag(rumor.id));
    }
    return tags.where((item) => item.isNotEmpty).toList(growable: false);
  }

  RumorContext applyRumorContext(Map<String, dynamic> context) {
    final active = getActiveRumors();
    final tags = getRumorTags();
    final raw = Map<String, dynamic>.from(context)
      ..['rumorIds'] = active.map((rumor) => rumor.id).toList()
      ..['rumorTags'] = tags;
    return RumorContext(
      activeRumors: active,
      tags: tags,
      records: Map<String, RumorRuntimeRecord>.unmodifiable(_records),
      raw: raw,
    );
  }

  RumorContext residentRumorContext(String residentId) {
    final state = _residentRuntimeManager.getResidentCurrentState(residentId);
    final personality =
        _residentRuntimeManager.getResidentPersonalityContext(residentId);
    final active = getRumorsForResident(residentId);
    final tags = <String>{};
    for (final rumor in active) {
      tags
        ..addAll(_rumorAliases(rumor.id))
        ..addAll(rumor.allTags)
        ..add(_lifecycleTag(rumor.id));
    }
    final raw = <String, dynamic>{
      'residentId': residentId,
      'residentMood': state.mood,
      'residentActivity': state.activity,
      'residentLocation': state.location,
      'personalityTags': personality.traits,
      'rumorPreference': personality.rumorPreference,
      'rumorIds': active.map((rumor) => rumor.id).toList(),
      'rumorTags': <String>{
        ...tags,
        ...personality.traits,
        personality.rumorPreference,
      }.toList(growable: false),
    };
    return RumorContext(
      activeRumors: active,
      tags: <String>{
        ...tags,
        ...personality.traits,
        personality.rumorPreference,
      }.where((item) => item.isNotEmpty).toList(growable: false),
      records: Map<String, RumorRuntimeRecord>.unmodifiable(_records),
      raw: raw,
    );
  }

  int _personalityRumorScore(
    RumorEntry rumor,
    ResidentPersonalityContext personality,
  ) {
    final tags = rumor.allTags.toSet();
    var score = rumor.weight;
    if (personality.traits.contains('gossipy')) score += 12;
    if (personality.traits.contains('curious') &&
        tags.any((tag) =>
            tag.contains('mystery') ||
            tag.contains('weather') ||
            tag.contains('ocean') ||
            tag.contains('fish'))) {
      score += 8;
    }
    if (personality.traits.contains('serious') &&
        tags.any((tag) =>
            tag.contains('office') ||
            tag.contains('work') ||
            tag.contains('company'))) {
      score += 6;
    }
    if (personality.traits.contains('kind') &&
        (rumor.category.contains('gossip') || tags.contains('malicious'))) {
      score -= 8;
    }
    if (personality.traits.contains('introverted')) score -= 2;
    if (personality.traits.contains('cautious')) score -= 1;
    return score;
  }

  RumorRuntimeRecord? recordFor(String rumorId) {
    _refreshDaily();
    return _records[rumorId];
  }

  List<RumorRuntimeRecord> get records {
    _refreshDaily();
    final items = _records.values.toList(growable: false);
    return List<RumorRuntimeRecord>.from(items)
      ..sort((a, b) => a.rumorId.compareTo(b.rumorId));
  }

  void loadRecords(List<RumorRuntimeRecord> records) {
    _records
      ..clear()
      ..addEntries(records
          .where((record) => record.rumorId.isNotEmpty)
          .map((record) => MapEntry(record.rumorId, record)));
  }

  void _refreshDaily() {
    final day = _worldClockManager.today().dayCount;
    for (final entry in _records.entries.toList(growable: false)) {
      final record = entry.value;
      if (record.lifecycle == RumorLifecycle.expired ||
          record.lifecycle == RumorLifecycle.archived ||
          record.lastUpdatedDay >= day) {
        continue;
      }
      final elapsed = day - record.lastUpdatedDay;
      final totalAge = day - record.startedDay;
      final nextSpread = record.spreadCount + elapsed * 4;
      final nextLifecycle = totalAge >= record.expiresAfterDays
          ? RumorLifecycle.expired
          : nextSpread >= 10
              ? RumorLifecycle.popular
              : RumorLifecycle.spreading;
      _records[entry.key] = record.copyWith(
        lifecycle: nextLifecycle,
        lastUpdatedDay: day,
        spreadCount: nextSpread,
        scope: nextLifecycle == RumorLifecycle.popular ? 'world' : record.scope,
        probability: nextLifecycle == RumorLifecycle.popular
            ? 1
            : (record.probability + elapsed * 0.12).clamp(0, 1).toDouble(),
      );
    }
  }

  bool _isRumorContextAvailable(RumorEntry rumor) {
    if (!_matchesTimeRange(rumor.timeRange)) return false;
    final condition = rumor.unlockCondition;
    if (condition.requiresFestivalId.isNotEmpty &&
        !_festivalRuntimeManager.isFestivalActive(
          condition.requiresFestivalId,
        )) {
      return false;
    }
    if (rumor.relatedFestivalId.isNotEmpty &&
        !_festivalRuntimeManager.isFestivalActive(rumor.relatedFestivalId)) {
      return false;
    }
    if (condition.requiresWeatherId.isNotEmpty &&
        !_weatherRuntimeManager.isWeatherActive(condition.requiresWeatherId)) {
      return false;
    }
    if (rumor.relatedWeatherId.isNotEmpty &&
        !_weatherRuntimeManager.isWeatherActive(rumor.relatedWeatherId)) {
      return false;
    }
    if (condition.requiresResidentId.isNotEmpty) {
      final state = _residentRuntimeManager.getResidentCurrentState(
        condition.requiresResidentId,
      );
      if (state.residentId != condition.requiresResidentId) return false;
    }
    return true;
  }

  bool _isArchivedOrExpired(String rumorId) {
    final record = _records[rumorId];
    return record?.lifecycle == RumorLifecycle.archived ||
        record?.lifecycle == RumorLifecycle.expired;
  }

  bool _matchesTimeRange(String range) {
    if (range.isEmpty || range == 'any' || range == 'all_day') return true;
    final current = _timeOfDay();
    final aliases = <String>{
      current,
      if (current == 'dusk') 'evening',
      if (current == 'late_night') 'night',
    };
    return range
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .any(aliases.contains);
  }

  String _timeOfDay() {
    final hour = _worldClockManager.hour();
    if (hour >= 5 && hour < 11) return 'morning';
    if (hour >= 11 && hour < 13) return 'noon';
    if (hour >= 13 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 20) return 'dusk';
    if (hour >= 20 && hour < 24) return 'night';
    return 'late_night';
  }

  String _initialScope(RumorEntry rumor) {
    if (rumor.relatedResidentId.isNotEmpty) return 'resident';
    if (rumor.relatedFestivalId.isNotEmpty) return 'festival';
    if (rumor.relatedWeatherId.isNotEmpty) return 'weather';
    return 'world';
  }

  double _probabilityFor(RumorEntry rumor) {
    final weight = rumor.weight <= 0 ? 1 : rumor.weight;
    return (weight / 100).clamp(0.05, 1).toDouble();
  }

  int _expiresAfterDaysFor(RumorEntry rumor) {
    switch (rumor.rarity) {
      case 'legend':
      case 'myth':
        return 7;
      case 'rare':
        return 5;
      default:
        return 3;
    }
  }

  String _lifecycleTag(String rumorId) {
    final lifecycle = _records[rumorId]?.lifecycle;
    if (lifecycle == null) return 'rumor_waiting';
    return 'rumor_${lifecycle.name}';
  }

  Set<String> _rumorAliases(String id) {
    final aliases = <String>{id};
    if (id.startsWith('rumor_')) {
      aliases.add(id.substring('rumor_'.length));
    } else {
      aliases.add('rumor_$id');
    }
    return aliases;
  }
}

class RumorContext {
  const RumorContext({
    required this.activeRumors,
    required this.tags,
    required this.records,
    required this.raw,
  });

  final List<RumorEntry> activeRumors;
  final List<String> tags;
  final Map<String, RumorRuntimeRecord> records;
  final Map<String, dynamic> raw;

  bool get hasRumors => activeRumors.isNotEmpty;
  List<String> get rumorIds =>
      activeRumors.map((rumor) => rumor.id).toList(growable: false);
}
