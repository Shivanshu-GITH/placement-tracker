import 'package:flutter/animation.dart';

/// Spacing, radius, and elevation tokens — an 8pt-based scale.
///
/// Consistent spacing is what separates a "classy" UI from an amateur one.
/// Always use these instead of magic numbers.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  /// Standard horizontal screen padding.
  static const double screenH = 20;
}

class AppRadius {
  AppRadius._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double pill = 999;
}

/// Motion tokens. A cohesive motion language: quick, springy, never sluggish.
class AppMotion {
  AppMotion._();

  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 220);
  static const Duration medium = Duration(milliseconds: 360);
  static const Duration slow = Duration(milliseconds: 560);

  /// Standard entrance easing — decelerate into place.
  static const Curve enter = Curves.easeOutCubic;

  /// Emphasized/expressive easing for hero moments.
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Springy overshoot for celebratory bits (streak bumps, check marks).
  static const Curve spring = Curves.easeOutBack;

  /// Staggered list item delay.
  static const Duration stagger = Duration(milliseconds: 55);
}
