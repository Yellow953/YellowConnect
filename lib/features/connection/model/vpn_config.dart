/// A WireGuard client config in wg-quick format.
class VpnConfig {
  const VpnConfig({
    required this.serverAddress,
    required this.wgQuickConfig,
    this.tunnelAddress,
    this.dns,
  });

  /// Parses [raw] wg-quick text, pulling the server from the `Endpoint` line.
  ///
  /// Throws [FormatException] if there is no `Endpoint`.
  factory VpnConfig.parse(String raw) {
    final endpoint = _value(raw, 'Endpoint');
    if (endpoint == null) {
      throw const FormatException('Config has no [Peer] Endpoint line.');
    }
    return VpnConfig(
      serverAddress: endpoint,
      wgQuickConfig: raw,
      tunnelAddress: _value(raw, 'Address'),
      dns: _value(raw, 'DNS'),
    );
  }

  /// `host:port` of the WireGuard server.
  final String serverAddress;
  final String wgQuickConfig;

  /// This device's address inside the tunnel, e.g. `10.8.0.2/32`.
  final String? tunnelAddress;
  final String? dns;

  String get serverHost {
    final i = serverAddress.lastIndexOf(':');
    return i > 0 ? serverAddress.substring(0, i) : serverAddress;
  }

  String? get serverPort {
    final i = serverAddress.lastIndexOf(':');
    return i > 0 ? serverAddress.substring(i + 1) : null;
  }

  static String? _value(String raw, String key) => RegExp(
    '^\\s*$key\\s*=\\s*(.+?)\\s*\$',
    multiLine: true,
  ).firstMatch(raw)?.group(1);
}
