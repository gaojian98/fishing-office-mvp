import 'time_manager.dart';

class BridgeCalendar {
  const BridgeCalendar();

  BridgeCalendarState resolve({required TimeManager timeManager}) {
    final clock = timeManager.clock;
    final calendar = timeManager.calendar;
    return BridgeCalendarState(
      weekdayLabel: _weekdayLabel(calendar.weekdayIndex),
      monthLabel: _monthLabel(calendar.month),
      season: calendar.season,
      isWeekend: calendar.isWeekend,
      timeLabel: clock.timeLabel,
      context: {
        'dayCount': calendar.dayCount,
        'hour': clock.hour,
        'minute': clock.minute,
      },
    );
  }
}

class BridgeCalendarState {
  const BridgeCalendarState({
    required this.weekdayLabel,
    required this.monthLabel,
    required this.season,
    required this.isWeekend,
    required this.timeLabel,
    required this.context,
  });

  final String weekdayLabel;
  final String monthLabel;
  final String season;
  final bool isWeekend;
  final String timeLabel;
  final Map<String, dynamic> context;
}

String _weekdayLabel(int weekdayIndex) {
  switch (weekdayIndex) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
      return 'Sunday';
    default:
      return 'Unknown';
  }
}

String _monthLabel(int month) {
  switch (month) {
    case 1:
      return 'January';
    case 2:
      return 'February';
    case 3:
      return 'March';
    case 4:
      return 'April';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'August';
    case 9:
      return 'September';
    case 10:
      return 'October';
    case 11:
      return 'November';
    case 12:
      return 'December';
    default:
      return 'Unknown';
  }
}
