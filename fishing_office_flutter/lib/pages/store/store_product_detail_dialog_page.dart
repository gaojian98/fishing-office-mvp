import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/bootstrap/fishing_office_scope.dart';
import '../../core/buttons/fishing_buttons.dart';
import '../../core/icons/fishing_icon.dart';
import '../../models/dialog_config.dart';
import '../../models/store_config.dart';

class StoreProductDetailDialogPage extends StatelessWidget {
  const StoreProductDetailDialogPage({
    super.key,
    required this.product,
    required this.currencyDisplayName,
    required this.owned,
    required this.dialogItem,
    required this.onCancel,
    required this.onBuy,
  });

  final StoreProduct product;
  final String currencyDisplayName;
  final int owned;
  final DialogItem? dialogItem;
  final VoidCallback onCancel;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final scope = FishingOfficeScope.of(context);
    final scale = scope.responsive.scale;
    final screen = MediaQuery.sizeOf(context);
    final width = math.min(screen.width * 0.88, 820 * scale);
    final height = math.min(screen.height * 0.82, 1180 * scale);
    final title =
        dialogItem?.title.isNotEmpty == true ? dialogItem!.title : '商品详情';
    final cancelLabel = _labelAt(dialogItem?.actions, 0, '取消');
    final buyLabel = _labelAt(dialogItem?.actions, 1, '购买');
    final priceText = '$currencyDisplayName ${product.price}';

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32 * scale),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5E0B0), Color(0xFFEACB88), Color(0xFFD0A85B)],
          ),
          border: Border.all(color: const Color(0xFFF6D87A), width: 2.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32 * scale),
          child: Column(
            children: [
              Container(
                height: 100 * scale,
                padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF123564),
                      Color(0xFF255A99),
                      Color(0xFF12305B)
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF4D46A), width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32 * scale,
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
                    FishingIconButton(
                      iconId: FishingIcon.close,
                      semanticLabel: cancelLabel,
                      onPressed: onCancel,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(22 * scale),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: _ProductHeroCard(
                                  product: product, scale: scale),
                            ),
                            SizedBox(width: 18 * scale),
                            Expanded(
                              flex: 6,
                              child: _ProductDetailPanel(
                                product: product,
                                currencyDisplayName: currencyDisplayName,
                                owned: owned,
                                priceText: priceText,
                                scale: scale,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                      Row(
                        children: [
                          Expanded(
                            child: FishingSecondaryButton(
                              label: cancelLabel,
                              onPressed: onCancel,
                            ),
                          ),
                          SizedBox(width: 16 * scale),
                          Expanded(
                            child: FishingPrimaryButton(
                              label: buyLabel,
                              onPressed: onBuy,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _labelAt(List<DialogAction>? actions, int index, String fallback) {
    if (actions == null || actions.length <= index) return fallback;
    final value = actions[index].label.trim();
    return value.isEmpty ? fallback : value;
  }
}

class _ProductHeroCard extends StatelessWidget {
  const _ProductHeroCard({
    required this.product,
    required this.scale,
  });

  final StoreProduct product;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final rarity = _rarityInfo(product.rarity);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26 * scale),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF9EBC8), Color(0xFFE8C57D), Color(0xFFD9AE5D)],
        ),
        border: Border.all(color: rarity.border, width: 2.2),
        boxShadow: [
          BoxShadow(
            color: rarity.border.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20 * scale),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      rarity.iconBgStart,
                      rarity.iconBgEnd,
                      rarity.iconBgStart.withValues(alpha: 0.84),
                    ],
                  ),
                  border: Border.all(
                      color: rarity.border.withValues(alpha: 0.8), width: 1.6),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20 * scale),
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
                    Center(
                      child: _ProductImage(product: product, rarity: rarity),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14 * scale),
            Row(
              children: [
                _QualityPill(label: rarity.label, color: rarity.accent),
                const Spacer(),
                _PriceChip(price: product.price),
              ],
            ),
            SizedBox(height: 10 * scale),
            Text(
              product.name,
              style: TextStyle(
                color: rarity.title,
                fontSize: 28 * scale,
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
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.product,
    required this.rarity,
  });

  final StoreProduct product;
  final _RarityInfo rarity;

  @override
  Widget build(BuildContext context) {
    final iconId = _iconIdForCategory(product.category);
    return Padding(
      padding: const EdgeInsets.all(18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          product.image,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    rarity.accent.withValues(alpha: 0.42),
                    const Color(0xFF103050)
                  ],
                ),
              ),
              child: FishingIconWidget(
                  iconId: iconId, size: 88, color: const Color(0xFFFDF2D2)),
            );
          },
        ),
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
}

class _ProductDetailPanel extends StatelessWidget {
  const _ProductDetailPanel({
    required this.product,
    required this.currencyDisplayName,
    required this.owned,
    required this.priceText,
    required this.scale,
  });

  final StoreProduct product;
  final String currencyDisplayName;
  final int owned;
  final String priceText;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final rarity = _rarityInfo(product.rarity);
    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24 * scale),
        color: const Color(0xFFF9EFD2).withValues(alpha: 0.72),
        border: Border.all(color: const Color(0xFFF6D87A), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            label: '品质',
            value: rarity.label,
            valueColor: rarity.accent,
            scale: scale,
          ),
          SizedBox(height: 12 * scale),
          _InfoRow(
            label: '价格',
            value: priceText,
            valueColor: const Color(0xFFC98A00),
            scale: scale,
            leading: const Icon(Icons.monetization_on_rounded,
                color: Color(0xFFC98A00), size: 20),
          ),
          SizedBox(height: 12 * scale),
          _InfoRow(
            label: '拥有数量',
            value: '$owned',
            valueColor: const Color(0xFF2B4A74),
            scale: scale,
          ),
          SizedBox(height: 20 * scale),
          _SectionTitle(text: '商品说明', scale: scale),
          SizedBox(height: 8 * scale),
          Text(
            product.description,
            style: TextStyle(
              color: const Color(0xFF26415F),
              fontSize: 20 * scale,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 18 * scale),
          _SectionTitle(text: '商品效果', scale: scale),
          SizedBox(height: 8 * scale),
          Text(
            product.effect,
            style: TextStyle(
              color: const Color(0xFF34577E),
              fontSize: 18 * scale,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 18 * scale),
          _SectionTitle(text: '分类', scale: scale),
          SizedBox(height: 8 * scale),
          Text(
            product.category,
            style: TextStyle(
              color: const Color(0xFF6C4A1B),
              fontSize: 18 * scale,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          _AvailabilityBadge(canBuy: product.canBuy, scale: scale),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.scale,
    required this.valueColor,
    this.leading,
  });

  final String label;
  final String value;
  final double scale;
  final Color valueColor;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label：',
          style: TextStyle(
            color: const Color(0xFF5E4523),
            fontSize: 20 * scale,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (leading != null) ...[
          leading!,
          SizedBox(width: 4 * scale),
        ],
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 22 * scale,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.text,
    required this.scale,
  });

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0xFF1D3558),
        fontSize: 22 * scale,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({
    required this.canBuy,
    required this.scale,
  });

  final bool canBuy;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 10 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18 * scale),
        gradient: LinearGradient(
          colors: canBuy
              ? [const Color(0xFF2EB46C), const Color(0xFF1B7B4B)]
              : [const Color(0xFF8D95A4), const Color(0xFF677484)],
        ),
        boxShadow: [
          BoxShadow(
            color: (canBuy ? const Color(0x552EB46C) : const Color(0x55677484)),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        canBuy ? '当前可购买' : '当前不可购买',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18 * scale,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _QualityPill extends StatelessWidget {
  const _QualityPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1.4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.price});

  final int price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1BD),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFC99A16), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_rounded,
              color: Color(0xFFC98A00), size: 18),
          const SizedBox(width: 6),
          Text(
            '$price',
            style: const TextStyle(
              color: Color(0xFFC98A00),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RarityInfo {
  const _RarityInfo({
    required this.label,
    required this.border,
    required this.accent,
    required this.title,
    required this.iconBgStart,
    required this.iconBgEnd,
  });

  final String label;
  final Color border;
  final Color accent;
  final Color title;
  final Color iconBgStart;
  final Color iconBgEnd;
}

_RarityInfo _rarityInfo(String rarity) {
  switch (rarity) {
    case 'rare':
      return const _RarityInfo(
        label: '优秀',
        border: Color(0xFF4CAF50),
        accent: Color(0xFF4CAF50),
        title: Color(0xFF1B5E20),
        iconBgStart: Color(0xFF2E7D32),
        iconBgEnd: Color(0xFF143D22),
      );
    case 'epic':
      return const _RarityInfo(
        label: '史诗',
        border: Color(0xFF7E57C2),
        accent: Color(0xFF7E57C2),
        title: Color(0xFF4A148C),
        iconBgStart: Color(0xFF673AB7),
        iconBgEnd: Color(0xFF26124F),
      );
    case 'legend':
      return const _RarityInfo(
        label: '传说',
        border: Color(0xFFFF9800),
        accent: Color(0xFFFF9800),
        title: Color(0xFF8D4E00),
        iconBgStart: Color(0xFFEF6C00),
        iconBgEnd: Color(0xFF5F2700),
      );
    case 'common':
    default:
      return const _RarityInfo(
        label: '普通',
        border: Color(0xFF90A4AE),
        accent: Color(0xFF78909C),
        title: Color(0xFF37474F),
        iconBgStart: Color(0xFF546E7A),
        iconBgEnd: Color(0xFF1D2D3A),
      );
  }
}
