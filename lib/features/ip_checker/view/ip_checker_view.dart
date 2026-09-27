import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/surfaces.dart';
import '../../connection/presenter/connection_presenter.dart';
import '../model/ip_info.dart';
import '../presenter/ip_checker_presenter.dart';

class IpCheckerView extends StatelessWidget {
  const IpCheckerView({
    super.key,
    required this.presenter,
    required this.connection,
  });

  final IpCheckerPresenter presenter;
  final ConnectionPresenter connection;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([presenter, connection]),
      builder: (context, _) {
        final info = presenter.info;
        return AppPage(
          title: 'IP address',
          subtitle: 'What websites see',
          action: RoundIconButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Refresh',
            onPressed: presenter.loading ? null : presenter.refresh,
          ),
          children: [
            _IpCard(
              info: info,
              loading: presenter.loading,
              viaVpn: connection.isConnected,
            ),
            if (presenter.failure case final failure?)
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 12, 6, 0),
                child: Text(
                  failure.message,
                  style: AppText.style(14, color: AppColors.red),
                ),
              ),
            const SectionLabel('Details'),
            DetailList(
              rows: [
                DetailRow(
                  icon: Icons.location_city_rounded,
                  label: 'City',
                  value: info?.city ?? '—',
                ),
                DetailRow(
                  icon: Icons.flag_rounded,
                  label: 'Country',
                  value: info?.country ?? '—',
                ),
                DetailRow(
                  icon: Icons.router_rounded,
                  label: 'Provider',
                  value: info?.isp ?? '—',
                ),
                DetailRow(
                  icon: Icons.schedule_rounded,
                  label: 'Time zone',
                  value: info?.timezone ?? '—',
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Dark card with the IP front and center.
class _IpCard extends StatelessWidget {
  const _IpCard({
    required this.info,
    required this.loading,
    required this.viaVpn,
  });

  final IpInfo? info;
  final bool loading;
  final bool viaVpn;

  void _copy(BuildContext context, String ip) {
    Clipboard.setData(ClipboardData(text: ip));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('IP copied')));
  }

  @override
  Widget build(BuildContext context) {
    final info = this.info;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            bottom: -50,
            child: Icon(
              Icons.public_rounded,
              size: 190,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusChip(
                      dark: true,
                      label: viaVpn ? 'Through your VPN' : 'Direct connection',
                      dotColor: viaVpn ? AppColors.yellow : AppColors.text2,
                    ),
                    const Spacer(),
                    RoundIconButton(
                      dark: true,
                      icon: Icons.copy_rounded,
                      tooltip: 'Copy IP',
                      onPressed: info == null
                          ? null
                          : () => _copy(context, info.ip),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    info?.ip ?? (loading ? 'Checking…' : '—'),
                    style: AppText.figure(
                      38,
                      weight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  info?.location == null
                      ? 'Location unknown'
                      : '${info?.flag ?? ''}  ${info?.location}'.trim(),
                  style: AppText.style(16, color: AppColors.text2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
