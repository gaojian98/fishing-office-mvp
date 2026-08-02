class OfficeGroup {
  const OfficeGroup({
    required this.groupId,
    required this.locationId,
    required this.members,
    required this.leaderId,
    required this.topic,
    required this.mood,
    required this.activity,
    required this.startTime,
    required this.expectedEndTime,
    required this.createdReason,
    required this.importance,
    required this.tags,
  });

  factory OfficeGroup.fromJson(Map<String, dynamic> json) {
    return OfficeGroup(
      groupId: json['groupId']?.toString() ?? '',
      locationId: json['locationId']?.toString() ?? '',
      members: _stringList(json['members']),
      leaderId: json['leaderId']?.toString() ?? '',
      topic: json['topic']?.toString() ?? '',
      mood: json['mood']?.toString() ?? 'calm',
      activity: json['activity']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      expectedEndTime: json['expectedEndTime']?.toString() ?? '',
      createdReason: json['createdReason']?.toString() ?? '',
      importance: _readInt(json['importance']),
      tags: _stringList(json['tags']),
    );
  }

  final String groupId;
  final String locationId;
  final List<String> members;
  final String leaderId;
  final String topic;
  final String mood;
  final String activity;
  final String startTime;
  final String expectedEndTime;
  final String createdReason;
  final int importance;
  final List<String> tags;

  int get size => members.length;

  bool containsResident(String residentId) => members.contains(residentId);

  bool get isValid =>
      groupId.isNotEmpty &&
      locationId.isNotEmpty &&
      members.length >= 2 &&
      members.length <= 6;

  OfficeGroup copyWith({
    String? groupId,
    String? locationId,
    List<String>? members,
    String? leaderId,
    String? topic,
    String? mood,
    String? activity,
    String? startTime,
    String? expectedEndTime,
    String? createdReason,
    int? importance,
    List<String>? tags,
  }) {
    return OfficeGroup(
      groupId: groupId ?? this.groupId,
      locationId: locationId ?? this.locationId,
      members: members ?? this.members,
      leaderId: leaderId ?? this.leaderId,
      topic: topic ?? this.topic,
      mood: mood ?? this.mood,
      activity: activity ?? this.activity,
      startTime: startTime ?? this.startTime,
      expectedEndTime: expectedEndTime ?? this.expectedEndTime,
      createdReason: createdReason ?? this.createdReason,
      importance: importance ?? this.importance,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'locationId': locationId,
      'members': members,
      'leaderId': leaderId,
      'topic': topic,
      'mood': mood,
      'activity': activity,
      'startTime': startTime,
      'expectedEndTime': expectedEndTime,
      'createdReason': createdReason,
      'importance': importance,
      'tags': tags,
    };
  }
}

List<OfficeGroup> officeGroupsFromJsonList(Object? value) {
  if (value is! List) return const <OfficeGroup>[];
  return value
      .whereType<Map>()
      .map((item) => OfficeGroup.fromJson(Map<String, dynamic>.from(item)))
      .where((group) => group.isValid)
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
