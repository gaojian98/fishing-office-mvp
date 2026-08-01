class ResidentSchedule {
  const ResidentSchedule({
    required this.id,
    required this.residentId,
    required this.schedule,
    required this.location,
    required this.activity,
    required this.activityId,
    required this.startTime,
    required this.endTime,
    required this.mood,
    required this.weekdays,
    required this.raw,
  });

  final String id;
  final String residentId;
  final String schedule;
  final String location;
  final String activity;
  final String activityId;
  final String startTime;
  final String endTime;
  final String mood;
  final List<int> weekdays;
  final Map<String, dynamic> raw;

  factory ResidentSchedule.fromJson(Map<String, dynamic> json) {
    return ResidentSchedule(
      id: json['id']?.toString() ?? '',
      residentId: json['residentId']?.toString() ?? '',
      schedule: json['schedule']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      activity: json['activity']?.toString() ?? '',
      activityId: json['activityId']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '00:00',
      endTime: json['endTime']?.toString() ?? '23:59',
      mood: json['mood']?.toString() ?? 'calm',
      weekdays: _intList(json['weekday']),
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class ResidentActivity {
  const ResidentActivity({
    required this.id,
    required this.name,
    required this.raw,
  });

  final String id;
  final String name;
  final Map<String, dynamic> raw;

  factory ResidentActivity.fromJson(Map<String, dynamic> json) {
    return ResidentActivity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class ResidentLifeConfig {
  const ResidentLifeConfig({
    required this.scheduleVersion,
    required this.activityVersion,
    required this.schedules,
    required this.activities,
  });

  final String scheduleVersion;
  final String activityVersion;
  final List<ResidentSchedule> schedules;
  final List<ResidentActivity> activities;

  factory ResidentLifeConfig.fromJson({
    required Map<String, dynamic> scheduleJson,
    required Map<String, dynamic> activityJson,
  }) {
    return ResidentLifeConfig(
      scheduleVersion: scheduleJson['version']?.toString() ?? '1.0',
      activityVersion: activityJson['version']?.toString() ?? '1.0',
      schedules: _listOfMaps(scheduleJson['schedules'])
          .map(ResidentSchedule.fromJson)
          .toList(growable: false),
      activities: _listOfMaps(activityJson['activities'])
          .map(ResidentActivity.fromJson)
          .toList(growable: false),
    );
  }

  static List<Map<String, dynamic>> _listOfMaps(Object? value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
}

List<int> _intList(Object? value) {
  if (value is! List) return const <int>[];
  return value
      .map((item) => int.tryParse(item.toString()))
      .whereType<int>()
      .toList(growable: false);
}
