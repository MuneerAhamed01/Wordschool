import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension NunitoTextTheme on TextTheme {
  TextTheme get nunito {
    return copyWith(
      displayLarge: GoogleFonts.nunito(textStyle: displayLarge),
      displayMedium: GoogleFonts.nunito(textStyle: displayMedium),
      displaySmall: GoogleFonts.nunito(textStyle: displaySmall),
      headlineLarge: GoogleFonts.nunito(textStyle: headlineLarge),
      headlineMedium: GoogleFonts.nunito(textStyle: headlineMedium),
      headlineSmall: GoogleFonts.nunito(textStyle: headlineSmall),
      titleLarge: GoogleFonts.nunito(textStyle: titleLarge),
      titleMedium: GoogleFonts.nunito(textStyle: titleMedium),
      titleSmall: GoogleFonts.nunito(textStyle: titleSmall),
      bodyLarge: GoogleFonts.nunito(textStyle: bodyLarge),
      bodyMedium: GoogleFonts.nunito(textStyle: bodyMedium),
      bodySmall: GoogleFonts.nunito(textStyle: bodySmall),
      labelLarge: GoogleFonts.nunito(textStyle: labelLarge),
      labelMedium: GoogleFonts.nunito(textStyle: labelMedium),
      labelSmall: GoogleFonts.nunito(textStyle: labelSmall),
    );
  }
}
