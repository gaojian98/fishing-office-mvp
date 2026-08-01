import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_typography.dart';
import '../../core/bootstrap/fishing_office_scope.dart';
import '../../core/dialog/dialog_manager.dart';
import '../../core/managers/app_managers.dart';
import '../../core/providers/app_providers.dart';
import '../../models/assets_config.dart';
import '../../models/fish_collection_config.dart';
import '../../models/layout_config.dart';
import '../../models/profile_config.dart';
import '../../models/task_config.dart';
import '../../models/transaction_config.dart';

class ProfileCenterDialogPage extends ConsumerStatefulWidget {
  const ProfileCenterDialogPage({
    super.key,
    required this.profile,
    required this.assets,
    required this.transactions,
    required this.fishCollection,
    required this.task,
    required this.layout,
    required this.transactionLayout,
    required this.dialogManager,
  });

  final ProfileConfig profile;
  final AssetsConfig assets;
  final TransactionConfig transactions;
  final FishCollectionConfig fishCollection;
  final TaskConfig task;
  final LayoutConfig layout;
  final LayoutConfig transactionLayout;
  final DialogManager dialogManager;

  @override
  ConsumerState<ProfileCenterDialogPage> createState() =>
      _ProfileCenterDialogPageState();
}

class _ProfileCenterDialogPageState
    extends ConsumerState<ProfileCenterDialogPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _avatarController;
  String _selectedMenuId = 'assets';

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = FishingOfficeScope.of(context);
    final scale = scope.responsive.scale;
    final screen = MediaQuery.sizeOf(context);

    final dialog = widget.layout.byId('profile_dialog');
    final header = widget.layout.byId('profile_header');
    final title = widget.layout.byId('profile_title');
    final close = widget.layout.byId('profile_close');
    final player = widget.layout.byId('profile_player');
    final sidebar = widget.layout.byId('profile_sidebar');
    final content = widget.layout.byId('profile_content');
    final footer = widget.layout.byId('profile_footer');
    final transactionButton = widget.layout.byId('profile_transaction_button');
    final closeButton = widget.layout.byId('profile_close_button');
    final selectedSection = widget.profile.sectionById(_selectedMenuId);
    final wallet = ref.watch(walletManagerProvider);
    final fishing = ref.watch(fishingProvider);
    final inventory = ref.watch(inventoryManagerProvider);
    final collection = ref.watch(collectionManagerProvider);
    final transactions = ref.watch(transactionManagerProvider);
    final tasks = ref.watch(taskManagerProvider);
    final questRuntime = ref.watch(questRuntimeManagerProvider);
    final achievementRuntime = ref.watch(achievementRuntimeManagerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final quest = questRuntime.valueOrNull;
      if (quest != null) {
        quest.syncFromState(
          fishing: ref.read(fishingProvider),
          inventory: ref.read(inventoryManagerProvider),
          collection: ref.read(collectionManagerProvider),
          transactions: ref.read(transactionManagerProvider),
        );
        return;
      }
      ref.read(taskManagerProvider).syncFromState(
            fishing: ref.read(fishingProvider),
            inventory: ref.read(inventoryManagerProvider),
            collection: ref.read(collectionManagerProvider),
            transactions: ref.read(transactionManagerProvider),
          );
    });
    final liveAssets = _buildLiveAssets(
      base: widget.assets,
      wallet: wallet,
      fishing: fishing,
      inventory: inventory,
      collection: collection,
      transactions: transactions,
      tasks: tasks,
      fishCollection: widget.fishCollection,
      taskConfig: widget.task,
    );

    final dialogWidth =
        (dialog?.rect.width ?? math.min(screen.width * 0.92, 1080)) * scale;
    final dialogHeight =
        (dialog?.rect.height ?? math.min(screen.height * 0.86, 1920)) * scale;

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
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0.94, end: 1),
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Container(
                width: dialogWidth,
                height: dialogHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32 * scale),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF3E1B8),
                      Color(0xFFE1C27B),
                      Color(0xFFC59649),
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
                                  widget.profile.title,
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
                              _ProfileTopButton(
                                rect: close.rect,
                                scale: scale,
                                label: widget.profile.closeLabel,
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
                              _ProfilePlayerPanel(
                                profile: widget.profile,
                                experienceValue: wallet.points,
                                titleOverride: achievementRuntime.valueOrNull
                                    ?.getEquippedTitle()
                                    ?.title,
                                rect: player.rect,
                                scale: scale,
                                avatarController: _avatarController,
                              ),
                            SizedBox(height: 16 * scale),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (sidebar != null)
                                    _ProfileMenuPanel(
                                      rect: sidebar.rect,
                                      scale: scale,
                                      layout: widget.layout,
                                      profile: widget.profile,
                                      selectedMenuId: _selectedMenuId,
                                      onSelected: (menuId) {
                                        setState(
                                            () => _selectedMenuId = menuId);
                                        if (menuId == 'settings') {
                                          widget.dialogManager.openById(
                                              context, 'SettingsDialog');
                                        }
                                      },
                                    ),
                                  SizedBox(width: 16 * scale),
                                  if (content != null)
                                    Expanded(
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        switchInCurve: Curves.easeOut,
                                        switchOutCurve: Curves.easeIn,
                                        transitionBuilder: (child, animation) =>
                                            FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                        child: _selectedMenuId == 'assets'
                                            ? _ProfileAssetsPanel(
                                                key: const ValueKey('assets'),
                                                rect: content.rect,
                                                scale: scale,
                                                assets: liveAssets,
                                              )
                                            : _ProfileTextSectionPanel(
                                                key: ValueKey(_selectedMenuId),
                                                rect: content.rect,
                                                scale: scale,
                                                menu: widget.profile.menus
                                                    .firstWhere(
                                                  (entry) =>
                                                      entry.id ==
                                                      _selectedMenuId,
                                                  orElse: () => widget
                                                      .profile.menus.first,
                                                ),
                                                section: selectedSection,
                                              ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16 * scale),
                            if (footer != null)
                              _ProfileFooter(
                                rect: footer.rect,
                                scale: scale,
                                transactionLabel:
                                    widget.profile.footer.transactionLabel,
                                closeLabel: widget.profile.footer.closeLabel,
                                transactionButtonRect: transactionButton?.rect,
                                closeButtonRect: closeButton?.rect,
                                onTransaction: () => widget.dialogManager
                                    .showProfileTransactionRecordsDialog(
                                  context,
                                  transactions: widget.transactions,
                                  layout: widget.transactionLayout,
                                ),
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
        ],
      ),
    );
  }
}

AssetsConfig _buildLiveAssets({
  required AssetsConfig base,
  required WalletManagerView wallet,
  required FishingProvider fishing,
  required InventoryManagerView inventory,
  required CollectionManagerView collection,
  required TransactionManagerView transactions,
  required TaskManagerView tasks,
  required FishCollectionConfig fishCollection,
  required TaskConfig taskConfig,
}) {
  final fishingCount =
      fishing.fishingEvents.where((event) => event.type == 'started').length;
  final sellCount = transactions.records
      .where(
          (record) => record.type == 'sell_fish' || record.type == 'sell_item')
      .length;
  final inventoryCount =
      inventory.entries.fold<int>(0, (sum, entry) => sum + entry.quantity);
  final discoveredCount = collection.records.length;
  final totalFish =
      fishCollection.fishes.isEmpty ? 1 : fishCollection.fishes.length;
  final completionRate =
      (discoveredCount / totalFish * 100).clamp(0, 100).round();
  final completedTasks = tasks
      .visibleTasks(taskConfig, 'all')
      .where((task) => task.status == 'completed')
      .length;
  final transactionCount = transactions.records.length;

  String summaryValue(String id, String fallback) {
    switch (id) {
      case 'fish_coin':
        return '${wallet.fishCoin}';
      case 'experience':
        return '${wallet.points}';
      case 'fish_count':
        return '$fishingCount 次';
      case 'sell_count':
        return '$sellCount 次';
      case 'release_count':
        return '${inventory.releaseCount} 次';
      case 'collection_rate':
        return '$completionRate%';
      case 'collection_count':
        return '$discoveredCount / ${fishCollection.fishes.length}';
      default:
        return fallback;
    }
  }

  String statisticValue(String id, String fallback) {
    switch (id) {
      case 'task_completed':
        return '$completedTasks';
      case 'inventory_count':
        return '$inventoryCount';
      case 'collection_count':
        return '$discoveredCount';
      case 'transaction_count':
        return '$transactionCount';
      case 'sell_count':
        return '$sellCount';
      case 'release_count':
        return '${inventory.releaseCount}';
      default:
        return fallback;
    }
  }

  return AssetsConfig(
    title: base.title,
    summaryTitle: base.summaryTitle,
    summaryCards: base.summaryCards
        .map(
          (metric) => AssetMetric(
            id: metric.id,
            label: metric.label,
            value: summaryValue(metric.id, metric.value),
            icon: metric.icon,
          ),
        )
        .toList(growable: false),
    statisticsTitle: base.statisticsTitle,
    statistics: base.statistics
        .map(
          (stat) => AssetStatistic(
            id: stat.id,
            label: stat.label,
            value: statisticValue(stat.id, stat.value),
          ),
        )
        .toList(growable: false),
  );
}

class _ProfilePlayerPanel extends StatelessWidget {
  const _ProfilePlayerPanel({
    required this.profile,
    required this.experienceValue,
    required this.titleOverride,
    required this.rect,
    required this.scale,
    required this.avatarController,
  });

  final ProfileConfig profile;
  final int experienceValue;
  final String? titleOverride;
  final Rect rect;
  final double scale;
  final AnimationController avatarController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: rect.width * scale,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28 * scale),
        gradient: const LinearGradient(
          colors: [Color(0xFFF4E5C8), Color(0xFFE2C68A), Color(0xFFD6AA5B)],
        ),
        border: Border.all(color: const Color(0xFFF7E19C), width: 1.8),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: avatarController,
            builder: (context, child) {
              final pulse = 1 + avatarController.value * 0.035;
              return Transform.scale(scale: pulse, child: child);
            },
            child: Container(
              width: 124 * scale,
              height: 124 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF326DAA), Color(0xFF173E74)],
                ),
                border: Border.all(color: const Color(0xFFF7E08E), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                profile.player.nickname.isNotEmpty
                    ? profile.player.nickname.substring(0, 1)
                    : '人',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42 * scale,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SizedBox(width: 18 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  profile.player.nickname,
                  style: TextStyle(
                    color: const Color(0xFF16345F),
                    fontSize: 30 * scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  profile.player.level,
                  style: TextStyle(
                    color: const Color(0xFF284E84),
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  '${profile.player.titleLabel}${titleOverride?.isNotEmpty == true ? titleOverride : profile.player.title}',
                  style: AppTypography.body.copyWith(
                    color: const Color(0xFF374F72),
                    fontSize: 18 * scale,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  '${profile.player.joinDaysLabel}${profile.player.joinDays}',
                  style: AppTypography.body.copyWith(
                    color: const Color(0xFF374F72),
                    fontSize: 16 * scale,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  '${profile.player.experienceLabel}$experienceValue',
                  style: AppTypography.body.copyWith(
                    color: const Color(0xFF374F72),
                    fontSize: 16 * scale,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  '${profile.player.streakLabel}${profile.player.streak}',
                  style: AppTypography.body.copyWith(
                    color: const Color(0xFF374F72),
                    fontSize: 16 * scale,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuPanel extends StatelessWidget {
  const _ProfileMenuPanel({
    required this.rect,
    required this.scale,
    required this.layout,
    required this.profile,
    required this.selectedMenuId,
    required this.onSelected,
  });

  final Rect rect;
  final double scale;
  final LayoutConfig layout;
  final ProfileConfig profile;
  final String selectedMenuId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: rect.width * scale,
      height: rect.height * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28 * scale),
        gradient: const LinearGradient(
          colors: [Color(0xFFF8EDD0), Color(0xFFEBCF95), Color(0xFFD6AA5B)],
        ),
        border: Border.all(color: const Color(0xFFF7E19C), width: 1.8),
      ),
      child: Stack(
        children: [
          for (final menu in profile.menus)
            (() {
              final menuRect = layout.byId('profile_menu_${menu.id}');
              if (menuRect == null) return const SizedBox.shrink();
              return Positioned(
                left: (menuRect.rect.left - rect.left) * scale,
                top: (menuRect.rect.top - rect.top) * scale,
                width: menuRect.rect.width * scale,
                height: menuRect.rect.height * scale,
                child: _ProfileMenuButton(
                  label: menu.label,
                  hint: menu.hint,
                  selected: menu.id == selectedMenuId,
                  onTap: () => onSelected(menu.id),
                ),
              );
            }()),
        ],
      ),
    );
  }
}

class _ProfileMenuButton extends StatelessWidget {
  const _ProfileMenuButton({
    required this.label,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF3D7CC0), Color(0xFF174B86)])
                : const LinearGradient(
                    colors: [Color(0xFFEFE4C8), Color(0xFFD9BF84)]),
            border: Border.all(
                color: selected
                    ? const Color(0xFFF7DE95)
                    : const Color(0xFFE2C06D),
                width: 1.6),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF6F9ED1).withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF18345F),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.9)
                      : const Color(0xFF5A6E8A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAssetsPanel extends StatelessWidget {
  const _ProfileAssetsPanel({
    super.key,
    required this.rect,
    required this.scale,
    required this.assets,
  });

  final Rect rect;
  final double scale;
  final AssetsConfig assets;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: rect.width * scale,
      height: rect.height * scale,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28 * scale),
        gradient: const LinearGradient(
          colors: [Color(0xFFF7E6C8), Color(0xFFE7C989), Color(0xFFD8AD5E)],
        ),
        border: Border.all(color: const Color(0xFFF8E19D), width: 1.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            assets.summaryTitle,
            style: TextStyle(
              color: const Color(0xFF17345F),
              fontSize: 22 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 14 * scale),
          Expanded(
            child: GridView.builder(
              itemCount: assets.summaryCards.length,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14 * scale,
                crossAxisSpacing: 14 * scale,
                childAspectRatio: 1.85,
              ),
              itemBuilder: (context, index) => _ProfileMetricCard(
                metric: assets.summaryCards[index],
                scale: scale,
              ),
            ),
          ),
          SizedBox(height: 18 * scale),
          Text(
            assets.statisticsTitle,
            style: TextStyle(
              color: const Color(0xFF17345F),
              fontSize: 22 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12 * scale),
          Expanded(
            child: GridView.builder(
              itemCount: assets.statistics.length,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12 * scale,
                crossAxisSpacing: 12 * scale,
                childAspectRatio: 2.15,
              ),
              itemBuilder: (context, index) => _ProfileStatCard(
                stat: assets.statistics[index],
                scale: scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTextSectionPanel extends StatelessWidget {
  const _ProfileTextSectionPanel({
    super.key,
    required this.rect,
    required this.scale,
    required this.menu,
    required this.section,
  });

  final Rect rect;
  final double scale;
  final ProfileMenuItem menu;
  final ProfileSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: rect.width * scale,
      height: rect.height * scale,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28 * scale),
        gradient: const LinearGradient(
          colors: [Color(0xFFF7E6C8), Color(0xFFE7C989), Color(0xFFD8AD5E)],
        ),
        border: Border.all(color: const Color(0xFFF8E19D), width: 1.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title.isNotEmpty ? section.title : menu.label,
            style: TextStyle(
              color: const Color(0xFF17345F),
              fontSize: 24 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 14 * scale),
          ...section.lines.map(
            (line) => Padding(
              padding: EdgeInsets.only(bottom: 10 * scale),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale, vertical: 14 * scale),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18 * scale),
                  color: const Color(0xFFFDF6E7),
                  border:
                      Border.all(color: const Color(0xFFE4C97A), width: 1.1),
                ),
                child: Text(
                  line,
                  style: TextStyle(
                    color: const Color(0xFF3C506E),
                    fontSize: 15 * scale,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetricCard extends StatelessWidget {
  const _ProfileMetricCard({
    required this.metric,
    required this.scale,
  });

  final AssetMetric metric;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        color: const Color(0xFFFDF7EA),
        border: Border.all(color: const Color(0xFFE3C67F), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            metric.label,
            style: TextStyle(
              color: const Color(0xFF4A5D78),
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8 * scale),
          _RollingValueText(
            value: metric.value,
            scale: scale,
          ),
        ],
      ),
    );
  }
}

class _RollingValueText extends StatelessWidget {
  const _RollingValueText({
    required this.value,
    required this.scale,
  });

  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final match = RegExp(r'^([\d,]+(?:\.\d+)?)\s*(.*)$').firstMatch(value);
    if (match == null) {
      return Text(
        value,
        style: TextStyle(
          color: const Color(0xFFB57A12),
          fontSize: 24 * scale,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    final numeric = double.tryParse(match.group(1)!.replaceAll(',', '')) ?? 0;
    final suffix = match.group(2) ?? '';
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: numeric),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, animated, child) {
        final display = numeric.truncate() == numeric
            ? animated.round().toString()
            : animated.toStringAsFixed(1);
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: _formatWithCommas(display),
                style: TextStyle(
                  color: const Color(0xFFB57A12),
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (suffix.isNotEmpty)
                TextSpan(
                  text: suffix.startsWith(' ') ? suffix : ' $suffix',
                  style: TextStyle(
                    color: const Color(0xFF7C6642),
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatWithCommas(String value) {
    final parts = value.split('.');
    final whole = parts.first.replaceAll(',', '');
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      final indexFromEnd = whole.length - i - 1;
      buffer.write(whole[i]);
      if (indexFromEnd % 3 == 0 && i != whole.length - 1) {
        buffer.write(',');
      }
    }
    if (parts.length == 2) {
      return '${buffer.toString()}.${parts.last}';
    }
    return buffer.toString();
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.stat,
    required this.scale,
  });

  final AssetStatistic stat;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        color: const Color(0xFFFDF7EA),
        border: Border.all(color: const Color(0xFFE3C67F), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat.label,
            style: TextStyle(
              color: const Color(0xFF4A5D78),
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            stat.value,
            style: TextStyle(
              color: const Color(0xFF1B416D),
              fontSize: 18 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFooter extends StatelessWidget {
  const _ProfileFooter({
    required this.rect,
    required this.scale,
    required this.transactionLabel,
    required this.closeLabel,
    required this.transactionButtonRect,
    required this.closeButtonRect,
    required this.onTransaction,
    required this.onClose,
  });

  final Rect rect;
  final double scale;
  final String transactionLabel;
  final String closeLabel;
  final Rect? transactionButtonRect;
  final Rect? closeButtonRect;
  final VoidCallback onTransaction;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final transactionWidth =
        (transactionButtonRect?.width ?? rect.width * 0.46) * scale;
    final closeWidth = (closeButtonRect?.width ?? rect.width * 0.46) * scale;
    final height = math.max(transactionButtonRect?.height ?? 78,
            closeButtonRect?.height ?? 78) *
        scale;
    return SizedBox(
      height: rect.height * scale,
      child: Row(
        children: [
          SizedBox(
            width: transactionWidth,
            height: height,
            child: _BlueGoldButton(
              label: transactionLabel,
              icon: Icons.receipt_long_rounded,
              onTap: onTransaction,
            ),
          ),
          SizedBox(width: 16 * scale),
          SizedBox(
            width: closeWidth,
            height: height,
            child: _BlueGoldButton(
              label: closeLabel,
              icon: Icons.close_rounded,
              onTap: onClose,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlueGoldButton extends StatelessWidget {
  const _BlueGoldButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF306FAF), Color(0xFF184A88)],
            ),
            border: Border.all(color: const Color(0xFFF4D77E), width: 1.6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTopButton extends StatelessWidget {
  const _ProfileTopButton({
    required this.label,
    required this.icon,
    required this.rect,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Rect rect;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: rect.width * scale,
      height: rect.height * scale,
      child: _BlueGoldButton(
        label: label,
        icon: icon,
        onTap: onTap,
      ),
    );
  }
}
