import 'package:flutter/material.dart';

import '../app_color.dart';
import '../app_typography.dart';
import '../icons/fishing_icon.dart';

class FishingButtonPressed extends StatefulWidget {
  const FishingButtonPressed({
    super.key,
    required this.child,
    required this.onPressed,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 150),
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double scale;
  final Duration duration;
  final String? semanticLabel;

  @override
  State<FishingButtonPressed> createState() => _FishingButtonPressedState();
}

class _FishingButtonPressedState extends State<FishingButtonPressed> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.onPressed == null ? null : (_) => setState(() => _pressed = true),
        onTapCancel: widget.onPressed == null ? null : () => setState(() => _pressed = false),
        onTapUp: widget.onPressed == null ? null : (_) => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          duration: widget.duration,
          scale: _pressed ? widget.scale : 1,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

class FishingPrimaryButton extends StatelessWidget {
  const FishingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.iconId,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? iconId;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return FishingButtonPressed(
      onPressed: onPressed,
      semanticLabel: semanticLabel ?? label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: AppColor.primaryButton,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconId != null) ...[
              FishingIconWidget(iconId: iconId!, size: 24, color: AppColor.textPrimary),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppTypography.buttonLarge.copyWith(color: AppColor.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class FishingSecondaryButton extends StatelessWidget {
  const FishingSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.iconId,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? iconId;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return FishingButtonPressed(
      onPressed: onPressed,
      semanticLabel: semanticLabel ?? label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColor.secondaryButton,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconId != null) ...[
              FishingIconWidget(iconId: iconId!, size: 20, color: AppColor.white),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppTypography.button.copyWith(color: AppColor.white)),
          ],
        ),
      ),
    );
  }
}

class FishingTextButton extends StatelessWidget {
  const FishingTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return FishingButtonPressed(
      onPressed: onPressed,
      semanticLabel: semanticLabel ?? label,
      child: Text(
        label,
        style: AppTypography.button.copyWith(color: AppColor.link),
      ),
    );
  }
}

class FishingIconButton extends StatelessWidget {
  const FishingIconButton({
    super.key,
    required this.iconId,
    required this.onPressed,
    this.semanticLabel,
  });

  final String iconId;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return FishingButtonPressed(
      onPressed: onPressed,
      semanticLabel: semanticLabel ?? iconId,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: FishingIconWidget(iconId: iconId, size: 24),
      ),
    );
  }
}

class FishingFloatingButton extends StatelessWidget {
  const FishingFloatingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.iconId,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? iconId;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return FishingButtonPressed(
      onPressed: onPressed,
      semanticLabel: semanticLabel ?? label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColor.primaryButton,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconId != null) ...[
              FishingIconWidget(iconId: iconId!, size: 24, color: AppColor.textPrimary),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppTypography.buttonLarge.copyWith(color: AppColor.textPrimary)),
          ],
        ),
      ),
    );
  }
}
