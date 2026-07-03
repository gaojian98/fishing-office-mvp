import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../managers/app_managers.dart';
import '../providers/app_providers.dart';

enum RuntimeStatus { loading, success, empty, error }

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
  bool get isEmpty => wallet.fishCoin == 0 && inventory.entries.isEmpty && transactions.records.isEmpty && fishing.result == null;

  String get currentBait => fishing.currentBaitLabel;
  String get currentFish => fishing.currentResultLabel;
  String get fishingState => fishing.stateLabel;
  String get sessionId => fishing.session?.id ?? '-';
  List<String> get waitingEvents => fishing.waitingMessages;
  int get inventoryCount => inventory.entries.fold<int>(0, (sum, entry) => sum + entry.quantity);
  int get transactionCount => transactions.records.length;
  String get currentWeather => weather.preview.description;
  String get currentToday => today.preview.mood.description;
  String get targetChain => fishChain.describePath(fishing.session?.initialData['baitId']?.toString() ?? 'bait_basic');

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
