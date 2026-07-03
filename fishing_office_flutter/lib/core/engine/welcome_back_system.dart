import 'dart:async';

import 'life_engine.dart';
import 'meaning_engine.dart';
import 'relationship_engine.dart';
import 'today_engine.dart';
import 'world_engine.dart';
import 'welcome_message.dart';

class WelcomeBackSystem {
  WelcomeBackSystem({
    required this.worldEngine,
    required this.todayEngine,
    required this.relationshipEngine,
    required this.lifeEngine,
    required this.meaningEngine,
    List<WelcomeBackListener> listeners = const [],
  }) : _listeners = List<WelcomeBackListener>.from(listeners);

  final WorldEngine worldEngine;
  final TodayEngine todayEngine;
  final RelationshipEngine relationshipEngine;
  final LifeEngine lifeEngine;
  final MeaningEngine meaningEngine;
  final List<WelcomeBackListener> _listeners;
  final StreamController<WelcomeMessage> _welcomeController =
      StreamController<WelcomeMessage>.broadcast();

  Stream<WelcomeMessage> get welcomes => _welcomeController.stream;

  WelcomeMessage buildWelcome({
    required String playerId,
    required DateTime lastLoginAt,
    required DateTime currentLoginAt,
    Map<String, dynamic> context = const {},
  }) {
    final offlineDuration = currentLoginAt.difference(lastLoginAt);
    final summary = OfflineSummary.fromContext(
      worldEngine: worldEngine,
      todayEngine: todayEngine,
      relationshipEngine: relationshipEngine,
      lifeEngine: lifeEngine,
      meaningEngine: meaningEngine,
      offlineDuration: offlineDuration,
      context: context,
    );
    final companionMessage = CompanionReturnMessage.fromSummary(
      playerId: playerId,
      summary: summary,
    );
    final recommendation = ReturnRecommendation.fromSummary(summary);
    final welcome = WelcomeMessage(
      recordId: DateTime.now().microsecondsSinceEpoch.toString(),
      playerId: playerId,
      lastLoginAt: lastLoginAt,
      currentLoginAt: currentLoginAt,
      offlineDuration: offlineDuration,
      worldSummary: summary,
      companionMessage: companionMessage,
      recommendation: recommendation,
      createdAt: currentLoginAt,
    );
    _emit(welcome);
    return welcome;
  }

  void _emit(WelcomeMessage welcome) {
    for (final listener in List<WelcomeBackListener>.from(_listeners)) {
      listener(welcome);
    }
    _welcomeController.add(welcome);
  }

  void addListener(WelcomeBackListener listener) {
    _listeners.add(listener);
  }

  void removeListener(WelcomeBackListener listener) {
    _listeners.remove(listener);
  }

  Future<void> dispose() async {
    await _welcomeController.close();
  }
}

typedef WelcomeBackListener = void Function(WelcomeMessage welcome);
