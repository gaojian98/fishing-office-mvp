import 'world_calendar.dart';
import 'world_clock.dart';

class FestivalManager {
  const FestivalManager();

  FestivalState resolve({
    required WorldCalendar calendar,
    required WorldClock clock,
  }) {
    final festivals = <String>[];
    if (calendar.month == 1 && calendar.day == 1) festivals.add('new_year');
    if (calendar.month == 2 && calendar.day <= 10) festivals.add('tet');
    if (calendar.month == 12 && calendar.day == 25) festivals.add('christmas');
    if (calendar.month == 1 && calendar.day == 1) festivals.add('spring_festival');
    return FestivalState(
      activeFestivals: festivals,
      timeLabel: clock.timeLabel,
      isWeekend: calendar.isWeekend,
    );
  }
}

class FestivalState {
  const FestivalState({
    required this.activeFestivals,
    required this.timeLabel,
    required this.isWeekend,
  });

  final List<String> activeFestivals;
  final String timeLabel;
  final bool isWeekend;

  bool get hasFestival => activeFestivals.isNotEmpty;
}
