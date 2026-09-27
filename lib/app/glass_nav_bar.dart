import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class GlassNavItem {
  const GlassNavItem(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;

  /// Used for accessibility and tooltips; the bar itself shows icons only.
  final String label;
}

/// Floating glass pill, icons only. Pages scroll underneath it (the host
/// sets `extendBody: true`), so the blur picks up whatever is behind, and a
/// translucent lens slides over to the selected tab.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.items,
    required this.index,
    required this.onSelect,
  });

  final List<GlassNavItem> items;
  final int index;
  final ValueChanged<int> onSelect;

  static const _height = 64.0;
  static const _bottomGap = 12.0;
  static const _sideInset = 20.0;
  static const _innerPadding = 6.0;

  /// Boosts saturation 1.6× (Rec. 709 luma weights) so colors behind the
  /// glass stay vivid instead of frosting to gray.
  static const List<double> _saturate = [
    1.4724, -0.4291, -0.0433, 0, 0, //
    -0.1276, 1.1709, -0.0433, 0, 0, //
    -0.1276, -0.4291, 1.5567, 0, 0, //
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _sideInset,
        0,
        _sideInset,
        _bottomGap + bottomInset,
      ),
      child: CustomPaint(
        // Shadow only outside the pill: a regular BoxShadow would also sit
        // under the translucent fill and gray the glass out.
        painter: const _OuterShadowPainter(radius: _height / 2),
        foregroundPainter: const _RimPainter(radius: _height / 2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_height / 2),
          child: BackdropFilter(
            filter: ImageFilter.compose(
              outer: const ColorFilter.matrix(_saturate),
              inner: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            ),
            child: Container(
              height: _height,
              padding: const EdgeInsets.all(_innerPadding),
              color: AppColors.white.withValues(alpha: 0.3),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final slot = constraints.maxWidth / items.length;
                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOutBack,
                        left: slot * index,
                        top: 0,
                        bottom: 0,
                        width: slot,
                        child: const _Lens(),
                      ),
                      Row(
                        children: [
                          for (final (i, item) in items.indexed)
                            Expanded(
                              child: _NavButton(
                                item: item,
                                selected: i == index,
                                onTap: () => onSelect(i),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Lens extends StatelessWidget {
  const _Lens();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          (GlassNavBar._height - GlassNavBar._innerPadding * 2) / 2,
        ),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.6)),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final GlassNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedScale(
            scale: selected ? 1.1 : 1,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              selected ? item.activeIcon : item.icon,
              size: 24,
              color: selected
                  ? AppColors.text
                  : AppColors.text.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft drop shadow clipped to the area outside the pill, so the glass
/// itself stays clear.
class _OuterShadowPainter extends CustomPainter {
  const _OuterShadowPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    canvas.save();
    canvas.clipPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rrect.outerRect.inflate(60)),
        Path()..addRRect(rrect),
      ),
    );
    canvas.drawRRect(
      rrect.shift(const Offset(0, 8)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OuterShadowPainter old) => old.radius != radius;
}

/// Glass edge: inner shading for thickness, a bright specular rim that
/// fades around the pill, and a faint dark hairline so the bar still reads
/// against white content.
class _RimPainter extends CustomPainter {
  const _RimPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // Soft shadow hugging the bottom inside edge, glow along the top one.
    canvas.save();
    canvas.clipRRect(rrect);
    final frame = Path()..addRect(rect.inflate(20));
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        frame,
        Path()..addRRect(rrect.shift(const Offset(0, -4))),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        frame,
        Path()..addRRect(rrect.shift(const Offset(0, 3))),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.restore();

    canvas.drawRRect(
      rrect.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black.withValues(alpha: 0.1),
    );

    canvas.drawRRect(
      rrect.deflate(1.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.7),
          ],
          stops: const [0, 0.35, 0.65, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RimPainter old) => old.radius != radius;
}
