import 'bridge_calendar.dart';

class BridgeFestival {
  const BridgeFestival();

  BridgeFestivalState resolve({
    required BridgeCalendarState calendar,
  }) {
    final festivals = <String>[];
    if (calendar.weekdayLabel == 'Monday') festivals.add('MondayCalm');
    if (calendar.weekdayLabel == 'Friday') festivals.add('FridayHope');
    if (calendar.isWeekend) festivals.add('Weekend');
    return BridgeFestivalState(
      activeFestivals: festivals,
      title: festivals.isEmpty ? 'OrdinaryDay' : festivals.first,
      message: _buildMessage(calendar),
      context: {
        'weekdayLabel': calendar.weekdayLabel,
        'season': calendar.season,
      },
    );
  }
}

class BridgeFestivalState {
  const BridgeFestivalState({
    required this.activeFestivals,
    required this.title,
    required this.message,
    required this.context,
  });

  final List<String> activeFestivals;
  final String title;
  final String message;
  final Map<String, dynamic> context;
}

String _buildMessage(BridgeCalendarState calendar) {
  if (calendar.weekdayLabel == 'Monday') {
    return '今天先慢一点，世界会陪着你。';
  }
  if (calendar.weekdayLabel == 'Friday') {
    return '周末快到了，海边已经在等你。';
  }
  if (calendar.isWeekend) {
    return '今天适合慢慢钓鱼，慢慢呼吸。';
  }
  return '今天也可以和第二世界轻轻相遇。';
}
