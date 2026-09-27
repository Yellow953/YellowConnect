/// Enumeration representing the type of speed test.
enum TestType {
  /// Download speed test.
  download,

  /// Upload speed test.
  upload,
}

/// Enumeration for callback types used in speed testing.
enum CallbacksEnum {
  /// Start download testing callback.
  startDownLoadTesting,

  /// Start upload testing callback.
  startUploadTesting,
}

/// Enumeration for listener event types.
enum ListenerEnum {
  /// Test completed successfully.
  complete,

  /// Test encountered an error.
  error,

  /// Test progress update.
  progress,

  /// Test was cancelled.
  cancel,
}

/// Enumeration for speed units of measurement.
enum SpeedUnit {
  /// Kilobits per second.
  kbps,

  /// Megabits per second.
  mbps,
}
