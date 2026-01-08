import 'package:flutter/material.dart';

/// App-wide border radius constants with Apple-style nested corners

class AppRadius {
  AppRadius._();

  // Base radius values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  // BorderRadius presets
  static final BorderRadius radiusXs = BorderRadius.circular(xs);
  static final BorderRadius radiusSm = BorderRadius.circular(sm);
  static final BorderRadius radiusMd = BorderRadius.circular(md);
  static final BorderRadius radiusLg = BorderRadius.circular(lg);
  static final BorderRadius radiusXl = BorderRadius.circular(xl);
  static final BorderRadius radiusXxl = BorderRadius.circular(xxl);
  static final BorderRadius radiusFull = BorderRadius.circular(999);

  /// Apple-style nested corner radius: parentRadius - padding
  static double nestedRadius(double parentRadius, double padding) {
    final result = parentRadius - padding;
    return result > 0 ? result : 0;
  }

  // Pre-calculated nested radii
  static const double nestedInXl = 8.0;
  static const double nestedInXxl = 16.0;
  static const double nestedInLg = 8.0;
}
