import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/logo.dart';

/// Repeats the native launch screen for a moment, then fades it away so the
/// jump from the black splash to the app isn't a hard cut.
class SplashOverlay extends StatefulWidget {
  const SplashOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay> {
  bool _visible = true;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_gone)
          IgnorePointer(
            ignoring: !_visible,
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              onEnd: () => setState(() => _gone = true),
              child: const ColoredBox(
                color: AppColors.black,
                child: Center(child: Logo()),
              ),
            ),
          ),
      ],
    );
  }
}
