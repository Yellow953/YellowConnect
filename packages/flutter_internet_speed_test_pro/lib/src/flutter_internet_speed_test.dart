import 'package:flutter_internet_speed_test_pro/src/speed_test_utils.dart';
import 'package:flutter_internet_speed_test_pro/src/test_result.dart';

import 'callbacks_enum.dart';
import 'flutter_internet_speed_test_platform_interface.dart';
import 'models/server_selection_response.dart';

/// Callback function type for default operations.
typedef DefaultCallback = void Function();

/// Callback function type for test completion with download and upload results.
typedef ResultCallback = void Function(TestResult download, TestResult upload);

/// Callback function type for test progress updates.
typedef TestProgressCallback = void Function(double percent, TestResult data);

/// Callback function type for individual test completion.
typedef ResultCompletionCallback = void Function(TestResult data);

/// Callback function type for server selection completion.
typedef DefaultServerSelectionCallback = void Function(Client? client);

/// A singleton class that provides internet speed testing functionality.
///
/// This class manages both download and upload speed tests, providing
/// real-time progress updates and completion callbacks.
class FlutterInternetSpeedTest {
  static const _defaultDownloadTestServer =
      'http://speedtest.ftp.otenet.gr/files/test10Mb.db';
  static const _defaultUploadTestServer = 'http://speedtest.ftp.otenet.gr/';
  static const _defaultFileSize = 10 * 1024 * 1024; //10 MB

  static final FlutterInternetSpeedTest _instance =
      FlutterInternetSpeedTest._private();

  bool _isTestInProgress = false;
  bool _isCancelled = false;

  /// Factory constructor that returns the singleton instance.
  factory FlutterInternetSpeedTest() => _instance;

  FlutterInternetSpeedTest._private();

  /// Checks if a speed test is currently in progress.
  ///
  /// Returns `true` if a test is running, `false` otherwise.
  bool isTestInProgress() => _isTestInProgress;

  /// Starts the internet speed testing process.
  ///
  /// This method performs both download and upload speed tests sequentially.
  /// The test will automatically select servers if not provided and useFastApi is true.
  ///
  /// Parameters:
  /// - [onCompleted]: Required callback when both tests complete
  /// - [onStarted]: Optional callback when testing begins
  /// - [onDownloadComplete]: Optional callback when download test completes
  /// - [onUploadComplete]: Optional callback when upload test completes
  /// - [onProgress]: Optional callback for progress updates
  /// - [onDefaultServerSelectionInProgress]: Optional callback during server selection
  /// - [onDefaultServerSelectionDone]: Optional callback when server selection completes
  /// - [onError]: Optional callback for error handling
  /// - [onCancel]: Optional callback when test is cancelled
  /// - [downloadTestServer]: Optional custom download server URL
  /// - [uploadTestServer]: Optional custom upload server URL
  /// - [fileSizeInBytes]: File size for testing (default: 10MB)
  /// - [useFastApi]: Whether to use Fast.com API for server selection (default: true)
  Future<void> startTesting({
    required ResultCallback onCompleted,
    DefaultCallback? onStarted,
    ResultCompletionCallback? onDownloadComplete,
    ResultCompletionCallback? onUploadComplete,
    TestProgressCallback? onProgress,
    DefaultCallback? onDefaultServerSelectionInProgress,
    DefaultServerSelectionCallback? onDefaultServerSelectionDone,
    ErrorCallback? onError,
    CancelCallback? onCancel,
    String? downloadTestServer,
    String? uploadTestServer,
    int fileSizeInBytes = _defaultFileSize,
    bool useFastApi = true,
  }) async {
    if (_isTestInProgress) {
      return;
    }
    if (await isInternetAvailable() == false) {
      if (onError != null) {
        onError('No internet connection', 'No internet connection');
      }
      return;
    }

    if (fileSizeInBytes < _defaultFileSize) {
      fileSizeInBytes = _defaultFileSize;
    }
    _isTestInProgress = true;

    if (onStarted != null) onStarted();

    if ((downloadTestServer == null || uploadTestServer == null) &&
        useFastApi) {
      if (onDefaultServerSelectionInProgress != null) {
        onDefaultServerSelectionInProgress();
      }
      final serverSelectionResponse =
          await FlutterInternetSpeedTestPlatform.instance.getDefaultServer();

      if (onDefaultServerSelectionDone != null) {
        onDefaultServerSelectionDone(serverSelectionResponse?.client);
      }
      String? url = serverSelectionResponse?.targets?.first.url;
      if (url != null) {
        downloadTestServer = downloadTestServer ?? url;
        uploadTestServer = uploadTestServer ?? url;
      }
    }
    if (downloadTestServer == null || uploadTestServer == null) {
      downloadTestServer = downloadTestServer ?? _defaultDownloadTestServer;
      uploadTestServer = uploadTestServer ?? _defaultUploadTestServer;
    }

    if (_isCancelled) {
      if (onCancel != null) {
        onCancel();
        _isTestInProgress = false;
        _isCancelled = false;
        return;
      }
    }

    final startDownloadTimeStamp = DateTime.now().millisecondsSinceEpoch;
    FlutterInternetSpeedTestPlatform.instance.startDownloadTesting(
      onDone: (double transferRate, SpeedUnit unit) {
        final downloadDuration =
            DateTime.now().millisecondsSinceEpoch - startDownloadTimeStamp;
        final downloadResult = TestResult(TestType.download, transferRate, unit,
            durationInMillis: downloadDuration);

        if (onProgress != null) onProgress(100, downloadResult);
        if (onDownloadComplete != null) onDownloadComplete(downloadResult);

        final startUploadTimeStamp = DateTime.now().millisecondsSinceEpoch;
        FlutterInternetSpeedTestPlatform.instance.startUploadTesting(
          onDone: (double transferRate, SpeedUnit unit) {
            final uploadDuration =
                DateTime.now().millisecondsSinceEpoch - startUploadTimeStamp;
            final uploadResult = TestResult(TestType.upload, transferRate, unit,
                durationInMillis: uploadDuration);

            if (onProgress != null) onProgress(100, uploadResult);
            if (onUploadComplete != null) onUploadComplete(uploadResult);

            onCompleted(downloadResult, uploadResult);
            _isTestInProgress = false;
            _isCancelled = false;
          },
          onProgress: (double percent, double transferRate, SpeedUnit unit) {
            final uploadProgressResult =
                TestResult(TestType.upload, transferRate, unit);
            if (onProgress != null) {
              onProgress(percent, uploadProgressResult);
            }
          },
          onError: (String errorMessage, String speedTestError) {
            if (onError != null) onError(errorMessage, speedTestError);
            _isTestInProgress = false;
            _isCancelled = false;
          },
          onCancel: () {
            if (onCancel != null) onCancel();
            _isTestInProgress = false;
            _isCancelled = false;
          },
          fileSize: fileSizeInBytes,
          testServer: uploadTestServer!,
        );
      },
      onProgress: (double percent, double transferRate, SpeedUnit unit) {
        final downloadProgressResult =
            TestResult(TestType.download, transferRate, unit);
        if (onProgress != null) onProgress(percent, downloadProgressResult);
      },
      onError: (String errorMessage, String speedTestError) {
        if (onError != null) onError(errorMessage, speedTestError);
        _isTestInProgress = false;
        _isCancelled = false;
      },
      onCancel: () {
        if (onCancel != null) onCancel();
        _isTestInProgress = false;
        _isCancelled = false;
      },
      fileSize: fileSizeInBytes,
      testServer: downloadTestServer,
    );
  }

  /// Enables logging for debugging purposes.
  ///
  /// When enabled, detailed logs will be printed to the console
  /// showing the progress and results of speed tests.
  void enableLog() {
    FlutterInternetSpeedTestPlatform.instance.toggleLog(value: true);
  }

  /// Disables logging.
  ///
  /// When disabled, no debug logs will be printed to the console.
  void disableLog() {
    FlutterInternetSpeedTestPlatform.instance.toggleLog(value: false);
  }

  /// Cancels the currently running speed test.
  ///
  /// Returns a [Future<bool>] that completes with `true` if the test
  /// was successfully cancelled, `false` otherwise.
  Future<bool> cancelTest() async {
    _isCancelled = true;
    return await FlutterInternetSpeedTestPlatform.instance.cancelTest();
  }

  /// Gets whether logging is currently enabled.
  ///
  /// Returns `true` if logging is enabled, `false` otherwise.
  bool get isLogEnabled => FlutterInternetSpeedTestPlatform.instance.logEnabled;
}
