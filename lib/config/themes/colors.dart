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
}
