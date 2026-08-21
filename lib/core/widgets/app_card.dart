import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// A standard bordered surface card — the workhorse container.
///
/// Flat (no drop shadow) with a hairline border, matching the modern
/// "soft UI" look used across the app. Optionally tappable with a ripple.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.color,
    this.borderColor,
    this.radius = AppRadius.lg,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: color ?? scheme.surface,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor ?? scheme.outline),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// A vivid gradient "hero" card used for the top-of-screen highlight
/// (today's focus, readiness score, etc.). Draws soft decorative blobs.
class GradientHeroCard extends StatelessWidget {
  const GradientHeroCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.radius = AppRadius.xl,
    this.onTap,
  });

  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Stack(
            children: [
              // Decorative light blobs for depth.
              Positioned(
                right: -30,
                top: -30,
                child: _Blob(size: 130, color: Colors.white.withValues(alpha: 0.12)),
              ),
              Positioned(
                left: -20,
                bottom: -40,
                child: _Blob(size: 110, color: Colors.white.withValues(alpha: 0.08)),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
