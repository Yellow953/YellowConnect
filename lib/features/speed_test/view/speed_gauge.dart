import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';

/// Car-style speedometer: a 240° dial with tick marks and a needle, on a log
/// scale up to 1 Gbps so everyday speeds (10–300 Mbps) move it visibly.
///
/// [center] sits on the needle's pivot (e.g. a Start button that hides the
/// needle). [readout] sits under the pivot, in the open bottom of the dial.
/// When [sweep] turns true the needle swings to the top and back once, like
/// a car's gauges on ignition.
class SpeedGauge extends StatefulWidget {
  const SpeedGauge({
    super.key,
    required this.mbps,
    this.showNeedle = true,
    this.sweep = false,
    this.center,
    this.readout,
  });

  final double mbps;
  final bool showNeedle;
  final bool sweep;
  final Widget? center;
  final Widget? readout;

  /// Scale labels. Each step is roughly a tenth of the dial on this scale.
  static const marks = [0, 1, 5, 10, 25, 50, 100, 250, 500, 1000];

  static double fractionFor(double mbps) =>
      (math.log(1 + mbps.clamp(0, 1000)) / math.log(1001)).clamp(0.0, 1.0);

  @override
  State<SpeedGauge> createState() => _SpeedGaugeState();
}

class _SpeedGaugeState extends State<SpeedGauge>
    with SingleTickerProviderStateMixin {
  late final _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void didUpdateWidget(SpeedGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sweep && !oldWidget.sweep) _sweep.forward(from: 0);
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  /// Up fast, down a little slower: 0 → 1 → 0.
  double get _sweepFraction {
    final t = _sweep.value;
    if (t == 0 || t == 1) return 0;
    return t < 0.45
        ? Curves.easeOutCubic.transform(t / 0.45)
        : 1 - Curves.easeInOutCubic.transform((t - 0.45) / 0.55);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest.shortestSide;
          return Stack(
            fit: StackFit.expand,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(end: widget.showNeedle ? 1 : 0),
                duration: const Duration(milliseconds: 300),
                builder: (context, needleOpacity, _) =>
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: SpeedGauge.fractionFor(widget.mbps)),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      builder: (context, fraction, _) => AnimatedBuilder(
                        animation: _sweep,
                        builder: (context, _) => CustomPaint(
                          painter: _GaugePainter(
                            fraction: math.max(fraction, _sweepFraction),
                            needleOpacity: needleOpacity,
                          ),
                        ),
                      ),
                    ),
              ),
              if (widget.readout case final readout?)
                Positioned(top: size * 0.61, left: 0, right: 0, child: readout),
              if (widget.center case final center?) Center(child: center),
            ],
          );
        },
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.fraction, required this.needleOpacity});

  final double fraction;
  final double needleOpacity;

  /// Dial runs from bottom-left (150°) clockwise to bottom-right (30°).
  static const _start = math.pi * 5 / 6;
  static const _sweep = math.pi * 4 / 3;
  static const _minorPerStep = 4;

  static const _trackColor = Color(0xFFE2E2E7);
  static const _tickOff = Color(0xFFC9C9CF);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final stroke = r * 0.06;
    final trackR = r - stroke / 2 - 2;
    final trackRect = Rect.fromCircle(center: center, radius: trackR);

    double angle(double f) => _start + _sweep * f;
    Offset at(double f, double radius) {
      final a = angle(f);
      return center + Offset(math.cos(a), math.sin(a)) * radius;
    }

    // Track.
    canvas.drawArc(
      trackRect,
      _start,
      _sweep,
      false,
      Paint()
        ..color = _trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );

    // Filled part up to the needle, with a soft glow.
    if (fraction > 0.001) {
      final shader = const SweepGradient(
        endAngle: _sweep,
        colors: [Color(0xFFFFE27A), AppColors.yellow, Color(0xFFFFA800)],
        transform: GradientRotation(_start),
      ).createShader(trackRect);
      canvas.drawArc(
        trackRect,
        _start,
        _sweep * fraction,
        false,
        Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawArc(
        trackRect,
        _start,
        _sweep * fraction,
        false,
        Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // Ticks: a long one at each label, short ones between.
    final tickOuter = trackR - stroke / 2 - r * 0.05;
    final steps = SpeedGauge.marks.length - 1;
    for (var i = 0; i <= steps * _minorPerStep; i++) {
      final major = i % _minorPerStep == 0;
      final f = major
          ? SpeedGauge.fractionFor(
              SpeedGauge.marks[i ~/ _minorPerStep].toDouble(),
            )
          : _between(i);
      final lit = f <= fraction + 0.0001 && fraction > 0.001;
      canvas.drawLine(
        at(f, tickOuter),
        at(f, tickOuter - (major ? r * 0.085 : r * 0.04)),
        Paint()
          ..color = lit ? AppColors.text : _tickOff
          ..strokeWidth = major ? 2.4 : 1.4
          ..strokeCap = StrokeCap.round,
      );
    }

    // Labels inside the long ticks.
    final labelR = tickOuter - r * 0.085 - r * 0.1;
    for (final mark in SpeedGauge.marks) {
      final f = SpeedGauge.fractionFor(mark.toDouble());
      final lit = f <= fraction + 0.0001 && fraction > 0.001;
      final label = TextPainter(
        text: TextSpan(
          text: '$mark',
          style: AppText.figure(
            r * 0.075,
            weight: lit ? FontWeight.w700 : FontWeight.w600,
            color: lit ? AppColors.text : AppColors.text2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(
        canvas,
        at(f, labelR) - Offset(label.width / 2, label.height / 2),
      );
    }

    if (needleOpacity > 0) _paintNeedle(canvas, center, r, angle(fraction));
  }

  /// Minor tick [i] sits evenly between its two labels on the dial.
  double _between(int i) {
    final step = i ~/ _minorPerStep;
    final a = SpeedGauge.fractionFor(SpeedGauge.marks[step].toDouble());
    final b = SpeedGauge.fractionFor(SpeedGauge.marks[step + 1].toDouble());
    return a + (b - a) * (i % _minorPerStep) / _minorPerStep;
  }

  void _paintNeedle(Canvas canvas, Offset center, double r, double angle) {
    final length = r * 0.58;
    final tail = r * 0.12;
    final base = r * 0.045;

    final needle = Path()
      ..moveTo(length, 0)
      ..lineTo(0, base)
      ..lineTo(-tail, base * 0.6)
      ..lineTo(-tail, -base * 0.6)
      ..lineTo(0, -base)
      ..close();

    canvas
      ..save()
      ..translate(center.dx, center.dy);

    // Shadow, offset down regardless of the needle's angle.
    canvas
      ..save()
      ..translate(0, 4)
      ..rotate(angle)
      ..drawPath(
        needle,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.2 * needleOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      )
      ..restore();

    canvas
      ..save()
      ..rotate(angle)
      ..drawPath(
        needle,
        Paint()..color = AppColors.black.withValues(alpha: needleOpacity),
      )
      ..restore();

    // Hub: black cap with a yellow center.
    canvas
      ..drawCircle(
        Offset.zero,
        r * 0.1,
        Paint()..color = AppColors.black.withValues(alpha: needleOpacity),
      )
      ..drawCircle(
        Offset.zero,
        r * 0.04,
        Paint()..color = AppColors.yellow.withValues(alpha: needleOpacity),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.fraction != fraction || old.needleOpacity != needleOpacity;
}
