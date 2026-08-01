import 'package:flutter/foundation.dart';

import '../../models/festival_config.dart';
import '../engine/world_calendar.dart';
import 'resident_runtime_manager.dart';
import 'world_clock_manager.dart';

class FestivalRuntimeManager {
  FestivalRuntimeManager({
    required FestivalConfig config,
    required WorldClockManager worldClockManager,
    required ResidentRuntimeManager residentRuntimeManager,
  })  : _config = config,
        _worldClockManager = worldClockManager,
        _residentRuntimeManager = residentRuntimeManager;

  final FestivalConfig _config;
  final WorldClockManager _worldClockManager;
  final ResidentRuntimeManager _residentRuntimeManager;
  String _cachedActiveKey = '';
  List<FestivalEntry> _cachedActive = const <FestivalEntry>[];
  String _cachedTagsKey = '';
  List<String> _cachedTags = const <String>[];

  FestivalEntry? getTodayFestival() {
    final festivals = getActiveFestivals();
    if (festivals.isEmpty) return null;
    return festivals.first;
  }

  List<FestivalEntry> getActiveFestivals() {
    final key = _festivalCacheKey();
    if (key == _cachedActiveKey) return _cachedActive;
    final calendar = _worldClockManager.today();
    final active = _config.festivals
        .where((festival) => festival.enabled)
        .where((festival) => _isActiveOnCalendar(festival, calendar))
        .toList(growable: false);
    final sorted = List<FestivalEntry>.from(active)
      ..sort((a, b) {
        final sort = a.sortOrder.compareTo(b.sortOrder);
        if (sort != 0) return sort;
        return a.id.compareTo(b.id);
      });
    if (kDebugMode) {
      debugPrint(
        'FestivalRuntimeManager | active=${sorted.map((item) => item.id).join(',')}',
      );
    }
    _cachedActiveKey = key;
    _cachedActive = sorted;
    return sorted;
  }

  bool isFestivalActive(String festivalId) {
    if (festivalId.isEmpty) return false;
    final aliases = _festivalAliases(festivalId);
    return getActiveFestivals()
        .any((festival) => aliases.any(_festivalAliases(festival.id).contains));
  }

  List<String> getFestivalTags() {
    final key = _festivalCacheKey();
    if (key == _cachedTagsKey) return _cachedTags;
    final tags = <String>{};
    for (final festival in getActiveFestivals()) {
      tags
        ..add(festival.id)
        ..addAll(_festivalAliases(festival.id))
        ..addAll(festival.tags)
        ..addAll(festival.dialogueTags)
        ..addAll(festival.storyTags)
        ..addAll(festival.eventTags);
      if (festival.category.isNotEmpty) tags.add(festival.category);
      if (festival.mood.isNotEmpty) tags.add(festival.mood);
      if (festival.theme.isNotEmpty) tags.add(festival.theme);
    }
    _cachedTagsKey = key;
    _cachedTags = tags.where((item) => item.isNotEmpty).toList(growable: false);
    return _cachedTags;
  }

  void invalidateCache() {
    _cachedActiveKey = '';
    _cachedActive = const <FestivalEntry>[];
    _cachedTagsKey = '';
    _cachedTags = const <String>[];
  }

  FestivalContext applyFestivalContext(Map<String, dynamic> context) {
    final active = getActiveFestivals();
    final currentMood = context['residentMood']?.toString() ??
        context['mood']?.toString() ??
        '';
    final currentActivity = context['residentActivity']?.toString() ??
        context['activity']?.toString() ??
        '';
    if (active.isEmpty) {
      return FestivalContext(
        activeFestivals: const <FestivalEntry>[],
        tags: const <String>[],
        residentMood: currentMood,
        residentActivity: currentActivity,
        raw: Map<String, dynamic>.from(context),
      );
    }
    final primary = active.first;
    final mood =
        primary.residentMood.isEmpty ? currentMood : primary.residentMood;
    final activity = 'festival:${primary.id}';
    final raw = Map<String, dynamic>.from(context)
      ..['festivalIds'] = active.map((festival) => festival.id).toList()
      ..['festivalTags'] = getFestivalTags()
      ..['residentMood'] = mood
      ..['residentActivity'] = activity;
    return FestivalContext(
      activeFestivals: active,
      tags: getFestivalTags(),
      residentMood: mood,
      residentActivity: activity,
      raw: raw,
    );
  }

  FestivalContext residentFestivalContext(String residentId) {
    final state = _residentRuntimeManager.getResidentCurrentState(residentId);
    return applyFestivalContext({
      'residentId': residentId,
      'residentMood': state.mood,
      'residentActivity': state.activity,
      'residentLocation': state.location,
    });
  }

  bool _isActiveOnCalendar(FestivalEntry festival, WorldCalendar calendar) {
    final date = _parseDateValue(festival.dateValue);
    if (date == null) return false;
    final duration = festival.durationDays <= 0 ? 1 : festival.durationDays;
    final currentOrdinal = _ordinal(calendar.month, calendar.day);
    final festivalOrdinal = _ordinal(date.month, date.day);
    return currentOrdinal >= festivalOrdinal &&
        currentOrdinal < festivalOrdinal + duration;
  }

  _FestivalDate? _parseDateValue(String value) {
    final normalized = value.replaceFirst('lunar-', '');
    final parts = normalized.split('-');
    if (parts.length < 2) return null;
    final month = int.tryParse(parts[0]);
    final day = int.tryParse(parts[1]);
    if (month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return _FestivalDate(month: month, day: day);
  }

  int _ordinal(int month, int day) => (month - 1) * 31 + day;

  Set<String> _festivalAliases(String id) {
    final aliases = <String>{id};
    if (id.startsWith('festival_')) {
      aliases.add(id.substring('festival_'.length));
    } else {
      aliases.add('festival_$id');
    }
    return aliases;
  }

  String _festivalCacheKey() {
    final calendar = _worldClockManager.today();
    return '${calendar.dayCount}:${calendar.month}:${calendar.day}';
  }
}

class FestivalContext {
  const FestivalContext({
    required this.activeFestivals,
    required this.tags,
    required this.residentMood,
    required this.residentActivity,
    required this.raw,
  });

  final List<FestivalEntry> activeFestivals;
  final List<String> tags;
  final String residentMood;
  final String residentActivity;
  final Map<String, dynamic> raw;

  bool get hasFestival => activeFestivals.isNotEmpty;

  List<String> get festivalIds =>
      activeFestivals.map((festival) => festival.id).toList(growable: false);
}

class _FestivalDate {
  const _FestivalDate({
    required this.month,
    required this.day,
  });

  final int month;
  final int day;
}
