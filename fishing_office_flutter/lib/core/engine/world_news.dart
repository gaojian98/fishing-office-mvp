import 'world_clock.dart';

class WorldNews {
  const WorldNews({
    required this.newsId,
    required this.title,
    required this.summary,
    required this.time,
    required this.context,
    required this.createdAt,
  });

  final String newsId;
  final String title;
  final String summary;
  final WorldClock time;
  final Map<String, dynamic> context;
  final DateTime createdAt;
}
