class GuideConfig {
  const GuideConfig({
    required this.meta,
    required this.dialog,
    required this.footer,
    required this.chapters,
  });

  factory GuideConfig.fromJson(Map<String, dynamic> json) {
    return GuideConfig(
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : const {},
      dialog: json['dialog'] is Map<String, dynamic>
          ? json['dialog'] as Map<String, dynamic>
          : const {},
      footer: json['footer'] is Map<String, dynamic>
          ? json['footer'] as Map<String, dynamic>
          : const {},
      chapters: json['chapters'] is List
          ? (json['chapters'] as List)
              .whereType<Map<String, dynamic>>()
              .map(GuideChapter.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  final Map<String, dynamic> meta;
  final Map<String, dynamic> dialog;
  final Map<String, dynamic> footer;
  final List<GuideChapter> chapters;

  GuideChapter? chapterById(String id) {
    for (final chapter in chapters) {
      if (chapter.id == id) return chapter;
    }
    return null;
  }
}

class GuideChapter {
  const GuideChapter({
    required this.id,
    required this.navLabel,
    required this.title,
    required this.paragraphs,
    required this.bullets,
  });

  factory GuideChapter.fromJson(Map<String, dynamic> json) {
    return GuideChapter(
      id: '${json['id'] ?? ''}',
      navLabel: '${json['navLabel'] ?? ''}',
      title: '${json['title'] ?? ''}',
      paragraphs: json['paragraphs'] is List
          ? (json['paragraphs'] as List)
              .map((item) => '$item')
              .toList(growable: false)
          : const [],
      bullets: json['bullets'] is List
          ? (json['bullets'] as List)
              .map((item) => '$item')
              .toList(growable: false)
          : const [],
    );
  }

  final String id;
  final String navLabel;
  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
}
