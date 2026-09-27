import '../../../core/services/preferences_service.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  final PreferencesService _prefs;

  static const _autoConnectKey = 'auto_connect';
  static const _onboardingDoneKey = 'onboarding_done';

  Future<bool> getAutoConnect() => _prefs.getBool(_autoConnectKey);

  Future<void> setAutoConnect(bool value) =>
      _prefs.setBool(_autoConnectKey, value);

  Future<bool> getOnboardingDone() => _prefs.getBool(_onboardingDoneKey);

  Future<void> setOnboardingDone() => _prefs.setBool(_onboardingDoneKey, true);
}
