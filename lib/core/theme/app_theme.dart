import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Thème global de l'application Benin Impressionist Sync.
///
/// Utilise la typographie du design system Figma :
/// - Newsreader pour les titres (élégance éditoriale)
/// - Be Vietnam Pro pour le corps (lisibilité contemporaine)
///
/// Les coins sont arrondis à 8px (ROUND_EIGHT du design system).
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // --------------------------- Color Scheme ---------------------------
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        onPrimary: AppColors.onPrimary,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondary: AppColors.onSecondary,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiary: AppColors.onTertiary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        error: AppColors.error,
        errorContainer: AppColors.errorContainer,
        onError: AppColors.onError,
        onErrorContainer: AppColors.onErrorContainer,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
      ),

      // --------------------------- Scaffold ---------------------------
      scaffoldBackgroundColor: AppColors.background,

      // --------------------------- Typography ---------------------------
      textTheme: _buildTextTheme(),

      // --------------------------- AppBar ---------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.newsreader(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),

      // --------------------------- Cards ---------------------------
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),

      // --------------------------- Elevated Buttons ---------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // --------------------------- Outlined Buttons ---------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // --------------------------- Input Decoration ---------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: GoogleFonts.beVietnamPro(
          color: AppColors.onSurfaceVariant,
        ),
        hintStyle: GoogleFonts.beVietnamPro(
          color: AppColors.outline,
        ),
      ),

      // --------------------------- Chips ---------------------------
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.secondary.withValues(alpha: 0.10),
        side: const BorderSide(color: AppColors.secondary),
        labelStyle: GoogleFonts.beVietnamPro(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05 * 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // --------------------------- Bottom Navigation ---------------------------
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outline,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // --------------------------- Floating Action Button ---------------------------
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimaryContainer,
        elevation: 0,
        shape: CircleBorder(),
      ),

      // --------------------------- Divider ---------------------------
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Typographie suivant le design system Figma Atelier Benin.
  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Headline Large - Newsreader 34px semibold
      headlineLarge: GoogleFonts.newsreader(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        height: 42 / 34,
        letterSpacing: -0.02 * 34,
        color: AppColors.onSurface,
      ),
      // Headline Medium - Newsreader 28px medium
      headlineMedium: GoogleFonts.newsreader(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        height: 34 / 28,
        letterSpacing: -0.01 * 28,
        color: AppColors.onSurface,
      ),
      // Headline Small
      headlineSmall: GoogleFonts.newsreader(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      ),
      // Title Large
      titleLarge: GoogleFonts.newsreader(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      // Title Medium
      titleMedium: GoogleFonts.beVietnamPro(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      // Title Small
      titleSmall: GoogleFonts.beVietnamPro(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      // Body Large - Be Vietnam Pro 18px regular
      bodyLarge: GoogleFonts.beVietnamPro(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: AppColors.onSurface,
      ),
      // Body Medium - Be Vietnam Pro 16px regular
      bodyMedium: GoogleFonts.beVietnamPro(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurface,
      ),
      // Body Small
      bodySmall: GoogleFonts.beVietnamPro(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
      ),
      // Label Large
      labelLarge: GoogleFonts.beVietnamPro(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      // Label Medium
      labelMedium: GoogleFonts.beVietnamPro(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      // Label Small - Be Vietnam Pro 12px semibold, tracking 0.05em
      labelSmall: GoogleFonts.beVietnamPro(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.05 * 12,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}
