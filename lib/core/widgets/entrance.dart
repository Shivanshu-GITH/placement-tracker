import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_dimens.dart';

/// Consistent entrance animation used across screens: a gentle fade + rise.
/// Pass [index] to stagger items in a list/column.
extension EntranceX on Widget {
  Widget entrance({int index = 0, double dy = 14}) {
    return animate(delay: AppMotion.stagger * index)
        .fadeIn(duration: AppMotion.medium, curve: AppMotion.enter)
        .slideY(
          begin: dy / 100,
          end: 0,
          duration: AppMotion.medium,
          curve: AppMotion.enter,
        );
  }
}
