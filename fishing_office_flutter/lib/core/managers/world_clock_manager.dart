import 'package:flutter/foundation.dart';

import '../engine/festival_manager.dart';
import '../engine/weather_state.dart';
import '../engine/weather_system.dart';
import '../engine/world_calendar.dart';
import '../engine/world_clock.dart';
import '../../models/living_world_config.dart';

class WorldClockManager extends ChangeNotifier {
  static DateTime systemNow() => DateTime.now();

  static String timestampId() => systemNow().microsecondsSinceEpoch.toString();

  WorldClockManager({
    DateTime Function()? realNow,
    WorldClock? initialClock,
    WorldCalendar? initialCalendar,
    FestivalManager? festivalManager,
    WeatherSystem? weatherSystem,
    double timeScale = 1,
    bool paused = false,
  })  : _realNow = realNow ?? systemNow,
        _realAnchor = (realNow ?? systemNow)(),
        _clockAnchor = initialClock ?? WorldClock.initial(),
        _clock = initialClock ?? WorldClock.initial(),
        _calendar = initialCalendar ?? WorldCalendar.initial(),
        _festivalManager = festivalManager ?? const FestivalManager(),
        _weatherSystem = weatherSystem ?? WeatherSystem(),
        _timeScale = timeScale <= 0 ? 1 : timeScale,
        _paused = paused;

  final DateTime Function() _realNow;
  DateTime _realAnchor;
  WorldClock _clockAnchor;
  WorldClock _clock;
  WorldCalendar _calendar;
  final FestivalManager _festivalManager;
  final WeatherSystem _weatherSystem;
  double _timeScale;
  bool _paused;

  DateTime now() => _realNow();
  WorldCalendar today() => _calendar;
  int hour() => _currentClock().hour;
  int minute() => _currentClock().minute;
  int weekday() => _calendar.weekdayIndex;
  String season() => _calendar.season;
  FestivalState festival() => _festivalManager.resolve(
        calendar: _calendar,
        clock: _currentClock(),
      );
  WeatherState weather() => _weatherSystem.resolve(
        calendar: _calendar,
        clock: _currentClock(),
      );

  WorldClock get clock => _currentClock();
  WorldCalendar get calendar => _calendar;
  double get timeScale => _timeScale;
  bool get paused => _paused;

  WorldClockConfig get config => WorldClockConfig(
        hour: hour(),
        minute: minute(),
        weekday: weekday(),
        month: today().month,
        season: season(),
      );

  WorldClock tick([Duration step = const Duration(minutes: 10)]) {
    _clock = _currentClock().tick(_scaled(step));
    _clockAnchor = _clock;
    _realAnchor = _realNow();
    _syncCalendar();
    notifyListeners();
    return _clock;
  }

  void pause() {
    if (_paused) return;
    _clock = _currentClock();
    _clockAnchor = _clock;
    _realAnchor = _realNow();
    _paused = true;
    notifyListeners();
  }

  void resume() {
    if (!_paused) return;
    _realAnchor = _realNow();
    _clockAnchor = _clock;
    _paused = false;
    notifyListeners();
  }

  void setTimeScale(double value) {
    final next = value <= 0 ? 1.0 : value;
    _clock = _currentClock();
    _clockAnchor = _clock;
    _realAnchor = _realNow();
    _timeScale = next;
    notifyListeners();
  }

  void setClock(WorldClock clock, {WorldCalendar? calendar}) {
    _clock = clock;
    _clockAnchor = clock;
    _calendar = calendar ?? _calendar.copyWith(dayCount: clock.dayCount);
    _realAnchor = _realNow();
    notifyListeners();
  }

  WorldClock _currentClock() {
    if (_paused) return _clock;
    final elapsed = _realNow().difference(_realAnchor);
    if (elapsed.inMilliseconds <= 0) return _clock;
    return _clockAnchor.tick(_scaled(elapsed));
  }

  Duration _scaled(Duration duration) {
    final milliseconds = (duration.inMilliseconds * _timeScale).round();
    return Duration(milliseconds: milliseconds);
  }

  void _syncCalendar() {
    while (_calendar.dayCount < _clock.dayCount) {
      _calendar = _calendar.advance(clock: _clock);
    }
  }
}
