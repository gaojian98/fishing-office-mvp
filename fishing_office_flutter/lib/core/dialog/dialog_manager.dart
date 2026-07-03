import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/dialog_config.dart';
import '../../models/routes_config.dart';
import '../animation/animation_manager.dart';
import '../app_color.dart';
import '../app_typography.dart';
import '../buttons/fishing_buttons.dart';
import '../../pages/store/store_dialog_page.dart';
import '../../models/store_config.dart';
import '../engine/fishing_result.dart';
import '../providers/app_providers.dart';

class DialogManager {
  DialogManager({
    required this.routes,
    required this.dialog,
    required this.animationManager,
  });

  final RoutesConfig routes;
  final DialogConfig dialog;
  final AnimationManager animationManager;

  Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'dialog',
      barrierColor: AppColor.overlay,
      useRootNavigator: useRootNavigator,
      transitionDuration: animationManager.durationOf('dialog_open'),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(child: child),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> openById(BuildContext context, String dialogId) {
    if (dialogId == 'StoreDialog') {
      return show<void>(
        context,
        child: StoreDialogPage(dialogManager: this),
        barrierDismissible: false,
      );
    }
    final item = dialog.byId(dialogId);
    final title = item?.title ?? dialogId;
    final body = item?.description.isNotEmpty == true
        ? item!.description
        : 'TODO: dialog content source not ready';
    final dialogType = item?.type ?? 'medium';

    return show<void>(
      context,
      child: FishingDialog(
        title: title,
        body: body,
        dialogType: dialogType,
        actions: [
          if (item?.actions.isNotEmpty == true)
            ...item!.actions.map(
              (action) => FishingSecondaryButton(
                label: action.label,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          if (item?.closeable ?? true)
            FishingPrimaryButton(
              label: '关闭',
              onPressed: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  Future<void> openStoreItemDetailDialog(
    BuildContext context, {
    required StoreItem item,
    required String currencyDisplayName,
    required int owned,
    required VoidCallback onBuy,
  }) {
    return show<void>(
      context,
      child: FishingDialog(
        title: item.name,
        body: [
          item.description,
          '',
          '价格：$currencyDisplayName ${item.price}',
          '已拥有：$owned',
        ].join('\n'),
        dialogType: 'medium',
        actions: [
          FishingSecondaryButton(
            label: '关闭',
            onPressed: () => Navigator.of(context).pop(),
          ),
          FishingPrimaryButton(
            label: '购买',
            onPressed: () {
              Navigator.of(context).pop();
              onBuy();
            },
          ),
        ],
      ),
    );
  }

  Future<void> openStoreConfirmDialog(
    BuildContext context, {
    required StoreItem item,
    required String currencyDisplayName,
    required int balance,
    required VoidCallback onConfirm,
  }) {
    return show<void>(
      context,
      child: FishingConfirmDialog(
        title: '确认购买',
        body: '${item.name} 需要 $currencyDisplayName ${item.price}\n当前余额 $balance',
        confirmLabel: '确认购买',
        cancelLabel: '取消',
        onConfirm: () {
          Navigator.of(context).pop();
          onConfirm();
        },
      ),
    );
  }

  Future<void> showPurchaseSuccessDialog(
    BuildContext context, {
    required StoreItem item,
    required String currencyDisplayName,
    required int remainingBalance,
    required int owned,
  }) {
    return show<void>(
      context,
      child: FishingRewardDialog(
        title: '购买成功',
        body: '${item.name} 已加入背包。\n当前拥有：$owned\n消耗 $currencyDisplayName ${item.price}\n剩余余额 $remainingBalance',
      ),
    );
  }

  Future<void> showInsufficientCoinDialog(
    BuildContext context, {
    required String currencyDisplayName,
    required int requiredAmount,
    required int currentBalance,
  }) {
    return show<void>(
      context,
      child: FishingDialog(
        title: '摸鱼币不足',
        body: '还差 $currencyDisplayName ${requiredAmount - currentBalance}\n当前余额 $currentBalance',
        dialogType: 'small',
        actions: [
          FishingPrimaryButton(
            label: '知道了',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> openFishResultDialog(
    BuildContext context, {
    required FishingResult result,
  }) {
    final canUseAsBait = result.collectionEligible;
    return show<void>(
      context,
      child: FishingDialog(
        title: '鱼上钩了',
        body: [
          '鱼名：${result.fishName}',
          '等级：${result.metadata['tier'] ?? 'normal'}',
          '可出售摸鱼币：${result.value}',
          '可获得积分：${result.points}',
          '可出售：${result.sellable ? '可以' : '不可以'}',
          '可留下：${result.keepable ? '可以' : '不可以'}',
          '可作为鱼饵：${canUseAsBait ? '可以' : '不可以'}',
        ].join('\n'),
        dialogType: 'medium',
        actions: [
          FishingSecondaryButton(
            label: '出售',
            onPressed: () {
              final container = ProviderScope.containerOf(context, listen: false);
              Navigator.of(context).pop();
              container.read(fishingProvider).sellFish(
                    wallet: container.read(walletManagerProvider),
                    transactions: container.read(transactionManagerProvider),
                  );
              showPlaceholder(
                context,
                title: '出售成功',
                body: '这条鱼已经换成摸鱼币了。',
              );
            },
          ),
          FishingSecondaryButton(
            label: '留下',
            onPressed: () {
              final container = ProviderScope.containerOf(context, listen: false);
              Navigator.of(context).pop();
              container.read(fishingProvider).keepFish(
                    inventory: container.read(inventoryManagerProvider),
                    memory: container.read(memoryManagerProvider),
                  );
              showPlaceholder(
                context,
                title: '已放入背包',
                body: '这条鱼会留在你的背包里。',
              );
            },
          ),
          FishingPrimaryButton(
            label: '作为鱼饵',
            onPressed: () {
              final container = ProviderScope.containerOf(context, listen: false);
              Navigator.of(context).pop();
              container.read(fishingProvider).useAsBait();
              showPlaceholder(
                context,
                title: '已作为下一次鱼饵',
                body: '下一次抛线会优先使用这条鱼。',
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> openByRoute(BuildContext context, AppRoute route) {
    return openById(context, route.page);
  }

  Future<void> showUnknownRoute(BuildContext context) {
    final unknown = routes.unknownRoute;
    return show<void>(
      context,
      child: FishingDialog(
        title: unknown.title,
        body: unknown.message,
        dialogType: 'small',
        actions: [
          FishingPrimaryButton(
            label: '知道了',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> showPlaceholder(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    return show<void>(
      context,
      child: FishingDialog(
        title: title,
        body: body,
        dialogType: 'medium',
        actions: [
          FishingPrimaryButton(
            label: '关闭',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class FishingDialog extends StatelessWidget {
  const FishingDialog({
    super.key,
    required this.title,
    required this.body,
    required this.dialogType,
    this.actions = const [],
  });

  final String title;
  final String body;
  final String dialogType;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final widthFactor = dialogType == 'full'
        ? .9
        : dialogType == 'small'
            ? .72
            : .84;
    final maxHeightFactor = dialogType == 'full'
        ? .85
        : dialogType == 'small'
            ? .45
            : .6;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: screen.width * widthFactor,
        maxHeight: screen.height * maxHeightFactor,
      ),
      child: Material(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title, style: AppTypography.h2),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColor.textPrimary,
                    tooltip: '关闭',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(body, style: AppTypography.body),
                ),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.end,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FishingConfirmDialog extends StatelessWidget {
  const FishingConfirmDialog({
    super.key,
    required this.title,
    required this.body,
    required this.onConfirm,
    this.confirmLabel = '确定',
    this.cancelLabel = '取消',
  });

  final String title;
  final String body;
  final VoidCallback onConfirm;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return FishingDialog(
      title: title,
      body: body,
      dialogType: 'small',
      actions: [
        FishingSecondaryButton(
          label: cancelLabel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        FishingPrimaryButton(
          label: confirmLabel,
          onPressed: onConfirm,
        ),
      ],
    );
  }
}

class FishingRewardDialog extends StatelessWidget {
  const FishingRewardDialog({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return FishingDialog(
      title: title,
      body: body,
      dialogType: 'medium',
      actions: [
        FishingPrimaryButton(
          label: '领取',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class FishingToast extends StatelessWidget {
  const FishingToast({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.textPrimary,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(message, style: AppTypography.caption.copyWith(color: AppColor.white)),
      ),
    );
  }
}

class FishingBottomSheet extends StatelessWidget {
  const FishingBottomSheet({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Material(
        color: AppColor.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.h2),
              const SizedBox(height: 12),
              Text(body, style: AppTypography.body),
            ],
          ),
        ),
      ),
    );
  }
}
