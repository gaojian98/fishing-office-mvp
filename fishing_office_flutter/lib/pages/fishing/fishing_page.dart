import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_color.dart';
import '../../core/app_typography.dart';
import '../../core/buttons/fishing_buttons.dart';
import '../../core/providers/app_providers.dart';

class FishingPage extends ConsumerStatefulWidget {
  const FishingPage({super.key});

  @override
  ConsumerState<FishingPage> createState() => _FishingPageState();
}

class _FishingPageState extends ConsumerState<FishingPage> {
  Timer? _readyTimer;
  String? _scheduledSessionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureSessionStarted();
    });
  }

  @override
  void dispose() {
    _readyTimer?.cancel();
    super.dispose();
  }

  void _ensureSessionStarted() {
    final fishing = ref.read(fishingProvider);
    if (fishing.state == 'idle' || fishing.state == 'preparing') {
      fishing.throwLine(baitId: 'bait_basic');
    }
    _scheduleReadySignal();
  }

  void _scheduleReadySignal() {
    final fishing = ref.read(fishingProvider);
    final sessionId = fishing.session?.id;
    if (fishing.state != 'waiting' ||
        sessionId == null ||
        _scheduledSessionId == sessionId) {
      return;
    }
    _readyTimer?.cancel();
    _scheduledSessionId = sessionId;
    _readyTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      final current = ref.read(fishingProvider);
      if (current.session?.id == sessionId && current.state == 'waiting') {
        current.markFishHooked();
      }
    });
  }

  Future<void> _pullLine() async {
    final fishing = ref.read(fishingProvider);
    fishing.pullLine();
    final result = fishing.result;
    if (!mounted || result == null) return;
    await ref
        .read(dialogManagerProvider)
        .openFishResultDialog(context, result: result);
  }

  @override
  Widget build(BuildContext context) {
    final fishing = ref.watch(fishingProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scheduleReadySignal();
    });

    final messages = fishing.waitingMessages;
    final result = fishing.result;

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
                  Expanded(child: Text('开始钓鱼', style: AppTypography.h1)),
                  FishingIconButton(
                    iconId: 'icon_back',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _FishingStatusCard(
                stateLabel: fishing.stateLabel,
                baitLabel: fishing.currentBaitLabel,
                chainLabel: fishing.currentChainLabel,
                actionLabel: fishing.currentActionsLabel,
              ),
              const SizedBox(height: 18),
              Text('窗外的海面很安静，鱼漂正在慢慢等一条路过的鱼。', style: AppTypography.body),
              const SizedBox(height: 14),
              Expanded(
                child: _WaitingEventPanel(messages: messages),
              ),
              if (result != null) ...[
                const SizedBox(height: 12),
                Text('当前鱼获：${result.fishName}', style: AppTypography.body),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FishingSecondaryButton(
                      label: '重新抛线',
                      onPressed: () {
                        ref
                            .read(fishingProvider)
                            .throwLine(baitId: 'bait_basic');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FishingPrimaryButton(
                      label: fishing.canPullLine ? '收线' : '等待中',
                      onPressed: fishing.canPullLine ? _pullLine : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FishingStatusCard extends StatelessWidget {
  const _FishingStatusCard({
    required this.stateLabel,
    required this.baitLabel,
    required this.chainLabel,
    required this.actionLabel,
  });

  final String stateLabel;
  final String baitLabel;
  final String chainLabel;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.accent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('状态：$stateLabel', style: AppTypography.h2),
          const SizedBox(height: 8),
          Text('当前鱼饵：$baitLabel', style: AppTypography.body),
          const SizedBox(height: 6),
          Text('鱼链：$chainLabel', style: AppTypography.caption),
          const SizedBox(height: 6),
          Text('现在可以：$actionLabel', style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _WaitingEventPanel extends StatelessWidget {
  const _WaitingEventPanel({required this.messages});

  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    final visibleMessages =
        messages.isEmpty ? const ['鱼漂轻轻浮在海面上，先安静等一会儿。'] : messages;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EBC8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0BF73), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('等待中发生的小事', style: AppTypography.h2),
          const SizedBox(height: 12),
          for (final message in visibleMessages.take(5)) ...[
            Text('• $message', style: AppTypography.body),
            const SizedBox(height: 10),
          ],
          const Spacer(),
          Text('不用急，大鱼从来不着急。', style: AppTypography.caption),
        ],
      ),
    );
  }
}
