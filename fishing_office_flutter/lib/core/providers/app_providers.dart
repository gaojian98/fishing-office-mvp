import 'dart:convert';

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
import '../engine/resident_dialogue_engine.dart';
import '../engine/resident_memory_engine.dart';
import '../engine/resident_relationship_engine.dart';
import '../engine/resident_story_engine.dart';
import '../engine/second_world_engine.dart';
import '../engine/relationship_engine.dart';
import '../engine/time_manager.dart';
import '../engine/today_engine.dart';
import '../engine/waiting_engine.dart';
import '../engine/weather_system.dart';
import '../engine/world_engine.dart';
import '../interaction/interaction_manager.dart';
import '../managers/app_managers.dart';
import '../managers/achievement_runtime_manager.dart';
import '../managers/daily_simulation_manager.dart';
import '../managers/dialogue_runtime_manager.dart';
import '../managers/dynamic_event_runtime_manager.dart';
import '../managers/economy_runtime_manager.dart';
import '../managers/festival_runtime_manager.dart';
import '../managers/fish_runtime_manager.dart';
import '../managers/quest_runtime_manager.dart';
import '../managers/resident_decision_manager.dart';
import '../managers/relationship_runtime_manager.dart';
import '../navigation/navigation_manager.dart';
import '../repository/festival_repository.dart';
import '../repository/dynamic_event_repository.dart';
import '../repository/fish_repository.dart';
import '../repository/home_repository.dart';
import '../repository/json/json_source.dart';
import '../repository/rumor_repository.dart';
import '../repository/store_repository.dart';
import '../repository/weather_repository.dart';
import '../repository/world_save_repository.dart';
import '../repository/story_repository.dart';
import '../repository/resident_dialogue_repository.dart';
import '../repository/resident_life_repository.dart';
import '../repository/resident_memory_repository.dart';
import '../repository/resident_repository.dart';
import '../repository/resident_relationship_repository.dart';
import '../repository/resident_story_repository.dart';
import '../repository/living_world_repository.dart';
import '../services/fairy_event_service.dart';
import '../managers/story_manager.dart';
import '../managers/world_clock_manager.dart';
import '../managers/resident_life_manager.dart';
import '../managers/resident_runtime_manager.dart';
import '../managers/rumor_runtime_manager.dart';
import '../managers/story_runtime_manager.dart';
import '../managers/weather_runtime_manager.dart';
import '../managers/world_save_manager.dart';
import '../managers/world_tick_manager.dart';
import '../managers/living_world_managers.dart';
import 'story_provider.dart';
import 'resident_life_provider.dart';
import 'living_world_providers.dart';
import '../managers/app_managers.dart' as app_state;
import '../../services/home_config_loader.dart';
import '../../models/store_config.dart';

final jsonSourceProvider =
    Provider<JsonSource>((ref) => const AssetJsonSource());

final homeConfigBundleProvider = FutureProvider<HomeConfigBundle>((ref) {
  return const HomeConfigLoader().load();
});

final storeConfigBundleProvider = FutureProvider<StoreConfigBundle>((ref) {
  return ref.read(storeRepositoryProvider).load();
});

final homeRepositoryProvider = FutureProvider<HomeRepositoryBundle>((ref) {
  return const HomeRepositoryLoader().load();
});

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepository();
});

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return StoryRepository(source: ref.read(jsonSourceProvider));
});

final residentLifeRepositoryProvider = Provider<ResidentLifeRepository>((ref) {
  return ResidentLifeRepository(source: ref.read(jsonSourceProvider));
});

final residentMemoryRepositoryProvider =
    Provider<ResidentMemoryRepository>((ref) {
  return ResidentMemoryRepository(source: ref.read(jsonSourceProvider));
});

final residentRelationshipRepositoryProvider =
    Provider<ResidentRelationshipRepository>((ref) {
  return ResidentRelationshipRepository(source: ref.read(jsonSourceProvider));
});

final residentDialogueRepositoryProvider =
    Provider<ResidentDialogueRepository>((ref) {
  return ResidentDialogueRepository(source: ref.read(jsonSourceProvider));
});

final residentStoryRepositoryProvider =
    Provider<ResidentStoryRepository>((ref) {
  return ResidentStoryRepository(source: ref.read(jsonSourceProvider));
});

final festivalRepositoryProvider = Provider<FestivalRepository>((ref) {
  return FestivalRepository(source: ref.read(jsonSourceProvider));
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository(source: ref.read(jsonSourceProvider));
});

final fishRepositoryProvider = Provider<FishRepository>((ref) {
  return FishRepository(source: ref.read(jsonSourceProvider));
});

final dynamicEventRepositoryProvider = Provider<DynamicEventRepository>((ref) {
  return DynamicEventRepository(source: ref.read(jsonSourceProvider));
});

final rumorRepositoryProvider = Provider<RumorRepository>((ref) {
  return RumorRepository(source: ref.read(jsonSourceProvider));
});

final worldSaveRepositoryProvider = Provider<WorldSaveRepository>((ref) {
  return InMemoryWorldSaveRepository();
});

final residentRepositoryProvider = Provider<ResidentRepository>((ref) {
  return ResidentRepository(source: ref.read(jsonSourceProvider));
});

final worldClockRepositoryProvider = Provider<WorldClockRepository>((ref) {
  return WorldClockRepository(source: ref.read(jsonSourceProvider));
});

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return MemoryRepository(source: ref.read(jsonSourceProvider));
});

final relationshipLevelRepositoryProvider =
    Provider<RelationshipLevelRepository>((ref) {
  return RelationshipLevelRepository(source: ref.read(jsonSourceProvider));
});

final worldTimelineRepositoryProvider =
    Provider<WorldTimelineRepository>((ref) {
  return WorldTimelineRepository(source: ref.read(jsonSourceProvider));
});

final dialogueContextRepositoryProvider =
    Provider<DialogueContextRepository>((ref) {
  return DialogueContextRepository(source: ref.read(jsonSourceProvider));
});

final eventTriggerRepositoryProvider = Provider<EventTriggerRepository>((ref) {
  return EventTriggerRepository(source: ref.read(jsonSourceProvider));
});

final worldClockManagerProvider =
    ChangeNotifierProvider<WorldClockManager>((ref) {
  return WorldClockManager();
});

final appStateProvider = ChangeNotifierProvider<app_state.JsonRuntimeState>(
    (ref) => app_state.JsonRuntimeState());

final storyManagerProvider = ChangeNotifierProvider<StoryManager>((ref) {
  return StoryManager(ref.read(storyRepositoryProvider));
});

final storyProvider = ChangeNotifierProvider<StoryProvider>((ref) {
  return StoryProvider(ref.read(storyManagerProvider));
});

final residentLifeManagerProvider =
    ChangeNotifierProvider<ResidentLifeManager>((ref) {
  return ResidentLifeManager(
    ref.read(residentLifeRepositoryProvider),
    worldClockManager: ref.read(worldClockManagerProvider),
  );
});

final residentLifeProvider =
    ChangeNotifierProvider<ResidentLifeProvider>((ref) {
  return ResidentLifeProvider(ref.read(residentLifeManagerProvider));
});

final residentRuntimeManagerProvider =
    ChangeNotifierProvider<ResidentRuntimeManager>((ref) {
  return ResidentRuntimeManager(
    residentRepository: ref.read(residentRepositoryProvider),
    lifeRepository: ref.read(residentLifeRepositoryProvider),
    worldClockManager: ref.read(worldClockManagerProvider),
  );
});

final residentMemoryEngineProvider =
    ChangeNotifierProvider<ResidentMemoryEngine>((ref) {
  return ResidentMemoryEngine();
});

final residentRelationshipEngineProvider =
    FutureProvider<ResidentRelationshipEngine>((ref) async {
  final config = await ref.read(residentRelationshipRepositoryProvider).load();
  return ResidentRelationshipEngine(
    config: config,
    memoryEngine: ref.read(residentMemoryEngineProvider),
  );
});

final festivalRuntimeManagerProvider =
    FutureProvider<FestivalRuntimeManager>((ref) async {
  final festivalConfig = await ref.read(festivalRepositoryProvider).load();
  final runtimeManager = ref.read(residentRuntimeManagerProvider);
  if (!runtimeManager.loaded) {
    await runtimeManager.load();
  }
  return FestivalRuntimeManager(
    config: festivalConfig,
    worldClockManager: ref.read(worldClockManagerProvider),
    residentRuntimeManager: runtimeManager,
  );
});

final weatherRuntimeManagerProvider =
    FutureProvider<WeatherRuntimeManager>((ref) async {
  final weatherConfig = await ref.read(weatherRepositoryProvider).load();
  final runtimeManager = ref.read(residentRuntimeManagerProvider);
  if (!runtimeManager.loaded) {
    await runtimeManager.load();
  }
  return WeatherRuntimeManager(
    config: weatherConfig,
    worldClockManager: ref.read(worldClockManagerProvider),
    residentRuntimeManager: runtimeManager,
  );
});

final rumorRuntimeManagerProvider =
    FutureProvider<RumorRuntimeManager>((ref) async {
  final rumorConfig = await ref.read(rumorRepositoryProvider).load();
  final runtimeManager = ref.read(residentRuntimeManagerProvider);
  if (!runtimeManager.loaded) {
    await runtimeManager.load();
  }
  return RumorRuntimeManager(
    config: rumorConfig,
    worldClockManager: ref.read(worldClockManagerProvider),
    festivalRuntimeManager:
        await ref.read(festivalRuntimeManagerProvider.future),
    weatherRuntimeManager: await ref.read(weatherRuntimeManagerProvider.future),
    residentRuntimeManager: runtimeManager,
  );
});

final residentDialogueEngineProvider =
    FutureProvider<ResidentDialogueEngine>((ref) async {
  final dialogueConfig =
      await ref.read(residentDialogueRepositoryProvider).load();
  final lifeManager = ref.read(residentLifeManagerProvider);
  if (!lifeManager.loaded) {
    await lifeManager.load();
  }
  final relationshipEngine =
      await ref.read(residentRelationshipEngineProvider.future);
  return ResidentDialogueEngine(
    config: dialogueConfig,
    lifeManager: lifeManager,
    memoryEngine: ref.read(residentMemoryEngineProvider),
    relationshipEngine: relationshipEngine,
    worldClockManager: ref.read(worldClockManagerProvider),
  );
});

final dialogueRuntimeManagerProvider =
    FutureProvider<DialogueRuntimeManager>((ref) async {
  final dialogueConfig =
      await ref.read(residentDialogueRepositoryProvider).load();
  final runtimeManager = ref.read(residentRuntimeManagerProvider);
  if (!runtimeManager.loaded) {
    await runtimeManager.load();
  }
  final relationshipEngine =
      await ref.read(residentRelationshipEngineProvider.future);
  final festivalRuntime = await ref.read(festivalRuntimeManagerProvider.future);
  final weatherRuntime = await ref.read(weatherRuntimeManagerProvider.future);
  final rumorRuntime = await ref.read(rumorRuntimeManagerProvider.future);
  return DialogueRuntimeManager(
    config: dialogueConfig,
    residentRuntimeManager: runtimeManager,
    residentMemoryEngine: ref.read(residentMemoryEngineProvider),
    residentRelationshipEngine: relationshipEngine,
    worldClockManager: ref.read(worldClockManagerProvider),
    festivalRuntimeManager: festivalRuntime,
    weatherRuntimeManager: weatherRuntime,
    rumorRuntimeManager: rumorRuntime,
  );
});

final residentStoryEngineProvider =
    FutureProvider<ResidentStoryEngine>((ref) async {
  final storyConfig = await ref.read(residentStoryRepositoryProvider).load();
  final lifeManager = ref.read(residentLifeManagerProvider);
  if (!lifeManager.loaded) {
    await lifeManager.load();
  }
  final relationshipEngine =
      await ref.read(residentRelationshipEngineProvider.future);
  final dialogueEngine = await ref.read(residentDialogueEngineProvider.future);
  return ResidentStoryEngine(
    config: storyConfig,
    lifeManager: lifeManager,
    memoryEngine: ref.read(residentMemoryEngineProvider),
    relationshipEngine: relationshipEngine,
    dialogueEngine: dialogueEngine,
    worldClockManager: ref.read(worldClockManagerProvider),
  );
});

final storyRuntimeManagerProvider =
    FutureProvider<StoryRuntimeManager>((ref) async {
  final storyConfig = await ref.read(residentStoryRepositoryProvider).load();
  final runtimeManager = ref.read(residentRuntimeManagerProvider);
  if (!runtimeManager.loaded) {
    await runtimeManager.load();
  }
  final relationshipEngine =
      await ref.read(residentRelationshipEngineProvider.future);
  final dialogueRuntime = await ref.read(dialogueRuntimeManagerProvider.future);
  final festivalRuntime = await ref.read(festivalRuntimeManagerProvider.future);
  final weatherRuntime = await ref.read(weatherRuntimeManagerProvider.future);
  final rumorRuntime = await ref.read(rumorRuntimeManagerProvider.future);
  return StoryRuntimeManager(
    config: storyConfig,
    residentRuntimeManager: runtimeManager,
    residentMemoryEngine: ref.read(residentMemoryEngineProvider),
    residentRelationshipEngine: relationshipEngine,
    dialogueRuntimeManager: dialogueRuntime,
    worldClockManager: ref.read(worldClockManagerProvider),
    festivalRuntimeManager: festivalRuntime,
    weatherRuntimeManager: weatherRuntime,
    rumorRuntimeManager: rumorRuntime,
  );
});

final worldSaveManagerProvider = FutureProvider<WorldSaveManager>((ref) async {
  return WorldSaveManager(
    repository: ref.read(worldSaveRepositoryProvider),
    worldClockManager: ref.read(worldClockManagerProvider),
    festivalRuntimeManager:
        await ref.read(festivalRuntimeManagerProvider.future),
    weatherRuntimeManager: await ref.read(weatherRuntimeManagerProvider.future),
    rumorRuntimeManager: await ref.read(rumorRuntimeManagerProvider.future),
    residentRuntimeManager: ref.read(residentRuntimeManagerProvider),
    residentMemoryEngine: ref.read(residentMemoryEngineProvider),
    residentRelationshipEngine:
        await ref.read(residentRelationshipEngineProvider.future),
    storyRuntimeManager: await ref.read(storyRuntimeManagerProvider.future),
    dialogueRuntimeManager:
        await ref.read(dialogueRuntimeManagerProvider.future),
  );
});

final secondWorldEngineProvider =
    FutureProvider<SecondWorldEngine>((ref) async {
  final residentConfig = await ref.read(residentRepositoryProvider).load();
  final memoryEngine = ref.read(residentMemoryEngineProvider);
  if (memoryEngine.records.isEmpty) {
    final memoryConfig =
        await ref.read(residentMemoryRepositoryProvider).load();
    memoryEngine.load(memoryConfig);
  }
  final lifeManager = ref.read(residentLifeManagerProvider);
  if (!lifeManager.loaded) {
    await lifeManager.load();
  }
  final relationshipEngine =
      await ref.read(residentRelationshipEngineProvider.future);
  final dialogueEngine = await ref.read(residentDialogueEngineProvider.future);
  final dialogueRuntime = await ref.read(dialogueRuntimeManagerProvider.future);
  final storyEngine = await ref.read(residentStoryEngineProvider.future);
  final storyRuntime = await ref.read(storyRuntimeManagerProvider.future);
  final festivalRuntime = await ref.read(festivalRuntimeManagerProvider.future);
  final weatherRuntime = await ref.read(weatherRuntimeManagerProvider.future);
  final rumorRuntime = await ref.read(rumorRuntimeManagerProvider.future);
  final worldSave = await ref.read(worldSaveManagerProvider.future);
  return SecondWorldEngine(
    residentConfig: residentConfig,
    residentLifeEngine: lifeManager,
    residentMemoryEngine: memoryEngine,
    residentRelationshipEngine: relationshipEngine,
    residentDialogueEngine: dialogueEngine,
    residentStoryEngine: storyEngine,
    dialogueRuntimeManager: dialogueRuntime,
    storyRuntimeManager: storyRuntime,
    festivalRuntimeManager: festivalRuntime,
    weatherRuntimeManager: weatherRuntime,
    rumorRuntimeManager: rumorRuntime,
    worldSaveManager: worldSave,
    residentRuntimeManager: ref.read(residentRuntimeManagerProvider),
  );
});

final fishRuntimeManagerProvider =
    FutureProvider<FishRuntimeManager>((ref) async {
  final fishConfig = await ref.read(fishRepositoryProvider).load();
  return FishRuntimeManager(
    config: fishConfig,
    worldClockManager: ref.read(worldClockManagerProvider),
    weatherRuntimeManager: await ref.read(weatherRuntimeManagerProvider.future),
    festivalRuntimeManager:
        await ref.read(festivalRuntimeManagerProvider.future),
    secondWorldEngine: await ref.read(secondWorldEngineProvider.future),
  );
});

final residentDecisionManagerProvider =
    FutureProvider<ResidentDecisionManager>((ref) async {
  return ResidentDecisionManager(
    residentRuntimeManager: ref.read(residentRuntimeManagerProvider),
    dialogueRuntimeManager:
        await ref.read(dialogueRuntimeManagerProvider.future),
    storyRuntimeManager: await ref.read(storyRuntimeManagerProvider.future),
    weatherRuntimeManager: await ref.read(weatherRuntimeManagerProvider.future),
    festivalRuntimeManager:
        await ref.read(festivalRuntimeManagerProvider.future),
    rumorRuntimeManager: await ref.read(rumorRuntimeManagerProvider.future),
    worldClockManager: ref.read(worldClockManagerProvider),
    secondWorldEngine: await ref.read(secondWorldEngineProvider.future),
    residentMemoryEngine: ref.read(residentMemoryEngineProvider),
  );
});

final worldTickManagerProvider = FutureProvider<WorldTickManager>((ref) async {
  final secondWorld = await ref.read(secondWorldEngineProvider.future);
  final manager = WorldTickManager(
    worldClockManager: ref.read(worldClockManagerProvider),
    festivalRuntimeManager:
        await ref.read(festivalRuntimeManagerProvider.future),
    weatherRuntimeManager: await ref.read(weatherRuntimeManagerProvider.future),
    rumorRuntimeManager: await ref.read(rumorRuntimeManagerProvider.future),
    residentRuntimeManager: ref.read(residentRuntimeManagerProvider),
    dialogueRuntimeManager:
        await ref.read(dialogueRuntimeManagerProvider.future),
    storyRuntimeManager: await ref.read(storyRuntimeManagerProvider.future),
    worldSaveManager: await ref.read(worldSaveManagerProvider.future),
    fishRuntimeManager: await ref.read(fishRuntimeManagerProvider.future),
    residentDecisionManager:
        await ref.read(residentDecisionManagerProvider.future),
    secondWorldEngine: secondWorld,
  );
  manager.register(secondWorld);
  ref.onDispose(manager.unregister);
  return manager;
});

final dailySimulationManagerProvider =
    FutureProvider<DailySimulationManager>((ref) async {
  return DailySimulationManager(
    worldTickManager: await ref.read(worldTickManagerProvider.future),
    worldClockManager: ref.read(worldClockManagerProvider),
    festivalRuntimeManager:
        await ref.read(festivalRuntimeManagerProvider.future),
    weatherRuntimeManager: await ref.read(weatherRuntimeManagerProvider.future),
    rumorRuntimeManager: await ref.read(rumorRuntimeManagerProvider.future),
    residentRuntimeManager: ref.read(residentRuntimeManagerProvider),
    storyRuntimeManager: await ref.read(storyRuntimeManagerProvider.future),
    worldSaveManager: await ref.read(worldSaveManagerProvider.future),
  );
});

final questRuntimeManagerProvider =
    FutureProvider<QuestRuntimeManager>((ref) async {
  final home = await ref.read(homeConfigBundleProvider.future);
  final residentRuntime = ref.read(residentRuntimeManagerProvider);
  if (!residentRuntime.loaded) {
    await residentRuntime.load();
  }
  final manager = QuestRuntimeManager(
    taskConfig: home.task,
    taskManager: ref.read(taskManagerProvider),
    worldClockManager: ref.read(worldClockManagerProvider),
    dailySimulationManager:
        await ref.read(dailySimulationManagerProvider.future),
    residentRuntimeManager: residentRuntime,
    dialogueRuntimeManager:
        await ref.read(dialogueRuntimeManagerProvider.future),
    storyRuntimeManager: await ref.read(storyRuntimeManagerProvider.future),
    fishRuntimeManager: await ref.read(fishRuntimeManagerProvider.future),
    rumorRuntimeManager: await ref.read(rumorRuntimeManagerProvider.future),
    festivalRuntimeManager:
        await ref.read(festivalRuntimeManagerProvider.future),
    weatherRuntimeManager: await ref.read(weatherRuntimeManagerProvider.future),
    worldSaveManager: await ref.read(worldSaveManagerProvider.future),
  );
  final tick = await ref.read(worldTickManagerProvider.future);
  tick.setQuestRuntimeManager(manager);
  return manager;
});

final economyRuntimeManagerProvider =
    FutureProvider<EconomyRuntimeManager>((ref) async {
  final manager = EconomyRuntimeManager(
    fishRuntimeManager: await ref.read(fishRuntimeManagerProvider.future),
    questRuntimeManager: await ref.read(questRuntimeManagerProvider.future),
    residentRuntimeManager: ref.read(residentRuntimeManagerProvider),
    festivalRuntimeManager:
        await ref.read(festivalRuntimeManagerProvider.future),
    weatherRuntimeManager: await ref.read(weatherRuntimeManagerProvider.future),
    worldClockManager: ref.read(worldClockManagerProvider),
    worldSaveManager: await ref.read(worldSaveManagerProvider.future),
    secondWorldEngine: await ref.read(secondWorldEngineProvider.future),
  );
  final tick = await ref.read(worldTickManagerProvider.future);
  tick.setEconomyRuntimeManager(manager);
  return manager;
});

final relationshipRuntimeManagerProvider =
    FutureProvider<RelationshipRuntimeManager>((ref) async {
  final manager = RelationshipRuntimeManager(
    residentRuntimeManager: ref.read(residentRuntimeManagerProvider),
    residentDecisionManager:
        await ref.read(residentDecisionManagerProvider.future),
    rumorRuntimeManager: await ref.read(rumorRuntimeManagerProvider.future),
    storyRuntimeManager: await ref.read(storyRuntimeManagerProvider.future),
    dailySimulationManager:
        await ref.read(dailySimulationManagerProvider.future),
    worldSaveManager: await ref.read(worldSaveManagerProvider.future),
    residentRelationshipEngine:
        await ref.read(residentRelationshipEngineProvider.future),
    secondWorldEngine: await ref.read(secondWorldEngineProvider.future),
  );
  final tick = await ref.read(worldTickManagerProvider.future);
  tick.setRelationshipRuntimeManager(manager);
  return manager;
});

final achievementRuntimeManagerProvider =
    FutureProvider<AchievementRuntimeManager>((ref) async {
  final home = await ref.read(homeConfigBundleProvider.future);
  final identityRaw = await ref
      .read(jsonSourceProvider)
      .loadString('assets/config/identity.json');
  final identityConfig = jsonDecode(identityRaw) as Map<String, dynamic>;
  final manager = AchievementRuntimeManager(
    honorConfig: home.honor,
    identityConfig: identityConfig,
    fishCollectionConfig: home.fishCollection,
    taskConfig: home.task,
    questRuntimeManager: await ref.read(questRuntimeManagerProvider.future),
    fishRuntimeManager: await ref.read(fishRuntimeManagerProvider.future),
    relationshipRuntimeManager:
        await ref.read(relationshipRuntimeManagerProvider.future),
    storyRuntimeManager: await ref.read(storyRuntimeManagerProvider.future),
    rumorRuntimeManager: await ref.read(rumorRuntimeManagerProvider.future),
    festivalRuntimeManager:
        await ref.read(festivalRuntimeManagerProvider.future),
    weatherRuntimeManager: await ref.read(weatherRuntimeManagerProvider.future),
    residentRuntimeManager: ref.read(residentRuntimeManagerProvider),
    worldClockManager: ref.read(worldClockManagerProvider),
    worldSaveManager: await ref.read(worldSaveManagerProvider.future),
    secondWorldEngine: await ref.read(secondWorldEngineProvider.future),
  );
  final tick = await ref.read(worldTickManagerProvider.future);
  tick.setAchievementRuntimeManager(manager);
  return manager;
});

final dynamicEventRuntimeManagerProvider =
    FutureProvider<DynamicEventRuntimeManager>((ref) async {
  final config = await ref.read(dynamicEventRepositoryProvider).load();
  final residentRuntime = ref.read(residentRuntimeManagerProvider);
  if (!residentRuntime.loaded) {
    await residentRuntime.load();
  }
  final manager = DynamicEventRuntimeManager(
    config: config,
    worldClockManager: ref.read(worldClockManagerProvider),
    dailySimulationManager:
        await ref.read(dailySimulationManagerProvider.future),
    residentRuntimeManager: residentRuntime,
    residentDecisionManager:
        await ref.read(residentDecisionManagerProvider.future),
    relationshipRuntimeManager:
        await ref.read(relationshipRuntimeManagerProvider.future),
    dialogueRuntimeManager:
        await ref.read(dialogueRuntimeManagerProvider.future),
    storyRuntimeManager: await ref.read(storyRuntimeManagerProvider.future),
    festivalRuntimeManager:
        await ref.read(festivalRuntimeManagerProvider.future),
    weatherRuntimeManager: await ref.read(weatherRuntimeManagerProvider.future),
    rumorRuntimeManager: await ref.read(rumorRuntimeManagerProvider.future),
    fishRuntimeManager: await ref.read(fishRuntimeManagerProvider.future),
    questRuntimeManager: await ref.read(questRuntimeManagerProvider.future),
    achievementRuntimeManager:
        await ref.read(achievementRuntimeManagerProvider.future),
    worldSaveManager: await ref.read(worldSaveManagerProvider.future),
    secondWorldEngine: await ref.read(secondWorldEngineProvider.future),
    residentMemoryEngine: ref.read(residentMemoryEngineProvider),
  );
  final tick = await ref.read(worldTickManagerProvider.future);
  tick.setDynamicEventRuntimeManager(manager);
  return manager;
});

final fairyEventServiceProvider =
    FutureProvider<FairyEventService>((ref) async {
  return FairyEventService(
    await ref.read(dynamicEventRuntimeManagerProvider.future),
  );
});

final livingWorldManagerProvider =
    ChangeNotifierProvider<LivingWorldManager>((ref) {
  return LivingWorldManager(
    worldClockRepository: ref.read(worldClockRepositoryProvider),
    timelineRepository: ref.read(worldTimelineRepositoryProvider),
    residentLifeRepository: ref.read(residentLifeRepositoryProvider),
    memoryRepository: ref.read(memoryRepositoryProvider),
    relationshipRepository: ref.read(relationshipLevelRepositoryProvider),
    dialogueContextRepository: ref.read(dialogueContextRepositoryProvider),
    eventTriggerRepository: ref.read(eventTriggerRepositoryProvider),
  );
});

final livingWorldProvider = ChangeNotifierProvider<LivingWorldProvider>((ref) {
  return LivingWorldProvider(ref.read(livingWorldManagerProvider));
});

final audioManagerProvider =
    Provider<AudioManager>((ref) => AudioManager.instance);

final balanceManagerProvider =
    Provider<BalanceManager>((ref) => BalanceManager());

final _sharedWaitingEngine = WaitingEngine();
final _sharedWaitingEventManager =
    WaitingEventManagerView(_sharedWaitingEngine);

final balanceViewProvider = ChangeNotifierProvider<BalanceManagerView>((ref) {
  return BalanceManagerView(ref.read(balanceManagerProvider));
});

final worldManagerProvider = ChangeNotifierProvider<WorldManagerView>((ref) {
  return WorldManagerView(WorldEngine());
});

final weatherManagerProvider =
    ChangeNotifierProvider<WeatherManagerView>((ref) {
  return WeatherManagerView(WeatherSystem());
});

final todayManagerProvider = ChangeNotifierProvider<TodayManagerView>((ref) {
  return TodayManagerView(TodayEngine(timeManager: TimeManager()));
});

final fishingManagerProvider =
    ChangeNotifierProvider<FishingManagerView>((ref) {
  return FishingManagerView(FishingEngine(oceanEngine: OceanEngine()));
});

final fishChainProvider = ChangeNotifierProvider<FishChainProvider>((ref) {
  return FishChainProvider();
});

final waitingEventManagerProvider =
    ChangeNotifierProvider<WaitingEventManagerView>((ref) {
  return _sharedWaitingEventManager;
});

final fishingProvider = ChangeNotifierProvider<FishingProvider>((ref) {
  final provider = FishingProvider(
    waitingEngine: _sharedWaitingEngine,
    waitingEventManager: _sharedWaitingEventManager,
    collectionManager: ref.read(collectionManagerProvider),
  );
  ref
      .read(fishRuntimeManagerProvider.future)
      .then(provider.setFishRuntimeManager);
  ref
      .read(fairyEventServiceProvider.future)
      .then(provider.setFairyEventService);
  return provider;
});

final waitingManagerProvider =
    ChangeNotifierProvider<WaitingManagerView>((ref) {
  return WaitingManagerView(_sharedWaitingEngine);
});

final relationshipManagerProvider =
    ChangeNotifierProvider<RelationshipManagerView>((ref) {
  return RelationshipManagerView(RelationshipEngine());
});

final lifeManagerProvider = ChangeNotifierProvider<LifeManagerView>((ref) {
  return LifeManagerView(LifeEngine(relationshipEngine: RelationshipEngine()));
});

final meaningManagerProvider =
    ChangeNotifierProvider<MeaningManagerView>((ref) {
  return MeaningManagerView(MeaningEngine());
});

final companionManagerProvider =
    ChangeNotifierProvider<CompanionManagerView>((ref) {
  return CompanionManagerView(const CompanionGiftManager());
});

final collectionManagerProvider =
    ChangeNotifierProvider<CollectionManagerView>((ref) {
  return CollectionManagerView();
});

final walletManagerProvider = ChangeNotifierProvider<WalletManagerView>((ref) {
  return WalletManagerView();
});

final inventoryManagerProvider =
    ChangeNotifierProvider<InventoryManagerView>((ref) {
  return InventoryManagerView();
});

final memoryManagerProvider = ChangeNotifierProvider<MemoryManagerView>((ref) {
  return MemoryManagerView();
});

final transactionManagerProvider =
    ChangeNotifierProvider<TransactionManagerView>((ref) {
  return TransactionManagerView();
});

final taskManagerProvider = ChangeNotifierProvider<TaskManagerView>((ref) {
  return TaskManagerView();
});

final honorManagerProvider = ChangeNotifierProvider<HonorManagerView>((ref) {
  return HonorManagerView();
});

final settingsManagerProvider =
    ChangeNotifierProvider<SettingsManagerView>((ref) {
  throw UnimplementedError('Override from bootstrap');
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

final appRouterStateProvider =
    ChangeNotifierProvider.family<AppRouterState, String>((ref, startPath) {
  return AppRouterState(startPath: startPath);
});
