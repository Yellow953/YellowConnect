/// A Flutter plugin to test internet download and upload speed.
///
/// This package provides functionality to measure internet connection speeds
/// including download and upload speeds. It supports both Android and iOS platforms.
///
/// ## Features
/// - Download speed testing
/// - Upload speed testing
/// - Real-time progress tracking
/// - Customizable test servers
/// - Support for multiple speed units (Kbps, Mbps)
///
/// ## Usage
/// ```dart
/// import 'package:flutter_internet_speed_test_pro/flutter_internet_speed_test_pro.dart';
///
/// final speedTest = FlutterInternetSpeedTest();
/// speedTest.startTesting(
///   onCompleted: (TestResult download, TestResult upload) {
///     print('Download: ${download.transferRate} ${download.unit}');
///     print('Upload: ${upload.transferRate} ${upload.unit}');
///   },
/// );
/// ```
library flutter_internet_speed_test_pro;

export './src/flutter_internet_speed_test.dart'
    show FlutterInternetSpeedTest, ResultCallback, TestProgressCallback;
export './src/callbacks_enum.dart';
export './src/flutter_internet_speed_test_platform_interface.dart'
    show ErrorCallback;
export './src/models/server_selection_response.dart' show Client;
export './src/test_result.dart' show TestResult;
