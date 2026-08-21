import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// A number that counts up to its value when it first appears or changes.
/// Small delight that makes stats feel alive.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.fractionDigits = 0,
    this.duration = AppMotion.slow,
  });

  final num value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final int fractionDigits;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: AppMotion.emphasized,
      builder: (context, v, _) {
        final text = fractionDigits == 0
            ? v.round().toString()
            : v.toStringAsFixed(fractionDigits);
        return Text('$prefix$text$suffix', style: style);
      },
    );
  }
}
