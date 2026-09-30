import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../model/connection_status.dart';
import '../model/vpn_config.dart';
import '../model/vpn_failure.dart';
import '../model/vpn_repository.dart';

class ConnectionPresenter extends ChangeNotifier {
  ConnectionPresenter(this._repository);

  final VpnRepository _repository;
  StreamSubscription<ConnectionStatus>? _statusSub;
  Timer? _ticker;
  DateTime? _connectedSince;

  ConnectionStatus _status = ConnectionStatus.disconnected;
  ConnectionStatus get status => _status;

  VpnFailure? _failure;
  VpnFailure? get failure => _failure;

  VpnConfig? _config;
  String? get serverHost => _config?.serverHost;

  /// This device's address inside the tunnel, without the prefix length.
  String? get tunnelIp => _config?.tunnelAddress?.split('/').first;

  /// Time since connecting. Ticks every second on its own notifier so views
  /// that only care about [status] don't rebuild with it.
  final _elapsed = ValueNotifier(Duration.zero);
  ValueListenable<Duration> get elapsed => _elapsed;

  bool get isBusy =>
      _status == ConnectionStatus.connecting ||
      _status == ConnectionStatus.disconnecting;

  bool get isConnected => _status == ConnectionStatus.connected;

  Future<void> init() async {
    _statusSub = _repository.statusStream.listen(_onStatus);
    if (await _repository.loadConfig() case Ok(:final value)) {
      _config = value;
    }
    try {
      _onStatus(await _repository.currentStatus());
    } catch (_) {
      // Plugin not initialized yet; stay disconnected until the first event.
      notifyListeners();
    }
  }

  Future<void> toggle() => isConnected ? disconnect() : connect();

  Future<void> connect() async {
    if (isBusy || isConnected) return;
    _failure = null;
    _setStatus(ConnectionStatus.connecting);
    if (await _repository.connect() case Err(:final failure)) {
      _failure = failure;
      if (failure.detail case final detail?) debugPrint('VPN: $detail');
      _setStatus(ConnectionStatus.disconnected);
    }
  }

  Future<void> disconnect() async {
    if (isBusy || !isConnected) return;
    _failure = null;
    _setStatus(ConnectionStatus.disconnecting);
    if (await _repository.disconnect() case Err(:final failure)) {
      _failure = failure;
      if (failure.detail case final detail?) debugPrint('VPN: $detail');
      _setStatus(ConnectionStatus.connected);
    }
  }

  void _onStatus(ConnectionStatus status) {
    if (status == ConnectionStatus.connected) _failure = null;
    _setStatus(status);
  }

  void _setStatus(ConnectionStatus status) {
    _status = status;
    if (status == ConnectionStatus.connected) {
      _startTicker();
    } else if (status == ConnectionStatus.disconnected) {
      _stopTicker();
    }
    notifyListeners();
  }

  void _startTicker() {
    if (_ticker != null) return;
    _connectedSince = DateTime.now();
    _elapsed.value = Duration.zero;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed.value = DateTime.now().difference(_connectedSince!);
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
    _connectedSince = null;
    _elapsed.value = Duration.zero;
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _ticker?.cancel();
    _elapsed.dispose();
    super.dispose();
  }
}
