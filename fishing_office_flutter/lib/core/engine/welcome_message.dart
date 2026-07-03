import 'life_engine.dart';
import 'meaning_engine.dart';
import 'relationship_engine.dart';
import 'today_engine.dart';
import 'world_engine.dart';

class WelcomeMessage {
  const WelcomeMessage({
    required this.recordId,
    required this.playerId,
    required this.lastLoginAt,
    required this.currentLoginAt,
    required this.offlineDuration,
    required this.worldSummary,
    required this.companionMessage,
    required this.recommendation,
    required this.createdAt,
    this.seenAt,
  });

  final String recordId;
  final String playerId;
  final DateTime lastLoginAt;
  final DateTime currentLoginAt;
  final Duration offlineDuration;
  final OfflineSummary worldSummary;
  final CompanionReturnMessage companionMessage;
  final ReturnRecommendation recommendation;
  final DateTime createdAt;
  final DateTime? seenAt;
}

class OfflineSummary {
  const OfflineSummary({
    required this.title,
    required this.summary,
    required this.durationLabel,
    required this.tags,
    required this.context,
  });

  final String title;
  final String summary;
  final String durationLabel;
  final List<String> tags;
  final Map<String, dynamic> context;

  factory OfflineSummary.fromContext({
    required WorldEngine worldEngine,
    required TodayEngine todayEngine,
    required RelationshipEngine relationshipEngine,
    required LifeEngine lifeEngine,
    required MeaningEngine meaningEngine,
    required Duration offlineDuration,
    Map<String, dynamic> context = const {},
  }) {
    final title = _buildTitle(offlineDuration);
    final summary = _buildSummary(worldEngine, todayEngine, offlineDuration);
    return OfflineSummary(
      title: title,
      summary: summary,
      durationLabel: _formatDuration(offlineDuration),
      tags: [
        worldEngine.state.clock.timeLabel,
        todayEngine.timeManager.clock.timeLabel,
      ],
      context: context,
    );
  }
}

class CompanionReturnMessage {
  const CompanionReturnMessage({
    required this.playerId,
    required this.message,
    required this.tags,
    required this.context,
  });

  final String playerId;
  final String message;
  final List<String> tags;
  final Map<String, dynamic> context;

  factory CompanionReturnMessage.fromSummary({
    required String playerId,
    required OfflineSummary summary,
  }) {
    return CompanionReturnMessage(
      playerId: playerId,
      message: _buildCompanionMessage(summary),
      tags: summary.tags,
      context: summary.context,
    );
  }
}

class ReturnRecommendation {
  const ReturnRecommendation({
    required this.title,
    required this.description,
    required this.tags,
    required this.context,
  });

  final String title;
  final String description;
  final List<String> tags;
  final Map<String, dynamic> context;

  factory ReturnRecommendation.fromSummary(OfflineSummary summary) {
    return ReturnRecommendation(
      title: '看看今天的世界',
      description: summary.summary,
      tags: summary.tags,
      context: summary.context,
    );
  }
}

String _buildTitle(Duration offlineDuration) {
  if (offlineDuration.inHours < 12) return '欢迎回来';
  if (offlineDuration.inDays < 2) return '你回来得正好';
  if (offlineDuration.inDays < 7) return '第二世界一直记得你';
  return '世界等你很久了';
}

String _buildSummary(
  WorldEngine worldEngine,
  TodayEngine todayEngine,
  Duration offlineDuration,
) {
  final world = worldEngine.state;
  final today = todayEngine.generateToday(worldId: world.worldId);
  return [
    '离开了${_formatDuration(offlineDuration)}。',
    '今天：${today.mood.description}',
    '世界状态：${world.clock.timeLabel}，${world.weather.join('、')}。',
  ].join(' ');
}

String _buildCompanionMessage(OfflineSummary summary) {
  if (summary.durationLabel.contains('天')) {
    return '你回来了，我一直记得你。';
  }
  if (summary.durationLabel.contains('小时')) {
    return '海风还在，鱼漂也还在。';
  }
  return '欢迎回来。';
}

String _formatDuration(Duration duration) {
  if (duration.inDays >= 1) return '${duration.inDays}天';
  if (duration.inHours >= 1) return '${duration.inHours}小时';
  return '${duration.inMinutes}分钟';
}
