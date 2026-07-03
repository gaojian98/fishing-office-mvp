enum WorldDayPeriod {
  dawn,
  morning,
  noon,
  afternoon,
  sunset,
  night,
  midnight,
}

class WorldClock {
  const WorldClock({
    required this.dayCount,
    required this.hour,
    required this.minute,
    required this.period,
    required this.timeLabel,
  });

  factory WorldClock.initial() {
    return const WorldClock(
      dayCount: 1,
      hour: 5,
      minute: 0,
      period: WorldDayPeriod.dawn,
      timeLabel: 'Dawn',
    );
  }

  final int dayCount;
  final int hour;
  final int minute;
  final WorldDayPeriod period;
  final String timeLabel;

  WorldClock tick([Duration step = const Duration(minutes: 10)]) {
    final totalMinutes = hour * 60 + minute + step.inMinutes;
    final dayOffset = totalMinutes ~/ (24 * 60);
    final minutesInDay = totalMinutes % (24 * 60);
    final nextHour = minutesInDay ~/ 60;
    final nextMinute = minutesInDay % 60;
    return WorldClock(
      dayCount: dayCount + dayOffset,
      hour: nextHour,
      minute: nextMinute,
      period: _resolvePeriod(nextHour),
      timeLabel: _resolveLabel(nextHour),
    );
  }

  WorldClock copyWith({
    int? dayCount,
    int? hour,
    int? minute,
    WorldDayPeriod? period,
    String? timeLabel,
  }) {
    return WorldClock(
      dayCount: dayCount ?? this.dayCount,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      period: period ?? this.period,
      timeLabel: timeLabel ?? this.timeLabel,
    );
  }
}

WorldDayPeriod _resolvePeriod(int hour) {
  if (hour >= 4 && hour < 6) return WorldDayPeriod.dawn;
  if (hour >= 6 && hour < 11) return WorldDayPeriod.morning;
  if (hour >= 11 && hour < 13) return WorldDayPeriod.noon;
  if (hour >= 13 && hour < 17) return WorldDayPeriod.afternoon;
  if (hour >= 17 && hour < 20) return WorldDayPeriod.sunset;
  if (hour >= 20 && hour < 24) return WorldDayPeriod.night;
  return WorldDayPeriod.midnight;
}

String _resolveLabel(int hour) {
  switch (_resolvePeriod(hour)) {
    case WorldDayPeriod.morning:
      return 'Morning';
    case WorldDayPeriod.noon:
      return 'Noon';
    case WorldDayPeriod.afternoon:
      return 'Afternoon';
    case WorldDayPeriod.sunset:
      return 'Sunset';
    case WorldDayPeriod.night:
      return 'Night';
    case WorldDayPeriod.dawn:
      return 'Dawn';
    case WorldDayPeriod.midnight:
      return 'Midnight';
  }
}
