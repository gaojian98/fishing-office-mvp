import 'identity_manager.dart';
import 'meaning_choice_record.dart';

class StoryGenerator {
  const StoryGenerator();

  MeaningStory generate({
    required String playerId,
    required List<MeaningChoiceRecord> choices,
    required IdentityProfile identity,
    Map<String, dynamic> context = const {},
  }) {
    return MeaningStory(
      storyId: DateTime.now().microsecondsSinceEpoch.toString(),
      playerId: playerId,
      title: _buildTitle(choices),
      summary: _buildSummary(choices, identity),
      identityTags: identity.tags,
      choices: choices,
      context: context,
      createdAt: DateTime.now(),
    );
  }

  String _buildTitle(List<MeaningChoiceRecord> choices) {
    if (choices.isEmpty) return '未命名故事';
    return '《${choices.last.choiceLabel}》';
  }

  String _buildSummary(
    List<MeaningChoiceRecord> choices,
    IdentityProfile identity,
  ) {
    if (choices.isEmpty) return '一段尚未展开的经历。';
    return '基于${choices.length}次选择形成的${identity.primaryLabel}。';
  }
}

class MeaningStory {
  const MeaningStory({
    required this.storyId,
    required this.playerId,
    required this.title,
    required this.summary,
    required this.identityTags,
    required this.choices,
    required this.context,
    required this.createdAt,
  });

  final String storyId;
  final String playerId;
  final String title;
  final String summary;
  final List<String> identityTags;
  final List<MeaningChoiceRecord> choices;
  final Map<String, dynamic> context;
  final DateTime createdAt;
}
