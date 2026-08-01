import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/bootstrap/fishing_office_scope.dart';
import '../../core/managers/app_managers.dart';
import '../../models/layout_config.dart';
import '../../models/transaction_config.dart';

class ProfileTransactionRecordsDialogPage extends StatefulWidget {
  const ProfileTransactionRecordsDialogPage({
    super.key,
    required this.transactions,
    required this.layout,
    required this.manager,
  });

  final TransactionConfig transactions;
  final LayoutConfig layout;
  final TransactionManagerView manager;

  @override
  State<ProfileTransactionRecordsDialogPage> createState() =>
      _ProfileTransactionRecordsDialogPageState();
}

class _ProfileTransactionRecordsDialogPageState
    extends State<ProfileTransactionRecordsDialogPage> {
  String _selectedFilterId = 'all';
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedFilterId = widget.manager.activeFilter;
  }

  @override
  Widget build(BuildContext context) {
    final scope = FishingOfficeScope.of(context);
    final scale = scope.responsive.scale;
    final screen = MediaQuery.sizeOf(context);
    final dialog = widget.layout.byId('profile_transactions_dialog');
    final header = widget.layout.byId('profile_transactions_header');
    final subtitle = widget.layout.byId('profile_transactions_subtitle');
    final close = widget.layout.byId('profile_transactions_close');
    final filters = widget.layout.byId('profile_transactions_filters');
    final list = widget.layout.byId('profile_transactions_list');
    final footer = widget.layout.byId('profile_transactions_footer');
    final prev = widget.layout.byId('profile_transactions_prev');
    final next = widget.layout.byId('profile_transactions_next');
    final pageInfo = widget.layout.byId('profile_transactions_page_info');
    final empty = widget.layout.byId('profile_transactions_empty');
    final filterAll = widget.layout.byId('profile_transactions_filter_all');
    final filterIncome =
        widget.layout.byId('profile_transactions_filter_income');
    final filterExpense =
        widget.layout.byId('profile_transactions_filter_expense');
    final filterReward =
        widget.layout.byId('profile_transactions_filter_reward');
    final filterPurchase =
        widget.layout.byId('profile_transactions_filter_purchase');

    final dialogRect = dialog?.rect ??
        Rect.fromLTWH(24, 88, math.min(screen.width * 0.92, 1032),
            math.min(screen.height * 0.86, 1744));
    final dialogWidth = dialogRect.width * scale;
    final dialogHeight = dialogRect.height * scale;
    final pageSize = widget.transactions.pageSize;

    final filterItems = widget.transactions.filters.items;

    return SizedBox.expand(
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xE6192E43),
                    Color(0xDD102537),
                    Color(0xF00A1521),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0.94, end: 1),
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Container(
                width: dialogWidth,
                height: dialogHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32 * scale),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF5E2BA),
                      Color(0xFFE2C37C),
                      Color(0xFFC59649),
                    ],
                  ),
                  border:
                      Border.all(color: const Color(0xFFF6DC8B), width: 2.4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.32),
                      blurRadius: 36,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: AnimatedBuilder(
                  animation: widget.manager,
                  builder: (context, child) {
                    final currentPageRecords =
                        widget.manager.filteredRecords(_selectedFilterId);
                    final currentPageCount = currentPageRecords.isEmpty
                        ? 1
                        : ((currentPageRecords.length - 1) ~/ pageSize) + 1;
                    if (_pageIndex >= currentPageCount) {
                      _pageIndex = currentPageCount - 1;
                    }
                    final records = currentPageRecords.isEmpty
                        ? <TransactionRecord>[]
                        : currentPageRecords
                            .skip(_pageIndex * pageSize)
                            .take(pageSize)
                            .toList(growable: false);

                    return Stack(
                      children: [
                        if (header != null)
                          Positioned.fromRect(
                            rect: _localRect(header.rect, dialogRect, scale),
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF163D73),
                                    Color(0xFF245A98),
                                    Color(0xFF132E56)
                                  ],
                                ),
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color(0xFFF3D47C), width: 2)),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24 * scale),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.transactions.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 34 * scale,
                                          fontWeight: FontWeight.w900,
                                          shadows: const [
                                            Shadow(
                                                color: Color(0xAA000000),
                                                blurRadius: 8,
                                                offset: Offset(0, 2)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (close != null)
                                      _TransactionTopButton(
                                        label: widget
                                            .transactions.footer.closeLabel,
                                        icon: Icons.close_rounded,
                                        rect: _localRect(
                                            close.rect, dialogRect, scale),
                                        scale: scale,
                                        onTap: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (subtitle != null)
                          Positioned(
                            left: subtitle.rect.left * scale -
                                dialogRect.left * scale,
                            top: subtitle.rect.top * scale -
                                dialogRect.top * scale,
                            width: subtitle.rect.width * scale,
                            height: subtitle.rect.height * scale,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.transactions.subtitle,
                                style: TextStyle(
                                  color: const Color(0xFF16335D),
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        if (filters != null)
                          Positioned.fromRect(
                            rect: _localRect(filters.rect, dialogRect, scale),
                            child: _TransactionFilterBar(
                              filters: filterItems,
                              selectedFilterId: _selectedFilterId,
                              scale: scale,
                              originRect: filters.rect,
                              filterRects: [
                                filterAll,
                                filterIncome,
                                filterExpense,
                                filterReward,
                                filterPurchase,
                              ],
                              onSelected: (filterId) {
                                setState(() {
                                  _selectedFilterId = filterId;
                                  _pageIndex = 0;
                                });
                                widget.manager.setFilter(filterId);
                              },
                            ),
                          ),
                        if (list != null)
                          Positioned.fromRect(
                            rect: _localRect(list.rect, dialogRect, scale),
                            child: records.isEmpty
                                ? Stack(
                                    children: [
                                      Positioned.fromRect(
                                        rect: _localRect(
                                            empty?.rect ??
                                                Rect.fromLTWH(
                                                    0,
                                                    0,
                                                    list.rect.width,
                                                    list.rect.height),
                                            list.rect,
                                            scale),
                                        child: _TransactionEmptyState(
                                          title: widget
                                              .transactions.emptyState.title,
                                          body: widget
                                              .transactions.emptyState.body,
                                          buttonLabel: widget.transactions
                                              .emptyState.buttonLabel,
                                          onBeginFishing: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(context)
                                                .pushNamed('/fishing');
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                : _TransactionList(
                                    records: records,
                                    columns: widget.transactions.columns,
                                    scale: scale,
                                  ),
                          ),
                        if (footer != null)
                          Positioned.fromRect(
                            rect: _localRect(footer.rect, dialogRect, scale),
                            child: Stack(
                              children: [
                                if (prev != null)
                                  Positioned.fromRect(
                                    rect: _localRect(
                                        prev.rect, footer.rect, scale),
                                    child: _TransactionFooterButton(
                                      label:
                                          widget.transactions.footer.prevLabel,
                                      icon: Icons.chevron_left_rounded,
                                      enabled: _pageIndex > 0,
                                      onTap: _pageIndex > 0
                                          ? () => setState(() {
                                                _pageIndex -= 1;
                                              })
                                          : null,
                                    ),
                                  ),
                                if (pageInfo != null)
                                  Positioned.fromRect(
                                    rect: _localRect(
                                        pageInfo.rect, footer.rect, scale),
                                    child: Center(
                                      child: Text(
                                        widget.transactions.pageInfoLabel(
                                            _pageIndex + 1, currentPageCount),
                                        style: TextStyle(
                                          color: const Color(0xFF16335D),
                                          fontSize: 18 * scale,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (next != null)
                                  Positioned.fromRect(
                                    rect: _localRect(
                                        next.rect, footer.rect, scale),
                                    child: _TransactionFooterButton(
                                      label:
                                          widget.transactions.footer.nextLabel,
                                      icon: Icons.chevron_right_rounded,
                                      enabled:
                                          _pageIndex < currentPageCount - 1,
                                      onTap: _pageIndex < currentPageCount - 1
                                          ? () => setState(() {
                                                _pageIndex += 1;
                                              })
                                          : null,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Rect _localRect(Rect rect, Rect origin, double scale) {
  return Rect.fromLTWH(
    (rect.left - origin.left) * scale,
    (rect.top - origin.top) * scale,
    rect.width * scale,
    rect.height * scale,
  );
}

class _TransactionFilterBar extends StatelessWidget {
  const _TransactionFilterBar({
    required this.filters,
    required this.selectedFilterId,
    required this.scale,
    required this.originRect,
    required this.filterRects,
    required this.onSelected,
  });

  final List<TransactionFilterItem> filters;
  final String selectedFilterId;
  final double scale;
  final Rect originRect;
  final List<LayoutElement?> filterRects;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (var index = 0;
            index < filters.length && index < filterRects.length;
            index++)
          if (filterRects[index] != null)
            Positioned.fromRect(
              rect: _localRect(filterRects[index]!.rect, originRect, scale),
              child: _TransactionFilterChip(
                label: filters[index].label,
                selected: selectedFilterId == filters[index].id,
                scale: scale,
                onTap: () => onSelected(filters[index].id),
              ),
            ),
      ],
    );
  }
}

class _TransactionFilterChip extends StatelessWidget {
  const _TransactionFilterChip({
    required this.label,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18 * scale),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: 12 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18 * scale),
            gradient: selected
                ? const LinearGradient(colors: [
                    Color(0xFFF6D780),
                    Color(0xFFE8B94C),
                    Color(0xFFDA9D20)
                  ])
                : const LinearGradient(
                    colors: [Color(0xFF315E99), Color(0xFF18477F)]),
            border: Border.all(
                color: selected
                    ? const Color(0xFFFFF0AA)
                    : const Color(0xFFF0D47A),
                width: 1.4),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? const Color(0x66F0C94B)
                    : Colors.black.withValues(alpha: 0.12),
                blurRadius: selected ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({
    required this.records,
    required this.columns,
    required this.scale,
  });

  final List<TransactionRecord> records;
  final TransactionColumns columns;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30 * scale),
        gradient: const LinearGradient(
          colors: [Color(0xFFF7E7CA), Color(0xFFE8C98B), Color(0xFFD5AB59)],
        ),
        border: Border.all(color: const Color(0xFFF8E3A0), width: 1.8),
      ),
      child: Column(
        children: [
          for (var index = 0; index < records.length; index++) ...[
            _TransactionCard(
              record: records[index],
              columns: columns,
              scale: scale,
            ),
            if (index < records.length - 1) SizedBox(height: 10 * scale),
          ],
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.record,
    required this.columns,
    required this.scale,
  });

  final TransactionRecord record;
  final TransactionColumns columns;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final signedAmount = record.amountLabel;
    final isExpense = record.isExpense;
    final amountColor =
        isExpense ? const Color(0xFFC83D2B) : const Color(0xFF1E8B53);
    final balanceColor = amountColor;
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18 * scale),
        color: const Color(0xFFF9F0DE),
        border: Border.all(
            color:
                isExpense ? const Color(0xFFE4B7A2) : const Color(0xFFCAE3C7),
            width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58 * scale,
            height: 58 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isExpense
                    ? [const Color(0xFFB94A39), const Color(0xFF7B251C)]
                    : [const Color(0xFF3C78B8), const Color(0xFF163B73)],
              ),
              border: Border.all(color: const Color(0xFFF5D98A), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              record.type.isNotEmpty ? record.type.substring(0, 1) : '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18 * scale,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: 14 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${columns.timeLabel} ${_formatTime(record.createdAt)}',
                        style: TextStyle(
                          color: const Color(0xFF7C6642),
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    Text(
                      '${columns.typeLabel} ${record.type}',
                      style: TextStyle(
                        color: const Color(0xFF18345F),
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6 * scale),
                Text(
                  '${columns.noteLabel} ${record.note.isNotEmpty ? record.note : record.itemName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF4B5D77),
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12 * scale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${columns.amountLabel} $signedAmount',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                '${columns.balanceLabel} $signedAmount',
                style: TextStyle(
                  color: balanceColor,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${time.year}-${twoDigits(time.month)}-${twoDigits(time.day)} ${twoDigits(time.hour)}:${twoDigits(time.minute)}';
  }
}

class _TransactionEmptyState extends StatelessWidget {
  const _TransactionEmptyState({
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onBeginFishing,
  });

  final String title;
  final String body;
  final String buttonLabel;
  final VoidCallback onBeginFishing;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFF7E7CA), Color(0xFFE8C98B), Color(0xFFD5AB59)],
        ),
        border: Border.all(color: const Color(0xFFF8E3A0), width: 1.8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF18345F),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF4B5D77),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _TransactionBeginButton(
            label: buttonLabel,
            onTap: onBeginFishing,
          ),
        ],
      ),
    );
  }
}

class _TransactionBeginButton extends StatelessWidget {
  const _TransactionBeginButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF2F74B5), Color(0xFF184E8B)],
            ),
            border: Border.all(color: const Color(0xFFF4D77E), width: 1.6),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionFooterButton extends StatelessWidget {
  const _TransactionFooterButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: enabled
                  ? [const Color(0xFF2F74B5), const Color(0xFF184E8B)]
                  : [const Color(0xFF8BA6C8), const Color(0xFF6F8FB8)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF4D77E), width: 1.6),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTopButton extends StatelessWidget {
  const _TransactionTopButton({
    required this.label,
    required this.icon,
    required this.rect,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Rect rect;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: rect.width,
      height: rect.height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18 * scale),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2F74B5), Color(0xFF184E8B)],
              ),
              borderRadius: BorderRadius.circular(18 * scale),
              border: Border.all(color: const Color(0xFFF4D77E), width: 1.6),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18 * scale),
                SizedBox(width: 6 * scale),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
