import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_dimens.dart';
import 'app_palette.dart';

/// Central theme builder. Produces a cohesive, modern Material 3 theme for
/// both light and dark modes, wired with the PrepPilot brand palette,
/// typography, and component styling.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppPalette.indigo,
      onPrimary: Colors.white,
      primaryContainer: isDark ? const Color(0xFF2A2550) : const Color(0xFFE7E6FF),
      onPrimaryContainer: isDark ? const Color(0xFFE0DEFF) : const Color(0xFF1E1B4B),
      secondary: AppPalette.violet,
      onSecondary: Colors.white,
      secondaryContainer: isDark ? const Color(0xFF33234D) : const Color(0xFFF0E9FF),
      onSecondaryContainer: isDark ? const Color(0xFFEADDFF) : const Color(0xFF2E1065),
      tertiary: AppPalette.mint,
      onTertiary: Colors.white,
      tertiaryContainer: isDark ? const Color(0xFF0C3B30) : const Color(0xFFD6F5EA),
      onTertiaryContainer: isDark ? const Color(0xFFB8F0DC) : const Color(0xFF04372B),
      error: AppPalette.danger,
      onError: Colors.white,
      errorContainer: isDark ? const Color(0xFF4A1D1D) : const Color(0xFFFDE1E1),
      onErrorContainer: isDark ? const Color(0xFFFFD6D6) : const Color(0xFF5F1414),
      surface: isDark ? AppPalette.darkSurfaceSolid : AppPalette.lightSurface,
      onSurface: isDark ? AppPalette.darkTextPrimary : AppPalette.lightTextPrimary,
      surfaceContainerLowest: isDark ? AppPalette.darkBg : Colors.white,
      surfaceContainerLow: isDark ? const Color(0xFF15151F) : const Color(0xFFFBFBFE),
      surfaceContainer: isDark ? AppPalette.darkSurfaceSolid : AppPalette.lightSurfaceAlt,
      surfaceContainerHigh: isDark ? AppPalette.darkSurfaceAlt : const Color(0xFFEDEDF5),
      surfaceContainerHighest: isDark ? const Color(0xFF262636) : const Color(0xFFE7E7F0),
      onSurfaceVariant: isDark ? AppPalette.darkTextSecondary : AppPalette.lightTextSecondary,
      outline: isDark ? AppPalette.darkBorder : AppPalette.lightBorder,
      outlineVariant: isDark ? const Color(0xFF34344A) : const Color(0xFFEDEDF3),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: isDark ? AppPalette.lightSurface : AppPalette.darkSurfaceSolid,
      onInverseSurface: isDark ? AppPalette.lightTextPrimary : AppPalette.darkTextPrimary,
      inversePrimary: AppPalette.violet,
      surfaceTint: Colors.transparent,
    );

    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );
    final textTheme = _applyTextColors(baseTextTheme, colorScheme.onSurface);

    final scaffoldBg = isDark ? AppPalette.darkBg : AppPalette.lightBg;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _FadeThroughTransitionBuilder(),
          TargetPlatform.iOS: _FadeThroughTransitionBuilder(),
        },
      ),
      extensions: [isDark ? AppSemanticColors.dark : AppSemanticColors.light],
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      // NOTE: Size.fromHeight(h) is Size(double.infinity, h) — these buttons
      // carry an *infinite* minimum width so they stretch to fill their parent.
      // That requires a bounded width: fine in a Column, a stretch column, a
      // sized box or a dialog's actions, but a plain Row/Flex gives non-flex
      // children unbounded width and layout throws "BoxConstraints forces an
      // infinite width" (the whole subtree then renders blank). Inside a Row,
      // wrap in Expanded/Flexible or override minimumSize with a finite width,
      // e.g. minimumSize: const Size(0, 40).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
          minimumSize: const Size.fromHeight(54),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: colorScheme.outline),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        selectedColor: colorScheme.primaryContainer,
        side: BorderSide(color: colorScheme.outline),
        labelStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),
    );
  }

  static TextTheme _applyTextColors(TextTheme base, Color color) {
    // Tighten letter spacing on large text for a more refined, "designed" feel.
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(color: color, letterSpacing: -1.0, fontWeight: FontWeight.w800),
      displayMedium: base.displayMedium?.copyWith(color: color, letterSpacing: -0.8, fontWeight: FontWeight.w800),
      displaySmall: base.displaySmall?.copyWith(color: color, letterSpacing: -0.5, fontWeight: FontWeight.w700),
      headlineLarge: base.headlineLarge?.copyWith(color: color, letterSpacing: -0.5, fontWeight: FontWeight.w700),
      headlineMedium: base.headlineMedium?.copyWith(color: color, letterSpacing: -0.4, fontWeight: FontWeight.w700),
      headlineSmall: base.headlineSmall?.copyWith(color: color, letterSpacing: -0.3, fontWeight: FontWeight.w700),
      titleLarge: base.titleLarge?.copyWith(color: color, fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(color: color),
      bodyMedium: base.bodyMedium?.copyWith(color: color),
      bodySmall: base.bodySmall?.copyWith(color: color),
      labelLarge: base.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
      labelMedium: base.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
      labelSmall: base.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
    );
  }
}

/// A subtle fade-through page transition for a polished, modern feel.
class _FadeThroughTransitionBuilder extends PageTransitionsBuilder {
  const _FadeThroughTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: AppMotion.enter);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
