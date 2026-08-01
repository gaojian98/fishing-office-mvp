import '../../models/dynamic_event_config.dart';
import '../managers/dynamic_event_runtime_manager.dart';

enum FairyEventCategory {
  fishTalk,
  fishCry,
  fishJoke,
  fishEscape,
  residentEncounter,
  weatherWonder,
  festivalSurprise,
  officeHumor,
  oceanMystery,
  silentMoment,
}

class FairyEventSelection {
  const FairyEventSelection({
    required this.event,
    required this.category,
    required this.rhythmTier,
    required this.score,
    required this.reason,
  });

  final DynamicEventEntry event;
  final FairyEventCategory category;
  final String rhythmTier;
  final int score;
  final String reason;
}

class FairyEventStats {
  const FairyEventStats({
    required this.triggerCount,
    required this.repeatRate,
    required this.averageIntervalMinutes,
    required this.categoryDistribution,
  });

  final int triggerCount;
  final double repeatRate;
  final double averageIntervalMinutes;
  final Map<FairyEventCategory, int> categoryDistribution;
}

class _FairyEventHistoryItem {
  const _FairyEventHistoryItem({
    required this.eventId,
    required this.category,
    required this.minute,
  });

  final String eventId;
  final FairyEventCategory category;
  final int minute;
}

class FairyEventService {
  FairyEventService(this._dynamicEventRuntimeManager);

  final DynamicEventRuntimeManager _dynamicEventRuntimeManager;
  final List<_FairyEventHistoryItem> _history = <_FairyEventHistoryItem>[];

  FairyEventSelection? selectEvent({
    Duration waitingDuration = Duration.zero,
  }) {
    final waitingMinute = waitingDuration.inMinutes;
    final rhythmTier = _rhythmTier(waitingDuration);
    final context = _dynamicEventRuntimeManager.getEventContext();
    final recentEventIds = _recentEventIds(waitingMinute).toSet();
    final candidates = _dynamicEventRuntimeManager
        .getAvailableEvents()
        .where((event) => _isFairyEvent(event))
        .where((event) => !recentEventIds.contains(event.id))
        .map(
          (event) => FairyEventSelection(
            event: event,
            category: _categoryFor(event),
            rhythmTier: rhythmTier,
            score: _scoreEvent(event, rhythmTier, context),
            reason:
                'matched $rhythmTier waiting rhythm with current world state',
          ),
        )
        .toList(growable: false);
    if (candidates.isEmpty) return null;
    final filtered = candidates
        .where((candidate) => !_wouldExceedConsecutiveLimit(
              candidate.category,
            ))
        .toList(growable: false);
    final available = filtered.isEmpty ? candidates : filtered;
    available.sort((a, b) {
      final score = b.score.compareTo(a.score);
      if (score != 0) return score;
      return a.event.id.compareTo(b.event.id);
    });
    return available.first;
  }

  DynamicEventRuntimeRecord? triggerFairyEvent({
    Duration waitingDuration = Duration.zero,
  }) {
    final selection = selectEvent(waitingDuration: waitingDuration);
    if (selection == null) return null;
    final record = _dynamicEventRuntimeManager.triggerEvent(selection.event.id);
    if (record == null) return null;
    _history.add(
      _FairyEventHistoryItem(
        eventId: selection.event.id,
        category: selection.category,
        minute: waitingDuration.inMinutes,
      ),
    );
    return record;
  }

  DynamicEventResolveResult? resolveFairyEvent(
    String eventId, {
    String choiceId = '',
  }) {
    return _dynamicEventRuntimeManager.resolveEvent(eventId, choiceId);
  }

  FairyEventStats stats() {
    if (_history.isEmpty) {
      return const FairyEventStats(
        triggerCount: 0,
        repeatRate: 0,
        averageIntervalMinutes: 0,
        categoryDistribution: <FairyEventCategory, int>{},
      );
    }
    var repeated = 0;
    var intervalSum = 0;
    final distribution = <FairyEventCategory, int>{};
    for (var i = 0; i < _history.length; i += 1) {
      final item = _history[i];
      distribution[item.category] = (distribution[item.category] ?? 0) + 1;
      if (i > 0) {
        if (_history[i - 1].category == item.category) repeated += 1;
        intervalSum += (item.minute - _history[i - 1].minute).abs();
      }
    }
    return FairyEventStats(
      triggerCount: _history.length,
      repeatRate: _history.length <= 1 ? 0 : repeated / (_history.length - 1),
      averageIntervalMinutes:
          _history.length <= 1 ? 0 : intervalSum / (_history.length - 1),
      categoryDistribution: Map<FairyEventCategory, int>.unmodifiable(
        distribution,
      ),
    );
  }

  List<String> _recentEventIds(int waitingMinute) {
    return _history
        .where((item) => waitingMinute - item.minute <= 10)
        .map((item) => item.eventId)
        .toList(growable: false);
  }

  bool _wouldExceedConsecutiveLimit(FairyEventCategory category) {
    if (_history.length < 2) return false;
    final last = _history[_history.length - 1].category;
    final previous = _history[_history.length - 2].category;
    return last == category && previous == category;
  }

  bool _isFairyEvent(DynamicEventEntry event) {
    final tags = <String>{event.type, event.category, ...event.tags};
    return tags.any((tag) {
      return const <String>{
        'waiting',
        'fish_talk',
        'fish_complain',
        'fish_help',
        'escape_laugh',
        'mother_fish',
        'bottle',
        'bird_pass',
        'boss_pass',
        'old_hint',
        'coffee_wind',
        'weather',
        'festival',
        'office',
        'resident',
        'ocean',
        'mystery',
        'silent',
      }.contains(tag);
    });
  }

  FairyEventCategory _categoryFor(DynamicEventEntry event) {
    final type = event.type;
    if (type == 'fish_talk') return FairyEventCategory.fishTalk;
    if (type == 'fish_help' || type == 'mother_fish') {
      return FairyEventCategory.fishCry;
    }
    if (type == 'fish_complain') return FairyEventCategory.fishJoke;
    if (type == 'escape_laugh') return FairyEventCategory.fishEscape;
    if (type == 'bird_pass' || event.category == 'resident') {
      return FairyEventCategory.residentEncounter;
    }
    if (event.category == 'weather' || type.contains('weather')) {
      return FairyEventCategory.weatherWonder;
    }
    if (event.category == 'festival' || type.contains('festival')) {
      return FairyEventCategory.festivalSurprise;
    }
    if (type == 'boss_pass' || type == 'coffee_wind') {
      return FairyEventCategory.officeHumor;
    }
    if (type == 'bottle' || event.tags.contains('mystery')) {
      return FairyEventCategory.oceanMystery;
    }
    return FairyEventCategory.silentMoment;
  }

  int _scoreEvent(
    DynamicEventEntry event,
    String rhythmTier,
    DynamicEventContext context,
  ) {
    var score = event.priority + event.weight;
    final category = _categoryFor(event);
    if (rhythmTier == 'light' &&
        (category == FairyEventCategory.fishTalk ||
            category == FairyEventCategory.officeHumor ||
            category == FairyEventCategory.silentMoment)) {
      score += 20;
    }
    if (rhythmTier == 'surprise' &&
        (category == FairyEventCategory.fishJoke ||
            category == FairyEventCategory.residentEncounter ||
            category == FairyEventCategory.weatherWonder ||
            category == FairyEventCategory.festivalSurprise)) {
      score += 30;
    }
    if (rhythmTier == 'fairy' &&
        (category == FairyEventCategory.fishCry ||
            category == FairyEventCategory.oceanMystery)) {
      score += 40;
    }
    if (event.conditions.weather.isNotEmpty && context.weatherIds.isNotEmpty) {
      score += 5;
    }
    if (event.conditions.festival.isNotEmpty &&
        context.festivalIds.isNotEmpty) {
      score += 5;
    }
    if (event.conditions.rumorTags.isNotEmpty && context.rumorTags.isNotEmpty) {
      score += 4;
    }
    if (event.conditions.relationshipLevel.isNotEmpty &&
        context.relationshipLevels.isNotEmpty) {
      score += 4;
    }
    return score;
  }

  String _rhythmTier(Duration waitingDuration) {
    final minutes = waitingDuration.inMinutes;
    if (minutes >= 20) return 'fairy';
    if (minutes >= 5) return 'surprise';
    if (minutes >= 2) return 'light';
    return 'ambient';
  }
}
