import NetworkExtension
import WireGuardKit
import os.log

/// Runs the WireGuard tunnel. The app hands over the wg-quick config text via
/// `providerConfiguration["wgQuickConfig"]` (see wireguard_flutter's VPNUtils).
class PacketTunnelProvider: NEPacketTunnelProvider {
    private lazy var adapter = WireGuardAdapter(with: self) { _, message in
        os_log("%{public}s", log: .default, type: .debug, message)
    }

    override func startTunnel(
        options: [String: NSObject]?,
        completionHandler: @escaping (Error?) -> Void
    ) {
        guard
            let proto = protocolConfiguration as? NETunnelProviderProtocol,
            let raw = proto.providerConfiguration?["wgQuickConfig"] as? String
        else {
            completionHandler(WgQuickError.missingConfig)
            return
        }

        let config: TunnelConfiguration
        do {
            config = try WgQuickParser.parse(raw)
        } catch {
            os_log("Invalid wg-quick config: %{public}s", log: .default, type: .error, "\(error)")
            completionHandler(error)
            return
        }

        adapter.start(tunnelConfiguration: config) { error in
            if let error {
                os_log("Tunnel failed to start: %{public}s", log: .default, type: .error, "\(error)")
            }
            completionHandler(error)
        }
    }

    override func stopTunnel(
        with reason: NEProviderStopReason,
        completionHandler: @escaping () -> Void
    ) {
        adapter.stop { _ in completionHandler() }
    }
}
