import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_color.dart';
import '../../core/app_typography.dart';
import '../../core/buttons/fishing_buttons.dart';
import '../../core/icons/fishing_icon.dart';
import '../../core/providers/app_providers.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletManagerProvider);

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
                  Expanded(
                    child: Text('钱包', style: AppTypography.h1),
                  ),
                  FishingIconButton(
                    iconId: FishingIcon.back,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _WalletCard(label: 'fish_coin', value: '${wallet.fishCoin}', iconId: FishingIcon.fishingCoin),
              const SizedBox(height: 12),
              _WalletCard(label: 'points', value: '${wallet.points}', iconId: FishingIcon.point),
              const SizedBox(height: 12),
              _WalletCard(label: 'cash', value: '${wallet.cashPlaceholder}', iconId: FishingIcon.coin),
              const SizedBox(height: 24),
              Text('当前仅展示资产，不做充值/提现。', style: AppTypography.caption),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.label,
    required this.value,
    required this.iconId,
  });

  final String label;
  final String value;
  final String iconId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          FishingIconWidget(iconId: iconId, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTypography.body)),
          Text(value, style: AppTypography.h2),
        ],
      ),
    );
  }
}
