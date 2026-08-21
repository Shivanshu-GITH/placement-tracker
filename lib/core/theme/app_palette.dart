import 'package:flutter/material.dart';

/// Raw brand colors and semantic tokens for PrepPilot.
///
/// This is the single source of truth for color across the app (and the whole
/// app series). Screens must never hard-code hex values — they read from the
/// [ColorScheme] (via `Theme.of(context)`) or from [AppPalette] semantic tokens.
class AppPalette {
  AppPalette._();

  // ---- Brand core ---------------------------------------------------------
  /// Indigo → violet is the PrepPilot signature (ambition + trust + "tech").
  static const Color indigo = Color(0xFF6366F1);
  static const Color indigoDark = Color(0xFF4F46E5);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color violetDark = Color(0xFF7C3AED);

  /// Progress / success accent — vibrant mint-teal.
  static const Color mint = Color(0xFF10B981);
  static const Color mintDark = Color(0xFF059669);

  // ---- Semantic feedback --------------------------------------------------
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ---- Difficulty (DSA problems) -----------------------------------------
  static const Color easy = Color(0xFF10B981);
  static const Color medium = Color(0xFFF59E0B);
  static const Color hard = Color(0xFFEF4444);

  // ---- Category accents (used across tracker/analytics) ------------------
  static const Color catDsa = Color(0xFF6366F1); // Data structures & algorithms
  static const Color catCore = Color(0xFF8B5CF6); // CS core subjects
  static const Color catAptitude = Color(0xFF14B8A6); // Aptitude & reasoning
  static const Color catSystem = Color(0xFFEC4899); // System design
  static const Color catInterview = Color(0xFFF97316); // HR / behavioural

  // ---- Neutrals (light) ---------------------------------------------------
  static const Color lightBg = Color(0xFFF7F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF1F1F8);
  static const Color lightBorder = Color(0xFFE7E7F0);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B6B85);

  // ---- Neutrals (dark) ----------------------------------------------------
  static const Color darkBg = Color(0xFF0E0E16);
  static const Color darkSurface = Color(0xFF171724);
  static const Color darkSurfaceSolid = Color(0xFF191926);
  static const Color darkSurfaceAlt = Color(0xFF20202F);
  static const Color darkBorder = Color(0xFF2C2C3E);
  static const Color darkTextPrimary = Color(0xFFF2F2F7);
  static const Color darkTextSecondary = Color(0xFF9A9AB0);

  // ---- Signature gradients ------------------------------------------------
  static const LinearGradient brandGradient = LinearGradient(
    colors: [indigo, violet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient progressGradient = LinearGradient(
    colors: [mint, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Difficulty → color helper.
  static Color difficulty(String level) {
    switch (level.toLowerCase()) {
      case 'easy':
        return easy;
      case 'medium':
        return medium;
      case 'hard':
        return hard;
      default:
        return medium;
    }
  }
}

/// Extra semantic colors not covered by [ColorScheme], exposed via theme
/// extension so widgets stay theme-aware in both light and dark mode.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.streak,
    required this.cardBorder,
    required this.surfaceAlt,
    required this.textSecondary,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  final Color success;
  final Color warning;
  final Color info;
  final Color streak;
  final Color cardBorder;
  final Color surfaceAlt;
  final Color textSecondary;
  final Color shimmerBase;
  final Color shimmerHighlight;

  static const light = AppSemanticColors(
    success: AppPalette.success,
    warning: AppPalette.warning,
    info: AppPalette.info,
    streak: Color(0xFFF97316),
    cardBorder: AppPalette.lightBorder,
    surfaceAlt: AppPalette.lightSurfaceAlt,
    textSecondary: AppPalette.lightTextSecondary,
    shimmerBase: Color(0xFFECECF3),
    shimmerHighlight: Color(0xFFF8F8FC),
  );

  static const dark = AppSemanticColors(
    success: AppPalette.success,
    warning: AppPalette.warning,
    info: AppPalette.info,
    streak: Color(0xFFFB923C),
    cardBorder: AppPalette.darkBorder,
    surfaceAlt: AppPalette.darkSurfaceAlt,
    textSecondary: AppPalette.darkTextSecondary,
    shimmerBase: Color(0xFF20202F),
    shimmerHighlight: Color(0xFF2C2C3E),
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? streak,
    Color? cardBorder,
    Color? surfaceAlt,
    Color? textSecondary,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      streak: streak ?? this.streak,
      cardBorder: cardBorder ?? this.cardBorder,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      textSecondary: textSecondary ?? this.textSecondary,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      streak: Color.lerp(streak, other.streak, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}

/// Convenience accessor: `context.semantic.streak`.
extension SemanticColorsX on BuildContext {
  AppSemanticColors get semantic =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;
}
