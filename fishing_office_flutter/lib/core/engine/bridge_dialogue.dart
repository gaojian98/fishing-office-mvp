import 'bridge_calendar.dart';
import 'bridge_festival.dart';
import 'bridge_weather.dart';

class BridgeDialogue {
  const BridgeDialogue({
    required this.dialogueId,
    required this.playerId,
    required this.message,
    required this.calendar,
    required this.festival,
    required this.weather,
    required this.publicContext,
    required this.createdAt,
  });

  factory BridgeDialogue.fromContext({
    required String playerId,
    required BridgeCalendarState calendar,
    required BridgeFestivalState festival,
    required BridgeWeatherState weather,
    required Map<String, dynamic> publicContext,
  }) {
    return BridgeDialogue(
      dialogueId: DateTime.now().microsecondsSinceEpoch.toString(),
      playerId: playerId,
      message: _buildMessage(calendar, festival, weather),
      calendar: calendar,
      festival: festival,
      weather: weather,
      publicContext: publicContext,
      createdAt: DateTime.now(),
    );
  }

  final String dialogueId;
  final String playerId;
  final String message;
  final BridgeCalendarState calendar;
  final BridgeFestivalState festival;
  final BridgeWeatherState weather;
  final Map<String, dynamic> publicContext;
  final DateTime createdAt;
}

String _buildMessage(
  BridgeCalendarState calendar,
  BridgeFestivalState festival,
  BridgeWeatherState weather,
) {
  if (calendar.weekdayLabel == 'Monday') {
    return '欢迎回来，今天先别急，海一直都在。';
  }
  if (calendar.weekdayLabel == 'Friday') {
    return '欢迎回来，周末快到了，先看看今天的海。';
  }
  if (festival.activeFestivals.isNotEmpty) {
    return '今天世界在庆祝，海边也有一点热闹。';
  }
  return weather.headline;
}
