import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../connection/model/connection_status.dart';
import '../model/ip_failure.dart';
import '../model/ip_info.dart';
import '../model/ip_repository.dart';

class IpCheckerPresenter extends ChangeNotifier {
  IpCheckerPresenter(this._repository, this._vpnStatus);

  final IpRepository _repository;
  final Stream<ConnectionStatus> _vpnStatus;
  StreamSubscription<ConnectionStatus>? _vpnSub;
  ConnectionStatus? _lastVpnStatus;

  IpInfo? _info;
  IpInfo? get info => _info;

  IpFailure? _failure;
  IpFailure? get failure => _failure;

  bool _loading = false;
  bool get loading => _loading;

  void init() {
    _vpnSub = _vpnStatus.listen(_onVpnStatus);
    refresh();
  }

  Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();
    switch (await _repository.fetchPublicIp()) {
      case Ok(:final value):
        _info = value;
        _failure = null;
      case Err(:final failure):
        _failure = failure;
    }
    _loading = false;
    notifyListeners();
  }

  /// Re-check once the tunnel settles in either direction.
  void _onVpnStatus(ConnectionStatus status) {
    final settled =
        status == ConnectionStatus.connected ||
        status == ConnectionStatus.disconnected;
    if (settled && status != _lastVpnStatus) {
      Future.delayed(const Duration(seconds: 1), refresh);
    }
    _lastVpnStatus = status;
  }

  @override
  void dispose() {
    _vpnSub?.cancel();
    super.dispose();
  }
}
