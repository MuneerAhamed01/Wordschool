import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wordshool/config/themes/colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData gameDark() {
    const colorScheme = ColorScheme.dark(
      primary: MyColors.tileCorrect,
      onPrimary: MyColors.white,
      secondary: MyColors.tilePresent,
      onSecondary: MyColors.white,
      surface: MyColors.gameSurface,
      onSurface: MyColors.white,
      error: Colors.redAccent,
      onError: MyColors.white,
    );

    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: MyColors.gameBackground,
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: MyColors.white,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: MyColors.white,
        ),
        iconTheme: const IconThemeData(color: MyColors.white, size: 24),
      ),
      dividerTheme: const DividerThemeData(
        color: MyColors.gameBorder,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: MyColors.gameSurfaceElevated,
        contentTextStyle: GoogleFonts.inter(color: MyColors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: MyColors.accentGlow,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: MyColors.white,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: MyColors.white,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: MyColors.white,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: MyColors.white,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: MyColors.white,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: MyColors.white.withValues(alpha: 0.9),
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: MyColors.textMuted,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: MyColors.white,
      ),
    );
  }
}
