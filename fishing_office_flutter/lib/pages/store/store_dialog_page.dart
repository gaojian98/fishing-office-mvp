import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_color.dart';
import '../../core/app_typography.dart';
import '../../core/buttons/fishing_buttons.dart';
import '../../core/dialog/dialog_manager.dart';
import '../../core/bootstrap/fishing_office_scope.dart';
import '../../core/managers/app_managers.dart';
import '../../core/providers/app_providers.dart';
import '../../models/store_config.dart';

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
    final wallet = ref.watch(walletManagerProvider);
    final inventory = ref.watch(inventoryManagerProvider);
    final transactions = ref.watch(transactionManagerProvider);

    return bundleAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => Material(
        color: Colors.black54,
        child: Center(child: Text('Store loading failed: $error')),
      ),
      data: (bundle) {
        final scope = FishingOfficeScope.of(context);
        final scale = scope.responsive.scale;
        final categories = bundle.data.categories;
        final visibleItems = _categoryId == 'recommend'
            ? bundle.data.items
            : bundle.data.items.where((item) => item.category == _categoryId).toList(growable: false);

        return SizedBox(
          width: 900 * scale,
          height: 720 * scale,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(color: AppColor.overlay),
                ),
                Center(
                  child: Container(
                    width: 860 * scale,
                    height: 640 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6E7C8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFB07A42), width: 2),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text('鱼具商店', style: AppTypography.h1)),
                              FishingIconButton(
                                iconId: 'close',
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final category in categories)
                                _CategoryChip(
                                  label: category.name,
                                  selected: category.id == _categoryId,
                                  onTap: () => setState(() {
                                    _categoryId = category.id;
                                  }),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: GridView.builder(
                              itemCount: 12,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.96,
                              ),
                              itemBuilder: (context, index) {
                                final item = index < visibleItems.length ? visibleItems[index] : null;
                                return _ProductCard(
                                  item: item,
                                  currencyDisplayName: bundle.data.currency.displayName,
                                  owned: item == null
                                      ? 0
                                      : inventory.ownedOf(item.id, fallback: item.owned),
                                  onTap: item == null
                                      ? null
                                      : () => widget.dialogManager.openStoreItemDetailDialog(
                                            context,
                                            item: item,
                                            currencyDisplayName: bundle.data.currency.displayName,
                                            owned: inventory.ownedOf(item.id, fallback: item.owned),
                                            onBuy: () => widget.dialogManager.openStoreConfirmDialog(
                                              context,
                                              item: item,
                                              currencyDisplayName: bundle.data.currency.displayName,
                                              balance: wallet.fishCoin,
                                              onConfirm: () => _purchaseItem(
                                                context: context,
                                                wallet: wallet,
                                                inventory: inventory,
                                                transactions: transactions,
                                                item: item,
                                                currencyDisplayName: bundle.data.currency.displayName,
                                              ),
                                            ),
                                          ),
                                );
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _BalancePill(
                                  label: bundle.data.currency.displayName,
                                  value: '${wallet.fishCoin}',
                                ),
                              ),
                              const SizedBox(width: 10),
                              FishingSecondaryButton(
                                label: '钱包',
                                onPressed: () => Navigator.of(context).pushNamed('/wallet'),
                              ),
                              const SizedBox(width: 10),
                              FishingSecondaryButton(
                                label: '背包',
                                onPressed: () => Navigator.of(context).pushNamed('/inventory'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _purchaseItem({
    required BuildContext context,
    required WalletManagerView wallet,
    required InventoryManagerView inventory,
    required TransactionManagerView transactions,
    required StoreItem item,
    required String currencyDisplayName,
  }) {
    if (wallet.spend(item.price)) {
      inventory.addItem(
        itemId: item.id,
        name: item.name,
        category: item.category,
        rarity: item.rarity,
        icon: item.icon,
        description: item.description,
        quantity: 1,
      );
      final owned = inventory.ownedOf(item.id, fallback: item.owned);
      transactions.addRecord(
        TransactionRecord(
          id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
          type: 'purchase',
          currency: 'fish_coin',
          amount: item.price,
          itemId: item.id,
          itemName: item.name,
          createdAt: DateTime.now(),
        ),
      );
      widget.dialogManager.showPurchaseSuccessDialog(
        context,
        item: item,
        currencyDisplayName: currencyDisplayName,
        remainingBalance: wallet.fishCoin,
        owned: owned,
      );
      return;
    }
    widget.dialogManager.showInsufficientCoinDialog(
      context,
      currencyDisplayName: currencyDisplayName,
      requiredAmount: item.price,
      currentBalance: wallet.fishCoin,
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _BalancePill extends StatelessWidget {
  const _BalancePill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text('$label: $value', style: AppTypography.body),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.item,
    required this.currencyDisplayName,
    required this.owned,
    required this.onTap,
  });

  final StoreItem? item;
  final String currencyDisplayName;
  final int owned;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFB07A42)),
        ),
        child: Center(
          child: item == null
              ? const Text('EMPTY')
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item!.name, style: AppTypography.body, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('$currencyDisplayName ${item!.price}', style: AppTypography.caption),
                    const SizedBox(height: 6),
                    Text('Owned $owned', style: AppTypography.caption),
                  ],
                ),
        ),
      ),
    );
  }
}
