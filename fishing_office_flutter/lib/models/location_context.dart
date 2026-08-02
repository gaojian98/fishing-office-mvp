class LocationContext {
  const LocationContext({
    required this.locationId,
    required this.locationType,
    required this.displayName,
    required this.isOfficeLocation,
    required this.isIndoor,
    required this.isOutdoor,
    required this.isPublic,
    required this.isPrivate,
    required this.availableActivities,
    required this.residentIds,
    required this.currentCapacity,
    required this.maxCapacity,
    required this.weatherAffected,
    required this.festivalAffected,
    required this.timeRestrictions,
    required this.tags,
  });

  final String locationId;
  final String locationType;
  final String displayName;
  final bool isOfficeLocation;
  final bool isIndoor;
  final bool isOutdoor;
  final bool isPublic;
  final bool isPrivate;
  final List<String> availableActivities;
  final List<String> residentIds;
  final int currentCapacity;
  final int maxCapacity;
  final bool weatherAffected;
  final bool festivalAffected;
  final List<String> timeRestrictions;
  final List<String> tags;

  bool get overCapacity => maxCapacity > 0 && currentCapacity > maxCapacity;

  LocationContext copyWith({
    List<String>? residentIds,
    int? currentCapacity,
  }) {
    return LocationContext(
      locationId: locationId,
      locationType: locationType,
      displayName: displayName,
      isOfficeLocation: isOfficeLocation,
      isIndoor: isIndoor,
      isOutdoor: isOutdoor,
      isPublic: isPublic,
      isPrivate: isPrivate,
      availableActivities: availableActivities,
      residentIds: residentIds ?? this.residentIds,
      currentCapacity: currentCapacity ?? this.currentCapacity,
      maxCapacity: maxCapacity,
      weatherAffected: weatherAffected,
      festivalAffected: festivalAffected,
      timeRestrictions: timeRestrictions,
      tags: tags,
    );
  }

  static const officeLocationIds = <String>{
    'office',
    'workstation',
    'meeting_room',
    'pantry',
    'printing_area',
    'manager_room',
    'balcony',
    'elevator',
    'restroom',
    'reception',
  };

  static const externalLocationIds = <String>{
    'home',
    'park',
    'coffee_shop',
    'shop',
    'seaside',
    'dock',
    'residential_area',
  };

  static const supportedLocationIds = <String>{
    ...officeLocationIds,
    ...externalLocationIds,
  };

  static String normalizeId(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) return 'office';
    final compact = value.replaceAll('-', '_').replaceAll(' ', '_');
    if (supportedLocationIds.contains(compact)) return compact;
    if (compact == 'meetingroom' || compact == 'meeting_room_area') {
      return 'meeting_room';
    }
    if (compact == 'meeting-room') return 'meeting_room';
    if (compact == 'managerroom' ||
        compact == 'boss_room' ||
        compact == 'director_room') {
      return 'manager_room';
    }
    if (compact == 'printingarea' || compact == 'printer') {
      return 'printing_area';
    }
    if (compact == 'front_desk' ||
        compact == 'office_front' ||
        compact == 'office_gate' ||
        compact == 'office_lounge') {
      return 'reception';
    }
    if (compact.startsWith('workplace') ||
        compact.startsWith('workspace') ||
        compact.startsWith('desk') ||
        compact.startsWith('station')) {
      return 'workstation';
    }
    if (compact.startsWith('home') ||
        compact == 'house' ||
        compact == 'guard_room' ||
        compact == 'old_fisher_home') {
      return 'home';
    }
    if (compact.contains('coffee') || compact.contains('cafe')) {
      return 'coffee_shop';
    }
    if (compact.contains('park')) return 'park';
    if (compact.contains('seaside') || compact.contains('beach')) {
      return 'seaside';
    }
    if (compact.contains('dock') ||
        compact.contains('harbor') ||
        compact.contains('pier')) {
      return 'dock';
    }
    if (compact.contains('shop') || compact.contains('store')) return 'shop';
    if (compact.contains('street') ||
        compact.contains('resident') ||
        compact.contains('area')) {
      return 'residential_area';
    }
    if (compact.contains('elevator')) return 'elevator';
    if (compact.contains('balcony')) return 'balcony';
    if (compact.contains('pantry')) return 'pantry';
    if (compact.contains('restroom')) return 'restroom';
    return compact;
  }

  static LocationContext fromId(
    String raw, {
    List<String> residentIds = const <String>[],
  }) {
    final id = normalizeId(raw);
    final spec = _specs[id] ?? _unknownSpec(id);
    return LocationContext(
      locationId: id,
      locationType: spec.type,
      displayName: spec.name,
      isOfficeLocation: officeLocationIds.contains(id),
      isIndoor: spec.indoor,
      isOutdoor: !spec.indoor,
      isPublic: spec.public,
      isPrivate: spec.private,
      availableActivities: spec.activities,
      residentIds: residentIds,
      currentCapacity: residentIds.length,
      maxCapacity: spec.capacity,
      weatherAffected: spec.weatherAffected,
      festivalAffected: spec.festivalAffected,
      timeRestrictions: spec.timeRestrictions,
      tags: spec.tags,
    );
  }

  static bool isReasonableForPhase(String locationId, String phase) {
    final id = normalizeId(locationId);
    final normalizedPhase = phase.trim().toLowerCase();
    if (normalizedPhase == 'sleep') return id == 'home';
    if (normalizedPhase == 'working' ||
        normalizedPhase == 'work_start' ||
        normalizedPhase == 'afternoon_work') {
      return const {
        'office',
        'workstation',
        'meeting_room',
        'printing_area',
        'manager_room',
      }.contains(id);
    }
    if (normalizedPhase == 'coffee_break') {
      return const {'pantry', 'balcony', 'coffee_shop'}.contains(id);
    }
    if (normalizedPhase == 'lunch') {
      return const {'pantry', 'coffee_shop', 'shop', 'balcony'}.contains(id);
    }
    if (normalizedPhase == 'overtime') {
      return const {'workstation', 'manager_room', 'office'}.contains(id);
    }
    if (normalizedPhase == 'off_work' || normalizedPhase == 'commute') {
      return const {'elevator', 'reception', 'home', 'residential_area'}
          .contains(id);
    }
    return true;
  }

  static String fallbackForPhase(String phase, {String seed = ''}) {
    final normalized = phase.trim().toLowerCase();
    return switch (normalized) {
      'morning' => 'home',
      'commute' => seed.hashCode.isEven ? 'elevator' : 'reception',
      'work_start' => 'workstation',
      'working' => seed.hashCode % 3 == 0 ? 'meeting_room' : 'workstation',
      'coffee_break' => seed.hashCode.isEven ? 'pantry' : 'balcony',
      'lunch' => seed.hashCode.isEven ? 'pantry' : 'coffee_shop',
      'afternoon_work' =>
        seed.hashCode % 3 == 0 ? 'meeting_room' : 'workstation',
      'overtime' => seed.hashCode.isEven ? 'workstation' : 'manager_room',
      'off_work' => seed.hashCode.isEven ? 'elevator' : 'reception',
      'evening' => 'residential_area',
      'home' => 'home',
      'sleep' => 'home',
      'weekend' => _weekendFallback(seed),
      'holiday' => 'reception',
      _ => 'office',
    };
  }

  static String _weekendFallback(String seed) {
    const options = <String>[
      'home',
      'park',
      'coffee_shop',
      'seaside',
      'dock',
      'shop',
    ];
    return options[seed.hashCode.abs() % options.length];
  }

  static _LocationSpec _unknownSpec(String id) {
    return _LocationSpec(
      name: id.isEmpty ? '办公室' : id,
      type: 'custom',
      capacity: 20,
      indoor: true,
      public: true,
      private: false,
      weatherAffected: false,
      festivalAffected: false,
      activities: const <String>['observe', 'talk'],
      tags: <String>[id, 'custom_location'],
      timeRestrictions: const <String>[],
    );
  }
}

class _LocationSpec {
  const _LocationSpec({
    required this.name,
    required this.type,
    required this.capacity,
    required this.indoor,
    required this.public,
    required this.private,
    required this.weatherAffected,
    required this.festivalAffected,
    required this.activities,
    required this.tags,
    required this.timeRestrictions,
  });

  final String name;
  final String type;
  final int capacity;
  final bool indoor;
  final bool public;
  final bool private;
  final bool weatherAffected;
  final bool festivalAffected;
  final List<String> activities;
  final List<String> tags;
  final List<String> timeRestrictions;
}

const _specs = <String, _LocationSpec>{
  'office': _LocationSpec(
    name: '办公室',
    type: 'office',
    capacity: 100,
    indoor: true,
    public: true,
    private: false,
    weatherAffected: false,
    festivalAffected: true,
    activities: ['talk', 'help_work', 'observe'],
    tags: ['office', 'indoor', 'work'],
    timeRestrictions: [],
  ),
  'workstation': _LocationSpec(
    name: '工位',
    type: 'office',
    capacity: 120,
    indoor: true,
    public: false,
    private: true,
    weatherAffected: false,
    festivalAffected: false,
    activities: ['talk', 'help_work', 'observe'],
    tags: ['office', 'indoor', 'work', 'desk'],
    timeRestrictions: [],
  ),
  'meeting_room': _LocationSpec(
    name: '会议室',
    type: 'office',
    capacity: 8,
    indoor: true,
    public: false,
    private: true,
    weatherAffected: false,
    festivalAffected: true,
    activities: ['talk', 'help_work', 'start_story'],
    tags: ['office', 'indoor', 'meeting', 'work', 'tense'],
    timeRestrictions: [],
  ),
  'pantry': _LocationSpec(
    name: '茶水间',
    type: 'office',
    capacity: 12,
    indoor: true,
    public: true,
    private: false,
    weatherAffected: false,
    festivalAffected: true,
    activities: ['talk', 'ask_about_rumor', 'invite_coffee', 'join_break'],
    tags: ['office', 'indoor', 'break', 'coffee', 'rumor'],
    timeRestrictions: [],
  ),
  'printing_area': _LocationSpec(
    name: '打印区',
    type: 'office',
    capacity: 4,
    indoor: true,
    public: true,
    private: false,
    weatherAffected: false,
    festivalAffected: false,
    activities: ['talk', 'help_work', 'observe'],
    tags: ['office', 'indoor', 'printer', 'humor', 'encounter'],
    timeRestrictions: [],
  ),
  'manager_room': _LocationSpec(
    name: '主管办公室',
    type: 'office',
    capacity: 3,
    indoor: true,
    public: false,
    private: true,
    weatherAffected: false,
    festivalAffected: false,
    activities: ['talk', 'help_work', 'start_story'],
    tags: ['office', 'indoor', 'manager', 'pressure', 'work'],
    timeRestrictions: [],
  ),
  'balcony': _LocationSpec(
    name: '阳台',
    type: 'office',
    capacity: 6,
    indoor: false,
    public: true,
    private: false,
    weatherAffected: true,
    festivalAffected: true,
    activities: ['talk', 'observe', 'join_break'],
    tags: ['office', 'outdoor', 'weather', 'relax', 'warm'],
    timeRestrictions: [],
  ),
  'elevator': _LocationSpec(
    name: '电梯',
    type: 'office',
    capacity: 8,
    indoor: true,
    public: true,
    private: false,
    weatherAffected: false,
    festivalAffected: false,
    activities: ['talk', 'observe'],
    tags: ['office', 'indoor', 'commute', 'encounter'],
    timeRestrictions: [],
  ),
  'restroom': _LocationSpec(
    name: '洗手间',
    type: 'office',
    capacity: 6,
    indoor: true,
    public: false,
    private: true,
    weatherAffected: false,
    festivalAffected: false,
    activities: ['observe'],
    tags: ['office', 'indoor', 'private'],
    timeRestrictions: [],
  ),
  'reception': _LocationSpec(
    name: '前台',
    type: 'office',
    capacity: 10,
    indoor: true,
    public: true,
    private: false,
    weatherAffected: false,
    festivalAffected: true,
    activities: ['talk', 'ask_about_rumor', 'observe'],
    tags: ['office', 'indoor', 'front', 'welcome'],
    timeRestrictions: [],
  ),
  'home': _LocationSpec(
    name: '家',
    type: 'home',
    capacity: 200,
    indoor: true,
    public: false,
    private: true,
    weatherAffected: false,
    festivalAffected: true,
    activities: ['observe'],
    tags: ['home', 'indoor', 'rest'],
    timeRestrictions: [],
  ),
  'park': _LocationSpec(
    name: '公园',
    type: 'world',
    capacity: 80,
    indoor: false,
    public: true,
    private: false,
    weatherAffected: true,
    festivalAffected: true,
    activities: ['talk', 'observe', 'start_story'],
    tags: ['outdoor', 'park', 'community', 'relax'],
    timeRestrictions: [],
  ),
  'coffee_shop': _LocationSpec(
    name: '咖啡店',
    type: 'world',
    capacity: 30,
    indoor: true,
    public: true,
    private: false,
    weatherAffected: false,
    festivalAffected: true,
    activities: ['talk', 'ask_about_rumor', 'invite_coffee', 'join_break'],
    tags: ['indoor', 'coffee', 'break', 'rumor', 'warm'],
    timeRestrictions: [],
  ),
  'shop': _LocationSpec(
    name: '商店',
    type: 'world',
    capacity: 40,
    indoor: true,
    public: true,
    private: false,
    weatherAffected: false,
    festivalAffected: true,
    activities: ['talk', 'observe'],
    tags: ['indoor', 'shop', 'public'],
    timeRestrictions: [],
  ),
  'seaside': _LocationSpec(
    name: '海边',
    type: 'world',
    capacity: 90,
    indoor: false,
    public: true,
    private: false,
    weatherAffected: true,
    festivalAffected: true,
    activities: ['talk', 'observe', 'start_story'],
    tags: ['outdoor', 'sea', 'weather', 'fishing'],
    timeRestrictions: [],
  ),
  'dock': _LocationSpec(
    name: '码头',
    type: 'world',
    capacity: 50,
    indoor: false,
    public: true,
    private: false,
    weatherAffected: true,
    festivalAffected: true,
    activities: ['talk', 'observe', 'start_story'],
    tags: ['outdoor', 'dock', 'fishing', 'sea'],
    timeRestrictions: [],
  ),
  'residential_area': _LocationSpec(
    name: '居民区',
    type: 'world',
    capacity: 100,
    indoor: false,
    public: true,
    private: false,
    weatherAffected: true,
    festivalAffected: true,
    activities: ['talk', 'observe'],
    tags: ['outdoor', 'community', 'home'],
    timeRestrictions: [],
  ),
};
