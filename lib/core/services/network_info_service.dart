import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkType { wifi, mobile, ethernet, none, other }

/// Reports the underlying network (Wi-Fi vs. mobile), ignoring VPN overlays.
class NetworkInfoService {
  NetworkInfoService([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<NetworkType> currentType() async =>
      _map(await _connectivity.checkConnectivity());

  Stream<NetworkType> get onTypeChanged =>
      _connectivity.onConnectivityChanged.map(_map);

  static NetworkType _map(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) return NetworkType.wifi;
    if (results.contains(ConnectivityResult.mobile)) return NetworkType.mobile;
    if (results.contains(ConnectivityResult.ethernet)) {
      return NetworkType.ethernet;
    }
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return NetworkType.none;
    }
    return NetworkType.other;
  }
}
