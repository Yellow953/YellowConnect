import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/logo.dart';
import '../../../core/widgets/surfaces.dart';
import '../../connection/presenter/connection_presenter.dart';
import '../../connection/view/connection_status_style.dart';
import '../../speed_test/presenter/speed_test_presenter.dart';
import '../../speed_test/view/speed_history_sheet.dart';
import '../presenter/settings_presenter.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.presenter,
    required this.connection,
    required this.speedTest,
  });

  final SettingsPresenter presenter;
  final ConnectionPresenter connection;
  final SpeedTestPresenter speedTest;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([presenter, connection, speedTest]),
      builder: (context, _) {
        return AppPage(
          title: 'Settings',
          children: [
            _AppCard(connection: connection),
            const SectionLabel('VPN'),
            DetailList(
              rows: [
                DetailRow(
                  icon: Icons.bolt_rounded,
                  tone: IconTileTone.yellow,
                  label: 'Connect on launch',
                  caption: 'Turn the VPN on when the app opens',
                  trailing: Switch(
                    value: presenter.autoConnect,
                    onChanged: presenter.setAutoConnect,
                  ),
                ),
              ],
            ),
            const SectionLabel('Speed test'),
            DetailList(
              rows: [
                DetailRow(
                  icon: Icons.history_rounded,
                  label: 'Test history',
                  caption: switch (speedTest.history.length) {
                    0 => 'No tests saved',
                    1 => '1 test saved',
                    final n => '$n tests saved',
                  },
                  trailing: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.red,
                      minimumSize: const Size(64, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: speedTest.history.isEmpty
                        ? null
                        : () => confirmClearSpeedHistory(context, speedTest),
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),
            const SectionLabel('About'),
            const DetailList(
              rows: [
                DetailRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Version',
                  value: AppConstants.appVersion,
                ),
                DetailRow(
                  icon: Icons.business_rounded,
                  label: 'Publisher',
                  value: AppConstants.publisher,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Dark card naming the app, its version and the live VPN state.
class _AppCard extends StatelessWidget {
  const _AppCard({required this.connection});

  final ConnectionPresenter connection;

  @override
  Widget build(BuildContext context) {
    final status = connection.status;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Logo(height: 60),
              const Spacer(),
              StatusChip(
                dark: true,
                label: 'VPN ${status.label.toLowerCase()}',
                dotColor: status.dotColor,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Yellow Connect',
            style: AppText.style(
              22,
              weight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'VPN, speed test and IP checker',
            style: AppText.style(15, color: AppColors.text2),
          ),
        ],
      ),
    );
  }
}
