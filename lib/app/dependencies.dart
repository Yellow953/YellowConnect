import 'dart:async';

import '../core/services/network_info_service.dart';
import '../core/services/preferences_service.dart';
import '../features/connection/model/vpn_repository.dart';
import '../features/connection/presenter/connection_presenter.dart';
import '../features/network/presenter/network_presenter.dart';
import '../features/ip_checker/model/ip_repository.dart';
import '../features/ip_checker/presenter/ip_checker_presenter.dart';
import '../features/onboarding/presenter/onboarding_presenter.dart';
import '../features/settings/model/settings_repository.dart';
import '../features/settings/presenter/settings_presenter.dart';
import '../features/speed_test/model/speed_history_repository.dart';
import '../features/speed_test/model/speed_test_repository.dart';
import '../features/speed_test/presenter/speed_test_presenter.dart';

/// Composition root: builds every repository and presenter once and injects
/// them through constructors.
class AppDependencies {
  AppDependencies._({
    required this.network,
    required this.connection,
    required this.ipChecker,
    required this.speedTest,
    required this.settings,
    required this.onboarding,
  });

  final NetworkPresenter network;
  final ConnectionPresenter connection;
  final IpCheckerPresenter ipChecker;
  final SpeedTestPresenter speedTest;
  final SettingsPresenter settings;
  final OnboardingPresenter onboarding;

  static Future<AppDependencies> create() async {
    final vpnRepository = VpnRepository();
    final settingsRepository = SettingsRepository(PreferencesService());
    final networkInfo = NetworkInfoService();

    final deps = AppDependencies._(
      network: NetworkPresenter(networkInfo),
      connection: ConnectionPresenter(vpnRepository),
      ipChecker: IpCheckerPresenter(IpRepository(), vpnRepository.statusStream),
      speedTest: SpeedTestPresenter(
        SpeedTestRepository(),
        SpeedHistoryRepository(),
        networkInfo,
      ),
      settings: SettingsPresenter(settingsRepository),
      onboarding: OnboardingPresenter(vpnRepository, settingsRepository),
    );

    await Future.wait([
      deps.network.init(),
      deps.connection.init(),
      deps.settings.init(),
      deps.onboarding.init(),
      deps.speedTest.init(),
    ]);
    deps.ipChecker.init();

    if (deps.onboarding.completed && deps.settings.autoConnect) {
      unawaited(deps.connection.connect());
    }
    return deps;
  }
}
