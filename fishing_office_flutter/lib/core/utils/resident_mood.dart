const supportedResidentMoods = <String>{
  'calm',
  'happy',
  'curious',
  'excited',
  'tired',
  'busy',
  'lonely',
  'worried',
  'sad',
  'angry',
  'grateful',
  'playful',
};

String normalizeResidentMood(String value) {
  final mood = value.trim().toLowerCase();
  if (supportedResidentMoods.contains(mood)) return mood;
  return switch (mood) {
    'warm' || 'friendly' || 'bright' || 'cheerful' || 'joyful' => 'happy',
    'quiet' || 'peaceful' || 'relaxed' || 'focused' => 'calm',
    'thoughtful' || 'hopeful' || 'interested' => 'curious',
    'sleepy' || 'exhausted' || 'lazy' => 'tired',
    'nervous' || 'anxious' || 'stormy' => 'worried',
    'thankful' || 'moved' => 'grateful',
    'funny' || 'mischievous' => 'playful',
    'mad' => 'angry',
    _ => mood.isEmpty ? 'calm' : 'calm',
  };
}

bool isMajorMoodReason(String reason) {
  return reason == 'player_helped' ||
      reason == 'story_finished' ||
      reason == 'festival_started' ||
      reason == 'rumor_heard';
}

String moodReasonFromTag(String tag) {
  if (tag.contains('help') || tag.contains('grateful')) return 'player_helped';
  if (tag.contains('story')) return 'story_finished';
  if (tag.contains('festival')) return 'festival_started';
  if (tag.contains('rumor')) return 'rumor_heard';
  if (tag.contains('weather')) return 'weather_change';
  return '';
}
