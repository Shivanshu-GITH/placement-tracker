import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';

/// Full-bleed branded splash. Its top edge matches the native launch screen's
/// solid color (indigo in light, deep slate in dark — see
/// flutter_native_splash.yaml), so the native → Flutter handoff reads as ONE
/// continuous screen instead of two separate windows.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.error});
  final String? error;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Begins at the exact native-splash color at the top so there's no visible
    // seam, then eases into the brand's second tone.
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? const [AppPalette.darkBg, Color(0xFF1E1B3A)]
          : const [AppPalette.indigo, AppPalette.violet],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark ? AppPalette.darkBg : AppPalette.violet,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: gradient),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Spacer(flex: 3),
                  _RocketBadge(),
                  const SizedBox(height: AppSpacing.xl),
                  Text('PrepPilot',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ))
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 500.ms)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Your placement co-pilot',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 15,
                          ))
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms),
                  const Spacer(flex: 4),
                  if (error == null)
                    SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(
                            Colors.white.withValues(alpha: 0.9)),
                      ),
                    ).animate().fadeIn(delay: 450.ms)
                  else
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Text(
                        'Something went wrong:\n$error',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.huge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The white rocket mark in a soft, glowing frosted tile — a polished echo of
/// the flat rocket shown on the native launch screen.
class _RocketBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.22),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.rocket_launch_rounded,
          color: Colors.white, size: 52),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
            begin: 1, end: 1.06, duration: 1100.ms, curve: Curves.easeInOut);
  }
}
