import 'package:flutter/foundation.dart';

import '../../models/living_world_config.dart';
import '../../models/resident_config.dart';
import '../../models/resident_life_config.dart';
import '../repository/resident_life_repository.dart';
import '../repository/resident_repository.dart';
import '../utils/resident_mood.dart';
import 'resident_life_manager.dart';
import 'world_clock_manager.dart';

class ResidentRuntimeManager extends ChangeNotifier {
  ResidentRuntimeManager({
    required ResidentRepository residentRepository,
    required ResidentLifeRepository lifeRepository,
    required WorldClockManager worldClockManager,
  })  : _residentRepository = residentRepository,
        _lifeRepository = lifeRepository,
        _worldClockManager = worldClockManager;

  final ResidentRepository _residentRepository;
  final ResidentLifeRepository _lifeRepository;
  final WorldClockManager _worldClockManager;

  ResidentConfig? _residentConfig;
  ResidentLifeConfig? _lifeConfig;
  final Map<String, ResidentRuntimeOverride> _runtimeOverrides =
      <String, ResidentRuntimeOverride>{};
  Object? _error;
  bool _loaded = false;

  bool get loaded => _loaded;
  Object? get error => _error;
  List<ResidentProfile> get residents =>
      _residentConfig?.residents ?? const <ResidentProfile>[];
  List<ResidentSchedule> get schedules =>
      _lifeConfig?.schedules ?? const <ResidentSchedule>[];
  List<ResidentActivity> get activities =>
      _lifeConfig?.activities ?? const <ResidentActivity>[];

  Future<void> load() async {
    try {
      _residentConfig = await _residentRepository.load();
      _lifeConfig = await _lifeRepository.load();
      _loaded = true;
      _error = null;
      if (kDebugMode) {
        debugPrint(
          'ResidentRuntimeManager Loaded | residents=${residents.length} schedules=${schedules.length}',
        );
      }
    } catch (error) {
      _loaded = false;
      _error = error;
      if (kDebugMode) {
        debugPrint('ResidentRuntimeManager Load Failed | $error');
      }
    }
    notifyListeners();
  }

  String getResidentCurrentLocation(String id) {
    return _currentState(id).location;
  }

  String getResidentCurrentActivity(String id) {
    return _currentState(id).activity;
  }

  String getResidentCurrentMood(String id) {
    return _currentState(id).mood;
  }

  List<ResidentProfile> getResidentsAtLocation(String locationId) {
    if (locationId.isEmpty) return const <ResidentProfile>[];
    return residents
        .where((resident) =>
            resident.enabled &&
            _currentState(resident.id).location == locationId)
        .toList(growable: false);
  }

  ResidentCurrentState getResidentCurrentState(String id) {
    return _currentState(id);
  }

  Map<String, ResidentCurrentState> getAllResidentCurrentStates() {
    return {
      for (final resident in residents.where((resident) => resident.enabled))
        resident.id: _currentState(resident.id),
    };
  }

  void applyRuntimeOverride(ResidentRuntimeOverride override) {
    if (override.residentId.isEmpty) return;
    _runtimeOverrides[override.residentId] = _normalizedOverride(override);
    notifyListeners();
  }

  ResidentRuntimeOverride applyEmotionOverride(
    ResidentRuntimeOverride override, {
    String reason = '',
    bool major = false,
  }) {
    if (override.residentId.isEmpty) return override;
    final normalized = _normalizedOverride(override.copyWith(reason: reason));
    final existing = _runtimeOverrides[normalized.residentId];
    final currentMinute =
        _worldClockManager.hour() * 60 + _worldClockManager.minute();
    if (existing != null &&
        existing.dayCount == normalized.dayCount &&
        existing.mood != normalized.mood &&
        !major &&
        currentMinute - existing.createdMinute < 30) {
      final stable = normalized.copyWith(
        mood: existing.mood,
        reason: existing.reason.isEmpty ? 'mood_stability' : existing.reason,
        source: normalized.source,
      );
      _runtimeOverrides[normalized.residentId] = stable;
      notifyListeners();
      return stable;
    }
    _runtimeOverrides[normalized.residentId] = normalized;
    notifyListeners();
    return normalized;
  }

  void clearRuntimeOverride(String residentId) {
    _runtimeOverrides.remove(residentId);
    notifyListeners();
  }

  void clearRuntimeOverrides() {
    _runtimeOverrides.clear();
    notifyListeners();
  }

  void loadRuntimeStates(List<Map<String, dynamic>> states) {
    _runtimeOverrides.clear();
    for (final state in states) {
      final residentId = state['residentId']?.toString() ?? '';
      if (residentId.isEmpty) continue;
      _runtimeOverrides[residentId] = ResidentRuntimeOverride(
        residentId: residentId,
        location: state['location']?.toString() ?? '',
        activity: state['activity']?.toString() ?? '',
        mood: normalizeResidentMood(state['mood']?.toString() ?? ''),
        dayCount: int.tryParse(state['dayCount']?.toString() ?? '') ??
            _worldClockManager.today().dayCount,
        source: state['source']?.toString() ?? 'world_save',
        reason: state['reason']?.toString() ?? 'world_save_restore',
        createdMinute: int.tryParse(state['createdMinute']?.toString() ?? '') ??
            _worldClockManager.hour() * 60 + _worldClockManager.minute(),
      );
    }
    notifyListeners();
  }

  ResidentCurrentState _currentState(String id) {
    final resident =
        _residentConfig?.findResident(id) ?? ResidentProfile.empty(id);
    if (!resident.enabled || resident.id.isEmpty) {
      return ResidentCurrentState.empty(residentId: id);
    }
    final override = _runtimeOverrides[id];
    if (override != null &&
        override.dayCount == _worldClockManager.today().dayCount) {
      return override.toCurrentState();
    }
    final clock = _worldClockManager.config;
    final residentSchedules = schedules
        .where((schedule) => schedule.residentId == id)
        .toList(growable: false);
    for (final schedule in residentSchedules) {
      if (_matchesWeekday(schedule, clock.weekday) &&
          _matchesTime(schedule, clock.hour, clock.minute)) {
        return _normalizedState(
          ResidentCurrentState.fromSchedule(_withActivityName(schedule)),
        );
      }
    }
    return _fallbackState(resident, clock);
  }

  ResidentCurrentState _normalizedState(ResidentCurrentState state) {
    return ResidentCurrentState(
      residentId: state.residentId,
      scheduleId: state.scheduleId,
      location: state.location,
      activity: state.activity,
      mood: normalizeResidentMood(state.mood),
      startTime: state.startTime,
      endTime: state.endTime,
      found: state.found,
    );
  }

  ResidentSchedule _withActivityName(ResidentSchedule schedule) {
    if (schedule.activity.isNotEmpty) return schedule;
    final activity = _activityName(schedule.activityId);
    if (activity.isEmpty) return schedule;
    return ResidentSchedule(
      id: schedule.id,
      residentId: schedule.residentId,
      schedule: schedule.schedule,
      location: schedule.location,
      activity: activity,
      activityId: schedule.activityId,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      mood: schedule.mood,
      weekdays: schedule.weekdays,
      raw: schedule.raw,
    );
  }

  String _activityName(String id) {
    for (final activity in activities) {
      if (activity.id == id) return activity.name;
    }
    return '';
  }

  bool _matchesWeekday(ResidentSchedule schedule, int weekday) {
    if (schedule.weekdays.isEmpty) return true;
    if (schedule.weekdays.contains(weekday)) return true;
    final start = _parseMinutes(schedule.startTime);
    final end = _parseMinutes(schedule.endTime);
    final isAfterMidnightSegment = start > end;
    if (!isAfterMidnightSegment) return false;
    final previous = weekday <= 1 ? 7 : weekday - 1;
    return schedule.weekdays.contains(previous);
  }

  bool _matchesTime(ResidentSchedule schedule, int hour, int minute) {
    final current = hour * 60 + minute;
    final start = _parseMinutes(schedule.startTime);
    final end = _parseMinutes(schedule.endTime);
    if (start == end) return true;
    if (start < end) return current >= start && current < end;
    return current >= start || current < end;
  }

  int _parseMinutes(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return hour.clamp(0, 23) * 60 + minute.clamp(0, 59);
  }

  ResidentCurrentState _fallbackState(
    ResidentProfile resident,
    WorldClockConfig clock,
  ) {
    final hour = clock.hour;
    final home = _rawString(resident, 'home', fallback: resident.location);
    final workplace = _rawString(
      resident,
      'workplace',
      fallback:
          resident.location.isEmpty ? 'office_sea_window' : resident.location,
    );
    final route = _rawList(resident, 'dailyRoute');
    final midday = route.isNotEmpty ? route.first : workplace;
    final evening = route.length > 1 ? route.last : home;
    if (hour >= 6 && hour < 12) {
      return _state(
        resident,
        location: workplace,
        activity: '开始一天的生活，顺手看看窗外的海。',
        mood: resident.mood.isEmpty
            ? 'calm'
            : normalizeResidentMood(resident.mood),
        startTime: '06:00',
        endTime: '12:00',
      );
    }
    if (hour >= 12 && hour < 14) {
      return _state(
        resident,
        location: midday,
        activity: '午间休息，给自己留一点安静。',
        mood: 'calm',
        startTime: '12:00',
        endTime: '14:00',
      );
    }
    if (hour >= 14 && hour < 18) {
      return _state(
        resident,
        location: workplace,
        activity: '继续今天的小工作，偶尔听听海风。',
        mood: resident.mood.isEmpty
            ? 'busy'
            : normalizeResidentMood(resident.mood),
        startTime: '14:00',
        endTime: '18:00',
      );
    }
    if (hour >= 18 && hour < 22) {
      return _state(
        resident,
        location: evening,
        activity: '慢慢结束今天，路过第二世界的灯光。',
        mood: 'happy',
        startTime: '18:00',
        endTime: '22:00',
      );
    }
    return _state(
      resident,
      location: home.isEmpty ? 'quiet_room' : home,
      activity: '休息中，世界仍然轻轻运转。',
      mood: 'calm',
      startTime: '22:00',
      endTime: '06:00',
    );
  }

  ResidentCurrentState _state(
    ResidentProfile resident, {
    required String location,
    required String activity,
    required String mood,
    required String startTime,
    required String endTime,
  }) {
    return ResidentCurrentState(
      residentId: resident.id,
      scheduleId: 'runtime_default_${resident.id}',
      location: location,
      activity: activity,
      mood: normalizeResidentMood(mood),
      startTime: startTime,
      endTime: endTime,
      found: true,
    );
  }

  String _rawString(
    ResidentProfile resident,
    String key, {
    String fallback = '',
  }) {
    final value = resident.raw[key];
    if (value == null || value.toString().isEmpty) return fallback;
    return value.toString();
  }

  List<String> _rawList(ResidentProfile resident, String key) {
    final value = resident.raw[key];
    if (value is! List) return const <String>[];
    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  ResidentRuntimeOverride _normalizedOverride(
      ResidentRuntimeOverride override) {
    return override.copyWith(
      mood: normalizeResidentMood(override.mood),
      createdMinute: override.createdMinute < 0
          ? _worldClockManager.hour() * 60 + _worldClockManager.minute()
          : override.createdMinute,
    );
  }
}

class ResidentRuntimeOverride {
  const ResidentRuntimeOverride({
    required this.residentId,
    required this.location,
    required this.activity,
    required this.mood,
    required this.dayCount,
    required this.source,
    this.reason = '',
    this.createdMinute = -1,
  });

  final String residentId;
  final String location;
  final String activity;
  final String mood;
  final int dayCount;
  final String source;
  final String reason;
  final int createdMinute;

  ResidentRuntimeOverride copyWith({
    String? residentId,
    String? location,
    String? activity,
    String? mood,
    int? dayCount,
    String? source,
    String? reason,
    int? createdMinute,
  }) {
    return ResidentRuntimeOverride(
      residentId: residentId ?? this.residentId,
      location: location ?? this.location,
      activity: activity ?? this.activity,
      mood: mood ?? this.mood,
      dayCount: dayCount ?? this.dayCount,
      source: source ?? this.source,
      reason: reason ?? this.reason,
      createdMinute: createdMinute ?? this.createdMinute,
    );
  }

  ResidentCurrentState toCurrentState() {
    return ResidentCurrentState(
      residentId: residentId,
      scheduleId: 'runtime_decision_$residentId',
      location: location,
      activity: activity,
      mood: normalizeResidentMood(mood),
      startTime: 'runtime',
      endTime: 'runtime',
      found: true,
    );
  }
}
