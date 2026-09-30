import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/services/network_info_service.dart';
import '../model/speed_history_repository.dart';
import '../model/speed_test_event.dart';
import '../model/speed_test_repository.dart';
import '../model/speed_test_result.dart';

enum SpeedTestState {
  idle,
  selectingServer,
  testingDownload,
  testingUpload,
  done,
  error,
}

class SpeedTestPresenter extends ChangeNotifier {
  SpeedTestPresenter(
    this._repository,
    this._historyRepository,
    this._networkInfo,
  );

  final SpeedTestRepository _repository;
  final SpeedHistoryRepository _historyRepository;
  final NetworkInfoService _networkInfo;
  StreamSubscription<SpeedTestEvent>? _sub;

  SpeedTestState _state = SpeedTestState.idle;
  SpeedTestState get state => _state;

  bool get isRunning =>
      _state == SpeedTestState.selectingServer ||
      _state == SpeedTestState.testingDownload ||
      _state == SpeedTestState.testingUpload;

  /// Live speed of the current phase.
  double _currentMbps = 0;
  double get currentMbps => _currentMbps;

  /// 0-100 progress of the current phase.
  double _percent = 0;
  double get percent => _percent;

  double? _downloadMbps;
  double? get downloadMbps => _downloadMbps;

  double? _uploadMbps;
  double? get uploadMbps => _uploadMbps;

  NetworkType? _networkType;
  NetworkType? get networkType => _networkType;

  String? _isp;

  SpeedTestResult? _result;
  SpeedTestResult? get result => _result;

  /// Saved results, newest first.
  List<SpeedTestResult> _history = [];
  List<SpeedTestResult> get history => List.unmodifiable(_history);

  /// Latest finished result, shown again if a new test is stopped, until
  /// [clear] is called.
  SpeedTestResult? _lastResult;
  SpeedTestResult? get lastResult => _lastResult;

  String? _error;
  String? get error => _error;

  Future<void> init() async {
    _history = await _historyRepository.load();
    notifyListeners();
  }

  Future<void> start() async {
    if (isRunning) return;
    _reset();
    _state = SpeedTestState.selectingServer;
    notifyListeners();

    await _sub?.cancel();
    _sub = _repository.run().listen(_onEvent);
    // Only needed for the saved result, well before the test ends.
    _networkType = await _networkInfo.currentType();
  }

  Future<void> cancel() async {
    if (!isRunning) return;
    await _repository.cancel();
  }

  /// Clears the result on screen, back to the start button. History stays.
  void clear() {
    if (isRunning) return;
    _reset();
    _lastResult = null;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _historyRepository.clear();
  }

  void _onEvent(SpeedTestEvent event) {
    switch (event) {
      case SpeedTestSelectingServer():
        _state = SpeedTestState.selectingServer;
      case SpeedTestServerSelected(:final isp):
        _isp = isp;
      case SpeedTestProgress(:final phase, :final percent, :final mbps):
        _state = phase == SpeedTestPhase.download
            ? SpeedTestState.testingDownload
            : SpeedTestState.testingUpload;
        _percent = percent;
        _currentMbps = mbps;
      case SpeedTestPhaseDone(:final phase, :final mbps):
        if (phase == SpeedTestPhase.download) {
          _downloadMbps = mbps;
        } else {
          _uploadMbps = mbps;
        }
        _percent = 0;
        _currentMbps = 0;
      case SpeedTestCompleted(:final downloadMbps, :final uploadMbps):
        _downloadMbps = downloadMbps;
        _uploadMbps = uploadMbps;
        _result = SpeedTestResult(
          downloadMbps: downloadMbps,
          uploadMbps: uploadMbps,
          networkType: _networkType ?? NetworkType.other,
          testedAt: DateTime.now(),
          isp: _isp,
        );
        _lastResult = _result;
        _history = [
          _result!,
          ..._history,
        ].take(_historyRepository.maxEntries).toList();
        unawaited(_historyRepository.save(_history));
        _state = SpeedTestState.done;
      case SpeedTestFailed(:final message):
        debugPrint('Speed test failed: $message');
        _error = 'Check your connection and try again.';
        _state = SpeedTestState.error;
      case SpeedTestCancelled():
        _reset();
    }
    notifyListeners();
  }

  void _reset() {
    _state = SpeedTestState.idle;
    _currentMbps = 0;
    _percent = 0;
    _downloadMbps = null;
    _uploadMbps = null;
    _result = null;
    _error = null;
    _isp = null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    _repository.cancel();
    super.dispose();
  }
}
