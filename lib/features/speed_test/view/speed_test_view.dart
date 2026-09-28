import 'package:flutter/material.dart';

import '../../../core/services/network_info_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/network_labels.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/surfaces.dart';
import '../../network/presenter/network_presenter.dart';
import '../presenter/speed_test_presenter.dart';
import 'speed_gauge.dart';
import 'speed_history_sheet.dart';

class SpeedTestView extends StatelessWidget {
  const SpeedTestView({
    super.key,
    required this.presenter,
    required this.network,
  });

  final SpeedTestPresenter presenter;
  final NetworkPresenter network;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([presenter, network]),
      builder: (context, _) {
        final state = presenter.state;
        final running = presenter.isRunning;
        final last = presenter.lastResult;
        final download = presenter.downloadMbps ?? last?.downloadMbps;
        final upload = presenter.uploadMbps ?? last?.uploadMbps;
        final shown = running ? presenter.currentMbps : (download ?? 0);
        final showStart = !running && download == null;

        return AppPage(
          title: 'Speed test',
          subtitle: switch (network.networkType) {
            null => null,
            NetworkType.none => 'No network',
            final type => 'On ${type.label}',
          },
          action: RoundIconButton(
            icon: Icons.history_rounded,
            tooltip: 'History',
            onPressed: () => showSpeedHistory(context, presenter),
          ),
          fill: true,
          children: [
            const Spacer(),
            SpeedGauge(
              mbps: shown,
              showNeedle: !showStart,
              sweep: state == SpeedTestState.selectingServer,
              center: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: showStart
                    ? _StartButton(onPressed: presenter.start)
                    : const SizedBox.shrink(),
              ),
              readout: showStart ? null : _Readout(state: state, mbps: shown),
            ),
            if (presenter.error case final error?)
              Text(
                error,
                textAlign: TextAlign.center,
                style: AppText.style(14, color: AppColors.red),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Result(
                    icon: Icons.arrow_downward_rounded,
                    tone: IconTileTone.yellow,
                    label: 'Download',
                    mbps: download,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Result(
                    icon: Icons.arrow_upward_rounded,
                    tone: IconTileTone.dark,
                    label: 'Upload',
                    mbps: upload,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const SizedBox(height: 20),
            if (running)
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.black,
                  foregroundColor: AppColors.white,
                ),
                onPressed: presenter.cancel,
                child: const Text('Stop test'),
              )
            else if (!showStart)
              Row(
                children: [
                  Expanded(
                    child: _ShadowedButton(
                      shadow: Colors.black.withValues(alpha: 0.06),
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.card,
                          foregroundColor: AppColors.text,
                        ),
                        onPressed: presenter.clear,
                        icon: const Icon(Icons.close_rounded, size: 20),
                        label: const Text('Clear'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _ShadowedButton(
                      shadow: AppColors.yellow.withValues(alpha: 0.4),
                      child: FilledButton.icon(
                        onPressed: presenter.start,
                        icon: const Icon(Icons.refresh_rounded, size: 22),
                        label: const Text('Test again'),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

/// Digital readout under the needle: current phase, speed and unit.
class _Readout extends StatelessWidget {
  const _Readout({required this.state, required this.mbps});

  final SpeedTestState state;
  final double mbps;

  @override
  Widget build(BuildContext context) {
    final icon = switch (state) {
      SpeedTestState.testingDownload ||
      SpeedTestState.done => Icons.arrow_downward_rounded,
      SpeedTestState.testingUpload => Icons.arrow_upward_rounded,
      _ => null,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatMbps(mbps),
          style: AppText.figure(54, weight: FontWeight.w800),
        ),
        Text(
          'Mbps',
          style: AppText.style(
            15,
            weight: FontWeight.w600,
            color: AppColors.text2,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.text2),
              const SizedBox(width: 3),
            ],
            Text(
              _label(state),
              style: AppText.style(
                14,
                weight: FontWeight.w600,
                color: AppColors.text2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _label(SpeedTestState state) => switch (state) {
    SpeedTestState.idle => 'Ready',
    SpeedTestState.selectingServer => 'Getting ready',
    SpeedTestState.testingDownload => 'Download',
    SpeedTestState.testingUpload => 'Upload',
    SpeedTestState.done => 'Download',
    SpeedTestState.error => 'Didn\'t finish',
  };
}

/// Big yellow "Start" in the middle of the gauge before the first test.
class _StartButton extends StatelessWidget {
  const _StartButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Start test',
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 150,
          height: 150,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.yellow,
            boxShadow: [
              BoxShadow(
                color: AppColors.yellow.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            'Start',
            style: AppText.style(
              26,
              weight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft colored shadow under a stadium button, so it lifts off the gray page
/// like the cards do.
class _ShadowedButton extends StatelessWidget {
  const _ShadowedButton({required this.shadow, required this.child});

  final Color shadow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({
    required this.icon,
    required this.tone,
    required this.label,
    required this.mbps,
  });

  final IconData icon;
  final IconTileTone tone;
  final String label;
  final double? mbps;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconTile(icon, tone: tone, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.style(13, color: AppColors.text2)),
                Text.rich(
                  TextSpan(
                    text: mbps == null ? '—' : formatMbps(mbps!),
                    style: AppText.figure(21),
                    children: [
                      if (mbps != null)
                        TextSpan(
                          text: ' Mbps',
                          style: AppText.style(13, color: AppColors.text2),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
