import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../connection/model/vpn_failure.dart';
import '../../connection/model/vpn_repository.dart';
import '../../settings/model/settings_repository.dart';

class OnboardingPresenter extends ChangeNotifier {
  OnboardingPresenter(this._vpnRepository, this._settingsRepository);

  final VpnRepository _vpnRepository;
  final SettingsRepository _settingsRepository;

  bool _completed = false;
  bool get completed => _completed;

  bool _working = false;
  bool get working => _working;

  VpnFailure? _failure;
  VpnFailure? get failure => _failure;

  Future<void> init() async {
    _completed = await _settingsRepository.getOnboardingDone();
    notifyListeners();
  }

  /// Registers the tunnel, which triggers the Android VPN permission dialog.
  /// On iOS the system asks to add the VPN profile on first connect instead.
  Future<void> grantVpnPermission() async {
    if (_working) return;
    _working = true;
    _failure = null;
    notifyListeners();

    switch (await _vpnRepository.initialize()) {
      case Ok():
        await _settingsRepository.setOnboardingDone();
        _completed = true;
      case Err(:final failure):
        _failure = failure;
    }
    _working = false;
    notifyListeners();
  }

  Future<void> skip() async {
    await _settingsRepository.setOnboardingDone();
    _completed = true;
    notifyListeners();
  }
}
