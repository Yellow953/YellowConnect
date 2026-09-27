import 'package:flutter/widgets.dart';

/// The lock-and-signal mark. Its keyhole and shackle are transparent, so it
/// takes on whatever background sits behind it.
class Logo extends StatelessWidget {
  const Logo({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/brand/logo_mark.png',
    height: height,
    semanticLabel: 'Yellow Connect',
  );
}
