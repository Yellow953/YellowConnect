import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';

/// 270° speedometer on a log scale up to 1 Gbps, so everyday speeds
/// (10–300 Mbps) move the needle visibly.
class SpeedGauge extends StatelessWidget {
  const SpeedGauge({super.key, required this.mbps, required this.child});

  final double mbps;
  final Widget child;

  static double fractionFor(double mbps) =>
      (math.log(1 + mbps.clamp(0, 1000)) / math.log(1001)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: fractionFor(mbps)),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, fraction, child) =>
          CustomPaint(painter: _GaugePainter(fraction), child: child),
      child: AspectRatio(aspectRatio: 1, child: Center(child: child)),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.fraction);

  final double fraction;

  static const _start = math.pi * 0.75;
  static const _sweep = math.pi * 1.5;
  static const _stroke = 22.0;
  static const _marks = [0, 5, 10, 50, 100, 250, 500, 1000];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - _stroke / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    Offset at(double f, double r) {
      final a = _start + _sweep * f;
      return center + Offset(math.cos(a), math.sin(a)) * r;
    }

    canvas.drawArc(
      rect,
      _start,
      _sweep,
      false,
      Paint()
        ..color = const Color(0xFFE2E2E7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round,
    );

    // Scale labels just inside the track.
    for (final mark in _marks) {
      final f = SpeedGauge.fractionFor(mark.toDouble());
      final label = TextPainter(
        text: TextSpan(
          text: '$mark',
          style: AppText.figure(
            13,
            weight: FontWeight.w600,
            color: fraction > 0 && f <= fraction
                ? AppColors.text
                : AppColors.text2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final pos = at(f, radius - _stroke - 14);
      label.paint(canvas, pos - Offset(label.width / 2, label.height / 2));
    }

    if (fraction <= 0) return;
    canvas.drawArc(
      rect,
      _start,
      _sweep * fraction,
      false,
      Paint()
        ..shader = const SweepGradient(
          endAngle: _sweep,
          colors: [Color(0xFFFFE27A), AppColors.yellow, Color(0xFFFFA800)],
          transform: GradientRotation(_start),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round,
    );

    // Knob at the current speed.
    final knob = at(fraction, radius);
    canvas.drawCircle(
      knob,
      _stroke / 2 + 5,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(knob, _stroke / 2 + 4, Paint()..color = AppColors.white);
    canvas.drawCircle(knob, _stroke / 2 - 4, Paint()..color = AppColors.black);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.fraction != fraction;
}
