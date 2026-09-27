import 'package:flutter/foundation.dart';
import 'package:flutter_internet_speed_test_pro/src/models/server_selection_response.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tuple_dart/tuple.dart';

import 'callbacks_enum.dart';
import 'flutter_internet_speed_test_method_channel.dart';

/// Callback function type for cancelling a listening operation.
typedef CancelListening = void Function();

/// Callback function type for when a test is completed.
typedef DoneCallback = void Function(double transferRate, SpeedUnit unit);

/// Callback function type for test progress updates.
typedef ProgressCallback = void Function(
  double percent,
  double transferRate,
  SpeedUnit unit,
);

/// Callback function type for error handling.
typedef ErrorCallback = void Function(
    String errorMessage, String speedTestError);

/// Callback function type for test cancellation.
typedef CancelCallback = void Function();

/// Platform interface for internet speed testing functionality.
///
/// This abstract class defines the interface that platform-specific
/// implementations must implement for internet speed testing.
abstract class FlutterInternetSpeedTestPlatform extends PlatformInterface {
  /// Constructs a FlutterInternetSpeedTestPlatform.
  FlutterInternetSpeedTestPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterInternetSpeedTestPlatform _instance =
      MethodChannelFlutterInternetSpeedTest();

  /// The default instance of [FlutterInternetSpeedTestPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterInternetSpeedTest].
  static FlutterInternetSpeedTestPlatform get instance => _instance;

  /// Map of callbacks indexed by test ID.
  Map<int,
          Tuple4<ErrorCallback, ProgressCallback, DoneCallback, CancelCallback>>
      callbacksById = {};

  /// Current download rate in bytes per second.
  int downloadRate = 0;

  /// Current upload rate in bytes per second.
  int uploadRate = 0;

  /// Number of download test steps completed.
  int downloadSteps = 0;

  /// Number of upload test steps completed.
  int uploadSteps = 0;

  /// Whether logging is enabled.
  bool logEnabled = false;

  /// Gets whether logging is enabled and debug mode is active.
  bool get isLogEnabled => logEnabled && kDebugMode;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterInternetSpeedTestPlatform] when
  /// they register themselves.
  static set instance(FlutterInternetSpeedTestPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Starts a download speed test.
  ///
  /// Parameters:
  /// - [onDone]: Callback when download test completes
  /// - [onProgress]: Callback for progress updates
  /// - [onError]: Callback for error handling
  /// - [onCancel]: Callback when test is cancelled
  /// - [fileSize]: Size of file to download for testing
  /// - [testServer]: URL of the test server
  ///
  /// Returns a [Future<CancelListening>] that provides a function to cancel the test.
  Future<CancelListening> startDownloadTesting(
      {required DoneCallback onDone,
      required ProgressCallback onProgress,
      required ErrorCallback onError,
      required CancelCallback onCancel,
      required int fileSize,
      required String testServer}) {
    throw UnimplementedError(
        'startDownloadTesting() has not been implemented.');
  }

  /// Starts an upload speed test.
  ///
  /// Parameters:
  /// - [onDone]: Callback when upload test completes
  /// - [onProgress]: Callback for progress updates
  /// - [onError]: Callback for error handling
  /// - [onCancel]: Callback when test is cancelled
  /// - [fileSize]: Size of file to upload for testing
  /// - [testServer]: URL of the test server
  ///
  /// Returns a [Future<CancelListening>] that provides a function to cancel the test.
  Future<CancelListening> startUploadTesting({
    required DoneCallback onDone,
    required ProgressCallback onProgress,
    required ErrorCallback onError,
    required CancelCallback onCancel,
    required int fileSize,
    required String testServer,
  }) {
    throw UnimplementedError('startUploadTesting() has not been implemented.');
  }

  /// Toggles logging on or off.
  ///
  /// Parameters:
  /// - [value]: Whether to enable or disable logging
  Future<void> toggleLog({
    required bool value,
  }) {
    throw UnimplementedError('toggleLog() has not been implemented.');
  }

  /// Gets the default server for speed testing.
  ///
  /// Returns a [Future<ServerSelectionResponse?>] containing server information.
  Future<ServerSelectionResponse?> getDefaultServer() {
    throw UnimplementedError('getDefaultServer() has not been implemented.');
  }

  /// Cancels the currently running test.
  ///
  /// Returns a [Future<bool>] that completes with `true` if the test
  /// was successfully cancelled, `false` otherwise.
  Future<bool> cancelTest() {
    throw UnimplementedError('cancelTest() has not been implemented.');
  }
}
