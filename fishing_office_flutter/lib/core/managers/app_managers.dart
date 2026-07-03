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
  });

  final String eventType;
  final String message;
  final String effectType;
  final num effectValue;
  final String target;
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
    ),
    WaitingEventTemplate(
      eventType: 'fish_nearby',
      message: '好像有鱼靠近。',
      effectType: 'proximity',
      effectValue: 1,
      target: 'bait',
    ),
    WaitingEventTemplate(
      eventType: 'bait_touched',
      message: '鱼饵被轻轻试探。',
      effectType: 'tension',
      effectValue: 1,
      target: 'bait',
    ),
    WaitingEventTemplate(
      eventType: 'fish_group_passed',
      message: '海面突然安静了。',
      effectType: 'silence',
      effectValue: 0,
      target: 'water',
    ),
    WaitingEventTemplate(
      eventType: 'old_fisherman_hint',
      message: '老渔夫说：别急，再等等。',
      effectType: 'hint',
      effectValue: 0,
      target: 'player',
    ),
    WaitingEventTemplate(
      eventType: 'bait_half_eaten',
      message: '鱼饵被轻轻试探，像是少了一点。',
      effectType: 'bite',
      effectValue: 1,
      target: 'bait',
    ),
  ];

  List<WaitingEvent> buildForSession({
    required String sessionId,
    required String baitLabel,
    required String chainLabel,
    required bool hasNextBait,
  }) {
    final count = 1 + (sessionId.hashCode.abs() % 3);
    final selected = <WaitingEventTemplate>[];
    final startIndex = hasNextBait ? 1 : 0;
    for (var i = 0; i < count - startIndex; i++) {
      selected.add(_templates[(sessionId.hashCode + i).abs() % _templates.length]);
    }
    final intro = hasNextBait ? '你把 $baitLabel 作为鱼饵抛了出去。' : '你把鱼饵抛了出去。';
    final result = <WaitingEvent>[
      if (hasNextBait)
        WaitingEvent(
          eventId: '${sessionId}_intro',
          sessionId: sessionId,
          eventType: 'bait_cast',
          time: DateTime.now(),
          message: intro,
          effect: 'bait_cast',
          visibleToPlayer: true,
          payload: {'chain': chainLabel},
          effectType: 'narrative',
          effectValue: 0,
          target: 'bait',
        ),
      for (var i = 0; i < selected.length; i++)
        WaitingEvent(
          eventId: '${sessionId}_wait_${i + 1}',
          sessionId: sessionId,
          eventType: selected[i].eventType,
          time: DateTime.now(),
          message: selected[i].message,
          effect: selected[i].effectType,
          visibleToPlayer: true,
          payload: {
            'chain': chainLabel,
            'baitLabel': baitLabel,
            'visibleToPlayer': true,
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
      debugPrint('Waiting Log | session=$sessionId events=${result.length} bait=$baitLabel');
    }
    return result;
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
          FishChainEntry(id: 'bait_basic', name: '基础鱼饵', nextFishId: 'fish_small', tier: 0),
          FishChainEntry(id: 'fish_small', name: '小鱼', nextFishId: 'fish_basa', tier: 1),
          FishChainEntry(id: 'fish_basa', name: '巴沙鱼', nextFishId: 'fish_tilapia', tier: 2),
          FishChainEntry(id: 'fish_tilapia', name: '罗非鱼', nextFishId: 'fish_mackerel', tier: 3),
          FishChainEntry(id: 'fish_mackerel', name: '鲭鱼', nextFishId: 'fish_grouper', tier: 4),
          FishChainEntry(id: 'fish_grouper', name: '石斑鱼', nextFishId: 'fish_tuna', tier: 5),
          FishChainEntry(id: 'fish_tuna', name: '金枪鱼', nextFishId: 'fish_legend', tier: 6),
          FishChainEntry(id: 'fish_legend', name: '传奇鱼', nextFishId: 'fish_legend', tier: 7),
        ];

  final List<FishChainEntry> _entries;

  List<FishChainEntry> get entries => List<FishChainEntry>.unmodifiable(_entries);

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
  })
      : _engine = engine ?? FishingEngine(oceanEngine: OceanEngine()),
        _waitingEngine = waitingEngine ?? WaitingEngine(),
        _chainProvider = chainProvider ?? FishChainProvider(),
        _waitingEventManager = waitingEventManager ?? WaitingEventManagerView(WaitingEngine());

  final FishingEngine _engine;
  final WaitingEngine _waitingEngine;
  final FishChainProvider _chainProvider;
  final WaitingEventManagerView _waitingEventManager;
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
  List<WaitingEvent> get waitingEvents => List<WaitingEvent>.unmodifiable(_waitingEvents);
  List<FishingEvent> get fishingEvents => List<FishingEvent>.unmodifiable(_fishingEvents);
  String get currentBaitLabel {
    final baitId = _nextBaitId ?? _session?.initialData['baitId']?.toString() ?? 'bait_basic';
    return _chainProvider.entryById(baitId).name;
  }

  String get currentChainLabel {
    final baitId = _nextBaitId ?? _session?.initialData['baitId']?.toString() ?? 'bait_basic';
    return _chainProvider.describePath(baitId);
  }
  String get currentResultLabel => _result?.fishName ?? '暂无结果';
  String get currentWaitingLabel => _waitingEvents.isEmpty ? '暂无等待事件' : _waitingEvents.first.message;
  List<String> get waitingMessages => _waitingEvents.map((event) => event.message).toList(growable: false);
  String get currentActionsLabel {
    final items = <String>[
      if (_state == 'waiting') '可以收线',
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

  void throwLine({String baitId = 'bait_mock'}) {
    final effectiveBaitId = _nextBaitId ?? baitId;
    if (kDebugMode) {
      debugPrint('Fishing Log | throwLine bait=$effectiveBaitId state=$_state');
    }
    _session = _engine.createSession(
      initialData: {
        'baitId': effectiveBaitId,
        'startTime': DateTime.now().toIso8601String(),
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

  void pullLine() {
    if (_state != 'waiting' && _state != 'fishInterested' && _state != 'fishHooked') {
      return;
    }
    if (_session == null) return;
    _state = 'pulling';
    notifyListeners();
    final resolved = _buildResult(
      _session!.id,
      baitId: _session!.initialData['baitId']?.toString() ?? 'bait_basic',
      nextFish: _pendingFish ?? _chainProvider.nextEntryFor(_session!.initialData['baitId']?.toString() ?? 'bait_basic'),
    );
    _result = resolved;
    _state = 'finished';
    if (kDebugMode) {
      debugPrint('Fishing Log | pullLine result=${resolved.fishName} tier=${resolved.metadata['tier']}');
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
        id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
        type: 'sell_fish',
        currency: 'fish_coin',
        amount: result.value,
        itemId: result.fishId,
        itemName: result.fishName,
        createdAt: DateTime.now(),
      ),
    );
    wallet.addPoints(result.points);
    if (kDebugMode) {
      debugPrint('Wallet Log | sellFish coin+=${result.value} points+=${result.points}');
      debugPrint('Transaction Log | sell_fish item=${result.fishName} amount=${result.value}');
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
          id: 'memory_${DateTime.now().microsecondsSinceEpoch}',
          type: 'companionPotential',
          title: result.fishName,
          createdAt: DateTime.now(),
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
        'baseCoin': 120 + (nextTier * 30),
        'baitId': baitId,
        'path': _chainProvider.describePath(baitId),
        'canUseAsBait': true,
      },
    );
  }

  void _clearResult() {
    _result = null;
    _pendingFish = null;
    _waitingEvents.clear();
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
}

class WalletManagerView extends ChangeNotifier {
  WalletManagerView({int initialFishCoin = 1000})
      : _fishCoin = initialFishCoin;

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

  final CoreManagerState _state = const CoreManagerState(ready: true, message: 'wallet ready');
  CoreManagerState get state => _state;
}

class InventoryManagerView extends ChangeNotifier {
  InventoryManagerView();

  final Map<String, InventoryEntry> _owned = <String, InventoryEntry>{};

  List<InventoryEntry> get entries => _owned.values.toList(growable: false);

  List<InventoryEntry> entriesByCategory(String category) {
    if (category.isEmpty || category == 'all') return entries;
    return entries.where((entry) => entry.category == category).toList(growable: false);
  }

  int ownedOf(String itemId, {int fallback = 0}) => _owned[itemId]?.quantity ?? fallback;

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
    _owned[itemId] = (current ?? InventoryEntry(
      itemId: itemId,
      name: name,
      category: category,
      rarity: rarity,
      icon: icon,
      description: description,
      quantity: 0,
    )).copyWith(
      quantity: (current?.quantity ?? 0) + quantity,
      name: name,
      category: category,
      rarity: rarity,
      icon: icon,
      description: description,
    );
    notifyListeners();
  }

  Map<String, InventoryEntry> snapshot() => Map<String, InventoryEntry>.unmodifiable(_owned);
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
  });

  final String id;
  final String type;
  final String currency;
  final int amount;
  final String itemId;
  final String itemName;
  final DateTime createdAt;
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
  final List<TransactionRecord> _records = <TransactionRecord>[];

  List<TransactionRecord> get records => List<TransactionRecord>.unmodifiable(_records);

  void addRecord(TransactionRecord record) {
    _records.add(record);
    notifyListeners();
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
