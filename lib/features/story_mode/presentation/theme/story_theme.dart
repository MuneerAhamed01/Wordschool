import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wordshool/config/themes/colors.dart';

/// Noir detective theme applied only to story mode routes.
class StoryTheme {
  StoryTheme._();

  static const Color background = Color(0xFF0A0A0C);
  static const Color surface = Color(0xFF141418);
  static const Color narrativeText = Color(0xFFD4CFC4);
  static const Color accent = Color(0xFFC9A227);

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      surface: surface,
      onSurface: narrativeText,
      primary: accent,
      onPrimary: background,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: narrativeText,
        elevation: 0,
      ),
    );

    final typewriter = GoogleFonts.specialEliteTextTheme(base.textTheme).apply(
      bodyColor: narrativeText,
      displayColor: narrativeText,
    );

    return base.copyWith(
      textTheme: typewriter,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: background,
        ),
      ),
      dividerColor: MyColors.gameBorder,
    );
  }
}
