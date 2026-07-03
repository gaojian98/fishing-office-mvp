import 'balance_models.dart';
import 'balance_report.dart';
import 'xlsx_table.dart';
import 'xlsx_workbook_reader.dart';

class BalanceManager {
  BalanceManager({
    XlsxWorkbookReader? reader,
    this.assetBasePath = 'assets/config/balance',
  }) : _reader = reader ?? const XlsxWorkbookReader();

  final XlsxWorkbookReader _reader;
  final String assetBasePath;

  Future<BalanceBundle> load() async {
    final fishChain = await _reader.readAsset('$assetBasePath/FishChain.xlsx');
    final economy = await _reader.readAsset('$assetBasePath/EconomyBalance.xlsx');
    final probability = await _reader.readAsset('$assetBasePath/Probability.xlsx');
    final time = await _reader.readAsset('$assetBasePath/TimeBalance.xlsx');
    final companion = await _reader.readAsset('$assetBasePath/CompanionBalance.xlsx');
    final reward = await _reader.readAsset('$assetBasePath/RewardBalance.xlsx');

    return BalanceBundle(
      fishChain: FishChainBalance.fromSheets(fishChain),
      economy: EconomyBalance.fromSheets(economy),
      probability: ProbabilityBalance.fromSheets(probability),
      time: TimeBalance.fromSheets(time),
      companion: CompanionBalance.fromSheets(companion),
      reward: RewardBalance.fromSheets(reward),
    );
  }

  Future<BalanceBundle> loadFromFiles({
    required String fishChainPath,
    required String economyPath,
    required String probabilityPath,
    required String timePath,
    required String companionPath,
    required String rewardPath,
  }) async {
    final fishChain = await _reader.readFile(fishChainPath);
    final economy = await _reader.readFile(economyPath);
    final probability = await _reader.readFile(probabilityPath);
    final time = await _reader.readFile(timePath);
    final companion = await _reader.readFile(companionPath);
    final reward = await _reader.readFile(rewardPath);

    return BalanceBundle(
      fishChain: FishChainBalance.fromSheets(fishChain),
      economy: EconomyBalance.fromSheets(economy),
      probability: ProbabilityBalance.fromSheets(probability),
      time: TimeBalance.fromSheets(time),
      companion: CompanionBalance.fromSheets(companion),
      reward: RewardBalance.fromSheets(reward),
    );
  }

  Future<BalanceMappingReport> loadReport() async {
    final sections = <BalanceMappingSection>[
      _fishChainSection(await _reader.readAsset('$assetBasePath/FishChain.xlsx')),
      _economySection(await _reader.readAsset('$assetBasePath/EconomyBalance.xlsx')),
      _probabilitySection(await _reader.readAsset('$assetBasePath/Probability.xlsx')),
      _timeSection(await _reader.readAsset('$assetBasePath/TimeBalance.xlsx')),
      _companionSection(await _reader.readAsset('$assetBasePath/CompanionBalance.xlsx')),
      _rewardSection(await _reader.readAsset('$assetBasePath/RewardBalance.xlsx')),
    ];
    return BalanceMappingReport(sections: sections);
  }

  Future<BalanceMappingReport> loadReportFromFiles({
    required String fishChainPath,
    required String economyPath,
    required String probabilityPath,
    required String timePath,
    required String companionPath,
    required String rewardPath,
  }) async {
    final sections = <BalanceMappingSection>[
      _fishChainSection(await _reader.readFile(fishChainPath)),
      _economySection(await _reader.readFile(economyPath)),
      _probabilitySection(await _reader.readFile(probabilityPath)),
      _timeSection(await _reader.readFile(timePath)),
      _companionSection(await _reader.readFile(companionPath)),
      _rewardSection(await _reader.readFile(rewardPath)),
    ];
    return BalanceMappingReport(sections: sections);
  }

  BalanceMappingSection _fishChainSection(Map<String, XlsxTable> sheets) {
    return BalanceMappingSection(
      fileName: 'FishChain.xlsx',
      sheets: _sheetReports(sheets),
      directMappings: const [
        'FishChain / Wait Min, Wait Max -> WaitingEngine, FishingSession',
        'FishChain / Base Coin, Points -> FishingResult, future EconomyEngine',
        'FishChain / Can Sell, Can Keep, Can Become Companion -> Reward flow, RelationshipEngine',
      ],
      missingFields: const [
        'No explicit row id or fish key namespace for runtime lookups.',
        'No asset/reference key for fish icon/portrait.',
        'No explicit bait/item category enum for UI binding.',
      ],
      supplementFields: const [
        'Add stable fish row identifiers for engine lookup.',
        'Add icon or asset reference keys if UI needs direct binding.',
        'Add bait and chain category keys if later engines require filtering.',
      ],
    );
  }

  BalanceMappingSection _economySection(Map<String, XlsxTable> sheets) {
    return BalanceMappingSection(
      fileName: 'EconomyBalance.xlsx',
      sheets: _sheetReports(sheets),
      directMappings: const [
        'Assumptions / Short-Medium-Workday sessions -> TimeManager, TodayEngine pacing',
        'Summary / Daily gross, spend, net -> future EconomyEngine, WalletManager',
      ],
      missingFields: const [
        'No currency unit column for multi-currency split in this workbook.',
        'No transaction type key for wallet ledger events.',
        'No source/target balance account key for transfers.',
      ],
      supplementFields: const [
        'Add currency scope keys if runtime wallet needs per-unit routing.',
        'Add ledger event keys if transaction logs must be reconstructed.',
        'Add account routing keys if future economy engine needs source/target bookkeeping.',
      ],
    );
  }

  BalanceMappingSection _probabilitySection(Map<String, XlsxTable> sheets) {
    return BalanceMappingSection(
      fileName: 'Probability.xlsx',
      sheets: _sheetReports(sheets),
      directMappings: const [
        'BaseProbability / Base Success %, Bait Loss %, Escape %, Rare Event %, Pity Floor -> FishingEngine',
        'Modifiers / add_success, reduce_escape, add_rare_event -> FishingEngine, WeatherSystem',
      ],
      missingFields: const [
        'No explicit weight key for weighted event buckets.',
        'No trigger condition key beyond free-text notes.',
        'No effect scope key for per-map or per-fish overrides.',
      ],
      supplementFields: const [
        'Add weight keys if runtime needs weighted roll blending.',
        'Add trigger keys if later config must separate global and local modifiers.',
        'Add override scope keys if multiple maps or fish families share the table.',
      ],
    );
  }

  BalanceMappingSection _timeSection(Map<String, XlsxTable> sheets) {
    return BalanceMappingSection(
      fileName: 'TimeBalance.xlsx',
      sheets: _sheetReports(sheets),
      directMappings: const [
        'TimeTiers / Recommended Checks, Event Count -> WaitingEngine, WorldClock, TodayEngine',
        'WorkdayExample / Time, World Event, Player Action -> WorldEngine, TodayEngine narrative hints',
      ],
      missingFields: const [
        'No timezone or locale key for future region-aware world time.',
        'No explicit start/end day boundary key.',
        'No festival binding key between time tiers and public events.',
      ],
      supplementFields: const [
        'Add locale/timezone keys if global release needs regional time rules.',
        'Add day boundary keys if calendar rollover needs config-only control.',
        'Add festival bridge keys if seasonal logic must be table-driven.',
      ],
    );
  }

  BalanceMappingSection _companionSection(Map<String, XlsxTable> sheets) {
    return BalanceMappingSection(
      fileName: 'CompanionBalance.xlsx',
      sheets: _sheetReports(sheets),
      directMappings: const [
        'RelationshipLevels / Score Min, Score Max -> RelationshipEngine',
        'GrowthActions / Base Score, Cooldown -> RelationshipEngine, LifeEngine, CompanionGiftManager',
      ],
      missingFields: const [
        'No companion type key separating human/animal/AI future branches.',
        'No memory bucket key for companion-specific memories.',
        'No unlock dependency key for companion progression chains.',
      ],
      supplementFields: const [
        'Add companion category keys if future profiles need type routing.',
        'Add memory bucket keys if companion memories are stored separately.',
        'Add dependency keys if progression must be validated across levels.',
      ],
    );
  }

  BalanceMappingSection _rewardSection(Map<String, XlsxTable> sheets) {
    return BalanceMappingSection(
      fileName: 'RewardBalance.xlsx',
      sheets: _sheetReports(sheets),
      directMappings: const [
        'DecisionRewards / Sell, Keep, Use As Bait, Release, Favorite -> FishingResult, MeaningEngine, RelationshipEngine',
        'RewardMix / Economic, Collection, Relationship, Meaning, World -> Reward routing and future EconomyEngine',
      ],
      missingFields: const [
        'No explicit reward id for each decision row.',
        'No item reference key for the affected fish/object.',
        'No UI presentation priority key for mixed reward preview.',
      ],
      supplementFields: const [
        'Add reward ids if multiple engines need deterministic lookup.',
        'Add item reference keys if reward source objects must be resolved.',
        'Add presentation priority keys if UI preview composition becomes configurable.',
      ],
    );
  }

  List<BalanceSheetReport> _sheetReports(Map<String, XlsxTable> sheets) {
    return sheets.values
        .map(
          (sheet) => BalanceSheetReport(
            sheetName: sheet.sheetName,
            fields: sheet.headers,
          ),
        )
        .toList(growable: false);
  }
}
