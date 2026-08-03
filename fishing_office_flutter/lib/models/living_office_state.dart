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

const int companyNewsHistoryLimit = 120;
const int companyTimelineHistoryLimit = 240;
const int aiCompanyEventHistoryLimit = 120;

class CompanyNewsItem {
  const CompanyNewsItem({
    required this.newsId,
    required this.sourceId,
    required this.type,
    required this.category,
    required this.title,
    required this.summary,
    required this.importance,
    required this.date,
    required this.relatedResidentIds,
    required this.tags,
  });

  factory CompanyNewsItem.fromJson(Map<String, dynamic> json) {
    return CompanyNewsItem(
      newsId: json['newsId']?.toString() ?? '',
      sourceId: json['sourceId']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      importance: _readInt(json['importance']).clamp(0, 100).toInt(),
      date: json['date']?.toString() ?? '',
      relatedResidentIds: _stringList(json['relatedResidentIds']),
      tags: _stringList(json['tags']),
    );
  }

  final String newsId;
  final String sourceId;
  final String type;
  final String category;
  final String title;
  final String summary;
  final int importance;
  final String date;
  final List<String> relatedResidentIds;
  final List<String> tags;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'newsId': newsId,
      'sourceId': sourceId,
      'type': type,
      'category': category,
      'title': title,
      'summary': summary,
      'importance': importance,
      'date': date,
      'relatedResidentIds': relatedResidentIds,
      'tags': tags,
    };
  }
}

class CompanyTimelineEvent {
  const CompanyTimelineEvent({
    required this.eventId,
    required this.sourceId,
    required this.type,
    required this.category,
    required this.title,
    required this.summary,
    required this.importance,
    required this.date,
    required this.weekKey,
    required this.monthKey,
    required this.relatedResidentIds,
    required this.tags,
    required this.payload,
  });

  factory CompanyTimelineEvent.fromJson(Map<String, dynamic> json) {
    return CompanyTimelineEvent(
      eventId: json['eventId']?.toString() ?? '',
      sourceId: json['sourceId']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      importance: _readInt(json['importance']).clamp(0, 100).toInt(),
      date: json['date']?.toString() ?? '',
      weekKey: json['weekKey']?.toString() ?? '',
      monthKey: json['monthKey']?.toString() ?? '',
      relatedResidentIds: _stringList(json['relatedResidentIds']),
      tags: _stringList(json['tags']),
      payload: _mapOf(json['payload']),
    );
  }

  final String eventId;
  final String sourceId;
  final String type;
  final String category;
  final String title;
  final String summary;
  final int importance;
  final String date;
  final String weekKey;
  final String monthKey;
  final List<String> relatedResidentIds;
  final List<String> tags;
  final Map<String, dynamic> payload;

  CompanyNewsItem toNewsItem() {
    return CompanyNewsItem(
      newsId: 'news:$sourceId',
      sourceId: sourceId,
      type: type,
      category: category,
      title: title,
      summary: summary,
      importance: importance,
      date: date,
      relatedResidentIds: relatedResidentIds,
      tags: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'eventId': eventId,
      'sourceId': sourceId,
      'type': type,
      'category': category,
      'title': title,
      'summary': summary,
      'importance': importance,
      'date': date,
      'weekKey': weekKey,
      'monthKey': monthKey,
      'relatedResidentIds': relatedResidentIds,
      'tags': tags,
      'payload': payload,
    };
  }
}

class CompanyTimelineSnapshot {
  const CompanyTimelineSnapshot({
    required this.news,
    required this.events,
    required this.dailySummary,
    required this.weeklySummary,
    required this.monthlySummary,
  });

  final List<CompanyNewsItem> news;
  final List<CompanyTimelineEvent> events;
  final Map<String, int> dailySummary;
  final Map<String, int> weeklySummary;
  final Map<String, int> monthlySummary;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'news': news.map((item) => item.toJson()).toList(growable: false),
      'events': events.map((item) => item.toJson()).toList(growable: false),
      'dailySummary': dailySummary,
      'weeklySummary': weeklySummary,
      'monthlySummary': monthlySummary,
    };
  }
}

class AICompanyEvent {
  const AICompanyEvent({
    required this.eventId,
    required this.sourceId,
    required this.type,
    required this.scope,
    required this.participants,
    required this.conditions,
    required this.effects,
    required this.reason,
    required this.result,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.cooldown,
    required this.createdAt,
    required this.updatedAt,
    required this.errors,
  });

  factory AICompanyEvent.fromJson(Map<String, dynamic> json) {
    return AICompanyEvent(
      eventId: json['eventId']?.toString() ?? '',
      sourceId: json['sourceId']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      scope: json['scope']?.toString() ?? 'company',
      participants: _stringList(json['participants']),
      conditions: _mapOf(json['conditions']),
      effects: _mapOf(json['effects']),
      reason: json['reason']?.toString() ?? '',
      result: _mapOf(json['result']),
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      status: _eventStatus(json['status']?.toString() ?? ''),
      cooldown: _readInt(json['cooldown']),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      errors: _stringList(json['errors']),
    );
  }

  final String eventId;
  final String sourceId;
  final String type;
  final String scope;
  final List<String> participants;
  final Map<String, dynamic> conditions;
  final Map<String, dynamic> effects;
  final String reason;
  final Map<String, dynamic> result;
  final String startTime;
  final String endTime;
  final String status;
  final int cooldown;
  final String createdAt;
  final String updatedAt;
  final List<String> errors;

  bool get isTerminal =>
      status == 'resolved' || status == 'cancelled' || status == 'expired';

  AICompanyEvent copyWith({
    String? status,
    String? updatedAt,
    Map<String, dynamic>? result,
    List<String>? errors,
  }) {
    return AICompanyEvent(
      eventId: eventId,
      sourceId: sourceId,
      type: type,
      scope: scope,
      participants: participants,
      conditions: conditions,
      effects: effects,
      reason: reason,
      result: result ?? this.result,
      startTime: startTime,
      endTime: endTime,
      status: status ?? this.status,
      cooldown: cooldown,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      errors: errors ?? this.errors,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'eventId': eventId,
      'sourceId': sourceId,
      'type': type,
      'scope': scope,
      'participants': participants,
      'conditions': conditions,
      'effects': effects,
      'reason': reason,
      'result': result,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'cooldown': cooldown,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'errors': errors,
    };
  }
}

class AICompanyEventResult {
  const AICompanyEventResult({
    required this.success,
    required this.idempotent,
    required this.event,
    required this.errors,
    required this.changedDomains,
  });

  const AICompanyEventResult.failure(this.errors)
      : success = false,
        idempotent = false,
        event = null,
        changedDomains = const <String>[];

  final bool success;
  final bool idempotent;
  final AICompanyEvent? event;
  final List<String> errors;
  final List<String> changedDomains;
}

List<CompanyNewsItem> companyNewsFromJsonList(Object? value) {
  if (value is! List) return const <CompanyNewsItem>[];
  return value
      .whereType<Map>()
      .map((item) => CompanyNewsItem.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.newsId.isNotEmpty && item.sourceId.isNotEmpty)
      .take(companyNewsHistoryLimit)
      .toList(growable: false);
}

List<CompanyTimelineEvent> companyTimelineFromJsonList(Object? value) {
  if (value is! List) return const <CompanyTimelineEvent>[];
  return value
      .whereType<Map>()
      .map((item) =>
          CompanyTimelineEvent.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.eventId.isNotEmpty && item.sourceId.isNotEmpty)
      .take(companyTimelineHistoryLimit)
      .toList(growable: false);
}

List<AICompanyEvent> aiCompanyEventsFromJsonList(Object? value) {
  if (value is! List) return const <AICompanyEvent>[];
  return value
      .whereType<Map>()
      .map((item) => AICompanyEvent.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.eventId.isNotEmpty && item.sourceId.isNotEmpty)
      .take(aiCompanyEventHistoryLimit)
      .toList(growable: false);
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

Map<String, dynamic> _mapOf(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

int _readInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

String _eventStatus(String value) {
  switch (value.toLowerCase()) {
    case 'planned':
    case 'active':
    case 'resolved':
    case 'cancelled':
    case 'expired':
      return value.toLowerCase();
  }
  return 'planned';
}
