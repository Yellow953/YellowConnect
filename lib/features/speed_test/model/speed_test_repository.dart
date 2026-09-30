import 'dart:async';
import 'dart:isolate';

import '../../../core/result.dart';
import '../../ip_checker/model/ip_repository.dart';
import 'speed_test_engine.dart';
import 'speed_test_event.dart';

/// Runs [SpeedTestEngine] in a background isolate and streams its events.
/// The ISP lookup runs alongside so it doesn't add to the test's length.
class SpeedTestRepository {
  SpeedTestRepository(this._ipRepository);

  final IpRepository _ipRepository;
  StreamController<SpeedTestEvent>? _controller;
  ReceivePort? _port;
  Isolate? _isolate;

  /// Runs download then upload. The stream closes after a terminal event
  /// ([SpeedTestCompleted], [SpeedTestFailed] or [SpeedTestCancelled]).
  Stream<SpeedTestEvent> run() {
    _controller?.close();
    _stop();
    final controller = _controller = StreamController<SpeedTestEvent>();
    final port = _port = ReceivePort();

    void emit(SpeedTestEvent event) {
      if (controller.isClosed) return;
      controller.add(event);
      if (event is SpeedTestCompleted ||
          event is SpeedTestFailed ||
          event is SpeedTestCancelled) {
        if (_controller == controller) _stop();
        port.close();
        controller.close();
      }
    }

    // Anything but an event (an uncaught error, or the exit notice before a
    // result) means the isolate died.
    port.listen(
      (message) => emit(
        message is SpeedTestEvent
            ? message
            : SpeedTestFailed('Test isolate ended: $message'),
      ),
    );

    emit(const SpeedTestSelectingServer());
    Isolate.spawn(
      _runInIsolate,
      port.sendPort,
      onError: port.sendPort,
      onExit: port.sendPort,
      debugName: 'speed_test',
    ).then((isolate) {
      // Cancelled or restarted before the isolate came up.
      if (_port != port) return isolate.kill(priority: Isolate.immediate);
      _isolate = isolate;
    }, onError: (Object e) => emit(SpeedTestFailed('$e')));

    unawaited(
      _ipRepository.fetchPublicIp().then((result) {
        if (result case Ok(:final value)) {
          emit(SpeedTestServerSelected(ip: value.ip, isp: value.isp));
        }
      }),
    );

    return controller.stream;
  }

  Future<void> cancel() async {
    final controller = _controller;
    if (controller == null || controller.isClosed) return;
    _stop();
    controller
      ..add(const SpeedTestCancelled())
      ..close();
  }

  /// Kills the running test, if any. Its sockets close with the isolate.
  void _stop() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _port?.close();
    _port = null;
    _controller = null;
  }

  static Future<void> _runInIsolate(SendPort out) async {
    final result = await SpeedTestEngine.run(out.send);
    Isolate.exit(out, result);
  }
}
