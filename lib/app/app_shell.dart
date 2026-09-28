import 'package:flutter/material.dart';

import '../features/connection/view/connection_view.dart';
import '../features/ip_checker/view/ip_checker_view.dart';
import '../features/settings/view/settings_view.dart';
import '../features/speed_test/view/speed_test_view.dart';
import 'app_tab.dart';
import 'dependencies.dart';
import 'glass_nav_bar.dart';

/// Tab host. Pages stay alive in an IndexedStack so switching tabs keeps
/// scroll position and in-progress tests.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // A widget tap on cold start picks the first tab.
  late AppTab _tab = widget.deps.launchActions.takeRequestedTab() ?? AppTab.vpn;

  static const _items = {
    AppTab.vpn: GlassNavItem(
      Icons.shield_outlined,
      Icons.shield_rounded,
      'VPN',
    ),
    AppTab.speedTest: GlassNavItem(
      Icons.speed_outlined,
      Icons.speed_rounded,
      'Speed',
    ),
    AppTab.ipChecker: GlassNavItem(
      Icons.public_outlined,
      Icons.public_rounded,
      'IP',
    ),
    AppTab.settings: GlassNavItem(
      Icons.settings_outlined,
      Icons.settings_rounded,
      'Settings',
    ),
  };

  @override
  void initState() {
    super.initState();
    widget.deps.launchActions.addListener(_onLaunchAction);
  }

  @override
  void dispose() {
    widget.deps.launchActions.removeListener(_onLaunchAction);
    super.dispose();
  }

  void _onLaunchAction() {
    if (widget.deps.launchActions.takeRequestedTab() case final tab?) {
      _select(tab);
    }
  }

  void _select(AppTab tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    final deps = widget.deps;
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _tab.index,
        children: [
          ConnectionView(presenter: deps.connection),
          SpeedTestView(presenter: deps.speedTest, network: deps.network),
          IpCheckerView(presenter: deps.ipChecker, connection: deps.connection),
          SettingsView(
            presenter: deps.settings,
            connection: deps.connection,
            speedTest: deps.speedTest,
          ),
        ],
      ),
      bottomNavigationBar: GlassNavBar(
        items: _items.values.toList(),
        index: _tab.index,
        onSelect: (i) => _select(AppTab.values[i]),
      ),
    );
  }
}
