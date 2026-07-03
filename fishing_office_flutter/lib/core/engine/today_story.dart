import 'today_mood.dart';
import 'today_news.dart';
import 'today_recommendation.dart';

class TodayStory {
  const TodayStory({
    required this.todayId,
    required this.worldId,
    required this.timeLabel,
    required this.mood,
    required this.news,
    required this.recommendation,
    required this.worldEvents,
    required this.companionStates,
    required this.fishSignals,
    required this.generatedAt,
    required this.context,
  });

  final String todayId;
  final String worldId;
  final String timeLabel;
  final TodayMood mood;
  final TodayNews news;
  final TodayRecommendation recommendation;
  final List<String> worldEvents;
  final List<String> companionStates;
  final List<String> fishSignals;
  final DateTime generatedAt;
  final Map<String, dynamic> context;
}
