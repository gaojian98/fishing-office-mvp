import 'ocean_ecology.dart';
import 'ocean_mood.dart';

class OceanState {
  const OceanState({
    required this.oceanId,
    required this.mood,
    required this.ecology,
    required this.seaData,
    required this.weatherTags,
    required this.memoryTags,
    required this.newsTags,
    required this.updatedAt,
  });

  factory OceanState.initial() {
    return OceanState(
      oceanId: 'main_ocean',
      mood: OceanMood.calm(),
      ecology: OceanEcology.initial(),
      seaData: const {},
      weatherTags: const [],
      memoryTags: const [],
      newsTags: const [],
      updatedAt: DateTime.now(),
    );
  }

  final String oceanId;
  final OceanMood mood;
  final OceanEcology ecology;
  final Map<String, dynamic> seaData;
  final List<String> weatherTags;
  final List<String> memoryTags;
  final List<String> newsTags;
  final DateTime updatedAt;

  OceanState copyWith({
    String? oceanId,
    OceanMood? mood,
    OceanEcology? ecology,
    Map<String, dynamic>? seaData,
    List<String>? weatherTags,
    List<String>? memoryTags,
    List<String>? newsTags,
    DateTime? updatedAt,
  }) {
    return OceanState(
      oceanId: oceanId ?? this.oceanId,
      mood: mood ?? this.mood,
      ecology: ecology ?? this.ecology,
      seaData: seaData ?? this.seaData,
      weatherTags: weatherTags ?? this.weatherTags,
      memoryTags: memoryTags ?? this.memoryTags,
      newsTags: newsTags ?? this.newsTags,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'oceanId': oceanId,
      'mood': mood.toMap(),
      'ecology': ecology.toMap(),
      'seaData': seaData,
      'weatherTags': weatherTags,
      'memoryTags': memoryTags,
      'newsTags': newsTags,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
