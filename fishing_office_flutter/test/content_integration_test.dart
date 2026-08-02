import 'dart:convert';
import 'dart:io';

import 'package:fishing_office_mvp/models/interactive_office.dart';
import 'package:fishing_office_mvp/models/resident_dialogue_config.dart';
import 'package:fishing_office_mvp/models/rumor_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> loadConfig(String name) {
    return jsonDecode(
      File('assets/config/$name').readAsStringSync(),
    ) as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> list(String file, String key) {
    return (loadConfig(file)[key] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  test('module 04 content pack has complete counts and unique ids', () {
    final residents = list('resident.json', 'residents');
    final dialogues = list('resident_dialogue.json', 'dialogues');
    final stories = list('resident_story.json', 'stories');
    final rumors = list('rumor.json', 'rumors');
    final events = list('events.json', 'events');

    expect(residents.length, 100);
    expect(dialogues.length, greaterThanOrEqualTo(2620));
    expect(stories.length, greaterThanOrEqualTo(1320));
    expect(rumors.length, 300);
    expect(events.length, greaterThanOrEqualTo(120));

    for (final entry in <String, List<Map<String, dynamic>>>{
      'resident': residents,
      'dialogue': dialogues,
      'story': stories,
      'rumor': rumors,
      'event': events,
    }.entries) {
      final ids = entry.value
          .map((item) => item['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList(growable: false);
      expect(ids.toSet().length, ids.length, reason: entry.key);
    }
  });

  test('module 04 content references remain valid', () {
    final residentIds =
        list('resident.json', 'residents').map((item) => item['id']).toSet();
    final fishIds =
        list('fish_catalog.json', 'fish').map((item) => item['id']).toSet();
    final rumorIds =
        list('rumor.json', 'rumors').map((item) => item['id']).toSet();
    final dialogueIds = list('resident_dialogue.json', 'dialogues')
        .map((item) => item['id'])
        .toSet();

    for (final dialogue in list('resident_dialogue.json', 'dialogues')) {
      final residentId = dialogue['residentId']?.toString() ?? '';
      expect(residentId == '*' || residentIds.contains(residentId), isTrue);
    }
    for (final story in list('resident_story.json', 'stories')) {
      final residentId = story['residentId']?.toString() ?? '';
      expect(residentId == '*' || residentIds.contains(residentId), isTrue);
      for (final dialogueId in (story['dialogueIds'] as List? ?? const [])) {
        expect(dialogueIds.contains(dialogueId), isTrue);
      }
    }
    for (final rumor in list('rumor.json', 'rumors')) {
      final residentId = rumor['relatedResidentId']?.toString() ?? '';
      final fishId = rumor['relatedFishId']?.toString() ?? '';
      expect(residentId.isEmpty || residentIds.contains(residentId), isTrue);
      expect(fishId.isEmpty || fishIds.contains(fishId), isTrue);
    }
    for (final event in list('events.json', 'events')) {
      final conditions = event['conditions'] as Map? ?? const {};
      for (final residentId
          in (conditions['residentId'] as List? ?? const [])) {
        expect(residentIds.contains(residentId), isTrue);
      }
      for (final choice in (event['choices'] as List? ?? const [])) {
        final result = (choice as Map)['result'] as Map? ?? const {};
        for (final rumorId in (result['rumorIds'] as List? ?? const [])) {
          expect(rumorIds.contains(rumorId), isTrue);
        }
      }
    }
  });

  test('interaction feedback content covers all action types', () {
    final dialogues = list('resident_dialogue.json', 'dialogues');
    final interactionDialogues = dialogues
        .where((item) => (item['actionType']?.toString() ?? '').isNotEmpty)
        .toList(growable: false);
    const requiredActions = <String>{
      'talk',
      'short_talk',
      'invite_coffee',
      'help_work',
      'join_break',
      'comfort',
      'share_rumor',
      'ask_about_rumor',
      'verify_rumor',
      'share_fish',
      'remember_preference',
      'apologize',
      'resolve_conflict',
      'observe',
      'start_story',
      'join_group',
    };
    final covered = interactionDialogues
        .map((item) => item['actionType']?.toString() ?? '')
        .toSet();

    expect(interactionDialogues.length, greaterThanOrEqualTo(150));
    expect(covered, containsAll(requiredActions));
    for (final item in interactionDialogues) {
      expect((item['text']?.toString() ?? '').trim(), isNotEmpty);
      expect((item['response']?.toString() ?? '').trim(), isNotEmpty);
      expect(item['conditions'], isA<Map>());
      expect(item['cooldownGroup'], item['actionType']);
      expect(item['weight'], isA<int>());
    }

    final config = ResidentDialogueConfig.fromJson(
      loadConfig('resident_dialogue.json'),
    );
    final parsed = config.dialogues.firstWhere(
      (item) => item.actionType == 'share_fish',
    );
    expect(parsed.response, contains('鱼'));
    expect(parsed.cooldownGroup, 'share_fish');
    expect(parsed.weight, greaterThan(0));
  });

  test('dialogue story rumor event content has broad condition coverage', () {
    final dialogues = list('resident_dialogue.json', 'dialogues');
    final stories = list('resident_story.json', 'stories');
    final events = list('events.json', 'events');
    final rumors = list('rumor.json', 'rumors');

    Set<String> nonEmptyConditionValues(
      List<Map<String, dynamic>> items,
      String key,
    ) {
      final values = <String>{};
      for (final item in items) {
        final conditions = item['conditions'] as Map? ?? const {};
        final raw = conditions[key];
        if (raw is List) {
          values.addAll(raw.map((item) => item.toString()));
        } else if (raw != null && raw.toString().isNotEmpty) {
          values.addAll(raw.toString().split(',').map((item) => item.trim()));
        }
      }
      values.removeWhere((item) => item.isEmpty || item == 'any');
      return values;
    }

    expect(nonEmptyConditionValues(dialogues, 'timeOfDay').length,
        greaterThanOrEqualTo(6));
    expect(
        nonEmptyConditionValues(dialogues, 'residentLocation').length +
            nonEmptyConditionValues(dialogues, 'location').length,
        greaterThanOrEqualTo(12));
    expect(nonEmptyConditionValues(dialogues, 'weather'), isNotEmpty);
    expect(nonEmptyConditionValues(dialogues, 'festival'), isNotEmpty);
    expect(nonEmptyConditionValues(dialogues, 'personalityTags').length,
        greaterThanOrEqualTo(10));
    expect(nonEmptyConditionValues(dialogues, 'officeMood').length,
        greaterThanOrEqualTo(8));
    expect(nonEmptyConditionValues(stories, 'weather'), isNotEmpty);
    expect(nonEmptyConditionValues(stories, 'festival'), isNotEmpty);
    expect(nonEmptyConditionValues(events, 'location').length,
        greaterThanOrEqualTo(10));
    expect(events.where((item) => (item['choices'] as List).isNotEmpty).length,
        events.length);
    expect(rumors.every((item) => item.containsKey('truthState')), isTrue);
    expect(rumors.every((item) => item.containsKey('spreadRules')), isTrue);
    expect(rumors.every((item) => item.containsKey('expireRules')), isTrue);
  });

  test('formal copy has no blanks, placeholders, or exact duplicate dialogue',
      () {
    final forbidden = RegExp(
      r'\\b(TODO|placeholder|mock|unknown|null|runtime|condition failed|minimumTrust|not available)\\b',
      caseSensitive: false,
    );
    final dialogueTexts = <String>{};
    for (final dialogue in list('resident_dialogue.json', 'dialogues')) {
      final text = dialogue['text']?.toString().trim() ?? '';
      expect(text, isNotEmpty);
      expect(forbidden.hasMatch(text), isFalse, reason: dialogue['id']);
      expect(dialogueTexts.add(text), isTrue, reason: dialogue['id']);
    }
    for (final story in list('resident_story.json', 'stories')) {
      expect(story['title']?.toString().trim(), isNotEmpty);
      expect(story['summary']?.toString().trim(), isNotEmpty);
      expect(forbidden.hasMatch(story['title'].toString()), isFalse);
      expect(forbidden.hasMatch(story['summary'].toString()), isFalse);
    }
    for (final event in list('events.json', 'events')) {
      expect(event['title']?.toString().trim(), isNotEmpty);
      expect(forbidden.hasMatch(event['title'].toString()), isFalse);
    }
  });

  test('product labels expose career skill and reputation in Chinese', () {
    const reputations = <String>[
      'reliable',
      'helpful',
      'funny',
      'professional',
      'popular',
      'quiet',
      'mysterious',
      'hardworking',
      'relaxed',
      'late_comer',
      'fishing_master',
      'rumor_keeper',
      'team_player',
      'problem_solver',
      'trusted_friend',
    ];
    for (final reputation in reputations) {
      expect(InteractiveOfficeLabels.reputation(reputation), isNot(reputation));
    }
    for (final skill in const <String>[
      'fishing',
      'communication',
      'observation',
      'efficiency',
      'management',
      'luck',
    ]) {
      expect(InteractiveOfficeLabels.skill(skill), isNot(skill));
    }
    for (final action in const <String>[
      'talk',
      'share_rumor',
      'verify_rumor',
      'share_fish',
      'join_group',
    ]) {
      expect(InteractiveOfficeLabels.action(action), isNot(action));
      expect(InteractiveOfficeLabels.actionDescription(action), isNotEmpty);
      expect(InteractiveOfficeLabels.actionImpact(action), isNotEmpty);
    }
    final rumor = RumorConfig.fromJson(loadConfig('rumor.json')).rumors.first;
    expect(rumor.summary, isNotEmpty);
    expect(rumor.truthState, isNotEmpty);
    expect(rumor.spreadRules, isNotEmpty);
    expect(rumor.expireRules, isNotEmpty);
  });
}
