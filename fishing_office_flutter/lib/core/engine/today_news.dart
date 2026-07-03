import 'festival_manager.dart';
import 'today_mood.dart';

class TodayNews {
  const TodayNews({
    required this.newsId,
    required this.headline,
    required this.summary,
    required this.tags,
    required this.context,
  });

  final String newsId;
  final String headline;
  final String summary;
  final List<String> tags;
  final Map<String, dynamic> context;

  factory TodayNews.generate({
    required String worldId,
    required TodayMood mood,
    required List<String> worldEvents,
    required List<String> companionStates,
    required List<String> fishSignals,
    required FestivalState festivalState,
    required Map<String, dynamic> worldData,
  }) {
    final headline = festivalState.hasFestival
        ? '今天，世界正在庆祝。'
        : worldEvents.isNotEmpty
            ? '今天，世界发生了一些事。'
            : '今天，世界安静而平稳。';
    return TodayNews(
      newsId: '${worldId}_${DateTime.now().microsecondsSinceEpoch}',
      headline: headline,
      summary: _buildSummary(
        mood: mood,
        worldEvents: worldEvents,
        companionStates: companionStates,
        fishSignals: fishSignals,
      ),
      tags: [
        ...mood.tags,
        ...worldEvents,
        ...companionStates,
        ...fishSignals,
      ],
      context: {
        'worldId': worldId,
        'festival': festivalState.activeFestivals,
        'worldData': worldData,
      },
    );
  }
}

String _buildSummary({
  required TodayMood mood,
  required List<String> worldEvents,
  required List<String> companionStates,
  required List<String> fishSignals,
}) {
  final parts = <String>[
    mood.description,
    if (worldEvents.isNotEmpty) '世界有${worldEvents.length}个变化。',
    if (companionStates.isNotEmpty) '伙伴正在经历自己的今天。',
    if (fishSignals.isNotEmpty) '鱼群也在悄悄移动。',
  ];
  return parts.join(' ');
}
