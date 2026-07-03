class OceanMood {
  const OceanMood({
    required this.name,
    required this.intensity,
    required this.description,
    required this.context,
  });

  final String name;
  final int intensity;
  final String description;
  final Map<String, dynamic> context;

  factory OceanMood.calm() {
    return const OceanMood(
      name: 'Calm',
      intensity: 1,
      description: '海面平静，节奏温和。',
      context: {},
    );
  }

  OceanMood copyWith({
    String? name,
    int? intensity,
    String? description,
    Map<String, dynamic>? context,
  }) {
    return OceanMood(
      name: name ?? this.name,
      intensity: intensity ?? this.intensity,
      description: description ?? this.description,
      context: context ?? this.context,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'intensity': intensity,
      'description': description,
      'context': context,
    };
  }
}
