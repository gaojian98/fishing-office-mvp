import 'world_clock.dart';

class WorldCalendar {
  const WorldCalendar({
    required this.dayCount,
    required this.weekdayIndex,
    required this.year,
    required this.month,
    required this.day,
    required this.isWeekend,
    required this.season,
  });

  factory WorldCalendar.initial() {
    return const WorldCalendar(
      dayCount: 1,
      weekdayIndex: 1,
      year: 1,
      month: 1,
      day: 1,
      isWeekend: false,
      season: 'spring',
    );
  }

  final int dayCount;
  final int weekdayIndex;
  final int year;
  final int month;
  final int day;
  final bool isWeekend;
  final String season;

  WorldCalendar advance({required WorldClock clock}) {
    final nextDayCount = dayCount + 1;
    final nextWeekday = (weekdayIndex % 7) + 1;
    final nextMonth = month;
    final nextDay = day + 1;
    return WorldCalendar(
      dayCount: nextDayCount,
      weekdayIndex: nextWeekday,
      year: year,
      month: nextMonth,
      day: nextDay,
      isWeekend: nextWeekday == 6 || nextWeekday == 7,
      season: season,
    );
  }

  WorldCalendar nextDay({required WorldClock clock}) => advance(clock: clock);

  bool isWorkLoop(WorldClock clock) {
    final hour = clock.hour;
    return hour >= 8 && hour < 17;
  }

  WorldCalendar copyWith({
    int? dayCount,
    int? weekdayIndex,
    int? year,
    int? month,
    int? day,
    bool? isWeekend,
    String? season,
  }) {
    return WorldCalendar(
      dayCount: dayCount ?? this.dayCount,
      weekdayIndex: weekdayIndex ?? this.weekdayIndex,
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      isWeekend: isWeekend ?? this.isWeekend,
      season: season ?? this.season,
    );
  }
}
