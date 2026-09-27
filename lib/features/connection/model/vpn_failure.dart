/// [message] is shown to the user, so it stays plain. Technical details go in
/// [detail] for logs and debugging.
sealed class VpnFailure {
  const VpnFailure(this.message, [this.detail]);

  final String message;
  final String? detail;
}

final class VpnConfigMissing extends VpnFailure {
  const VpnConfigMissing()
    : super(
        'The VPN isn\'t set up in this version of the app yet.',
        'No config bundled. Add assets/vpn/wg0.conf and rebuild.',
      );
}

final class VpnConfigInvalid extends VpnFailure {
  const VpnConfigInvalid(String detail)
    : super('The VPN settings in this app aren\'t valid.', detail);
}

final class VpnPermissionDenied extends VpnFailure {
  const VpnPermissionDenied()
    : super('VPN permission was not granted. Allow it and try again.');
}

final class VpnPlatformError extends VpnFailure {
  const VpnPlatformError(String detail)
    : super('Couldn\'t connect. Check your internet and try again.', detail);
}
