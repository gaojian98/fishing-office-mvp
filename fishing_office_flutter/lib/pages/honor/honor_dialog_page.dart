import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/bootstrap/fishing_office_scope.dart';
import '../../core/dialog/dialog_manager.dart';
import '../../core/managers/achievement_runtime_manager.dart';
import '../../core/managers/app_managers.dart';
import '../../core/providers/app_providers.dart';
import '../../models/honor_config.dart';
import '../../models/layout_config.dart';
import '../../models/task_config.dart';

class HonorDialogPage extends ConsumerStatefulWidget {
  const HonorDialogPage({
    super.key,
    required this.honor,
    required this.layout,
    required this.dialogManager,
  });

  final HonorConfig honor;
  final LayoutConfig layout;
  final DialogManager dialogManager;

  @override
  ConsumerState<HonorDialogPage> createState() => _HonorDialogPageState();
}

class _HonorDialogPageState extends ConsumerState<HonorDialogPage> {
  String? _selectedBadgeId;

  @override
  Widget build(BuildContext context) {
    final scope = FishingOfficeScope.of(context);
    final screen = MediaQuery.sizeOf(context);
    final scale = scope.responsive.scale;
    final dialog = widget.layout.byId('honor_dialog');
    final header = widget.layout.byId('honor_header');
    final title = widget.layout.byId('honor_title');
    final close = widget.layout.byId('honor_close');
    final player = widget.layout.byId('honor_player');
    final statistics = widget.layout.byId('honor_statistics');
    final badgeGrid = widget.layout.byId('honor_badge_grid');
    final footer = widget.layout.byId('honor_footer');
    final titleTab = widget.layout.byId('honor_tab_title');
    final achievementTab = widget.layout.byId('honor_tab_achievement');
    final bottomClose = widget.layout.byId('honor_close_button');

    final wallet = ref.watch(walletManagerProvider);
    final fishing = ref.watch(fishingProvider);
    final inventory = ref.watch(inventoryManagerProvider);
    final collection = ref.watch(collectionManagerProvider);
    final transactions = ref.watch(transactionManagerProvider);
    final tasks = ref.watch(taskManagerProvider);
    final honorManager = ref.watch(honorManagerProvider);
    final achievementRuntime = ref.watch(achievementRuntimeManagerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final quest = ref.read(questRuntimeManagerProvider).valueOrNull;
      if (quest != null) {
        quest.syncFromState(
          fishing: ref.read(fishingProvider),
          inventory: ref.read(inventoryManagerProvider),
          collection: ref.read(collectionManagerProvider),
          transactions: ref.read(transactionManagerProvider),
        );
      }
      final taskManager = ref.read(taskManagerProvider);
      taskManager.syncFromState(
        fishing: ref.read(fishingProvider),
        inventory: ref.read(inventoryManagerProvider),
        collection: ref.read(collectionManagerProvider),
        transactions: ref.read(transactionManagerProvider),
      );
      ref.read(honorManagerProvider).syncFromState(
            honor: widget.honor,
            fishCollection: widget.dialogManager.fishCollection,
            fishing: ref.read(fishingProvider),
            wallet: ref.read(walletManagerProvider),
            inventory: ref.read(inventoryManagerProvider),
            collection: ref.read(collectionManagerProvider),
            transactions: ref.read(transactionManagerProvider),
            tasks: taskManager,
            taskConfig: widget.dialogManager.task,
          );
    });
    final runtimeAchievements = achievementRuntime.valueOrNull;
    final honorViews = _honorViewsFromAchievementRuntime(
      honor: widget.honor,
      runtime: runtimeAchievements,
      fallback: honorManager,
    );
    final selectedBadge = _selectedBadgeId == null
        ? null
        : honorManager.honorById(widget.honor, _selectedBadgeId!);
    final liveStats = _buildHonorStats(
      base: widget.honor.statistics.items,
      fishing: fishing,
      inventory: inventory,
      collection: collection,
      transactions: transactions,
      tasks: tasks,
      taskConfig: widget.dialogManager.task,
      totalFish: widget.dialogManager.fishCollection.fishes.length,
    );
    final honorValue =
        wallet.points + honorViews.where((item) => item.obtained).length * 50;

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
                    Color(0xE61A2F44),
                    Color(0xDD11263B),
                    Color(0xF00B1624),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0.94, end: 1),
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: 1,
                child: Container(
                  width: (dialog?.rect.width ??
                          math.min(screen.width * 0.92, 1080)) *
                      scale,
                  height: (dialog?.rect.height ??
                          math.min(screen.height * 0.86, 1920)) *
                      scale,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32 * scale),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF4E5C0),
                        Color(0xFFE0C27A),
                        Color(0xFFC79544),
                      ],
                    ),
                    border:
                        Border.all(color: const Color(0xFFF6DC8B), width: 2.4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.32),
                        blurRadius: 36,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      if (header != null)
                        Container(
                          height: header.rect.height * scale,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF163D73),
                                Color(0xFF245A98),
                                Color(0xFF132E56)
                              ],
                            ),
                            border: Border(
                                bottom: BorderSide(
                                    color: Color(0xFFF3D47C), width: 2)),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                          child: Row(
                            children: [
                              if (title != null)
                                Expanded(
                                  child: Text(
                                    widget.honor.title,
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
                              if (close != null)
                                _HonorTopButton(
                                  rect: close.rect,
                                  scale: scale,
                                  label: widget.honor.footer['closeLabel']
                                          ?.toString() ??
                                      '关闭',
                                  icon: Icons.close_rounded,
                                  onTap: () => Navigator.of(context).pop(),
                                ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              18 * scale, 16 * scale, 18 * scale, 14 * scale),
                          child: Column(
                            children: [
                              if (player != null)
                                _HonorPlayerPanel(
                                  rect: player.rect,
                                  scale: scale,
                                  honor: widget.honor,
                                  honorValue: honorValue,
                                ),
                              SizedBox(height: 14 * scale),
                              if (statistics != null)
                                _HonorStatsPanel(
                                  rect: statistics.rect,
                                  scale: scale,
                                  stats: liveStats,
                                ),
                              SizedBox(height: 14 * scale),
                              if (badgeGrid != null)
                                Expanded(
                                  child: _HonorBadgeGrid(
                                    rect: badgeGrid.rect,
                                    scale: scale,
                                    honors: honorViews,
                                    statusLabels: widget.honor.statusLabels,
                                    onSelected: (badgeId) => setState(
                                        () => _selectedBadgeId = badgeId),
                                  ),
                                ),
                              SizedBox(height: 14 * scale),
                              if (footer != null)
                                _HonorFooter(
                                  rect: footer.rect,
                                  scale: scale,
                                  titleLabel: titleTab?.label ?? '称号',
                                  achievementLabel:
                                      achievementTab?.label ?? '成就',
                                  closeLabel: bottomClose?.label ?? '关闭',
                                  onTitle: () {
                                    setState(() {
                                      _selectedBadgeId ??=
                                          widget.honor.badges.isNotEmpty
                                              ? widget.honor.badges.first.id
                                              : null;
                                    });
                                  },
                                  onAchievement: () {
                                    setState(() {
                                      _selectedBadgeId ??=
                                          widget.honor.badges.isNotEmpty
                                              ? widget.honor.badges.first.id
                                              : null;
                                    });
                                  },
                                  onClose: () => Navigator.of(context).pop(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (selectedBadge != null)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => _selectedBadgeId = null),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.38),
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(24 * scale),
                  child: _HonorBadgeDetailDialog(
                    honor: selectedBadge,
                    scale: scale,
                    onClose: () => setState(() => _selectedBadgeId = null),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

List<HonorProgressView> _honorViewsFromAchievementRuntime({
  required HonorConfig honor,
  required AchievementRuntimeManager? runtime,
  required HonorManagerView fallback,
}) {
  if (runtime == null) return fallback.visibleHonors(honor, 'all');
  final byId = {
    for (final item in runtime.getAllAchievements().where(
          (item) => item.source == 'honor',
        ))
      item.id: item,
  };
  final views = honor.badges.map((badge) {
    final progress = byId[badge.id];
    if (progress == null) {
      return fallback.honorById(honor, badge.id) ??
          HonorProgressView(
            config: badge,
            progress: badge.progress,
            status: badge.status,
            obtainedAt: badge.obtainedAt,
          );
    }
    return HonorProgressView(
      config: badge,
      progress: progress.progress,
      status: progress.unlocked ? 'obtained' : progress.status,
      obtainedAt: progress.unlockedAt,
    );
  }).toList(growable: false);
  views.sort((a, b) => a.config.sortOrder.compareTo(b.config.sortOrder));
  return views;
}

List<HonorStatItem> _buildHonorStats({
  required List<HonorStatItem> base,
  required FishingProvider fishing,
  required InventoryManagerView inventory,
  required CollectionManagerView collection,
  required TransactionManagerView transactions,
  required TaskManagerView tasks,
  required TaskConfig taskConfig,
  required int totalFish,
}) {
  final safeTotalFish = totalFish <= 0 ? 1 : totalFish;
  final fishingCount =
      fishing.fishingEvents.where((event) => event.type == 'started').length;
  final sellCount = transactions.records
      .where(
          (record) => record.type == 'sell_fish' || record.type == 'sell_item')
      .length;
  final collectionRate =
      (collection.records.length / safeTotalFish * 100).clamp(0, 100).round();
  final taskCompleted = tasks
      .visibleTasks(taskConfig, 'all')
      .where((task) => task.status == 'completed')
      .length;
  final values = <String>[
    '$fishingCount 条',
    '$collectionRate%',
    '1 天',
    '$taskCompleted 次',
  ];
  return [
    for (var i = 0; i < base.length; i++)
      HonorStatItem(
        label: base[i].label,
        value: i < values.length
            ? values[i]
            : i == 4
                ? '$sellCount 次'
                : '${inventory.releaseCount} 次',
      ),
  ];
}

class _HonorPlayerPanel extends StatelessWidget {
  const _HonorPlayerPanel({
    required this.rect,
    required this.scale,
    required this.honor,
    required this.honorValue,
  });

  final Rect rect;
  final double scale;
  final HonorConfig honor;
  final int honorValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: rect.width * scale,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26 * scale),
        gradient: const LinearGradient(
          colors: [Color(0xFFF2E4C5), Color(0xFFE4C386), Color(0xFFD2A756)],
        ),
        border: Border.all(color: const Color(0xFFF8E2A0), width: 1.8),
      ),
      child: Row(
        children: [
          Container(
            width: 108 * scale,
            height: 108 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [Color(0xFF2E69A7), Color(0xFF173E74)]),
              border: Border.all(color: const Color(0xFFF7DE95), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              honor.player.avatarLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 18 * scale),
          Expanded(
            child: DefaultTextStyle(
              style: TextStyle(
                color: const Color(0xFF4B3212),
                fontSize: 22 * scale,
                fontWeight: FontWeight.w800,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(honor.player.nickname),
                  SizedBox(height: 8 * scale),
                  Text('${honor.player.levelLabel}    荣耀值：$honorValue'),
                  SizedBox(height: 8 * scale),
                  Text('称号：${honor.player.titleLabel}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HonorStatsPanel extends StatelessWidget {
  const _HonorStatsPanel({
    required this.rect,
    required this.scale,
    required this.stats,
  });

  final Rect rect;
  final double scale;
  final List<HonorStatItem> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: rect.width * scale,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24 * scale),
        gradient: const LinearGradient(
          colors: [Color(0xFFF7E9C7), Color(0xFFE8D092), Color(0xFFD5B062)],
        ),
        border: Border.all(color: const Color(0xFFF3D780), width: 1.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final item in stats)
            Expanded(
              child: _HonorStatItem(
                label: item.label,
                value: item.value,
                scale: scale,
              ),
            ),
        ],
      ),
    );
  }
}

class _HonorStatItem extends StatelessWidget {
  const _HonorStatItem({
    required this.label,
    required this.value,
    required this.scale,
  });

  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF4A3112),
            fontSize: 18 * scale,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF183C6B),
            fontSize: 24 * scale,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _HonorBadgeGrid extends StatelessWidget {
  const _HonorBadgeGrid({
    required this.rect,
    required this.scale,
    required this.honors,
    required this.statusLabels,
    required this.onSelected,
  });

  final Rect rect;
  final double scale;
  final List<HonorProgressView> honors;
  final Map<String, String> statusLabels;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: rect.width * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26 * scale),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF6E4BF), Color(0xFFE7C98A), Color(0xFFD4A95E)],
        ),
        border: Border.all(color: const Color(0xFFF8DF94), width: 1.6),
      ),
      padding: EdgeInsets.all(18 * scale),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: honors.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.86,
        ),
        itemBuilder: (context, index) {
          final badge = honors[index];
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.94, end: 1),
            duration: Duration(milliseconds: 140 + index * 24),
            curve: Curves.easeOutBack,
            builder: (context, value, child) =>
                Transform.scale(scale: value, child: child),
            child: _HonorBadgeCard(
              honor: badge,
              statusLabels: statusLabels,
              scale: scale,
              onTap: () => onSelected(badge.config.id),
            ),
          );
        },
      ),
    );
  }
}

class _HonorBadgeCard extends StatelessWidget {
  const _HonorBadgeCard({
    required this.honor,
    required this.statusLabels,
    required this.scale,
    required this.onTap,
  });

  final HonorProgressView honor;
  final Map<String, String> statusLabels;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badge = honor.config;
    final colors = honor.obtained
        ? const [Color(0xFF59D7F8), Color(0xFF246DBB), Color(0xFF17355F)]
        : const [Color(0xFF8C8C8C), Color(0xFF616161), Color(0xFF474747)];
    final titleColor =
        honor.obtained ? const Color(0xFF17355F) : const Color(0xFFDEDEDE);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22 * scale),
          gradient: LinearGradient(colors: colors),
          border: Border.all(
            color: honor.obtained
                ? const Color(0xFFFFE190)
                : const Color(0xFF9D9D9D),
            width: honor.obtained ? 2 : 1.3,
          ),
          boxShadow: [
            if (honor.obtained)
              const BoxShadow(
                color: Color(0x66FFD968),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
          ],
        ),
        padding: EdgeInsets.all(10 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badge.icon,
              style: TextStyle(fontSize: 26 * scale),
            ),
            SizedBox(height: 8 * scale),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 16 * scale,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4 * scale),
            Text(
              statusLabels[honor.status] ?? honor.status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 11 * scale,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 3 * scale),
            Text(
              honor.config.target > 0
                  ? '${honor.cappedProgress}/${honor.config.target}'
                  : '${honor.progress}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HonorFooter extends StatelessWidget {
  const _HonorFooter({
    required this.rect,
    required this.scale,
    required this.titleLabel,
    required this.achievementLabel,
    required this.closeLabel,
    required this.onTitle,
    required this.onAchievement,
    required this.onClose,
  });

  final Rect rect;
  final double scale;
  final String titleLabel;
  final String achievementLabel;
  final String closeLabel;
  final VoidCallback onTitle;
  final VoidCallback onAchievement;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: rect.width * scale,
      child: Row(
        children: [
          Expanded(
            child: _HonorFooterButton(
                label: titleLabel, scale: scale, onTap: onTitle),
          ),
          SizedBox(width: 14 * scale),
          Expanded(
            child: _HonorFooterButton(
                label: achievementLabel, scale: scale, onTap: onAchievement),
          ),
          SizedBox(width: 14 * scale),
          Expanded(
            child: _HonorFooterButton(
              label: closeLabel,
              scale: scale,
              onTap: onClose,
              primary: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _HonorFooterButton extends StatelessWidget {
  const _HonorFooterButton({
    required this.label,
    required this.scale,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final double scale;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        height: 72 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22 * scale),
          gradient: primary
              ? const LinearGradient(colors: [
                  Color(0xFFFFD96B),
                  Color(0xFFE19A1B),
                  Color(0xFFB56708)
                ])
              : const LinearGradient(
                  colors: [Color(0xFF3A85DA), Color(0xFF18446F)]),
          border: Border.all(
            color: primary ? const Color(0xFFFFF0A8) : const Color(0xFFF3D780),
            width: 1.8,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _HonorTopButton extends StatelessWidget {
  const _HonorTopButton({
    required this.rect,
    required this.scale,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final Rect rect;
  final double scale;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        width: rect.width * scale,
        height: rect.height * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18 * scale),
          gradient: const LinearGradient(
              colors: [Color(0xFF3B86DB), Color(0xFF18426F)]),
          border: Border.all(color: const Color(0xFFF7D77B), width: 1.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18 * scale, color: const Color(0xFFFFE08C)),
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

class _HonorBadgeDetailDialog extends StatelessWidget {
  const _HonorBadgeDetailDialog({
    required this.honor,
    required this.scale,
    required this.onClose,
  });

  final HonorProgressView honor;
  final double scale;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final badge = honor.config;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {},
      child: Container(
        width: 760 * scale,
        constraints:
            BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28 * scale),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF4E7C3), Color(0xFFE4C98A), Color(0xFFCFA558)],
          ),
          border: Border.all(color: const Color(0xFFF7DE95), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 88 * scale,
                  height: 88 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: honor.obtained
                        ? const LinearGradient(
                            colors: [Color(0xFF5BD6F7), Color(0xFF256FB8)])
                        : const LinearGradient(
                            colors: [Color(0xFF909090), Color(0xFF5F5F5F)]),
                    border:
                        Border.all(color: const Color(0xFFF7DE95), width: 2),
                  ),
                  alignment: Alignment.center,
                  child:
                      Text(badge.icon, style: TextStyle(fontSize: 34 * scale)),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        badge.name,
                        style: TextStyle(
                          color: const Color(0xFF4A3112),
                          fontSize: 28 * scale,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      Text(
                        badge.detailTitle,
                        style: TextStyle(
                          color: const Color(0xFF18426F),
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                _HonorFooterButton(
                    label: '关闭', scale: scale, onTap: onClose, primary: true),
              ],
            ),
            SizedBox(height: 16 * scale),
            _detailRow('状态', honor.status, scale),
            SizedBox(height: 10 * scale),
            _detailRow(
                '当前进度',
                honor.config.target > 0
                    ? '${honor.cappedProgress}/${honor.config.target}'
                    : '${honor.progress}',
                scale),
            SizedBox(height: 10 * scale),
            _detailRow('获得时间', honor.obtainedAt, scale),
            SizedBox(height: 10 * scale),
            _detailRow('获得条件', badge.condition, scale),
            SizedBox(height: 10 * scale),
            _detailRow('徽章故事', badge.story, scale),
            SizedBox(height: 10 * scale),
            _detailRow('奖励', badge.reward, scale),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, double scale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110 * scale,
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF4B3112),
              fontSize: 18 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: const Color(0xFF5B3B16),
              fontSize: 18 * scale,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
