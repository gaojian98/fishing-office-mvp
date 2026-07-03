class OceanEcology {
  const OceanEcology({
    required this.fishPopulation,
    required this.migrationNotes,
    required this.lifeForms,
    required this.context,
  });

  factory OceanEcology.initial() {
    return const OceanEcology(
      fishPopulation: {},
      migrationNotes: [],
      lifeForms: [],
      context: {},
    );
  }

  final Map<String, int> fishPopulation;
  final List<String> migrationNotes;
  final List<String> lifeForms;
  final Map<String, dynamic> context;

  OceanEcology copyWith({
    Map<String, int>? fishPopulation,
    List<String>? migrationNotes,
    List<String>? lifeForms,
    Map<String, dynamic>? context,
  }) {
    return OceanEcology(
      fishPopulation: fishPopulation ?? this.fishPopulation,
      migrationNotes: migrationNotes ?? this.migrationNotes,
      lifeForms: lifeForms ?? this.lifeForms,
      context: context ?? this.context,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fishPopulation': fishPopulation,
      'migrationNotes': migrationNotes,
      'lifeForms': lifeForms,
      'context': context,
    };
  }
}
