import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../models/fish_catalog_config.dart';
import '../engine/second_world_engine.dart';
import 'festival_runtime_manager.dart';
import 'weather_runtime_manager.dart';
import 'world_clock_manager.dart';

class FishRuntimeContext {
  const FishRuntimeContext({
    required this.baitId,
    this.locationId = '',
  });

  final String baitId;
  final String locationId;
}

class FishRuntimeResult {
  const FishRuntimeResult({
    required this.fish,
    required this.biteChance,
    required this.weightKg,
    required this.waitDialogue,
    required this.catchReaction,
  });

  final FishCatalogEntry fish;
  final double biteChance;
  final double weightKg;
  final String waitDialogue;
  final String catchReaction;
}

class FishRuntimeManager extends ChangeNotifier {
  FishRuntimeManager({
    required FishCatalogConfig config,
    required WorldClockManager worldClockManager,
    required WeatherRuntimeManager weatherRuntimeManager,
    required FestivalRuntimeManager festivalRuntimeManager,
    SecondWorldEngine? secondWorldEngine,
  })  : _config = config,
        _worldClockManager = worldClockManager,
        _weatherRuntimeManager = weatherRuntimeManager,
        _festivalRuntimeManager = festivalRuntimeManager,
        _secondWorldEngine = secondWorldEngine;

  final FishCatalogConfig _config;
  final WorldClockManager _worldClockManager;
  final WeatherRuntimeManager _weatherRuntimeManager;
  final FestivalRuntimeManager _festivalRuntimeManager;
  final SecondWorldEngine? _secondWorldEngine;
  final Random _random = Random();

  List<FishCatalogEntry> _lastActivePool = const <FishCatalogEntry>[];

  List<FishCatalogEntry> get lastActivePool =>
      List<FishCatalogEntry>.from(_lastActivePool);

  FishCatalogEntry? fishById(String fishId) => _config.findFish(fishId);

  void refresh() {
    _lastActivePool = getActiveFishPool();
    if (kDebugMode) {
      debugPrint('FishRuntimeManager | activePool=${_lastActivePool.length}');
    }
    notifyListeners();
  }

  List<FishCatalogEntry> getActiveFishPool() {
    final time = _timeOfDay();
    final weather = _weatherRuntimeManager.getCurrentWeather();
    final festivalTags = _festivalRuntimeManager.getFestivalTags();
    final pool = _config.fish.where((fish) {
      final timeScore = _timeScore(fish.favoriteTime, time);
      final weatherScore = _weatherScore(
        fish.favoriteWeather,
        weather?.type ?? '',
        weather?.name ?? '',
      );
      final festivalScore = festivalTags.isEmpty ? 0 : 1;
      return timeScore > 0 || weatherScore > 0 || festivalScore > 0;
    }).toList(growable: false);
    if (pool.isEmpty) return List<FishCatalogEntry>.from(_config.fish);
    return _sortPool(pool);
  }

  List<FishCatalogEntry> getFishPoolByLocation(String locationId) {
    final active = getActiveFishPool();
    if (locationId.isEmpty) return active;
    final locationTokens = _tokens(locationId);
    final filtered = active
        .where((fish) => _matchesAny(fish.habitat, locationTokens))
        .toList(growable: false);
    return _sortPool(filtered);
  }

  double getFishBiteChance(String fishId, String baitId) {
    final fish = _config.findFish(fishId);
    if (fish == null) return 0;
    final chance = _scoreFish(
      fish,
      FishRuntimeContext(baitId: baitId),
    );
    return chance.clamp(0, 1).toDouble();
  }

  FishRuntimeResult selectFishResult(FishRuntimeContext context) {
    final pool = _candidatePool(context);
    final scored = pool
        .map((fish) => MapEntry(fish, _scoreFish(fish, context)))
        .where((entry) => entry.value > 0)
        .toList(growable: false);
    final candidates = scored.isEmpty
        ? pool
            .map((fish) => MapEntry(fish, _rarityBaseWeight(fish.rarity)))
            .toList(growable: false)
        : scored;
    final selected = _selectWeighted(candidates);
    final chance = getFishBiteChance(selected.id, context.baitId);
    return FishRuntimeResult(
      fish: selected,
      biteChance: chance,
      weightKg: _resolveWeight(selected, context),
      waitDialogue: waitingDialogueFor(selected.id, context: context),
      catchReaction: selected.catchReaction,
    );
  }

  String waitingDialogueFor(
    String fishId, {
    required FishRuntimeContext context,
  }) {
    final fish = _config.findFish(fishId);
    final directDialogues =
        fish == null ? const <String>[] : _uniqueDialogues(fish.waitDialogues);
    if (fish == null || directDialogues.isEmpty) {
      final result = selectFishResult(context);
      final fallbackDialogues = _uniqueDialogues(result.fish.waitDialogues);
      return fallbackDialogues.isEmpty ? '' : fallbackDialogues.first;
    }
    final index = (_worldClockManager.today().dayCount +
            _worldClockManager.hour() +
            context.baitId.hashCode.abs()) %
        directDialogues.length;
    return directDialogues[index];
  }

  String waitingDialogueForContext(FishRuntimeContext context) {
    final result = selectFishResult(context);
    return result.waitDialogue;
  }

  List<FishCatalogEntry> _candidatePool(FishRuntimeContext context) {
    final locationPool = getFishPoolByLocation(context.locationId);
    final basePool =
        locationPool.isNotEmpty ? locationPool : getActiveFishPool();
    final baitFish = _config.findFish(context.baitId);
    final baitRank = baitFish == null ? 0 : _rarityRank(baitFish.rarity);
    final requiredMatches = basePool
        .where((fish) => _matchesBait(fish.baitRequired, context.baitId))
        .toList(growable: false);
    final supportPool = basePool.where((fish) {
      final rank = _rarityRank(fish.rarity);
      if (baitRank <= 0) return rank == 1;
      return rank <= baitRank;
    }).toList(growable: false);
    if (requiredMatches.isNotEmpty || supportPool.isNotEmpty) {
      return _sortPool(<FishCatalogEntry>{
        ...supportPool,
        ...requiredMatches,
      }.toList(growable: false));
    }
    final baitFiltered = basePool.where((fish) {
      final required = fish.baitRequired;
      final favorite = fish.favoriteBait;
      if (required.isEmpty && favorite.isEmpty) return true;
      return _matchesBait(required, context.baitId) ||
          _matchesBait(favorite, context.baitId);
    }).toList(growable: false);
    if (baitFiltered.isNotEmpty) return _sortPool(baitFiltered);
    return basePool.isNotEmpty ? basePool : _sortPool(_config.fish);
  }

  double _scoreFish(FishCatalogEntry fish, FishRuntimeContext context) {
    final rarityWeight = _rarityBaseWeight(fish.rarity);
    var score = rarityWeight;
    score += _timeScore(fish.favoriteTime, _timeOfDay()) * 0.14;
    final weather = _weatherRuntimeManager.getCurrentWeather();
    score += _weatherScore(
          fish.favoriteWeather,
          weather?.type ?? '',
          weather?.name ?? '',
        ) *
        0.14;
    if (_matchesBait(fish.baitRequired, context.baitId)) score += 0.24;
    if (_matchesBait(fish.favoriteBait, context.baitId)) score += 0.12;
    if (_matchesAny(fish.habitat, _tokens(context.locationId))) score += 0.08;
    if (_festivalRuntimeManager.getActiveFestivals().isNotEmpty) score += 0.02;
    score += _skillScoreBonus(fish);
    final rarityCap = 0.45 + (rarityWeight * 0.9);
    return score.clamp(0.01, rarityCap.clamp(0.12, 1)).toDouble();
  }

  double _resolveWeight(FishCatalogEntry fish, FishRuntimeContext context) {
    final min = fish.weightRange.min;
    final max = fish.weightRange.max <= min ? min + 0.1 : fish.weightRange.max;
    final seed = (fish.id.hashCode + context.baitId.hashCode).abs();
    final ratio = (seed % 1000) / 1000;
    final fishingLevel = _skillLevel('fishing');
    final luckLevel = _skillLevel('luck');
    final skillRatio =
        (ratio + ((fishingLevel - 1) * 0.008) + ((luckLevel - 1) * 0.004))
            .clamp(0, 0.92)
            .toDouble();
    return double.parse((min + ((max - min) * skillRatio)).toStringAsFixed(1));
  }

  double _skillScoreBonus(FishCatalogEntry fish) {
    final fishing = _skillLevel('fishing') - 1;
    final observation = _skillLevel('observation') - 1;
    final luck = _skillLevel('luck') - 1;
    if (fishing <= 0 && observation <= 0 && luck <= 0) return 0;
    final rarityRank = _rarityRank(fish.rarity);
    final base = (fishing * 0.008) + (observation * 0.004);
    final rareSupport = rarityRank >= 3 ? luck * 0.004 : luck * 0.002;
    return (base + rareSupport).clamp(0, 0.06).toDouble();
  }

  int _skillLevel(String skillId) {
    return _secondWorldEngine?.getSkillState(skillId).level ?? 1;
  }

  FishCatalogEntry _selectWeighted(
      List<MapEntry<FishCatalogEntry, double>> candidates) {
    final total = candidates.fold<double>(
      0,
      (sum, entry) => sum + entry.value.clamp(0.01, 1).toDouble(),
    );
    if (total <= 0) return candidates.first.key;
    final target = _random.nextDouble() * total;
    var cursor = 0.0;
    for (final entry in candidates) {
      cursor += entry.value.clamp(0.01, 1).toDouble();
      if (cursor >= target) return entry.key;
    }
    return candidates.last.key;
  }

  List<FishCatalogEntry> _sortPool(List<FishCatalogEntry> fish) {
    final items = List<FishCatalogEntry>.from(fish);
    items.sort((a, b) {
      final rarity = _rarityRank(a.rarity).compareTo(_rarityRank(b.rarity));
      if (rarity != 0) return rarity;
      return a.id.compareTo(b.id);
    });
    return items;
  }

  double _rarityBaseWeight(String rarity) {
    switch (rarity) {
      case 'myth':
      case '神话':
        return 0.02;
      case 'legend':
      case 'legendary':
      case '传说':
        return 0.05;
      case 'epic':
      case '史诗':
        return 0.1;
      case 'rare':
      case '稀有':
        return 0.18;
      case 'good':
      case 'excellent':
      case '优秀':
        return 0.32;
      default:
        return 0.55;
    }
  }

  int _rarityRank(String rarity) {
    switch (rarity) {
      case 'myth':
      case '神话':
        return 6;
      case 'legend':
      case 'legendary':
      case '传说':
        return 5;
      case 'epic':
      case '史诗':
        return 4;
      case 'rare':
      case '稀有':
        return 3;
      case 'good':
      case 'excellent':
      case '优秀':
        return 2;
      default:
        return 1;
    }
  }

  int _timeScore(String expected, String actual) {
    if (expected.isEmpty || expected == 'any') return 1;
    final values = _tokens(expected);
    final aliases = <String>{
      actual,
      if (actual == 'dusk') 'evening',
      if (actual == 'late_night') 'night',
      if (actual == 'morning') '早晨',
      if (actual == 'afternoon') '午后',
      if (actual == 'dusk') '傍晚',
      if (actual == 'night') '夜晚',
      if (actual == 'late_night') '深夜',
      if (actual == 'morning') '黎明',
    };
    return values.any(aliases.contains) ? 1 : 0;
  }

  int _weatherScore(String expected, String weatherType, String weatherName) {
    if (expected.isEmpty || expected == 'any') return 1;
    final values = _tokens(expected);
    final aliases = <String>{
      weatherType,
      weatherName,
      if (weatherType == 'sunny') '晴天',
      if (weatherType == 'rain') '雨天',
      if (weatherType == 'rain') 'rainy',
      if (weatherType == 'cloudy') '多云',
      if (weatherType == 'windy') '大风',
      if (weatherType == 'fog') '雾',
      if (weatherType == 'foggy') '雾',
    };
    return values.any(aliases.contains) ? 1 : 0;
  }

  bool _matchesBait(String expected, String baitId) {
    if (expected.isEmpty || expected == 'any') return false;
    final values = _tokens(expected);
    final aliases = <String>{
      baitId,
      if (baitId == 'bait_basic') 'basic_bait',
      if (baitId == 'basic_bait') 'bait_basic',
      if (baitId == 'bait_basic') '基础鱼饵',
      if (baitId == 'basic_bait') '基础鱼饵',
      '普通鱼饵',
    };
    return values.any(aliases.contains);
  }

  bool _matchesAny(String expected, List<String> actualTokens) {
    if (expected.isEmpty || actualTokens.isEmpty) return false;
    final expectedTokens = _tokens(expected);
    return expectedTokens.any((expected) {
      return actualTokens.any(
        (actual) =>
            expected == actual ||
            expected.contains(actual) ||
            actual.contains(expected),
      );
    });
  }

  List<String> _tokens(String value) {
    if (value.isEmpty) return const <String>[];
    return value
        .split(RegExp(r'[,，/|、\s]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  List<String> _uniqueDialogues(List<String> dialogues) {
    final seen = <String>{};
    final result = <String>[];
    for (final dialogue in dialogues) {
      final text = dialogue.trim();
      if (text.isEmpty || seen.contains(text)) continue;
      seen.add(text);
      result.add(text);
    }
    return result;
  }

  String _timeOfDay() {
    final hour = _worldClockManager.hour();
    if (hour >= 5 && hour < 11) return 'morning';
    if (hour >= 11 && hour < 13) return 'noon';
    if (hour >= 13 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 20) return 'dusk';
    if (hour >= 20 && hour < 24) return 'night';
    return 'late_night';
  }
}
