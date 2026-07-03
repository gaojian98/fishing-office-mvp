import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../animation/animation_manager.dart';
import '../audio/audio_manager.dart';
import '../balance/balance_manager.dart';
import '../dialog/dialog_manager.dart';
import '../engine/companion_gift_manager.dart';
import '../engine/fishing_engine.dart';
import '../engine/life_engine.dart';
import '../engine/meaning_engine.dart';
import '../engine/ocean_engine.dart';
import '../engine/relationship_engine.dart';
import '../engine/time_manager.dart';
import '../engine/today_engine.dart';
import '../engine/waiting_engine.dart';
import '../engine/weather_system.dart';
import '../engine/world_engine.dart';
import '../interaction/interaction_manager.dart';
import '../managers/app_managers.dart';
import '../navigation/navigation_manager.dart';
import '../repository/home_repository.dart';
import '../repository/json/json_source.dart';
import '../repository/store_repository.dart';
import '../managers/app_managers.dart' as app_state;
import '../../services/home_config_loader.dart';
import '../../models/store_config.dart';
import '../../services/store_config_loader.dart';

final jsonSourceProvider = Provider<JsonSource>((ref) => const AssetJsonSource());

final homeConfigBundleProvider = FutureProvider<HomeConfigBundle>((ref) {
  return const HomeConfigLoader().load();
});

final storeConfigBundleProvider = FutureProvider<StoreConfigBundle>((ref) {
  return const StoreConfigLoader().load();
});

final homeRepositoryProvider = FutureProvider<HomeRepositoryBundle>((ref) {
  return const HomeRepositoryLoader().load();
});

final storeRepositoryProvider = Provider<StoreRepositoryLoader>((ref) {
  return const StoreRepositoryLoader();
});

final appStateProvider = ChangeNotifierProvider<app_state.JsonRuntimeState>((ref) => app_state.JsonRuntimeState());

final audioManagerProvider = Provider<AudioManager>((ref) => AudioManager.instance);

final balanceManagerProvider = Provider<BalanceManager>((ref) => BalanceManager());

final _sharedWaitingEngine = WaitingEngine();
final _sharedWaitingEventManager = WaitingEventManagerView(_sharedWaitingEngine);

final balanceViewProvider = ChangeNotifierProvider<BalanceManagerView>((ref) {
  return BalanceManagerView(ref.read(balanceManagerProvider));
});

final worldManagerProvider = ChangeNotifierProvider<WorldManagerView>((ref) {
  return WorldManagerView(WorldEngine());
});

final weatherManagerProvider = ChangeNotifierProvider<WeatherManagerView>((ref) {
  return WeatherManagerView(WeatherSystem());
});

final todayManagerProvider = ChangeNotifierProvider<TodayManagerView>((ref) {
  return TodayManagerView(TodayEngine(timeManager: TimeManager()));
});

final fishingManagerProvider = ChangeNotifierProvider<FishingManagerView>((ref) {
  return FishingManagerView(FishingEngine(oceanEngine: OceanEngine()));
});

final fishChainProvider = ChangeNotifierProvider<FishChainProvider>((ref) {
  return FishChainProvider();
});

final waitingEventManagerProvider = ChangeNotifierProvider<WaitingEventManagerView>((ref) {
  return _sharedWaitingEventManager;
});

final fishingProvider = ChangeNotifierProvider<FishingProvider>((ref) {
  return FishingProvider(
    waitingEngine: _sharedWaitingEngine,
    waitingEventManager: _sharedWaitingEventManager,
  );
});

final waitingManagerProvider = ChangeNotifierProvider<WaitingManagerView>((ref) {
  return WaitingManagerView(_sharedWaitingEngine);
});

final relationshipManagerProvider = ChangeNotifierProvider<RelationshipManagerView>((ref) {
  return RelationshipManagerView(RelationshipEngine());
});

final lifeManagerProvider = ChangeNotifierProvider<LifeManagerView>((ref) {
  return LifeManagerView(LifeEngine(relationshipEngine: RelationshipEngine()));
});

final meaningManagerProvider = ChangeNotifierProvider<MeaningManagerView>((ref) {
  return MeaningManagerView(MeaningEngine());
});

final companionManagerProvider = ChangeNotifierProvider<CompanionManagerView>((ref) {
  return CompanionManagerView(const CompanionGiftManager());
});

final walletManagerProvider = ChangeNotifierProvider<WalletManagerView>((ref) {
  return WalletManagerView();
});

final inventoryManagerProvider = ChangeNotifierProvider<InventoryManagerView>((ref) {
  return InventoryManagerView();
});

final memoryManagerProvider = ChangeNotifierProvider<MemoryManagerView>((ref) {
  return MemoryManagerView();
});

final transactionManagerProvider = ChangeNotifierProvider<TransactionManagerView>((ref) {
  return TransactionManagerView();
});

final animationManagerProvider = Provider<AnimationManager>((ref) {
  throw UnimplementedError('Override from bootstrap');
});

final dialogManagerProvider = Provider<DialogManager>((ref) {
  throw UnimplementedError('Override from bootstrap');
});

final navigationManagerProvider = Provider<NavigationManager>((ref) {
  throw UnimplementedError('Override from bootstrap');
});

final interactionManagerProvider = Provider<InteractionManager>((ref) {
  throw UnimplementedError('Override from bootstrap');
});

final appRouterStateProvider = ChangeNotifierProvider.family<AppRouterState, String>((ref, startPath) {
  return AppRouterState(startPath: startPath);
});
