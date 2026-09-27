import 'package:flutter/painting.dart';

/// Text styles on the platform font (SF Pro on iOS, Roboto on Android).
abstract final class AppText {
  static TextStyle style(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double letterSpacing = 0,
  }) => TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  /// Bold tabular numbers for IPs, speeds, and timers.
  static TextStyle figure(
    double size, {
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) => style(
    size,
    weight: weight,
    color: color,
    height: 1.1,
    letterSpacing: -0.01 * size,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}
