enum SpeedTestPhase { download, upload }

sealed class SpeedTestEvent {
  const SpeedTestEvent();
}

final class SpeedTestSelectingServer extends SpeedTestEvent {
  const SpeedTestSelectingServer();
}

final class SpeedTestServerSelected extends SpeedTestEvent {
  const SpeedTestServerSelected({this.ip, this.isp});

  final String? ip;
  final String? isp;
}

final class SpeedTestProgress extends SpeedTestEvent {
  const SpeedTestProgress(this.phase, this.percent, this.mbps);

  final SpeedTestPhase phase;
  final double percent;
  final double mbps;
}

final class SpeedTestPhaseDone extends SpeedTestEvent {
  const SpeedTestPhaseDone(this.phase, this.mbps);

  final SpeedTestPhase phase;
  final double mbps;
}

final class SpeedTestCompleted extends SpeedTestEvent {
  const SpeedTestCompleted(this.downloadMbps, this.uploadMbps);

  final double downloadMbps;
  final double uploadMbps;
}

final class SpeedTestFailed extends SpeedTestEvent {
  const SpeedTestFailed(this.message);

  final String message;
}

final class SpeedTestCancelled extends SpeedTestEvent {
  const SpeedTestCancelled();
}
