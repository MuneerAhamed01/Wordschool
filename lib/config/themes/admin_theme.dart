import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/config/themes/fonts.dart';

/// Dark theme for the admin panel, built on the crossword tokens.
ThemeData adminTheme() {
  const scheme = ColorScheme.dark(
    primary: MyColors.buttonFill,
    onPrimary: MyColors.white,
    secondary: MyColors.hint,
    onSecondary: MyColors.gameBackground,
    tertiary: MyColors.infoText,
    error: MyColors.errorText,
    onError: MyColors.gameBackground,
    surface: MyColors.gameBackground,
    onSurface: MyColors.white,
    surfaceContainerLowest: MyColors.gameBackground,
    surfaceContainerLow: MyColors.gameSurface,
    surfaceContainer: MyColors.gameSurface,
    surfaceContainerHigh: MyColors.gameSurfaceElevated,
    surfaceContainerHighest: MyColors.gameSurfaceElevated,
    onSurfaceVariant: MyColors.textSecondary,
    outline: MyColors.gameBorder,
    outlineVariant: MyColors.gameBorderSubtle,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  final radius = BorderRadius.circular(12);

  return base.copyWith(
    scaffoldBackgroundColor: MyColors.gameBackground,
    textTheme: base.textTheme.nunito,
    cardTheme: CardThemeData(
      color: MyColors.gameSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: MyColors.gameBorderSubtle),
      ),
    ),
    dividerTheme: const DividerThemeData(color: MyColors.gameBorderSubtle),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MyColors.gameSurfaceElevated,
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: MyColors.gameBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: MyColors.gameBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: MyColors.accentGlow, width: 2),
      ),
      labelStyle: const TextStyle(color: MyColors.textSecondary),
      helperStyle: const TextStyle(color: MyColors.navInactive),
      hintStyle: const TextStyle(color: MyColors.navInactive),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 44),
        foregroundColor: MyColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: const BorderSide(color: MyColors.gameBorder),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        foregroundColor: MyColors.accentGlow,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: MyColors.gameSurfaceElevated,
      selectedColor: MyColors.successBg,
      side: const BorderSide(color: MyColors.gameBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: MyColors.gameSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: MyColors.navBarBackground,
      indicatorColor: MyColors.successBg,
      selectedIconTheme: IconThemeData(color: MyColors.successText),
      unselectedIconTheme: IconThemeData(color: MyColors.navInactive),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    tooltipTheme:
        const TooltipThemeData(waitDuration: Duration(milliseconds: 400)),
  );
}
