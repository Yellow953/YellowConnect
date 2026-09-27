abstract final class AppConstants {
  static const appVersion = '1.0.0';
  static const publisher = 'YellowTech';

  /// Tunnel name. Android requires 1-15 chars of [a-zA-Z0-9_=+.-].
  static const vpnTunnelName = 'YellowConnect';

  /// Bundle ID of the iOS Packet Tunnel Network Extension target.
  static const iosTunnelBundleId = 'com.yellowtech.yellowconnect.WGExtension';

  /// Bundled WireGuard client config (gitignored; see wg0.conf.example).
  static const vpnConfigAsset = 'assets/vpn/wg0.conf';

  /// IP plus location and ISP. Free, no key.
  static final ipDetailsUrl = Uri.parse('https://ipwho.is/');

  /// Plain IP fallback when the details lookup fails.
  static final ipFallbackUrl = Uri.parse('https://api.ipify.org?format=json');
}
