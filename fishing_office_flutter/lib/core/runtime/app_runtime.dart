import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../managers/app_managers.dart';
import '../providers/app_providers.dart';

enum RuntimeStatus { loading, success, empty, error }

class UiRuntimeSnapshot {
  const UiRuntimeSnapshot({
    required this.clockLabel,
    required this.timeOfDay,
    required this.weatherLabel,
    required this.weatherType,
    required this.windLevel,
    required this.festivalLabel,
    required this.festivalTags,
    required this.dailySummary,
    required this.activeEventCount,
    required this.availableEventCount,
    required this.residentContextLabel,
    required this.residentActivity,
    required this.residentDialogue,
  });

  final String clockLabel;
  final String timeOfDay;
  final String weatherLabel;
  final String weatherType;
  final int windLevel;
  final String festivalLabel;
  final List<String> festivalTags;
  final String dailySummary;
  final int activeEventCount;
  final int availableEventCount;
  final String residentContextLabel;
  final String residentActivity;
  final String residentDialogue;

  static const fallback = UiRuntimeSnapshot(
    clockLabel: '第二世界时间准备中',
    timeOfDay: 'day',
    weatherLabel: '天气准备中',
    weatherType: 'sunny',
    windLevel: 1,
    festivalLabel: '今日无节日',
    festivalTags: <String>[],
    dailySummary: '第二世界正在醒来。',
    activeEventCount: 0,
    availableEventCount: 0,
    residentContextLabel: '居民状态准备中',
    residentActivity: '安静看海',
    residentDialogue: '今天也慢一点。',
  );
}

class AppRuntime {
  const AppRuntime({
    required this.status,
    required this.wallet,
    required this.fishing,
    required this.fishChain,
    required this.inventory,
    required this.transactions,
    required this.waiting,
    required this.today,
    required this.weather,
  });

  final RuntimeStatus status;
  final WalletManagerView wallet;
  final FishingProvider fishing;
  final FishChainProvider fishChain;
  final InventoryManagerView inventory;
  final TransactionManagerView transactions;
  final WaitingEventManagerView waiting;
  final TodayManagerView today;
  final WeatherManagerView weather;

  bool get hasData => status == RuntimeStatus.success;
  bool get isEmpty =>
      wallet.fishCoin == 0 &&
      inventory.entries.isEmpty &&
      transactions.records.isEmpty &&
      fishing.result == null;

  String get currentBait => fishing.currentBaitLabel;
  String get currentFish => fishing.currentResultLabel;
  String get fishingState => fishing.stateLabel;
  String get sessionId => fishing.session?.id ?? '-';
  List<String> get waitingEvents => fishing.waitingMessages;
  int get inventoryCount =>
      inventory.entries.fold<int>(0, (sum, entry) => sum + entry.quantity);
  int get transactionCount => transactions.records.length;
  String get currentWeather => weather.preview.description;
  String get currentToday => today.preview.mood.description;
  String get targetChain => fishChain.describePath(
      fishing.session?.initialData['baitId']?.toString() ?? 'bait_basic');

  factory AppRuntime.fromProviders({
    required WalletManagerView wallet,
    required FishingProvider fishing,
    required FishChainProvider fishChain,
    required InventoryManagerView inventory,
    required TransactionManagerView transactions,
    required WaitingEventManagerView waiting,
    required TodayManagerView today,
    required WeatherManagerView weather,
  }) {
    return AppRuntime(
      status: RuntimeStatus.success,
      wallet: wallet,
      fishing: fishing,
      fishChain: fishChain,
      inventory: inventory,
      transactions: transactions,
      waiting: waiting,
      today: today,
      weather: weather,
    );
  }
}

final appRuntimeProvider = Provider<AppRuntime>((ref) {
  final runtime = AppRuntime.fromProviders(
    wallet: ref.watch(walletManagerProvider),
    fishing: ref.watch(fishingProvider),
    fishChain: ref.watch(fishChainProvider),
    inventory: ref.watch(inventoryManagerProvider),
    transactions: ref.watch(transactionManagerProvider),
    waiting: ref.watch(waitingEventManagerProvider),
    today: ref.watch(todayManagerProvider),
    weather: ref.watch(weatherManagerProvider),
  );
  if (kDebugMode) {
    debugPrint(
      'Runtime Log | wallet=${runtime.wallet.fishCoin} inventory=${runtime.inventoryCount} tx=${runtime.transactionCount} bait=${runtime.currentBait} fish=${runtime.currentFish} state=${runtime.fishingState}',
    );
  }
  return runtime;
});

final uiRuntimeSnapshotProvider =
    FutureProvider<UiRuntimeSnapshot>((ref) async {
  final clock = ref.watch(worldClockManagerProvider);
  final daily = await ref.watch(dailySimulationManagerProvider.future);
  final summary = daily.hasRunToday()
      ? daily.getTodayWorldSummary()
      : await daily.runDailySimulation();
  final weather = await ref.watch(weatherRuntimeManagerProvider.future);
  final festival = await ref.watch(festivalRuntimeManagerProvider.future);
  final events = await ref.watch(dynamicEventRuntimeManagerProvider.future);
  final secondWorld = await ref.watch(secondWorldEngineProvider.future);
  final currentWeather = weather.getCurrentWeather();
  final activeFestivals = festival.getActiveFestivals();
  final residentContext = secondWorld.getResidentContext('old_fisher');
  final hour = clock.hour();
  final snapshot = UiRuntimeSnapshot(
    clockLabel:
        'Day ${clock.today().dayCount} ${clock.hour().toString().padLeft(2, '0')}:${clock.minute().toString().padLeft(2, '0')}',
    timeOfDay: _timeOfDay(hour),
    weatherLabel: currentWeather?.name ?? clock.weather().description,
    weatherType: currentWeather?.type ?? clock.weather().weatherType.name,
    windLevel: currentWeather?.windLevel ?? 1,
    festivalLabel: activeFestivals.isEmpty
        ? '今日无节日'
        : activeFestivals.map((item) => item.name).join('、'),
    festivalTags: festival.getFestivalTags(),
    dailySummary: summary?.todayMessage ?? '第二世界正在安静运行。',
    activeEventCount: events.getActiveEvents().length,
    availableEventCount: events.getAvailableEvents().length,
    residentContextLabel:
        '${residentContext.resident.name} / ${residentContext.life.location} / ${residentContext.life.activity} / ${residentContext.life.mood} / ${residentContext.relationship.relationshipLevel}',
    residentActivity: residentContext.life.activity,
    residentDialogue: residentContext.dialogue.text,
  );
  if (kDebugMode) {
    debugPrint(
      'UI Runtime Snapshot | ${snapshot.clockLabel} weather=${snapshot.weatherLabel} festival=${snapshot.festivalLabel} events=${snapshot.availableEventCount}',
    );
  }
  return snapshot;
});

String _timeOfDay(int hour) {
  if (hour >= 5 && hour < 11) return 'morning';
  if (hour >= 11 && hour < 17) return 'day';
  if (hour >= 17 && hour < 20) return 'dusk';
  return 'night';
}
