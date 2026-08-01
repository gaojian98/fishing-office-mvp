import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/bootstrap/fishing_office_scope.dart';
import '../../core/runtime/app_runtime.dart';
import 'widgets/ambient_presentation_layer.dart';
import 'widgets/background.dart';
import 'widgets/bottom_bar.dart';
import 'widgets/desk_layer.dart';
import 'widgets/dialog_layer.dart';
import 'widgets/interactive_layer.dart';
import 'widgets/hotspot_debug_state.dart';
import 'widgets/office_layer.dart';
import 'widgets/sea_layer.dart';
import 'widgets/top_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const Size designSize = Size(1080, 1920);
  static const Color viewportBackground = Color(0xFF06131F);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.watch(appRuntimeProvider);
    final uiRuntime = ref.watch(uiRuntimeSnapshotProvider);
    final showDebugPanel =
        kDebugMode && Uri.base.queryParameters['debugPanel'] == '1';
    final showDebugHotspots =
        kDebugMode && Uri.base.queryParameters['debugHotspots'] == '1';
    return Scaffold(
      backgroundColor: viewportBackground,
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final responsive = FishingOfficeScope.of(context).responsive;
              assert(responsive.isPortrait);
              return SizedBox.expand(
                child: ClipRect(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: designSize.width,
                      height: designSize.height,
                      child: _HomeDesignStage(
                        runtime: runtime,
                        uiRuntime: uiRuntime,
                        showDebugPanel: showDebugPanel,
                        showDebugHotspots: showDebugHotspots,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeDesignStage extends StatelessWidget {
  const _HomeDesignStage({
    required this.runtime,
    required this.uiRuntime,
    required this.showDebugPanel,
    required this.showDebugHotspots,
  });

  final AppRuntime runtime;
  final AsyncValue<UiRuntimeSnapshot> uiRuntime;
  final bool showDebugPanel;
  final bool showDebugHotspots;

  @override
  Widget build(BuildContext context) {
    final stage = AspectRatio(
      aspectRatio: HomePage.designSize.width / HomePage.designSize.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Background(),
          AmbientPresentationLayer(
            runtime: runtime,
            uiRuntime: uiRuntime.valueOrNull ?? UiRuntimeSnapshot.fallback,
          ),
          const SeaLayer(),
          const OfficeLayer(),
          const DeskLayer(),
          const InteractiveLayer(),
          const TopBar(),
          const BottomBar(),
          const DialogLayer(),
          if (showDebugHotspots)
            ValueListenableBuilder<String>(
              valueListenable: HotspotDebugState.lastTap,
              builder: (context, value, child) {
                return Positioned(
                  left: 8,
                  top: 8,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Text(
                          value,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 9, height: 1.0),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          if (showDebugPanel) ...[
            Positioned(
              left: 16,
              bottom: 16,
              child: _MiniStatus(text: runtime.currentToday),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: _MiniStatus(text: runtime.currentWeather),
            ),
            Positioned(
              left: 16,
              top: 88,
              child: _MiniStatus(text: runtime.fishingState),
            ),
            Positioned(
              left: 16,
              top: 116,
              child: _MiniStatus(text: '鱼饵: ${runtime.currentBait}'),
            ),
            Positioned(
              left: 16,
              top: 144,
              child: _MiniStatus(text: '链路: ${runtime.targetChain}'),
            ),
            Positioned(
              left: 16,
              top: 172,
              child: _MiniStatus(
                  text:
                      '事件: ${runtime.waitingEvents.isEmpty ? '暂无等待事件' : runtime.waitingEvents.first}'),
            ),
            Positioned(
              left: 16,
              top: 200,
              child: _MiniStatus(text: '结果: ${runtime.currentFish}'),
            ),
            Positioned(
              left: 16,
              top: 228,
              child: _MiniStatus(text: '目标: ${runtime.targetChain}'),
            ),
            Positioned(
              left: 16,
              top: 256,
              child: _MiniEventList(items: runtime.waitingEvents),
            ),
            Positioned(
              left: 16,
              top: 388,
              child: _MiniStatus(
                  text: '现在可以：${runtime.fishing.currentActionsLabel}'),
            ),
            Positioned(
              right: 12,
              top: 92,
              child: _DebugPanel(
                runtime: runtime,
                uiRuntime: uiRuntime.valueOrNull ?? UiRuntimeSnapshot.fallback,
              ),
            ),
          ],
        ],
      ),
    );
    if (!kDebugMode) return stage;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        debugPrint(
          'HomePointerDown | position=${event.localPosition.dx.toStringAsFixed(1)},${event.localPosition.dy.toStringAsFixed(1)}',
        );
      },
      child: stage,
    );
  }
}

class _DebugPanel extends StatelessWidget {
  const _DebugPanel({
    required this.runtime,
    required this.uiRuntime,
  });

  final AppRuntime runtime;
  final UiRuntimeSnapshot uiRuntime;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white, fontSize: 10, height: 1.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Debug Panel',
                style: TextStyle(fontWeight: FontWeight.w700)),
            Text('Wallet: ${runtime.wallet.fishCoin}'),
            Text('Current Bait: ${runtime.currentBait}'),
            Text('Current Fish: ${runtime.currentFish}'),
            Text('Fish Result: ${runtime.currentFish}'),
            Text('Fishing State: ${runtime.fishingState}'),
            Text('Current Session: ${runtime.sessionId}'),
            Text('Waiting Events: ${runtime.waitingEvents.length}'),
            Text('Inventory Count: ${runtime.inventoryCount}'),
            Text('Transaction Count: ${runtime.transactionCount}'),
            Text('Current Weather: ${runtime.currentWeather}'),
            Text('Current Today: ${runtime.currentToday}'),
            Text('World Clock: ${uiRuntime.clockLabel}'),
            Text('Runtime Weather: ${uiRuntime.weatherLabel}'),
            Text('Festival: ${uiRuntime.festivalLabel}'),
            Text('Daily Summary: ${uiRuntime.dailySummary}'),
            Text('Dynamic Events: ${uiRuntime.availableEventCount}'),
            Text('Resident: ${uiRuntime.residentContextLabel}'),
            Text('Dialogue: ${uiRuntime.residentDialogue}'),
          ],
        ),
      ),
    );
  }
}

class _MiniEventList extends StatelessWidget {
  const _MiniEventList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('等待事件',
              style: TextStyle(color: Colors.white, fontSize: 11)),
          const SizedBox(height: 4),
          for (final item in items.take(4))
            Text(
              item,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
        ],
      ),
    );
  }
}

class _MiniStatus extends StatelessWidget {
  const _MiniStatus({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}
