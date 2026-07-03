import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_color.dart';
import '../../core/app_typography.dart';
import '../../core/buttons/fishing_buttons.dart';
import '../../core/providers/app_providers.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  String _category = 'all';

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryManagerProvider);
    final transactions = ref.watch(transactionManagerProvider);
    final categories = <String>{
      'all',
      ...inventory.entries.map((entry) => entry.category),
    }.toList(growable: false);
    final visible = inventory.entriesByCategory(_category);

    return Scaffold(
      backgroundColor: AppColor.pageBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('背包 / Inventory', style: AppTypography.h1)),
                  FishingIconButton(
                    iconId: 'icon_back',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in categories)
                    ChoiceChip(
                      label: Text(category == 'all' ? '全部' : category),
                      selected: category == _category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: visible.isEmpty
                    ? Center(
                        child: Text('暂无已购买商品', style: AppTypography.body),
                      )
                    : ListView.separated(
                        itemCount: visible.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = visible[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColor.primary.withValues(alpha: 0.25)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(entry.name, style: AppTypography.body),
                                    ),
                                    Text('x${entry.quantity}', style: AppTypography.h2),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('${entry.category} · ${entry.rarity}', style: AppTypography.caption),
                                const SizedBox(height: 6),
                                Text(entry.description, style: AppTypography.caption),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              Text('交易记录：${transactions.records.length} 条', style: AppTypography.caption),
            ],
          ),
        ),
      ),
    );
  }
}
