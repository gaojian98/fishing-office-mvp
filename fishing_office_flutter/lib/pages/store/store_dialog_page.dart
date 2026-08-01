import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/bootstrap/fishing_office_scope.dart';
import '../../core/dialog/dialog_manager.dart';
import '../../core/managers/app_managers.dart';
import '../../core/providers/app_providers.dart';
import '../../models/store_config.dart';
import '../../core/managers/world_clock_manager.dart';

class StoreDialogPage extends ConsumerStatefulWidget {
  const StoreDialogPage({
    super.key,
    required this.dialogManager,
  });

  final DialogManager dialogManager;

  @override
  ConsumerState<StoreDialogPage> createState() => _StoreDialogPageState();
}

class _StoreDialogPageState extends ConsumerState<StoreDialogPage> {
  String _categoryId = 'recommend';

  @override
  Widget build(BuildContext context) {
    final bundleAsync = ref.watch(storeConfigBundleProvider);
    final economyRuntime = ref.watch(economyRuntimeManagerProvider);
    final wallet = ref.watch(walletManagerProvider);
    final inventory = ref.watch(inventoryManagerProvider);

    return bundleAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => _StoreLoadingSurface(
        child: Center(
          child: Text('Store loading failed: $error',
              style: const TextStyle(color: Colors.white)),
        ),
      ),
      data: (bundle) {
        final scope = FishingOfficeScope.of(context);
        final screen = MediaQuery.sizeOf(context);
        final scale = scope.responsive.scale;
        final storeRepository = ref.read(storeRepositoryProvider);
        final categories = storeRepository.getCategories();
        final categoryIds = categories.map((category) => category.id).toSet();
        final effectiveCategoryId =
            categoryIds.contains(_categoryId) || categories.isEmpty
                ? _categoryId
                : categories.first.id;
        final visibleItems = storeRepository.getProducts(
          categoryId: effectiveCategoryId,
        );
        economyRuntime.valueOrNull?.getMarketMultiplier();
        final dialogWidth = math.min(screen.width * 0.88, 1080 * scale);
        final dialogHeight = math.min(screen.height * 0.82, 1920 * scale);

        return SizedBox(
          width: screen.width,
          height: screen.height,
          child: _StoreBackdrop(
            child: Center(
              child: AnimatedScale(
                scale: 1,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    width: dialogWidth,
                    height: dialogHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32 * scale),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF6E0B1),
                          Color(0xFFE7C586),
                          Color(0xFFD7B06E),
                        ],
                      ),
                      border: Border.all(
                          color: const Color(0xFFF5D98D), width: 2.4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 36,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _StoreHeader(
                          title: '🐟 鱼具商店',
                          onClose: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                18 * scale, 16 * scale, 18 * scale, 14 * scale),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _CategoryRail(
                                  categories: categories,
                                  selectedCategoryId: effectiveCategoryId,
                                  onSelected: (id) =>
                                      setState(() => _categoryId = id),
                                ),
                                SizedBox(height: 16 * scale),
                                Expanded(
                                  child: _ProductGrid(
                                    items: visibleItems,
                                    wallet: wallet,
                                    inventory: inventory,
                                    dialogManager: widget.dialogManager,
                                    currencyDisplayName:
                                        bundle.data.currency.displayName,
                                    onRefresh: () => setState(() {}),
                                  ),
                                ),
                                SizedBox(height: 16 * scale),
                                _StoreFooterBar(
                                  walletValue: wallet.fishCoin,
                                  currencyDisplayName:
                                      bundle.data.currency.displayName,
                                  onWallet: () => Navigator.of(context)
                                      .pushNamed('/wallet'),
                                  onBag: () =>
                                      Navigator.of(context).pushNamed('/bag'),
                                  onClose: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        _BottomCoinHint(
                          currencyDisplayName: bundle.data.currency.displayName,
                          value: wallet.fishCoin,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StoreBackdrop extends StatelessWidget {
  const _StoreBackdrop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF08192A),
                Color(0xFF0D2A46),
                Color(0xFF183B5F),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(painter: _StoreGlowPainter()),
        ),
        child,
      ],
    );
  }
}

class _StoreGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 42);
    paint.shader = const RadialGradient(
      colors: [Color(0x55FFD87A), Color(0x00123A63)],
    ).createShader(
        Rect.fromCircle(center: const Offset(540, 346.56), radius: 420));
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.18),
        size.shortestSide * 0.42, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({
    required this.title,
    required this.onClose,
  });

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF143D73), Color(0xFF245C9D), Color(0xFF12305B)],
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFFF4D46A), width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                shadows: [
                  Shadow(
                      color: Color(0xAA000000),
                      blurRadius: 8,
                      offset: Offset(0, 2)),
                ],
              ),
            ),
          ),
          _StoreIconButton(
            label: '关闭',
            icon: Icons.close_rounded,
            onTap: onClose,
            width: 118,
          ),
        ],
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<StoreCategory> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final scale = FishingOfficeScope.of(context).responsive.scale;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in categories) ...[
            _CategoryButton(
              label: category.name,
              selected: category.id == selectedCategoryId,
              onTap: () => onSelected(category.id),
            ),
            SizedBox(width: 12 * scale),
          ],
        ],
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = FishingOfficeScope.of(context).responsive.scale;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 58 * scale,
          padding: EdgeInsets.symmetric(horizontal: 22 * scale),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: selected
                  ? [
                      const Color(0xFF3E8EF1),
                      const Color(0xFF134381),
                      const Color(0xFF0E2B54)
                    ]
                  : [const Color(0xFF183866), const Color(0xFF102A4F)],
            ),
            borderRadius: BorderRadius.circular(18 * scale),
            border: Border.all(
              color:
                  selected ? const Color(0xFFFFE08A) : const Color(0xFF72B0FF),
              width: selected ? 2.4 : 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? const Color(0x88FFE08A)
                    : Colors.black.withValues(alpha: 0.2),
                blurRadius: selected ? 18 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20 * scale,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
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
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.items,
    required this.wallet,
    required this.inventory,
    required this.dialogManager,
    required this.currencyDisplayName,
    required this.onRefresh,
  });

  final List<StoreItem> items;
  final WalletManagerView wallet;
  final InventoryManagerView inventory;
  final DialogManager dialogManager;
  final String currencyDisplayName;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final scale = FishingOfficeScope.of(context).responsive.scale;
    return LayoutBuilder(
      builder: (context, constraints) {
        final displayItems = [...items]
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        final visibleItems = displayItems.take(16).toList(growable: false);
        return GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 2),
          itemCount: 16,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 18 * scale,
            mainAxisSpacing: 18 * scale,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final item =
                index < visibleItems.length ? visibleItems[index] : null;
            final row = index ~/ 4;
            final column = index % 4;
            return _WoodShelfSlot(
              row: row,
              column: column,
              child: item == null
                  ? const _WoodEmptySlot()
                  : _StoreProductCard(
                      item: item,
                      owned: inventory.ownedOf(item.id, fallback: item.owned),
                      canBuy: item.canBuy && item.price <= wallet.fishCoin,
                      currencyDisplayName: currencyDisplayName,
                      onTap: () => dialogManager.openStoreItemDetailDialog(
                        context,
                        item: item,
                        currencyDisplayName: currencyDisplayName,
                        owned: inventory.ownedOf(item.id, fallback: item.owned),
                        onBuy: () => dialogManager.openStoreConfirmDialog(
                          context,
                          item: item,
                          currencyDisplayName: currencyDisplayName,
                          balance: wallet.fishCoin,
                          onConfirm: () => _purchaseItem(
                            context: context,
                            wallet: wallet,
                            inventory: inventory,
                            transactions: ProviderScope.containerOf(context,
                                    listen: false)
                                .read(transactionManagerProvider),
                            dialogManager: dialogManager,
                            item: item,
                            currencyDisplayName: currencyDisplayName,
                          ),
                        ),
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  void _purchaseItem({
    required BuildContext context,
    required WalletManagerView wallet,
    required InventoryManagerView inventory,
    required TransactionManagerView transactions,
    required DialogManager dialogManager,
    required StoreItem item,
    required String currencyDisplayName,
  }) {
    final currentOwned = inventory.ownedOf(item.id, fallback: item.owned);
    if (item.maxOwned > 0 && currentOwned >= item.maxOwned) {
      dialogManager.showPlaceholder(
        context,
        title: '已达上限',
        body: '这件商品已经达到当前可拥有数量上限。',
      );
      return;
    }
    if (wallet.spend(item.price)) {
      inventory.addItem(
        itemId: item.id,
        name: item.name,
        category: item.category,
        rarity: item.rarity,
        icon: item.image,
        description: item.description,
        quantity: 1,
      );
      final owned = inventory.ownedOf(item.id, fallback: item.owned);
      transactions.addRecord(
        TransactionRecord(
          id: 'tx_${WorldClockManager.timestampId()}',
          type: 'purchase',
          currency: 'fish_coin',
          amount: item.price,
          itemId: item.id,
          itemName: item.name,
          createdAt: WorldClockManager.systemNow(),
          category: 'expense',
          note: '购买 ${item.name}',
        ),
      );
      dialogManager.showPurchaseSuccessDialog(
        context,
        item: item,
        currencyDisplayName: currencyDisplayName,
        remainingBalance: wallet.fishCoin,
        owned: owned,
      );
      onRefresh();
      return;
    }
    dialogManager.showInsufficientCoinDialog(
      context,
      currencyDisplayName: currencyDisplayName,
      requiredAmount: item.price,
      currentBalance: wallet.fishCoin,
    );
  }
}

class _WoodShelfSlot extends StatelessWidget {
  const _WoodShelfSlot({
    required this.row,
    required this.column,
    required this.child,
  });

  final int row;
  final int column;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scale = FishingOfficeScope.of(context).responsive.scale;
    final highlight = row.isEven ? 0.12 : 0.06;
    final plankColor =
        row.isEven ? const Color(0xFF9B6B37) : const Color(0xFF7E542A);
    final inset = 6.0 * scale;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFB57A3B),
            plankColor.withValues(alpha: 0.95),
            const Color(0xFF5A3414),
          ],
        ),
        border: Border.all(color: const Color(0xFF533010), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14 + highlight),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(inset),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14 * scale),
                  color: const Color(0xFF3A210D).withValues(alpha: 0.48),
                  border:
                      Border.all(color: const Color(0x99FFF4C8), width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20 * scale),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10 * scale,
            right: 10 * scale,
            top: 8 * scale,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF8E6B6), Color(0xFF8B5B2A)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 10 * scale,
            right: 10 * scale,
            bottom: 8 * scale,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5B2A), Color(0xFF3A220F)],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 10 * scale, vertical: 12 * scale),
            child: child,
          ),
          Positioned(
            right: 8 * scale,
            top: 8 * scale,
            child: Text(
              '${row + 1}${column + 1}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.12),
                fontSize: 10 * scale,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WoodEmptySlot extends StatelessWidget {
  const _WoodEmptySlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x55FBE39B), width: 1),
        color: const Color(0x33FFF6E0),
      ),
      child: const Center(
        child: Text(
          '空',
          style: TextStyle(
            color: Color(0x99FFF8D8),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _StoreProductCard extends StatelessWidget {
  const _StoreProductCard({
    required this.item,
    required this.owned,
    required this.canBuy,
    required this.currencyDisplayName,
    required this.onTap,
  });

  final StoreItem item;
  final int owned;
  final bool canBuy;
  final String currencyDisplayName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = FishingOfficeScope.of(context).responsive.scale;
    final rarity = _rarityInfo(item.rarity);
    final priceText = item.price.toString();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8E9C5), Color(0xFFE7C78B), Color(0xFFD7B06A)],
          ),
          borderRadius: BorderRadius.circular(26 * scale),
          border: Border.all(
            color: rarity.border,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: EdgeInsets.all(10 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18 * scale),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      rarity.iconBgStart,
                      rarity.iconBgEnd,
                      rarity.iconBgStart.withValues(alpha: 0.85),
                    ],
                  ),
                  border: Border.all(
                      color: rarity.border.withValues(alpha: 0.85), width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: rarity.border.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18 * scale),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.16),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.08),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10 * scale,
                      left: 10 * scale,
                      child: _RarityStars(text: rarity.stars),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StoreItemEmblem(
                            imagePath: item.image,
                            category: item.category,
                            color: rarity.accent,
                          ),
                          SizedBox(height: 10 * scale),
                          Text(
                            item.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: rarity.title,
                              fontSize: 22 * scale,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                              shadows: const [
                                Shadow(
                                    color: Color(0x66FFFFFF),
                                    blurRadius: 2,
                                    offset: Offset(0, 1)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12 * scale),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  rarity.label,
                  style: TextStyle(
                    color: rarity.accent,
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '×$owned',
                  style: TextStyle(
                    color: const Color(0xFF6A4A1F),
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10 * scale),
            Row(
              children: [
                Container(
                  width: 26 * scale,
                  height: 26 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFFFF2B8),
                        Color(0xFFFFBA3C),
                        Color(0xFFF08A12)
                      ],
                    ),
                    border:
                        Border.all(color: const Color(0xFF9A6500), width: 1.1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66D18A00),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.monetization_on_rounded,
                      size: 16, color: Color(0xFF8A5B00)),
                ),
                SizedBox(width: 8 * scale),
                Text(
                  priceText,
                  style: TextStyle(
                    color: const Color(0xFFC28900),
                    fontSize: 24 * scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  '摸鱼币',
                  style: TextStyle(
                    color: const Color(0xFF8D651F),
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10 * scale),
            if (item.maxOwned > 0 && owned >= item.maxOwned)
              const _OwnedPill(text: '已达上限')
            else if (canBuy)
              _BuyButton(label: '购买', onTap: onTap)
            else
              const _OwnedPill(text: '暂不可购'),
          ],
        ),
      ),
    );
  }
}

class _StoreItemEmblem extends StatelessWidget {
  const _StoreItemEmblem({
    required this.imagePath,
    required this.category,
    required this.color,
  });

  final String imagePath;
  final String category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.45), const Color(0xFF0F2746)],
        ),
        border: Border.all(color: const Color(0xFFFBE39B), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            _iconFor(_iconIdForCategory(category)),
            color: const Color(0xFFFDF4D2),
            size: 40,
          );
        },
      ),
    );
  }

  String _iconIdForCategory(String category) {
    switch (category) {
      case 'rod':
        return 'icon_rod';
      case 'line':
        return 'icon_line';
      case 'float':
        return 'icon_float';
      case 'bait':
        return 'icon_bait';
      case 'tool':
        return 'icon_tool';
      case 'decoration':
        return 'icon_decoration';
      default:
        return 'icon_bucket';
    }
  }

  IconData _iconFor(String id) {
    switch (id) {
      case 'icon_rod':
        return Icons.straight_rounded;
      case 'icon_line':
        return Icons.linear_scale_rounded;
      case 'icon_float':
        return Icons.water_rounded;
      case 'icon_bait':
        return Icons.set_meal_rounded;
      case 'icon_tool':
        return Icons.handyman_rounded;
      case 'icon_bucket':
        return Icons.inventory_2_rounded;
      case 'icon_decoration':
        return Icons.park_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }
}

class _BuyButton extends StatelessWidget {
  const _BuyButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = FishingOfficeScope.of(context).responsive.scale;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 48 * scale,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFCF54), Color(0xFFE48B15), Color(0xFFB96A0B)],
          ),
          borderRadius: BorderRadius.circular(18 * scale),
          border: Border.all(color: const Color(0xFFFFF0B0), width: 1.4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x88C77A00),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18 * scale,
              fontWeight: FontWeight.w900,
              shadows: const [
                Shadow(
                    color: Color(0x99000000),
                    blurRadius: 4,
                    offset: Offset(0, 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OwnedPill extends StatelessWidget {
  const _OwnedPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scale = FishingOfficeScope.of(context).responsive.scale;
    return Container(
      height: 48 * scale,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF4A5C73), Color(0xFF25364A)]),
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(color: const Color(0xFFA8C8FF), width: 1.2),
      ),
      child: Center(
        child: Text(
          text,
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

class _RarityStars extends StatelessWidget {
  const _RarityStars({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFFFE38A),
        fontSize: 15,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
        shadows: [
          Shadow(color: Color(0xB0000000), blurRadius: 3, offset: Offset(0, 1))
        ],
      ),
    );
  }
}

class _StoreFooterBar extends StatelessWidget {
  const _StoreFooterBar({
    required this.walletValue,
    required this.currencyDisplayName,
    required this.onWallet,
    required this.onBag,
    required this.onClose,
  });

  final int walletValue;
  final String currencyDisplayName;
  final VoidCallback onWallet;
  final VoidCallback onBag;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final scale = FishingOfficeScope.of(context).responsive.scale;
    return Row(
      children: [
        Expanded(
          child: _StoreFooterPanel(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on_rounded,
                    color: Color(0xFFFFD66B), size: 24),
                SizedBox(width: 8 * scale),
                Text(
                  '$currencyDisplayName $walletValue',
                  style: TextStyle(
                    color: const Color(0xFF1D355A),
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 14 * scale),
        Expanded(
          child: _FooterBlueButton(
              label: '背包', icon: Icons.backpack_rounded, onTap: onBag),
        ),
        SizedBox(width: 14 * scale),
        Expanded(
          child: _FooterBlueButton(
              label: '钱包',
              icon: Icons.account_balance_wallet_rounded,
              onTap: onWallet),
        ),
        SizedBox(width: 14 * scale),
        Expanded(
          child: _FooterBlueButton(
              label: '关闭', icon: Icons.close_rounded, onTap: onClose),
        ),
      ],
    );
  }
}

class _StoreFooterPanel extends StatelessWidget {
  const _StoreFooterPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scale = FishingOfficeScope.of(context).responsive.scale;
    return Container(
      height: 70 * scale,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFF5DE9F), Color(0xFFE9C979)]),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: const Color(0xFFF3D77F), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FooterBlueButton extends StatelessWidget {
  const _FooterBlueButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = FishingOfficeScope.of(context).responsive.scale;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70 * scale,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF2F77D0), Color(0xFF133C72)]),
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(color: const Color(0xFFF9D66D), width: 1.8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFFFE08C), size: 22 * scale),
            SizedBox(height: 2 * scale),
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

class _BottomCoinHint extends StatelessWidget {
  const _BottomCoinHint({
    required this.currencyDisplayName,
    required this.value,
  });

  final String currencyDisplayName;
  final int value;

  @override
  Widget build(BuildContext context) {
    final scale = FishingOfficeScope.of(context).responsive.scale;
    return Padding(
      padding: EdgeInsets.only(bottom: 4 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.monetization_on_rounded,
              color: Color(0xFFFFD66B), size: 18),
          const SizedBox(width: 6),
          Text(
            '$currencyDisplayName $value',
            style: TextStyle(
              color: const Color(0xFF1D355A),
              fontSize: 14 * scale,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreLoadingSurface extends StatelessWidget {
  const _StoreLoadingSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF08192A), Color(0xFF183B5F)],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _StoreIconButton extends StatelessWidget {
  const _StoreIconButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.width,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF3C84D7), Color(0xFF123761)]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF9D66D), width: 1.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFFFE08C), size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _RarityStyle {
  const _RarityStyle({
    required this.label,
    required this.stars,
    required this.title,
    required this.accent,
    required this.border,
    required this.iconBgStart,
    required this.iconBgEnd,
  });

  final String label;
  final String stars;
  final Color title;
  final Color accent;
  final Color border;
  final Color iconBgStart;
  final Color iconBgEnd;
}

_RarityStyle _rarityInfo(String rarity) {
  switch (rarity) {
    case 'common':
      return const _RarityStyle(
        label: '普通',
        stars: '★',
        title: Color(0xFF6F7782),
        accent: Color(0xFF6F7782),
        border: Color(0xFF98A2B3),
        iconBgStart: Color(0xFFE5ECF6),
        iconBgEnd: Color(0xFFC8D5E4),
      );
    case 'rare':
      return const _RarityStyle(
        label: '稀有',
        stars: '★★',
        title: Color(0xFF2B6DD8),
        accent: Color(0xFF2B6DD8),
        border: Color(0xFF4F86E6),
        iconBgStart: Color(0xFFDBE9FF),
        iconBgEnd: Color(0xFFADC8FF),
      );
    case 'epic':
      return const _RarityStyle(
        label: '史诗',
        stars: '★★★',
        title: Color(0xFF7C49D7),
        accent: Color(0xFF7C49D7),
        border: Color(0xFFA86DF1),
        iconBgStart: Color(0xFFE7D8FF),
        iconBgEnd: Color(0xFFC7A7FF),
      );
    case 'legend':
      return const _RarityStyle(
        label: '传说',
        stars: '★★★★★',
        title: Color(0xFFFF8A00),
        accent: Color(0xFFFF8A00),
        border: Color(0xFFFFB040),
        iconBgStart: Color(0xFFFFE2B4),
        iconBgEnd: Color(0xFFFFC34D),
      );
    default:
      return const _RarityStyle(
        label: '优秀',
        stars: '★★',
        title: Color(0xFF33935E),
        accent: Color(0xFF33935E),
        border: Color(0xFF53B67A),
        iconBgStart: Color(0xFFDDF7E7),
        iconBgEnd: Color(0xFFB2E8C4),
      );
  }
}
