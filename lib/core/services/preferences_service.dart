import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over shared_preferences so repositories don't depend on it
/// directly.
class PreferencesService {
  PreferencesService([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  Future<bool> getBool(String key, {bool defaultValue = false}) async =>
      await _prefs.getBool(key) ?? defaultValue;

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
}
