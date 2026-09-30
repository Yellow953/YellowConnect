import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'speed_test_event.dart';

/// Download then upload test against Cloudflare's speed endpoints. Each
/// phase stops at [phaseLength] or once its data budget is used, whichever
/// comes first, so slow lines never run long and fast lines never burn
/// hundreds of MB. Parallel connections keep the pipe full, and whatever is
/// still in flight when a phase stops is dropped.
///
/// Meant to run in a background isolate (see `SpeedTestRepository`) so counting
/// hundreds of MB/s of traffic never costs the UI a frame.
abstract final class SpeedTestEngine {
  static const phaseLength = Duration(seconds: 8);

  /// Slow start ramps up over the first second or so; leave it out of the
  /// final figure.
  static const _warmUp = Duration(seconds: 1);

  /// Parallel connections. Slow lines start (and stay) on a couple: more
  /// flood the ISP's queue, which then takes seconds to drain and stalls the
  /// upload phase. Fast lines need more to fill the pipe.
  static const _startConnections = 2;
  static const _fastConnections = 4;
  static const _fastMbps = 25.0;
  static const _tick = Duration(milliseconds: 250);

  /// Max data per phase. Past ~200 Mbps (download) / ~80 Mbps (upload) a
  /// phase ends early on this instead of the clock.
  static const _budget = {
    SpeedTestPhase.download: 20 * 1000 * 1000,
    SpeedTestPhase.upload: 8 * 1000 * 1000,
  };

  /// Per request; connections that finish early start another. Cloudflare
  /// rate-limits large downloads (10 MB and up) after a few tests. Uploads
  /// stay small so each response drains the OS send buffer, which would
  /// otherwise count as sent before it is.
  static const _downloadBytes = 4 * 1000 * 1000;
  static const _uploadBytes = 1000 * 1000;
  static final _downloadUrl = Uri.parse(
    'https://speed.cloudflare.com/__down?bytes=$_downloadBytes',
  );
  static final _uploadUrl = Uri.parse('https://speed.cloudflare.com/__up');
  static final _uploadChunk = Uint8List(64 * 1024);

  static Future<SpeedTestEvent> run(void Function(SpeedTestEvent) emit) async {
    try {
      final download = await _measure(SpeedTestPhase.download, emit);
      emit(SpeedTestPhaseDone(SpeedTestPhase.download, download));
      final upload = await _measure(SpeedTestPhase.upload, emit);
      emit(SpeedTestPhaseDone(SpeedTestPhase.upload, upload));
      return SpeedTestCompleted(download, upload);
    } catch (e) {
      return SpeedTestFailed('$e');
    }
  }

  static Future<double> _measure(
    SpeedTestPhase phase,
    void Function(SpeedTestEvent) emit,
  ) async {
    final clock = Stopwatch()..start();
    // Ends the phase before the deadline: budget used, or server refused.
    final stopEarly = Completer<void>();
    void stop() => stopEarly.isCompleted ? null : stopEarly.complete();
    final meter = _Meter(clock, _budget[phase]!, stop);
    // No connect timeout of its own: on a slow line the previous phase can
    // leave the link clogged for seconds, and the phase deadline caps it
    // anyway.
    final client = HttpClient();
    var stopped = false;
    Object? error;

    // Loops requests, retrying failures, until the phase stops. The phase
    // only fails if nothing at all came through by then.
    Future<void> connection() async {
      while (!stopped) {
        try {
          await (phase == SpeedTestPhase.download
              ? _download(client, meter)
              : _upload(client, meter));
        } on _Rejected catch (e) {
          // The server said no (e.g. 429); retrying only makes it worse.
          error = e;
          stop();
          return;
        } catch (e) {
          if (stopped) return;
          error = e;
          await Future<void>.delayed(const Duration(milliseconds: 300));
        }
      }
    }

    var connections = _startConnections;
    for (var i = 0; i < connections; i++) {
      unawaited(connection());
    }

    final ticker = Timer.periodic(_tick, (_) {
      if (connections < _fastConnections && meter.mbps > _fastMbps) {
        for (; connections < _fastConnections; connections++) {
          unawaited(connection());
        }
      }
      final percent =
          clock.elapsedMicroseconds / phaseLength.inMicroseconds * 100;
      emit(SpeedTestProgress(phase, percent.clamp(0, 100), meter.mbps));
    });
    try {
      await Future.any([Future<void>.delayed(phaseLength), stopEarly.future]);
    } finally {
      stopped = true;
      ticker.cancel();
      // Aborts whatever is still in flight.
      client.close(force: true);
    }

    if (!meter.hasData) throw error ?? const SocketException('No data');
    final mbps = meter.mbps;
    emit(SpeedTestProgress(phase, 100, mbps));
    return mbps;
  }

  static Future<void> _download(HttpClient client, _Meter meter) async {
    final response = await (await client.getUrl(_downloadUrl)).close();
    _check(response);
    await for (final chunk in response) {
      meter.add(chunk.length);
    }
  }

  /// Zero bytes, counted as the socket takes them: `flush` waits for each
  /// chunk to be handed to the OS (`addStream` doesn't, and would count
  /// buffered bytes as sent). The OS send buffer still fills up front, which
  /// the warm-up window leaves out.
  static Future<void> _upload(HttpClient client, _Meter meter) async {
    final request = await client.postUrl(_uploadUrl)
      ..contentLength = _uploadBytes
      ..headers.contentType = ContentType.binary;
    for (var sent = 0; sent < _uploadBytes; sent += _uploadChunk.length) {
      final size = (_uploadBytes - sent).clamp(0, _uploadChunk.length);
      request.add(
        size == _uploadChunk.length
            ? _uploadChunk
            : Uint8List.sublistView(_uploadChunk, 0, size),
      );
      await request.flush();
      meter.add(size);
    }
    final response = await request.close();
    _check(response);
    await response.drain<void>();
  }

  static void _check(HttpClientResponse response) {
    if (response.statusCode != HttpStatus.ok) {
      throw _Rejected(response.statusCode);
    }
  }
}

class _Rejected implements Exception {
  const _Rejected(this.status);

  final int status;

  @override
  String toString() => 'Server rejected the test (HTTP $status)';
}

/// Byte counter that reports throughput after the warm-up, or since the
/// first byte until enough time has passed after warm-up to be stable.
class _Meter {
  _Meter(this._clock, this._budget, this._onBudgetUsed);

  final Stopwatch _clock;
  final int _budget;
  final void Function() _onBudgetUsed;
  int _bytes = 0;
  Duration? _firstByteAt;
  Duration? _warmAt;
  int _warmBytes = 0;

  bool get hasData => _bytes > 0;

  void add(int bytes) {
    final now = _clock.elapsed;
    final first = _firstByteAt ??= now;
    if (_warmAt == null && now - first >= SpeedTestEngine._warmUp) {
      _warmAt = now;
      _warmBytes = _bytes;
    }
    final before = _bytes;
    _bytes += bytes;
    if (before < _budget && _bytes >= _budget) _onBudgetUsed();
  }

  double get mbps {
    final now = _clock.elapsed;
    final first = _firstByteAt;
    if (first == null) return 0;
    final warm = _warmAt;
    final (from, base) = warm != null && now - warm >= SpeedTestEngine._warmUp
        ? (warm, _warmBytes)
        : (first, 0);
    final seconds =
        (now - from).inMicroseconds / Duration.microsecondsPerSecond;
    return seconds <= 0 ? 0 : (_bytes - base) * 8 / seconds / 1e6;
  }
}
