import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// An animated circular progress ring with a gradient sweep and an optional
/// centered label. Used for daily goals, readiness score, topic mastery, etc.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 120,
    this.strokeWidth = 12,
    this.gradient,
    this.trackColor,
    this.center,
    this.duration = AppMotion.slow,
  }) : assert(value >= 0 && value <= 1);

  /// 0.0 – 1.0
  final double value;
  final double size;
  final double strokeWidth;
  final Gradient? gradient;
  final Color? trackColor;
  final Widget? center;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveGradient = gradient ??
        SweepGradient(
          colors: [scheme.primary, scheme.secondary, scheme.primary],
        );
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: duration,
        curve: AppMotion.emphasized,
        builder: (context, animatedValue, _) {
          return CustomPaint(
            painter: _RingPainter(
              value: animatedValue,
              strokeWidth: strokeWidth,
              gradient: effectiveGradient,
              trackColor: trackColor ?? scheme.surfaceContainerHighest,
            ),
            child: Center(child: center),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.strokeWidth,
    required this.gradient,
    required this.trackColor,
  });

  final double value;
  final double strokeWidth;
  final Gradient gradient;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (value <= 0) return;

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const start = -math.pi / 2;
    final sweep = 2 * math.pi * value;
    canvas.drawArc(rect, start, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.strokeWidth != strokeWidth ||
      old.trackColor != trackColor;
}
