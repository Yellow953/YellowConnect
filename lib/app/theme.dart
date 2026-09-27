import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';

abstract final class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: AppColors.black,
      onPrimary: AppColors.white,
      secondary: AppColors.yellow,
      onSecondary: AppColors.black,
      surface: AppColors.background,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.text2,
      outline: AppColors.divider,
      outlineVariant: AppColors.divider,
      error: AppColors.red,
    );

    final buttonText = AppText.style(17, weight: FontWeight.w600);
    const buttonSize = Size.fromHeight(56);

    return ThemeData(
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.yellow,
          foregroundColor: AppColors.black,
          disabledBackgroundColor: AppColors.track,
          disabledForegroundColor: AppColors.text2,
          minimumSize: buttonSize,
          shape: const StadiumBorder(),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.divider, width: 1.5),
          minimumSize: buttonSize,
          shape: const StadiumBorder(),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.text2,
          minimumSize: const Size.fromHeight(48),
          textStyle: AppText.style(15, weight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.yellow
              : const Color(0xFFE3E3E8),
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.yellow,
        linearTrackColor: AppColors.track,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.black,
        contentTextStyle: AppText.style(
          15,
          weight: FontWeight.w600,
          color: AppColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
        shape: const StadiumBorder(),
      ),
    );
  }
}
