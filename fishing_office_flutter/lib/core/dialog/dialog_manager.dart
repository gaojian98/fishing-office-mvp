import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/dialog_config.dart';
import '../../models/fish_collection_config.dart';
import '../../models/honor_config.dart';
import '../../models/inventory_config.dart';
import '../../models/layout_config.dart';
import '../../models/profile_config.dart';
import '../../models/settings_config.dart';
import '../../models/assets_config.dart';
import '../../models/transaction_config.dart';
import '../../models/guide_config.dart';
import '../../models/routes_config.dart';
import '../animation/animation_manager.dart';
import '../app_color.dart';
import '../app_typography.dart';
import '../buttons/fishing_buttons.dart';
import '../managers/app_managers.dart';
import '../../pages/help/guide_dialog_page.dart';
import '../../pages/collection/fish_collection_dialog_page.dart';
import '../../pages/profile/profile_center_dialog_page.dart';
import '../../pages/profile/profile_transaction_records_dialog_page.dart';
import '../../pages/profile/settings_dialog_page.dart';
import '../../pages/honor/honor_dialog_page.dart';
import '../../pages/inventory/inventory_dialog_page.dart';
import '../../pages/store/store_dialog_page.dart';
import '../../pages/store/store_product_detail_dialog_page.dart';
import '../../pages/tasks/task_dialog_page.dart';
import '../../widgets/office/office_hub_dialog.dart';
import '../../models/store_config.dart';
import '../../models/task_config.dart';
import '../engine/fishing_result.dart';
import '../providers/app_providers.dart';

class DialogManager {
  DialogManager({
    required this.routes,
    required this.dialog,
    required this.guide,
    required this.guideLayout,
    required this.honor,
    required this.honorLayout,
    required this.inventory,
    required this.inventoryLayout,
    required this.fishCollection,
    required this.fishCollectionLayout,
    required this.profile,
    required this.profileLayout,
    required this.profileTransactionsLayout,
    required this.settings,
    required this.settingsLayout,
    required this.settingsManager,
    required this.transactionManager,
    required this.assets,
    required this.transactions,
    required this.task,
    required this.animationManager,
  });

  final RoutesConfig routes;
  final DialogConfig dialog;
  final GuideConfig guide;
  final LayoutConfig guideLayout;
  final HonorConfig honor;
  final LayoutConfig honorLayout;
  final InventoryConfig inventory;
  final LayoutConfig inventoryLayout;
  final FishCollectionConfig fishCollection;
  final LayoutConfig fishCollectionLayout;
  final ProfileConfig profile;
  final LayoutConfig profileLayout;
  final LayoutConfig profileTransactionsLayout;
  final SettingsConfig settings;
  final LayoutConfig settingsLayout;
  final SettingsManagerView settingsManager;
  final TransactionManagerView transactionManager;
  final AssetsConfig assets;
  final TransactionConfig transactions;
  final TaskConfig task;
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
    if (dialogId == 'GameHelpDialog') {
      return show<void>(
        context,
        barrierDismissible: false,
        child: GuideDialogPage(
          guide: guide,
          layout: guideLayout,
          dialogManager: this,
        ),
      );
    }
    if (dialogId == 'HonorDialog') {
      return show<void>(
        context,
        barrierDismissible: false,
        child: HonorDialogPage(
          honor: honor,
          layout: honorLayout,
          dialogManager: this,
        ),
      );
    }
    if (dialogId == 'BagDialog' || dialogId == 'InventoryDialog') {
      return show<void>(
        context,
        barrierDismissible: false,
        child: InventoryDialogPage(
          inventory: inventory,
          layout: inventoryLayout,
          dialogManager: this,
        ),
      );
    }
    if (dialogId == 'FishCollectionDialog') {
      return show<void>(
        context,
        barrierDismissible: false,
        child: FishCollectionDialogPage(
          collection: fishCollection,
          layout: fishCollectionLayout,
        ),
      );
    }
    if (dialogId == 'ProfileCenterDialog') {
      return show<void>(
        context,
        barrierDismissible: false,
        child: ProfileCenterDialogPage(
          profile: profile,
          assets: assets,
          transactions: transactions,
          fishCollection: fishCollection,
          task: task,
          layout: profileLayout,
          transactionLayout: profileTransactionsLayout,
          dialogManager: this,
        ),
      );
    }
    if (dialogId == 'OfficeHubDialog') {
      return show<void>(
        context,
        barrierDismissible: false,
        child: const OfficeHubDialog(),
      );
    }
    if (dialogId == 'SettingsDialog') {
      return show<void>(
        context,
        barrierDismissible: false,
        child: SettingsDialogPage(
          settings: settings,
          layout: settingsLayout,
          manager: settingsManager,
          dialogManager: this,
        ),
      );
    }
    if (dialogId == 'TransactionRecordsDialog') {
      return show<void>(
        context,
        barrierDismissible: false,
        child: ProfileTransactionRecordsDialogPage(
          transactions: transactions,
          layout: profileTransactionsLayout,
          manager: transactionManager,
        ),
      );
    }
    if (dialogId == 'StoreDialog') {
      return show<void>(
        context,
        child: StoreDialogPage(dialogManager: this),
        barrierDismissible: false,
      );
    }
    if (dialogId == 'TaskDialog') {
      return show<void>(
        context,
        child: TaskDialogPage(config: task),
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
    final detailDialog = dialog.byId('ProductDetailDialog');
    return show<void>(
      context,
      child: StoreProductDetailDialogPage(
        product: item,
        currencyDisplayName: currencyDisplayName,
        owned: owned,
        dialogItem: detailDialog,
        onCancel: () => Navigator.of(context).pop(),
        onBuy: () {
          Navigator.of(context).pop();
          onBuy();
        },
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
    final confirmDialog = dialog.byId('ConfirmPurchaseDialog');
    final title =
        confirmDialog?.title.isNotEmpty == true ? confirmDialog!.title : '确认购买';
    final description = confirmDialog?.description.isNotEmpty == true
        ? confirmDialog!.description
        : '确认是否使用摸鱼币购买该商品。';
    final cancelLabel = confirmDialog?.actions.isNotEmpty == true
        ? confirmDialog!.actions.first.label
        : '取消';
    final confirmLabel = (confirmDialog?.actions.length ?? 0) > 1
        ? confirmDialog!.actions[1].label
        : '确认购买';
    return show<void>(
      context,
      child: _StoreThemedDialog(
        title: title,
        subtitle: item.name,
        body:
            '$description\n需要消耗 $currencyDisplayName ${item.price}\n当前余额 $balance',
        footer: const [],
        actions: [
          _StoreActionButton.secondary(
            label: cancelLabel,
            onTap: () => Navigator.of(context).pop(),
          ),
          _StoreActionButton.primary(
            label: confirmLabel,
            onTap: onConfirm,
          ),
        ],
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
    final successDialog = dialog.byId('PurchaseSuccessDialog');
    final title =
        successDialog?.title.isNotEmpty == true ? successDialog!.title : '购买成功';
    final description = successDialog?.description.isNotEmpty == true
        ? successDialog!.description
        : '商品已放入背包。';
    final closeLabel = successDialog?.actions.isNotEmpty == true
        ? successDialog!.actions.first.label
        : '知道了';
    return show<void>(
      context,
      child: _StoreThemedDialog(
        title: title,
        subtitle: item.name,
        body:
            '$description\n当前拥有：$owned\n消耗 $currencyDisplayName ${item.price}\n剩余余额 $remainingBalance',
        footer: const [],
        actions: [
          _StoreActionButton.primary(
            label: closeLabel,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
        heroBadge: successDialog?.title.isNotEmpty == true ? '成功' : '成功',
      ),
    );
  }

  Future<void> showInsufficientCoinDialog(
    BuildContext context, {
    required String currencyDisplayName,
    required int requiredAmount,
    required int currentBalance,
  }) {
    final insufficientDialog = dialog.byId('InsufficientCoinDialog');
    final title = insufficientDialog?.title.isNotEmpty == true
        ? insufficientDialog!.title
        : '摸鱼币不足';
    final description = insufficientDialog?.description.isNotEmpty == true
        ? insufficientDialog!.description
        : '摸鱼币暂时不够，可以去钱包兑换，也可以继续钓鱼赚取。';
    final cancelLabel = insufficientDialog?.actions.isNotEmpty == true
        ? insufficientDialog!.actions.first.label
        : '关闭';
    final walletLabel = (insufficientDialog?.actions.length ?? 0) > 1
        ? insufficientDialog!.actions[1].label
        : '去钱包';
    return show<void>(
      context,
      child: _StoreThemedDialog(
        title: title,
        subtitle: '余额不够了',
        body:
            '$description\n还差 $currencyDisplayName ${requiredAmount - currentBalance}\n当前余额 $currentBalance',
        footer: const [],
        actions: [
          _StoreActionButton.primary(
            label: cancelLabel,
            onTap: () => Navigator.of(context).pop(),
          ),
          _StoreActionButton.secondary(
            label: walletLabel,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/wallet');
            },
          ),
        ],
        heroBadge: '提示',
      ),
    );
  }

  Future<void> openFishResultDialog(
    BuildContext context, {
    required FishingResult result,
  }) {
    final quality = result.metadata['quality']?.toString() ?? '普通';
    final weight = result.metadata['weightKg']?.toString() ?? '1.0';
    return show<void>(
      context,
      child: FishingDialog(
        title: '鱼上钩了',
        body: [
          '鱼名：${result.fishName}',
          '品质：$quality',
          '重量：${weight}kg',
          '售价：${result.value} 摸鱼币',
          '经验：${result.points}',
        ].join('\n'),
        dialogType: 'medium',
        actions: [
          FishingSecondaryButton(
            label: '出售',
            onPressed: () {
              final container =
                  ProviderScope.containerOf(context, listen: false);
              Navigator.of(context).pop();
              container.read(fishingProvider).sellFish(
                    wallet: container.read(walletManagerProvider),
                    transactions: container.read(transactionManagerProvider),
                  );
              showPlaceholder(
                context,
                title: '出售成功',
                body: '摸鱼币和交易记录已经更新。',
              );
            },
          ),
          FishingPrimaryButton(
            label: '放入背包',
            onPressed: () {
              final container =
                  ProviderScope.containerOf(context, listen: false);
              Navigator.of(context).pop();
              container.read(fishingProvider).keepFish(
                    inventory: container.read(inventoryManagerProvider),
                    memory: container.read(memoryManagerProvider),
                  );
              showPlaceholder(
                context,
                title: '已放入背包',
                body: '这条鱼已经成为你的收藏。',
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> showProfileTransactionRecordsDialog(
    BuildContext context, {
    required TransactionConfig transactions,
    required LayoutConfig layout,
  }) {
    return show<void>(
      context,
      barrierDismissible: false,
      child: ProfileTransactionRecordsDialogPage(
        transactions: transactions,
        layout: layout,
        manager: transactionManager,
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

  Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    required String cancelLabel,
  }) async {
    final result = await show<bool>(
      context,
      barrierDismissible: false,
      child: FishingDialog(
        title: title,
        body: body,
        dialogType: 'small',
        actions: [
          FishingSecondaryButton(
            label: cancelLabel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          FishingPrimaryButton(
            label: confirmLabel,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _StoreThemedDialog extends StatelessWidget {
  const _StoreThemedDialog({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.footer,
    required this.actions,
    this.heroBadge,
  });

  final String title;
  final String subtitle;
  final String body;
  final List<Widget> footer;
  final List<Widget> actions;
  final String? heroBadge;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final width = screen.width * 0.88;
    final height = screen.height * 0.82;
    return SafeArea(
      child: Center(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF6E0B1),
                Color(0xFFE9C98A),
                Color(0xFFDAB572),
              ],
            ),
            border: Border.all(color: const Color(0xFFF6DD8A), width: 2.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                height: 90,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF143D73),
                      Color(0xFF245C9D),
                      Color(0xFF12305B)
                    ],
                  ),
                  border: Border(
                      bottom: BorderSide(color: Color(0xFFF1D57E), width: 2)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                    color: Color(0x90000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Color(0xFFFBE7B9),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (heroBadge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFFFD564), Color(0xFFE09A1C)]),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFFFF1B3), width: 1.4),
                        ),
                        child: Text(
                          heroBadge!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    const SizedBox(width: 14),
                    _StoreActionButton.icon(
                      label: '关闭',
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 100,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEFDCA7), Color(0xFFF7EBC8)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: const Color(0xFFE0BF73), width: 1.4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            body,
                            style: const TextStyle(
                              color: Color(0xFF4E3512),
                              fontSize: 20,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: footer,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          for (int i = 0; i < actions.length; i++) ...[
                            actions[i],
                            if (i != actions.length - 1)
                              const SizedBox(width: 12),
                          ],
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
}

class _StoreActionButton extends StatelessWidget {
  const _StoreActionButton._({
    required this.label,
    required this.onTap,
    required this.gradient,
    required this.borderColor,
    this.icon,
  });

  factory _StoreActionButton.primary({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return _StoreActionButton._(
      label: label,
      onTap: onTap,
      gradient: const LinearGradient(
          colors: [Color(0xFFFFD86B), Color(0xFFE08D19), Color(0xFFB8670B)]),
      borderColor: const Color(0xFFFFF2B2),
      icon: icon,
    );
  }

  factory _StoreActionButton.secondary({
    required String label,
    required VoidCallback onTap,
  }) {
    return _StoreActionButton._(
      label: label,
      onTap: onTap,
      gradient:
          const LinearGradient(colors: [Color(0xFF3B86DB), Color(0xFF18426F)]),
      borderColor: const Color(0xFFF7D77B),
    );
  }

  factory _StoreActionButton.icon({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return _StoreActionButton._(
      label: label,
      onTap: onTap,
      gradient:
          const LinearGradient(colors: [Color(0xFF3B86DB), Color(0xFF18426F)]),
      borderColor: const Color(0xFFF7D77B),
      icon: icon,
    );
  }

  final String label;
  final VoidCallback onTap;
  final LinearGradient gradient;
  final Color borderColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900),
            ),
          ],
        ),
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
        child: Text(message,
            style: AppTypography.caption.copyWith(color: AppColor.white)),
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
