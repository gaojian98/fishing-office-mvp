import 'package:flutter/material.dart';

import '../app_color.dart';

class FishingIcon {
  static const String home = 'icon_home';
  static const String store = 'icon_store';
  static const String bag = 'icon_bag';
  static const String honor = 'icon_honor';
  static const String book = 'icon_book';
  static const String wallet = 'icon_wallet';
  static const String setting = 'icon_setting';
  static const String message = 'icon_message';
  static const String help = 'icon_help';
  static const String back = 'icon_back';
  static const String close = 'icon_close';
  static const String fish = 'icon_fish';
  static const String rod = 'icon_rod';
  static const String line = 'icon_line';
  static const String float = 'icon_float';
  static const String bait = 'icon_bait';
  static const String bucket = 'icon_bucket';
  static const String reward = 'icon_reward';
  static const String coin = 'icon_coin';
  static const String fishingCoin = 'icon_fishing_coin';
  static const String point = 'icon_point';
  static const String pc = 'icon_pc';
  static const String mouse = 'icon_mouse';
  static const String keyboard = 'icon_keyboard';
  static const String coffee = 'icon_coffee';
  static const String desk = 'icon_desk';
  static const String badge = 'icon_badge';
  static const String task = 'icon_task';
  static const String success = 'icon_success';
  static const String error = 'icon_error';
  static const String warning = 'icon_warning';
  static const String info = 'icon_info';
  static const String loading = 'icon_loading';
  static const String network = 'icon_network';
}

class FishingIconWidget extends StatelessWidget {
  const FishingIconWidget({
    super.key,
    required this.iconId,
    this.size = 24,
    this.color = AppColor.textPrimary,
    this.semanticLabel,
  });

  final String iconId;
  final double size;
  final Color color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? iconId,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size / 4),
            border: Border.all(color: color.withAlpha(64)),
          ),
          child: Center(
            child: Text(
              _glyphFor(iconId),
              style: TextStyle(
                color: color,
                fontSize: size * 0.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _glyphFor(String value) {
    final text = value.replaceFirst('icon_', '');
    if (text.isEmpty) return '?';
    return text.substring(0, 1).toUpperCase();
  }
}
