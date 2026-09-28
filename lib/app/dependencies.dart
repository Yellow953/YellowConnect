import 'dart:async';

import '../core/services/network_info_service.dart';
import '../core/services/preferences_service.dart';
import '../features/connection/model/vpn_repository.dart';
import '../features/connection/presenter/connection_presenter.dart';
import '../features/launch_actions/model/launch_action_repository.dart';
import '../features/launch_actions/presenter/launch_action_presenter.dart';
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
    required this.launchActions,
  });

  final NetworkPresenter network;
  final ConnectionPresenter connection;
  final IpCheckerPresenter ipChecker;
  final SpeedTestPresenter speedTest;
  final SettingsPresenter settings;
  final OnboardingPresenter onboarding;
  final LaunchActionPresenter launchActions;

  static Future<AppDependencies> create() async {
    final vpnRepository = VpnRepository();
    final settingsRepository = SettingsRepository(PreferencesService());
    final networkInfo = NetworkInfoService();
    final connection = ConnectionPresenter(vpnRepository);
    final speedTest = SpeedTestPresenter(
      SpeedTestRepository(),
      SpeedHistoryRepository(),
      networkInfo,
    );
    final onboarding = OnboardingPresenter(vpnRepository, settingsRepository);

    final deps = AppDependencies._(
      network: NetworkPresenter(networkInfo),
      connection: connection,
      ipChecker: IpCheckerPresenter(IpRepository(), vpnRepository.statusStream),
      speedTest: speedTest,
      settings: SettingsPresenter(settingsRepository),
      onboarding: onboarding,
      launchActions: LaunchActionPresenter(
        LaunchActionRepository(),
        connection,
        speedTest,
        onboarding,
      ),
    );

    await Future.wait([
      deps.network.init(),
      deps.connection.init(),
      deps.settings.init(),
      deps.onboarding.init(),
      deps.speedTest.init(),
    ]);
    deps.ipChecker.init();
    await deps.launchActions.init();

    if (deps.onboarding.completed && deps.settings.autoConnect) {
      unawaited(deps.connection.connect());
    }
    return deps;
  }
}
