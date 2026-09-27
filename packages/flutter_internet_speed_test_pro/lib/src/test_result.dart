import 'package:flutter_internet_speed_test_pro/src/callbacks_enum.dart';

/// Represents the result of a speed test operation.
///
/// This class contains information about the test type, transfer rate,
/// speed unit, and duration of the test.
class TestResult {
  /// The type of test that was performed (download or upload).
  final TestType type;

  /// The transfer rate achieved during the test.
  final double transferRate;

  /// The unit of measurement for the transfer rate (Kbps or Mbps).
  final SpeedUnit unit;

  /// The duration in milliseconds it took to complete the test.
  final int durationInMillis;

  /// Creates a new [TestResult] instance.
  ///
  /// Parameters:
  /// - [type]: The type of test performed
  /// - [transferRate]: The achieved transfer rate
  /// - [unit]: The unit of measurement
  /// - [durationInMillis]: Optional duration in milliseconds (defaults to 0)
  TestResult(this.type, this.transferRate, this.unit,
      {int durationInMillis = 0})
      : durationInMillis = durationInMillis - (durationInMillis % 1000);
}
