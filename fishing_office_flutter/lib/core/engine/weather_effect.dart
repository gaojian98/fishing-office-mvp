import 'weather_state.dart';

class WeatherEffect {
  const WeatherEffect({
    required this.weatherType,
    required this.fishMood,
    required this.waitingTone,
    required this.companionTone,
    required this.oceanTone,
    required this.fishingNotes,
  });

  final WeatherType weatherType;
  final String fishMood;
  final String waitingTone;
  final String companionTone;
  final String oceanTone;
  final List<String> fishingNotes;

  factory WeatherEffect.fromType(WeatherType type) {
    switch (type) {
      case WeatherType.sunny:
        return const WeatherEffect(
          weatherType: WeatherType.sunny,
          fishMood: 'active',
          waitingTone: 'light',
          companionTone: 'bright',
          oceanTone: 'bright',
          fishingNotes: ['fish_near_surface'],
        );
      case WeatherType.cloudy:
        return const WeatherEffect(
          weatherType: WeatherType.cloudy,
          fishMood: 'steady',
          waitingTone: 'soft',
          companionTone: 'calm',
          oceanTone: 'muted',
          fishingNotes: ['slight_visibility_drop'],
        );
      case WeatherType.lightRain:
        return const WeatherEffect(
          weatherType: WeatherType.lightRain,
          fishMood: 'quiet',
          waitingTone: 'soft',
          companionTone: 'gentle',
          oceanTone: 'still',
          fishingNotes: ['rare_fish_nearby'],
        );
      case WeatherType.windy:
        return const WeatherEffect(
          weatherType: WeatherType.windy,
          fishMood: 'restless',
          waitingTone: 'restless',
          companionTone: 'watchful',
          oceanTone: 'rough',
          fishingNotes: ['float_harder_to_read'],
        );
      case WeatherType.misty:
        return const WeatherEffect(
          weatherType: WeatherType.misty,
          fishMood: 'mysterious',
          waitingTone: 'mysterious',
          companionTone: 'thoughtful',
          oceanTone: 'soft',
          fishingNotes: ['special_events_possible'],
        );
      case WeatherType.sunsetGlow:
        return const WeatherEffect(
          weatherType: WeatherType.sunsetGlow,
          fishMood: 'glowing',
          waitingTone: 'warm',
          companionTone: 'warm',
          oceanTone: 'golden',
          fishingNotes: ['evening_activity'],
        );
      case WeatherType.calmSea:
        return const WeatherEffect(
          weatherType: WeatherType.calmSea,
          fishMood: 'balanced',
          waitingTone: 'steady',
          companionTone: 'peaceful',
          oceanTone: 'still',
          fishingNotes: ['stable_wait'],
        );
      case WeatherType.stormComing:
        return const WeatherEffect(
          weatherType: WeatherType.stormComing,
          fishMood: 'charged',
          waitingTone: 'tense',
          companionTone: 'concerned',
          oceanTone: 'wild',
          fishingNotes: ['high_attention'],
        );
    }
  }
}
