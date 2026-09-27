import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Page with a large title, optional subtitle and trailing action.
///
/// With [fill], the children are laid out in a column at least as tall as
/// the screen, so [Spacer]s can center a hero section.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.action,
    this.fill = false,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final List<Widget> children;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    // Inside a Scaffold with `extendBody`, the bottom padding is the height
    // of the floating tab bar, so content can scroll clear of it.
    final padding = EdgeInsets.fromLTRB(
      20,
      16,
      20,
      MediaQuery.paddingOf(context).bottom + 24,
    );
    final header = [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.style(
                    32,
                    weight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                if (subtitle case final subtitle?)
                  Text(
                    subtitle,
                    style: AppText.style(16, color: AppColors.text2),
                  ),
              ],
            ),
          ),
          ?action,
        ],
      ),
      const SizedBox(height: 22),
    ];

    final Widget body = fill
        ? LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - padding.vertical,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [...header, ...children],
                  ),
                ),
              ),
            ),
          )
        : ListView(padding: padding, children: [...header, ...children]);

    return SafeArea(bottom: false, child: body);
  }
}
