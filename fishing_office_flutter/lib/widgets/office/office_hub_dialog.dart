import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_typography.dart';
import '../../core/buttons/fishing_buttons.dart';
import '../../core/providers/app_providers.dart';
import '../../models/interactive_office.dart';

class _OfficeUi {
  const _OfficeUi._();

  static const navy = Color(0xFF17345F);
  static const blue = Color(0xFF225996);
  static const ink = Color(0xFF4A361B);
  static const muted = Color(0xFF6B5735);
  static const paper = Color(0xFFFFF8E7);
  static const line = Color(0xFFE0BF73);
  static const success = Color(0xFF246B55);
  static const warning = Color(0xFF8A5A12);
  static const danger = Color(0xFF9A3E31);

  static const radius = 18.0;
  static const radiusLarge = 28.0;
  static const gap = 10.0;

  static const title = TextStyle(
    color: navy,
    fontSize: 17,
    fontWeight: FontWeight.w900,
  );
  static const subtitle = TextStyle(
    color: ink,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );
  static const body = TextStyle(
    color: muted,
    fontSize: 12.5,
    height: 1.32,
    fontWeight: FontWeight.w700,
  );
}

class OfficeHubDialog extends ConsumerStatefulWidget {
  const OfficeHubDialog({super.key});

  @override
  ConsumerState<OfficeHubDialog> createState() => _OfficeHubDialogState();
}

class _OfficeHubDialogState extends ConsumerState<OfficeHubDialog> {
  String _section = 'overview';
  String _residentFilter = 'all';
  String _residentSort = 'interactive';
  String _selectedResidentId = '';
  final Set<String> _pendingActionIds = <String>{};
  PlayerActionResult? _lastResult;

  @override
  Widget build(BuildContext context) {
    final asyncSnapshot = ref.watch(interactiveOfficeSnapshotProvider);
    final size = MediaQuery.sizeOf(context);
    final width = math.min(size.width * 0.94, 980.0);
    final height = math.min(size.height * 0.9, 860.0);
    return SafeArea(
      minimum: const EdgeInsets.all(12),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_OfficeUi.radiusLarge),
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
          child: asyncSnapshot.when(
            loading: () => _Frame(
              title: '今日办公室',
              onClose: () => Navigator.of(context).pop(),
              child: const _LoadingState(
                title: '办公室正在慢慢醒来',
                body: '正在整理居民、天气、传闻和今日摘要。',
              ),
            ),
            error: (error, _) => _Frame(
              title: '今日办公室',
              onClose: () => Navigator.of(context).pop(),
              child: _EmptyState(
                title: '暂时读不到办公室状态',
                body: error.toString(),
              ),
            ),
            data: (snapshot) => _Frame(
              title: '今日办公室',
              onClose: () => Navigator.of(context).pop(),
              child: Column(
                children: [
                  _SectionTabs(
                    selected: _section,
                    onChanged: (value) => setState(() => _section = value),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _sectionBody(snapshot)),
                  if (_lastResult != null) ...[
                    const SizedBox(height: 10),
                    _ResultPanel(result: _lastResult!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionBody(InteractiveOfficeSnapshot snapshot) {
    switch (_section) {
      case 'residents':
        return _ResidentsSection(
          snapshot: snapshot,
          selectedResidentId: _selectedResidentId,
          filter: _residentFilter,
          sort: _residentSort,
          onFilterChanged: (value) => setState(() => _residentFilter = value),
          onSortChanged: (value) => setState(() => _residentSort = value),
          onResidentSelected: (value) =>
              setState(() => _selectedResidentId = value),
          onAction: _submit,
          pendingActionIds: _pendingActionIds,
        );
      case 'groups':
        return _GroupsSection(
          groups: snapshot.activeGroups,
          onAction: _submit,
          pendingActionIds: _pendingActionIds,
        );
      case 'events':
        return _EventsSection(
          events: snapshot.currentEvents,
          onAction: _submit,
          pendingActionIds: _pendingActionIds,
        );
      case 'career':
        return _CareerSection(snapshot: snapshot, onAction: _submit);
      case 'history':
        return _HistorySection(snapshot: snapshot);
      default:
        return _OverviewSection(snapshot: snapshot);
    }
  }

  Future<void> _submit(PlayerActionRequest request) async {
    if (_pendingActionIds.contains(request.actionId)) return;
    setState(() => _pendingActionIds.add(request.actionId));
    final result = await ref.read(residentInteractionProvider(request).future);
    if (!mounted) return;
    setState(() {
      _pendingActionIds.remove(request.actionId);
      _lastResult = result;
      if (request.targetResidentId.isNotEmpty) {
        _selectedResidentId = request.targetResidentId;
      }
    });
  }
}

class _Frame extends StatelessWidget {
  const _Frame({
    required this.title,
    required this.child,
    required this.onClose,
  });

  final String title;
  final Widget child;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 78),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF163E74), Color(0xFF245A98), Color(0xFF132E56)],
            ),
            border: Border(
              bottom: BorderSide(color: Color(0xFFF3D47C), width: 2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: '关闭今日办公室弹窗',
                child: Tooltip(
                  message: '关闭',
                  child:
                      FishingSecondaryButton(label: '关闭', onPressed: onClose),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const tabs = <String, String>{
      'overview': '状态',
      'residents': '居民',
      'groups': '群体',
      'events': '事件',
      'career': '职业',
      'history': '历史',
    };
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in tabs.entries)
          _SmallChip(
            label: entry.value,
            selected: selected == entry.key,
            onTap: () => onChanged(entry.key),
          ),
      ],
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.snapshot});

  final InteractiveOfficeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final office = snapshot.officeState;
    final availableActions = snapshot.availableActions
        .where((action) => action.available)
        .take(4)
        .map((action) =>
            '${action.label}${action.reason.isEmpty ? '' : '：${action.reason}'}')
        .toList();
    return ListView(
      children: [
        _InfoCard(
          title: '当前办公室状态',
          subtitle:
              '${snapshot.date} · ${snapshot.timeOfDay} · ${InteractiveOfficeLabels.mood(office.officeMood)}',
          body: _officeMoodDescription(office.officeMood),
          tags: [
            office.currentWeather.isEmpty ? '普通天气' : office.currentWeather,
            office.currentFestival.isEmpty ? '无节日' : office.currentFestival,
          ],
          actions: const [],
        ),
        const SizedBox(height: _OfficeUi.gap),
        _MetricGrid(metrics: [
          _MetricData('活跃度', office.activityLevel,
              _levelDescription('activity', office.activityLevel)),
          _MetricData('生产力', office.productivityLevel,
              _levelDescription('productivity', office.productivityLevel)),
          _MetricData('社交水平', office.socialLevel,
              _levelDescription('social', office.socialLevel)),
          _MetricData('紧张度', office.tensionLevel,
              _levelDescription('tension', office.tensionLevel)),
          _MetricData('活跃居民', office.activeResidentCount,
              '今天可以遇见 ${office.activeResidentCount} 位居民',
              maxValue: math.max(100, office.activeResidentCount)),
          _MetricData('群体活动', office.activeGroupCount,
              office.activeGroupCount == 0 ? '暂时没有群体活动' : '办公室里有小群体正在发生',
              maxValue: math.max(6, office.activeGroupCount)),
        ]),
        const SizedBox(height: _OfficeUi.gap),
        _TextBlock(
          title: '今日建议',
          lines: availableActions,
          emptyText: '现在没有必须做的事，安静待一会儿也很好。',
        ),
        const SizedBox(height: _OfficeUi.gap),
        _TextBlock(
          title: '办公室评价',
          lines: snapshot.playerReputation
              .map(InteractiveOfficeLabels.reputation)
              .take(4)
              .toList(),
          emptyText: '大家还在慢慢认识你。',
        ),
      ],
    );
  }
}

class _MetricData {
  const _MetricData(
    this.label,
    this.value,
    this.description, {
    this.maxValue = 100,
  });

  final String label;
  final int value;
  final String description;
  final int maxValue;
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final List<_MetricData> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720
            ? 3
            : constraints.maxWidth >= 520
                ? 2
                : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: columns == 1
                ? 2.0
                : constraints.maxWidth >= 720
                    ? 2.35
                    : 1.45,
            mainAxisSpacing: _OfficeUi.gap,
            crossAxisSpacing: _OfficeUi.gap,
          ),
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return _MetricCard(metric: metric);
          },
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _MetricData metric;

  @override
  Widget build(BuildContext context) {
    final progress = metric.maxValue <= 0
        ? 0.0
        : (metric.value / metric.maxValue).clamp(0.0, 1.0);
    return _InfoCard(
      title: metric.label,
      subtitle: '${metric.value}',
      body: metric.description,
      actions: [
        SizedBox(
          width: 112,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress,
              color: metric.label == '紧张度' ? _OfficeUi.warning : _OfficeUi.blue,
              backgroundColor: const Color(0xFFE4CCA0),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResidentsSection extends StatelessWidget {
  const _ResidentsSection({
    required this.snapshot,
    required this.selectedResidentId,
    required this.filter,
    required this.sort,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onResidentSelected,
    required this.onAction,
    required this.pendingActionIds,
  });

  final InteractiveOfficeSnapshot snapshot;
  final String selectedResidentId;
  final String filter;
  final String sort;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String> onResidentSelected;
  final ValueChanged<PlayerActionRequest> onAction;
  final Set<String> pendingActionIds;

  @override
  Widget build(BuildContext context) {
    final residents = _residentFilteredSorted(snapshot, filter, sort);
    if (residents.isEmpty) {
      return const _EmptyState(title: '附近暂时没有居民', body: '办公室很安静。');
    }
    final selected = snapshot.residentDetails.firstWhere(
      (item) => item.residentId == selectedResidentId,
      orElse: () => snapshot.residentDetails.firstWhere(
        (item) => item.residentId == residents.first.id,
        orElse: () => ResidentDetailViewModel.empty(residents.first.id),
      ),
    );
    return Column(
      children: [
        _ResidentControls(
          filter: filter,
          sort: sort,
          onFilterChanged: onFilterChanged,
          onSortChanged: onSortChanged,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              final list = _ResidentList(
                residents: residents,
                selectedId: selected.residentId,
                onSelected: onResidentSelected,
              );
              final detail = _ResidentDetailPanel(
                detail: selected,
                onAction: onAction,
                pendingActionIds: pendingActionIds,
              );
              if (wide) {
                return Row(
                  children: [
                    SizedBox(width: constraints.maxWidth * 0.38, child: list),
                    const SizedBox(width: 12),
                    Expanded(child: detail),
                  ],
                );
              }
              return Column(
                children: [
                  SizedBox(height: constraints.maxHeight * 0.42, child: list),
                  const SizedBox(height: 10),
                  Expanded(child: detail),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ResidentControls extends StatelessWidget {
  const _ResidentControls({
    required this.filter,
    required this.sort,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  final String filter;
  final String sort;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSortChanged;

  @override
  Widget build(BuildContext context) {
    const filters = <String, String>{
      'all': '全部',
      'nearby': '附近',
      'same_location': '同地点',
      'interactive': '可互动',
      'friends': '朋友',
      'story': '有故事',
      'event': '有事件',
      'rumor': '有传闻',
    };
    const sorts = <String, String>{
      'interactive': '可互动优先',
      'name': '姓名',
      'friendship': '友情',
      'recent': '最近互动',
      'location': '地点',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in filters.entries)
              _SmallChip(
                label: entry.value,
                selected: filter == entry.key,
                onTap: () => onFilterChanged(entry.key),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in sorts.entries)
              _SmallChip(
                label: '排序：${entry.value}',
                selected: sort == entry.key,
                onTap: () => onSortChanged(entry.key),
              ),
          ],
        ),
      ],
    );
  }
}

class _ResidentList extends StatelessWidget {
  const _ResidentList({
    required this.residents,
    required this.selectedId,
    required this.onSelected,
  });

  final List<ResidentOfficeView> residents;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: residents.length,
      itemBuilder: (context, index) {
        final resident = residents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ResidentListTile(
            resident: resident,
            selected: resident.id == selectedId,
            onTap: () => onSelected(resident.id),
          ),
        );
      },
    );
  }
}

class _ResidentListTile extends StatelessWidget {
  const _ResidentListTile({
    required this.resident,
    required this.selected,
    required this.onTap,
  });

  final ResidentOfficeView resident;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(_OfficeUi.radius),
        onTap: onTap,
        child: Semantics(
          button: true,
          selected: selected,
          label:
              '${resident.name}，${resident.locationName}，${InteractiveOfficeLabels.mood(resident.mood)}，${InteractiveOfficeLabels.friendshipStage(resident.friendshipStage)}',
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  selected ? const Color(0xFFFFF7DA) : const Color(0xFFF1D9A3),
              borderRadius: BorderRadius.circular(_OfficeUi.radius),
              border: Border.all(
                color: selected ? _OfficeUi.blue : _OfficeUi.line,
                width: selected ? 2 : 1.2,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _OfficeUi.blue,
                  child: Text(
                    resident.name.isEmpty ? '?' : resident.name.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resident.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _OfficeUi.title.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${resident.locationName} · ${resident.activity}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _OfficeUi.body.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  alignment: WrapAlignment.end,
                  children: [
                    _StatusPill(
                      label: InteractiveOfficeLabels.mood(resident.mood),
                    ),
                    _StatusPill(
                      label: InteractiveOfficeLabels.friendshipStage(
                        resident.friendshipStage,
                      ),
                      tone: _PillTone.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResidentDetailPanel extends StatelessWidget {
  const _ResidentDetailPanel({
    required this.detail,
    required this.onAction,
    required this.pendingActionIds,
  });

  final ResidentDetailViewModel detail;
  final ValueChanged<PlayerActionRequest> onAction;
  final Set<String> pendingActionIds;

  @override
  Widget build(BuildContext context) {
    if (!detail.active) {
      return _EmptyState(title: '居民详情暂不可用', body: detail.description);
    }
    return ListView(
      children: [
        _InfoCard(
          title: '${detail.name} · ${detail.nickname}',
          subtitle:
              '${detail.job} · ${InteractiveOfficeLabels.friendshipStage(detail.friendshipStage)}',
          body: detail.description,
          actions: const [],
        ),
        _DetailSection(
          title: '当前状态',
          lines: [
            '地点：${detail.currentLocation}',
            '行为：${detail.currentActivity}',
            '心情：${InteractiveOfficeLabels.mood(detail.currentMood)}',
            '日程：${InteractiveOfficeLabels.schedulePhase(detail.schedulePhase)}',
            if (detail.isWorking) '状态：工作中',
            if (detail.isOnBreak) '状态：休息中',
            if (detail.isOvertime) '状态：加班中',
            if (detail.isWeekend) '状态：周末节奏',
            if (detail.nextLocation.isNotEmpty) '下一地点：${detail.nextLocation}',
            if (detail.nextActivity.isNotEmpty) '下一行为：${detail.nextActivity}',
            if (detail.nextChangeTime.isNotEmpty)
              '预计变化：${detail.nextChangeTime}',
            '原因：${detail.scheduleReason}',
          ],
        ),
        _DetailSection(
          title: '职业',
          lines: [
            '职业阶段：${detail.careerLevelName.isEmpty ? detail.careerLevel : detail.careerLevelName}',
            '雇佣状态：${_employmentStatusLabel(detail.employmentStatus)}',
            if (detail.hireDate.isNotEmpty) '入职时间：${detail.hireDate}',
            '薪资层级：${detail.salaryLevel}',
            '绩效：${_levelText(detail.performanceScore)}',
            '能力：${_levelText(detail.capabilityScore)}',
            if (detail.promotionHistory.isNotEmpty)
              '最近职业事件：${_careerEventLabel(detail.promotionHistory.last.type)}',
            if (detail.careerTags.isNotEmpty)
              '职业标签：${detail.careerTags.take(4).join(' / ')}',
          ],
        ),
        if (detail.officeEconomyLines.isNotEmpty)
          _DetailSection(
            title: '公司经济',
            lines: detail.officeEconomyLines,
          ),
        _InteractionsSection(
          detail: detail,
          onAction: onAction,
          pendingActionIds: pendingActionIds,
        ),
        _DetailSection(
          title: '性格',
          lines: [
            '主要性格：${InteractiveOfficeLabels.personality(detail.dominantPersonality)}',
            '性格摘要：${detail.personalitySummary}',
          ],
        ),
        _DetailSection(
          title: '友情与关系',
          lines: [
            '友情：${InteractiveOfficeLabels.friendshipStage(detail.friendshipStage)}',
            '信任：${_levelText(detail.trust)}',
            '熟悉度：${_levelText(detail.familiarity)}',
            '近期变化：${InteractiveOfficeLabels.trend(detail.relationshipTrend)}',
            '冲突状态：${InteractiveOfficeLabels.conflict(detail.conflictState)}',
            if (detail.relationshipTags.isNotEmpty)
              '关系标签：${detail.relationshipTags.map(InteractiveOfficeLabels.relationshipTag).take(4).join(' / ')}',
          ],
        ),
        _DetailSection(
          title: '可见资料',
          lines: detail.visibleProfileFields.entries
              .map((entry) => '${entry.key}：${entry.value}')
              .toList(),
        ),
        if (detail.privateProfileFields.isNotEmpty)
          _DetailSection(
            title: '尚未了解',
            lines: detail.privateProfileFields.entries
                .map((entry) => '${entry.key}：继续相处后，可能会了解更多。')
                .toList(),
          ),
        _DetailSection(
          title: '最近记忆',
          lines: detail.recentMemories.isEmpty
              ? const ['还没有共同记忆。']
              : detail.recentMemories
                  .map((item) => '${item.summary} · ${item.time}')
                  .toList(),
        ),
        _DetailSection(
          title: '最近互动',
          lines: detail.recentInteractions.isEmpty
              ? const ['还没有最近互动。']
              : detail.recentInteractions
                  .map((item) => '${item.summary} · ${item.time}')
                  .toList(),
        ),
        _DetailSection(
          title: '故事与传闻',
          lines: [
            if (detail.recentStories.isEmpty) '当前没有可触发故事。',
            ...detail.recentStories
                .take(4)
                .map((story) => '${story.title}：${story.publicHint}'),
            if (detail.recentRumors.isEmpty) '当前没有可询问传闻。',
            ...detail.recentRumors
                .take(4)
                .map((rumor) => '${rumor.title}：${rumor.status}'),
          ],
        ),
        _DetailSection(
          title: '互动冷却',
          lines: detail.currentCooldowns.isEmpty
              ? const ['当前没有冷却。']
              : detail.currentCooldowns
                  .map((item) => '${item.label}：${item.remainingText}')
                  .toList(),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: _InfoCard(
        title: title,
        subtitle: '',
        body: lines.isEmpty ? '暂无内容。' : lines.take(8).join('\n'),
        maxBodyLines: 10,
        actions: const [],
      ),
    );
  }
}

class _InteractionsSection extends StatefulWidget {
  const _InteractionsSection({
    required this.detail,
    required this.onAction,
    required this.pendingActionIds,
  });

  final ResidentDetailViewModel detail;
  final ValueChanged<PlayerActionRequest> onAction;
  final Set<String> pendingActionIds;

  @override
  State<_InteractionsSection> createState() => _InteractionsSectionState();
}

class _InteractionsSectionState extends State<_InteractionsSection> {
  bool _showFishSelector = false;
  bool _showUnavailableFish = false;
  String _fishSort = 'preference';
  String _selectedFishId = '';

  @override
  Widget build(BuildContext context) {
    final all = <ResidentInteractionView>[
      ...widget.detail.availableInteractions,
      ...widget.detail.blockedInteractions,
    ];
    final ordered = _orderedInteractions(all);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_showFishSelector) ...[
            _FishShareSelector(
              residentId: widget.detail.residentId,
              options: widget.detail.shareFishOptions,
              selectedFishId: _selectedFishId,
              showUnavailable: _showUnavailableFish,
              sort: _fishSort,
              pendingActionIds: widget.pendingActionIds,
              onSelected: (value) => setState(() => _selectedFishId = value),
              onShowUnavailableChanged: (value) =>
                  setState(() => _showUnavailableFish = value),
              onSortChanged: (value) => setState(() => _fishSort = value),
              onCancel: () => setState(() => _showFishSelector = false),
              onConfirm: _confirmFishShare,
            ),
            const SizedBox(height: 10),
          ],
          _InfoCard(
            title: '可用互动',
            subtitle: widget.detail.availableInteractions.isEmpty
                ? '现在先观察一下就好'
                : '选择一个轻互动',
            body: widget.detail.blockedInteractions.isEmpty
                ? '所有当前显示的互动都可尝试。'
                : widget.detail.blockedInteractions
                    .take(3)
                    .map((item) => '${item.label} 暂不可用：${item.reason}')
                    .join('\n'),
            tags: [
              if (widget.detail.availableInteractions.isNotEmpty)
                '可互动 ${widget.detail.availableInteractions.length}',
              if (widget.detail.currentCooldowns.isNotEmpty)
                '冷却 ${widget.detail.currentCooldowns.length}',
            ],
            actions: ordered.take(10).map((item) {
              final isShareFish = item.id == 'share_fish';
              final id = isShareFish
                  ? 'share_fish_picker_${widget.detail.residentId}'
                  : _requestId(item.id, widget.detail.residentId);
              final pending = widget.pendingActionIds.contains(id);
              return _ActionButton(
                label: pending
                    ? '正在送过去'
                    : item.available
                        ? item.label
                        : '${item.label} · 稍后再试',
                tooltip: item.available
                    ? '${item.description}\n${item.impactHint}'
                    : item.reason,
                disabled: pending || !item.available,
                loading: pending,
                onTap: () {
                  if (isShareFish) {
                    setState(() => _showFishSelector = !_showFishSelector);
                    return;
                  }
                  widget.onAction(PlayerActionRequest(
                    actionId: id,
                    actionType: item.id,
                    targetResidentId: widget.detail.residentId,
                    targetLocationId: widget.detail.currentLocation,
                    sourcePage: 'resident_detail',
                    metadata: <String, Object?>{
                      'impactHint': item.impactHint,
                      'cooldown': item.cooldownText,
                    },
                  ));
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _confirmFishShare(FishShareOptionView option) {
    final id = _shareFishRequestId(
      widget.detail.residentId,
      option.fishId,
    );
    widget.onAction(PlayerActionRequest(
      actionId: id,
      actionType: 'share_fish',
      targetResidentId: widget.detail.residentId,
      targetLocationId: widget.detail.currentLocation,
      sourcePage: 'resident_detail',
      metadata: <String, Object?>{
        'fishId': option.fishId,
        'fishName': option.name,
        'rarity': option.rarity,
        'requestScope': 'daily_share',
      },
    ));
  }

  List<ResidentInteractionView> _orderedInteractions(
    List<ResidentInteractionView> items,
  ) {
    final copy = items.toList(growable: true);
    copy.sort((a, b) {
      if (a.id == 'share_fish') return -1;
      if (b.id == 'share_fish') return 1;
      if (a.available != b.available) return a.available ? -1 : 1;
      return a.label.compareTo(b.label);
    });
    return copy;
  }
}

class _FishShareSelector extends StatelessWidget {
  const _FishShareSelector({
    required this.residentId,
    required this.options,
    required this.selectedFishId,
    required this.showUnavailable,
    required this.sort,
    required this.pendingActionIds,
    required this.onSelected,
    required this.onShowUnavailableChanged,
    required this.onSortChanged,
    required this.onCancel,
    required this.onConfirm,
  });

  final String residentId;
  final List<FishShareOptionView> options;
  final String selectedFishId;
  final bool showUnavailable;
  final String sort;
  final Set<String> pendingActionIds;
  final ValueChanged<String> onSelected;
  final ValueChanged<bool> onShowUnavailableChanged;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onCancel;
  final ValueChanged<FishShareOptionView> onConfirm;

  @override
  Widget build(BuildContext context) {
    final visible = _visibleOptions();
    final selected = visible.where((item) => item.fishId == selectedFishId);
    final selectedOption = selected.isEmpty
        ? (visible.isEmpty ? null : visible.first)
        : selected.first;
    final pending = selectedOption == null
        ? false
        : pendingActionIds.contains(
            _shareFishRequestId(residentId, selectedOption.fishId),
          );
    return _InfoCard(
      title: '选择一条鱼获',
      subtitle: options.isEmpty ? '背包里暂时没有鱼获' : '默认只显示可以分享的鱼',
      body: visible.isEmpty
          ? '现在没有可以分享的鱼。等下一次钓到鱼，再把它变成一个小话题吧。'
          : selectedOption == null
              ? '请选择一条可以分享的鱼获。'
              : '${selectedOption.name} · ${InteractiveOfficeLabels.rarity(selectedOption.rarity)} · ${selectedOption.weightLabel} · ${selectedOption.quantity} 条\n${selectedOption.available ? selectedOption.residentPreference : selectedOption.unavailableReason}',
      maxBodyLines: 3,
      tags: [
        '可分享 ${options.where((item) => item.available).length}',
        if (selectedOption != null)
          '已选 ${selectedOption.name} · ${InteractiveOfficeLabels.rarity(selectedOption.rarity)}',
      ],
      actions: [
        _ActionButton(
          label: showUnavailable ? '只看可分享' : '查看全部',
          onTap: () => onShowUnavailableChanged(!showUnavailable),
        ),
        _ActionButton(
          label: sort == 'preference' ? '按稀有度' : '按偏好',
          onTap: () =>
              onSortChanged(sort == 'preference' ? 'rarity' : 'preference'),
        ),
        _ActionButton(
          label: pending ? '正在分享' : '确认分享',
          tooltip: selectedOption == null
              ? '请选择一条可以分享的鱼获'
              : '确认把 ${selectedOption.name} 分享给居民。数量 ${selectedOption.quantity} 条。',
          disabled:
              pending || selectedOption == null || !selectedOption.available,
          loading: pending,
          onTap: () => onConfirm(selectedOption!),
        ),
        for (final item in visible.take(4))
          _ActionButton(
            label: item.fishId == (selectedOption?.fishId ?? '')
                ? '${item.name} · 已选'
                : item.name,
            disabled: !item.available,
            onTap: () => onSelected(item.fishId),
          ),
        _ActionButton(label: '取消', onTap: onCancel),
      ],
    );
  }

  List<FishShareOptionView> _visibleOptions() {
    final list = options
        .where((item) => showUnavailable || item.available)
        .toList(growable: true);
    list.sort((a, b) {
      if (sort == 'rarity') {
        final rarity = _rarityRank(b.rarity).compareTo(_rarityRank(a.rarity));
        if (rarity != 0) return rarity;
        return a.name.compareTo(b.name);
      }
      final preference = b.preferenceScore.compareTo(a.preferenceScore);
      if (preference != 0) return preference;
      return a.name.compareTo(b.name);
    });
    return list;
  }
}

class _GroupsSection extends StatelessWidget {
  const _GroupsSection({
    required this.groups,
    required this.onAction,
    required this.pendingActionIds,
  });

  final List<OfficeGroupView> groups;
  final ValueChanged<PlayerActionRequest> onAction;
  final Set<String> pendingActionIds;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const _EmptyState(title: '当前没有群体活动', body: '也许过一会儿茶水间会热闹起来。');
    }
    return ListView(
      children: [
        for (final view in groups.take(5)) ...[
          _InfoCard(
            title: view.group.topic.isEmpty
                ? view.group.activity
                : view.group.topic,
            subtitle:
                '${_locationText(view.group.locationId)} · ${view.group.members.length} 人 · ${InteractiveOfficeLabels.mood(view.group.mood)}',
            body:
                '${view.possibleImpact}\n${view.canJoin ? view.joinCondition : '暂时不适合加入：${view.joinCondition}'}',
            maxBodyLines: 4,
            tags: [
              view.group.activity,
              '预计到 ${view.group.expectedEndTime}',
              view.canJoin ? '可加入' : '先观察',
            ],
            important: view.group.importance >= 70,
            actions: ['join_group', 'observe_group'].map((action) {
              final id = _requestId(action, view.group.groupId);
              final pending = pendingActionIds.contains(id);
              return _ActionButton(
                label: InteractiveOfficeLabels.action(action),
                tooltip:
                    view.canJoin ? view.possibleImpact : view.joinCondition,
                disabled: pending || (!view.canJoin && action == 'join_group'),
                loading: pending,
                onTap: () => onAction(PlayerActionRequest(
                  actionId: id,
                  actionType: action,
                  targetGroupId: view.group.groupId,
                )),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _EventsSection extends StatelessWidget {
  const _EventsSection({
    required this.events,
    required this.onAction,
    required this.pendingActionIds,
  });

  final List<OfficeEventView> events;
  final ValueChanged<PlayerActionRequest> onAction;
  final Set<String> pendingActionIds;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const _EmptyState(title: '当前没有办公室事件', body: '今天的办公室暂时没有波澜。');
    }
    return ListView(
      children: [
        for (final event in events.take(5)) ...[
          _InfoCard(
            title: event.title,
            subtitle: event.locationId.isEmpty
                ? '办公室事件'
                : _locationText(event.locationId),
            body:
                '${event.summary.isEmpty ? event.possibleImpact : event.summary}\n可能影响：${event.possibleImpact}',
            maxBodyLines: 5,
            tags: [
              _importanceText(event.importance),
              if (event.residentIds.isNotEmpty)
                '涉及 ${event.residentIds.length} 位居民',
            ],
            important: event.importance >= 70,
            actions: event.availableActions.take(3).map((action) {
              final id = _requestId(action, event.id);
              final pending = pendingActionIds.contains(id);
              return _ActionButton(
                label: InteractiveOfficeLabels.action(action),
                disabled: pending,
                loading: pending,
                tooltip: event.possibleImpact,
                onTap: () => onAction(PlayerActionRequest(
                  actionId: id,
                  actionType: action,
                  targetEventId: event.id,
                )),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _CareerSection extends StatelessWidget {
  const _CareerSection({required this.snapshot, required this.onAction});

  final InteractiveOfficeSnapshot snapshot;
  final ValueChanged<PlayerActionRequest> onAction;

  @override
  Widget build(BuildContext context) {
    final career = snapshot.playerCareer;
    return ListView(
      children: [
        _InfoCard(
          title: '职业反馈',
          subtitle:
              '${career.jobTitle} · ${career.promotionEligible ? '可以尝试晋升' : '继续积累中'}',
          body:
              '绩效 ${career.performanceScore}：${_levelDescription('productivity', career.performanceScore)}\n'
              '经验 ${career.experience} · 工资周期 ${career.salary} 摸鱼币\n'
              '${career.promotionEligible ? '晋升条件已基本满足，可以尝试申请。' : '距离下一阶段还需要更多职业经验、任务或技能积累。'}',
          tags: [
            '职业等级 ${career.levelIndex + 1}',
            '晋升 ${career.promotionProgress}%',
            if (career.lastSalaryDate.isNotEmpty)
              '最近工资 ${career.lastSalaryDate}',
          ],
          actions: [
            SizedBox(
              width: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 7,
                  value: career.promotionProgress.clamp(0, 100) / 100,
                  color: career.promotionEligible
                      ? _OfficeUi.success
                      : _OfficeUi.blue,
                  backgroundColor: const Color(0xFFE4CCA0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: _OfficeUi.gap),
        _InfoCard(
          title: '技能',
          subtitle: '这些不是压力，只是你在第二世界慢慢擅长的事',
          body: snapshot.playerSkills.values.isEmpty
              ? '还没有明显的技能成长。多和居民聊聊、钓钓鱼，世界会慢慢记住。'
              : snapshot.playerSkills.values
                  .map((skill) =>
                      '${InteractiveOfficeLabels.skill(skill.skillId)} Lv.${skill.level} · ${skill.progress}% · ${_skillEffectText(skill.skillId)}')
                  .take(6)
                  .join('\n'),
          maxBodyLines: 8,
          tags: snapshot.playerSkills.values
              .take(4)
              .map((skill) =>
                  '${InteractiveOfficeLabels.skill(skill.skillId)} ${skill.progress}%')
              .toList(),
          actions: const [],
        ),
        const SizedBox(height: _OfficeUi.gap),
        Align(
          alignment: Alignment.centerRight,
          child: FishingPrimaryButton(
            label: career.promotionEligible ? '尝试晋升' : '查看晋升准备',
            onPressed: () => onAction(PlayerActionRequest(
              actionId: _requestId('promote_career', career.careerLevel),
              actionType: 'promote_career',
            )),
          ),
        ),
      ],
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.snapshot});

  final InteractiveOfficeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.officeWorldHistory.isEmpty) {
      return const _EmptyState(title: '还没有办公室历史', body: '等世界慢慢运行几天，这里会留下痕迹。');
    }
    return ListView(
      children: [
        for (final item in snapshot.officeWorldHistory.take(8)) ...[
          _InfoCard(
            title: item.date,
            subtitle: InteractiveOfficeLabels.mood(item.mood),
            body:
                '${item.summary.isEmpty ? '这一天安静地过去了。' : item.summary}\n玩家影响：${item.playerImpact.isEmpty ? '安静地经过。' : item.playerImpact}',
            maxBodyLines: 5,
            tags: [
              '主导情绪 ${InteractiveOfficeLabels.mood(item.mood)}',
              if (item.playerImpact.isNotEmpty) '有玩家影响',
            ],
            actions: const [],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.result});

  final PlayerActionResult result;

  @override
  Widget build(BuildContext context) {
    final positive = <String>[
      ...result.positiveChanges,
      ...result.friendshipChanges,
      ...result.skillChanges,
      ...result.careerChanges,
      ...result.questChanges,
      ...result.achievementChanges,
      ...result.memoryChanges,
      ...result.reputationChanges,
      ...result.officeInfluenceChanges,
    ].where((item) => item.trim().isNotEmpty).toList(growable: false);
    final neutral = <String>[
      ...result.neutralChanges,
      ...result.worldStateChanges,
      ...result.cooldownChanges,
    ].where((item) => item.trim().isNotEmpty).toList(growable: false);
    final blocked = <String>[
      ...result.blockedReasons,
      ...result.negativeChanges,
      ...result.warnings,
    ].where((item) => item.trim().isNotEmpty).toList(growable: false);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _OfficeUi.paper,
        borderRadius: BorderRadius.circular(_OfficeUi.radius),
        border: Border.all(
          color: result.success ? _OfficeUi.success : _OfficeUi.warning,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusPill(
                label: result.success ? '完成' : '暂时受阻',
                tone: result.success ? _PillTone.green : _PillTone.gold,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: _OfficeUi.ink,
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (result.dialogue != null)
            _ResultGroup(title: '居民回应', lines: [result.dialogue!.text]),
          if (positive.isNotEmpty)
            _ResultGroup(title: '正向变化', lines: positive.take(4).toList()),
          if (neutral.isNotEmpty)
            _ResultGroup(title: '发生了什么', lines: neutral.take(3).toList()),
          if (blocked.isNotEmpty)
            _ResultGroup(title: '受阻原因', lines: blocked.take(3).toList()),
          if (result.recommendedNextActions.isNotEmpty)
            _ResultGroup(
              title: '下一步建议',
              lines: result.recommendedNextActions.take(3).toList(),
            ),
        ],
      ),
    );
  }
}

class _ResultGroup extends StatelessWidget {
  const _ResultGroup({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Text(
        '$title：${lines.join(' / ')}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: _OfficeUi.body.copyWith(fontSize: 12),
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({
    required this.title,
    required this.lines,
    this.emptyText = '暂无内容。',
  });

  final String title;
  final List<String> lines;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: title,
      subtitle: '',
      body: lines.isEmpty ? emptyText : lines.take(5).join('\n'),
      maxBodyLines: 6,
      actions: const [],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.actions,
    this.tags = const <String>[],
    this.important = false,
    this.maxBodyLines,
  });

  final String title;
  final String subtitle;
  final String body;
  final List<Widget> actions;
  final List<String> tags;
  final bool important;
  final int? maxBodyLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF7EBC8), Color(0xFFE9D09B)],
        ),
        borderRadius: BorderRadius.circular(_OfficeUi.radius),
        border: Border.all(
          color: important ? _OfficeUi.warning : _OfficeUi.line,
          width: important ? 1.8 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _OfficeUi.title,
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _OfficeUi.subtitle,
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 7),
            Wrap(
              spacing: 6,
              runSpacing: 5,
              children: [
                for (final tag
                    in tags.where((item) => item.trim().isNotEmpty).take(4))
                  _StatusPill(label: tag),
              ],
            ),
          ],
          if (body.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              body,
              maxLines: maxBodyLines ?? (body.contains('\n') ? 8 : 2),
              overflow: TextOverflow.ellipsis,
              style: _OfficeUi.body,
            ),
          ],
          if (actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(spacing: 8, runSpacing: 6, children: actions),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    this.disabled = false,
    this.loading = false,
    this.tooltip = '',
  });

  final String label;
  final VoidCallback onTap;
  final bool disabled;
  final bool loading;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !disabled,
      label: tooltip.isEmpty ? label : '$label，$tooltip',
      child: _SmallChip(
        label: loading ? '处理中' : label,
        selected: !disabled,
        onTap: disabled ? null : onTap,
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: selected
                  ? const LinearGradient(
                      colors: [Color(0xFF326FAF), Color(0xFF184A88)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFF8EDD0), Color(0xFFE0C58B)],
                    ),
              border: Border.all(color: const Color(0xFFF4D77E), width: 1.2),
            ),
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF17345F),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _InfoCard(
        title: title,
        subtitle: '可以稍后再试',
        body: body,
        maxBodyLines: 5,
        tags: const ['空状态'],
        actions: const [],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _InfoCard(
        title: title,
        subtitle: body,
        body: '请稍等一下。如果加载失败，可以关闭后重新打开。',
        tags: const ['加载中'],
        actions: const [
          SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              minHeight: 6,
              color: _OfficeUi.blue,
              backgroundColor: Color(0xFFE4CCA0),
            ),
          ),
        ],
      ),
    );
  }
}

enum _PillTone { blue, gold, green, red }

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, this.tone = _PillTone.gold});

  final String label;
  final _PillTone tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      _PillTone.blue => _OfficeUi.blue,
      _PillTone.green => _OfficeUi.success,
      _PillTone.red => _OfficeUi.danger,
      _PillTone.gold => _OfficeUi.warning,
    };
    return Semantics(
      label: '状态：$label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.72), width: 1),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

List<ResidentOfficeView> _residentFilteredSorted(
  InteractiveOfficeSnapshot snapshot,
  String filter,
  String sort,
) {
  final nearbyIds = snapshot.nearbyResidents.map((item) => item.id).toSet();
  final detailById = <String, ResidentDetailViewModel>{
    for (final detail in snapshot.residentDetails) detail.residentId: detail,
  };
  final list = snapshot.availableResidents.where((resident) {
    final detail = detailById[resident.id];
    switch (filter) {
      case 'nearby':
        return nearbyIds.contains(resident.id);
      case 'same_location':
        return resident.locationId == 'office' ||
            resident.locationId == 'pantry';
      case 'interactive':
        return detail?.availableInteractions.isNotEmpty ??
            resident.availableActions.isNotEmpty;
      case 'friends':
        return resident.friendshipStage == 'friend' ||
            resident.friendshipStage == 'close_friend' ||
            resident.friendshipStage == 'trusted_friend';
      case 'story':
        return detail?.recentStories.isNotEmpty ?? false;
      case 'event':
        return detail?.recentEvents.isNotEmpty ?? false;
      case 'rumor':
        return detail?.recentRumors.isNotEmpty ?? false;
      default:
        return true;
    }
  }).toList(growable: true);
  int friendshipRank(ResidentOfficeView item) {
    const order = <String>[
      'stranger',
      'acquaintance',
      'familiar',
      'friend',
      'close_friend',
      'trusted_friend',
    ];
    return order.indexOf(item.friendshipStage);
  }

  list.sort((a, b) {
    switch (sort) {
      case 'name':
        return a.name.compareTo(b.name);
      case 'friendship':
        return friendshipRank(b).compareTo(friendshipRank(a));
      case 'recent':
        return b.recentInteraction.compareTo(a.recentInteraction);
      case 'location':
        return a.locationName.compareTo(b.locationName);
      case 'interactive':
      default:
        final aCount = detailById[a.id]?.availableInteractions.length ??
            a.availableActions.length;
        final bCount = detailById[b.id]?.availableInteractions.length ??
            b.availableActions.length;
        return bCount.compareTo(aCount);
    }
  });
  return list;
}

String _levelText(int value) {
  if (value >= 70) return '很高';
  if (value >= 40) return '较高';
  if (value >= 15) return '正在建立';
  return '还需要时间';
}

String _employmentStatusLabel(String value) {
  return const <String, String>{
        'active': '在职',
        'probation': '试用期',
        'transferred': '已转岗',
        'demoted': '调整中',
        'resigned': '已离职',
        'recruiting': '招聘中',
      }[value] ??
      (value.isEmpty ? '在职' : value);
}

String _careerEventLabel(String value) {
  return const <String, String>{
        'hire': '入职',
        'promotion': '晋升',
        'transfer': '转岗',
        'demotion': '降职',
        'resignation': '离职',
        'recruitment': '招聘',
      }[value] ??
      (value.isEmpty ? '入职' : value);
}

String _officeMoodDescription(String mood) {
  return const <String, String>{
        'calm': '今天办公室节奏平稳，适合慢慢观察和轻松交流。',
        'happy': '办公室里有轻松气氛，居民更愿意聊几句。',
        'busy': '今天事情比较多，适合短互动或帮一点小忙。',
        'tense': '会议和任务让气氛略紧，行动要更温和。',
        'social': '今天大家更愿意聚在一起，群体活动更容易出现。',
        'quiet': '办公室很安静，适合等待、观察和听故事。',
        'festive': '节日气氛正在影响办公室，居民可能更愿意分享小事。',
      }[mood] ??
      '办公室正在按照今天的世界状态自然运转。';
}

String _levelDescription(String type, int value) {
  final level = value >= 75
      ? 'high'
      : value >= 45
          ? 'mid'
          : 'low';
  final table = <String, Map<String, String>>{
    'activity': {
      'high': '大家来来往往，今天很容易遇见小事。',
      'mid': '办公室有稳定的生活节奏。',
      'low': '今天偏安静，适合慢慢等待。',
    },
    'productivity': {
      'high': '整体运转顺畅，工作邀请更容易出现。',
      'mid': '工作节奏正常，没有明显压力。',
      'low': '大家的效率放慢了，适合休息和交流。',
    },
    'social': {
      'high': '社交气氛活跃，传闻和群体活动更容易流动。',
      'mid': '居民偶尔聊天，关系会慢慢升温。',
      'low': '大家更专注自己的事，互动要轻一点。',
    },
    'tension': {
      'high': '会议与加班让气氛有些紧张。',
      'mid': '有一点忙，但还在可控范围内。',
      'low': '没有明显紧张感，今天适合放松。',
    },
  };
  return table[type]?[level] ?? '当前状态稳定。';
}

String _skillEffectText(String id) {
  return const <String, String>{
        'fishing': '让钓鱼经验更稳定。',
        'communication': '略微提高与居民互动的质量。',
        'observation': '更容易发现隐藏线索。',
        'efficiency': '处理办公室小事更从容。',
        'management': '更适合组织会议和群体活动。',
        'luck': '让偶然的小惊喜更容易被注意到。',
      }[id] ??
      '这项能力正在慢慢成长。';
}

String _locationText(String id) {
  return const <String, String>{
        'office': '办公区',
        'meeting_room': '会议室',
        'pantry': '茶水间',
        'printing_area': '打印区',
        'manager_room': '经理办公室',
        'balcony': '阳台',
        'elevator': '电梯口',
        'restroom': '休息区',
        'reception': '前台',
        'workstation': '工位',
        'home': '家',
        'park': '公园',
        'coffee_shop': '咖啡店',
        'shop': '商店',
        'seaside': '海边',
        'dock': '码头',
        'sea': '海边',
      }[id] ??
      (id.isEmpty ? '办公室' : id);
}

String _importanceText(int value) {
  if (value >= 80) return '重要事件';
  if (value >= 55) return '值得关注';
  return '普通事件';
}

int _rarityRank(String rarity) {
  return const <String, int>{
        'mythic': 6,
        'mythical': 6,
        'legendary': 5,
        'legend': 5,
        'epic': 4,
        'rare': 3,
        'uncommon': 2,
        'common': 1,
      }[rarity] ??
      1;
}

String _shareFishRequestId(String residentId, String fishId) {
  final day = DateTime.now().toIso8601String().substring(0, 10);
  return 'share_fish_${residentId}_${fishId}_$day';
}

String _requestId(String action, String target) {
  return '${action}_${target}_${DateTime.now().millisecondsSinceEpoch}';
}
