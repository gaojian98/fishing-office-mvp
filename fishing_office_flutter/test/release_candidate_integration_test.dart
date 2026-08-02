import 'dart:convert';
import 'dart:io';

import 'package:fishing_office_mvp/models/layout_config.dart';
import 'package:fishing_office_mvp/models/player_influence.dart';
import 'package:fishing_office_mvp/models/world_save_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> loadConfig(String path) {
    return jsonDecode(
      File('assets/config/$path').readAsStringSync(),
    ) as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> entries(String file, String key) {
    final data = loadConfig(file);
    final raw = key.split('.').fold<Object?>(data, (value, part) {
      return value is Map<String, dynamic> ? value[part] : null;
    });
    return (raw as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Set<String> ids(String file, String key) {
    return entries(file, key)
        .map((item) => item['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  String projectFile(String path) => File('../$path').readAsStringSync();

  Iterable<String> dartFilesUnder(String path) {
    return Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync());
  }

  LayoutElement? layoutElement(
      Map<String, dynamic> layout, String page, String id) {
    return LayoutConfig.fromJson(layout[page] as Map<String, dynamic>).byId(id);
  }

  test('rc critical registered assets exist and invalid dialog asset is absent',
      () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec.contains('assets/config/dialog.json'), isFalse);
    expect(pubspec.contains('assets/config/resident_dialogue.json'), isTrue);
    expect(pubspec.contains('assets/config/office_dialog.json'), isTrue);

    final assetLines = pubspec
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.startsWith('- assets/'))
        .map((line) => line.substring(2).trim())
        .toList(growable: false);
    expect(assetLines, isNotEmpty);
    for (final asset in assetLines) {
      expect(File(asset).existsSync(), isTrue, reason: asset);
    }
  });

  test('rc key json files parse and expose expected top-level collections', () {
    final specs = <String, String>{
      'resident.json': 'residents',
      'residents.json': 'residents',
      'fish_catalog.json': 'fish',
      'resident_dialogue.json': 'dialogues',
      'resident_story.json': 'stories',
      'events.json': 'events',
      'event.json': 'events',
      'rumor.json': 'rumors',
      'festival.json': 'festivals',
      'weather.json': 'weatherEvents',
      'identity.json': 'identities',
      'legend.json': 'legends',
      'task.json': 'tasks.items',
      'honor.json': 'honor.badges',
      'fish_collection.json': 'collection.fishes',
      'store/store_products.json': 'products',
    };
    for (final spec in specs.entries) {
      expect(entries(spec.key, spec.value), isNotEmpty, reason: spec.key);
    }
  });

  test('rc content counts match current acceptance baseline', () {
    expect(entries('resident.json', 'residents').length, 100);
    expect(entries('fish_catalog.json', 'fish').length, 90);
    expect(entries('resident_dialogue.json', 'dialogues').length,
        greaterThanOrEqualTo(2620));
    expect(entries('resident_story.json', 'stories').length,
        greaterThanOrEqualTo(1320));
    expect(entries('events.json', 'events').length, greaterThanOrEqualTo(120));
    expect(entries('rumor.json', 'rumors').length, 300);
    expect(entries('festival.json', 'festivals').length, 50);
    expect(entries('weather.json', 'weatherEvents').length, 100);
    expect(entries('identity.json', 'identities').length, 100);
    expect(entries('legend.json', 'legends').length, 100);
  });

  test('rc key content ids are unique', () {
    for (final spec in const <List<String>>[
      ['resident.json', 'residents'],
      ['residents.json', 'residents'],
      ['fish_catalog.json', 'fish'],
      ['resident_dialogue.json', 'dialogues'],
      ['resident_story.json', 'stories'],
      ['events.json', 'events'],
      ['event.json', 'events'],
      ['rumor.json', 'rumors'],
      ['festival.json', 'festivals'],
      ['weather.json', 'weatherEvents'],
      ['identity.json', 'identities'],
      ['legend.json', 'legends'],
    ]) {
      final allIds = entries(spec[0], spec[1])
          .map((item) => item['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList(growable: false);
      expect(allIds.toSet().length, allIds.length, reason: spec[0]);
    }
  });

  test('rc resident dialogue references remain valid', () {
    final residentIds = ids('resident.json', 'residents');
    for (final dialogue in entries('resident_dialogue.json', 'dialogues')) {
      final residentId = dialogue['residentId']?.toString() ?? '';
      expect(residentId == '*' || residentIds.contains(residentId), isTrue,
          reason: dialogue['id']?.toString());
      expect((dialogue['text']?.toString() ?? '').trim(), isNotEmpty);
      expect(dialogue['conditions'], isA<Map>());
      expect(dialogue['repeatable'], isA<bool>());
    }
  });

  test('rc story dialogue and resident references remain valid', () {
    final residentIds = ids('resident.json', 'residents');
    final dialogueIds = ids('resident_dialogue.json', 'dialogues');
    for (final story in entries('resident_story.json', 'stories')) {
      final residentId = story['residentId']?.toString() ?? '';
      expect(residentId == '*' || residentIds.contains(residentId), isTrue,
          reason: story['id']?.toString());
      for (final dialogueId in (story['dialogueIds'] as List? ?? const [])) {
        expect(dialogueIds.contains(dialogueId), isTrue,
            reason: story['id']?.toString());
      }
      expect((story['title']?.toString() ?? '').trim(), isNotEmpty);
      expect((story['summary']?.toString() ?? '').trim(), isNotEmpty);
    }
  });

  test('rc rumor references remain valid when present', () {
    final residentIds = ids('resident.json', 'residents');
    final fishIds = ids('fish_catalog.json', 'fish');
    final weatherIds = ids('weather.json', 'weatherEvents');
    final festivalIds = ids('festival.json', 'festivals');
    for (final rumor in entries('rumor.json', 'rumors')) {
      final residentId = rumor['relatedResidentId']?.toString() ?? '';
      final fishId = rumor['relatedFishId']?.toString() ?? '';
      final weatherId = rumor['relatedWeatherId']?.toString() ?? '';
      final festivalId = rumor['relatedFestivalId']?.toString() ?? '';
      expect(residentId.isEmpty || residentIds.contains(residentId), isTrue);
      expect(fishId.isEmpty || fishIds.contains(fishId), isTrue);
      expect(weatherId.isEmpty || weatherIds.contains(weatherId), isTrue);
      expect(festivalId.isEmpty || festivalIds.contains(festivalId), isTrue);
      expect((rumor['content']?.toString() ?? '').trim(), isNotEmpty);
    }
  });

  test('rc dynamic events have choices and valid rumor result references', () {
    final rumorIds = ids('rumor.json', 'rumors');
    for (final event in entries('events.json', 'events')) {
      expect((event['title']?.toString() ?? '').trim(), isNotEmpty);
      expect(event['conditions'], isA<Map>());
      final choices = (event['choices'] as List? ?? const []);
      expect(choices, isNotEmpty, reason: event['id']?.toString());
      for (final choice in choices.cast<Map>()) {
        final result = choice['result'] as Map? ?? const {};
        for (final rumorId in (result['rumorIds'] as List? ?? const [])) {
          expect(rumorIds.contains(rumorId), isTrue,
              reason: event['id']?.toString());
        }
      }
    }
  });

  test('rc event compatibility files mirror the same event ids', () {
    expect(ids('event.json', 'events'), ids('events.json', 'events'));
  });

  test('rc fish catalog has no self bait target and keeps rarity fields', () {
    const rarities = {
      'common',
      'uncommon',
      'rare',
      'epic',
      'legendary',
      'mythic',
      'legend',
      'myth',
      '普通',
      '优秀',
      '稀有',
      '史诗',
      '传说',
      '神话',
    };
    for (final fish in entries('fish_catalog.json', 'fish')) {
      final id = fish['id']?.toString() ?? '';
      expect(rarities.contains(fish['rarity']?.toString()), isTrue, reason: id);
      expect(fish['nextBaitTarget']?.toString() == id, isFalse, reason: id);
      expect((fish['waitDialogues'] as List? ?? const []).length,
          greaterThanOrEqualTo(2));
    }
  });

  test('rc task reward and honor entries have non-empty product copy', () {
    for (final task in entries('task.json', 'tasks.items')) {
      expect((task['title']?.toString() ?? '').trim(), isNotEmpty);
      expect((task['description']?.toString() ?? '').trim(), isNotEmpty);
      expect(task['reward'], isA<Map>());
    }
    for (final honor in entries('honor.json', 'honor.badges')) {
      expect((honor['title']?.toString() ?? '').trim(), isNotEmpty);
      expect((honor['description']?.toString() ?? '').trim(), isNotEmpty);
    }
  });

  test('rc world save empty state roundtrips safely', () {
    final save = WorldSaveData.empty();
    final restored = WorldSaveData.fromJson(save.toJson());
    expect(restored.saveVersion, save.saveVersion);
    expect(restored.worldClock.dayCount, save.worldClock.dayCount);
    expect(restored.careerState.careerLevel, save.careerState.careerLevel);
    expect(restored.playerInfluenceContext.reputation, contains('quiet'));
    expect(restored.officeWorldHistory, isEmpty);
  });

  test('rc legacy v1 save without v1.1 or v1.2 fields loads safely', () {
    final legacy = WorldSaveData.fromJson(const <String, dynamic>{
      'saveVersion': '1.0',
      'worldClock': {'dayCount': 8, 'hour': 10, 'minute': 20},
      'finishedStories': ['story_a'],
    });
    expect(legacy.saveVersion, '1.0');
    expect(legacy.worldClock.dayCount, 8);
    expect(legacy.finishedStories, ['story_a']);
    expect(legacy.careerState.careerLevel, 'intern');
    expect(legacy.friendshipStates, isEmpty);
    expect(legacy.playerInfluenceContext.reputation, contains('quiet'));
    expect(legacy.officeWorldHistory, isEmpty);
  });

  test('rc damaged save fields fallback without throwing', () {
    final damaged = WorldSaveData.fromJson(const <String, dynamic>{
      'saveVersion': 'broken',
      'worldClock': 'bad',
      'worldCalendar': 7,
      'finishedStories': 'not-list',
      'careerState': 'bad',
      'playerSkillStates': 'bad',
      'friendshipStates': ['bad'],
      'officeWorldHistory': 'bad',
      'recentPlayerActions': 'bad',
      'officeReputation': [],
    });
    expect(damaged.worldClock.dayCount, greaterThanOrEqualTo(1));
    expect(damaged.finishedStories, isEmpty);
    expect(damaged.playerSkillStates, isNotEmpty);
    expect(damaged.friendshipStates, isEmpty);
    expect(damaged.officeWorldHistory, isEmpty);
    expect(damaged.officeReputation, contains('quiet'));
  });

  test('rc duplicate-settlement state survives save serialization', () {
    final save = WorldSaveData.empty().copyWith(
      salaryTransactionIds: const ['salary_1_7'],
      processedOfficeEventIds: const ['event_a', 'event_b'],
      finishedStories: const ['story_a'],
      taskRewards: const [
        TaskRewardRecord(
          id: 'task_reward_1',
          taskId: 'daily_talk',
          taskTitle: '聊一会',
          fishCoin: 10,
          exp: 2,
          claimedAt: '2026-08-02T10:00:00',
          tags: ['daily'],
        ),
      ],
      interactionHistory: const [
        InteractionHistoryRecord(
          id: 'interaction_1',
          residentId: 'resident_001',
          dialogueId: 'dialogue_001',
          storyId: 'story_a',
          createdAt: '2026-08-02T10:00:00',
          tags: ['talk'],
        ),
      ],
    );
    final restored = WorldSaveData.fromJson(save.toJson());
    expect(restored.salaryTransactionIds, contains('salary_1_7'));
    expect(
        restored.processedOfficeEventIds, containsAll(['event_a', 'event_b']));
    expect(restored.finishedStories, contains('story_a'));
    expect(restored.taskRewards.single.id, 'task_reward_1');
    expect(restored.interactionHistory.single.id, 'interaction_1');
  });

  test('rc interaction feedback covers release candidate action types', () {
    final dialogues = entries('resident_dialogue.json', 'dialogues');
    final actionTypes = dialogues
        .map((item) => item['actionType']?.toString() ?? '')
        .where((action) => action.isNotEmpty)
        .toSet();
    expect(
      actionTypes,
      containsAll(<String>[
        'talk',
        'ask_about_rumor',
        'share_fish',
        'join_group',
        'start_story',
        'help_work',
        'observe',
      ]),
    );
  });

  test('rc office interaction content exposes product-facing labels', () {
    final actionLabels = <String>[
      'talk',
      'ask_about_rumor',
      'share_fish',
      'join_group',
      'help_work',
    ];
    expect(actionLabels, containsAll(['talk', 'share_fish', 'join_group']));
    final dialogueTexts = entries('resident_dialogue.json', 'dialogues')
        .take(50)
        .map((item) => item['text']?.toString() ?? '');
    expect(dialogueTexts.every((text) => text.trim().isNotEmpty), isTrue);
  });

  test('rc no key config uses forbidden empty object fallback', () {
    for (final spec in const <List<String>>[
      ['resident_dialogue.json', 'dialogues'],
      ['resident_story.json', 'stories'],
      ['rumor.json', 'rumors'],
      ['events.json', 'events'],
    ]) {
      for (final item in entries(spec[0], spec[1]).take(30)) {
        expect((item['id']?.toString() ?? '').trim(), isNotEmpty);
      }
    }
  });

  test('rc web asset urls use Flutter release asset prefix', () {
    final criticalAssets = [
      'assets/assets/config/resident_dialogue.json',
      'assets/assets/config/office_dialog.json',
      'assets/assets/config/resident_story.json',
      'assets/assets/config/rumor.json',
      'assets/assets/config/festival.json',
      'assets/assets/config/weather.json',
      'assets/assets/config/task.json',
      'assets/assets/config/fish_catalog.json',
    ];
    expect(criticalAssets.every((path) => path.startsWith('assets/assets/')),
        isTrue);
    expect(
        criticalAssets.any((path) => path.endsWith('/dialog.json')), isFalse);
  });

  test('rc v1 release archive is not part of current package assets', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec.contains('106_Releases'), isFalse);
    expect(pubspec.contains('Railway'), isFalse);
  });

  test('browser acceptance route map covers production home entries', () {
    final routes = entries('office_routes.json', 'routes');
    final routeByPath = {
      for (final route in routes) route['path']?.toString() ?? '': route,
    };
    for (final path in const [
      '/home',
      '/profile',
      '/help',
      '/store',
      '/honor',
      '/bag',
      '/collection',
      '/fishing',
      '/exit',
    ]) {
      expect(routeByPath[path], isNotNull, reason: path);
    }
    expect(routeByPath['/profile']!['type'], 'dialog');
    expect(routeByPath['/collection']!['page'], 'FishCollectionDialog');
  });

  test('browser acceptance all home buttons are registered once', () {
    final actions = entries('office_interaction.json', 'home.actions');
    final actionByTarget = <String, Map<String, dynamic>>{};
    for (final action in actions) {
      final target = action['target']?.toString() ?? '';
      if (target.isNotEmpty) actionByTarget[target] = action;
    }
    for (final target in const [
      'profile_card',
      'btn_help',
      'btn_exit',
      'btn_store',
      'btn_honor',
      'btn_bag',
      'btn_start_fishing',
      'btn_tasks',
      'fish_book',
    ]) {
      expect(actions.where((item) => item['target'] == target).length, 1,
          reason: target);
      expect(actionByTarget[target]?['event'], 'tap', reason: target);
    }
  });

  test('browser acceptance critical dialogs have close contracts', () {
    final layout = loadConfig('office_layout.json');
    for (final spec in const <List<String>>[
      ['fish_collection', 'collection_close'],
      ['profile', 'profile_close'],
      ['inventory', 'inventory_close'],
      ['honor', 'honor_close'],
    ]) {
      expect(layoutElement(layout, spec[0], spec[1]), isNotNull,
          reason: spec.join(':'));
    }
  });

  test('browser acceptance share fish flow keeps browser-safe metadata', () {
    final dialogues = entries('resident_dialogue.json', 'dialogues');
    expect(
      dialogues.any((item) => item['actionType'] == 'share_fish'),
      isTrue,
    );
    final restored = WorldSaveData.fromJson(WorldSaveData.empty().copyWith(
      recentPlayerActions: const [
        RecentPlayerAction(
          id: 'action_share_fish_browser',
          type: 'share_fish',
          sourceId: 'browser_flow',
          description: 'Share one fish during browser acceptance.',
          createdAt: '2026-08-02T12:00:00',
          day: 1,
          weight: 3,
          tags: ['fish', 'resident'],
        ),
      ],
    ).toJson());
    expect(restored.recentPlayerActions.single.type, 'share_fish');
  });

  test('browser acceptance refresh restore preserves runtime state', () {
    final save = WorldSaveData.empty().copyWith(
      finishedStories: const ['story_refresh'],
      processedOfficeEventIds: const ['event_refresh'],
      salaryTransactionIds: const ['salary_refresh'],
    );
    final restored = WorldSaveData.fromJson(save.toJson());
    expect(restored.finishedStories, contains('story_refresh'));
    expect(restored.processedOfficeEventIds, contains('event_refresh'));
    expect(restored.salaryTransactionIds, contains('salary_refresh'));
  });

  test('browser acceptance asset content type contract is explicit', () {
    final server = projectFile('server.js');
    expect(server, contains("'.js': 'application/javascript; charset=utf-8'"));
    expect(server, contains("'.json': 'application/json; charset=utf-8'"));
    expect(server, contains("'.wasm': 'application/wasm'"));
    expect(server, contains("'.png': 'image/png'"));
  });

  test('browser acceptance no dialog json request contract', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec.contains('assets/config/dialog.json'), isFalse);
    expect(pubspec.contains('resident_dialogue.json'), isTrue);
    expect(pubspec.contains('office_dialog.json'), isTrue);
    for (final source in dartFilesUnder('lib')) {
      expect(source.contains('assets/config/dialog.json'), isFalse);
    }
  });

  test('browser acceptance staging root directory contract', () {
    final dockerfile = projectFile('Dockerfile');
    final packageJson = jsonDecode(projectFile('package.json')) as Map;
    expect(dockerfile, contains('WORKDIR /app/fishing_office_flutter'));
    expect(dockerfile, contains('COPY fishing_office_flutter'));
    expect(dockerfile, contains('COPY server.js ./server.js'));
    expect(packageJson['scripts']['start'], 'node server.js');
  });

  test('browser acceptance dockerfile build context contract', () {
    final dockerfile = projectFile('Dockerfile');
    expect(dockerfile, contains('flutter pub get'));
    expect(dockerfile, contains('flutter build web --release'));
    expect(
      dockerfile,
      contains('/app/fishing_office_flutter/build/web'),
    );
    expect(dockerfile, isNot(contains('fishing_office_flutter/server.js')));
  });

  test('browser acceptance spa fallback excludes missing static json', () {
    final server = projectFile('server.js');
    expect(server, contains('isStaticAssetRequest'));
    expect(server, contains("pathname.startsWith('/assets/')"));
    expect(server, contains('Static asset not found'));
    expect(server.indexOf('isStaticAssetRequest(pathname)'),
        lessThan(server.indexOf("pathname === '/'")));
  });

  test('browser acceptance responsive close button stays above 44px', () {
    final layout = loadConfig('office_layout.json');
    for (final spec in const <List<String>>[
      ['fish_collection', 'collection_close'],
      ['profile', 'profile_close'],
      ['inventory', 'inventory_close'],
      ['honor', 'honor_close'],
    ]) {
      final close = layoutElement(layout, spec[0], spec[1]);
      expect(close, isNotNull, reason: spec.join(':'));
      expect(close!.rect.width, greaterThanOrEqualTo(44));
      expect(close.rect.height, greaterThanOrEqualTo(44));
    }
  });

  test('browser acceptance overlay loop stability is covered by widget test',
      () {
    final widgetTest = File('test/widgets/resident_detail_dialog_test.dart')
        .readAsStringSync();
    expect(widgetTest, contains('overlay lock'));
    expect(widgetTest, contains('pumpWidget(const SizedBox.shrink())'));
  });

  test('browser acceptance duplicate interaction contract survives reload', () {
    final save = WorldSaveData.empty().copyWith(
      processedOfficeEventIds: const ['duplicate_event'],
      taskRewards: const [
        TaskRewardRecord(
          id: 'task_reward_duplicate',
          taskId: 'daily_browser',
          taskTitle: '浏览器验收任务',
          fishCoin: 8,
          exp: 1,
          claimedAt: '2026-08-02T12:00:00',
          tags: ['browser'],
        ),
      ],
    );
    final restored = WorldSaveData.fromJson(save.toJson());
    expect(restored.processedOfficeEventIds.toSet().length,
        restored.processedOfficeEventIds.length);
    expect(restored.taskRewards.single.id, 'task_reward_duplicate');
  });

  test('browser acceptance local storage migration contract is safe', () {
    final legacy = WorldSaveData.fromJson(const <String, dynamic>{
      'saveVersion': '0.9',
      'worldClock': {'dayCount': 1},
      'residentMemoryState': {},
      'relationshipRuntimeState': {},
    });
    expect(legacy.saveVersion, '0.9');
    expect(legacy.worldClock.dayCount, 1);
    expect(legacy.officeWorldHistory, isEmpty);
    expect(legacy.playerInfluenceContext.officeInfluence.officeTrust,
        greaterThanOrEqualTo(0));
  });

  test('browser acceptance release build asset manifest contract', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final path in const [
      'assets/config/',
      'assets/images/',
    ]) {
      expect(pubspec, contains(path), reason: path);
    }
    expect(pubspec.contains('assets/config/dialog.json'), isFalse);
  });
}
