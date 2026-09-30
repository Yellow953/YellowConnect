import Foundation
import WireGuardKit

enum WgQuickError: Error {
    case missingConfig
    case missingInterface
    case invalidValue(key: String, value: String)
    case missingKey(String)
}

/// Minimal wg-quick parser covering the keys our server issues:
/// [Interface] PrivateKey, Address, DNS, MTU, ListenPort and
/// [Peer] PublicKey, PresharedKey, AllowedIPs, Endpoint, PersistentKeepalive.
/// Unknown keys are ignored.
enum WgQuickParser {
    static func parse(_ raw: String) throws -> TunnelConfiguration {
        var sections: [(name: String, values: [String: String])] = []

        for rawLine in raw.split(whereSeparator: \.isNewline) {
            let line = rawLine.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)[0]
                .trimmingCharacters(in: .whitespaces)
            if line.isEmpty { continue }
            if line.hasPrefix("[") && line.hasSuffix("]") {
                sections.append((line.dropFirst().dropLast().lowercased(), [:]))
                continue
            }
            guard let eq = line.firstIndex(of: "="), !sections.isEmpty else { continue }
            let key = line[..<eq].trimmingCharacters(in: .whitespaces).lowercased()
            let value = line[line.index(after: eq)...].trimmingCharacters(in: .whitespaces)
            sections[sections.count - 1].values[key] = value
        }

        guard let iface = sections.first(where: { $0.name == "interface" })?.values else {
            throw WgQuickError.missingInterface
        }
        let peers = try sections.filter { $0.name == "peer" }.map { try peer($0.values) }
        return TunnelConfiguration(name: nil, interface: try interface(iface), peers: peers)
    }

    private static func interface(_ v: [String: String]) throws -> InterfaceConfiguration {
        let key = try required(v, "privatekey")
        guard let privateKey = PrivateKey(base64Key: key) else {
            throw WgQuickError.invalidValue(key: "PrivateKey", value: "<hidden>")
        }
        var config = InterfaceConfiguration(privateKey: privateKey)
        config.addresses = try list(v["address"]).map {
            guard let range = IPAddressRange(from: $0) else {
                throw WgQuickError.invalidValue(key: "Address", value: $0)
            }
            return range
        }
        for entry in list(v["dns"]) {
            if let server = DNSServer(from: entry) {
                config.dns.append(server)
            } else {
                config.dnsSearch.append(entry)
            }
        }
        if let mtu = v["mtu"] {
            guard let value = UInt16(mtu) else { throw WgQuickError.invalidValue(key: "MTU", value: mtu) }
            config.mtu = value
        }
        if let port = v["listenport"] {
            guard let value = UInt16(port) else { throw WgQuickError.invalidValue(key: "ListenPort", value: port) }
            config.listenPort = value
        }
        return config
    }

    private static func peer(_ v: [String: String]) throws -> PeerConfiguration {
        let key = try required(v, "publickey")
        guard let publicKey = PublicKey(base64Key: key) else {
            throw WgQuickError.invalidValue(key: "PublicKey", value: key)
        }
        var config = PeerConfiguration(publicKey: publicKey)
        if let psk = v["presharedkey"] {
            guard let value = PreSharedKey(base64Key: psk) else {
                throw WgQuickError.invalidValue(key: "PresharedKey", value: "<hidden>")
            }
            config.preSharedKey = value
        }
        config.allowedIPs = try list(v["allowedips"]).map {
            guard let range = IPAddressRange(from: $0) else {
                throw WgQuickError.invalidValue(key: "AllowedIPs", value: $0)
            }
            return range
        }
        if let endpoint = v["endpoint"] {
            guard let value = Endpoint(from: endpoint) else {
                throw WgQuickError.invalidValue(key: "Endpoint", value: endpoint)
            }
            config.endpoint = value
        }
        if let keepalive = v["persistentkeepalive"] {
            guard let value = UInt16(keepalive) else {
                throw WgQuickError.invalidValue(key: "PersistentKeepalive", value: keepalive)
            }
            config.persistentKeepAlive = value
        }
        return config
    }

    private static func required(_ v: [String: String], _ key: String) throws -> String {
        guard let value = v[key], !value.isEmpty else { throw WgQuickError.missingKey(key) }
        return value
    }

    private static func list(_ value: String?) -> [String] {
        (value ?? "").split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
