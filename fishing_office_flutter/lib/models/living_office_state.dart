class LivingOfficeState {
  const LivingOfficeState({
    required this.date,
    required this.timeOfDay,
    required this.officeMood,
    required this.activityLevel,
    required this.productivityLevel,
    required this.socialLevel,
    required this.tensionLevel,
    required this.activeResidentCount,
    required this.workingResidentCount,
    required this.breakResidentCount,
    required this.overtimeResidentCount,
    required this.activeGroupCount,
    required this.activeEventCount,
    required this.activeStoryCount,
    required this.popularLocations,
    required this.popularTopics,
    required this.dominantRumors,
    required this.currentFestival,
    required this.currentWeather,
    required this.importantChanges,
    required this.worldTags,
    required this.lastUpdatedAt,
  });

  factory LivingOfficeState.empty() {
    return const LivingOfficeState(
      date: '',
      timeOfDay: '',
      officeMood: 'calm',
      activityLevel: 0,
      productivityLevel: 0,
      socialLevel: 0,
      tensionLevel: 0,
      activeResidentCount: 0,
      workingResidentCount: 0,
      breakResidentCount: 0,
      overtimeResidentCount: 0,
      activeGroupCount: 0,
      activeEventCount: 0,
      activeStoryCount: 0,
      popularLocations: <String>[],
      popularTopics: <String>[],
      dominantRumors: <String>[],
      currentFestival: '',
      currentWeather: '',
      importantChanges: <String>[],
      worldTags: <String>[],
      lastUpdatedAt: '',
    );
  }

  factory LivingOfficeState.fromJson(Map<String, dynamic> json) {
    return LivingOfficeState(
      date: json['date']?.toString() ?? '',
      timeOfDay: json['timeOfDay']?.toString() ?? '',
      officeMood: json['officeMood']?.toString() ?? 'calm',
      activityLevel: _readInt(json['activityLevel']),
      productivityLevel: _readInt(json['productivityLevel']),
      socialLevel: _readInt(json['socialLevel']),
      tensionLevel: _readInt(json['tensionLevel']),
      activeResidentCount: _readInt(json['activeResidentCount']),
      workingResidentCount: _readInt(json['workingResidentCount']),
      breakResidentCount: _readInt(json['breakResidentCount']),
      overtimeResidentCount: _readInt(json['overtimeResidentCount']),
      activeGroupCount: _readInt(json['activeGroupCount']),
      activeEventCount: _readInt(json['activeEventCount']),
      activeStoryCount: _readInt(json['activeStoryCount']),
      popularLocations: _stringList(json['popularLocations']),
      popularTopics: _stringList(json['popularTopics']),
      dominantRumors: _stringList(json['dominantRumors']),
      currentFestival: json['currentFestival']?.toString() ?? '',
      currentWeather: json['currentWeather']?.toString() ?? '',
      importantChanges: _stringList(json['importantChanges']),
      worldTags: _stringList(json['worldTags']),
      lastUpdatedAt: json['lastUpdatedAt']?.toString() ?? '',
    );
  }

  final String date;
  final String timeOfDay;
  final String officeMood;
  final int activityLevel;
  final int productivityLevel;
  final int socialLevel;
  final int tensionLevel;
  final int activeResidentCount;
  final int workingResidentCount;
  final int breakResidentCount;
  final int overtimeResidentCount;
  final int activeGroupCount;
  final int activeEventCount;
  final int activeStoryCount;
  final List<String> popularLocations;
  final List<String> popularTopics;
  final List<String> dominantRumors;
  final String currentFestival;
  final String currentWeather;
  final List<String> importantChanges;
  final List<String> worldTags;
  final String lastUpdatedAt;

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'timeOfDay': timeOfDay,
      'officeMood': officeMood,
      'activityLevel': activityLevel,
      'productivityLevel': productivityLevel,
      'socialLevel': socialLevel,
      'tensionLevel': tensionLevel,
      'activeResidentCount': activeResidentCount,
      'workingResidentCount': workingResidentCount,
      'breakResidentCount': breakResidentCount,
      'overtimeResidentCount': overtimeResidentCount,
      'activeGroupCount': activeGroupCount,
      'activeEventCount': activeEventCount,
      'activeStoryCount': activeStoryCount,
      'popularLocations': popularLocations,
      'popularTopics': popularTopics,
      'dominantRumors': dominantRumors,
      'currentFestival': currentFestival,
      'currentWeather': currentWeather,
      'importantChanges': importantChanges,
      'worldTags': worldTags,
      'lastUpdatedAt': lastUpdatedAt,
    };
  }

  bool get isEmpty => date.isEmpty && activeResidentCount == 0;
}

class OfficeWorldHistoryEntry {
  const OfficeWorldHistoryEntry({
    required this.date,
    required this.dominantMood,
    required this.activityLevel,
    required this.productivityLevel,
    required this.socialLevel,
    required this.tensionLevel,
    required this.importantEvents,
    required this.importantStories,
    required this.importantGroups,
    required this.importantRumors,
    required this.importantRelationshipChanges,
    required this.tags,
    this.keepForever = false,
  });

  factory OfficeWorldHistoryEntry.fromJson(Map<String, dynamic> json) {
    return OfficeWorldHistoryEntry(
      date: json['date']?.toString() ?? '',
      dominantMood: json['dominantMood']?.toString() ?? 'calm',
      activityLevel: _readInt(json['activityLevel']),
      productivityLevel: _readInt(json['productivityLevel']),
      socialLevel: _readInt(json['socialLevel']),
      tensionLevel: _readInt(json['tensionLevel']),
      importantEvents: _stringList(json['importantEvents']),
      importantStories: _stringList(json['importantStories']),
      importantGroups: _stringList(json['importantGroups']),
      importantRumors: _stringList(json['importantRumors']),
      importantRelationshipChanges:
          _stringList(json['importantRelationshipChanges']),
      tags: _stringList(json['tags']),
      keepForever: json['keepForever'] == true,
    );
  }

  final String date;
  final String dominantMood;
  final int activityLevel;
  final int productivityLevel;
  final int socialLevel;
  final int tensionLevel;
  final List<String> importantEvents;
  final List<String> importantStories;
  final List<String> importantGroups;
  final List<String> importantRumors;
  final List<String> importantRelationshipChanges;
  final List<String> tags;
  final bool keepForever;

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'dominantMood': dominantMood,
      'activityLevel': activityLevel,
      'productivityLevel': productivityLevel,
      'socialLevel': socialLevel,
      'tensionLevel': tensionLevel,
      'importantEvents': importantEvents,
      'importantStories': importantStories,
      'importantGroups': importantGroups,
      'importantRumors': importantRumors,
      'importantRelationshipChanges': importantRelationshipChanges,
      'tags': tags,
      'keepForever': keepForever,
    };
  }
}

List<OfficeWorldHistoryEntry> officeWorldHistoryFromJsonList(Object? value) {
  if (value is! List) return const <OfficeWorldHistoryEntry>[];
  return value
      .whereType<Map>()
      .map((item) => OfficeWorldHistoryEntry.fromJson(
            Map<String, dynamic>.from(item),
          ))
      .where((item) => item.date.isNotEmpty)
      .toList(growable: false);
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return value
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

int _readInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
