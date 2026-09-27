import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/surfaces.dart';
import '../model/connection_status.dart';
import '../presenter/connection_presenter.dart';
import 'connection_status_style.dart';
import 'power_button.dart';

class ConnectionView extends StatelessWidget {
  const ConnectionView({super.key, required this.presenter});

  final ConnectionPresenter presenter;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: presenter,
      builder: (context, _) {
        final status = presenter.status;
        final host = presenter.serverHost;

        return AppPage(
          title: 'Yellow Connect',
          action: StatusChip(label: status.label, dotColor: status.dotColor),
          fill: true,
          children: [
            const Spacer(),
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: -120,
                    right: -120,
                    top: -120,
                    bottom: -120,
                    child: _Glow(on: status.isLit),
                  ),
                  PowerButton(
                    size: 290,
                    status: status,
                    onPressed: presenter.isBusy ? null : presenter.toggle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            Text(
              _headline(status),
              textAlign: TextAlign.center,
              style: AppText.style(
                30,
                weight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 6),
            presenter.isConnected
                ? Text(
                    formatDuration(presenter.elapsed),
                    textAlign: TextAlign.center,
                    style: AppText.figure(
                      20,
                      weight: FontWeight.w600,
                      color: AppColors.text2,
                    ),
                  )
                : Text(
                    _hint(status, host),
                    textAlign: TextAlign.center,
                    style: AppText.style(16, color: AppColors.text2),
                  ),
            if (presenter.failure case final failure?)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
                child: Text(
                  failure.message,
                  textAlign: TextAlign.center,
                  style: AppText.style(14, color: AppColors.red, height: 1.35),
                ),
              ),
            const Spacer(flex: 2),
          ],
        );
      },
    );
  }

  static String _headline(ConnectionStatus status) => switch (status) {
    ConnectionStatus.connected => 'You\'re protected',
    ConnectionStatus.connecting => 'Connecting…',
    ConnectionStatus.disconnecting => 'Disconnecting…',
    ConnectionStatus.disconnected => 'Not connected',
  };

  static String _hint(ConnectionStatus status, String? host) =>
      switch (status) {
        ConnectionStatus.connecting => 'Securing your connection',
        ConnectionStatus.disconnecting => 'Turning off the VPN',
        _ => host == null ? 'The VPN isn\'t set up yet' : 'Tap to connect',
      };
}

/// Soft light behind the button; turns yellow when connected.
class _Glow extends StatelessWidget {
  const _Glow({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              on
                  ? AppColors.yellow.withValues(alpha: 0.28)
                  : AppColors.white.withValues(alpha: 0.9),
              on
                  ? AppColors.yellow.withValues(alpha: 0)
                  : AppColors.white.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
