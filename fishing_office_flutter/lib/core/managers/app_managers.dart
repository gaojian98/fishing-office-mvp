import 'package:flutter/foundation.dart';

import '../balance/balance_manager.dart';
import '../engine/companion_gift_manager.dart';
import '../engine/fishing_engine.dart';
import '../engine/fishing_event.dart';
import '../engine/fishing_result.dart';
import '../engine/fishing_session.dart';
import '../engine/life_engine.dart';
import '../engine/meaning_engine.dart';
import '../engine/relationship_engine.dart';
import '../engine/today_engine.dart';
import '../engine/today_story.dart';
import '../engine/waiting_engine.dart';
import '../engine/weather_state.dart';
import '../engine/weather_system.dart';
import '../engine/world_engine.dart';
import '../engine/ocean_engine.dart';
import '../engine/waiting_event.dart';
import '../engine/waiting_commitment.dart';
import '../engine/waiting_notification.dart';
import '../engine/waiting_session.dart';
import '../../models/fish_collection_config.dart';
import '../../models/honor_config.dart';
import '../../models/inventory_config.dart';
import '../../models/settings_config.dart';
import '../../models/task_config.dart';
import '../../models/transaction_config.dart';
import '../services/fairy_event_service.dart';
import 'fish_runtime_manager.dart';
import 'world_clock_manager.dart';

class CoreManagerState {
  const CoreManagerState({this.ready = false, this.message = 'loading'});
  final bool ready;
  final String message;
}

class BalanceManagerView extends ChangeNotifier {
  BalanceManagerView(this.manager);
  final BalanceManager manager;
  CoreManagerState _state = const CoreManagerState();
  CoreManagerState get state => _state;
  Future<void> bootstrap() async {
    _state = const CoreManagerState(ready: false, message: 'loading balance');
    notifyListeners();
    await manager.load();
    _state = const CoreManagerState(ready: true, message: 'balance ready');
    notifyListeners();
  }
}

class FishingManagerView extends ChangeNotifier {
  FishingManagerView(this.engine);
  final FishingEngine engine;
  final CoreManagerState _state = const CoreManagerState();
  CoreManagerState get state => _state;
}

class WaitingManagerView extends ChangeNotifier {
  WaitingManagerView(this.engine);
  final WaitingEngine engine;
  final CoreManagerState _state = const CoreManagerState();
  CoreManagerState get state => _state;
}

class RelationshipManagerView extends ChangeNotifier {
  RelationshipManagerView(this.engine);
  final RelationshipEngine engine;
}

class LifeManagerView extends ChangeNotifier {
  LifeManagerView(this.engine);
  final LifeEngine engine;
}

class MeaningManagerView extends ChangeNotifier {
  MeaningManagerView(this.engine);
  final MeaningEngine engine;
}

class WorldManagerView extends ChangeNotifier {
  WorldManagerView(this.engine);
  final WorldEngine engine;
}

class TodayManagerView extends ChangeNotifier {
  TodayManagerView(this.engine);
  final TodayEngine engine;
  late final TodayStory preview = engine.generateToday(worldId: 'second_world');
}

class WeatherManagerView extends ChangeNotifier {
  WeatherManagerView(this.engine);
  final WeatherSystem engine;
  WeatherState get preview => engine.state;
}

class WaitingEventTemplate {
  const WaitingEventTemplate({
    required this.eventType,
    required this.message,
    required this.effectType,
    required this.effectValue,
    required this.target,
    required this.tone,
    required this.surpriseTier,
  });

  final String eventType;
  final String message;
  final String effectType;
  final num effectValue;
  final String target;
  final String tone;
  final String surpriseTier;
}

class WaitingEventManagerView extends ChangeNotifier {
  WaitingEventManagerView(this.engine);

  final WaitingEngine engine;
  final List<WaitingEventTemplate> _templates = const <WaitingEventTemplate>[
    WaitingEventTemplate(
      eventType: 'float_moved',
      message: '鱼漂刚才动了一下。',
      effectType: 'attention',
      effectValue: 1,
      target: 'float',
      tone: 'gentle',
      surpriseTier: 'normal',
    ),
    WaitingEventTemplate(
      eventType: 'fish_nearby',
      message: '好像有鱼靠近。',
      effectType: 'proximity',
      effectValue: 1,
      target: 'bait',
      tone: 'curious',
      surpriseTier: 'normal',
    ),
    WaitingEventTemplate(
      eventType: 'bait_touched',
      message: '鱼饵被轻轻试探。',
      effectType: 'tension',
      effectValue: 1,
      target: 'bait',
      tone: 'soft',
      surpriseTier: 'normal',
    ),
    WaitingEventTemplate(
      eventType: 'fish_group_passed',
      message: '海面突然安静了。',
      effectType: 'silence',
      effectValue: 0,
      target: 'water',
      tone: 'healing',
      surpriseTier: 'surprise',
    ),
    WaitingEventTemplate(
      eventType: 'old_fisherman_hint',
      message: '老渔夫说：别急，再等等。',
      effectType: 'hint',
      effectValue: 0,
      target: 'player',
      tone: 'warm',
      surpriseTier: 'surprise',
    ),
    WaitingEventTemplate(
      eventType: 'bait_half_eaten',
      message: '鱼饵被轻轻试探，像是少了一点。',
      effectType: 'bite',
      effectValue: 1,
      target: 'bait',
      tone: 'humor',
      surpriseTier: 'unexpected',
    ),
    WaitingEventTemplate(
      eventType: 'office_coffee_pause',
      message: '咖啡香从办公室飘过来，鱼漂也像是在休息。',
      effectType: 'comfort',
      effectValue: 0,
      target: 'world',
      tone: 'office_healing',
      surpriseTier: 'surprise',
    ),
    WaitingEventTemplate(
      eventType: 'fish_whisper',
      message: '水下传来很轻的声音：今天可以慢一点。',
      effectType: 'fairy_hint',
      effectValue: 0,
      target: 'fish',
      tone: 'fairy',
      surpriseTier: 'fairy',
    ),
    WaitingEventTemplate(
      eventType: 'resident_passed',
      message: '有人从窗边路过，轻轻说：这会儿海风正好。',
      effectType: 'resident_hint',
      effectValue: 0,
      target: 'resident',
      tone: 'living_world',
      surpriseTier: 'unexpected',
    ),
  ];

  List<WaitingEvent> buildForSession({
    required String sessionId,
    required String baitLabel,
    required String chainLabel,
    required bool hasNextBait,
  }) {
    final desiredCount = 3 + (sessionId.hashCode.abs() % 3);
    final selected = <WaitingEventTemplate>[];
    final narrativeSlots = hasNextBait ? 1 : 0;
    final templateCount =
        (desiredCount - narrativeSlots).clamp(1, desiredCount);
    final startIndex = sessionId.hashCode.abs() % _templates.length;
    for (var offset = 0;
        selected.length < templateCount && offset < _templates.length * 2;
        offset++) {
      final candidate = _templates[(startIndex + offset) % _templates.length];
      final alreadyUsed = selected.any((item) =>
          item.eventType == candidate.eventType ||
          item.message == candidate.message);
      if (!alreadyUsed) selected.add(candidate);
    }
    final intro = hasNextBait ? '你把 $baitLabel 作为鱼饵抛了出去。' : '你把鱼饵抛了出去。';
    _ensureTier(selected, 'surprise', templateCount);
    _ensureTier(selected, 'unexpected', templateCount);
    if (desiredCount >= 5) _ensureTier(selected, 'fairy', templateCount);
    final result = <WaitingEvent>[
      if (hasNextBait)
        WaitingEvent(
          eventId: '${sessionId}_intro',
          sessionId: sessionId,
          eventType: 'bait_cast',
          time: WorldClockManager.systemNow(),
          message: intro,
          effect: 'bait_cast',
          visibleToPlayer: true,
          payload: {
            'chain': chainLabel,
            'rhythm': 'start',
            'tone': 'chain',
          },
          effectType: 'narrative',
          effectValue: 0,
          target: 'bait',
        ),
      for (var i = 0; i < selected.length; i++)
        WaitingEvent(
          eventId: '${sessionId}_wait_${i + 1}',
          sessionId: sessionId,
          eventType: selected[i].eventType,
          time: WorldClockManager.systemNow(),
          message: selected[i].message,
          effect: selected[i].effectType,
          visibleToPlayer: true,
          payload: {
            'chain': chainLabel,
            'baitLabel': baitLabel,
            'visibleToPlayer': true,
            'tone': selected[i].tone,
            'surpriseTier': selected[i].surpriseTier,
            'rhythm': _rhythmFor(selected[i].surpriseTier),
          },
          effectType: selected[i].effectType,
          effectValue: selected[i].effectValue,
          target: selected[i].target,
        ),
    ];
    engine.notify(
      WaitingSession(
        id: sessionId,
        commitment: const WaitingCommitment(),
        metadata: const {},
      ),
      WaitingNotification(
        notificationId: '${sessionId}_notify',
        type: 'waiting',
        message: intro,
        effect: 'bait_cast',
        visibleToPlayer: true,
        payload: {'chain': chainLabel},
      ),
    );
    if (kDebugMode) {
      debugPrint(
          'Waiting Log | session=$sessionId events=${result.length} bait=$baitLabel');
    }
    return result;
  }

  WaitingEventTemplate _templateByTier(String surpriseTier) {
    return _templates.firstWhere(
      (template) => template.surpriseTier == surpriseTier,
      orElse: () => _templates.first,
    );
  }

  void _ensureTier(
    List<WaitingEventTemplate> selected,
    String surpriseTier,
    int maxCount,
  ) {
    if (selected.any((item) => item.surpriseTier == surpriseTier)) return;
    final template = _templateByTier(surpriseTier);
    if (selected.length < maxCount) {
      selected.add(template);
      return;
    }
    final replaceIndex = selected.lastIndexWhere(
      (item) => item.surpriseTier == 'normal',
    );
    if (replaceIndex >= 0) selected[replaceIndex] = template;
  }

  String _rhythmFor(String surpriseTier) {
    switch (surpriseTier) {
      case 'surprise':
        return 'within_5_minutes';
      case 'unexpected':
        return 'within_10_minutes';
      case 'fairy':
        return 'within_30_minutes';
      default:
        return 'ambient';
    }
  }
}

class FishChainEntry {
  const FishChainEntry({
    required this.id,
    required this.name,
    required this.nextFishId,
    required this.tier,
  });

  final String id;
  final String name;
  final String nextFishId;
  final int tier;
}

class FishChainProvider extends ChangeNotifier {
  FishChainProvider()
      : _entries = const <FishChainEntry>[
          FishChainEntry(
              id: 'bait_basic',
              name: '基础鱼饵',
              nextFishId: 'fish_small',
              tier: 0),
          FishChainEntry(
              id: 'fish_small', name: '小鱼', nextFishId: 'fish_basa', tier: 1),
          FishChainEntry(
              id: 'fish_basa',
              name: '巴沙鱼',
              nextFishId: 'fish_tilapia',
              tier: 2),
          FishChainEntry(
              id: 'fish_tilapia',
              name: '罗非鱼',
              nextFishId: 'fish_mackerel',
              tier: 3),
          FishChainEntry(
              id: 'fish_mackerel',
              name: '鲭鱼',
              nextFishId: 'fish_grouper',
              tier: 4),
          FishChainEntry(
              id: 'fish_grouper',
              name: '石斑鱼',
              nextFishId: 'fish_tuna',
              tier: 5),
          FishChainEntry(
              id: 'fish_tuna', name: '金枪鱼', nextFishId: 'fish_legend', tier: 6),
          FishChainEntry(
              id: 'fish_legend',
              name: '传奇鱼',
              nextFishId: 'fish_legend',
              tier: 7),
        ];

  final List<FishChainEntry> _entries;

  List<FishChainEntry> get entries =>
      List<FishChainEntry>.unmodifiable(_entries);

  FishChainEntry entryById(String id) {
    return _entries.firstWhere(
      (entry) => entry.id == id,
      orElse: () => _entries.first,
    );
  }

  FishChainEntry nextEntryFor(String baitId) {
    final current = entryById(baitId);
    return entryById(current.nextFishId);
  }

  String describePath(String baitId) {
    final current = entryById(baitId);
    final next = entryById(current.nextFishId);
    return '${current.name} → ${next.name}';
  }
}

class FishingProvider extends ChangeNotifier {
  FishingProvider({
    FishingEngine? engine,
    WaitingEngine? waitingEngine,
    FishChainProvider? chainProvider,
    WaitingEventManagerView? waitingEventManager,
    CollectionManagerView? collectionManager,
    FishRuntimeManager? fishRuntimeManager,
    FairyEventService? fairyEventService,
  })  : _engine = engine ?? FishingEngine(oceanEngine: OceanEngine()),
        _waitingEngine = waitingEngine ?? WaitingEngine(),
        _chainProvider = chainProvider ?? FishChainProvider(),
        _waitingEventManager =
            waitingEventManager ?? WaitingEventManagerView(WaitingEngine()),
        _collectionManager = collectionManager ?? CollectionManagerView(),
        _fishRuntimeManager = fishRuntimeManager,
        _fairyEventService = fairyEventService;

  final FishingEngine _engine;
  final WaitingEngine _waitingEngine;
  final FishChainProvider _chainProvider;
  final WaitingEventManagerView _waitingEventManager;
  final CollectionManagerView _collectionManager;
  FishRuntimeManager? _fishRuntimeManager;
  FairyEventService? _fairyEventService;
  FishingSession? _session;
  FishingResult? _result;
  String? _nextBaitId;
  FishChainEntry? _pendingFish;
  final List<WaitingEvent> _waitingEvents = <WaitingEvent>[];
  final List<FishingEvent> _fishingEvents = <FishingEvent>[];
  String _state = 'idle';

  String get state => _state;
  FishingSession? get session => _session;
  FishingResult? get result => _result;
  List<WaitingEvent> get waitingEvents =>
      List<WaitingEvent>.unmodifiable(_waitingEvents);
  List<FishingEvent> get fishingEvents =>
      List<FishingEvent>.unmodifiable(_fishingEvents);
  String get currentBaitLabel {
    final baitId = _nextBaitId ??
        _session?.initialData['baitId']?.toString() ??
        'bait_basic';
    return _chainProvider.entryById(baitId).name;
  }

  String get currentChainLabel {
    final baitId = _nextBaitId ??
        _session?.initialData['baitId']?.toString() ??
        'bait_basic';
    return _chainProvider.describePath(baitId);
  }

  String get currentResultLabel => _result?.fishName ?? '暂无结果';
  String get currentWaitingLabel =>
      _waitingEvents.isEmpty ? '暂无等待事件' : _waitingEvents.first.message;
  List<String> get waitingMessages =>
      _waitingEvents.map((event) => event.message).toList(growable: false);
  bool get canPullLine => _state == 'fishHooked';

  void setFishRuntimeManager(FishRuntimeManager manager) {
    _fishRuntimeManager = manager;
  }

  void setFairyEventService(FairyEventService service) {
    _fairyEventService = service;
  }

  String get currentActionsLabel {
    final items = <String>[
      if (_state == 'waiting') '继续等待',
      if (_state == 'fishHooked') '可以收线',
      if (_state == 'finished' && _result != null) '可以处理钓获',
      if (_state == 'preparing') '准备再次抛线',
      if (_state == 'idle') '先抛线开始',
    ];
    return items.isEmpty ? '等一等，看看情况' : items.join(' · ');
  }

  String get stateLabel {
    switch (_state) {
      case 'idle':
        return '未抛线';
      case 'preparing':
        return '准备中';
      case 'waiting':
        return '等待中';
      case 'fishInterested':
        return '有动静';
      case 'fishHooked':
        return '可以收线';
      case 'pulling':
        return '收线中';
      case 'finished':
        return '钓到了鱼';
      default:
        return _state;
    }
  }

  void throwLine({String baitId = 'bait_basic'}) {
    final effectiveBaitId = _nextBaitId ?? baitId;
    if (kDebugMode) {
      debugPrint('Fishing Log | throwLine bait=$effectiveBaitId state=$_state');
    }
    _session = _engine.createSession(
      initialData: {
        'baitId': effectiveBaitId,
        'startTime': WorldClockManager.systemNow().toIso8601String(),
        'waitTier': 'mock',
        'currentState': 'waiting',
      },
    );
    final nextFish = _chainProvider.nextEntryFor(effectiveBaitId);
    _waitingEvents
      ..clear()
      ..addAll(
        _waitingEventManager.buildForSession(
          sessionId: _session!.id,
          baitLabel: _chainProvider.entryById(effectiveBaitId).name,
          chainLabel: _chainProvider.describePath(effectiveBaitId),
          hasNextBait: _nextBaitId != null,
        ),
      );
    final fishHint = _uniqueWaitingHint(
      _fishRuntimeManager?.waitingDialogueForContext(
        FishRuntimeContext(
          baitId: effectiveBaitId,
          locationId: '海边',
        ),
      ),
    );
    if (fishHint != null && fishHint.isNotEmpty) {
      _waitingEvents.add(
        WaitingEvent(
          eventId: '${_session!.id}_fish_hint',
          sessionId: _session!.id,
          eventType: 'fish_wait_dialogue',
          time: WorldClockManager.systemNow(),
          message: fishHint,
          effect: 'fish_hint',
          visibleToPlayer: true,
          payload: const {
            'visibleToPlayer': true,
            'tone': 'fish_dialogue',
            'rhythm': 'fish_presence',
          },
          effectType: 'fish_dialogue',
          effectValue: 0,
          target: 'fish',
        ),
      );
    }
    final fairySelection = _fairyEventService?.selectEvent(
      waitingDuration: const Duration(minutes: 3),
    );
    if (fairySelection != null &&
        !_waitingEvents.any(
          (event) => event.message == _fairyMessage(fairySelection),
        )) {
      final fairyRecord = _fairyEventService?.triggerFairyEvent(
        waitingDuration: const Duration(minutes: 3),
      );
      if (fairyRecord != null) {
        _addWaitingEventWithCap(
          WaitingEvent(
            eventId: '${_session!.id}_fairy_${fairyRecord.eventId}',
            sessionId: _session!.id,
            eventType: 'fairy_${fairySelection.category.name}',
            time: WorldClockManager.systemNow(),
            message: _fairyMessage(fairySelection),
            effect: 'fairy_event',
            visibleToPlayer: true,
            payload: {
              'visibleToPlayer': true,
              'dynamicEventId': fairyRecord.eventId,
              'fairyCategory': fairySelection.category.name,
              'rhythm': fairySelection.rhythmTier,
              'tone': 'fairy_runtime',
            },
            effectType: 'fairy_event',
            effectValue: 1,
            target: 'second_world',
          ),
        );
      }
    }
    for (final event in _waitingEvents) {
      _waitingEngine.emit(event);
    }
    _fishingEvents.add(FishingEvent.started(sessionId: _session!.id));
    _state = 'waiting';
    _pendingFish = nextFish;
    _result = null;
    _nextBaitId = null;
    notifyListeners();
  }

  void markFishHooked() {
    if (_state != 'waiting' || _session == null) return;
    _state = 'fishHooked';
    _waitingEvents.add(
      WaitingEvent(
        eventId: '${_session!.id}_hooked',
        sessionId: _session!.id,
        eventType: 'fish_hooked',
        time: WorldClockManager.systemNow(),
        message: '鱼儿上钩了，可以收线了。',
        effect: 'hooked',
        visibleToPlayer: true,
        payload: const {
          'visibleToPlayer': true,
          'feedbackText': '鱼漂沉了一下，手边的线忽然有了重量。',
          'audioCue': 'reserved_pull_ready',
          'animationCue': 'reserved_float_dip',
        },
        effectType: 'hooked',
        effectValue: 1,
        target: 'float',
      ),
    );
    if (kDebugMode) {
      debugPrint('Fishing Log | fishHooked session=${_session!.id}');
    }
    notifyListeners();
  }

  void pullLine() {
    if (_state != 'fishHooked') {
      if (kDebugMode) {
        debugPrint('Fishing Log | pullLine ignored state=$_state');
      }
      return;
    }
    if (_session == null) return;
    _state = 'pulling';
    notifyListeners();
    final resolved = _buildResult(
      _session!.id,
      baitId: _session!.initialData['baitId']?.toString() ?? 'bait_basic',
      nextFish: _pendingFish ??
          _chainProvider.nextEntryFor(
              _session!.initialData['baitId']?.toString() ?? 'bait_basic'),
    );
    _result = resolved;
    _collectionManager.discoverFish(
      fishId: resolved.fishId,
      fishName: resolved.fishName,
      rarity: _tierName(resolved.metadata['tier']),
      category: 'fish',
    );
    _state = 'finished';
    if (kDebugMode) {
      debugPrint(
          'Fishing Log | pullLine result=${resolved.fishName} tier=${resolved.metadata['tier']}');
    }
    _fishingEvents.add(
      FishingEvent.updated(
        sessionId: _session!.id,
        stage: 'finished',
        payload: {
          'result': {
            'fishId': resolved.fishId,
            'fishName': resolved.fishName,
            'canUseAsBait': resolved.collectionEligible,
            'tier': resolved.metadata['tier'],
            'baseCoin': resolved.value,
            'points': resolved.points,
            'canSell': resolved.sellable,
            'canKeep': resolved.keepable,
            'feedbackText': '收线完成，今天的海给了你一个小小回应。',
            'audioCue': 'reserved_catch_result',
            'animationCue': 'reserved_line_pull',
          },
        },
      ),
    );
    notifyListeners();
  }

  void sellFish({
    required WalletManagerView wallet,
    required TransactionManagerView transactions,
  }) {
    final result = _result;
    if (result == null || !result.sellable) return;
    wallet.add(result.value);
    transactions.addRecord(
      TransactionRecord(
        id: 'tx_${WorldClockManager.timestampId()}',
        type: 'sell_fish',
        currency: 'fish_coin',
        amount: result.value,
        itemId: result.fishId,
        itemName: result.fishName,
        createdAt: WorldClockManager.systemNow(),
        category: 'income',
        note: '出售 ${result.fishName}',
      ),
    );
    wallet.addPoints(result.points);
    if (kDebugMode) {
      debugPrint(
          'Wallet Log | sellFish coin+=${result.value} points+=${result.points}');
      debugPrint(
          'Transaction Log | sell_fish item=${result.fishName} amount=${result.value}');
    }
    _clearResult();
    _state = 'idle';
    notifyListeners();
  }

  void keepFish({
    required InventoryManagerView inventory,
    required MemoryManagerView memory,
  }) {
    final result = _result;
    if (result == null || !result.keepable) return;
    final companionPotential = _tierValue(result.metadata['tier']) >= 5;
    inventory.addItem(
      itemId: result.fishId,
      name: result.fishName,
      category: 'fish',
      rarity: result.metadata['tier']?.toString() ?? 'normal',
      icon: 'fish',
      description: '来自钓鱼闭环的 mock 鱼获',
      quantity: 1,
    );
    if (companionPotential) {
      memory.addRecord(
        MemoryRecord(
          id: 'memory_${WorldClockManager.timestampId()}',
          type: 'companionPotential',
          title: result.fishName,
          createdAt: WorldClockManager.systemNow(),
          payload: {
            'fishId': result.fishId,
            'tier': result.metadata['tier'],
          },
        ),
      );
    }
    if (kDebugMode) {
      debugPrint('Inventory Log | keepFish item=${result.fishName} qty=1');
    }
    _clearResult();
    _state = 'idle';
    notifyListeners();
  }

  void useAsBait() {
    final result = _result;
    if (result == null) return;
    _nextBaitId = result.fishId;
    if (kDebugMode) {
      debugPrint('FishChain Log | useAsBait nextBaitId=$_nextBaitId');
    }
    _clearResult();
    _state = 'preparing';
    notifyListeners();
  }

  void baitEaten() {
    _state = 'waiting';
    notifyListeners();
  }

  void fishEscaped() {
    _state = 'waiting';
    notifyListeners();
  }

  void chainFailed() {
    _state = 'waiting';
    notifyListeners();
  }

  FishingResult _buildResult(
    String sessionId, {
    required String baitId,
    required FishChainEntry nextFish,
  }) {
    final nextTier = nextFish.tier;
    final runtimeResult = _fishRuntimeManager?.selectFishResult(
      FishRuntimeContext(
        baitId: baitId,
        locationId: '海边',
      ),
    );
    if (runtimeResult != null) {
      final fish = runtimeResult.fish;
      final tier = _rarityTier(fish.rarity);
      return FishingResult(
        sessionId: sessionId,
        status: 'resolved',
        fishId: fish.id,
        fishName: fish.name,
        value: fish.value,
        points: 10 + (tier * 4),
        keepable: true,
        sellable: true,
        companionEligible: false,
        collectionEligible: true,
        metadata: {
          'tier': tier,
          'quality': _rarityDisplayName(fish.rarity),
          'rarity': fish.rarity,
          'weightKg': runtimeResult.weightKg,
          'baseCoin': fish.value,
          'baitId': baitId,
          'baitName': _chainProvider.entryById(baitId).name,
          'path': _chainProvider.describePath(baitId),
          'canUseAsBait': fish.nextBaitTarget.isNotEmpty,
          'catchReaction': runtimeResult.catchReaction,
          'waitDialogue': runtimeResult.waitDialogue,
          'biteChance': runtimeResult.biteChance,
          'habitat': fish.habitat,
          'feedbackText': '收线完成，今天的海给了你一个小小回应。',
          'audioCue': 'reserved_catch_result',
          'animationCue': 'reserved_line_pull',
        },
      );
    }
    return FishingResult(
      sessionId: sessionId,
      status: 'resolved',
      fishId: nextFish.id,
      fishName: nextFish.name,
      value: 120 + (nextTier * 30),
      points: 12 + (nextTier * 3),
      keepable: true,
      sellable: true,
      companionEligible: false,
      collectionEligible: true,
      metadata: {
        'tier': nextTier,
        'quality': _tierDisplayName(nextTier),
        'weightKg': double.parse((0.4 + (nextTier * 0.85)).toStringAsFixed(1)),
        'baseCoin': 120 + (nextTier * 30),
        'baitId': baitId,
        'baitName': _chainProvider.entryById(baitId).name,
        'path': _chainProvider.describePath(baitId),
        'canUseAsBait': true,
        'feedbackText': '收线完成，今天的海给了你一个小小回应。',
        'audioCue': 'reserved_catch_result',
        'animationCue': 'reserved_line_pull',
      },
    );
  }

  void _clearResult() {
    _result = null;
    _pendingFish = null;
    _waitingEvents.clear();
  }

  String? _uniqueWaitingHint(String? hint) {
    final text = hint?.trim();
    if (text == null || text.isEmpty) return null;
    final exists = _waitingEvents.any((event) => event.message == text);
    return exists ? null : text;
  }

  String _fairyMessage(FairyEventSelection selection) {
    for (final line in selection.event.dialog) {
      final text = line.text.trim();
      if (text.isNotEmpty) return text;
    }
    return selection.event.title;
  }

  void _addWaitingEventWithCap(WaitingEvent event) {
    const maxWaitingEvents = 5;
    if (_waitingEvents.length < maxWaitingEvents) {
      _waitingEvents.add(event);
      return;
    }
    final replaceIndex = _waitingEvents.lastIndexWhere(
      (item) => item.payload['surpriseTier'] == 'normal',
    );
    if (replaceIndex >= 0) {
      _waitingEvents[replaceIndex] = event;
    }
  }

  int _tierValue(Object? value) {
    final text = '$value';
    final parsed = int.tryParse(text);
    if (parsed != null) return parsed;
    switch (text) {
      case 'common':
        return 1;
      case 'uncommon':
        return 2;
      case 'rare':
        return 3;
      case 'epic':
        return 4;
      case 'legendary':
        return 5;
      default:
        return 0;
    }
  }

  String _tierDisplayName(int tier) {
    switch (tier) {
      case 0:
      case 1:
        return '普通';
      case 2:
        return '优秀';
      case 3:
        return '稀有';
      case 4:
        return '史诗';
      case 5:
      case 6:
        return '传说';
      default:
        return '神话';
    }
  }

  String _tierName(Object? value) {
    final tier = _tierValue(value);
    switch (tier) {
      case 0:
      case 1:
      case 2:
        return 'common';
      case 3:
        return 'excellent';
      case 4:
      case 5:
        return 'rare';
      case 6:
        return 'epic';
      case 7:
        return 'legendary';
      default:
        return 'special';
    }
  }

  int _rarityTier(String rarity) {
    switch (rarity) {
      case 'myth':
      case '神话':
        return 7;
      case 'legend':
      case 'legendary':
      case '传说':
        return 6;
      case 'epic':
      case '史诗':
        return 5;
      case 'rare':
      case '稀有':
        return 4;
      case 'good':
      case 'excellent':
      case '优秀':
        return 3;
      default:
        return 1;
    }
  }

  String _rarityDisplayName(String rarity) {
    switch (rarity) {
      case 'myth':
        return '神话';
      case 'legend':
      case 'legendary':
        return '传说';
      case 'epic':
        return '史诗';
      case 'rare':
        return '稀有';
      case 'good':
      case 'excellent':
        return '优秀';
      default:
        return '普通';
    }
  }
}

class WalletManagerView extends ChangeNotifier {
  WalletManagerView({int initialFishCoin = 1000}) : _fishCoin = initialFishCoin;

  int _fishCoin;
  int get fishCoin => _fishCoin;

  int _points = 0;
  int get points => _points;

  int _cashPlaceholder = 0;
  int get cashPlaceholder => _cashPlaceholder;

  bool canSpend(int amount) => amount >= 0 && _fishCoin >= amount;

  bool spend(int amount) {
    if (!canSpend(amount)) return false;
    _fishCoin -= amount;
    notifyListeners();
    return true;
  }

  void add(int amount) {
    if (amount <= 0) return;
    _fishCoin += amount;
    notifyListeners();
  }

  void addPoints(int amount) {
    if (amount <= 0) return;
    _points += amount;
    notifyListeners();
  }

  void setCashPlaceholder(int amount) {
    if (amount < 0) return;
    _cashPlaceholder = amount;
    notifyListeners();
  }

  final CoreManagerState _state =
      const CoreManagerState(ready: true, message: 'wallet ready');
  CoreManagerState get state => _state;
}

class InventoryManagerView extends ChangeNotifier {
  InventoryManagerView();

  final Map<String, InventoryEntry> _owned = <String, InventoryEntry>{};
  final Set<String> _loadedCatalogIds = <String>{};
  int _releaseCount = 0;

  int get releaseCount => _releaseCount;
  List<InventoryEntry> get entries => _owned.values.toList(growable: false);

  List<InventoryEntry> sortedEntries(InventoryConfig inventory,
      {String category = 'all'}) {
    final visible = entriesByCategory(category);
    visible.sort((a, b) {
      final catalogA = inventory.itemById(a.itemId);
      final catalogB = inventory.itemById(b.itemId);
      final order =
          (catalogA?.sortOrder ?? 999).compareTo(catalogB?.sortOrder ?? 999);
      if (order != 0) return order;
      final categoryOrder = a.category.compareTo(b.category);
      if (categoryOrder != 0) return categoryOrder;
      return a.name.compareTo(b.name);
    });
    return visible;
  }

  List<InventoryEntry> entriesByCategory(String category) {
    final visible =
        entries.where((entry) => entry.quantity > 0).toList(growable: false);
    if (category.isEmpty || category == 'all') return visible;
    return visible
        .where((entry) => entry.category == category)
        .toList(growable: false);
  }

  int ownedOf(String itemId, {int fallback = 0}) =>
      _owned[itemId]?.quantity ?? fallback;

  void ensureCatalogLoaded(InventoryConfig inventory) {
    var changed = false;
    for (final item in inventory.catalog) {
      if (item.initialQuantity <= 0 || _loadedCatalogIds.contains(item.id)) {
        continue;
      }
      _loadedCatalogIds.add(item.id);
      _owned[item.id] = InventoryEntry(
        itemId: item.id,
        name: item.name,
        category: item.category,
        rarity: item.rarity,
        icon: item.icon,
        description: item.description,
        quantity: item.initialQuantity,
      );
      changed = true;
    }
    if (changed) {
      if (kDebugMode) {
        debugPrint('Inventory Log | catalogLoaded count=${_owned.length}');
      }
      notifyListeners();
    }
  }

  void addItem({
    required String itemId,
    required String name,
    required String category,
    required String rarity,
    required String icon,
    required String description,
    int quantity = 1,
  }) {
    if (itemId.isEmpty || quantity <= 0) return;
    final current = _owned[itemId];
    _owned[itemId] = (current ??
            InventoryEntry(
              itemId: itemId,
              name: name,
              category: category,
              rarity: rarity,
              icon: icon,
              description: description,
              quantity: 0,
            ))
        .copyWith(
      quantity: (current?.quantity ?? 0) + quantity,
      name: name,
      category: category,
      rarity: rarity,
      icon: icon,
      description: description,
    );
    notifyListeners();
  }

  bool removeOne(String itemId) {
    final current = _owned[itemId];
    if (current == null || current.quantity <= 0) return false;
    final nextQuantity = current.quantity - 1;
    if (nextQuantity <= 0) {
      _owned.remove(itemId);
    } else {
      _owned[itemId] = current.copyWith(quantity: nextQuantity);
    }
    notifyListeners();
    return true;
  }

  bool sellItem({
    required InventoryCatalogItem item,
    required WalletManagerView wallet,
    required TransactionManagerView transactions,
  }) {
    if (!item.canSell || item.sellPrice <= 0) return false;
    final removed = removeOne(item.id);
    if (!removed) return false;
    wallet.add(item.sellPrice);
    transactions.addRecord(
      TransactionRecord(
        id: 'tx_${WorldClockManager.timestampId()}',
        type: item.category == 'fish' ? 'sell_fish' : 'sell_item',
        currency: 'fish_coin',
        amount: item.sellPrice,
        itemId: item.id,
        itemName: item.name,
        createdAt: WorldClockManager.systemNow(),
        category: 'income',
        note: '背包出售 ${item.name}',
      ),
    );
    if (kDebugMode) {
      debugPrint(
          'Inventory Log | sell item=${item.name} price=${item.sellPrice}');
    }
    return true;
  }

  bool releaseFish(InventoryCatalogItem item) {
    if (item.category != 'fish') return false;
    final removed = removeOne(item.id);
    if (removed) {
      _releaseCount += 1;
    }
    if (kDebugMode) {
      debugPrint(
          'Inventory Log | releaseFish item=${item.name} removed=$removed');
    }
    return removed;
  }

  Map<String, InventoryEntry> snapshot() =>
      Map<String, InventoryEntry>.unmodifiable(_owned);
}

class CollectionRecord {
  const CollectionRecord({
    required this.fishId,
    required this.fishName,
    required this.rarity,
    required this.category,
    required this.discoveredAt,
    required this.catchCount,
  });

  final String fishId;
  final String fishName;
  final String rarity;
  final String category;
  final DateTime discoveredAt;
  final int catchCount;

  CollectionRecord copyWith({
    String? fishId,
    String? fishName,
    String? rarity,
    String? category,
    DateTime? discoveredAt,
    int? catchCount,
  }) {
    return CollectionRecord(
      fishId: fishId ?? this.fishId,
      fishName: fishName ?? this.fishName,
      rarity: rarity ?? this.rarity,
      category: category ?? this.category,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      catchCount: catchCount ?? this.catchCount,
    );
  }
}

class CollectionManagerView extends ChangeNotifier {
  final Map<String, CollectionRecord> _records = <String, CollectionRecord>{};

  List<CollectionRecord> get records => _records.values.toList(growable: false);
  Set<String> get discoveredIds => _records.keys.toSet();

  bool isDiscovered(String fishId) => _records.containsKey(fishId);

  CollectionRecord? recordOf(String fishId) => _records[fishId];

  void discoverFish({
    required String fishId,
    required String fishName,
    required String rarity,
    required String category,
  }) {
    if (fishId.isEmpty) return;
    final now = WorldClockManager.systemNow();
    final current = _records[fishId];
    _records[fishId] = current == null
        ? CollectionRecord(
            fishId: fishId,
            fishName: fishName,
            rarity: rarity,
            category: category,
            discoveredAt: now,
            catchCount: 1,
          )
        : current.copyWith(
            fishName: fishName,
            rarity: rarity,
            category: category,
            catchCount: current.catchCount + 1,
          );
    if (kDebugMode) {
      debugPrint(
          'Collection Log | fish=$fishName id=$fishId discovered=${current == null}');
    }
    notifyListeners();
  }
}

class InventoryEntry {
  const InventoryEntry({
    required this.itemId,
    required this.name,
    required this.category,
    required this.rarity,
    required this.icon,
    required this.description,
    required this.quantity,
    this.companionPotential = false,
  });

  final String itemId;
  final String name;
  final String category;
  final String rarity;
  final String icon;
  final String description;
  final int quantity;
  final bool companionPotential;

  InventoryEntry copyWith({
    String? itemId,
    String? name,
    String? category,
    String? rarity,
    String? icon,
    String? description,
    int? quantity,
    bool? companionPotential,
  }) {
    return InventoryEntry(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      companionPotential: companionPotential ?? this.companionPotential,
    );
  }
}

class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.type,
    required this.currency,
    required this.amount,
    required this.itemId,
    required this.itemName,
    required this.createdAt,
    this.category = '',
    this.note = '',
  });

  final String id;
  final String type;
  final String currency;
  final int amount;
  final String itemId;
  final String itemName;
  final DateTime createdAt;
  final String category;
  final String note;

  String get amountLabel => amount == 0
      ? '0'
      : isExpense
          ? '-${amount.abs()}'
          : '+${amount.abs()}';
  bool get isExpense =>
      normalizedCategory == 'expense' || normalizedCategory == 'purchase';
  bool get isIncome =>
      normalizedCategory == 'income' || normalizedCategory == 'reward';
  String get normalizedCategory => _normalizeCategory(category, amount);

  static String _normalizeCategory(String value, int amount) {
    if (value.trim().isEmpty) return amount < 0 ? 'expense' : 'income';
    return value.trim().toLowerCase();
  }
}

class MemoryRecord {
  const MemoryRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.createdAt,
    this.payload = const {},
  });

  final String id;
  final String type;
  final String title;
  final DateTime createdAt;
  final Map<String, dynamic> payload;
}

class MemoryManagerView extends ChangeNotifier {
  final List<MemoryRecord> _records = <MemoryRecord>[];

  List<MemoryRecord> get records => List<MemoryRecord>.unmodifiable(_records);

  void addRecord(MemoryRecord record) {
    _records.add(record);
    notifyListeners();
  }
}

class TransactionManagerView extends ChangeNotifier {
  TransactionManagerView({List<TransactionRecord> initialRecords = const []}) {
    _records.addAll(initialRecords);
  }

  TransactionManagerView.fromConfig(TransactionConfig config) {
    _records.addAll(
      config.records.map(
        (item) => TransactionRecord(
          id: item.id,
          type: item.type,
          currency: item.currency,
          amount: item.parsedAmount,
          itemId: item.itemId.isNotEmpty ? item.itemId : item.id,
          itemName: item.itemName.isNotEmpty ? item.itemName : item.type,
          createdAt: item.parsedCreatedAt,
          category: item.category,
          note: item.note,
        ),
      ),
    );
  }

  final List<TransactionRecord> _records = <TransactionRecord>[];
  String _activeFilter = 'all';

  List<TransactionRecord> get records =>
      List<TransactionRecord>.unmodifiable(_records);
  String get activeFilter => _activeFilter;
  List<TransactionRecord> filteredRecords([String? filterId]) {
    final resolvedFilter = (filterId ?? _activeFilter).trim().toLowerCase();
    if (resolvedFilter.isEmpty || resolvedFilter == 'all') {
      return List<TransactionRecord>.unmodifiable(_records);
    }
    return List<TransactionRecord>.unmodifiable(
      _records
          .where((record) => _matchesFilter(record, resolvedFilter))
          .toList(growable: false),
    );
  }

  void addRecord(TransactionRecord record) {
    _records.add(record);
    notifyListeners();
  }

  void setFilter(String filterId) {
    final normalized = filterId.trim().toLowerCase();
    if (normalized.isEmpty || normalized == _activeFilter) return;
    _activeFilter = normalized;
    if (kDebugMode) {
      debugPrint(
          'Transaction Log | filter=$_activeFilter count=${filteredRecords().length}');
    }
    notifyListeners();
  }

  bool _matchesFilter(TransactionRecord record, String filterId) {
    final category = record.normalizedCategory;
    if (filterId == 'expense') {
      return category == 'expense' || category == 'purchase';
    }
    if (filterId == 'income') {
      return category == 'income' || category == 'reward';
    }
    return category == filterId;
  }
}

class HonorProgressView {
  const HonorProgressView({
    required this.config,
    required this.progress,
    required this.status,
    required this.obtainedAt,
  });

  final HonorBadge config;
  final int progress;
  final String status;
  final String obtainedAt;

  int get cappedProgress =>
      config.target <= 0 ? progress : progress.clamp(0, config.target);
  bool get obtained => status == 'obtained' || status == 'equipped';
  bool get equipped => status == 'equipped';
}

class HonorManagerView extends ChangeNotifier {
  final Map<String, int> _metrics = <String, int>{
    'login_days': 1,
  };
  final Map<String, String> _obtainedAt = <String, String>{};

  Map<String, int> get metrics => Map<String, int>.unmodifiable(_metrics);

  void syncFromState({
    required HonorConfig honor,
    required FishCollectionConfig fishCollection,
    required FishingProvider fishing,
    required WalletManagerView wallet,
    required InventoryManagerView inventory,
    required CollectionManagerView collection,
    required TransactionManagerView transactions,
    required TaskManagerView tasks,
    required TaskConfig taskConfig,
  }) {
    final fishingCount =
        fishing.fishingEvents.where((event) => event.type == 'started').length;
    final sellCount = transactions.records
        .where((record) =>
            record.type == 'sell_fish' || record.type == 'sell_item')
        .length;
    final incomeTotal = transactions.records
        .where((record) =>
            record.normalizedCategory == 'income' ||
            record.normalizedCategory == 'reward')
        .fold<int>(0, (sum, record) => sum + record.amount.abs());
    final totalFish =
        fishCollection.fishes.isEmpty ? 1 : fishCollection.fishes.length;
    final collectionRate =
        (collection.records.length / totalFish * 100).clamp(0, 100).round();
    final taskCompleted = tasks
        .visibleTasks(taskConfig, 'all')
        .where((task) => task.status == 'completed')
        .length;
    final obtainedCount = honor.badges
        .where((badge) =>
            _statusFor(badge) == 'obtained' || _statusFor(badge) == 'equipped')
        .length;
    final next = <String, int>{
      'login_days': 1,
      'fishing_count': fishingCount,
      'sell_count': sellCount,
      'release_count': inventory.releaseCount,
      'collection_count': collection.records.length,
      'collection_rate': collectionRate,
      'task_completed': taskCompleted,
      'inventory_count':
          inventory.entries.fold<int>(0, (sum, entry) => sum + entry.quantity),
      'experience': wallet.points,
      'fish_coin': wallet.fishCoin,
      'income_total': incomeTotal,
      'lucky_count': 0,
      'honor_value': wallet.points + obtainedCount * 50,
    };
    var changed = !_mapEquals(_metrics, next);
    _metrics
      ..clear()
      ..addAll(next);
    for (final badge in honor.badges) {
      final status = _statusFor(badge);
      if ((status == 'obtained' || status == 'equipped') &&
          !_obtainedAt.containsKey(badge.id)) {
        _obtainedAt[badge.id] =
            badge.obtainedAt.isNotEmpty ? badge.obtainedAt : '预留';
        changed = true;
      }
    }
    if (changed) {
      if (kDebugMode) {
        debugPrint('Honor Log | metrics=$_metrics');
      }
      notifyListeners();
    }
  }

  List<HonorProgressView> visibleHonors(HonorConfig config, String categoryId) {
    final items = config.badges
        .where((badge) => categoryId == 'all' || badge.category == categoryId)
        .map((badge) => HonorProgressView(
              config: badge,
              progress: _progressFor(badge),
              status: _statusFor(badge),
              obtainedAt: _obtainedAt[badge.id] ?? badge.obtainedAt,
            ))
        .toList(growable: false);
    items.sort((a, b) => a.config.sortOrder.compareTo(b.config.sortOrder));
    return items;
  }

  HonorProgressView? honorById(HonorConfig config, String id) {
    for (final view in visibleHonors(config, 'all')) {
      if (view.config.id == id) return view;
    }
    return null;
  }

  int _progressFor(HonorBadge badge) {
    if (badge.metric.isEmpty) return badge.progress;
    return (_metrics[badge.metric] ?? badge.progress)
        .clamp(0, badge.target <= 0 ? 999999 : badge.target);
  }

  String _statusFor(HonorBadge badge) {
    if (badge.status == 'equipped' || badge.equipped) return 'equipped';
    if (badge.status == 'obtained' || badge.obtained) return 'obtained';
    final progress = _progressFor(badge);
    if (badge.target > 0 && progress >= badge.target) return 'obtained';
    return 'not_obtained';
  }

  bool _mapEquals(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}

class TaskProgressView {
  const TaskProgressView({
    required this.config,
    required this.progress,
    required this.status,
  });

  final TaskItemConfig config;
  final int progress;
  final String status;

  int get cappedProgress => progress.clamp(0, config.target);
  bool get canClaim => status == 'claimable';
}

class TaskManagerView extends ChangeNotifier {
  final Map<String, int> _metrics = <String, int>{
    'login_days': 1,
  };
  final Map<String, int> _dailyMetrics = <String, int>{};
  final Set<String> _claimedTaskIds = <String>{};
  int? _lastDailyRefreshDay;

  Map<String, int> get metrics => Map<String, int>.unmodifiable(_metrics);
  Map<String, int> get dailyMetrics =>
      Map<String, int>.unmodifiable(_dailyMetrics);
  Set<String> get claimedTaskIds => Set<String>.unmodifiable(_claimedTaskIds);
  int? get lastDailyRefreshDay => _lastDailyRefreshDay;

  void syncFromState({
    required FishingProvider fishing,
    required InventoryManagerView inventory,
    required CollectionManagerView collection,
    required TransactionManagerView transactions,
  }) {
    final next = <String, int>{
      'login_days': 1,
      'fishing_count': fishing.fishingEvents
          .where((event) => event.type == 'started')
          .length,
      'sell_count': transactions.records
          .where((record) =>
              record.type == 'sell_fish' || record.type == 'sell_item')
          .length,
      'release_count': inventory.releaseCount,
      'fish_obtained_count': collection.records
          .fold<int>(0, (sum, record) => sum + record.catchCount),
      'inventory_count':
          inventory.entries.fold<int>(0, (sum, entry) => sum + entry.quantity),
      'collection_count': collection.records.length,
    };
    if (!_mapEquals(_metrics, next)) {
      _metrics
        ..clear()
        ..addAll(next);
      if (kDebugMode) {
        debugPrint('Task Log | metrics=$_metrics');
      }
      notifyListeners();
    }
  }

  void syncFromQuest({
    required Map<String, int> cumulativeMetrics,
    required Map<String, int> dailyMetrics,
    required int dayCount,
    required Iterable<String> dailyTaskIds,
  }) {
    var changed = false;
    if (_lastDailyRefreshDay != dayCount) {
      _lastDailyRefreshDay = dayCount;
      _claimedTaskIds.removeAll(dailyTaskIds);
      changed = true;
    }
    if (!_mapEquals(_metrics, cumulativeMetrics)) {
      _metrics
        ..clear()
        ..addAll(cumulativeMetrics);
      changed = true;
    }
    if (!_mapEquals(_dailyMetrics, dailyMetrics)) {
      _dailyMetrics
        ..clear()
        ..addAll(dailyMetrics);
      changed = true;
    }
    if (changed) {
      if (kDebugMode) {
        debugPrint(
            'Task Log | quest day=$_lastDailyRefreshDay metrics=$_metrics daily=$_dailyMetrics');
      }
      notifyListeners();
    }
  }

  List<TaskProgressView> visibleTasks(TaskConfig config, String categoryId) {
    final tasks = config.tasks
        .where((task) => categoryId == 'all' || task.category == categoryId)
        .map((task) => TaskProgressView(
              config: task,
              progress: _progressFor(task),
              status: _statusFor(task),
            ))
        .toList(growable: false);
    final sorted = List<TaskProgressView>.from(tasks)
      ..sort((a, b) => a.config.sortOrder.compareTo(b.config.sortOrder));
    return sorted;
  }

  bool claimReward({
    required TaskItemConfig task,
    required WalletManagerView wallet,
    required TransactionManagerView transactions,
  }) {
    if (_statusFor(task) != 'claimable') return false;
    _claimedTaskIds.add(task.id);
    if (task.reward.fishCoin > 0) {
      wallet.add(task.reward.fishCoin);
    }
    if (task.reward.exp > 0) {
      wallet.addPoints(task.reward.exp);
    }
    transactions.addRecord(
      TransactionRecord(
        id: 'tx_${WorldClockManager.timestampId()}',
        type: 'task_reward',
        currency: 'fish_coin',
        amount: task.reward.fishCoin,
        itemId: task.id,
        itemName: task.title,
        createdAt: WorldClockManager.systemNow(),
        category: 'reward',
        note: '领取任务奖励 ${task.title}',
      ),
    );
    if (kDebugMode) {
      debugPrint(
          'Task Log | claim=${task.id} fishCoin=${task.reward.fishCoin} exp=${task.reward.exp}');
    }
    notifyListeners();
    return true;
  }

  int _progressFor(TaskItemConfig task) {
    final source = task.category == 'daily' ? _dailyMetrics : _metrics;
    final current =
        source[task.metric] ?? _metrics[task.metric] ?? task.progress;
    return current.clamp(0, task.target);
  }

  String _statusFor(TaskItemConfig task) {
    if (_claimedTaskIds.contains(task.id) || task.status == 'completed') {
      return 'completed';
    }
    final progress = _progressFor(task);
    if (progress >= task.target) return 'claimable';
    if (progress <= 0) return 'not_started';
    return 'in_progress';
  }

  bool _mapEquals(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}

class SettingsManagerView extends ChangeNotifier {
  SettingsManagerView(this.config) {
    _applyDefaults();
  }

  final SettingsConfig config;
  final Map<String, String> _values = <String, String>{};
  String _statusMessage = '';

  String get statusMessage => _statusMessage;

  String valueOf(String id) {
    final item = config.itemById(id);
    if (item == null) return '';
    return _values[id] ?? item.defaultValue;
  }

  bool isEnabled(String id) => valueOf(id) == 'on';

  void toggle(String id) {
    final item = config.itemById(id);
    if (item == null || !item.isToggle) return;
    _values[id] = isEnabled(id) ? 'off' : 'on';
    _statusMessage = '';
    if (kDebugMode) {
      debugPrint('Settings Log | toggle=$id value=${_values[id]}');
    }
    notifyListeners();
  }

  void select(String id, String value) {
    final item = config.itemById(id);
    if (item == null || !item.isSegment || value.isEmpty) return;
    _values[id] = value;
    _statusMessage = '';
    if (kDebugMode) {
      debugPrint('Settings Log | select=$id value=$value');
    }
    notifyListeners();
  }

  void save() {
    _statusMessage = config.savedMessage;
    if (kDebugMode) {
      debugPrint('Settings Log | save message=${config.savedMessage}');
    }
    notifyListeners();
  }

  void restoreDefaults() {
    _applyDefaults();
    _statusMessage = config.restoredMessage;
    if (kDebugMode) {
      debugPrint(
          'Settings Log | restoreDefaults message=${config.restoredMessage}');
    }
    notifyListeners();
  }

  void clearCache() {
    _statusMessage = config.cacheClearedMessage;
    if (kDebugMode) {
      debugPrint(
          'Settings Log | clearCache message=${config.cacheClearedMessage}');
    }
    notifyListeners();
  }

  void _applyDefaults() {
    _values.clear();
    for (final item in config.items) {
      if (item.isToggle) {
        _values[item.id] = _normalizeToggle(item.defaultValue);
        continue;
      }
      if (item.isSegment) {
        _values[item.id] = _normalizeSegment(item);
      }
    }
  }

  String _normalizeToggle(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'off' ||
        normalized == '关' ||
        normalized == 'false' ||
        normalized == '0') {
      return 'off';
    }
    return 'on';
  }

  String _normalizeSegment(SettingsItem item) {
    if (item.defaultValue.isNotEmpty) return item.defaultValue;
    return item.options.isNotEmpty ? item.options.first.id : '';
  }
}

class CompanionManagerView extends ChangeNotifier {
  CompanionManagerView(this.giftManager);
  final CompanionGiftManager giftManager;
}

class AppRouterState extends ChangeNotifier {
  AppRouterState({required this.startPath});
  final String startPath;
  String _currentPath = '';
  String get currentPath => _currentPath.isEmpty ? startPath : _currentPath;
  void setPath(String value) {
    _currentPath = value;
    notifyListeners();
  }
}

class RouteGuard {
  const RouteGuard();
  bool allow(String path) => path.isNotEmpty;
}

class DeepLinkParser {
  const DeepLinkParser();
  String parse(Uri uri) => uri.path.isEmpty ? '/' : uri.path;
}

class JsonRuntimeState extends ChangeNotifier {
  CoreManagerState _state = const CoreManagerState();
  CoreManagerState get state => _state;
  void markReady(String message) {
    _state = CoreManagerState(ready: true, message: message);
    notifyListeners();
  }
}
