import 'package:flutter/services.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';
import 'package:wireguard_flutter/wireguard_flutter_platform_interface.dart';

import '../../../core/constants.dart';
import '../../../core/result.dart';
import 'connection_status.dart';
import 'vpn_config.dart';
import 'vpn_failure.dart';

/// Wraps the wireguard_flutter plugin and the bundled config.
class VpnRepository {
  VpnRepository({WireGuardFlutterInterface? wireGuard, AssetBundle? bundle})
    : _wireGuard = wireGuard ?? WireGuardFlutter.instance,
      _bundle = bundle ?? rootBundle;

  final WireGuardFlutterInterface _wireGuard;
  final AssetBundle _bundle;
  bool _initialized = false;
  VpnConfig? _config;

  /// Single shared subscription: the plugin's EventChannel only supports one
  /// native listener, so every consumer must go through this stream.
  late final Stream<ConnectionStatus> statusStream = _wireGuard.vpnStageSnapshot
      .map(_mapStage)
      .asBroadcastStream();

  Future<ConnectionStatus> currentStatus() async =>
      _mapStage(await _wireGuard.stage());

  /// Sets up the tunnel. On Android this shows the system VPN permission
  /// dialog the first time.
  Future<Result<void, VpnFailure>> initialize() async {
    if (_initialized) return const Ok(null);
    try {
      await _wireGuard.initialize(interfaceName: AppConstants.vpnTunnelName);
      _initialized = true;
      return const Ok(null);
    } on PlatformException catch (e) {
      return Err(_mapPlatformError(e));
    }
  }

  Future<Result<VpnConfig, VpnFailure>> loadConfig() async {
    if (_config case final config?) return Ok(config);
    final String raw;
    try {
      raw = await _bundle.loadString(AppConstants.vpnConfigAsset);
    } catch (_) {
      return const Err(VpnConfigMissing());
    }
    try {
      return Ok(_config = VpnConfig.parse(raw));
    } on FormatException catch (e) {
      return Err(VpnConfigInvalid(e.message));
    }
  }

  Future<Result<void, VpnFailure>> connect() async {
    final init = await initialize();
    if (init is Err<void, VpnFailure>) return init;

    final VpnConfig config;
    switch (await loadConfig()) {
      case Ok(:final value):
        config = value;
      case Err(:final failure):
        return Err(failure);
    }

    try {
      await _wireGuard.startVpn(
        serverAddress: config.serverAddress,
        wgQuickConfig: config.wgQuickConfig,
        providerBundleIdentifier: AppConstants.iosTunnelBundleId,
      );
      return const Ok(null);
    } on PlatformException catch (e) {
      return Err(_mapPlatformError(e));
    }
  }

  Future<Result<void, VpnFailure>> disconnect() async {
    try {
      await _wireGuard.stopVpn();
      return const Ok(null);
    } on PlatformException catch (e) {
      return Err(_mapPlatformError(e));
    }
  }

  static VpnFailure _mapPlatformError(PlatformException e) {
    final message = e.message ?? e.code;
    if (message.contains('Permissions are not given')) {
      return const VpnPermissionDenied();
    }
    return VpnPlatformError(message);
  }

  static ConnectionStatus _mapStage(VpnStage stage) => switch (stage) {
    VpnStage.connected => ConnectionStatus.connected,
    VpnStage.connecting ||
    VpnStage.preparing ||
    VpnStage.authenticating ||
    VpnStage.reconnect ||
    VpnStage.waitingConnection => ConnectionStatus.connecting,
    VpnStage.disconnecting ||
    VpnStage.exiting => ConnectionStatus.disconnecting,
    VpnStage.disconnected ||
    VpnStage.noConnection ||
    VpnStage.denied => ConnectionStatus.disconnected,
  };
}
