import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/bootstrap/fishing_office_scope.dart';
import '../../core/dialog/dialog_manager.dart';
import '../../core/managers/app_managers.dart';
import '../../core/providers/app_providers.dart';
import '../../models/inventory_config.dart';
import '../../models/layout_config.dart';

class InventoryDialogPage extends ConsumerStatefulWidget {
  const InventoryDialogPage({
    super.key,
    required this.inventory,
    required this.layout,
    required this.dialogManager,
  });

  final InventoryConfig inventory;
  final LayoutConfig layout;
  final DialogManager dialogManager;

  @override
  ConsumerState<InventoryDialogPage> createState() =>
      _InventoryDialogPageState();
}

class _InventoryDialogPageState extends ConsumerState<InventoryDialogPage> {
  String _categoryId = 'all';
  int _pageIndex = 0;
  String? _selectedItemId;

  @override
  Widget build(BuildContext context) {
    final scope = FishingOfficeScope.of(context);
    final scale = scope.responsive.scale;
    final screen = MediaQuery.sizeOf(context);
    final dialog = widget.layout.byId('inventory_dialog');
    final header = widget.layout.byId('inventory_header');
    final title = widget.layout.byId('inventory_title');
    final close = widget.layout.byId('inventory_close');
    final capacity = widget.layout.byId('inventory_capacity');
    final organize = widget.layout.byId('inventory_organize');
    final filter = widget.layout.byId('inventory_filter');
    final categories = widget.layout.byId('inventory_categories');
    final grid = widget.layout.byId('inventory_grid');
    final footer = widget.layout.byId('inventory_footer');
    final footerClose = widget.layout.byId('inventory_close_bottom');
    final empty = widget.layout.byId('inventory_empty');
    final detailPanel = widget.layout.byId('inventory_detail');

    final inventoryState = ref.watch(inventoryManagerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(inventoryManagerProvider)
            .ensureCatalogLoaded(widget.inventory);
      }
    });
    final filteredItems = _buildVisibleItems(
      inventoryState,
      inventory: widget.inventory,
      categoryId: _categoryId,
    );
    final pageCount =
        filteredItems.isEmpty ? 1 : ((filteredItems.length - 1) ~/ 16) + 1;
    if (_pageIndex >= pageCount) _pageIndex = pageCount - 1;
    final currentPageItems = filteredItems.isEmpty
        ? <_InventoryItemViewModel>[]
        : filteredItems.skip(_pageIndex * 16).take(16).toList(growable: false);
    final selectedItem = _selectedItemId == null
        ? null
        : currentPageItems.firstWhere(
            (item) => item.entry.itemId == _selectedItemId,
            orElse: () => currentPageItems.isNotEmpty
                ? currentPageItems.first
                : const _InventoryItemViewModel.empty(),
          );
    final width =
        (dialog?.rect.width ?? math.min(screen.width * 0.92, 1080)) * scale;
    final height =
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
                    Color(0xE6192E43),
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
                      Color(0xFFF6E1B8),
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
                              Color(0xFF163E74),
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
                                  widget.inventory.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 34 * scale,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            if (close != null)
                              _InventoryTopButton(
                                rect: close.rect,
                                scale: scale,
                                label: widget.inventory.footer['closeLabel']
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
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (capacity != null)
                                  _InventoryCapacityBar(
                                    rect: capacity.rect,
                                    scale: scale,
                                    inventory: widget.inventory,
                                    current: inventoryState.entries.fold<int>(0,
                                        (sum, entry) => sum + entry.quantity),
                                  ),
                                SizedBox(height: 14 * scale),
                                if (organize != null || filter != null)
                                  Row(
                                    children: [
                                      if (organize != null)
                                        Expanded(
                                          child: _InventoryActionButton(
                                            label: widget.inventory.capacity
                                                .organizeLabel,
                                            scale: scale,
                                            onTap: () => setState(() {
                                              _pageIndex = 0;
                                              _selectedItemId = null;
                                            }),
                                          ),
                                        ),
                                      if (organize != null && filter != null)
                                        SizedBox(width: 12 * scale),
                                      if (filter != null)
                                        Expanded(
                                          child: _InventoryActionButton(
                                            label: widget
                                                .inventory.capacity.filterLabel,
                                            scale: scale,
                                            onTap: () =>
                                                _showFilterMenu(context),
                                          ),
                                        ),
                                    ],
                                  ),
                                SizedBox(height: 14 * scale),
                                if (categories != null)
                                  SizedBox(
                                    height: categories.rect.height * scale,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          widget.inventory.categories.length,
                                      separatorBuilder: (_, __) =>
                                          SizedBox(width: 10 * scale),
                                      itemBuilder: (context, index) {
                                        final category =
                                            widget.inventory.categories[index];
                                        final selected =
                                            category.id == _categoryId;
                                        return _InventoryCategoryChip(
                                          label: category.label,
                                          selected: selected,
                                          scale: scale,
                                          onTap: () => setState(() {
                                            _categoryId = category.id;
                                            _pageIndex = 0;
                                            _selectedItemId = null;
                                          }),
                                        );
                                      },
                                    ),
                                  ),
                                SizedBox(height: 14 * scale),
                                if (grid != null)
                                  Expanded(
                                    child: currentPageItems.isEmpty
                                        ? _InventoryEmptyState(
                                            rect: empty?.rect,
                                            scale: scale,
                                            emptyState:
                                                widget.inventory.emptyState,
                                          )
                                        : _InventoryGrid(
                                            rect: grid.rect,
                                            scale: scale,
                                            items: currentPageItems,
                                            selectedItemId: _selectedItemId,
                                            onSelected: (itemId) => setState(
                                                () => _selectedItemId = itemId),
                                            onPage: (delta) => setState(() {
                                              final next = _pageIndex + delta;
                                              if (next >= 0 &&
                                                  next < pageCount) {
                                                _pageIndex = next;
                                                _selectedItemId = null;
                                              }
                                            }),
                                            pageIndex: _pageIndex,
                                            pageCount: pageCount,
                                            inventory: widget.inventory,
                                          ),
                                  ),
                                SizedBox(height: 12 * scale),
                                if (footer != null)
                                  _InventoryFooter(
                                    rect: footer.rect,
                                    scale: scale,
                                    sellLabel: widget
                                            .inventory.footer['sellLabel']
                                            ?.toString() ??
                                        '出售',
                                    useLabel: widget
                                            .inventory.footer['useLabel']
                                            ?.toString() ??
                                        '使用',
                                    closeLabel: footerClose?.label ??
                                        widget.inventory.footer['closeLabel']
                                            ?.toString() ??
                                        '关闭',
                                    onSell: selectedItem == null
                                        ? null
                                        : () => _sellItem(selectedItem),
                                    onUse: selectedItem == null
                                        ? null
                                        : () => _useItem(selectedItem),
                                    onClose: () => Navigator.of(context).pop(),
                                  ),
                              ],
                            ),
                            if (selectedItem != null && detailPanel != null)
                              Positioned(
                                right: 0,
                                top: 12 * scale,
                                bottom: 12 * scale,
                                width: detailPanel.rect.width * scale,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 180),
                                  opacity: 1,
                                  child: _InventoryDetailPanel(
                                    item: selectedItem,
                                    inventory: widget.inventory,
                                    scale: scale,
                                    onClose: () =>
                                        setState(() => _selectedItemId = null),
                                    onUse: () => _useItem(selectedItem),
                                    onSell: () => _sellItem(selectedItem),
                                    onRelease: () => _releaseFish(selectedItem),
                                  ),
                                ),
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

  List<_InventoryItemViewModel> _buildVisibleItems(
    InventoryManagerView inventoryState, {
    required InventoryConfig inventory,
    required String categoryId,
  }) {
    final result = <_InventoryItemViewModel>[];
    for (final entry
        in inventoryState.sortedEntries(inventory, category: categoryId)) {
      final catalog = inventory.itemById(entry.itemId);
      final meta = catalog ??
          InventoryCatalogItem(
            id: entry.itemId,
            name: entry.name,
            category: entry.category,
            rarity: entry.rarity,
            icon: entry.icon,
            description: entry.description,
            usage: '',
            obtainSource: '',
            sellPrice: 0,
            canUse: true,
            canSell: true,
            badge: '',
            initialQuantity: 0,
            sortOrder: 999,
            attributes: {},
          );
      result.add(_InventoryItemViewModel(
        entry: entry,
        catalog: meta,
      ));
    }
    return result;
  }

  void _showFilterMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(140, 220, 0, 0),
      items: [
        for (final category in widget.inventory.categories)
          PopupMenuItem<String>(
            value: category.id,
            child: Text(category.label),
          ),
      ],
    ).then((value) {
      if (value == null) return;
      setState(() {
        _categoryId = value;
        _pageIndex = 0;
        _selectedItemId = null;
      });
    });
  }

  void _sellItem(_InventoryItemViewModel item) {
    final success = ref.read(inventoryManagerProvider).sellItem(
          item: item.catalog,
          wallet: ref.read(walletManagerProvider),
          transactions: ref.read(transactionManagerProvider),
        );
    setState(() => _selectedItemId = null);
    widget.dialogManager.showPlaceholder(
      context,
      title: success ? '出售成功' : '无法出售',
      body: success
          ? '${item.catalog.name} 已换成 ${item.catalog.sellPrice} 摸鱼币。'
          : '这个物品暂时不能出售。',
    );
  }

  void _releaseFish(_InventoryItemViewModel item) {
    final success =
        ref.read(inventoryManagerProvider).releaseFish(item.catalog);
    setState(() => _selectedItemId = null);
    widget.dialogManager.showPlaceholder(
      context,
      title: success ? '已经放生' : '无法放生',
      body: success ? '${item.catalog.name} 回到了海里。' : '只有鱼类可以放生。',
    );
  }

  void _useItem(_InventoryItemViewModel item) {
    final category = item.catalog.category;
    if (category == 'fish') {
      widget.dialogManager.showPlaceholder(
        context,
        title: '作为鱼饵',
        body: '作为鱼饵功能已预留，后续会接入鱼链。',
      );
      return;
    }
    if (category == 'gear') {
      final attributes = item.catalog.attributes.entries
          .map((entry) => '${entry.key}：${entry.value}')
          .join('\n');
      widget.dialogManager.showPlaceholder(
        context,
        title: '渔具属性',
        body: attributes.isEmpty ? item.catalog.usage : attributes,
      );
      return;
    }
    widget.dialogManager.showPlaceholder(
      context,
      title: widget.inventory.detail['useTitle']?.toString() ?? '使用物品',
      body: item.catalog.usage.isEmpty ? '该物品暂时只能查看。' : item.catalog.usage,
    );
  }
}

class _InventoryItemViewModel {
  const _InventoryItemViewModel({
    required this.entry,
    required this.catalog,
  });

  const _InventoryItemViewModel.empty()
      : entry = const InventoryEntry(
          itemId: '',
          name: '',
          category: '',
          rarity: 'common',
          icon: '📦',
          description: '',
          quantity: 0,
        ),
        catalog = const InventoryCatalogItem(
          id: '',
          name: '',
          category: '',
          rarity: 'common',
          icon: '📦',
          description: '',
          usage: '',
          obtainSource: '',
          sellPrice: 0,
          canUse: false,
          canSell: false,
          badge: '',
          initialQuantity: 0,
          sortOrder: 999,
          attributes: {},
        );

  final InventoryEntry entry;
  final InventoryCatalogItem catalog;
}

class _InventoryCapacityBar extends StatelessWidget {
  const _InventoryCapacityBar({
    required this.rect,
    required this.scale,
    required this.inventory,
    required this.current,
  });

  final Rect rect;
  final double scale;
  final InventoryConfig inventory;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: rect.width * scale,
      height: rect.height * scale,
      padding:
          EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24 * scale),
        gradient: const LinearGradient(
          colors: [Color(0xFFF4E2BB), Color(0xFFE4C37C), Color(0xFFD0A24F)],
        ),
        border: Border.all(color: const Color(0xFFF7DE95), width: 1.6),
      ),
      child: Row(
        children: [
          Text(
            '${inventory.capacity.currentLabel}：',
            style: TextStyle(
              color: const Color(0xFF4A3112),
              fontSize: 18 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '$current / ${inventory.capacity.maxLabel}',
            style: TextStyle(
              color: const Color(0xFF183C6B),
              fontSize: 22 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryActionButton extends StatelessWidget {
  const _InventoryActionButton({
    required this.label,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        height: 72 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22 * scale),
          gradient: const LinearGradient(
              colors: [Color(0xFF3B86DB), Color(0xFF18426F)]),
          border: Border.all(color: const Color(0xFFF7D77B), width: 1.8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _InventoryCategoryChip extends StatelessWidget {
  const _InventoryCategoryChip({
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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding:
            EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 12 * scale),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20 * scale),
          gradient: selected
              ? const LinearGradient(colors: [
                  Color(0xFFFFD86B),
                  Color(0xFFE08D19),
                  Color(0xFFB56708)
                ])
              : const LinearGradient(
                  colors: [Color(0xFF21426F), Color(0xFF122744)]),
          border: Border.all(
            color: selected ? const Color(0xFFFFF0AA) : const Color(0xFFF7D77B),
            width: 1.4,
          ),
          boxShadow: [
            if (selected)
              const BoxShadow(
                color: Color(0x55FFD86B),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16 * scale,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _InventoryGrid extends StatelessWidget {
  const _InventoryGrid({
    required this.rect,
    required this.scale,
    required this.items,
    required this.selectedItemId,
    required this.onSelected,
    required this.onPage,
    required this.pageIndex,
    required this.pageCount,
    required this.inventory,
  });

  final Rect rect;
  final double scale;
  final List<_InventoryItemViewModel> items;
  final String? selectedItemId;
  final ValueChanged<String> onSelected;
  final ValueChanged<int> onPage;
  final int pageIndex;
  final int pageCount;
  final InventoryConfig inventory;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 16,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) {
            final item = index < items.length ? items[index] : null;
            return _InventorySlotCard(
              item: item,
              scale: scale,
              selected: item != null && item.entry.itemId == selectedItemId,
              onTap: item == null ? null : () => onSelected(item.entry.itemId),
            );
          },
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Row(
            children: [
              _InventoryPageButton(
                label: '上一页',
                enabled: pageIndex > 0,
                scale: scale,
                onTap: () => onPage(-1),
              ),
              SizedBox(width: 10 * scale),
              Text(
                '${pageIndex + 1} / $pageCount',
                style: TextStyle(
                  color: const Color(0xFF4A3112),
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 10 * scale),
              _InventoryPageButton(
                label: '下一页',
                enabled: pageIndex < pageCount - 1,
                scale: scale,
                onTap: () => onPage(1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InventorySlotCard extends StatelessWidget {
  const _InventorySlotCard({
    required this.item,
    required this.scale,
    required this.selected,
    required this.onTap,
  });

  final _InventoryItemViewModel? item;
  final double scale;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final present = item != null;
    final name = item?.catalog.name ?? '';
    final icon = item?.catalog.icon ?? '📦';
    final rarity = _rarityLabel(item?.catalog.rarity ?? 'common');
    final badge = item?.catalog.badge.isNotEmpty == true
        ? item!.catalog.badge
        : (present ? '' : '');
    final colors = _rarityColors(item?.catalog.rarity ?? 'common');
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20 * scale),
          gradient: LinearGradient(colors: colors),
          border: Border.all(
            color: selected ? const Color(0xFFFFE38A) : const Color(0xFFF6DD8B),
            width: selected ? 2.4 : 1.2,
          ),
          boxShadow: [
            if (selected)
              const BoxShadow(
                color: Color(0x55FFD86B),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
          ],
        ),
        padding: EdgeInsets.all(8 * scale),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(icon, style: TextStyle(fontSize: 28 * scale)),
                  SizedBox(height: 8 * scale),
                  Text(
                    name.isEmpty ? '空格' : name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    'x${item?.entry.quantity ?? 0}',
                    style: TextStyle(
                      color: const Color(0xFFFFE08C),
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            if (badge.isNotEmpty)
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale, vertical: 4 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD86B),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18 * scale),
                      bottomRight: Radius.circular(12 * scale),
                    ),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: const Color(0xFF5A3A15),
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Text(
                rarity,
                style: TextStyle(
                  color: const Color(0xFFFDE8A4),
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryPageButton extends StatelessWidget {
  const _InventoryPageButton({
    required this.label,
    required this.enabled,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: enabled ? onTap : null,
        child: Container(
          padding:
              EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16 * scale),
            gradient: const LinearGradient(
                colors: [Color(0xFF3B86DB), Color(0xFF18426F)]),
            border: Border.all(color: const Color(0xFFF7D77B), width: 1.4),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _InventoryEmptyState extends StatelessWidget {
  const _InventoryEmptyState({
    required this.rect,
    required this.scale,
    required this.emptyState,
  });

  final Rect? rect;
  final double scale;
  final Map<String, dynamic> emptyState;

  @override
  Widget build(BuildContext context) {
    final title = '${emptyState['title'] ?? '📦'}';
    final message = '${emptyState['message'] ?? '你的背包还是空的。\n快去海边钓第一条鱼吧。'}';
    final buttonLabel = '${emptyState['buttonLabel'] ?? '开始钓鱼'}';
    final width = (rect?.width ?? 620) * scale;
    final height = (rect?.height ?? 660) * scale;
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26 * scale),
          gradient: const LinearGradient(
            colors: [Color(0xFFF5E4C4), Color(0xFFE8D29A), Color(0xFFD6AF64)],
          ),
          border: Border.all(color: const Color(0xFFF6DD8B), width: 1.6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 76 * scale)),
            SizedBox(height: 18 * scale),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF5A3A15),
                fontSize: 22 * scale,
                height: 1.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 22 * scale),
            _InventoryActionButton(
              label: buttonLabel,
              scale: scale,
              onTap: () => Navigator.of(context).pushNamed('/fishing'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryDetailPanel extends StatelessWidget {
  const _InventoryDetailPanel({
    required this.item,
    required this.inventory,
    required this.scale,
    required this.onClose,
    required this.onUse,
    required this.onSell,
    required this.onRelease,
  });

  final _InventoryItemViewModel item;
  final InventoryConfig inventory;
  final double scale;
  final VoidCallback onClose;
  final VoidCallback onUse;
  final VoidCallback onSell;
  final VoidCallback onRelease;

  @override
  Widget build(BuildContext context) {
    final detail = inventory.detail;
    final hasSell = item.catalog.canSell;
    final hasUse = item.catalog.canUse;
    final isFish = item.catalog.category == 'fish';
    final isGear = item.catalog.category == 'gear';
    final useLabel = isFish
        ? '作为鱼饵'
        : isGear
            ? '查看属性'
            : detail['useButtonLabel']?.toString() ?? '使用';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28 * scale),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4E7C6), Color(0xFFE2C383), Color(0xFFC99649)],
        ),
        border: Border.all(color: const Color(0xFFF7DE95), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(18 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.catalog.name,
                  style: TextStyle(
                    color: const Color(0xFF4A3112),
                    fontSize: 28 * scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _InventoryPageButton(
                  label: detail['closeLabel']?.toString() ?? '关闭',
                  enabled: true,
                  scale: scale,
                  onTap: onClose),
            ],
          ),
          SizedBox(height: 14 * scale),
          Text(item.catalog.icon, style: TextStyle(fontSize: 42 * scale)),
          SizedBox(height: 12 * scale),
          _detailRow(detail['rarityLabel']?.toString() ?? '品质',
              _rarityLabel(item.catalog.rarity), scale),
          SizedBox(height: 10 * scale),
          _detailRow(detail['descriptionLabel']?.toString() ?? '介绍',
              item.catalog.description, scale),
          SizedBox(height: 10 * scale),
          _detailRow(detail['usageLabel']?.toString() ?? '用途',
              item.catalog.usage, scale),
          SizedBox(height: 10 * scale),
          _detailRow(detail['quantityLabel']?.toString() ?? '数量',
              'x${item.entry.quantity}', scale),
          SizedBox(height: 10 * scale),
          _detailRow(detail['sourceLabel']?.toString() ?? '获得来源',
              item.catalog.obtainSource, scale),
          SizedBox(height: 10 * scale),
          _detailRow(detail['priceLabel']?.toString() ?? '出售价格',
              '${item.catalog.sellPrice}', scale),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _InventoryActionButton(
                  label: hasUse
                      ? useLabel
                      : detail['useDisabledLabel']?.toString() ?? '不可使用',
                  scale: scale,
                  onTap: hasUse ? onUse : onClose,
                ),
              ),
              SizedBox(width: 12 * scale),
              if (isFish) ...[
                Expanded(
                  child: _InventoryActionButton(
                    label: '放生',
                    scale: scale,
                    onTap: onRelease,
                  ),
                ),
                SizedBox(width: 12 * scale),
              ],
              Expanded(
                child: _InventoryActionButton(
                  label: hasSell
                      ? detail['sellButtonLabel']?.toString() ?? '出售'
                      : detail['sellDisabledLabel']?.toString() ?? '不可出售',
                  scale: scale,
                  onTap: hasSell ? onSell : onClose,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, double scale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96 * scale,
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF4A3112),
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
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _InventoryFooter extends StatelessWidget {
  const _InventoryFooter({
    required this.rect,
    required this.scale,
    required this.sellLabel,
    required this.useLabel,
    required this.closeLabel,
    required this.onSell,
    required this.onUse,
    required this.onClose,
  });

  final Rect rect;
  final double scale;
  final String sellLabel;
  final String useLabel;
  final String closeLabel;
  final VoidCallback? onSell;
  final VoidCallback? onUse;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: rect.width * scale,
      child: Row(
        children: [
          Expanded(
            child: _InventoryActionButton(
              label: sellLabel,
              scale: scale,
              onTap: onSell ?? () {},
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: _InventoryActionButton(
              label: useLabel,
              scale: scale,
              onTap: onUse ?? () {},
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: _InventoryActionButton(
              label: closeLabel,
              scale: scale,
              onTap: onClose,
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryTopButton extends StatelessWidget {
  const _InventoryTopButton({
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

List<Color> _rarityColors(String rarity) {
  switch (rarity) {
    case 'uncommon':
      return const [Color(0xFFBCF29A), Color(0xFF4CA95D), Color(0xFF245A31)];
    case 'rare':
      return const [Color(0xFFB9D7FF), Color(0xFF4A85DA), Color(0xFF203E73)];
    case 'epic':
      return const [Color(0xFFE2C0FF), Color(0xFF9D65E7), Color(0xFF4A257B)];
    case 'legend':
      return const [Color(0xFFFFDC9A), Color(0xFFFFA03B), Color(0xFF8A4510)];
    case 'mythic':
      return const [Color(0xFFFFF0A8), Color(0xFFE8C83F), Color(0xFF916B09)];
    default:
      return const [Color(0xFFEAEAEA), Color(0xFFB8B8B8), Color(0xFF747474)];
  }
}

String _rarityLabel(String rarity) {
  switch (rarity) {
    case 'uncommon':
      return '优秀';
    case 'rare':
      return '稀有';
    case 'epic':
      return '史诗';
    case 'legend':
      return '传说';
    case 'mythic':
      return '神话';
    default:
      return '普通';
  }
}
