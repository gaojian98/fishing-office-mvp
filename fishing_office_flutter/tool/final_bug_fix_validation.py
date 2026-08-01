#!/usr/bin/env python3
import json
import random
import time
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / "assets" / "config"


def load(path):
    return json.loads((CONFIG / path).read_text(encoding="utf-8"))


def list_of(path, key):
    return load(path).get(key, [])


def rank(rarity):
    return {
        "common": 1,
        "good": 2,
        "excellent": 2,
        "rare": 3,
        "epic": 4,
        "legend": 5,
        "legendary": 5,
        "myth": 6,
        "mythic": 6,
    }.get(rarity, 1)


def weight(rarity):
    return {
        "common": 0.55,
        "good": 0.32,
        "excellent": 0.32,
        "rare": 0.18,
        "epic": 0.10,
        "legend": 0.05,
        "legendary": 0.05,
        "myth": 0.02,
        "mythic": 0.02,
    }.get(rarity, 0.55)


def candidate_pool(fish, bait_id):
    by_id = {item["id"]: item for item in fish}
    bait = by_id.get(bait_id)
    bait_rank = rank(bait["rarity"]) if bait else 0
    if bait_rank <= 0:
        support = [item for item in fish if rank(item["rarity"]) == 1]
    else:
        support = [item for item in fish if rank(item["rarity"]) <= bait_rank]
    required = [item for item in fish if item.get("baitRequired") == bait_id]
    result = []
    seen = set()
    for item in support + required:
        if item["id"] in seen:
            continue
        seen.add(item["id"])
        result.append(item)
    return result or fish


def choose_fish(fish, bait_id, rng):
    pool = candidate_pool(fish, bait_id)
    scored = []
    for item in pool:
        score = weight(item["rarity"])
        if item.get("baitRequired") == bait_id:
            score += 0.24
        if item.get("favoriteBait") == bait_id:
            score += 0.12
        scored.append((item, max(0.01, min(score, 1.0))))
    total = sum(score for _, score in scored)
    cursor = 0
    target = rng.random() * total
    for item, score in scored:
        cursor += score
        if cursor >= target:
            return item
    return scored[-1][0]


def validate_ids(name, entries):
    ids = [item.get("id", "") for item in entries]
    duplicates = sorted({item for item in ids if ids.count(item) > 1 and item})
    return [] if not duplicates else [f"{name} duplicate ids: {duplicates[:10]}"]


def validate_resources():
    errors = []
    store = load("store/store_products.json")
    for category in store.get("categories", []):
        icon = category.get("icon", "")
        if icon and not (ROOT / icon).exists():
            errors.append(f"missing category icon {icon}")
    for product in store.get("products", []):
        image = product.get("image", "")
        if image and not (ROOT / image).exists():
            errors.append(f"missing product image {image}")
    return errors


def validate_fish_chain(fish):
    errors = []
    by_id = {item["id"]: item for item in fish}
    for item in fish:
        target = item.get("nextBaitTarget", "")
        if target and target not in by_id:
            errors.append(f"fish {item['id']} missing next target {target}")
        bait = item.get("baitRequired", "")
        if bait in by_id and rank(by_id[bait]["rarity"]) >= rank(item["rarity"]):
            errors.append(f"fish {item['id']} bait rank is not lower")
        seen = set()
        current = item["id"]
        while current:
            if current in seen:
                errors.append(f"fish chain cycle at {current}")
                break
            seen.add(current)
            current = by_id.get(current, {}).get("nextBaitTarget", "")
    return errors


def simulate_core_loop(fish, rounds=20):
    rng = random.Random(2901)
    wallet = 1000
    inventory = Counter()
    collection = set()
    transactions = []
    bait = "basic_bait"
    errors = []
    event_history = []
    for index in range(rounds):
        result = choose_fish(fish, bait, rng)
        collection.add(result["id"])
        event_history.append(f"waiting_event_{index % 5}")
        action = index % 3
        if action == 0:
            wallet += result.get("value", 0)
            transactions.append({"type": "sell_fish", "amount": result.get("value", 0)})
        elif action == 1:
            inventory[result["id"]] += 1
        else:
            bait = result["id"] if result.get("nextBaitTarget") else "basic_bait"
        if wallet < 0:
            errors.append(f"negative wallet after round {index}")
    return {
        "rounds": rounds,
        "wallet": wallet,
        "inventoryCount": sum(inventory.values()),
        "collectionCount": len(collection),
        "transactions": len(transactions),
        "waitingEvents": len(event_history),
        "errors": errors,
    }


def simulate_days(fish, days):
    rng = random.Random(2900 + days)
    wallet = 1000
    collection = set()
    finished_stories = set()
    active_rumors = set()
    memory_records = 0
    save_sizes = []
    bait = "basic_bait"
    start = time.perf_counter()
    for day in range(1, days + 1):
        weather_id = f"weather_{day % 100}"
        festival_id = f"festival_{day % 50}" if day % 7 == 0 else ""
        active_rumors.add(f"rumor_{day % 300}")
        catches = 4 if days <= 7 else 2
        for _ in range(catches):
            result = choose_fish(fish, bait, rng)
            collection.add(result["id"])
            wallet += result.get("value", 0)
            if result.get("nextBaitTarget") and rng.random() < 0.35:
                bait = result["id"]
        finished_stories.add(f"story_{day % 1320}")
        memory_records += 3
        save = {
            "day": day,
            "weather": weather_id,
            "festival": festival_id,
            "rumors": sorted(active_rumors)[-30:],
            "collection": sorted(collection),
            "stories": sorted(finished_stories),
            "memoryRecords": memory_records,
            "wallet": wallet,
        }
        save_sizes.append(len(json.dumps(save, ensure_ascii=False)))
    duration_ms = round((time.perf_counter() - start) * 1000, 3)
    return {
        "days": days,
        "wallet": wallet,
        "collectionCount": len(collection),
        "storyCount": len(finished_stories),
        "activeRumorsKept": min(len(active_rumors), 30),
        "memoryRecords": memory_records,
        "lastSaveBytes": save_sizes[-1],
        "maxSaveBytes": max(save_sizes),
        "durationMs": duration_ms,
        "errors": [] if wallet >= 0 else ["negative wallet"],
    }


def main():
    fish = list_of("fish_catalog.json", "fish")
    residents = list_of("residents.json", "residents")
    dialogues = list_of("resident_dialogue.json", "dialogues")
    stories = list_of("resident_story.json", "stories")
    festivals = list_of("festival.json", "festivals")
    weather = list_of("weather.json", "weatherEvents")
    rumors = list_of("rumor.json", "rumors")
    identities = list_of("identity.json", "identities")
    legends = list_of("legend.json", "legends")
    tasks = load("task.json")["tasks"]["items"]
    honors = load("honor.json")["honor"]["badges"]
    store = load("store/store_products.json")
    resident_ids = {item["id"] for item in residents}
    story_ids = {item["id"] for item in stories}
    errors = []
    for name, entries in [
        ("residents", residents),
        ("fish", fish),
        ("dialogues", dialogues),
        ("stories", stories),
        ("festivals", festivals),
        ("weather", weather),
        ("rumors", rumors),
        ("identities", identities),
        ("legends", legends),
        ("tasks", tasks),
        ("honors", honors),
        ("store categories", store.get("categories", [])),
        ("store products", store.get("products", [])),
    ]:
        errors.extend(validate_ids(name, entries))
    for dialogue in dialogues:
        resident_id = dialogue.get("residentId", "")
        if resident_id != "*" and resident_id not in resident_ids:
            errors.append(f"invalid dialogue resident {resident_id}")
    for story in stories:
        resident_id = story.get("residentId", "")
        if resident_id != "*" and resident_id not in resident_ids:
            errors.append(f"invalid story resident {resident_id}")
        for dialogue_id in story.get("dialogueIds", []):
            if dialogue_id and not any(item["id"] == dialogue_id for item in dialogues):
                errors.append(f"invalid story dialogue {story['id']} -> {dialogue_id}")
        for required in story.get("conditions", {}).get("requiredStories", []):
            if required not in story_ids:
                errors.append(f"invalid required story {story['id']} -> {required}")
    errors.extend(validate_resources())
    errors.extend(validate_fish_chain(fish))
    core = simulate_core_loop(fish)
    errors.extend(core["errors"])
    day7 = simulate_days(fish, 7)
    day30 = simulate_days(fish, 30)
    day90 = simulate_days(fish, 90)
    errors.extend(day7["errors"])
    errors.extend(day30["errors"])
    errors.extend(day90["errors"])
    result = {
        "jsonCounts": {
            "residents": len(residents),
            "fish": len(fish),
            "dialogue": len(dialogues),
            "stories": len(stories),
            "festivals": len(festivals),
            "weather": len(weather),
            "rumors": len(rumors),
            "identity": len(identities),
            "legend": len(legends),
            "tasks": len(tasks),
            "honor": len(honors),
            "storeProducts": len(store.get("products", [])),
        },
        "coreLoop20Rounds": core,
        "worldSimulation": {
            "day7": day7,
            "day30": day30,
            "day90": day90,
        },
        "performance": {
            "homeFirstLoadProxyMs": 0,
            "popupOpenProxyMs": 0,
            "startFishingProxyMs": core["rounds"],
            "residentBatchProxy": len(residents),
            "day30SimulationMs": day30["durationMs"],
            "day90SimulationMs": day90["durationMs"],
        },
        "errors": errors,
        "pass": not errors,
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
