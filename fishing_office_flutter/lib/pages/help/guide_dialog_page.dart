import 'package:flutter/material.dart';

import '../../core/bootstrap/fishing_office_scope.dart';
import '../../core/dialog/dialog_manager.dart';
import '../../models/guide_config.dart';
import '../../models/layout_config.dart';

class GuideDialogPage extends StatefulWidget {
  const GuideDialogPage({
    super.key,
    required this.guide,
    required this.layout,
    required this.dialogManager,
  });

  final GuideConfig guide;
  final LayoutConfig layout;
  final DialogManager dialogManager;

  @override
  State<GuideDialogPage> createState() => _GuideDialogPageState();
}

class _GuideDialogPageState extends State<GuideDialogPage> {
  late String _chapterId;

  @override
  void initState() {
    super.initState();
    _chapterId =
        widget.guide.chapters.isNotEmpty ? widget.guide.chapters.first.id : '';
  }

  GuideChapter? get _currentChapter => widget.guide.chapterById(_chapterId);

  @override
  Widget build(BuildContext context) {
    final scope = FishingOfficeScope.of(context);
    final scale = scope.responsive.scale;
    final dialog = widget.layout.byId('guide_dialog');
    final header = widget.layout.byId('guide_header');
    final title = widget.layout.byId('guide_title');
    final close = widget.layout.byId('guide_close');
    final sidebar = widget.layout.byId('guide_sidebar');
    final content = widget.layout.byId('guide_content');
    final footer = widget.layout.byId('guide_footer');
    final prevButton = widget.layout.byId('guide_prev');
    final nextButton = widget.layout.byId('guide_next');
    final doneButton = widget.layout.byId('guide_done');

    return SizedBox.expand(
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xE61B2F4A),
                    Color(0xCC17314A),
                    Color(0xD90D1E2E),
                  ],
                ),
              ),
            ),
          ),
          if (dialog != null)
            Positioned(
              left: dialog.rect.left * scale,
              top: dialog.rect.top * scale,
              width: dialog.rect.width * scale,
              height: dialog.rect.height * scale,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32 * scale),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF3E1B8),
                      Color(0xFFE2C07C),
                      Color(0xFFC49247)
                    ],
                  ),
                  border:
                      Border.all(color: const Color(0xFFF7DC8B), width: 2.4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 38,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
              ),
            ),
          if (header != null)
            Positioned(
              left: header.rect.left * scale,
              top: header.rect.top * scale,
              width: header.rect.width * scale,
              height: header.rect.height * scale,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF16417E),
                      Color(0xFF2E69A7),
                      Color(0xFF112F5A)
                    ],
                  ),
                  border: Border(
                      bottom: BorderSide(color: Color(0xFFF1D57E), width: 2)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26 * scale),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _guideTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34 * scale,
                            fontWeight: FontWeight.w900,
                            shadows: const [
                              Shadow(
                                  color: Color(0xAA000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2)),
                            ],
                          ),
                        ),
                      ),
                      _GuideButton(
                        rect: close?.rect,
                        scale: scale,
                        label: widget.guide.footer['closeLabel']?.toString() ??
                            '关闭',
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (title != null)
            Positioned(
              left: title.rect.left * scale,
              top: title.rect.top * scale,
              width: title.rect.width * scale,
              height: title.rect.height * scale,
              child: _GuideSectionTitle(
                  text: _currentChapter?.title ?? _guideTitle, scale: scale),
            ),
          if (sidebar != null)
            Positioned(
              left: sidebar.rect.left * scale,
              top: sidebar.rect.top * scale,
              width: sidebar.rect.width * scale,
              height: sidebar.rect.height * scale,
              child: _GuideSidebar(
                guide: widget.guide,
                selectedChapterId: _chapterId,
                onSelected: (id) => setState(() => _chapterId = id),
                scale: scale,
              ),
            ),
          if (content != null)
            Positioned(
              left: content.rect.left * scale,
              top: content.rect.top * scale,
              width: content.rect.width * scale,
              height: content.rect.height * scale,
              child: _GuideContentCard(
                chapter: _currentChapter,
                scale: scale,
              ),
            ),
          if (footer != null)
            Positioned(
              left: footer.rect.left * scale,
              top: footer.rect.top * scale,
              width: footer.rect.width * scale,
              height: footer.rect.height * scale,
              child: Row(
                children: [
                  if (prevButton != null)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 12 * scale),
                        child: _GuideFooterButton(
                          rect: prevButton.rect,
                          scale: scale,
                          label: widget.guide.footer['prevLabel']?.toString() ??
                              '上一页',
                          icon: Icons.chevron_left_rounded,
                          onTap: _prevChapter,
                        ),
                      ),
                    ),
                  if (nextButton != null)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                        child: _GuideFooterButton(
                          rect: nextButton.rect,
                          scale: scale,
                          label: widget.guide.footer['nextLabel']?.toString() ??
                              '下一页',
                          icon: Icons.chevron_right_rounded,
                          onTap: _nextChapter,
                        ),
                      ),
                    ),
                  if (doneButton != null)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 12 * scale),
                        child: _GuideFooterButton(
                          rect: doneButton.rect,
                          scale: scale,
                          label: widget.guide.footer['doneLabel']?.toString() ??
                              '我知道了',
                          icon: Icons.check_rounded,
                          onTap: () => Navigator.of(context).pop(),
                          primary: true,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String get _guideTitle => widget.guide.meta['title']?.toString() ?? '游戏说明';

  void _prevChapter() {
    final chapters = widget.guide.chapters;
    if (chapters.isEmpty) return;
    final currentIndex =
        chapters.indexWhere((chapter) => chapter.id == _chapterId);
    final nextIndex =
        currentIndex <= 0 ? chapters.length - 1 : currentIndex - 1;
    setState(() => _chapterId = chapters[nextIndex].id);
  }

  void _nextChapter() {
    final chapters = widget.guide.chapters;
    if (chapters.isEmpty) return;
    final currentIndex =
        chapters.indexWhere((chapter) => chapter.id == _chapterId);
    final nextIndex = currentIndex < 0 || currentIndex >= chapters.length - 1
        ? 0
        : currentIndex + 1;
    setState(() => _chapterId = chapters[nextIndex].id);
  }
}

class _GuideSidebar extends StatelessWidget {
  const _GuideSidebar({
    required this.guide,
    required this.selectedChapterId,
    required this.onSelected,
    required this.scale,
  });

  final GuideConfig guide;
  final String selectedChapterId;
  final ValueChanged<String> onSelected;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final chapter in guide.chapters)
          Padding(
            padding: EdgeInsets.only(bottom: 12 * scale),
            child: _GuideNavButton(
              label: chapter.navLabel,
              selected: chapter.id == selectedChapterId,
              onTap: () => onSelected(chapter.id),
              scale: scale,
            ),
          ),
      ],
    );
  }
}

class _GuideNavButton extends StatelessWidget {
  const _GuideNavButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.scale,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        height: 112 * scale,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: selected
                ? [
                    const Color(0xFF4A8EEA),
                    const Color(0xFF19447C),
                    const Color(0xFF12305B)
                  ]
                : [const Color(0xFF203A63), const Color(0xFF122744)],
          ),
          borderRadius: BorderRadius.circular(22 * scale),
          border: Border.all(
            color: selected ? const Color(0xFFFFE38A) : const Color(0xFF6EA9FF),
            width: selected ? 2.4 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0xAAFFE38A)
                  : Colors.black.withValues(alpha: 0.18),
              blurRadius: selected ? 18 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22 * scale,
              fontWeight: FontWeight.w900,
              shadows: const [
                Shadow(
                    color: Color(0xAA000000),
                    blurRadius: 6,
                    offset: Offset(0, 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideSectionTitle extends StatelessWidget {
  const _GuideSectionTitle({
    required this.text,
    required this.scale,
  });

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 10 * scale),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFF2D37C), Color(0xFFDBA243)]),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: const Color(0xFFFDF0B8), width: 1.6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF4C3212),
          fontSize: 26 * scale,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _GuideContentCard extends StatelessWidget {
  const _GuideContentCard({
    required this.chapter,
    required this.scale,
  });

  final GuideChapter? chapter;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final current = chapter;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26 * scale),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF9E7BD), Color(0xFFEFD79A), Color(0xFFD4AE64)],
        ),
        border: Border.all(color: const Color(0xFFF6DD8B), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(20 * scale),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: current == null
            ? const SizedBox.shrink()
            : Column(
                key: ValueKey(current.id),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    current.title,
                    style: TextStyle(
                      color: const Color(0xFF4A2F11),
                      fontSize: 30 * scale,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 18 * scale),
                  for (final paragraph in current.paragraphs) ...[
                    Text(
                      paragraph,
                      style: TextStyle(
                        color: const Color(0xFF5A3A15),
                        fontSize: 20 * scale,
                        height: 1.45,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                  ],
                  if (current.bullets.isNotEmpty) ...[
                    SizedBox(height: 6 * scale),
                    for (final bullet in current.bullets)
                      Padding(
                        padding: EdgeInsets.only(bottom: 10 * scale),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 10 * scale),
                              width: 10 * scale,
                              height: 10 * scale,
                              decoration: const BoxDecoration(
                                color: Color(0xFFB97A0A),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 12 * scale),
                            Expanded(
                              child: Text(
                                bullet,
                                style: TextStyle(
                                  color: const Color(0xFF5A3A15),
                                  fontSize: 19 * scale,
                                  height: 1.4,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _GuideButton extends StatelessWidget {
  const _GuideButton({
    required this.rect,
    required this.scale,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final Rect? rect;
  final double scale;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = rect?.width ?? 120;
    final height = rect?.height ?? 54;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF3B86DB), Color(0xFF18426F)]),
          borderRadius: BorderRadius.circular(18 * scale),
          border: Border.all(color: const Color(0xFFF7D77B), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFFFE08C), size: 18 * scale),
            SizedBox(width: 6 * scale),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16 * scale,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideFooterButton extends StatelessWidget {
  const _GuideFooterButton({
    required this.rect,
    required this.scale,
    required this.label,
    required this.icon,
    required this.onTap,
    this.primary = false,
  });

  final Rect? rect;
  final double scale;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final width = rect?.width ?? 200;
    final height = rect?.height ?? 68;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: primary
              ? const LinearGradient(colors: [
                  Color(0xFFFFD86B),
                  Color(0xFFE08D19),
                  Color(0xFFB8670B)
                ])
              : const LinearGradient(
                  colors: [Color(0xFF3B86DB), Color(0xFF18426F)]),
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(
              color:
                  primary ? const Color(0xFFFFF2B2) : const Color(0xFFF7D77B),
              width: 1.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18 * scale),
            SizedBox(width: 8 * scale),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18 * scale,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
