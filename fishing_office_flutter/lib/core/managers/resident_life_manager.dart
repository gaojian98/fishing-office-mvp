import 'package:flutter/foundation.dart';

import '../../models/living_world_config.dart';
import '../../models/company_organization.dart';
import '../../models/office_life_schedule.dart';
import '../../models/resident_life_config.dart';
import '../repository/resident_life_repository.dart';
import 'world_clock_manager.dart';

class ResidentLifeManager extends ChangeNotifier {
  ResidentLifeManager(this.repository, {WorldClockManager? worldClockManager})
      : _worldClockManager = worldClockManager;

  final ResidentLifeRepository repository;
  final WorldClockManager? _worldClockManager;
  ResidentLifeConfig? _config;
  bool _loaded = false;
  Object? _error;

  ResidentLifeConfig? get config => _config;
  bool get loaded => _loaded;
  Object? get error => _error;
  List<ResidentSchedule> get schedules =>
      _config?.schedules ?? const <ResidentSchedule>[];
  List<ResidentActivity> get activities =>
      _config?.activities ?? const <ResidentActivity>[];

  ResidentCurrentState getResidentCurrentState(
    String id, {
    WorldClockConfig? clock,
    DateTime? now,
  }) {
    final resolvedClock = clock ??
        _clockFromDateTime(now) ??
        _worldClockManager?.config ??
        const WorldClockConfig(
          hour: 5,
          minute: 0,
          weekday: 1,
          month: 1,
          season: 'spring',
        );
    final residentSchedules = schedules
        .where((item) => item.residentId == id)
        .toList(growable: false);
    if (residentSchedules.isEmpty) {
      return ResidentCurrentState.empty(residentId: id);
    }
    for (final schedule in residentSchedules) {
      if (_matchesWeekday(schedule, resolvedClock.weekday) &&
          _matchesTime(schedule, resolvedClock.hour, resolvedClock.minute)) {
        return ResidentCurrentState.fromSchedule(schedule);
      }
    }
    final fallback = residentSchedules.first;
    return ResidentCurrentState.fromSchedule(fallback);
  }

  WorldClockConfig? _clockFromDateTime(DateTime? dateTime) {
    if (dateTime == null) return null;
    return WorldClockConfig(
      hour: dateTime.hour,
      minute: dateTime.minute,
      weekday: dateTime.weekday,
      month: dateTime.month,
      season: 'reserved',
    );
  }

  bool _matchesWeekday(ResidentSchedule schedule, int weekday) {
    return schedule.weekdays.isEmpty || schedule.weekdays.contains(weekday);
  }

  bool _matchesTime(ResidentSchedule schedule, int hour, int minute) {
    final current = hour * 60 + minute;
    final start = _parseMinutes(schedule.startTime);
    final end = _parseMinutes(schedule.endTime);
    if (start == end) return true;
    if (start < end) {
      return current >= start && current < end;
    }
    return current >= start || current < end;
  }

  int _parseMinutes(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return hour.clamp(0, 23) * 60 + minute.clamp(0, 59);
  }

  Future<void> load() async {
    try {
      _config = await repository.load();
      _loaded = true;
      _error = null;
      if (kDebugMode) {
        debugPrint(
            'ResidentLifeManager Loaded | schedules=${schedules.length} activities=${activities.length}');
      }
    } catch (error) {
      _loaded = false;
      _error = error;
      if (kDebugMode) {
        debugPrint('ResidentLifeManager Load Failed | $error');
      }
    }
    notifyListeners();
  }
}

class ResidentCurrentState {
  const ResidentCurrentState({
    required this.residentId,
    required this.scheduleId,
    required this.location,
    required this.activity,
    required this.mood,
    required this.startTime,
    required this.endTime,
    required this.found,
    this.schedulePhase = '',
    this.isWorking = false,
    this.isOnBreak = false,
    this.isOvertime = false,
    this.isWeekend = false,
    this.nextLocation = '',
    this.nextActivity = '',
    this.nextChangeTime = '',
    this.scheduleReason = '',
    this.organization = const OrganizationAssignment.empty(),
  });

  factory ResidentCurrentState.fromSchedule(ResidentSchedule schedule) {
    final life = OfficeLifeSchedule.fromRaw(
      rawPhase: schedule.schedule,
      hour: _hourFromTime(schedule.startTime),
      minute: _minuteFromTime(schedule.startTime),
      weekday: schedule.weekdays.isEmpty ? 1 : schedule.weekdays.first,
      location: schedule.location,
      activity: schedule.activity,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
    );
    return ResidentCurrentState(
      residentId: schedule.residentId,
      scheduleId: schedule.id,
      location: schedule.location,
      activity: schedule.activity,
      mood: schedule.mood,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      found: true,
      schedulePhase: life.phase,
      isWorking: life.isWorking,
      isOnBreak: life.isOnBreak,
      isOvertime: life.isOvertime,
      isWeekend: life.isWeekend,
      nextLocation: life.nextLocation,
      nextActivity: life.nextActivity,
      nextChangeTime: life.nextChangeTime,
      scheduleReason: life.reason,
    );
  }

  factory ResidentCurrentState.empty({required String residentId}) {
    return ResidentCurrentState(
      residentId: residentId,
      scheduleId: '',
      location: '',
      activity: '',
      mood: '',
      startTime: '',
      endTime: '',
      found: false,
    );
  }

  final String residentId;
  final String scheduleId;
  final String location;
  final String activity;
  final String mood;
  final String startTime;
  final String endTime;
  final bool found;
  final String schedulePhase;
  final bool isWorking;
  final bool isOnBreak;
  final bool isOvertime;
  final bool isWeekend;
  final String nextLocation;
  final String nextActivity;
  final String nextChangeTime;
  final String scheduleReason;
  final OrganizationAssignment organization;
}

int _hourFromTime(String value) {
  final parts = value.split(':');
  return (int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0).clamp(0, 23);
}

int _minuteFromTime(String value) {
  final parts = value.split(':');
  return (int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0).clamp(0, 59);
}
