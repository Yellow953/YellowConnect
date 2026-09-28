/// Something the app was opened to do, e.g. from a home screen widget.
enum LaunchAction {
  connectVpn('vpn-connect'),
  startSpeedTest('speed-test');

  const LaunchAction(this.path);

  /// Last segment of the `yellowconnect://widget/<path>` deep link.
  final String path;

  static LaunchAction? fromUri(String? uri) {
    final parsed = uri == null ? null : Uri.tryParse(uri);
    if (parsed == null || parsed.scheme != 'yellowconnect') return null;
    final segment = parsed.pathSegments.lastOrNull;
    for (final action in values) {
      if (action.path == segment) return action;
    }
    return null;
  }
}
