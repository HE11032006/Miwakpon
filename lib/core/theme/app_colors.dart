import 'package:flutter/material.dart';

/// Palette Impressionniste Béninoise
///
/// Inspirée du design system Figma "Atelier Benin" :
/// - Ocre Terreux : soleil et terracotta de l'architecture béninoise
/// - Indigo Profond : prestige des textiles teints à l'indigo
/// - Canvas White : toile apprêtée, chaleur sans la dureté du blanc pur
///
/// Les ombres utilisent un blurRadius élevé (>20) pour l'effet impressionniste
/// de lumière diffuse à travers un paysage ouest-africain brumeux.
class AppColors {
  AppColors._();

  // --------------------------- Couleurs Primaires (Ocre Terreux) ---------------------------
  static const Color primary = Color(0xFF8C4B00);
  static const Color primaryContainer = Color(0xFFAF6005);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFFFBFF);

  // --------------------------- Couleurs Secondaires (Indigo Profond) ---------------------------
  static const Color secondary = Color(0xFF4C56AF);
  static const Color secondaryContainer = Color(0xFF959EFD);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF27308A);

  // --------------------------- Couleurs Tertiaires ---------------------------
  static const Color tertiary = Color(0xFF5D5C57);
  static const Color tertiaryContainer = Color(0xFF76756F);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // --------------------------- Surfaces (Canvas) ---------------------------
  static const Color background = Color(0xFFFCF9F8);
  static const Color surface = Color(0xFFFCF9F8);
  static const Color surfaceDim = Color(0xFFDCD9D9);
  static const Color surfaceContainer = Color(0xFFF0EDEC);
  static const Color surfaceContainerHigh = Color(0xFFEBE7E7);
  static const Color surfaceContainerHighest = Color(0xFFE5E2E1);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color onSurface = Color(0xFF1C1B1B);
  static const Color onSurfaceVariant = Color(0xFF544437);

  // --------------------------- Erreurs ---------------------------
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  // --------------------------- Contours ---------------------------
  static const Color outline = Color(0xFF877365);
  static const Color outlineVariant = Color(0xFFDAC2B2);

  // --------------------------- Inverse ---------------------------
  static const Color inverseSurface = Color(0xFF313030);
  static const Color inverseOnSurface = Color(0xFFF3F0EF);
  static const Color inversePrimary = Color(0xFFFFB77C);

  // --------------------------- Couleurs Complémentaires (Jaune Soleil & Bleu Lagune) ---------------------------
  static const Color jauneSoleil = Color(0xFFF4A300);
  static const Color bleuLagune = Color(0xFF1A237E);
  static const Color canvasWhite = Color(0xFFF4F1EA);

  // --------------------------- OMBRES IMPRESSIONNISTES ---------------------------
  //
  // Ombres très floues (blurRadius > 20) pour simuler la lumière
  // diffuse des paysages impressionnistes béninois.

  /// Ombre légère - effet "brume matinale"
  static List<BoxShadow> get shadowLight => [
        BoxShadow(
          color: primary.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  /// Ombre moyenne - effet "lumière d'après-midi"
  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: primary.withValues(alpha: 0.12),
          blurRadius: 32,
          offset: const Offset(0, 8),
          spreadRadius: 2,
        ),
      ];

  /// Ombre forte - effet "coucher de soleil"
  static List<BoxShadow> get shadowHeavy => [
        BoxShadow(
          color: primary.withValues(alpha: 0.16),
          blurRadius: 48,
          offset: const Offset(0, 12),
          spreadRadius: 4,
        ),
        BoxShadow(
          color: secondary.withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  /// Ombre teintée indigo - pour les cartes événements
  static List<BoxShadow> get shadowIndigo => [
        BoxShadow(
          color: secondary.withValues(alpha: 0.10),
          blurRadius: 28,
          offset: const Offset(0, 6),
          spreadRadius: 1,
        ),
      ];

  /// Ombre dorée - pour les éléments interactifs en focus
  static List<BoxShadow> get shadowGolden => [
        BoxShadow(
          color: jauneSoleil.withValues(alpha: 0.20),
          blurRadius: 36,
          offset: const Offset(0, 8),
          spreadRadius: 2,
        ),
      ];
}
