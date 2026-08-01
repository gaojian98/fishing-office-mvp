#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT.parent
CONFIG = ROOT / 'assets' / 'config'
ERRORS = []
WARNINGS = []


def load_json(rel):
    path = CONFIG / rel
    try:
        return json.loads(path.read_text(encoding='utf-8'))
    except Exception as exc:
        ERRORS.append(f'{rel}: cannot parse JSON: {exc}')
        return None


def list_of(data, *keys):
    cur = data
    for key in keys:
        if isinstance(cur, dict):
            cur = cur.get(key)
        else:
            return []
    return cur if isinstance(cur, list) else []


def check_duplicates(name, rows):
    seen = set()
    for row in rows:
        if not isinstance(row, dict):
            ERRORS.append(f'{name}: non-object row')
            continue
        item_id = str(row.get('id', ''))
        if not item_id:
            ERRORS.append(f'{name}: missing id')
        elif item_id in seen:
            ERRORS.append(f'{name}: duplicate id {item_id}')
        seen.add(item_id)
    return seen


def asset_exists(asset):
    if not asset:
        return True
    if asset.startswith('assets/'):
        return (ROOT / asset).exists()
    return (ROOT / asset).exists()


def check_asset(name, item_id, asset):
    if asset and not asset_exists(asset):
        ERRORS.append(f'{name} {item_id}: missing asset {asset}')


def check_pubspec_assets():
    pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    if 'version: 1.0.0+1' not in pubspec:
        ERRORS.append('pubspec.yaml: expected version 1.0.0+1')
    assets = re.findall(r'^\s{4}-\s+(assets/[^\n]+)$', pubspec, re.M)
    for asset in assets:
        if not (ROOT / asset).exists():
            ERRORS.append(f'pubspec.yaml: registered asset missing {asset}')
    required = [
        'assets/config/office_layout.json',
        'assets/config/office_interaction.json',
        'assets/config/office_animation.json',
        'assets/config/fish_catalog.json',
        'assets/config/residents.json',
        'assets/config/resident_dialogue.json',
        'assets/config/resident_story.json',
        'assets/config/weather.json',
        'assets/config/festival.json',
        'assets/config/rumor.json',
        'assets/config/legend.json',
        'assets/config/store/store_products.json',
    ]
    for asset in required:
        if asset not in assets:
            ERRORS.append(f'pubspec.yaml: required asset not registered {asset}')


def check_no_local_paths():
    patterns = ('/Users/pc', '127.0.0.1', 'localhost')
    scan_roots = [ROOT / 'lib', ROOT / 'assets' / 'config', PROJECT / 'server.js', ROOT / 'server.js']
    for target in scan_roots:
        files = [target] if target.is_file() else target.rglob('*')
        for path in files:
            if path.is_file() and path.suffix in {'.dart', '.json', '.js', '.html', '.yaml'}:
                text = path.read_text(encoding='utf-8', errors='ignore')
                for pat in patterns:
                    if pat in text:
                        ERRORS.append(f'{path.relative_to(PROJECT)}: contains local-only reference {pat}')


def check_store():
    data = load_json('store/store_products.json') or {}
    category_ids = check_duplicates('store.categories', list_of(data, 'categories'))
    product_ids = check_duplicates('store.products', list_of(data, 'products'))
    for row in list_of(data, 'categories'):
        check_asset('store.category', row.get('id'), row.get('icon', ''))
    for row in list_of(data, 'products'):
        if row.get('category') not in category_ids:
            ERRORS.append(f"store.product {row.get('id')}: unknown category {row.get('category')}")
        check_asset('store.product', row.get('id'), row.get('image', ''))
    return product_ids


def check_world_content():
    residents = load_json('residents.json') or {}
    fish = load_json('fish_catalog.json') or {}
    dialogue = load_json('resident_dialogue.json') or {}
    stories = load_json('resident_story.json') or {}
    festivals = load_json('festival.json') or {}
    weather = load_json('weather.json') or {}
    rumor = load_json('rumor.json') or {}
    identity = load_json('identity.json') or {}
    legend = load_json('legend.json') or {}
    tasks = load_json('task.json') or {}
    honor = load_json('honor.json') or {}
    layout = load_json('office_layout.json') or {}
    interaction = load_json('office_interaction.json') or {}
    animation = load_json('office_animation.json') or {}

    resident_rows = list_of(residents, 'residents')
    fish_rows = list_of(fish, 'fish')
    dialogue_rows = list_of(dialogue, 'dialogues')
    story_rows = list_of(stories, 'stories')

    resident_ids = check_duplicates('residents', resident_rows)
    fish_ids = check_duplicates('fish_catalog', fish_rows)
    dialogue_ids = check_duplicates('resident_dialogue', dialogue_rows)
    story_ids = check_duplicates('resident_story', story_rows)
    check_duplicates('festival', list_of(festivals, 'festivals'))
    check_duplicates('weather', list_of(weather, 'weatherEvents'))
    check_duplicates('rumor', list_of(rumor, 'rumors'))
    check_duplicates('identity', list_of(identity, 'identities'))
    check_duplicates('legend', list_of(legend, 'legends'))
    check_duplicates('task', list_of(tasks, 'tasks', 'items'))
    check_duplicates('honor', list_of(honor, 'honor', 'badges'))
    check_duplicates('office_layout.elements', list_of(layout, 'elements'))
    check_duplicates('office_interaction.hotspots', list_of(interaction, 'hotspots'))
    check_duplicates('office_animation.animations', list_of(animation, 'animations'))

    for row in dialogue_rows:
        rid = row.get('residentId')
        if rid and rid not in resident_ids:
            ERRORS.append(f"resident_dialogue {row.get('id')}: unknown residentId {rid}")
    for row in story_rows:
        rid = row.get('residentId')
        if rid and rid not in resident_ids:
            ERRORS.append(f"resident_story {row.get('id')}: unknown residentId {rid}")
        for did in row.get('dialogueIds', []) or []:
            if did not in dialogue_ids:
                ERRORS.append(f"resident_story {row.get('id')}: unknown dialogueId {did}")
        for sid in (row.get('conditions') or {}).get('requiredStories', []) or []:
            if sid not in story_ids:
                ERRORS.append(f"resident_story {row.get('id')}: unknown requiredStory {sid}")

    rarity_rank = {'common': 1, 'rare': 2, 'epic': 3, 'legend': 4, 'myth': 5}
    by_id = {row.get('id'): row for row in fish_rows if isinstance(row, dict)}
    graph = {}
    for row in fish_rows:
        fid = row.get('id')
        next_id = row.get('nextBaitTarget') or ''
        bait = row.get('baitRequired') or ''
        if next_id:
            if next_id not in by_id:
                ERRORS.append(f'fish {fid}: missing nextBaitTarget {next_id}')
            else:
                graph[fid] = next_id
        if bait.startswith('fish_') and bait not in by_id:
            ERRORS.append(f'fish {fid}: missing baitRequired {bait}')
        if bait.startswith('fish_') and bait in by_id:
            if rarity_rank.get(by_id[bait].get('rarity'), 0) > rarity_rank.get(row.get('rarity'), 0):
                ERRORS.append(f'fish {fid}: baitRequired has higher rarity than result')
    for start in graph:
        seen = set()
        current = start
        while current in graph:
            if current in seen:
                ERRORS.append(f'fish_catalog: bait chain cycle at {current}')
                break
            seen.add(current)
            current = graph[current]

    counts = {
        'residents': len(resident_rows),
        'fish': len(fish_rows),
        'dialogues': len(dialogue_rows),
        'stories': len(story_rows),
        'festivals': len(list_of(festivals, 'festivals')),
        'weather': len(list_of(weather, 'weatherEvents')),
        'rumors': len(list_of(rumor, 'rumors')),
        'identity': len(list_of(identity, 'identities')),
        'legend': len(list_of(legend, 'legends')),
        'tasks': len(list_of(tasks, 'tasks', 'items')),
        'honor': len(list_of(honor, 'honor', 'badges')),
    }
    expected = {'residents': 100, 'fish': 90, 'dialogues': 2460, 'stories': 1320, 'festivals': 50, 'weather': 100, 'rumors': 300, 'identity': 100, 'legend': 100}
    for key, minimum in expected.items():
        if counts.get(key, 0) < minimum:
            ERRORS.append(f'{key}: expected at least {minimum}, got {counts.get(key, 0)}')
    return counts


def main():
    check_pubspec_assets()
    check_no_local_paths()
    store_product_ids = check_store()
    counts = check_world_content()
    result = {
        'version': 'v1.0.0',
        'saveVersion': '1.0',
        'counts': counts,
        'storeProducts': len(store_product_ids),
        'errors': ERRORS,
        'warnings': WARNINGS,
        'pass': not ERRORS,
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))
    if ERRORS:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
