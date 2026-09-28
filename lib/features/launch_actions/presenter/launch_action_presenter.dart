import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../app/app_tab.dart';
import '../../connection/presenter/connection_presenter.dart';
import '../../onboarding/presenter/onboarding_presenter.dart';
import '../../speed_test/presenter/speed_test_presenter.dart';
import '../model/launch_action.dart';
import '../model/launch_action_repository.dart';

/// Runs widget actions: connect the VPN or start a speed test, and asks the
/// shell to show the matching tab.
class LaunchActionPresenter extends ChangeNotifier {
  LaunchActionPresenter(
    this._repository,
    this._connection,
    this._speedTest,
    this._onboarding,
  );

  final LaunchActionRepository _repository;
  final ConnectionPresenter _connection;
  final SpeedTestPresenter _speedTest;
  final OnboardingPresenter _onboarding;
  StreamSubscription<LaunchAction>? _sub;

  AppTab? _requestedTab;

  /// Tab the latest action wants on screen. Cleared once read.
  AppTab? takeRequestedTab() {
    final tab = _requestedTab;
    _requestedTab = null;
    return tab;
  }

  /// Call after the other presenters are initialized.
  Future<void> init() async {
    _sub = _repository.actions.listen(_handle);
    if (await _repository.initialAction() case final action?) _handle(action);
  }

  void _handle(LaunchAction action) {
    // Before onboarding there's no VPN permission yet; onboarding shows instead.
    if (!_onboarding.completed) return;
    switch (action) {
      case LaunchAction.connectVpn:
        _requestedTab = AppTab.vpn;
        unawaited(_connection.connect());
      case LaunchAction.startSpeedTest:
        _requestedTab = AppTab.speedTest;
        unawaited(_speedTest.start());
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
