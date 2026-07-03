import 'xlsx_table.dart';

class BalanceBundle {
  const BalanceBundle({
    required this.fishChain,
    required this.economy,
    required this.probability,
    required this.time,
    required this.companion,
    required this.reward,
  });

  final FishChainBalance fishChain;
  final EconomyBalance economy;
  final ProbabilityBalance probability;
  final TimeBalance time;
  final CompanionBalance companion;
  final RewardBalance reward;
}

class FishChainBalance {
  const FishChainBalance({
    required this.readme,
    required this.fishChainSheet,
  });

  factory FishChainBalance.fromSheets(Map<String, XlsxTable> sheets) {
    return FishChainBalance(
      readme: sheets['README'],
      fishChainSheet: sheets['FishChain'],
    );
  }

  final XlsxTable? readme;
  final XlsxTable? fishChainSheet;
}

class EconomyBalance {
  const EconomyBalance({
    required this.readme,
    required this.assumptions,
    required this.summary,
  });

  factory EconomyBalance.fromSheets(Map<String, XlsxTable> sheets) {
    return EconomyBalance(
      readme: sheets['README'],
      assumptions: sheets['Assumptions'],
      summary: sheets['Summary'],
    );
  }

  final XlsxTable? readme;
  final XlsxTable? assumptions;
  final XlsxTable? summary;
}

class ProbabilityBalance {
  const ProbabilityBalance({
    required this.readme,
    required this.baseProbability,
    required this.modifiers,
  });

  factory ProbabilityBalance.fromSheets(Map<String, XlsxTable> sheets) {
    return ProbabilityBalance(
      readme: sheets['README'],
      baseProbability: sheets['BaseProbability'],
      modifiers: sheets['Modifiers'],
    );
  }

  final XlsxTable? readme;
  final XlsxTable? baseProbability;
  final XlsxTable? modifiers;
}

class TimeBalance {
  const TimeBalance({
    required this.readme,
    required this.timeTiers,
    required this.workdayExample,
  });

  factory TimeBalance.fromSheets(Map<String, XlsxTable> sheets) {
    return TimeBalance(
      readme: sheets['README'],
      timeTiers: sheets['TimeTiers'],
      workdayExample: sheets['WorkdayExample'],
    );
  }

  final XlsxTable? readme;
  final XlsxTable? timeTiers;
  final XlsxTable? workdayExample;
}

class CompanionBalance {
  const CompanionBalance({
    required this.readme,
    required this.relationshipLevels,
    required this.growthActions,
  });

  factory CompanionBalance.fromSheets(Map<String, XlsxTable> sheets) {
    return CompanionBalance(
      readme: sheets['README'],
      relationshipLevels: sheets['RelationshipLevels'],
      growthActions: sheets['GrowthActions'],
    );
  }

  final XlsxTable? readme;
  final XlsxTable? relationshipLevels;
  final XlsxTable? growthActions;
}

class RewardBalance {
  const RewardBalance({
    required this.readme,
    required this.decisionRewards,
    required this.rewardMix,
  });

  factory RewardBalance.fromSheets(Map<String, XlsxTable> sheets) {
    return RewardBalance(
      readme: sheets['README'],
      decisionRewards: sheets['DecisionRewards'],
      rewardMix: sheets['RewardMix'],
    );
  }

  final XlsxTable? readme;
  final XlsxTable? decisionRewards;
  final XlsxTable? rewardMix;
}

