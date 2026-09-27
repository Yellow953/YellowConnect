import 'package:flutter/foundation.dart';

import '../model/settings_repository.dart';

class SettingsPresenter extends ChangeNotifier {
  SettingsPresenter(this._repository);

  final SettingsRepository _repository;

  bool _autoConnect = false;
  bool get autoConnect => _autoConnect;

  Future<void> init() async {
    _autoConnect = await _repository.getAutoConnect();
    notifyListeners();
  }

  Future<void> setAutoConnect(bool value) async {
    _autoConnect = value;
    notifyListeners();
    await _repository.setAutoConnect(value);
  }
}
