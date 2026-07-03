class MeaningChoiceRecord {
  const MeaningChoiceRecord({
    required this.choiceId,
    required this.playerId,
    required this.eventId,
    required this.choiceType,
    required this.choiceLabel,
    required this.context,
    required this.createdAt,
  });

  final String choiceId;
  final String playerId;
  final String eventId;
  final String choiceType;
  final String choiceLabel;
  final Map<String, dynamic> context;
  final DateTime createdAt;
}
