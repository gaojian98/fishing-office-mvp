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
    if (action == null) {
      _logFailure(elementId, fallbackAction, '', 'no-action-found');
      return;
    }
    debugPrint(
      'HotspotMatch | hotspotId=$elementId matchedAction=${action.action} matchedTarget=${action.target}',
    );

    try {
      switch (action.action) {
        case 'navigate':
          final route = _firstNonEmpty([
            params['route']?.toString(),
            action.params['route']?.toString(),
            action.target,
          ]);
          if (route.isNotEmpty) {
            final pageJumped = navigationManager.openRoute(context, route);
            debugPrint(
              'HotspotExecute | hotspotId=$elementId action=${action.action} target=$route result=success pageJump=$pageJumped',
            );
            _logSuccess(elementId, action.action, action.target,
                'route=$route pageJump=$pageJumped');
          } else {
            debugPrint(
              'HotspotExecute | hotspotId=$elementId action=${action.action} target=${action.target} result=fail reason=missing-route',
            );
            _logFailure(
                elementId, action.action, action.target, 'missing-route');
          }
          break;
        case 'openDialog':
          final dialogId = _firstNonEmpty([
            params['dialog']?.toString(),
            action.params['dialog']?.toString(),
            action.target,
          ]);
          if (dialogId.isNotEmpty) {
            dialogManager.openById(context, dialogId);
            debugPrint(
              'HotspotExecute | hotspotId=$elementId action=${action.action} target=$dialogId result=success pageJump=false',
            );
            _logSuccess(
                elementId, action.action, dialogId, 'opened pageJump=false');
          } else {
            debugPrint(
              'HotspotExecute | hotspotId=$elementId action=${action.action} target=${action.target} result=fail reason=missing-dialog-id',
            );
            _logFailure(
                elementId, action.action, action.target, 'missing-dialog-id');
          }
          break;
        case 'confirmExit':
          dialogManager.openById(
              context, action.target.isNotEmpty ? action.target : 'ExitDialog');
          debugPrint(
            'HotspotExecute | hotspotId=$elementId action=${action.action} target=${action.target.isNotEmpty ? action.target : 'ExitDialog'} result=success pageJump=false',
          );
          _logSuccess(
              elementId,
              action.action,
              action.target.isNotEmpty ? action.target : 'ExitDialog',
              'opened pageJump=false');
          break;
        case 'startFishingFlow':
        case 'startFishing':
          {
            final container = ProviderScope.containerOf(context, listen: false);
            container.read(fishingProvider).throwLine(
                  baitId: params['baitId']?.toString() ?? 'bait_basic',
                );
            final pageJumped = navigationManager.openRoute(context, '/fishing');
            debugPrint(
              'HotspotExecute | hotspotId=$elementId action=${action.action} target=/fishing result=success pageJump=$pageJumped',
            );
            _logSuccess(elementId, action.action, '/fishing',
                'throwLine pageJump=$pageJumped');
          }
          break;
        case 'throwFishingLine':
        case 'throwLine':
          ProviderScope.containerOf(context, listen: false)
              .read(fishingProvider)
              .throwLine(
                baitId: params['baitId']?.toString() ?? 'bait_basic',
              );
          debugPrint(
            'HotspotExecute | hotspotId=$elementId action=${action.action} target=${action.target} result=success pageJump=false',
          );
          _logSuccess(elementId, action.action, action.target,
              'throwLine pageJump=false');
          break;
        case 'pullFishingLine':
        case 'pullLine':
          {
            final container = ProviderScope.containerOf(context, listen: false);
            final fishing = container.read(fishingProvider);
            fishing.pullLine();
            final result = fishing.result;
            if (result != null) {
              dialogManager.openFishResultDialog(context, result: result);
              debugPrint(
                'HotspotExecute | hotspotId=$elementId action=${action.action} target=${action.target} result=success pageJump=false fish=${result.fishName}',
              );
              _logSuccess(elementId, action.action, action.target,
                  'fish=${result.fishName} pageJump=false');
            } else {
              debugPrint(
                'HotspotExecute | hotspotId=$elementId action=${action.action} target=${action.target} result=fail reason=no-fish-result',
              );
              _logFailure(
                  elementId, action.action, action.target, 'no-fish-result');
            }
          }
          break;
        case 'sellFish':
          {
            final container = ProviderScope.containerOf(context, listen: false);
            container.read(fishingProvider).sellFish(
                  wallet: container.read(walletManagerProvider),
                  transactions: container.read(transactionManagerProvider),
                );
            debugPrint(
              'HotspotExecute | hotspotId=$elementId action=${action.action} target=${action.target} result=success pageJump=false',
            );
            _logSuccess(elementId, action.action, action.target,
                'sellFish pageJump=false');
          }
          break;
        case 'keepFish':
          {
            final container = ProviderScope.containerOf(context, listen: false);
            container.read(fishingProvider).keepFish(
                  inventory: container.read(inventoryManagerProvider),
                  memory: container.read(memoryManagerProvider),
                );
            debugPrint(
              'HotspotExecute | hotspotId=$elementId action=${action.action} target=${action.target} result=success pageJump=false',
            );
            _logSuccess(elementId, action.action, action.target,
                'keepFish pageJump=false');
          }
          break;
        case 'useAsBait':
          ProviderScope.containerOf(context, listen: false)
              .read(fishingProvider)
              .useAsBait();
          debugPrint(
            'HotspotExecute | hotspotId=$elementId action=${action.action} target=${action.target} result=success pageJump=false',
          );
          _logSuccess(elementId, action.action, action.target,
              'useAsBait pageJump=false');
          break;
        case 'switchFishingMode':
        case 'openAccountCenter':
        case 'switchMap':
        case 'setFishingMode':
          dialogManager.showPlaceholder(
            context,
            title: fallbackLabel,
            body:
                action.note.isNotEmpty ? action.note : 'TODO: ${action.action}',
          );
          debugPrint(
            'HotspotExecute | hotspotId=$elementId action=${action.action} target=${action.target} result=success pageJump=false',
          );
          _logSuccess(elementId, action.action, action.target,
              '${action.note.isNotEmpty ? action.note : 'placeholder'} pageJump=false');
          break;
        default:
          dialogManager.showPlaceholder(
            context,
            title: fallbackLabel,
            body: 'TODO: ${action.action}',
          );
          debugPrint(
            'HotspotExecute | hotspotId=$elementId action=${action.action} target=${action.target} result=fail reason=unhandled-action',
          );
          _logFailure(
              elementId, action.action, action.target, 'unhandled-action');
      }
    } catch (error) {
      debugPrint(
        'HotspotExecute | hotspotId=$elementId action=${action.action} target=${action.target} result=fail reason=$error',
      );
      _logFailure(elementId, action.action, action.target, error.toString());
      rethrow;
    }
  }

  void _logSuccess(
      String elementId, String action, String target, String reason) {
    debugPrint(
        'HotspotResult | hotspotId=$elementId action=$action target=$target success reason=$reason');
  }

  void _logFailure(
      String elementId, String action, String target, String reason) {
    debugPrint(
        'HotspotResult | hotspotId=$elementId action=$action target=$target fail reason=$reason');
  }

  String _firstNonEmpty(Iterable<String?> values) {
    for (final value in values) {
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }
}
