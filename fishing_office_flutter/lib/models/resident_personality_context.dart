import 'location_context.dart';
import 'resident_config.dart';

class ResidentPersonalityContext {
  const ResidentPersonalityContext({
    required this.residentId,
    required this.traits,
    required this.dominantTrait,
    required this.socialPreference,
    required this.workPreference,
    required this.riskPreference,
    required this.rumorPreference,
    required this.storyPreference,
    required this.locationPreferences,
    required this.interactionWeights,
    required this.dialogueTags,
    required this.eventReactionTags,
  });

  factory ResidentPersonalityContext.fromResident(ResidentProfile resident) {
    final traits = normalizeTraits(
      <String>[
        resident.personality,
        ..._listValue(resident.raw['personalityTags']),
        ..._listValue(resident.raw['traits']),
      ],
    );
    final resolvedTraits = traits.isEmpty ? const <String>['calm'] : traits;
    final dominant = resolvedTraits.first;
    return ResidentPersonalityContext(
      residentId: resident.id,
      traits: resolvedTraits,
      dominantTrait: dominant,
      socialPreference: _socialPreference(resolvedTraits),
      workPreference: _workPreference(resolvedTraits),
      riskPreference: _riskPreference(resolvedTraits),
      rumorPreference: _rumorPreference(resolvedTraits),
      storyPreference: _storyPreference(resolvedTraits),
      locationPreferences: _locationPreferences(resolvedTraits),
      interactionWeights: _interactionWeights(resolvedTraits),
      dialogueTags: _dialogueTags(resolvedTraits),
      eventReactionTags: _eventReactionTags(resolvedTraits),
    );
  }

  final String residentId;
  final List<String> traits;
  final String dominantTrait;
  final String socialPreference;
  final String workPreference;
  final String riskPreference;
  final String rumorPreference;
  final String storyPreference;
  final List<String> locationPreferences;
  final Map<String, int> interactionWeights;
  final List<String> dialogueTags;
  final List<String> eventReactionTags;

  bool hasTrait(String trait) => traits.contains(normalizeTrait(trait));

  int locationWeight(String locationId) {
    final normalized = LocationContext.normalizeId(locationId);
    final index = locationPreferences.indexOf(normalized);
    return index < 0 ? 0 : locationPreferences.length - index;
  }

  String preferredLocationForPhase(String phase) {
    for (final location in locationPreferences) {
      if (LocationContext.isReasonableForPhase(location, phase)) {
        return location;
      }
    }
    return LocationContext.fallbackForPhase(phase, seed: residentId);
  }

  static List<String> normalizeTraits(Iterable<String> rawTraits) {
    final result = <String>[];
    for (final raw in rawTraits) {
      for (final token in raw.split(RegExp(r'[,/|、，\s]+'))) {
        final normalized = normalizeTrait(token);
        if (normalized.isNotEmpty && !result.contains(normalized)) {
          result.add(normalized);
        }
      }
    }
    return result;
  }

  static String normalizeTrait(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) return '';
    if (_traitAliases.containsKey(value)) return _traitAliases[value]!;
    for (final entry in _traitAliases.entries) {
      if (value.contains(entry.key)) return entry.value;
    }
    if (_supportedTraits.contains(value)) return value;
    return 'calm';
  }

  static List<String> _listValue(Object? value) {
    if (value is! List) return const <String>[];
    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static String _socialPreference(List<String> traits) {
    if (traits.any((trait) =>
        trait == 'outgoing' || trait == 'gossipy' || trait == 'playful')) {
      return 'social';
    }
    if (traits.any((trait) =>
        trait == 'introverted' || trait == 'cautious' || trait == 'calm')) {
      return 'quiet';
    }
    return 'balanced';
  }

  static String _workPreference(List<String> traits) {
    if (traits.any((trait) =>
        trait == 'hardworking' ||
        trait == 'serious' ||
        trait == 'competitive')) {
      return 'focused';
    }
    if (traits.contains('lazy')) return 'slow';
    return 'steady';
  }

  static String _riskPreference(List<String> traits) {
    if (traits.contains('cautious') || traits.contains('sensitive')) {
      return 'careful';
    }
    if (traits.contains('curious') || traits.contains('competitive')) {
      return 'open';
    }
    return 'normal';
  }

  static String _rumorPreference(List<String> traits) {
    if (traits.contains('gossipy')) return 'spread';
    if (traits.contains('cautious') || traits.contains('serious')) {
      return 'verify';
    }
    if (traits.contains('curious')) return 'investigate';
    if (traits.contains('kind')) return 'gentle';
    return 'listen';
  }

  static String _storyPreference(List<String> traits) {
    if (traits.contains('curious')) return 'mystery';
    if (traits.contains('kind')) return 'warm';
    if (traits.contains('competitive')) return 'challenge';
    if (traits.contains('playful')) return 'humor';
    if (traits.contains('sensitive')) return 'memory';
    return 'daily';
  }

  static List<String> _locationPreferences(List<String> traits) {
    final result = <String>[];
    void addAll(List<String> values) {
      for (final value in values) {
        final id = LocationContext.normalizeId(value);
        if (!result.contains(id)) result.add(id);
      }
    }

    for (final trait in traits) {
      switch (trait) {
        case 'outgoing':
          addAll(['pantry', 'reception', 'coffee_shop', 'meeting_room']);
        case 'introverted':
          addAll(['workstation', 'balcony', 'home', 'printing_area']);
        case 'hardworking':
          addAll(['workstation', 'meeting_room', 'manager_room']);
        case 'lazy':
          addAll(['pantry', 'balcony', 'coffee_shop', 'home']);
        case 'gossipy':
          addAll(['pantry', 'reception', 'coffee_shop']);
        case 'serious':
          addAll(['workstation', 'meeting_room', 'manager_room']);
        case 'curious':
          addAll(['printing_area', 'reception', 'dock', 'seaside']);
        case 'calm':
          addAll(['balcony', 'park', 'home', 'seaside']);
        case 'playful':
          addAll(['printing_area', 'pantry', 'reception', 'coffee_shop']);
        case 'kind':
          addAll(['reception', 'pantry', 'park', 'coffee_shop']);
        case 'competitive':
          addAll(['meeting_room', 'manager_room', 'workstation']);
        case 'cautious':
          addAll(['workstation', 'home', 'reception']);
        default:
          break;
      }
    }
    if (result.isEmpty) addAll(['workstation', 'pantry', 'home']);
    return result;
  }

  static Map<String, int> _interactionWeights(List<String> traits) {
    final weights = <String, int>{
      'talk': 1,
      'short_talk': 1,
      'observe': 1,
    };
    void add(String key, int value) {
      weights[key] = (weights[key] ?? 0) + value;
    }

    if (traits.contains('outgoing')) {
      add('talk', 3);
      add('invite_coffee', 3);
    }
    if (traits.contains('introverted')) {
      add('observe', 3);
      add('short_talk', 2);
    }
    if (traits.contains('gossipy')) add('ask_about_rumor', 4);
    if (traits.contains('kind')) {
      add('help_work', 3);
      add('comfort', 3);
    }
    if (traits.contains('competitive')) {
      add('discuss_task', 3);
      add('compare_progress', 2);
    }
    if (traits.contains('playful')) {
      add('joke', 3);
      add('office_humor', 3);
    }
    return Map<String, int>.unmodifiable(weights);
  }

  static List<String> _dialogueTags(List<String> traits) {
    final tags = <String>{...traits};
    if (traits.contains('gossipy')) tags.addAll(['rumor', 'talkative']);
    if (traits.contains('serious')) tags.addAll(['work', 'focused']);
    if (traits.contains('playful')) tags.addAll(['humor', 'joke']);
    if (traits.contains('kind')) tags.addAll(['help', 'warm']);
    if (traits.contains('introverted')) tags.addAll(['short', 'quiet']);
    if (traits.contains('curious')) tags.addAll(['mystery', 'discovery']);
    return tags.toList(growable: false);
  }

  static List<String> _eventReactionTags(List<String> traits) {
    final tags = <String>{...traits};
    if (traits.contains('playful')) tags.add('office_humor');
    if (traits.contains('serious')) tags.add('work_fault');
    if (traits.contains('curious')) tags.add('mystery');
    if (traits.contains('cautious')) tags.add('avoid_risk');
    if (traits.contains('kind')) tags.add('help');
    if (traits.contains('competitive')) tags.add('challenge');
    return tags.toList(growable: false);
  }
}

const _supportedTraits = <String>{
  'outgoing',
  'introverted',
  'hardworking',
  'lazy',
  'gossipy',
  'serious',
  'optimistic',
  'pessimistic',
  'curious',
  'cautious',
  'kind',
  'competitive',
  'playful',
  'calm',
  'sensitive',
};

const _traitAliases = <String, String>{
  '外向': 'outgoing',
  '开朗': 'outgoing',
  '活泼': 'outgoing',
  'talkative': 'gossipy',
  'lively': 'outgoing',
  'energetic': 'outgoing',
  'hearty': 'outgoing',
  '内向': 'introverted',
  '安静': 'introverted',
  'quiet': 'introverted',
  'solitary': 'introverted',
  'awkward': 'introverted',
  '努力': 'hardworking',
  '勤奋': 'hardworking',
  'busy': 'hardworking',
  'practical': 'hardworking',
  'reliable': 'hardworking',
  'organized': 'hardworking',
  'orderly': 'hardworking',
  'meticulous': 'hardworking',
  '偷懒': 'lazy',
  '懒': 'lazy',
  'sleepy': 'lazy',
  '八卦': 'gossipy',
  'informed': 'gossipy',
  'witty': 'gossipy',
  '严肃': 'serious',
  'serious': 'serious',
  'precise': 'serious',
  'upright': 'serious',
  'sharp': 'serious',
  '乐观': 'optimistic',
  'cheerful': 'optimistic',
  'bright': 'optimistic',
  'warm': 'optimistic',
  '悲观': 'pessimistic',
  'nostalgic': 'pessimistic',
  '好奇': 'curious',
  'curious': 'curious',
  'creative': 'curious',
  'imaginative': 'curious',
  'mysterious': 'curious',
  'observant': 'curious',
  'scholarly': 'curious',
  '小心': 'cautious',
  '谨慎': 'cautious',
  'careful': 'cautious',
  'watchful': 'cautious',
  '善良': 'kind',
  '温柔': 'kind',
  'kind': 'kind',
  'gentle': 'kind',
  'nurturing': 'kind',
  'tender': 'kind',
  'soft': 'kind',
  'soothing': 'kind',
  '竞争': 'competitive',
  'bold': 'competitive',
  'brave': 'competitive',
  'direct': 'competitive',
  '好玩': 'playful',
  '幽默': 'playful',
  'funny': 'playful',
  'playful': 'playful',
  'dreamy': 'playful',
  '平静': 'calm',
  'calm': 'calm',
  'patient': 'calm',
  'serene': 'calm',
  'seasoned': 'calm',
  'wise': 'calm',
  'philosophical': 'calm',
  'poetic': 'calm',
  'polite': 'calm',
  'frugal': 'calm',
  'easygoing': 'calm',
  'stylish': 'calm',
  '敏感': 'sensitive',
  'sensitive': 'sensitive',
};
