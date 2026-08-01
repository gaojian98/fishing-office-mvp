import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/buttons/fishing_buttons.dart';
import '../../core/providers/app_providers.dart';
import '../../models/fish_collection_config.dart';
import '../../models/layout_config.dart';

class FishCollectionDialogPage extends ConsumerStatefulWidget {
  const FishCollectionDialogPage({
    super.key,
    required this.collection,
    required this.layout,
  });

  final FishCollectionConfig collection;
  final LayoutConfig layout;

  @override
  ConsumerState<FishCollectionDialogPage> createState() =>
      _FishCollectionDialogPageState();
}

class _FishCollectionDialogPageState
    extends ConsumerState<FishCollectionDialogPage> {
  String _selectedCategoryId = 'all';
  String? _selectedFishId;

  @override
  void initState() {
    super.initState();
    _selectedFishId = widget.collection.defaultFishId.isNotEmpty
        ? widget.collection.defaultFishId
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final scale = math.min(
      screen.width / widget.layout.designSize.width,
      screen.height / widget.layout.designSize.height,
    );
    final dialog = widget.layout.byId('collection_dialog');
    final header = widget.layout.byId('collection_header');
    final title = widget.layout.byId('collection_title');
    final close = widget.layout.byId('collection_close');
    final stats = widget.layout.byId('collection_stats');
    final sidebar = widget.layout.byId('collection_sidebar');
    final detail = widget.layout.byId('collection_detail');
    final preview = widget.layout.byId('collection_preview');
    final nameRect = widget.layout.byId('collection_name');
    final conditionRect = widget.layout.byId('collection_condition');
    final storyRect = widget.layout.byId('collection_story');
    final footer = widget.layout.byId('collection_footer');
    final prev = widget.layout.byId('collection_prev');
    final next = widget.layout.byId('collection_next');

    final collectionManager = ref.watch(collectionManagerProvider);
    final discoveredIds = collectionManager.discoveredIds;
    final discoveredFish = widget.collection.fishes
        .where((fish) => discoveredIds.contains(fish.id))
        .toList(growable: false);
    final filteredFish = _filteredFish();
    final pageFish =
        filteredFish.isEmpty ? widget.collection.fishes : filteredFish;
    if (_selectedFishId == null ||
        !pageFish.any((fish) => fish.id == _selectedFishId)) {
      _selectedFishId = pageFish.isNotEmpty ? pageFish.first.id : null;
    }
    final selectedFish = _selectedFishId == null
        ? null
        : widget.collection.fishById(_selectedFishId!);
    final selectedDiscovered =
        selectedFish != null && collectionManager.isDiscovered(selectedFish.id);
    final displayFish = selectedFish ??
        (widget.collection.fishes.isNotEmpty
            ? widget.collection.fishes.first
            : null);
    final total = widget.collection.fishes.length;
    final collectedCount = discoveredFish.length.clamp(0, total);
    final completion = total == 0 ? 0.0 : (collectedCount / total);
    final totalWeight = discoveredFish.fold<double>(
        0, (sum, fish) => sum + fish.averageWeightKg);
    final heaviestWeight = discoveredFish.isEmpty
        ? 0.0
        : discoveredFish.map((fish) => fish.maxWeightKg).reduce(math.max);
    final width =
        (dialog?.rect.width ?? math.min(screen.width * 0.92, 1080)) * scale;
    final height =
        (dialog?.rect.height ?? math.min(screen.height * 0.9, 1920)) * scale;

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
                    Color(0xE6192D41),
                    Color(0xDD102537),
                    Color(0xF00A1521),
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
                width: width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32 * scale),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF5E4BC),
                      Color(0xFFE2C27B),
                      Color(0xFFC79647),
                    ],
                  ),
                  border:
                      Border.all(color: const Color(0xFFF6DE8A), width: 2.4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.32),
                      blurRadius: 38,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
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
                                Color(0xFF163D73),
                                Color(0xFF245A98),
                                Color(0xFF132E56)
                              ],
                            ),
                            border: Border(
                                bottom: BorderSide(
                                    color: Color(0xFFF3D47C), width: 2)),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 26 * scale),
                          child: Row(
                            children: [
                              if (title != null)
                                Expanded(
                                  child: Text(
                                    widget.collection.title,
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
                                _TopButton(
                                  rect: close.rect,
                                  scale: scale,
                                  label: widget.collection.footer.closeLabel,
                                  icon: Icons.close_rounded,
                                  onTap: () => Navigator.of(context).pop(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    if (stats != null)
                      Positioned(
                        left: stats.rect.left * scale,
                        top: stats.rect.top * scale,
                        width: stats.rect.width * scale,
                        height: stats.rect.height * scale,
                        child: _CollectionStatsBar(
                          scale: scale,
                          collectedLabel:
                              widget.collection.stats.collectedLabel,
                          completionLabel:
                              widget.collection.stats.completionLabel,
                          totalWeightLabel:
                              widget.collection.stats.totalWeightLabel,
                          heaviestLabel: widget.collection.stats.heaviestLabel,
                          collectedText: '$collectedCount / $total',
                          completionText:
                              '${(completion * 100).toStringAsFixed(total == 0 ? 0 : 1)}%',
                          totalWeightText: '${_formatWeight(totalWeight)}kg',
                          heaviestText: '${_formatWeight(heaviestWeight)}kg',
                        ),
                      ),
                    if (sidebar != null)
                      Positioned(
                        left: sidebar.rect.left * scale,
                        top: sidebar.rect.top * scale,
                        width: sidebar.rect.width * scale,
                        height: sidebar.rect.height * scale,
                        child: _CollectionSidebar(
                          categories: widget.collection.categories,
                          selectedCategoryId: _selectedCategoryId,
                          scale: scale,
                          onSelected: (id) {
                            setState(() {
                              _selectedCategoryId = id;
                              final nextFish = _filteredFish();
                              _selectedFishId = nextFish.isNotEmpty
                                  ? nextFish.first.id
                                  : null;
                            });
                          },
                        ),
                      ),
                    if (detail != null)
                      Positioned(
                        left: detail.rect.left * scale,
                        top: detail.rect.top * scale,
                        width: detail.rect.width * scale,
                        height: detail.rect.height * scale,
                        child: displayFish == null
                            ? _CollectionEmptyState(
                                emptyState: widget.collection.emptyState,
                                scale: scale,
                                onStartFishing: () {
                                  Navigator.of(context).pop();
                                  ref
                                      .read(navigationManagerProvider)
                                      .openRoute(context, '/fishing');
                                },
                              )
                            : _CollectionDetailPanel(
                                scale: scale,
                                fish: displayFish,
                                selectedDiscovered: selectedDiscovered,
                                catchCount: collectionManager
                                        .recordOf(displayFish.id)
                                        ?.catchCount ??
                                    0,
                                labels: widget.collection.labels,
                                lockedState: widget.collection.lockedState,
                                previewRect: preview?.rect,
                                nameRect: nameRect?.rect,
                                conditionRect: conditionRect?.rect,
                                storyRect: storyRect?.rect,
                                emptyState: widget.collection.emptyState,
                                onStartFishing: () {
                                  Navigator.of(context).pop();
                                  ref
                                      .read(navigationManagerProvider)
                                      .openRoute(context, '/fishing');
                                },
                              ),
                      ),
                    if (footer != null && discoveredIds.isNotEmpty)
                      Positioned(
                        left: footer.rect.left * scale,
                        top: footer.rect.top * scale,
                        width: footer.rect.width * scale,
                        height: footer.rect.height * scale,
                        child: Row(
                          children: [
                            if (prev != null)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 12 * scale),
                                  child: FishingSecondaryButton(
                                    label:
                                        widget.collection.footer.previousLabel,
                                    onPressed: _previousFish,
                                  ),
                                ),
                              ),
                            if (next != null)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: prev != null ? 12 * scale : 0),
                                  child: FishingSecondaryButton(
                                    label: widget.collection.footer.nextLabel,
                                    onPressed: _nextFish,
                                  ),
                                ),
                              ),
                          ],
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

  List<FishCollectionFish> _filteredFish() {
    if (_selectedCategoryId == 'all') return widget.collection.fishes;
    return widget.collection.fishes
        .where((fish) => fish.category == _selectedCategoryId)
        .toList(growable: false);
  }

  void _previousFish() {
    final current = _filteredFish();
    if (current.isEmpty) return;
    final index = current.indexWhere((fish) => fish.id == _selectedFishId);
    final nextIndex = index <= 0 ? current.length - 1 : index - 1;
    setState(() => _selectedFishId = current[nextIndex].id);
  }

  void _nextFish() {
    final current = _filteredFish();
    if (current.isEmpty) return;
    final index = current.indexWhere((fish) => fish.id == _selectedFishId);
    final nextIndex = index < 0 || index >= current.length - 1 ? 0 : index + 1;
    setState(() => _selectedFishId = current[nextIndex].id);
  }
}

class _CollectionStatsBar extends StatelessWidget {
  const _CollectionStatsBar({
    required this.scale,
    required this.collectedLabel,
    required this.completionLabel,
    required this.totalWeightLabel,
    required this.heaviestLabel,
    required this.collectedText,
    required this.completionText,
    required this.totalWeightText,
    required this.heaviestText,
  });

  final double scale;
  final String collectedLabel;
  final String completionLabel;
  final String totalWeightLabel;
  final String heaviestLabel;
  final String collectedText;
  final String completionText;
  final String totalWeightText;
  final String heaviestText;

  @override
  Widget build(BuildContext context) {
    final entries = [
      (collectedLabel, collectedText),
      (completionLabel, completionText),
      (totalWeightLabel, totalWeightText),
      (heaviestLabel, heaviestText),
    ];
    return Row(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) SizedBox(width: 14 * scale),
          Expanded(
            child: _CollectionStatCard(
              scale: scale,
              label: entries[i].$1,
              value: entries[i].$2,
            ),
          ),
        ],
      ],
    );
  }
}

class _CollectionStatCard extends StatelessWidget {
  const _CollectionStatCard({
    required this.scale,
    required this.label,
    required this.value,
  });

  final double scale;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE9D7A7), Color(0xFFF8ECD0)],
        ),
        borderRadius: BorderRadius.circular(22 * scale),
        border: Border.all(color: const Color(0xFFE0BF73), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF5E4524),
              fontSize: 18 * scale,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF143C73),
              fontSize: 22 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionSidebar extends StatelessWidget {
  const _CollectionSidebar({
    required this.categories,
    required this.selectedCategoryId,
    required this.scale,
    required this.onSelected,
  });

  final List<FishCollectionCategory> categories;
  final String selectedCategoryId;
  final double scale;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9D0A4), Color(0xFFD8B26A)],
        ),
        borderRadius: BorderRadius.circular(26 * scale),
        border: Border.all(color: const Color(0xFFF4E5B0), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '目录',
            style: TextStyle(
              color: const Color(0xFF173E72),
              fontSize: 24 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 14 * scale),
          for (final category in categories)
            Padding(
              padding: EdgeInsets.only(bottom: 10 * scale),
              child: _CategoryButton(
                label: category.label,
                selected: category.id == selectedCategoryId,
                scale: scale,
                onTap: () => onSelected(category.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.label,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FishingButtonPressed(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 16 * scale),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF2C67AA), Color(0xFF1D4D87)])
              : const LinearGradient(
                  colors: [Color(0xFF25486F), Color(0xFF173656)]),
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(
            color: selected ? const Color(0xFFF6E49C) : const Color(0xFF7EA2CA),
            width: selected ? 2.2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0x55FFD66A)
                  : Colors.black.withValues(alpha: 0.12),
              blurRadius: selected ? 18 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22 * scale,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _CollectionDetailPanel extends StatelessWidget {
  const _CollectionDetailPanel({
    required this.scale,
    required this.fish,
    required this.selectedDiscovered,
    required this.catchCount,
    required this.labels,
    required this.lockedState,
    required this.previewRect,
    required this.nameRect,
    required this.conditionRect,
    required this.storyRect,
    required this.emptyState,
    required this.onStartFishing,
  });

  final double scale;
  final FishCollectionFish? fish;
  final bool selectedDiscovered;
  final int catchCount;
  final Map<String, dynamic> labels;
  final FishCollectionLockedState lockedState;
  final Rect? previewRect;
  final Rect? nameRect;
  final Rect? conditionRect;
  final Rect? storyRect;
  final FishCollectionEmptyState emptyState;
  final VoidCallback onStartFishing;

  @override
  Widget build(BuildContext context) {
    final isUnlocked = selectedDiscovered && fish != null;
    final rarity = isUnlocked ? fish!.rarity : 'locked';
    final rarityColor = _rarityColor(rarity);
    final displayName = isUnlocked ? fish!.name : lockedState.name;
    final displayDescription =
        isUnlocked ? fish!.description : lockedState.description;
    final displayCondition =
        isUnlocked ? fish!.unlockCondition : lockedState.condition;
    final displayImage = isUnlocked ? fish!.icon : lockedState.imageLabel;
    final displayPlaceholder = lockedState.placeholder;

    return Container(
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8D7AB), Color(0xFFF6ECD3)],
        ),
        borderRadius: BorderRadius.circular(28 * scale),
        border: Border.all(color: const Color(0xFFE2C070), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (fish != null)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (previewRect != null)
                    SizedBox(
                      height: previewRect!.height * scale,
                      child: _FishPreviewCard(
                        scale: scale,
                        label: displayImage,
                        rarity: rarity,
                        unlocked: isUnlocked,
                      ),
                    ),
                  SizedBox(height: 14 * scale),
                  if (nameRect != null)
                    _DetailHeader(
                      label: displayName,
                      value: isUnlocked
                          ? labels['detailHeaderUnlocked']?.toString() ?? '已收集'
                          : labels['detailHeaderLocked']?.toString() ?? '未解锁',
                      scale: scale,
                      accent: rarityColor,
                    ),
                  SizedBox(height: 12 * scale),
                  _DetailGrid(
                    scale: scale,
                    accent: rarityColor,
                    entries: [
                      (
                        labels['rarity']?.toString() ?? '品质',
                        isUnlocked
                            ? _rarityName(fish!.rarity)
                            : displayPlaceholder
                      ),
                      (
                        labels['collected']?.toString() ?? '是否收集',
                        isUnlocked ? '已收集' : '未解锁'
                      ),
                      (
                        labels['price']?.toString() ?? '售价',
                        isUnlocked ? '${fish!.price} 摸鱼币' : displayPlaceholder
                      ),
                      (
                        labels['catchCount']?.toString() ?? '获得次数',
                        isUnlocked ? '$catchCount 次' : displayPlaceholder
                      ),
                      (
                        labels['averageWeight']?.toString() ?? '平均重量',
                        isUnlocked
                            ? '${_formatWeight(fish!.averageWeightKg)}kg'
                            : displayPlaceholder
                      ),
                      (
                        labels['maxWeight']?.toString() ?? '最大重量',
                        isUnlocked
                            ? '${_formatWeight(fish!.maxWeightKg)}kg'
                            : displayPlaceholder
                      ),
                      (
                        labels['location']?.toString() ?? '出现地点',
                        isUnlocked ? fish!.location : displayPlaceholder
                      ),
                      (
                        labels['rarityRate']?.toString() ?? '稀有度',
                        isUnlocked ? fish!.rarityRate : displayPlaceholder
                      ),
                      (
                        labels['weatherRequirement']?.toString() ?? '天气要求',
                        isUnlocked
                            ? fish!.weatherRequirement
                            : displayPlaceholder
                      ),
                      (
                        labels['timeRequirement']?.toString() ?? '时间要求',
                        isUnlocked ? fish!.timeRequirement : displayPlaceholder
                      ),
                      (
                        labels['reward']?.toString() ?? '收藏奖励',
                        isUnlocked ? fish!.reward : displayPlaceholder
                      ),
                    ],
                  ),
                  SizedBox(height: 14 * scale),
                  if (conditionRect != null)
                    _CollectionField(
                      label: labels['condition']?.toString() ?? '获得条件',
                      value: displayCondition,
                      scale: scale,
                      accent: rarityColor,
                    ),
                  SizedBox(height: 12 * scale),
                  if (storyRect != null)
                    Expanded(
                      child: _CollectionStoryCard(
                        scale: scale,
                        label: labels['story']?.toString() ?? '故事介绍',
                        story: isUnlocked ? fish!.story : displayDescription,
                        rewardLabel: labels['reward']?.toString() ?? '奖励',
                        rewardValue:
                            isUnlocked ? fish!.reward : displayPlaceholder,
                        accent: rarityColor,
                      ),
                    ),
                ],
              ),
            )
          else
            _CollectionEmptyState(
              emptyState: emptyState,
              scale: scale,
              onStartFishing: onStartFishing,
            ),
        ],
      ),
    );
  }
}

class _FishPreviewCard extends StatelessWidget {
  const _FishPreviewCard({
    required this.scale,
    required this.label,
    required this.rarity,
    required this.unlocked,
  });

  final double scale;
  final String label;
  final String rarity;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final accent = _rarityColor(rarity);
    return Container(
      decoration: BoxDecoration(
        gradient: unlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.98),
                  accent.withValues(alpha: 0.62),
                  const Color(0xFFE9D8AA),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2C3140),
                  Color(0xFF111823),
                  Color(0xFF02060B)
                ],
              ),
        borderRadius: BorderRadius.circular(26 * scale),
        border: Border.all(
          color: unlocked ? const Color(0xFFFFE6A0) : const Color(0xFF62708A),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: unlocked
                ? accent.withValues(alpha: 0.32)
                : Colors.black.withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26 * scale),
                gradient: unlocked
                    ? RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                        radius: 0.85,
                      )
                    : RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                        radius: 0.8,
                      ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: unlocked ? Colors.white : const Color(0xFFD3D8E4),
                    fontSize: 72 * scale,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * scale),
                Text(
                  unlocked ? _rarityName(rarity) : '黑色剪影',
                  style: TextStyle(
                    color: unlocked
                        ? const Color(0xFFFFF1C1)
                        : const Color(0xFF9AA6B8),
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w800,
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

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.label,
    required this.value,
    required this.scale,
    required this.accent,
  });

  final String label;
  final String value;
  final double scale;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.92),
            accent.withValues(alpha: 0.66),
          ],
        ),
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32 * scale,
                fontWeight: FontWeight.w900,
                shadows: const [
                  Shadow(
                      color: Color(0xAA000000),
                      blurRadius: 6,
                      offset: Offset(0, 2))
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 12 * scale, vertical: 8 * scale),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14 * scale),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16 * scale,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({
    required this.scale,
    required this.accent,
    required this.entries,
  });

  final double scale;
  final Color accent;
  final List<(String, String)> entries;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10 * scale,
      runSpacing: 10 * scale,
      children: [
        for (final entry in entries)
          SizedBox(
            width: 162 * scale,
            child: _CollectionField(
              label: entry.$1,
              value: entry.$2,
              scale: scale,
              accent: accent,
            ),
          ),
      ],
    );
  }
}

class _CollectionField extends StatelessWidget {
  const _CollectionField({
    required this.label,
    required this.value,
    required this.scale,
    required this.accent,
  });

  final String label;
  final String value;
  final double scale;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.8),
            Colors.white.withValues(alpha: 0.56),
          ],
        ),
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(color: accent.withValues(alpha: 0.28), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF6E5328),
              fontSize: 14 * scale,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF173D72),
              fontSize: 18 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionStoryCard extends StatelessWidget {
  const _CollectionStoryCard({
    required this.scale,
    required this.label,
    required this.story,
    required this.rewardLabel,
    required this.rewardValue,
    required this.accent,
  });

  final double scale;
  final String label;
  final String story;
  final String rewardLabel;
  final String rewardValue;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8D6AB), Color(0xFFF6EDD6)],
        ),
        borderRadius: BorderRadius.circular(22 * scale),
        border: Border.all(color: accent.withValues(alpha: 0.22), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF184178),
              fontSize: 24 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10 * scale),
          Expanded(
            child: Text(
              story,
              style: TextStyle(
                color: const Color(0xFF5D4724),
                fontSize: 18 * scale,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 10 * scale),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: 14 * scale, vertical: 12 * scale),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.92),
                  accent.withValues(alpha: 0.74),
                ],
              ),
              borderRadius: BorderRadius.circular(18 * scale),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$rewardLabel：$rewardValue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w900,
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
}

class _CollectionEmptyState extends StatelessWidget {
  const _CollectionEmptyState({
    required this.emptyState,
    required this.scale,
    required this.onStartFishing,
  });

  final FishCollectionEmptyState emptyState;
  final double scale;
  final VoidCallback onStartFishing;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9D7AB), Color(0xFFF8EED4)],
        ),
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0xFFE0BF73), width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emptyState.title,
            style: TextStyle(
              fontSize: 72 * scale,
              color: const Color(0xFF184178),
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 16 * scale),
          Text(
            emptyState.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26 * scale,
              height: 1.4,
              color: const Color(0xFF5A4526),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 28 * scale),
          FishingPrimaryButton(
            label: emptyState.buttonLabel,
            onPressed: onStartFishing,
            iconId: 'fish',
          ),
        ],
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  const _TopButton({
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
    return SizedBox(
      width: rect.width * scale,
      height: rect.height * scale,
      child: FishingButtonPressed(
        onPressed: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF2C67AA), Color(0xFF14355E)]),
            borderRadius: BorderRadius.circular(24 * scale),
            border: Border.all(color: const Color(0xFFF5D67A), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28 * scale),
              SizedBox(width: 8 * scale),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20 * scale,
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

Color _rarityColor(String rarity) {
  switch (rarity) {
    case 'common':
      return const Color(0xFFB8B8B8);
    case 'excellent':
      return const Color(0xFF55C66B);
    case 'rare':
      return const Color(0xFF56A6FF);
    case 'epic':
      return const Color(0xFFA86CFF);
    case 'legendary':
      return const Color(0xFFFFA24C);
    case 'mythic':
      return const Color(0xFFFFD35B);
    case 'boss':
      return const Color(0xFFFF5F5F);
    case 'special':
      return const Color(0xFF52D7C8);
    default:
      return const Color(0xFF98A4B8);
  }
}

String _rarityName(String rarity) {
  switch (rarity) {
    case 'common':
      return '普通';
    case 'excellent':
      return '优秀';
    case 'rare':
      return '稀有';
    case 'epic':
      return '史诗';
    case 'legendary':
      return '传说';
    case 'mythic':
      return '神话';
    case 'boss':
      return 'Boss';
    case 'special':
      return '特殊';
    default:
      return '未解锁';
  }
}

String _formatWeight(double value) {
  if (value <= 0) return '0';
  final fixed =
      value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
  return fixed;
}
