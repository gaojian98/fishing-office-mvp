import 'package:flutter/material.dart';

import 'app_color.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColor.primary,
      primary: AppColor.primary,
      secondary: AppColor.secondary,
      tertiary: AppColor.accent,
      surface: AppColor.white,
      error: AppColor.error,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColor.pageBackground,
      fontFamily: AppTypography.chineseFont,
      textTheme: TextTheme(
        displayLarge: AppTypography.display,
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.caption,
        labelLarge: AppTypography.button,
        labelMedium: AppTypography.buttonSmall,
      ),
      dividerTheme: const DividerThemeData(color: AppColor.divider, thickness: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColor.white,
        surfaceTintColor: AppColor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColor.textPrimary,
        contentTextStyle: AppTypography.body.copyWith(color: AppColor.white),
      ),
    );
  }
}
