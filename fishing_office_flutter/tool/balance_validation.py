#!/usr/bin/env python3
import json
import random
from collections import Counter, defaultdict
from pathlib import Path


BASE = Path(__file__).resolve().parents[1] / "assets" / "config"
RARITY_RANK = {
    "common": 1,
    "good": 2,
    "excellent": 2,
    "rare": 3,
    "epic": 4,
    "legend": 5,
    "legendary": 5,
    "myth": 6,
    "mythic": 6,
}
RARITY_WEIGHT = {
    "common": 0.55,
    "good": 0.32,
    "excellent": 0.32,
    "rare": 0.18,
    "epic": 0.10,
    "legend": 0.05,
    "legendary": 0.05,
    "myth": 0.02,
    "mythic": 0.02,
}
RARITY_WAIT_MINUTES = {
    "common": (0.2, 0.5),
    "good": (0.5, 0.9),
    "excellent": (0.5, 0.9),
    "rare": (0.9, 1.5),
    "epic": (1.5, 3.0),
    "legend": (3.0, 6.0),
    "legendary": (3.0, 6.0),
    "myth": (6.0, 12.0),
    "mythic": (6.0, 12.0),
}


def load_json(path):
    return json.loads((BASE / path).read_text(encoding="utf-8"))


def fish():
    return load_json("fish_catalog.json")["fish"]


def store_products():
    return load_json("store/store_products.json")["products"]


def tasks():
    return load_json("task.json")["tasks"]["items"]


def honors():
    return load_json("honor.json")["honor"]["badges"]


def rarity_rank(value):
    return RARITY_RANK.get(value, 1)


def rarity_wait(value):
    return RARITY_WAIT_MINUTES.get(value, RARITY_WAIT_MINUTES["common"])


def time_score(expected, actual):
    if not expected or expected == "any":
        return 1
    aliases = {actual}
    if actual == "dusk":
        aliases.add("evening")
    if actual == "late_night":
        aliases.add("night")
    return 1 if expected in aliases else 0


def weather_score(expected, weather):
    if not expected or expected == "any":
        return 1
    aliases = {weather}
    if weather == "rain":
        aliases.add("rainy")
    if weather == "sunny":
        aliases.add("晴天")
    return 1 if expected in aliases else 0


def score_fish(item, bait_id, weather="sunny", time_of_day="morning", location="海边"):
    weight = RARITY_WEIGHT.get(item["rarity"], 0.55)
    score = weight
    score += time_score(item.get("favoriteTime", ""), time_of_day) * 0.14
    score += weather_score(item.get("favoriteWeather", ""), weather) * 0.14
    if item.get("baitRequired") == bait_id:
        score += 0.24
    if item.get("favoriteBait") == bait_id:
        score += 0.12
    if location and location in item.get("habitat", ""):
        score += 0.08
    cap = 0.45 + (weight * 0.9)
    return max(0.01, min(score, min(max(cap, 0.12), 1.0)))


def candidate_pool(items, bait_id, weather="sunny", time_of_day="morning", location="海边"):
    bait_fish = next((item for item in items if item["id"] == bait_id), None)
    bait_rank = rarity_rank(bait_fish["rarity"]) if bait_fish else 0
    required = [item for item in items if item.get("baitRequired") == bait_id]
    if bait_rank <= 0:
        support = [item for item in items if rarity_rank(item["rarity"]) == 1]
    else:
        support = [item for item in items if rarity_rank(item["rarity"]) <= bait_rank]
    combined = []
    seen = set()
    for item in support + required:
        if item["id"] in seen:
            continue
        seen.add(item["id"])
        combined.append(item)
    if combined:
        return [
            (item, score_fish(item, bait_id, weather, time_of_day, location))
            for item in combined
        ]
    pool = [
        item
        for item in items
        if item.get("baitRequired") == bait_id or item.get("favoriteBait") == bait_id
    ]
    if not pool:
        pool = items
    return [(item, score_fish(item, bait_id, weather, time_of_day, location)) for item in pool]


def choose_weighted(candidates, rng):
    total = sum(weight for _, weight in candidates)
    target = rng.random() * total
    cursor = 0
    for item, weight in candidates:
        cursor += weight
        if cursor >= target:
            return item
    return candidates[-1][0]


def simulate_results(items, iterations, bait_id, weather, time_of_day, location, seed=27):
    rng = random.Random(seed)
    counts = Counter()
    values = []
    wait_minutes = []
    for _ in range(iterations):
        selected = choose_weighted(
            candidate_pool(items, bait_id, weather, time_of_day, location),
            rng,
        )
        counts[selected["rarity"]] += 1
        values.append(selected.get("value", 0))
        wait_min, wait_max = rarity_wait(selected["rarity"])
        wait_minutes.append(rng.uniform(wait_min, wait_max))
    return {
        "iterations": iterations,
        "bait": bait_id,
        "weather": weather,
        "timeOfDay": time_of_day,
        "location": location,
        "rarityRates": {
            key: round(value / iterations * 100, 2)
            for key, value in sorted(counts.items(), key=lambda item: rarity_rank(item[0]))
        },
        "emptyRate": 0.0,
        "averageValue": round(sum(values) / len(values), 2),
        "averageWaitMinutes": round(sum(wait_minutes) / len(wait_minutes), 2),
    }


def chain_report(items):
    by_id = {item["id"]: item for item in items}
    missing = []
    cycles = []
    invalid_bait_rank = []
    unusable_as_bait = []
    for item in items:
        target = item.get("nextBaitTarget", "")
        if target and target not in by_id:
            missing.append(item["id"])
        seen = []
        current = item["id"]
        while current:
            if current in seen:
                cycles.append(seen[seen.index(current):] + [current])
                break
            seen.append(current)
            current_item = by_id.get(current)
            if not current_item:
                break
            current = current_item.get("nextBaitTarget", "")
            if current and current not in by_id:
                break
        bait = item.get("baitRequired", "")
        if bait in by_id:
            bait_rank = rarity_rank(by_id[bait]["rarity"])
            item_rank = rarity_rank(item["rarity"])
            if bait_rank >= item_rank:
                invalid_bait_rank.append(
                    {
                        "fishId": item["id"],
                        "rarity": item["rarity"],
                        "baitId": bait,
                        "baitRarity": by_id[bait]["rarity"],
                    }
                )
        if item["rarity"] != "myth" and not item.get("nextBaitTarget", ""):
            unusable_as_bait.append(item["id"])
    return {
        "missingNextTargets": missing,
        "cycles": cycles,
        "invalidBaitRank": invalid_bait_rank,
        "unusableAsBait": unusable_as_bait,
    }


def wait_report(items):
    by_rarity = defaultdict(list)
    for item in items:
        wait_min, wait_max = rarity_wait(item["rarity"])
        by_rarity[item["rarity"]].append((wait_min + wait_max) / 2)
    result = {}
    for rarity, values in sorted(by_rarity.items(), key=lambda entry: rarity_rank(entry[0])):
        wait_min, wait_max = rarity_wait(rarity)
        result[rarity] = {
            "fishCount": len(values),
            "minMinutes": wait_min,
            "maxMinutes": wait_max,
            "averageMinutes": round(sum(values) / len(values), 2),
        }
    return result


def simulate_player(items, minutes, catches_per_hour, seed=101):
    rng = random.Random(seed)
    coin = 1000
    collection = set()
    bait = "basic_bait"
    catches = int(minutes / 60 * catches_per_hour)
    sold = 0
    kept = 0
    for index in range(catches):
        result = choose_weighted(candidate_pool(items, bait), rng)
        collection.add(result["id"])
        if index % 4 == 0:
            kept += 1
        else:
            coin += result["value"]
            sold += 1
        if result.get("nextBaitTarget"):
            bait = result["id"]
    return {
        "minutes": minutes,
        "catches": catches,
        "sold": sold,
        "kept": kept,
        "coin": coin,
        "collectionCount": len(collection),
    }


def main():
    items = fish()
    products = [item for item in store_products() if item.get("enabled", True)]
    daily_tasks = [item for item in tasks() if item.get("category") == "daily"]
    report = {
        "counts": {
            "fish": len(items),
            "storeProducts": len(products),
            "tasks": len(tasks()),
            "dailyTasks": len(daily_tasks),
            "honorBadges": len(honors()),
        },
        "rarityCounts": dict(Counter(item["rarity"] for item in items)),
        "waitCurve": wait_report(items),
        "chain": chain_report(items),
        "probability": [
            simulate_results(items, 10000, "basic_bait", "sunny", "morning", "海边"),
            simulate_results(items, 10000, "fish_001", "sunny", "morning", "海边"),
            simulate_results(items, 10000, "fish_011", "rainy", "night", "深海"),
            simulate_results(items, 10000, "fish_025", "sunny", "night", "深海"),
        ],
        "economy": {
            "storeMinPrice": min(item["price"] for item in products),
            "storeMaxPrice": max(item["price"] for item in products),
            "storeAveragePrice": round(sum(item["price"] for item in products) / len(products), 2),
            "dailyRewardFishCoin": sum(
                item.get("reward", {}).get("fishCoin", 0) for item in daily_tasks
            ),
            "player30Minutes": simulate_player(items, 30, catches_per_hour=10),
            "player1Hour": simulate_player(items, 60, catches_per_hour=10),
            "player7Days": simulate_player(items, 60 * 24 * 7, catches_per_hour=2),
            "normal30Days": simulate_player(items, 60 * 24 * 30, catches_per_hour=1),
            "highFreq30Days": simulate_player(items, 60 * 24 * 30, catches_per_hour=4),
        },
    }
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
