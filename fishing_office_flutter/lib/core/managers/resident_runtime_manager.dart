import 'package:flutter/foundation.dart';

import '../../models/living_world_config.dart';
import '../../models/location_context.dart';
import '../../models/office_life_schedule.dart';
import '../../models/resident_config.dart';
import '../../models/resident_life_config.dart';
import '../../models/resident_personality_context.dart';
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
  final Map<String, ResidentPersonalityContext> _personalityCache =
      <String, ResidentPersonalityContext>{};
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
      _personalityCache.clear();
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
    final normalized = LocationContext.normalizeId(locationId);
    return residents
        .where((resident) =>
            resident.enabled &&
            LocationContext.normalizeId(_currentState(resident.id).location) ==
                normalized)
        .toList(growable: false);
  }

  ResidentCurrentState getResidentCurrentState(String id) {
    return _currentState(id);
  }

  LocationContext getResidentLocationContext(String id) {
    final state = _currentState(id);
    return getLocationContext(state.location);
  }

  LocationContext getLocationContext(String locationId) {
    final normalized = LocationContext.normalizeId(locationId);
    final residentIds = residents
        .where((resident) =>
            resident.enabled &&
            LocationContext.normalizeId(_currentState(resident.id).location) ==
                normalized)
        .map((resident) => resident.id)
        .toList(growable: false);
    return LocationContext.fromId(normalized, residentIds: residentIds);
  }

  List<ResidentProfile> getResidentsByLocationType(String type) {
    if (type.isEmpty) return const <ResidentProfile>[];
    return residents
        .where((resident) =>
            resident.enabled &&
            getResidentLocationContext(resident.id).locationType == type)
        .toList(growable: false);
  }

  ResidentPersonalityContext getResidentPersonalityContext(String id) {
    final cached = _personalityCache[id];
    if (cached != null) return cached;
    final resident =
        _residentConfig?.findResident(id) ?? ResidentProfile.empty(id);
    final context = ResidentPersonalityContext.fromResident(resident);
    _personalityCache[id] = context;
    return context;
  }

  Map<String, ResidentPersonalityContext> getAllResidentPersonalityContexts() {
    for (final resident in residents.where((resident) => resident.enabled)) {
      getResidentPersonalityContext(resident.id);
    }
    return Map<String, ResidentPersonalityContext>.unmodifiable({
      for (final resident in residents.where((resident) => resident.enabled))
        resident.id: _personalityCache[resident.id]!,
    });
  }

  Map<String, ResidentCurrentState> getAllResidentCurrentStates() {
    return _normalizeCapacity({
      for (final resident in residents.where((resident) => resident.enabled))
        resident.id: _currentState(resident.id),
    });
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
      _runtimeOverrides[residentId] = _normalizedOverride(
        ResidentRuntimeOverride(
          residentId: residentId,
          location: state['residentCurrentLocation']?.toString() ??
              state['location']?.toString() ??
              '',
          activity: state['activity']?.toString() ?? '',
          mood: normalizeResidentMood(state['mood']?.toString() ?? ''),
          dayCount: int.tryParse(state['dayCount']?.toString() ?? '') ??
              _worldClockManager.today().dayCount,
          source: state['source']?.toString() ?? 'world_save',
          reason: state['reason']?.toString() ?? 'world_save_restore',
          createdMinute:
              int.tryParse(state['createdMinute']?.toString() ?? '') ??
                  _worldClockManager.hour() * 60 + _worldClockManager.minute(),
          schedulePhase: state['schedulePhase']?.toString() ?? '',
          isWorking: _readBool(state['isWorking']),
          isOnBreak: _readBool(state['isOnBreak']),
          isOvertime: _readBool(state['isOvertime']),
          isWeekend: _readBool(state['isWeekend']),
          nextLocation: state['nextLocation']?.toString() ?? '',
          nextActivity: state['nextActivity']?.toString() ?? '',
          nextChangeTime: state['nextChangeTime']?.toString() ?? '',
          overrideExpiresAt: state['overrideExpiresAt']?.toString() ?? '',
          lastScheduleChange: state['lastScheduleChange']?.toString() ?? '',
          nextScheduleChange: state['nextScheduleChange']?.toString() ?? '',
        ),
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
    final location = _reasonableLocationForPhase(
      state.location,
      state.schedulePhase,
      state.residentId,
    );
    return ResidentCurrentState(
      residentId: state.residentId,
      scheduleId: state.scheduleId,
      location: location,
      activity: state.activity,
      mood: normalizeResidentMood(state.mood),
      startTime: state.startTime,
      endTime: state.endTime,
      found: state.found,
      schedulePhase: state.schedulePhase,
      isWorking: state.isWorking,
      isOnBreak: state.isOnBreak,
      isOvertime: state.isOvertime,
      isWeekend: state.isWeekend,
      nextLocation: _reasonableLocationForPhase(
        state.nextLocation,
        state.schedulePhase,
        state.residentId,
      ),
      nextActivity: state.nextActivity,
      nextChangeTime: state.nextChangeTime,
      scheduleReason: state.scheduleReason,
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
    final weekday = clock.weekday;
    final isWeekend = weekday == 6 || weekday == 7;
    final home = _rawString(resident, 'home', fallback: resident.location);
    final workplace = _rawString(
      resident,
      'workplace',
      fallback:
          resident.location.isEmpty ? 'office_sea_window' : resident.location,
    );
    final route = _rawList(resident, 'dailyRoute');
    if (isWeekend) {
      return _weekendFallbackState(
        resident: resident,
        home: home,
        workplace: workplace,
        route: route,
        clock: clock,
      );
    }
    final lunchSpot = _officeBreakLocation(resident, route, workplace);
    final evening = _routePick(route, resident.id, fallback: home, offset: 2);
    if (hour >= 6 && hour < 7) {
      return _state(
        resident,
        location: home,
        activity: '起床收拾，给今天留一点慢慢来的空间。',
        mood: _baseMood(resident, fallback: 'calm'),
        startTime: '06:00',
        endTime: '07:00',
        phase: 'morning',
        nextLocation: 'elevator',
        nextActivity: '准备通勤到办公室。',
        reason: 'weekday_morning',
      );
    }
    if (hour >= 7 && hour < 8) {
      return _state(
        resident,
        location: _commuteLocation(resident),
        activity: '通勤路上，带着一点咖啡香往办公室走。',
        mood: 'calm',
        startTime: '07:00',
        endTime: '08:00',
        phase: 'commute',
        nextLocation: workplace,
        nextActivity: '准备开始今天的工作。',
        reason: 'weekday_commute',
      );
    }
    if (hour >= 8 && hour < 9) {
      return _state(
        resident,
        location: workplace,
        activity: '刚到工位，整理电脑和今天的小计划。',
        mood: _baseMood(resident, fallback: 'busy'),
        startTime: '08:00',
        endTime: '09:00',
        phase: 'work_start',
        nextLocation: workplace,
        nextActivity: '进入上午工作节奏。',
        reason: 'weekday_work_start',
      );
    }
    if (hour >= 9 && hour < 11) {
      return _state(
        resident,
        location: _officeWorkLocation(resident, workplace),
        activity: '处理上午的工作，偶尔看一眼窗外的海。',
        mood: _baseMood(resident, fallback: 'busy'),
        startTime: '09:00',
        endTime: '11:00',
        phase: 'working',
        nextLocation: 'pantry',
        nextActivity: '去茶水间短暂休息。',
        reason: 'weekday_working',
      );
    }
    if (hour >= 11 && hour < 12) {
      return _state(
        resident,
        location: 'pantry',
        activity: '在茶水间接水，顺便听听今天的小传闻。',
        mood: 'curious',
        startTime: '11:00',
        endTime: '12:00',
        phase: 'coffee_break',
        nextLocation: lunchSpot,
        nextActivity: '准备午休。',
        reason: 'weekday_coffee_break',
      );
    }
    if (hour >= 12 && hour < 14) {
      return _state(
        resident,
        location: lunchSpot,
        activity: '午间休息，给自己留一点安静。',
        mood: 'calm',
        startTime: '12:00',
        endTime: '14:00',
        phase: 'lunch',
        nextLocation: workplace,
        nextActivity: '回到下午工作。',
        reason: 'weekday_lunch',
      );
    }
    if (hour >= 14 && hour < 17) {
      return _state(
        resident,
        location: _officeWorkLocation(resident, workplace, afternoon: true),
        activity: '继续今天的小工作，偶尔听听海风。',
        mood: _baseMood(resident, fallback: 'busy'),
        startTime: '14:00',
        endTime: '17:00',
        phase: 'afternoon_work',
        nextLocation: _shouldOvertime(resident) ? workplace : evening,
        nextActivity: _shouldOvertime(resident) ? '可能留下来处理一点收尾。' : '准备下班。',
        reason: 'weekday_afternoon_work',
      );
    }
    if (hour >= 17 && hour < 18) {
      final overtime = _shouldOvertime(resident);
      return _state(
        resident,
        location: overtime ? workplace : _commuteLocation(resident),
        activity: overtime ? '今天稍微加一点班，把事情收个尾。' : '收拾东西，准备离开办公室。',
        mood: overtime ? 'busy' : 'happy',
        startTime: '17:00',
        endTime: '18:00',
        phase: overtime ? 'overtime' : 'off_work',
        nextLocation: overtime ? _commuteLocation(resident) : evening,
        nextActivity: overtime ? '加班结束后离开办公室。' : '下班后去放松一下。',
        reason: overtime ? 'weekday_overtime' : 'weekday_off_work',
      );
    }
    if (hour >= 18 && hour < 21) {
      return _state(
        resident,
        location: evening,
        activity: '慢慢结束今天，路过第二世界的灯光。',
        mood: 'happy',
        startTime: '18:00',
        endTime: '21:00',
        phase: 'evening',
        nextLocation: home,
        nextActivity: '准备回家休息。',
        reason: 'weekday_evening',
      );
    }
    if (hour >= 21 && hour < 22) {
      return _state(
        resident,
        location: home,
        activity: '回到自己的小地方，让今天慢慢收尾。',
        mood: 'calm',
        startTime: '21:00',
        endTime: '22:00',
        phase: 'home',
        nextLocation: home,
        nextActivity: '进入休息时间。',
        reason: 'weekday_home',
      );
    }
    return _state(
      resident,
      location: home.isEmpty ? 'quiet_room' : home,
      activity: '休息中，世界仍然轻轻运转。',
      mood: 'calm',
      startTime: '22:00',
      endTime: '06:00',
      phase: 'sleep',
      nextLocation: home,
      nextActivity: '明天早晨再开始新的生活。',
      reason: 'weekday_sleep',
    );
  }

  ResidentCurrentState _weekendFallbackState({
    required ResidentProfile resident,
    required String home,
    required String workplace,
    required List<String> route,
    required WorldClockConfig clock,
  }) {
    final hour = clock.hour;
    final weekendSpot = _weekendLocation(resident, route, workplace);
    if (hour < 7 || hour >= 22) {
      return _state(
        resident,
        location: home.isEmpty ? 'quiet_room' : home,
        activity: '周末休息中，今天不用急着赶路。',
        mood: 'calm',
        startTime: '22:00',
        endTime: '07:00',
        phase: 'sleep',
        nextLocation: home,
        nextActivity: '醒来后慢慢安排周末。',
        reason: 'weekend_sleep',
      );
    }
    if (hour >= 7 && hour < 11) {
      return _state(
        resident,
        location: home,
        activity: '周末早晨，慢慢整理自己的小生活。',
        mood: _baseMood(resident, fallback: 'happy'),
        startTime: '07:00',
        endTime: '11:00',
        phase: 'weekend',
        nextLocation: weekendSpot,
        nextActivity: '去喜欢的地方待一会儿。',
        reason: 'weekend_morning',
      );
    }
    if (hour >= 11 && hour < 14) {
      return _state(
        resident,
        location: _weekendLunchLocation(resident, route),
        activity: '周末午间，吃点喜欢的东西，不谈 KPI。',
        mood: 'happy',
        startTime: '11:00',
        endTime: '14:00',
        phase: 'weekend',
        nextLocation: weekendSpot,
        nextActivity: '继续周末的小活动。',
        reason: 'weekend_lunch',
      );
    }
    if (hour >= 14 && hour < 18) {
      return _state(
        resident,
        location: weekendSpot,
        activity: _weekendActivity(resident),
        mood: 'curious',
        startTime: '14:00',
        endTime: '18:00',
        phase: 'weekend',
        nextLocation: home,
        nextActivity: '准备慢慢回家。',
        reason: 'weekend_activity',
      );
    }
    return _state(
      resident,
      location: _routePick(route, resident.id, fallback: home, offset: 3),
      activity: '周末傍晚，和熟悉的风景打个招呼。',
      mood: 'calm',
      startTime: '18:00',
      endTime: '22:00',
      phase: 'evening',
      nextLocation: home,
      nextActivity: '回家休息。',
      reason: 'weekend_evening',
    );
  }

  ResidentCurrentState _state(
    ResidentProfile resident, {
    required String location,
    required String activity,
    required String mood,
    required String startTime,
    required String endTime,
    required String phase,
    required String nextLocation,
    required String nextActivity,
    required String reason,
  }) {
    final resolvedLocation =
        _reasonableLocationForPhase(location, phase, resident.id);
    final resolvedNextLocation =
        _reasonableLocationForPhase(nextLocation, phase, resident.id);
    final life = OfficeLifeSchedule.fromRaw(
      rawPhase: phase,
      hour: _parseMinutes(startTime) ~/ 60,
      minute: _parseMinutes(startTime) % 60,
      weekday: _worldClockManager.weekday(),
      location: resolvedLocation,
      activity: activity,
      startTime: startTime,
      endTime: endTime,
      reason: reason,
    );
    return ResidentCurrentState(
      residentId: resident.id,
      scheduleId: 'runtime_default_${resident.id}',
      location: resolvedLocation,
      activity: activity,
      mood: normalizeResidentMood(mood),
      startTime: startTime,
      endTime: endTime,
      found: true,
      schedulePhase: life.phase,
      isWorking: life.isWorking,
      isOnBreak: life.isOnBreak,
      isOvertime: life.isOvertime,
      isWeekend: life.isWeekend,
      nextLocation: resolvedNextLocation,
      nextActivity: nextActivity,
      nextChangeTime: life.nextChangeTime,
      scheduleReason: reason,
    );
  }

  String _baseMood(ResidentProfile resident, {required String fallback}) {
    final normalized = normalizeResidentMood(resident.mood);
    return normalized.isEmpty ? fallback : normalized;
  }

  String _commuteLocation(ResidentProfile resident) {
    final seed = _stableSeed(resident.id);
    return switch (seed % 3) {
      0 => 'elevator',
      1 => 'reception',
      _ => 'balcony',
    };
  }

  String _officeWorkLocation(
    ResidentProfile resident,
    String workplace, {
    bool afternoon = false,
  }) {
    final personality = getResidentPersonalityContext(resident.id);
    final preferred = personality.preferredLocationForPhase(
      afternoon ? 'afternoon_work' : 'working',
    );
    if (personality.locationWeight(preferred) > 0) return preferred;
    final seed = _stableSeed(resident.id) + (afternoon ? 2 : 0);
    return switch (seed % 5) {
      0 => workplace,
      1 => 'workstation',
      2 => 'meeting_room',
      3 => 'printing_area',
      _ => 'manager_room',
    };
  }

  String _officeBreakLocation(
    ResidentProfile resident,
    List<String> route,
    String workplace,
  ) {
    final personality = getResidentPersonalityContext(resident.id);
    final preferred = personality.preferredLocationForPhase('coffee_break');
    if (personality.locationWeight(preferred) > 0) return preferred;
    final seed = _stableSeed(resident.id);
    if (route.length > 2 && seed.isEven) return route.last;
    return seed % 3 == 0 ? 'coffee_shop' : 'pantry';
  }

  String _weekendLocation(
    ResidentProfile resident,
    List<String> route,
    String fallback,
  ) {
    final personality = getResidentPersonalityContext(resident.id);
    for (final preferred in personality.locationPreferences) {
      if (const {
        'home',
        'park',
        'coffee_shop',
        'seaside',
        'dock',
        'shop',
      }.contains(preferred)) {
        return preferred;
      }
    }
    final seed = _stableSeed(resident.id);
    final locations = <String>[
      'home',
      'park',
      'coffee_shop',
      'seaside',
      'dock',
      'shop',
      ...route,
      fallback,
    ].where((item) => item.isNotEmpty).toList(growable: false);
    return locations[seed % locations.length];
  }

  String _weekendLunchLocation(ResidentProfile resident, List<String> route) {
    final seed = _stableSeed(resident.id);
    if (route.any((item) => item.contains('咖啡') || item.contains('coffee'))) {
      return route.firstWhere(
        (item) => item.contains('咖啡') || item.contains('coffee'),
      );
    }
    return seed.isEven ? 'coffee_shop' : 'shop';
  }

  String _weekendActivity(ResidentProfile resident) {
    final seed = _stableSeed(resident.id);
    return switch (seed % 6) {
      0 => '在公园慢慢散步，看看今天的云。',
      1 => '去咖啡店坐一会儿，听杯子轻轻碰响。',
      2 => '到海边吹风，像给心情放个小假。',
      3 => '去码头看看有没有新的船和鱼。',
      4 => '顺路购物，给下周准备一点小东西。',
      _ => '拜访朋友，聊聊最近发生的小故事。',
    };
  }

  String _routePick(
    List<String> route,
    String residentId, {
    required String fallback,
    int offset = 0,
  }) {
    if (route.isEmpty) return fallback;
    return route[(_stableSeed(residentId) + offset) % route.length];
  }

  bool _shouldOvertime(ResidentProfile resident) {
    final mood = normalizeResidentMood(resident.mood);
    if (mood == 'tired' || mood == 'lonely' || mood == 'sad') return false;
    final personality = getResidentPersonalityContext(resident.id);
    if (personality.hasTrait('lazy')) {
      return false;
    }
    if (personality.hasTrait('hardworking') ||
        personality.hasTrait('serious') ||
        personality.hasTrait('competitive')) {
      return true;
    }
    return _stableSeed(resident.id) % 4 == 0;
  }

  int _stableSeed(String value) {
    var total = 0;
    for (final unit in value.codeUnits) {
      total += unit;
    }
    return total.abs();
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
    final currentMinute =
        _worldClockManager.hour() * 60 + _worldClockManager.minute();
    final phase = override.schedulePhase.isEmpty
        ? OfficeLifeSchedule.normalizePhase(
            rawPhase: override.reason,
            hour: _worldClockManager.hour(),
            weekday: _worldClockManager.weekday(),
          )
        : override.schedulePhase;
    return override.copyWith(
      location: _reasonableLocationForPhase(
        override.location,
        phase,
        override.residentId,
      ),
      nextLocation: _reasonableLocationForPhase(
        override.nextLocation,
        phase,
        override.residentId,
      ),
      mood: normalizeResidentMood(override.mood),
      schedulePhase: phase,
      isWorking: override.hasScheduleFlags
          ? override.isWorking
          : phase == 'work_start' ||
              phase == 'working' ||
              phase == 'afternoon_work' ||
              phase == 'overtime',
      isOnBreak: override.hasScheduleFlags
          ? override.isOnBreak
          : phase == 'coffee_break' ||
              phase == 'lunch' ||
              phase == 'off_work' ||
              phase == 'weekend' ||
              phase == 'holiday',
      isOvertime:
          override.hasScheduleFlags ? override.isOvertime : phase == 'overtime',
      isWeekend: override.hasScheduleFlags
          ? override.isWeekend
          : _worldClockManager.weekday() == 6 ||
              _worldClockManager.weekday() == 7,
      nextChangeTime: override.nextChangeTime.isEmpty
          ? OfficeLifeSchedule.nextBoundary(
              _worldClockManager.hour(),
              _worldClockManager.minute(),
            )
          : override.nextChangeTime,
      lastScheduleChange: override.lastScheduleChange.isEmpty
          ? _formatMinute(currentMinute)
          : override.lastScheduleChange,
      nextScheduleChange: override.nextScheduleChange.isEmpty
          ? (override.nextChangeTime.isEmpty
              ? OfficeLifeSchedule.nextBoundary(
                  _worldClockManager.hour(),
                  _worldClockManager.minute(),
                )
              : override.nextChangeTime)
          : override.nextScheduleChange,
      createdMinute: override.createdMinute < 0
          ? _worldClockManager.hour() * 60 + _worldClockManager.minute()
          : override.createdMinute,
    );
  }

  String _formatMinute(int totalMinutes) {
    final normalized = totalMinutes % (24 * 60);
    final hour = normalized ~/ 60;
    final minute = normalized % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  bool _readBool(Object? value) {
    if (value is bool) return value;
    return value?.toString() == 'true';
  }

  Map<String, ResidentCurrentState> _normalizeCapacity(
    Map<String, ResidentCurrentState> states,
  ) {
    final counts = <String, int>{};
    final normalized = <String, ResidentCurrentState>{};
    for (final entry in states.entries) {
      final state = entry.value;
      var location = LocationContext.normalizeId(state.location);
      final context = LocationContext.fromId(location);
      final count = (counts[location] ?? 0) + 1;
      counts[location] = count;
      if (context.maxCapacity > 0 &&
          count > context.maxCapacity &&
          location != 'workstation') {
        location = _capacityFallback(state, count);
      }
      normalized[entry.key] = state.location == location
          ? state
          : ResidentCurrentState(
              residentId: state.residentId,
              scheduleId: state.scheduleId,
              location: location,
              activity: state.activity,
              mood: state.mood,
              startTime: state.startTime,
              endTime: state.endTime,
              found: state.found,
              schedulePhase: state.schedulePhase,
              isWorking: state.isWorking,
              isOnBreak: state.isOnBreak,
              isOvertime: state.isOvertime,
              isWeekend: state.isWeekend,
              nextLocation: state.nextLocation,
              nextActivity: state.nextActivity,
              nextChangeTime: state.nextChangeTime,
              scheduleReason: '${state.scheduleReason}|capacity_fallback',
            );
    }
    return normalized;
  }

  String _capacityFallback(ResidentCurrentState state, int count) {
    if (state.isWorking) return count.isEven ? 'workstation' : 'office';
    if (state.isOnBreak) return 'coffee_shop';
    return LocationContext.fallbackForPhase(
      state.schedulePhase,
      seed: '${state.residentId}_$count',
    );
  }

  String _reasonableLocationForPhase(
    String location,
    String phase,
    String residentId,
  ) {
    final normalized = LocationContext.normalizeId(location);
    if (LocationContext.isReasonableForPhase(normalized, phase)) {
      return normalized;
    }
    return LocationContext.fallbackForPhase(phase, seed: residentId);
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
    this.schedulePhase = '',
    this.isWorking = false,
    this.isOnBreak = false,
    this.isOvertime = false,
    this.isWeekend = false,
    this.nextLocation = '',
    this.nextActivity = '',
    this.nextChangeTime = '',
    this.overrideExpiresAt = '',
    this.lastScheduleChange = '',
    this.nextScheduleChange = '',
  });

  final String residentId;
  final String location;
  final String activity;
  final String mood;
  final int dayCount;
  final String source;
  final String reason;
  final int createdMinute;
  final String schedulePhase;
  final bool isWorking;
  final bool isOnBreak;
  final bool isOvertime;
  final bool isWeekend;
  final String nextLocation;
  final String nextActivity;
  final String nextChangeTime;
  final String overrideExpiresAt;
  final String lastScheduleChange;
  final String nextScheduleChange;

  bool get hasScheduleFlags =>
      isWorking || isOnBreak || isOvertime || isWeekend;

  ResidentRuntimeOverride copyWith({
    String? residentId,
    String? location,
    String? activity,
    String? mood,
    int? dayCount,
    String? source,
    String? reason,
    int? createdMinute,
    String? schedulePhase,
    bool? isWorking,
    bool? isOnBreak,
    bool? isOvertime,
    bool? isWeekend,
    String? nextLocation,
    String? nextActivity,
    String? nextChangeTime,
    String? overrideExpiresAt,
    String? lastScheduleChange,
    String? nextScheduleChange,
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
      schedulePhase: schedulePhase ?? this.schedulePhase,
      isWorking: isWorking ?? this.isWorking,
      isOnBreak: isOnBreak ?? this.isOnBreak,
      isOvertime: isOvertime ?? this.isOvertime,
      isWeekend: isWeekend ?? this.isWeekend,
      nextLocation: nextLocation ?? this.nextLocation,
      nextActivity: nextActivity ?? this.nextActivity,
      nextChangeTime: nextChangeTime ?? this.nextChangeTime,
      overrideExpiresAt: overrideExpiresAt ?? this.overrideExpiresAt,
      lastScheduleChange: lastScheduleChange ?? this.lastScheduleChange,
      nextScheduleChange: nextScheduleChange ?? this.nextScheduleChange,
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
      schedulePhase: schedulePhase,
      isWorking: isWorking,
      isOnBreak: isOnBreak,
      isOvertime: isOvertime,
      isWeekend: isWeekend,
      nextLocation: nextLocation,
      nextActivity: nextActivity,
      nextChangeTime: nextChangeTime,
      scheduleReason: reason,
    );
  }
}
