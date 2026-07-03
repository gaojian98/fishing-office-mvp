import 'festival_manager.dart';

class TodayMood {
  const TodayMood({
    required this.name,
    required this.description,
    required this.tags,
    required this.context,
  });

  final String name;
  final String description;
  final List<String> tags;
  final Map<String, dynamic> context;

  factory TodayMood.resolve({
    required String timeLabel,
    required FestivalState festivalState,
    required List<String> weatherTags,
    required List<String> companionStates,
    required List<String> fishSignals,
  }) {
    final isWeekend = festivalState.isWeekend;
    final hasFestival = festivalState.hasFestival;
    final baseName = hasFestival
        ? 'Festive'
        : isWeekend
            ? 'Relaxed'
            : timeLabel == 'Night'
                ? 'Quiet'
                : 'Calm';
    final tags = <String>[
      timeLabel,
      if (isWeekend) 'Weekend',
      if (hasFestival) ...festivalState.activeFestivals,
      ...weatherTags,
      ...companionStates,
      ...fishSignals,
    ];
    return TodayMood(
      name: baseName,
      description: _buildDescription(
        baseName,
        timeLabel,
        isWeekend,
        hasFestival,
      ),
      tags: tags,
      context: {
        'timeLabel': timeLabel,
        'isWeekend': isWeekend,
        'festivals': festivalState.activeFestivals,
      },
    );
  }
}

String _buildDescription(
  String baseName,
  String timeLabel,
  bool isWeekend,
  bool hasFestival,
) {
  if (hasFestival) return '今天的世界有节日气息。';
  if (isWeekend) return '今天更适合慢慢呼吸。';
  if (timeLabel == 'Night') return '今天的夜晚安静而漫长。';
  return '今天的第二世界在轻轻变化。';
}
