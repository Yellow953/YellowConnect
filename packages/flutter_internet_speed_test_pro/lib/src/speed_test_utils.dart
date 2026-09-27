import 'package:connectivity_plus/connectivity_plus.dart';

/// Checks if internet connectivity is available.
///
/// This function uses the connectivity_plus package to determine
/// if the device has an active internet connection through
/// mobile data, WiFi, or ethernet.
///
/// Returns a [Future<bool>] that completes with `true` if internet
/// is available, `false` otherwise.
Future<bool> isInternetAvailable() async {
  final connectivity = Connectivity();
  final connectivityResult = await connectivity.checkConnectivity();
  return connectivityResult.contains(ConnectivityResult.mobile) ||
      connectivityResult.contains(ConnectivityResult.wifi) ||
      connectivityResult.contains(ConnectivityResult.ethernet);
}
