import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/interaction_config.dart';
import '../dialog/dialog_manager.dart';
import '../navigation/navigation_manager.dart';
import '../providers/app_providers.dart';

class InteractionManager {
  const InteractionManager({
    required this.config,
    required this.navigationManager,
    required this.dialogManager,
  });

  final InteractionConfig config;
  final NavigationManager navigationManager;
  final DialogManager dialogManager;

  InteractionAction? actionFor(String id, String fallbackAction) {
    return config.actions[id] ?? config.actions[fallbackAction];
  }

  Future<void> handle(
    BuildContext context, {
    required String elementId,
    required String fallbackAction,
    required String fallbackLabel,
    required Map<String, dynamic> params,
  }) async {
    final action = actionFor(elementId, fallbackAction);
    if (action == null) return;

    switch (action.action) {
      case 'navigate':
        final route = params['route']?.toString();
        if (route != null && route.isNotEmpty) {
          navigationManager.openRoute(context, route);
        }
        break;
      case 'openDialog':
        final dialogId = params['dialog']?.toString() ?? action.target;
        if (dialogId.isNotEmpty) {
          dialogManager.openById(context, dialogId);
        }
        break;
      case 'confirmExit':
        dialogManager.openById(context, action.target.isNotEmpty ? action.target : 'ExitDialog');
        break;
      case 'throwFishingLine':
      case 'throwLine':
      case 'startFishingFlow':
      case 'startFishing':
        ProviderScope.containerOf(context, listen: false).read(fishingProvider).throwLine(
              baitId: params['baitId']?.toString() ?? 'bait_mock',
            );
        break;
      case 'pullFishingLine':
      case 'pullLine':
        final container = ProviderScope.containerOf(context, listen: false);
        final fishing = container.read(fishingProvider);
        fishing.pullLine();
        final result = fishing.result;
        if (result != null) {
          dialogManager.openFishResultDialog(context, result: result);
        }
        break;
      case 'sellFish':
        {
          final container = ProviderScope.containerOf(context, listen: false);
          container.read(fishingProvider).sellFish(
                wallet: container.read(walletManagerProvider),
                transactions: container.read(transactionManagerProvider),
              );
        }
        break;
      case 'keepFish':
        {
          final container = ProviderScope.containerOf(context, listen: false);
          container.read(fishingProvider).keepFish(
                inventory: container.read(inventoryManagerProvider),
                memory: container.read(memoryManagerProvider),
              );
        }
        break;
      case 'useAsBait':
        ProviderScope.containerOf(context, listen: false).read(fishingProvider).useAsBait();
        break;
      case 'switchFishingMode':
      case 'openAccountCenter':
      case 'switchMap':
        dialogManager.showPlaceholder(
          context,
          title: fallbackLabel,
          body: action.note.isNotEmpty ? action.note : 'TODO: ${action.action}',
        );
        break;
      default:
        dialogManager.showPlaceholder(
          context,
          title: fallbackLabel,
          body: 'TODO: ${action.action}',
        );
    }
  }
}
