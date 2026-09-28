import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../model/connection_status.dart';
import 'connection_status_style.dart';

/// Round connect button inside concentric rings.
///
/// Off: white rings, black button. Busy: rings tint yellow and an arc spins
/// around the outer ring (clockwise while connecting, back while
/// disconnecting). Connected: a ripple bursts out once, the button turns
/// yellow and the rings slowly breathe.
class PowerButton extends StatefulWidget {
  const PowerButton({
    super.key,
    required this.status,
    this.onPressed,
    this.size = 250,
  });

  final ConnectionStatus status;
  final VoidCallback? onPressed;

  /// Outer ring diameter; the button is 60% of it.
  final double size;

  @override
  State<PowerButton> createState() => _PowerButtonState();
}

class _PowerButtonState extends State<PowerButton>
    with TickerProviderStateMixin {
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final _arc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final _tint = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final _breathe = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  late final _all = Listenable.merge([_spin, _arc, _tint, _breathe, _burst]);

  bool _pressed = false;

  /// Spin direction, kept from the last busy state so the arc doesn't flip
  /// while it fades out.
  bool _reverse = false;

  ConnectionStatus get _status => widget.status;
  bool get _busy =>
      _status == ConnectionStatus.connecting ||
      _status == ConnectionStatus.disconnecting;
  bool get _on => _status.isLit;

  @override
  void initState() {
    super.initState();
    _tint.value = _on || _busy ? 1 : 0;
    _sync(null);
  }

  @override
  void didUpdateWidget(PowerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != _status) _sync(oldWidget.status);
  }

  void _sync(ConnectionStatus? previous) {
    _tint.animateTo(_on || _busy ? 1 : 0);

    if (_busy) {
      _reverse = _status == ConnectionStatus.disconnecting;
      if (!_spin.isAnimating) _spin.repeat();
      _arc.forward();
    } else {
      // Let the arc fade out while still spinning, then stop it.
      _arc.reverse().whenCompleteOrCancel(() {
        if (!_busy && mounted) _spin.stop();
      });
    }

    if (_on) {
      if (!_breathe.isAnimating) _breathe.repeat(reverse: true);
      if (previous != null && previous != ConnectionStatus.connected) {
        _burst.forward(from: 0);
        HapticFeedback.lightImpact();
      }
    } else if (_breathe.value > 0 || _breathe.isAnimating) {
      _breathe.animateTo(0, duration: const Duration(milliseconds: 400));
    }
  }

  void _setPressed(bool pressed) {
    if (widget.onPressed == null || _pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  void _onTap() {
    if (widget.onPressed case final onPressed?) {
      HapticFeedback.mediumImpact();
      onPressed();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _arc.dispose();
    _tint.dispose();
    _breathe.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final on = _on;

    return Semantics(
      button: true,
      label: _status.actionLabel,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: _onTap,
        child: SizedBox.square(
          dimension: size,
          child: AnimatedBuilder(
            animation: _all,
            builder: (context, child) {
              final tint = Curves.easeOut.transform(_tint.value);
              final breathe = Curves.easeInOut.transform(_breathe.value);
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  _Ring(
                    size: size,
                    scale: 1 + breathe * 0.03,
                    color: Color.lerp(
                      AppColors.white,
                      AppColors.yellow.withValues(alpha: 0.16),
                      tint,
                    )!,
                    shadowOpacity: 1 - tint,
                  ),
                  _Ring(
                    size: size * 0.816,
                    scale: 1 + breathe * 0.018,
                    color: Color.lerp(
                      AppColors.white,
                      AppColors.yellow.withValues(alpha: 0.3),
                      tint,
                    )!,
                    shadowOpacity: 1 - tint,
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ArcPainter(
                        rotation: _spin.value,
                        opacity: _arc.value,
                        reverse: _reverse,
                        burst: _burst.value,
                      ),
                    ),
                  ),
                  child!,
                ],
              );
            },
            child: AnimatedScale(
              scale: _pressed ? 0.94 : 1,
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOut,
                width: size * 0.6,
                height: size * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: on ? AppColors.yellow : AppColors.black,
                  boxShadow: [
                    BoxShadow(
                      color: on
                          ? AppColors.yellow.withValues(alpha: 0.55)
                          : Colors.black.withValues(alpha: 0.16),
                      blurRadius: 26,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _PowerIcon(
                  size: size * 0.24,
                  on: on,
                  busy: _busy,
                  spin: _spin,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The power glyph. It softly blinks while the tunnel is busy.
class _PowerIcon extends StatelessWidget {
  const _PowerIcon({
    required this.size,
    required this.on,
    required this.busy,
    required this.spin,
  });

  final double size;
  final bool on;
  final bool busy;
  final Animation<double> spin;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: spin,
      builder: (context, child) => Opacity(
        opacity: busy
            ? 0.55 + 0.45 * math.cos(spin.value * 2 * math.pi).abs()
            : 1,
        child: child,
      ),
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: on ? AppColors.black : AppColors.yellow),
        duration: const Duration(milliseconds: 380),
        builder: (context, color, _) =>
            Icon(Icons.power_settings_new_rounded, size: size, color: color),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({
    required this.size,
    required this.scale,
    required this.color,
    required this.shadowOpacity,
  });

  final double size;
  final double scale;
  final Color color;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: shadowOpacity > 0
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04 * shadowOpacity),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

/// Spinning progress arc on the outer ring, plus the ripple that bursts out
/// when the tunnel comes up.
class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.rotation,
    required this.opacity,
    required this.reverse,
    required this.burst,
  });

  /// 0..1, one full turn.
  final double rotation;
  final double opacity;
  final bool reverse;

  /// 0..1 progress of the connect ripple; 0 or 1 draws nothing.
  final double burst;

  static const _stroke = 5.0;
  static const _sweep = math.pi * 0.62;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    if (opacity > 0) _paintArc(canvas, center, size.width / 2 - _stroke / 2);
    if (burst > 0 && burst < 1) _paintBurst(canvas, center, size.width);
  }

  void _paintArc(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);

    canvas
      ..save()
      ..translate(center.dx, center.dy);
    if (reverse) canvas.scale(-1, 1);
    canvas.rotate(rotation * 2 * math.pi - math.pi / 2);

    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..color = AppColors.yellow.withValues(alpha: 0.18 * opacity),
    );
    canvas.drawArc(
      rect,
      0,
      _sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          endAngle: _sweep,
          colors: [
            AppColors.yellow.withValues(alpha: 0),
            AppColors.yellow.withValues(alpha: opacity),
          ],
        ).createShader(rect),
    );
    canvas.restore();
  }

  void _paintBurst(Canvas canvas, Offset center, double diameter) {
    for (var i = 0; i < 2; i++) {
      final t = ((burst - i * 0.2) / 0.8).clamp(0.0, 1.0);
      if (t <= 0 || t >= 1) continue;
      final eased = Curves.easeOutCubic.transform(t);
      canvas.drawCircle(
        center,
        diameter * (0.3 + 0.5 * eased),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * (1 - t) + 1
          ..color = AppColors.yellow.withValues(alpha: 0.6 * (1 - t)),
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.rotation != rotation ||
      old.opacity != opacity ||
      old.reverse != reverse ||
      old.burst != burst;
}
