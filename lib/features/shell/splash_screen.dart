import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.error});
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                gradient: AppPalette.brandGradient,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: AppPalette.indigo.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(Icons.rocket_launch_rounded,
                  color: Colors.white, size: 46),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 1, end: 1.06, duration: 900.ms, curve: Curves.easeInOut),
            const SizedBox(height: AppSpacing.xl),
            Text('PrepPilot',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800))
                .animate()
                .fadeIn(delay: 150.ms, duration: 500.ms),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Your placement co-pilot',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            const SizedBox(height: AppSpacing.xxxl),
            if (error == null)
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            else
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Something went wrong:\n$error',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
