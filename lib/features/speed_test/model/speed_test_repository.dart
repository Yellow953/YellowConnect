import 'dart:async';

import 'package:flutter_internet_speed_test_pro/flutter_internet_speed_test_pro.dart';

import 'speed_test_event.dart';

/// Wraps flutter_internet_speed_test_pro's callback API as a stream.
class SpeedTestRepository {
  SpeedTestRepository([FlutterInternetSpeedTest? speedTest])
    : _speedTest = speedTest ?? FlutterInternetSpeedTest();

  final FlutterInternetSpeedTest _speedTest;
  StreamController<SpeedTestEvent>? _controller;

  bool get isRunning => _speedTest.isTestInProgress();

  /// Runs download then upload. The stream closes after a terminal event
  /// ([SpeedTestCompleted], [SpeedTestFailed] or [SpeedTestCancelled]).
  Stream<SpeedTestEvent> run() {
    _controller?.close();
    final controller = _controller = StreamController<SpeedTestEvent>();

    void emit(SpeedTestEvent event) {
      if (controller.isClosed) return;
      controller.add(event);
      if (event is SpeedTestCompleted ||
          event is SpeedTestFailed ||
          event is SpeedTestCancelled) {
        controller.close();
      }
    }

    _speedTest.startTesting(
      onDefaultServerSelectionInProgress: () =>
          emit(const SpeedTestSelectingServer()),
      onDefaultServerSelectionDone: (client) =>
          emit(SpeedTestServerSelected(ip: client?.ip, isp: client?.isp)),
      onProgress: (percent, data) =>
          emit(SpeedTestProgress(_phase(data), percent, _toMbps(data))),
      onDownloadComplete: (data) =>
          emit(SpeedTestPhaseDone(SpeedTestPhase.download, _toMbps(data))),
      onUploadComplete: (data) =>
          emit(SpeedTestPhaseDone(SpeedTestPhase.upload, _toMbps(data))),
      onCompleted: (download, upload) =>
          emit(SpeedTestCompleted(_toMbps(download), _toMbps(upload))),
      onError: (message, _) => emit(SpeedTestFailed(message)),
      onCancel: () => emit(const SpeedTestCancelled()),
    );

    return controller.stream;
  }

  Future<void> cancel() => _speedTest.cancelTest();

  static SpeedTestPhase _phase(TestResult r) => r.type == TestType.download
      ? SpeedTestPhase.download
      : SpeedTestPhase.upload;

  static double _toMbps(TestResult r) =>
      r.unit == SpeedUnit.kbps ? r.transferRate / 1000 : r.transferRate;
}
