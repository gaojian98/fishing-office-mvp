import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/buttons/fishing_buttons.dart';
import '../../core/managers/app_managers.dart';
import '../../core/providers/app_providers.dart';
import '../../models/task_config.dart';

class TaskDialogPage extends ConsumerStatefulWidget {
  const TaskDialogPage({super.key, required this.config});

  final TaskConfig config;

  @override
  ConsumerState<TaskDialogPage> createState() => _TaskDialogPageState();
}

class _TaskDialogPageState extends ConsumerState<TaskDialogPage> {
  String _categoryId = 'all';

  @override
  Widget build(BuildContext context) {
    final manager = ref.watch(taskManagerProvider);
    final questRuntime = ref.watch(questRuntimeManagerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final quest = questRuntime.valueOrNull;
      if (quest != null) {
        quest.syncFromState(
          fishing: ref.read(fishingProvider),
          inventory: ref.read(inventoryManagerProvider),
          collection: ref.read(collectionManagerProvider),
          transactions: ref.read(transactionManagerProvider),
        );
        return;
      }
      ref.read(taskManagerProvider).syncFromState(
            fishing: ref.read(fishingProvider),
            inventory: ref.read(inventoryManagerProvider),
            collection: ref.read(collectionManagerProvider),
            transactions: ref.read(transactionManagerProvider),
          );
    });

    final categories = [
      TaskCategoryConfig(
          id: 'all',
          label: widget.config.uiLabel('all', '全部'),
          enabled: true,
          sortOrder: 0),
      ...widget.config.categories.where((item) => item.enabled),
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final tasks = (questRuntime.valueOrNull?.visibleTasks(_categoryId) ??
            manager.visibleTasks(widget.config, _categoryId))
        .take(6)
        .toList(growable: false);
    final size = MediaQuery.sizeOf(context);
    final width = size.width * 0.9;
    final height = size.height * 0.82;

    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6E1B8), Color(0xFFE1C27B), Color(0xFFC59649)],
          ),
          border: Border.all(color: const Color(0xFFF6DC8B), width: 2.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.32),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 92,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color(0xFF163E74),
                  Color(0xFF245A98),
                  Color(0xFF132E56)
                ]),
                border: Border(
                    bottom: BorderSide(color: Color(0xFFF3D47C), width: 2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.config.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                              color: Color(0x90000000),
                              blurRadius: 6,
                              offset: Offset(0, 2))
                        ],
                      ),
                    ),
                  ),
                  _TaskBlueGoldButton(
                    label: widget.config.uiLabel('close', '关闭'),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Text(
                widget.config.uiLabel('todayHint', widget.config.emptyMessage),
                style: const TextStyle(
                    color: Color(0xFF5A3A15),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.35),
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final selected = category.id == _categoryId;
                  return _TaskCategoryButton(
                    label: category.label,
                    selected: selected,
                    onTap: () => setState(() => _categoryId = category.id),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemCount: categories.length,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          widget.config.emptyMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color(0xFF5A3A15),
                              fontSize: 18,
                              fontWeight: FontWeight.w900),
                        ),
                      )
                    : Column(
                        children: [
                          for (final task in tasks) ...[
                            Expanded(
                              child: _TaskCard(
                                task: task,
                                config: widget.config,
                                onClaim: task.canClaim
                                    ? () => _claimTask(task.config)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _claimTask(TaskItemConfig task) {
    final quest = ref.read(questRuntimeManagerProvider).valueOrNull;
    final success = quest == null
        ? ref.read(taskManagerProvider).claimReward(
              task: task,
              wallet: ref.read(walletManagerProvider),
              transactions: ref.read(transactionManagerProvider),
            )
        : quest.claimReward(
            task: task,
            wallet: ref.read(walletManagerProvider),
            transactions: ref.read(transactionManagerProvider),
          );
    ref.read(dialogManagerProvider).showPlaceholder(
          context,
          title: success
              ? widget.config.claimSuccessMessage
              : widget.config.statusLabel('completed'),
          body: success
              ? _rewardText(task.reward)
              : widget.config.statusLabel('completed'),
        );
  }

  String _rewardText(TaskRewardConfig reward) {
    final parts = <String>[];
    if (reward.fishCoin > 0) {
      parts.add(
          '${widget.config.rewardLabels['fishCoin'] ?? '摸鱼币'} +${reward.fishCoin}');
    }
    if (reward.exp > 0) {
      parts.add('${widget.config.rewardLabels['exp'] ?? '经验'} +${reward.exp}');
    }
    if (reward.collectionPoint > 0) {
      parts.add(
          '${widget.config.rewardLabels['collectionPoint'] ?? '图鉴积分'} +${reward.collectionPoint}');
    }
    if (reward.titleId.isNotEmpty) {
      parts.add(
          '${widget.config.rewardLabels['titleId'] ?? '称号'} ${reward.titleId}');
    }
    return parts.isEmpty
        ? widget.config.claimSuccessMessage
        : parts.join(' · ');
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.config,
    required this.onClaim,
  });

  final TaskProgressView task;
  final TaskConfig config;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    final progress = task.config.target <= 0
        ? 1.0
        : task.cappedProgress / task.config.target;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFF7EBC8), Color(0xFFE9D09B)]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0BF73), width: 1.4),
      ),
      child: Row(
        children: [
          Text(task.config.icon, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.config.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF173D72),
                            fontSize: 17,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      config.statusLabel(task.status),
                      style: TextStyle(
                        color: task.status == 'claimable'
                            ? const Color(0xFFE08D19)
                            : const Color(0xFF5A3A15),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  task.config.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFF5A3A15),
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: const Color(0xFFD5B476),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF245A98)),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '${config.uiLabel('progress', '进度')} ${task.cappedProgress}/${task.config.target}',
                      style: const TextStyle(
                          color: Color(0xFF5A3A15),
                          fontSize: 12,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${config.uiLabel('reward', '奖励')} ${_rewardText(task.config.reward)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF8A5B12),
                            fontSize: 12,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _TaskBlueGoldButton(
            label: task.status == 'completed'
                ? config.uiLabel('claimed', '已领取')
                : config.uiLabel('claim', '领取'),
            enabled: onClaim != null,
            onTap: onClaim ?? () {},
          ),
        ],
      ),
    );
  }

  String _rewardText(TaskRewardConfig reward) {
    final parts = <String>[];
    if (reward.fishCoin > 0) parts.add('🐟${reward.fishCoin}');
    if (reward.exp > 0) parts.add('EXP ${reward.exp}');
    if (reward.collectionPoint > 0) parts.add('📖${reward.collectionPoint}');
    if (reward.titleId.isNotEmpty) parts.add('🏷 ${reward.titleId}');
    return parts.isEmpty ? '-' : parts.join(' ');
  }
}

class _TaskCategoryButton extends StatelessWidget {
  const _TaskCategoryButton(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFFFFD86B), Color(0xFFE08D19)])
              : const LinearGradient(
                  colors: [Color(0xFF21426F), Color(0xFF122744)]),
          border: Border.all(color: const Color(0xFFF7D77B), width: 1.4),
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}

class _TaskBlueGoldButton extends StatelessWidget {
  const _TaskBlueGoldButton(
      {required this.label, required this.onTap, this.enabled = true});

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.48,
      child: FishingButtonPressed(
        onPressed: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
                colors: [Color(0xFF3B86DB), Color(0xFF18426F)]),
            border: Border.all(color: const Color(0xFFF7D77B), width: 1.4),
          ),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}
