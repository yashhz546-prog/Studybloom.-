import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central place for every color, radius and text style used across
/// StudyBloom. Keeping this in one file makes the "premium minimal"
/// look easy to tweak without hunting through every screen.
class AppColors {
  AppColors._();

  static const Color primaryPink = Color(0xFFF8C8DC); // Baby Pink
  static const Color softBlush = Color(0xFFFFDCE8); // Secondary
  static const Color rosePink = Color(0xFFF5A9C5); // Accent
  static const Color warmCream = Color(0xFFFFF9F2); // Background
  static const Color creamText = Color(0xFFFFFDF8); // Cream text on dark/pink
  static const Color inkText = Color(0xFF4A3B41); // Deep warm charcoal for body text
  static const Color mutedText = Color(0xFF8A757C);
  static const Color success = Color(0xFF7BC49B);
}

class AppRadius {
  AppRadius._();
  static const double card = 20;
  static const double button = 22;
  static const double chip = 16;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.warmCream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.rosePink,
        brightness: Brightness.light,
        primary: AppColors.rosePink,
        secondary: AppColors.softBlush,
        surface: AppColors.warmCream,
      ),
    );

    final textTheme = GoogleFonts.montserratTextTheme(base.textTheme).apply(
      bodyColor: AppColors.inkText,
      displayColor: AppColors.inkText,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.warmCream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.montserrat(
          color: AppColors.inkText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.inkText),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: AppColors.rosePink.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rosePink,
          foregroundColor: AppColors.creamText,
          disabledBackgroundColor: AppColors.softBlush,
          disabledForegroundColor: AppColors.mutedText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.rosePink;
          }
          return Colors.white;
        }),
        side: const BorderSide(color: AppColors.rosePink, width: 1.6),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.rosePink;
          }
          return AppColors.mutedText;
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.softBlush.withValues(alpha: 0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.rosePink, width: 1.6),
        ),
        hintStyle: GoogleFonts.montserrat(color: AppColors.mutedText),
      ),
    );
  }
}
