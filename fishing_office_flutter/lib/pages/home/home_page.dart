import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/bootstrap/fishing_office_scope.dart';
import '../../core/runtime/app_runtime.dart';
import 'widgets/background.dart';
import 'widgets/bottom_bar.dart';
import 'widgets/desk_layer.dart';
import 'widgets/dialog_layer.dart';
import 'widgets/interactive_layer.dart';
import 'widgets/office_layer.dart';
import 'widgets/sea_layer.dart';
import 'widgets/top_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const Size designSize = Size(390, 844);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.watch(appRuntimeProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final responsive = FishingOfficeScope.of(context).responsive;
              assert(responsive.isPortrait);
              final stageWidth = constraints.maxWidth;
              final stageHeight = constraints.maxHeight;
              final designRatio = designSize.width / designSize.height;
              final fitWidth = stageWidth;
              final fitHeight = fitWidth / designRatio;
              final actualHeight = fitHeight <= stageHeight ? fitHeight : stageHeight;
              final actualWidth = actualHeight * designRatio;

              return SizedBox(
                width: actualWidth,
                height: actualHeight,
                child: _HomeDesignStage(
                  runtime: runtime,
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
  const _HomeDesignStage({required this.runtime});

  final AppRuntime runtime;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: HomePage.designSize.width / HomePage.designSize.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Background(),
          const SeaLayer(),
          const OfficeLayer(),
          const DeskLayer(),
          const InteractiveLayer(),
          const TopBar(),
          const BottomBar(),
          const DialogLayer(),
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
            child: _MiniStatus(text: '事件: ${runtime.waitingEvents.isEmpty ? '暂无等待事件' : runtime.waitingEvents.first}'),
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
            child: _MiniStatus(text: '现在可以：${runtime.fishing.currentActionsLabel}'),
          ),
          if (kDebugMode)
            Positioned(
              right: 12,
              top: 92,
              child: _DebugPanel(runtime: runtime),
            ),
        ],
      ),
    );
  }
}

class _DebugPanel extends StatelessWidget {
  const _DebugPanel({required this.runtime});

  final AppRuntime runtime;

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
            const Text('Debug Panel', style: TextStyle(fontWeight: FontWeight.w700)),
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
          const Text('等待事件', style: TextStyle(color: Colors.white, fontSize: 11)),
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
