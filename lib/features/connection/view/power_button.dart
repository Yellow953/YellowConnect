import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../model/connection_status.dart';
import 'connection_status_style.dart';

/// Round connect button inside concentric rings. The rings pulse while the
/// tunnel is opening or closing and turn yellow once connected.
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
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  bool get _busy =>
      widget.status == ConnectionStatus.connecting ||
      widget.status == ConnectionStatus.disconnecting;

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(PowerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    if (_busy && !_pulse.isAnimating) {
      _pulse.repeat();
    } else if (!_busy && _pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.status.isLit;
    final ringColor = on || _busy ? AppColors.yellow : AppColors.white;

    return Semantics(
      button: true,
      label: widget.status.actionLabel,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: SizedBox.square(
          dimension: widget.size,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) => Stack(
              alignment: Alignment.center,
              children: [
                for (final (i, size) in [
                  widget.size,
                  widget.size * 0.816,
                ].indexed)
                  _Ring(
                    size: size,
                    color: ringColor,
                    opacity: on || _busy
                        ? (i == 0 ? 0.16 : 0.3) *
                              (_busy ? 1 - _pulse.value * 0.7 : 1)
                        : 1,
                    scale: _busy ? 0.94 + _pulse.value * 0.06 : 1,
                    shadow: !on && !_busy,
                  ),
                child!,
              ],
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: widget.size * 0.6,
              height: widget.size * 0.6,
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
              child: Icon(
                Icons.power_settings_new_rounded,
                size: widget.size * 0.24,
                color: on ? AppColors.black : AppColors.yellow,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({
    required this.size,
    required this.color,
    required this.opacity,
    required this.scale,
    required this.shadow,
  });

  final double size;
  final Color color;
  final double opacity;
  final double scale;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
          boxShadow: shadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
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
