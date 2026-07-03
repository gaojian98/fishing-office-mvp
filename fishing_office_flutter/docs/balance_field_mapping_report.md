# Game Balance Field Mapping Report

Source workbooks:
- `FishChain.xlsx`
- `EconomyBalance.xlsx`
- `Probability.xlsx`
- `TimeBalance.xlsx`
- `CompanionBalance.xlsx`
- `RewardBalance.xlsx`

## 1. FishChain.xlsx

### Sheets read
- `README`
- `FishChain`

### Fields
- `README`: `Field`, `Value`
- `FishChain`: `Tier`, `Fish ID`, `Fish CN`, `Fish EN`, `Bait Required`, `Wait Min (min)`, `Wait Max (min)`, `Base Coin`, `Points`, `AI Potential`, `Can Sell`, `Can Keep`, `Can Become Companion`, `Notes`

### Direct mappings
- `Wait Min (min)`, `Wait Max (min)` -> `WaitingEngine`, `FishingSession`
- `Base Coin`, `Points` -> `FishingResult`, future economy settlement
- `Can Sell`, `Can Keep`, `Can Become Companion` -> reward flow and `RelationshipEngine`

### Missing for current engine contract
- Stable row id namespace for runtime lookup
- Fish asset reference key
- Bait/item category enum key
- Explicit runtime filter key for chain levels

### Needs supplement
- Stable fish identifiers
- Asset reference keys
- Bait/category routing keys

## 2. EconomyBalance.xlsx

### Sheets read
- `README`
- `Assumptions`
- `Summary`

### Fields
- `Assumptions`: `Parameter`, `Value`, `Unit`, `Notes`
- `Summary`: `Metric`, `Formula / Value`, `Day 1`, `Day 7`, `Day 30`, `Notes`

### Direct mappings
- Session assumptions -> `TimeManager`, `TodayEngine`
- Summary income/spend/net -> future economy/wallet settlement

### Missing for current engine contract
- Currency unit routing key
- Transaction type key
- Account source/target key

### Needs supplement
- Currency scope keys
- Ledger event keys
- Account routing keys

## 3. Probability.xlsx

### Sheets read
- `README`
- `BaseProbability`
- `Modifiers`

### Fields
- `BaseProbability`: `Tier`, `Target Fish`, `Base Success %`, `Bait Loss %`, `Small Fish %`, `Escape %`, `Rare Event %`, `Pity Floor`, `Notes`
- `Modifiers`: `Modifier`, `Effect Type`, `Value`, `Applies To`, `Notes`

### Direct mappings
- Base success / loss / escape / rare / pity -> `FishingEngine`
- Modifiers -> `FishingEngine`, `WeatherSystem`

### Missing for current engine contract
- Weight key for blended rolls
- Trigger condition key
- Override scope key

### Needs supplement
- Weighted event keys
- Trigger keys for local/global modifiers
- Scope keys for multi-map use

## 4. TimeBalance.xlsx

### Sheets read
- `README`
- `TimeTiers`
- `WorkdayExample`

### Fields
- `TimeTiers`: `Loop`, `Min Time`, `Max Time`, `Recommended Checks`, `Event Count`, `Primary Use`, `Player Feeling`
- `WorkdayExample`: `Time`, `World Event`, `Player Action`, `Message Tone`

### Direct mappings
- Time tier windows -> `WaitingEngine`, `WorldClock`, `TodayEngine`
- Example events -> `WorldEngine`, `TodayEngine`

### Missing for current engine contract
- Timezone / locale key
- Day boundary key
- Festival bridge key

### Needs supplement
- Locale/timezone keys
- Day rollover keys
- Festival bridge keys

## 5. CompanionBalance.xlsx

### Sheets read
- `README`
- `RelationshipLevels`
- `GrowthActions`

### Fields
- `RelationshipLevels`: `Level`, `Name EN`, `Name CN`, `Score Min`, `Score Max`, `Unlocks`, `UI Expression`
- `GrowthActions`: `Action`, `Base Score`, `Cooldown`, `Notes`

### Direct mappings
- Relationship thresholds -> `RelationshipEngine`
- Growth actions -> `RelationshipEngine`, `LifeEngine`, `CompanionGiftManager`

### Missing for current engine contract
- Companion type key
- Memory bucket key
- Unlock dependency key

### Needs supplement
- Companion category keys
- Memory bucket keys
- Dependency keys

## 6. RewardBalance.xlsx

### Sheets read
- `README`
- `DecisionRewards`
- `RewardMix`

### Fields
- `DecisionRewards`: `Decision`, `Coin`, `Points`, `Relationship`, `Meaning`, `Memory`, `Future Effect`, `Notes`
- `RewardMix`: `Value Type`, `Target Share`, `Description`

### Direct mappings
- Decision rewards -> `FishingResult`, `MeaningEngine`, `RelationshipEngine`
- Value mix -> reward routing and future economy settlement

### Missing for current engine contract
- Reward id per decision row
- Item reference key
- UI presentation priority key

### Needs supplement
- Reward ids
- Item reference keys
- Presentation priority keys

