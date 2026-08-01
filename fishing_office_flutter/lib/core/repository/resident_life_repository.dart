import 'dart:convert';

import '../../models/resident_life_config.dart';
import 'json/json_source.dart';

class ResidentLifeRepository {
  const ResidentLifeRepository({
    required this.source,
    this.schedulePath = 'assets/config/resident_schedule.json',
    this.activityPath = 'assets/config/resident_activity.json',
  });

  final JsonSource source;
  final String schedulePath;
  final String activityPath;

  Future<ResidentLifeConfig> load() async {
    final scheduleRaw = await source.loadString(schedulePath);
    final activityRaw = await source.loadString(activityPath);
    return ResidentLifeConfig.fromJson(
      scheduleJson: jsonDecode(scheduleRaw) as Map<String, dynamic>,
      activityJson: jsonDecode(activityRaw) as Map<String, dynamic>,
    );
  }
}
