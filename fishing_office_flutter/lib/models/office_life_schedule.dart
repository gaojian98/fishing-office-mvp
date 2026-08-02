class OfficeLifeSchedule {
  const OfficeLifeSchedule({
    required this.phase,
    required this.isWorking,
    required this.isOnBreak,
    required this.isOvertime,
    required this.isWeekend,
    required this.nextLocation,
    required this.nextActivity,
    required this.nextChangeTime,
    required this.reason,
  });

  final String phase;
  final bool isWorking;
  final bool isOnBreak;
  final bool isOvertime;
  final bool isWeekend;
  final String nextLocation;
  final String nextActivity;
  final String nextChangeTime;
  final String reason;

  static const phases = <String>{
    'morning',
    'commute',
    'work_start',
    'working',
    'coffee_break',
    'lunch',
    'afternoon_work',
    'overtime',
    'off_work',
    'evening',
    'home',
    'sleep',
    'weekend',
    'holiday',
  };

  factory OfficeLifeSchedule.fromRaw({
    required String rawPhase,
    required int hour,
    required int minute,
    required int weekday,
    required String location,
    required String activity,
    required String startTime,
    required String endTime,
    String reason = 'schedule',
  }) {
    final phase = normalizePhase(
      rawPhase: rawPhase,
      hour: hour,
      weekday: weekday,
    );
    final weekend = weekday == 6 || weekday == 7 || phase == 'weekend';
    return OfficeLifeSchedule(
      phase: phase,
      isWorking: _isWorking(phase),
      isOnBreak: _isOnBreak(phase),
      isOvertime: phase == 'overtime',
      isWeekend: weekend,
      nextLocation: location,
      nextActivity: activity,
      nextChangeTime: endTime.isEmpty ? nextBoundary(hour, minute) : endTime,
      reason: reason,
    );
  }

  static String normalizePhase({
    required String rawPhase,
    required int hour,
    required int weekday,
  }) {
    final raw = rawPhase.toLowerCase();
    if (raw.contains('holiday')) return 'holiday';
    if (weekday == 6 || weekday == 7) return 'weekend';
    if (raw.contains('morning')) return 'morning';
    if (raw.contains('commute')) return 'commute';
    if (raw.contains('start')) return 'work_start';
    if (raw.contains('coffee') || raw.contains('break')) {
      return 'coffee_break';
    }
    if (raw.contains('lunch') || raw.contains('noon')) return 'lunch';
    if (raw.contains('afternoon')) return 'afternoon_work';
    if (raw.contains('overtime')) return 'overtime';
    if (raw.contains('off')) return 'off_work';
    if (raw.contains('evening')) return 'evening';
    if (raw.contains('home')) return 'home';
    if (raw.contains('night') || raw.contains('sleep')) return 'sleep';
    if (hour >= 0 && hour < 6) return 'sleep';
    if (hour >= 6 && hour < 7) return 'morning';
    if (hour >= 7 && hour < 8) return 'commute';
    if (hour >= 8 && hour < 9) return 'work_start';
    if (hour >= 9 && hour < 11) return 'working';
    if (hour >= 11 && hour < 12) return 'coffee_break';
    if (hour >= 12 && hour < 14) return 'lunch';
    if (hour >= 14 && hour < 17) return 'afternoon_work';
    if (hour >= 17 && hour < 18) return 'off_work';
    if (hour >= 18 && hour < 21) return 'evening';
    if (hour >= 21 && hour < 22) return 'home';
    return 'sleep';
  }

  static String nextBoundary(int hour, int minute) {
    final nextHour = switch (normalizePhase(
      rawPhase: '',
      hour: hour,
      weekday: 1,
    )) {
      'sleep' => hour < 6 ? 6 : 24,
      'morning' => 7,
      'commute' => 8,
      'work_start' => 9,
      'working' => 11,
      'coffee_break' => 12,
      'lunch' => 14,
      'afternoon_work' => 17,
      'off_work' => 18,
      'evening' => 21,
      'home' => 22,
      _ => (hour + 1).clamp(0, 24),
    };
    return _formatMinute(nextHour * 60);
  }

  static String _formatMinute(int totalMinutes) {
    final normalized = totalMinutes % (24 * 60);
    final hour = normalized ~/ 60;
    final minute = normalized % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  static bool _isWorking(String phase) {
    return phase == 'work_start' ||
        phase == 'working' ||
        phase == 'afternoon_work' ||
        phase == 'overtime';
  }

  static bool _isOnBreak(String phase) {
    return phase == 'coffee_break' ||
        phase == 'lunch' ||
        phase == 'off_work' ||
        phase == 'weekend' ||
        phase == 'holiday';
  }
}
