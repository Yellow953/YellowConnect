import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/network_labels.dart';
import '../../../core/widgets/surfaces.dart';
import '../model/speed_test_result.dart';
import '../presenter/speed_test_presenter.dart';

Future<void> showSpeedHistory(
  BuildContext context,
  SpeedTestPresenter presenter,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ListenableBuilder(
        listenable: presenter,
        builder: (context, _) => _HistoryList(
          history: presenter.history,
          scrollController: scrollController,
          onClear: () => confirmClearSpeedHistory(context, presenter),
        ),
      ),
    ),
  );
}

/// Asks first, then deletes every saved result.
Future<void> confirmClearSpeedHistory(
  BuildContext context,
  SpeedTestPresenter presenter,
) async {
  final count = presenter.history.length;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Clear history?',
              style: AppText.style(21, weight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              count == 1
                  ? 'This deletes your saved test result.'
                  : 'This deletes all $count saved test results.',
              style: AppText.style(15, color: AppColors.text2, height: 1.4),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: AppColors.white,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (confirmed ?? false) await presenter.clearHistory();
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.history,
    required this.scrollController,
    required this.onClear,
  });

  final List<SpeedTestResult> history;
  final ScrollController scrollController;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final days = <DateTime, List<SpeedTestResult>>{};
    for (final result in history) {
      final t = result.testedAt;
      (days[DateTime(t.year, t.month, t.day)] ??= []).add(result);
    }

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'History',
                    style: AppText.style(
                      26,
                      weight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(switch (history.length) {
                    0 => 'No tests saved',
                    1 => '1 test',
                    final n => '$n tests',
                  }, style: AppText.style(15, color: AppColors.text2)),
                ],
              ),
            ),
            if (history.isNotEmpty)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.red,
                  minimumSize: const Size(64, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  backgroundColor: AppColors.card,
                  shape: const StadiumBorder(),
                ),
                onPressed: onClear,
                child: const Text('Clear history'),
              ),
          ],
        ),
        if (history.isEmpty)
          const _Empty()
        else
          for (final MapEntry(key: day, value: results) in days.entries) ...[
            SectionLabel(_dayLabel(day)),
            DetailList(rows: [for (final r in results) _HistoryRow(r)]),
          ],
      ],
    );
  }

  static String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (today.difference(day).inDays) {
      0 => 'Today',
      1 => 'Yesterday',
      _ => formatDay(day),
    };
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow(this.result);

  final SpeedTestResult result;

  @override
  Widget build(BuildContext context) {
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(result.testedAt),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    final network = result.networkType.label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconTile(result.networkType.icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: AppText.style(16, weight: FontWeight.w600)),
                Text(
                  switch (result.isp) {
                    final isp? when isp.isNotEmpty => '$network · $isp',
                    _ => network,
                  },
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.style(14, color: AppColors.text2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Speed(Icons.arrow_downward_rounded, result.downloadMbps),
              const SizedBox(height: 2),
              _Speed(Icons.arrow_upward_rounded, result.uploadMbps),
            ],
          ),
        ],
      ),
    );
  }
}

class _Speed extends StatelessWidget {
  const _Speed(this.icon, this.mbps);

  final IconData icon;
  final double mbps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.text2),
        const SizedBox(width: 3),
        Text.rich(
          TextSpan(
            text: formatMbps(mbps),
            style: AppText.figure(16),
            children: [
              TextSpan(
                text: ' Mbps',
                style: AppText.style(12, color: AppColors.text2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          const IconTile(Icons.speed_rounded, size: 56),
          const SizedBox(height: 14),
          Text(
            'No tests yet',
            style: AppText.style(17, weight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Run a speed test and the result is saved here.',
            textAlign: TextAlign.center,
            style: AppText.style(15, color: AppColors.text2),
          ),
        ],
      ),
    );
  }
}
