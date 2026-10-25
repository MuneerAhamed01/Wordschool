import 'package:flutter/material.dart';

class MyColorScheme extends ColorScheme {
  const MyColorScheme({
    required super.brightness,
    required super.primary,
    required super.onPrimary,
    required super.secondary,
    required super.onSecondary,
    required super.error,
    required super.onError,
    required Color background,
    required Color onBackground,
    required super.surface,
    required super.onSurface,
  });

  factory MyColorScheme.light() {
    return const MyColorScheme(
      brightness: Brightness.light,
      primary: MyColors.green2,
      onPrimary: MyColors.white,
      secondary: MyColors.yellow2,
      onSecondary: MyColors.black,
      error: Colors.red,
      onError: MyColors.white,
      background: MyColors.lightGray,
      onBackground: MyColors.black,
      surface: MyColors.white,
      onSurface: MyColors.black,
    );
  }

  factory MyColorScheme.dark() {
    return const MyColorScheme(
      brightness: Brightness.dark,
      primary: MyColors.green3,
      onPrimary: MyColors.white,
      secondary: MyColors.yellow3,
      onSecondary: MyColors.white,
      error: Colors.red,
      onError: MyColors.white,
      background: MyColors.gray4,
      onBackground: MyColors.white,
      surface: MyColors.gray4,
      onSurface: MyColors.white,
    );
  }
}

class MyTheme {
  static ThemeData lightTheme() {
    final colorScheme = MyColorScheme.light();
    return ThemeData(
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: MyColors.gray3,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: MyColors.black),
        bodyMedium: TextStyle(color: MyColors.black),
      ),
      // Add more theme configurations as needed
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = MyColorScheme.dark();
    return ThemeData(
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: MyColors.white),
        bodyMedium: TextStyle(color: MyColors.white),
      ),
      // Add more theme configurations as needed
    );
  }
}

class MyColors {
  // Green shades
  static const Color green1 = Color(0xFF66CDAA);
  static const Color green2 = Color(0xFF3CB371);
  static const Color green3 = Color(0xFF2E8B57);
  static const Color green4 = Color(0xff189D7C);
  static const Color green5 = Color(0xff02C39A);

  // Yellow/Gold shades
  static const Color yellow1 = Color(0xFFFFD700);
  static const Color yellow2 = Color(0xFFDAA520);
  static const Color yellow3 = Color(0xFFB8860B);

  // Gray shades
  static const Color gray1 = Color(0xFFC0C0C0);
  static const Color gray2 = Color(0xFFA9A9A9);
  static const Color gray3 = Color(0xFF808080);
  static const Color gray4 = Color(0xff1D1F25);
  static const Color gray5 = Color(0xff48495F);
  static const Color gray6 = Color(0xff2D3047);

  // Blue/Navy shades
  static const Color navy1 = Color(0xFF4682B4);
  static const Color navy2 = Color(0xFF000080);
  static const Color navy3 = Color(0xFF696969);

  // Orange shades
  static const Color orange1 = Color(0xFFFFA500);
  static const Color orange2 = Color(0xFFFF8C00);
  static const Color orange3 = Color(0xFFD2691E);
  static const Color orange4 = Color(0xFFFDD85D);
  static const Color orange5 = Color(0xFFD9B952);

  // Light Blue shades
  static const Color lightBlue1 = Color(0xFF87CEEB);
  static const Color lightBlue2 = Color(0xFF4682B4);
  static const Color lightBlue3 = Color(0xFF1E90FF);

  // White, Black, Light Gray
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color lightGray = Color(0xFFD3D3D3);

  static const Color errorColor = Colors.red;

  // Professional game palette (Wordle-inspired, accessible contrast)
  static const Color gameBackground = Color(0xFF121213);
  static const Color gameSurface = Color(0xFF1A1A1B);
  static const Color gameSurfaceElevated = Color(0xFF252526);
  static const Color gameBorder = Color(0xFF3A3A3C);
  static const Color tileEmpty = Color(0xFF121213);
  static const Color tileFilled = Color(0xFF565658);
  static const Color tileCorrect = Color(0xFF538D4E);
  static const Color tilePresent = Color(0xFFB59F3B);
  static const Color tileAbsent = Color(0xFF3A3A3C);
  static const Color keyDefault = Color(0xFF818384);
  static const Color keyAction = Color(0xFF565658);
  static const Color textMuted = Color(0xFF818384);
  static const Color accentGlow = Color(0xFF6AAA64);
  static const Color streakAccent = Color(0xFFF5793A);
  static const Color gameBorderSubtle = Color(0xFF2E2E30);
  static const Color navBarBackground = Color(0xFF161617);
  static const Color navInactive = Color(0xFF9A9B9C);

  // PSC Crossword tokens (design/tokens/psc-crossword.tokens.json)
  static const Color buttonFill = Color(0xFF467A41);
  static const Color textSecondary = Color(0xFFA9A9AB);
  static const Color hint = Color(0xFFC9B458);
  static const Color gridCell = Color(0xFF2A2A2C);
  static const Color gridBlock = Color(0xFF0A0A0B);
  static const Color gridWordBg = Color(0xFF3A3524);
  static const Color gridWordBorder = Color(0xFF7C6C2A);
  static const Color gridWrongBg = Color(0xFF7A2A22);
  static const Color gridWrongBorder = Color(0xFFB54A3C);
  static const Color successBg = Color(0xFF253323);
  static const Color successText = Color(0xFF9FD39A);
  static const Color errorBg = Color(0xFF3A1F1B);
  static const Color errorText = Color(0xFFF2B8AE);
  static const Color warnBg = Color(0xFF3A3524);
  static const Color warnText = Color(0xFFE5D27A);
  static const Color sheetBackground = Color(0xFF1C1C1D);
  static const Color scrim = Color(0x9E000000);
  static const Color streakBg = Color(0xFF2A1E16);
  static const Color gridCellBorder = gameBorder;
  static const Color gridActiveBg = hint;
  static const Color gridActiveBorder = warnText;
  static const Color gridActiveText = gameBackground;
  static const Color gridCorrectBg = tileCorrect;
  static const Color gridRevealedText = Color(0xFF85C0F9);
  static const Color gridNumber = textSecondary;
  static const Color clueBarBg = Color(0xFF2B2719);
  static const Color clueBarBorder = Color(0xFF5C5224);
  static const Color clueBarLabel = warnText;
  static const Color crosswordKey = Color(0xFF58585A);
  static const Color crosswordKeyAction = tileCorrect;

  // Admin panel
  static const Color infoBg = Color(0xFF1B2A3A);
  static const Color infoText = Color(0xFF9CC4F2);
}
