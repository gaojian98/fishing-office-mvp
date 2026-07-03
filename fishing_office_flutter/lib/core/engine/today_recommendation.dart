import 'festival_manager.dart';
import 'today_mood.dart';

class TodayRecommendation {
  const TodayRecommendation({
    required this.title,
    required this.description,
    required this.tags,
    required this.context,
  });

  final String title;
  final String description;
  final List<String> tags;
  final Map<String, dynamic> context;

  factory TodayRecommendation.generate({
    required TodayMood mood,
    required FestivalState festivalState,
    required List<String> worldEvents,
    required List<String> companionStates,
    required List<String> fishSignals,
  }) {
    final title = festivalState.hasFestival
        ? '今天适合慢慢待着'
        : mood.name == 'Quiet'
            ? '今天适合安静等待'
            : '今天适合看看世界';
    return TodayRecommendation(
      title: title,
      description: _buildDescription(
        mood: mood,
        festivalState: festivalState,
        worldEvents: worldEvents,
        companionStates: companionStates,
        fishSignals: fishSignals,
      ),
      tags: [
        mood.name,
        if (festivalState.hasFestival) ...festivalState.activeFestivals,
        ...worldEvents,
        ...companionStates,
        ...fishSignals,
      ],
      context: {
        'timeLabel': mood.context['timeLabel'],
        'isWeekend': festivalState.isWeekend,
      },
    );
  }
}

String _buildDescription({
  required TodayMood mood,
  required FestivalState festivalState,
  required List<String> worldEvents,
  required List<String> companionStates,
  required List<String> fishSignals,
}) {
  if (festivalState.hasFestival) {
    return '今天的世界带着节日感，适合陪伴与观察。';
  }
  if (worldEvents.isNotEmpty) {
    return '今天有一些变化，适合留意世界的呼吸。';
  }
  if (companionStates.isNotEmpty) {
    return '今天适合看看伙伴的状态。';
  }
  if (fishSignals.isNotEmpty) {
    return '今天鱼群很活跃，适合等待。';
  }
  return '今天适合保持耐心，看看会发生什么。';
}
