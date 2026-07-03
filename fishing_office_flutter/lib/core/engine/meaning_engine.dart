import 'dart:async';

import 'identity_manager.dart';
import 'legacy_manager.dart';
import 'meaning_choice_record.dart';
import 'story_generator.dart';

typedef MeaningEngineListener = void Function(MeaningChoiceRecord choice);

class MeaningEngine {
  MeaningEngine({
    StoryGenerator? storyGenerator,
    IdentityManager? identityManager,
    LegacyManager? legacyManager,
    List<MeaningEngineListener> listeners = const [],
  })  : storyGenerator = storyGenerator ?? const StoryGenerator(),
        identityManager = identityManager ?? const IdentityManager(),
        legacyManager = legacyManager ?? const LegacyManager(),
        _listeners = List<MeaningEngineListener>.from(listeners);

  final StoryGenerator storyGenerator;
  final IdentityManager identityManager;
  final LegacyManager legacyManager;
  final List<MeaningEngineListener> _listeners;
  final StreamController<MeaningChoiceRecord> _choiceController =
      StreamController<MeaningChoiceRecord>.broadcast();

  Stream<MeaningChoiceRecord> get choices => _choiceController.stream;

  MeaningChoiceRecord recordChoice({
    required String playerId,
    required String eventId,
    required String choiceType,
    required String choiceLabel,
    required Map<String, dynamic> context,
  }) {
    final record = MeaningChoiceRecord(
      choiceId: DateTime.now().microsecondsSinceEpoch.toString(),
      playerId: playerId,
      eventId: eventId,
      choiceType: choiceType,
      choiceLabel: choiceLabel,
      context: context,
      createdAt: DateTime.now(),
    );
    emit(record);
    return record;
  }

  void emit(MeaningChoiceRecord record) {
    for (final listener in List<MeaningEngineListener>.from(_listeners)) {
      listener(record);
    }
    _choiceController.add(record);
  }

  Future<void> dispose() async {
    await _choiceController.close();
  }
}
