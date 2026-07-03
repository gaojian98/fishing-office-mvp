import 'package:flutter/material.dart';

import 'app_color.dart';

class AppTypography {
  static const String chineseFont = 'Noto Sans SC';
  static const String englishFont = 'Inter';
  static const String numberFont = 'DIN';

  static TextStyle get display => _style(
        size: 36,
        weight: FontWeight.bold,
        height: 1.2,
      );

  static TextStyle get h1 => _style(
        size: 28,
        weight: FontWeight.bold,
        height: 1.3,
      );

  static TextStyle get h2 => _style(
        size: 24,
        weight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get h3 => _style(
        size: 20,
        weight: FontWeight.w600,
        height: 1.35,
      );

  static TextStyle get bodyLarge => _style(
        size: 18,
        weight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get body => _style(
        size: 16,
        weight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get caption => _style(
        size: 14,
        weight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get small => _style(
        size: 12,
        weight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get buttonLarge => _style(
        size: 18,
        weight: FontWeight.w600,
        height: 1.2,
      );

  static TextStyle get button => _style(
        size: 16,
        weight: FontWeight.w500,
        height: 1.2,
      );

  static TextStyle get buttonSmall => _style(
        size: 14,
        weight: FontWeight.w500,
        height: 1.2,
      );

  static TextStyle _style({
    required double size,
    required FontWeight weight,
    required double height,
    Color color = AppColor.textPrimary,
    String? fontFamily,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      fontFamily: fontFamily ?? chineseFont,
      package: null,
      letterSpacing: 0,
    );
  }

  static TextStyle number({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    Color color = AppColor.textPrimary,
    double height = 1.2,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      fontFamily: numberFont,
      letterSpacing: 0,
    );
  }
}
