import 'package:flutter/foundation.dart';

import '../../models/career_state.dart';
import '../../models/task_config.dart';
import '../engine/second_world_engine.dart';
import 'festival_runtime_manager.dart';
import 'fish_runtime_manager.dart';
import 'quest_runtime_manager.dart';
import 'resident_runtime_manager.dart';
import 'weather_runtime_manager.dart';
import 'world_clock_manager.dart';
import 'world_save_manager.dart';

class EconomyReward {
  const EconomyReward({
    required this.taskId,
    required this.fishCoin,
    required this.exp,
    required this.multiplier,
  });

  final String taskId;
  final int fishCoin;
  final int exp;
  final double multiplier;
}

class EconomyRuntimeManager extends ChangeNotifier {
  EconomyRuntimeManager({
    required FishRuntimeManager fishRuntimeManager,
    required ResidentRuntimeManager residentRuntimeManager,
    required FestivalRuntimeManager festivalRuntimeManager,
    required WeatherRuntimeManager weatherRuntimeManager,
    required WorldClockManager worldClockManager,
    required WorldSaveManager worldSaveManager,
    QuestRuntimeManager? questRuntimeManager,
    SecondWorldEngine? secondWorldEngine,
  })  : _fishRuntimeManager = fishRuntimeManager,
        _questRuntimeManager = questRuntimeManager,
        _residentRuntimeManager = residentRuntimeManager,
        _festivalRuntimeManager = festivalRuntimeManager,
        _weatherRuntimeManager = weatherRuntimeManager,
        _worldClockManager = worldClockManager,
        _worldSaveManager = worldSaveManager,
        _secondWorldEngine = secondWorldEngine {
    _restoreState(worldSaveManager.economyRuntimeState);
  }

  final FishRuntimeManager _fishRuntimeManager;
  QuestRuntimeManager? _questRuntimeManager;
  final ResidentRuntimeManager _residentRuntimeManager;
  final FestivalRuntimeManager _festivalRuntimeManager;
  final WeatherRuntimeManager _weatherRuntimeManager;
  final WorldClockManager _worldClockManager;
  final WorldSaveManager _worldSaveManager;
  final SecondWorldEngine? _secondWorldEngine;

  double _marketTrend = 1;
  double _priceMultiplier = 1;
  int? _lastMarketDay;
  final Map<String, double> _residentDemand = <String, double>{};
  final Map<String, double> _fishSupply = <String, double>{};
  final Map<String, double> _dailyMarket = <String, double>{};

  double get marketTrend => _marketTrend;
  double get priceMultiplier => _priceMultiplier;
  int? get lastMarketDay => _lastMarketDay;
  Map<String, double> get residentDemand =>
      Map<String, double>.unmodifiable(_residentDemand);
  Map<String, double> get dailyMarket =>
      Map<String, double>.unmodifiable(_dailyMarket);

  void setQuestRuntimeManager(QuestRuntimeManager manager) {
    _questRuntimeManager = manager;
  }

  int getFishSellPrice(String fishId) {
    final fish = _fishRuntimeManager.fishById(fishId);
    if (fish == null) return 0;
    final multiplier = _fishMarketMultiplier(fishId);
    return (fish.value * multiplier).round().clamp(1, 1 << 31);
  }

  int getFishBuyPrice(String fishId) {
    final sellPrice = getFishSellPrice(fishId);
    if (sellPrice <= 0) return 0;
    return (sellPrice * 1.35).round();
  }

  double getMarketMultiplier() {
    _ensureMarket();
    return _round(_priceMultiplier);
  }

  double getResidentDemand(String residentId) {
    _ensureMarket();
    return _round(_residentDemand[residentId] ?? 1);
  }

  EconomyReward calculateReward(String taskId) {
    _ensureMarket();
    final task = _questRuntimeManager?.taskById(taskId);
    final reward = task?.reward ??
        const TaskRewardConfig(
          fishCoin: 0,
          exp: 0,
          collectionPoint: 0,
          titleId: '',
        );
    final multiplier = _taskRewardMultiplier(task);
    return EconomyReward(
      taskId: taskId,
      fishCoin: (reward.fishCoin * multiplier).round(),
      exp: (reward.exp * multiplier).round(),
      multiplier: _round(multiplier),
    );
  }

  int getSalaryForCareerLevel(String careerLevel) {
    _ensureMarket();
    final base = CareerState.salaryForLevel(careerLevel);
    final multiplier = _salaryMultiplier();
    return (base * multiplier).round().clamp(1, 1 << 31);
  }

  int getSalaryForCareerState(CareerState state) {
    final base = getSalaryForCareerLevel(state.careerLevel);
    final efficiency = state.skill('efficiency').level;
    final skillMultiplier = 1 + (((efficiency - 1) * 0.006).clamp(0, 0.05));
    return (base * skillMultiplier).round().clamp(1, 1 << 31);
  }

  void updateMarket() {
    final day = _worldClockManager.today().dayCount;
    final weather = _weatherRuntimeManager.getCurrentWeather();
    final festivalCount = _festivalRuntimeManager.getActiveFestivals().length;
    final season = _worldClockManager.today().season;
    final weatherFactor = _weatherFactor(weather?.type ?? weather?.name ?? '');
    final festivalFactor = 1 + (festivalCount * 0.08);
    final seasonFactor = _seasonFactor(season);
    final activeFish = _fishRuntimeManager.getActiveFishPool();
    final rarityFactor = activeFish.isEmpty
        ? 1.0
        : activeFish
                .map((fish) => _rarityPriceFactor(fish.rarity))
                .fold<double>(0, (sum, item) => sum + item) /
            activeFish.length;
    _marketTrend = _round(
      (0.78 + ((day % 7) * 0.035)) * weatherFactor * seasonFactor,
    );
    _priceMultiplier = _round(
      (_marketTrend * festivalFactor * rarityFactor).clamp(0.65, 2.25),
    );
    _lastMarketDay = day;
    _residentDemand
      ..clear()
      ..addEntries(_residentRuntimeManager.residents.map((resident) {
        final state = _residentRuntimeManager.getResidentCurrentState(
          resident.id,
        );
        return MapEntry(resident.id, _residentDemandFor(state.mood));
      }));
    _fishSupply
      ..clear()
      ..addEntries(activeFish.map((fish) {
        return MapEntry(fish.id, _supplyForFish(fish.id));
      }));
    _dailyMarket
      ..clear()
      ..addAll({
        'marketTrend': _marketTrend,
        'priceMultiplier': _priceMultiplier,
        'weatherFactor': weatherFactor,
        'festivalFactor': festivalFactor,
        'seasonFactor': seasonFactor,
        'rarityFactor': _round(rarityFactor),
      });
    _persistState();
    if (kDebugMode) {
      debugPrint(
        'EconomyRuntimeManager | day=$day multiplier=$_priceMultiplier trend=$_marketTrend',
      );
    }
    notifyListeners();
  }

  void _ensureMarket() {
    if (_lastMarketDay != _worldClockManager.today().dayCount) {
      updateMarket();
    }
  }

  double _fishMarketMultiplier(String fishId) {
    _ensureMarket();
    final fish = _fishRuntimeManager.fishById(fishId);
    if (fish == null) return 0;
    final rarity = _rarityPriceFactor(fish.rarity);
    final demand = _averageResidentDemand();
    final supply = _fishSupply[fishId] ?? _supplyForFish(fishId);
    final weatherMatch = _weatherMatchesFish(fish.favoriteWeather) ? 1.08 : 1;
    final festivalBonus =
        _festivalRuntimeManager.getActiveFestivals().isEmpty ? 1.0 : 1.12;
    return (_priceMultiplier *
            rarity *
            demand *
            weatherMatch *
            festivalBonus /
            supply)
        .clamp(0.5, 4.0)
        .toDouble();
  }

  double _taskRewardMultiplier(TaskItemConfig? task) {
    final category = task?.category ?? '';
    final base = getMarketMultiplier();
    if (category == 'daily') return (base * 0.95).clamp(0.75, 1.8).toDouble();
    if (category == 'growth') return (base * 1.05).clamp(0.8, 2.0).toDouble();
    return base.clamp(0.75, 1.8).toDouble();
  }

  double _salaryMultiplier() {
    final market = getMarketMultiplier();
    final festivalBonus =
        _festivalRuntimeManager.getActiveFestivals().isEmpty ? 1.0 : 1.03;
    return (market * festivalBonus).clamp(0.95, 1.15).toDouble();
  }

  double _averageResidentDemand() {
    if (_residentDemand.isEmpty) return 1;
    return _residentDemand.values.fold<double>(0, (sum, item) => sum + item) /
        _residentDemand.length;
  }

  double _residentDemandFor(String mood) {
    final text = mood.toLowerCase();
    if (text.contains('happy') ||
        text.contains('warm') ||
        text.contains('bright') ||
        text.contains('开心') ||
        text.contains('温暖')) {
      return 1.16;
    }
    if (text.contains('quiet') ||
        text.contains('calm') ||
        text.contains('安静') ||
        text.contains('平静')) {
      return 1.04;
    }
    if (text.contains('tired') || text.contains('累')) return 0.92;
    return 1.0;
  }

  double _weatherFactor(String weather) {
    final text = weather.toLowerCase();
    if (text.contains('rain') ||
        text.contains('storm') ||
        text.contains('雨') ||
        text.contains('风暴')) {
      return 1.14;
    }
    if (text.contains('sun') || text.contains('晴')) return 1.04;
    if (text.contains('fog') || text.contains('雾')) return 0.96;
    return 1.0;
  }

  bool _weatherMatchesFish(String favoriteWeather) {
    final weather = _weatherRuntimeManager.getCurrentWeather();
    if (weather == null || favoriteWeather.isEmpty) return false;
    final expected = favoriteWeather.toLowerCase();
    final actual = '${weather.type} ${weather.name}'.toLowerCase();
    return actual.contains(expected) || expected.contains(weather.type);
  }

  double _seasonFactor(String season) {
    switch (season.toLowerCase()) {
      case 'summer':
      case '夏':
      case '夏季':
        return 1.05;
      case 'winter':
      case '冬':
      case '冬季':
        return 1.08;
      case 'autumn':
      case 'fall':
      case '秋':
      case '秋季':
        return 1.02;
      default:
        return 1.0;
    }
  }

  double _rarityPriceFactor(String rarity) {
    switch (rarity) {
      case 'myth':
      case '神话':
        return 2.2;
      case 'legend':
      case 'legendary':
      case '传说':
        return 1.85;
      case 'epic':
      case '史诗':
        return 1.55;
      case 'rare':
      case '稀有':
        return 1.32;
      case 'good':
      case 'excellent':
      case '优秀':
        return 1.12;
      default:
        return 1.0;
    }
  }

  double _supplyForFish(String fishId) {
    final activePool = _fishRuntimeManager.getActiveFishPool();
    final active = activePool.any((fish) => fish.id == fishId);
    final fish = _fishRuntimeManager.fishById(fishId);
    final rarity = fish == null ? 1.0 : _rarityPriceFactor(fish.rarity);
    return (active ? 1.0 : 1.25) / rarity.clamp(1.0, 2.2);
  }

  void _persistState() {
    _worldSaveManager.setEconomyRuntimeState({
      'marketTrend': _marketTrend,
      'priceMultiplier': _priceMultiplier,
      'lastMarketDay': _lastMarketDay,
      'residentDemand': _residentDemand,
      'fishSupply': _fishSupply,
      'dailyMarket': _dailyMarket,
      'hasSecondWorldEngine': _secondWorldEngine != null,
    });
  }

  void _restoreState(Map<String, dynamic> state) {
    if (state.isEmpty) return;
    _marketTrend = _readDouble(state['marketTrend'], fallback: 1);
    _priceMultiplier = _readDouble(state['priceMultiplier'], fallback: 1);
    _lastMarketDay = _readInt(state['lastMarketDay']);
    _residentDemand
      ..clear()
      ..addAll(_doubleMap(state['residentDemand']));
    _fishSupply
      ..clear()
      ..addAll(_doubleMap(state['fishSupply']));
    _dailyMarket
      ..clear()
      ..addAll(_doubleMap(state['dailyMarket']));
  }

  Map<String, double> _doubleMap(Object? value) {
    if (value is! Map) return const <String, double>{};
    return value.map(
      (key, item) => MapEntry(
        key.toString(),
        _readDouble(item, fallback: 0),
      ),
    );
  }

  int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '');
  }

  double _readDouble(Object? value, {required double fallback}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _round(double value) => double.parse(value.toStringAsFixed(3));
}
