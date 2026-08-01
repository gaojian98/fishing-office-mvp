class ProfileConfig {
  const ProfileConfig({
    required this.title,
    required this.closeLabel,
    required this.player,
    required this.menus,
    required this.sections,
    required this.footer,
  });

  factory ProfileConfig.fromJson(Map<String, dynamic> json) {
    final playerJson = json['player'] as Map<String, dynamic>? ?? const {};
    final menuJson = json['menu'];
    final sectionJson = json['sections'] as Map<String, dynamic>? ?? const {};
    final footerJson = json['footer'] as Map<String, dynamic>? ?? const {};
    return ProfileConfig(
      title: '${json['title'] ?? '个人中心'}',
      closeLabel: '${json['closeLabel'] ?? '关闭'}',
      player: ProfilePlayerInfo.fromJson(playerJson),
      menus: menuJson is List
          ? menuJson
              .whereType<Map<String, dynamic>>()
              .map(ProfileMenuItem.fromJson)
              .toList(growable: false)
          : const [],
      sections: sectionJson.map(
        (key, value) => MapEntry(
          key,
          value is Map<String, dynamic>
              ? ProfileSection.fromJson(value)
              : const ProfileSection.empty(),
        ),
      ),
      footer: ProfileFooter.fromJson(footerJson),
    );
  }

  final String title;
  final String closeLabel;
  final ProfilePlayerInfo player;
  final List<ProfileMenuItem> menus;
  final Map<String, ProfileSection> sections;
  final ProfileFooter footer;

  ProfileSection sectionById(String id) =>
      sections[id] ?? const ProfileSection.empty();
}

class ProfilePlayerInfo {
  const ProfilePlayerInfo({
    required this.nickname,
    required this.level,
    required this.titleLabel,
    required this.title,
    required this.joinDaysLabel,
    required this.joinDays,
    required this.streakLabel,
    required this.streak,
    required this.experienceLabel,
  });

  factory ProfilePlayerInfo.fromJson(Map<String, dynamic> json) {
    return ProfilePlayerInfo(
      nickname: '${json['nickname'] ?? 'FishingPro'}',
      level: '${json['level'] ?? 'Lv.1'}',
      titleLabel: '${json['titleLabel'] ?? '称号：'}',
      title: '${json['title'] ?? '优秀摸鱼员'}',
      joinDaysLabel: '${json['joinDaysLabel'] ?? '加入天数：'}',
      joinDays: '${json['joinDays'] ?? '0 天'}',
      streakLabel: '${json['streakLabel'] ?? '连续登录：'}',
      streak: '${json['streak'] ?? '0 天'}',
      experienceLabel: '${json['experienceLabel'] ?? '经验：'}',
    );
  }

  final String nickname;
  final String level;
  final String titleLabel;
  final String title;
  final String joinDaysLabel;
  final String joinDays;
  final String streakLabel;
  final String streak;
  final String experienceLabel;
}

class ProfileMenuItem {
  const ProfileMenuItem({
    required this.id,
    required this.label,
    required this.hint,
  });

  factory ProfileMenuItem.fromJson(Map<String, dynamic> json) {
    return ProfileMenuItem(
      id: '${json['id'] ?? ''}',
      label: '${json['label'] ?? ''}',
      hint: '${json['hint'] ?? ''}',
    );
  }

  final String id;
  final String label;
  final String hint;
}

class ProfileSection {
  const ProfileSection({
    required this.title,
    required this.lines,
  });

  const ProfileSection.empty()
      : title = '',
        lines = const [];

  factory ProfileSection.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'];
    return ProfileSection(
      title: '${json['title'] ?? ''}',
      lines: rawLines is List
          ? rawLines.map((line) => '$line').toList(growable: false)
          : const [],
    );
  }

  final String title;
  final List<String> lines;
}

class ProfileFooter {
  const ProfileFooter({
    required this.transactionLabel,
    required this.closeLabel,
  });

  factory ProfileFooter.fromJson(Map<String, dynamic> json) {
    return ProfileFooter(
      transactionLabel: '${json['transactionLabel'] ?? '查看交易记录'}',
      closeLabel: '${json['closeLabel'] ?? '关闭'}',
    );
  }

  final String transactionLabel;
  final String closeLabel;
}
