import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/bootstrap/fishing_office_scope.dart';
import '../../core/dialog/dialog_manager.dart';
import '../../core/managers/app_managers.dart';
import '../../models/layout_config.dart';
import '../../models/settings_config.dart';

class SettingsDialogPage extends StatefulWidget {
  const SettingsDialogPage({
    super.key,
    required this.settings,
    required this.layout,
    required this.manager,
    required this.dialogManager,
  });

  final SettingsConfig settings;
  final LayoutConfig layout;
  final SettingsManagerView manager;
  final DialogManager dialogManager;

  @override
  State<SettingsDialogPage> createState() => _SettingsDialogPageState();
}

class _SettingsDialogPageState extends State<SettingsDialogPage> {
  @override
  Widget build(BuildContext context) {
    final scope = FishingOfficeScope.of(context);
    final scale = scope.responsive.scale;
    final screen = MediaQuery.sizeOf(context);
    final dialog = widget.layout.byId('settings_dialog');
    final header = widget.layout.byId('settings_header');
    final title = widget.layout.byId('settings_title');
    final close = widget.layout.byId('settings_close');
    final panel = widget.layout.byId('settings_panel');
    final status = widget.layout.byId('settings_status');
    final footer = widget.layout.byId('settings_footer');
    final save = widget.layout.byId('settings_save');
    final restore = widget.layout.byId('settings_restore');
    final closeButton = widget.layout.byId('settings_close_button');

    final dialogWidth =
        (dialog?.rect.width ?? math.min(screen.width * 0.92, 1080)) * scale;
    final dialogHeight =
        (dialog?.rect.height ?? math.min(screen.height * 0.88, 1712)) * scale;

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
                    Color(0xE61B2F4A),
                    Color(0xCC17314A),
                    Color(0xD90D1E2E),
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
                      Color(0xFFF3E1B8),
                      Color(0xFFE1C27B),
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
                child: Stack(
                  children: [
                    if (panel != null)
                      Positioned(
                        left: panel.rect.left * scale,
                        top: panel.rect.top * scale,
                        width: panel.rect.width * scale,
                        height: panel.rect.height * scale,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28 * scale),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF8EDD0),
                                Color(0xFFEBCF95),
                                Color(0xFFD6AA5B)
                              ],
                            ),
                            border: Border.all(
                                color: const Color(0xFFF7E19C), width: 1.8),
                          ),
                        ),
                      ),
                    if (header != null)
                      Positioned(
                        left: header.rect.left * scale,
                        top: header.rect.top * scale,
                        width: header.rect.width * scale,
                        height: header.rect.height * scale,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
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
                        ),
                      ),
                    if (title != null)
                      Positioned(
                        left: title.rect.left * scale,
                        top: title.rect.top * scale,
                        width: title.rect.width * scale,
                        height: title.rect.height * scale,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.settings.title,
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
                      ),
                    if (close != null)
                      Positioned(
                        left: close.rect.left * scale,
                        top: close.rect.top * scale,
                        width: close.rect.width * scale,
                        height: close.rect.height * scale,
                        child: _SettingsIconButton(
                          label: widget.settings.closeLabel,
                          icon: Icons.close_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                    _SettingsContentLayer(
                      layout: widget.layout,
                      settings: widget.settings,
                      manager: widget.manager,
                      dialogManager: widget.dialogManager,
                      scale: scale,
                      dialogRect:
                          dialog?.rect ?? const Rect.fromLTWH(0, 0, 984, 1712),
                    ),
                    if (status != null)
                      Positioned(
                        left: status.rect.left * scale,
                        top: status.rect.top * scale,
                        width: status.rect.width * scale,
                        height: status.rect.height * scale,
                        child: AnimatedBuilder(
                          animation: widget.manager,
                          builder: (context, child) {
                            if (widget.manager.statusMessage.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8E9C8),
                                borderRadius: BorderRadius.circular(18 * scale),
                                border: Border.all(
                                    color: const Color(0xFFE0B765), width: 1.2),
                              ),
                              child: Center(
                                child: Text(
                                  widget.manager.statusMessage,
                                  style: TextStyle(
                                    color: const Color(0xFF70501A),
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (footer != null)
                      Positioned(
                        left: footer.rect.left * scale,
                        top: footer.rect.top * scale,
                        width: footer.rect.width * scale,
                        height: footer.rect.height * scale,
                        child: const SizedBox.shrink(),
                      ),
                    if (save != null)
                      Positioned(
                        left: save.rect.left * scale,
                        top: save.rect.top * scale,
                        width: save.rect.width * scale,
                        height: save.rect.height * scale,
                        child: _SettingsFooterButton(
                          label: widget.settings.footer.saveLabel,
                          primary: true,
                          onTap: () => widget.manager.save(),
                        ),
                      ),
                    if (restore != null)
                      Positioned(
                        left: restore.rect.left * scale,
                        top: restore.rect.top * scale,
                        width: restore.rect.width * scale,
                        height: restore.rect.height * scale,
                        child: _SettingsFooterButton(
                          label: widget.settings.footer.restoreLabel,
                          primary: false,
                          onTap: () async {
                            final confirmed = await widget.dialogManager
                                .showConfirmationDialog(
                              context,
                              title: widget.settings.confirmReset.title,
                              body: widget.settings.confirmReset.body,
                              confirmLabel:
                                  widget.settings.confirmReset.confirmLabel,
                              cancelLabel:
                                  widget.settings.confirmReset.cancelLabel,
                            );
                            if (!confirmed) return;
                            widget.manager.restoreDefaults();
                          },
                        ),
                      ),
                    if (closeButton != null)
                      Positioned(
                        left: closeButton.rect.left * scale,
                        top: closeButton.rect.top * scale,
                        width: closeButton.rect.width * scale,
                        height: closeButton.rect.height * scale,
                        child: _SettingsFooterButton(
                          label: widget.settings.footer.closeLabel,
                          primary: false,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsContentLayer extends StatelessWidget {
  const _SettingsContentLayer({
    required this.layout,
    required this.settings,
    required this.manager,
    required this.dialogManager,
    required this.scale,
    required this.dialogRect,
  });

  final LayoutConfig layout;
  final SettingsConfig settings;
  final SettingsManagerView manager;
  final DialogManager dialogManager;
  final double scale;
  final Rect dialogRect;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: manager,
      builder: (context, child) {
        final children = <Widget>[];
        for (final item in settings.items) {
          final rect = layout.byId('settings_${item.id}')?.rect;
          if (rect == null) continue;
          children.add(
            Positioned(
              left: (rect.left - dialogRect.left) * scale,
              top: (rect.top - dialogRect.top) * scale,
              width: rect.width * scale,
              height: rect.height * scale,
              child: _SettingsItemCard(
                item: item,
                value: manager.valueOf(item.id),
                scale: scale,
                onToggle: item.isToggle ? () => manager.toggle(item.id) : null,
                onSegmentSelected: item.isSegment
                    ? (value) => manager.select(item.id, value)
                    : null,
                onAction: item.id == 'clear_cache'
                    ? () async {
                        final confirmed =
                            await dialogManager.showConfirmationDialog(
                          context,
                          title: settings.confirmClearCache.title,
                          body: settings.confirmClearCache.body,
                          confirmLabel: settings.confirmClearCache.confirmLabel,
                          cancelLabel: settings.confirmClearCache.cancelLabel,
                        );
                        if (!confirmed) return;
                        manager.clearCache();
                      }
                    : item.id == 'back_profile'
                        ? () => Navigator.of(context).pop()
                        : null,
              ),
            ),
          );
        }
        return Stack(children: children);
      },
    );
  }
}

class _SettingsItemCard extends StatelessWidget {
  const _SettingsItemCard({
    required this.item,
    required this.value,
    required this.scale,
    required this.onToggle,
    required this.onSegmentSelected,
    required this.onAction,
  });

  final SettingsItem item;
  final String value;
  final double scale;
  final VoidCallback? onToggle;
  final ValueChanged<String>? onSegmentSelected;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isAction = item.isAction;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 180),
      tween: Tween<double>(begin: 1, end: 1),
      builder: (context, animatedScale, child) =>
          Transform.scale(scale: animatedScale, child: child),
      child: Container(
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22 * scale),
          gradient: const LinearGradient(
            colors: [Color(0xFFFDF4DC), Color(0xFFE9CD91)],
          ),
          border: Border.all(color: const Color(0xFFE2BF6A), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: isAction
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      color: const Color(0xFF18345F),
                      fontSize: 21 * scale,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (item.help.isNotEmpty)
                    Text(
                      item.help,
                      style: TextStyle(
                        color: const Color(0xFF5A6E8A),
                        fontSize: 13 * scale,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: _SettingsPillButton(
                      label: item.buttonLabel,
                      onTap: onAction,
                      primary: true,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      color: const Color(0xFF18345F),
                      fontSize: 21 * scale,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (item.help.isNotEmpty)
                    Text(
                      item.help,
                      style: TextStyle(
                        color: const Color(0xFF5A6E8A),
                        fontSize: 13 * scale,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (item.isToggle)
                    Row(
                      children: [
                        Expanded(
                          child: _SettingsChoiceChip(
                            label: item.onLabel,
                            selected: value == 'on',
                            onTap: () => onToggle?.call(),
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        Expanded(
                          child: _SettingsChoiceChip(
                            label: item.offLabel,
                            selected: value == 'off',
                            onTap: () => onToggle?.call(),
                          ),
                        ),
                      ],
                    )
                  else
                    Wrap(
                      spacing: 10 * scale,
                      runSpacing: 10 * scale,
                      children: [
                        for (final option in item.options)
                          _SettingsChoiceChip(
                            label: option.label,
                            selected: value == option.id,
                            onTap: () => onSegmentSelected?.call(option.id),
                          ),
                      ],
                    ),
                ],
              ),
      ),
    );
  }
}

class _SettingsChoiceChip extends StatelessWidget {
  const _SettingsChoiceChip({
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
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF3E7DC4), Color(0xFF184A88)])
                : const LinearGradient(
                    colors: [Color(0xFFF8EFD8), Color(0xFFE2C78B)]),
            border: Border.all(
              color:
                  selected ? const Color(0xFFF7DE95) : const Color(0xFFD8AE59),
              width: 1.4,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF6F9ED1).withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF18345F),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsPillButton extends StatelessWidget {
  const _SettingsPillButton({
    required this.label,
    required this.onTap,
    required this.primary,
  });

  final String label;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: primary
                ? const LinearGradient(
                    colors: [Color(0xFF3E7DC4), Color(0xFF184A88)])
                : const LinearGradient(
                    colors: [Color(0xFFF3E1B8), Color(0xFFE1C27B)]),
            border: Border.all(
              color:
                  primary ? const Color(0xFFF7DE95) : const Color(0xFFD8AE59),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: primary ? Colors.white : const Color(0xFF18345F),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsFooterButton extends StatelessWidget {
  const _SettingsFooterButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return primary
        ? _SettingsPillButton(label: label, onTap: onTap, primary: true)
        : _SettingsPillButton(label: label, onTap: onTap, primary: false);
  }
}

class _SettingsIconButton extends StatelessWidget {
  const _SettingsIconButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF3E7DC4), Color(0xFF184A88)],
            ),
            border: Border.all(color: const Color(0xFFF7DE95), width: 1.5),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
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
