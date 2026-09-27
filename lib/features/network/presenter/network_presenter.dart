import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/services/network_info_service.dart';

/// Live network type (Wi-Fi, mobile, ...) shown on the VPN and speed pages.
class NetworkPresenter extends ChangeNotifier {
  NetworkPresenter(this._networkInfo);

  final NetworkInfoService _networkInfo;
  StreamSubscription<NetworkType>? _sub;

  NetworkType? _networkType;
  NetworkType? get networkType => _networkType;

  Future<void> init() async {
    _sub = _networkInfo.onTypeChanged.listen(_set);
    _set(await _networkInfo.currentType());
  }

  void _set(NetworkType type) {
    _networkType = type;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
