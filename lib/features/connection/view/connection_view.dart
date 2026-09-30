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
        final failure = presenter.failure;

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
                  // The rings animate continuously while connected; keep
                  // those repaints from spreading to the rest of the page.
                  RepaintBoundary(
                    child: PowerButton(
                      size: 290,
                      status: status,
                      onPressed: presenter.isBusy ? null : presenter.toggle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            _Swap(
              child: Text(
                _headline(status),
                key: ValueKey(status),
                textAlign: TextAlign.center,
                style: AppText.style(
                  30,
                  weight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            const SizedBox(height: 6),
            _Swap(
              child: presenter.isConnected
                  ? ValueListenableBuilder(
                      key: const ValueKey('timer'),
                      valueListenable: presenter.elapsed,
                      builder: (context, elapsed, _) => Text(
                        formatDuration(elapsed),
                        textAlign: TextAlign.center,
                        style: AppText.figure(
                          20,
                          weight: FontWeight.w600,
                          color: AppColors.text2,
                        ),
                      ),
                    )
                  : Text(
                      _hint(status, host),
                      key: ValueKey(status),
                      textAlign: TextAlign.center,
                      style: AppText.style(16, color: AppColors.text2),
                    ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: failure != null
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
                      child: Text(
                        failure.message,
                        textAlign: TextAlign.center,
                        style: AppText.style(
                          14,
                          color: AppColors.red,
                          height: 1.35,
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            const Spacer(),
            const SizedBox(height: 24),
            _ServerCard(presenter: presenter),
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

/// Cross-fades and slides text when its key changes.
class _Swap extends StatelessWidget {
  const _Swap({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.25),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// The server in use; grows to show the tunnel address once connected.
class _ServerCard extends StatelessWidget {
  const _ServerCard({required this.presenter});

  final ConnectionPresenter presenter;

  @override
  Widget build(BuildContext context) {
    final connected = presenter.isConnected;
    final host = presenter.serverHost;
    final tunnelIp = presenter.tunnelIp;

    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: DetailList(
        rows: [
          DetailRow(
            icon: Icons.dns_rounded,
            tone: connected ? IconTileTone.yellow : IconTileTone.gray,
            label: 'Server',
            caption: 'WireGuard',
            value: host ?? 'Not set up',
          ),
          if (connected && tunnelIp != null)
            DetailRow(
              icon: Icons.lock_rounded,
              tone: IconTileTone.yellow,
              label: 'Tunnel IP',
              caption: 'Your address inside the VPN',
              value: tunnelIp,
            ),
        ],
      ),
    );
  }
}
