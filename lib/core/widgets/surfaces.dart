import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

const _cardRadius = BorderRadius.all(Radius.circular(24));

/// White rounded card with a soft shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: _cardRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

enum IconTileTone { gray, yellow, dark }

/// Rounded square holding an icon.
class IconTile extends StatelessWidget {
  const IconTile(
    this.icon, {
    super.key,
    this.tone = IconTileTone.gray,
    this.size = 40,
  });

  final IconData icon;
  final IconTileTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      IconTileTone.gray => (AppColors.iconTile, AppColors.text),
      IconTileTone.yellow => (AppColors.yellowSoft, const Color(0xFF8A6A00)),
      IconTileTone.dark => (AppColors.black, AppColors.yellow),
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, size: size * 0.5, color: fg),
    );
  }
}

/// Icon, label and value in one line. Rows in a card are joined by
/// [DetailList].
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.caption,
    this.trailing,
    this.tone = IconTileTone.gray,
  });

  final IconData icon;
  final String label;
  final String? value;

  /// Smaller gray line under the label.
  final String? caption;
  final Widget? trailing;
  final IconTileTone tone;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconTile(icon, tone: tone),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppText.style(16, weight: FontWeight.w600),
                  ),
                  if (caption case final caption?)
                    Text(
                      caption,
                      style: AppText.style(14, color: AppColors.text2),
                    ),
                ],
              ),
            ),
            if (value case final value?)
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.style(15, color: AppColors.text2),
                ),
              ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// White card of [DetailRow]s separated by inset dividers.
class DetailList extends StatelessWidget {
  const DetailList({super.key, required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (final (i, row) in rows.indexed) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: 70,
                endIndent: 16,
                color: AppColors.divider,
              ),
            row,
          ],
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 26, 6, 10),
      child: Text(
        text,
        style: AppText.style(
          15,
          weight: FontWeight.w600,
          color: AppColors.text2,
        ),
      ),
    );
  }
}

/// Small rounded label with a colored dot, e.g. "Connected".
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.dotColor,
    this.dark = false,
  });

  final String label;
  final Color dotColor;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: 0.1) : AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: AppText.style(
              14,
              weight: FontWeight.w600,
              color: dark ? AppColors.white : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

/// Round white icon button for page headers.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.dark = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(44),
        backgroundColor: dark
            ? Colors.white.withValues(alpha: 0.1)
            : AppColors.card,
        foregroundColor: dark ? AppColors.white : AppColors.text,
      ),
      icon: Icon(icon, size: 22),
    );
  }
}
