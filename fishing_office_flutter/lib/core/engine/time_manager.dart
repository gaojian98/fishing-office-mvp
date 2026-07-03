import 'festival_manager.dart';
import 'world_calendar.dart';
import 'world_clock.dart';

class TimeManager {
  TimeManager({
    WorldClock? initialClock,
    WorldCalendar? calendar,
    FestivalManager? festivalManager,
  })  : clock = initialClock ?? WorldClock.initial(),
        calendar = calendar ?? WorldCalendar.initial(),
        festivalManager = festivalManager ?? const FestivalManager();

  WorldClock clock;
  WorldCalendar calendar;
  final FestivalManager festivalManager;

  WorldClock tick([Duration step = const Duration(minutes: 10)]) {
    clock = clock.tick(step);
    calendar = calendar.advance(clock: clock);
    return clock;
  }

  bool get isWorkLoop => calendar.isWorkLoop(clock);

  WorldCalendar nextDay() {
    calendar = calendar.nextDay(clock: clock);
    return calendar;
  }

  FestivalState festivalState() {
    return festivalManager.resolve(calendar: calendar, clock: clock);
  }
}
