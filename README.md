# Yellow Connect

Cross-platform (Android + iOS) network-utilities app built in Flutter:

- **VPN** — WireGuard client connecting to a self-hosted server
- **Speed Test** — download/upload, Wi-Fi vs. mobile
- **IP Checker** — current public IP

See [CLAUDE.md](CLAUDE.md) for architecture, stack, and build plan.

## Project layout

```
lib/
  main.dart            entry point
  app/                 MaterialApp, theme, top-level wiring
  core/                shared utilities
  features/<name>/     one folder per tool, each with model/ presenter/ view/
assets/vpn/            WireGuard client config (wg0.conf, gitignored)
```

Presenters and repositories are built once in `lib/app/dependencies.dart` and
passed into views through constructors.

## Development

```sh
flutter pub get
flutter analyze
flutter run
```

## VPN config

The app loads a WireGuard client config from `assets/vpn/wg0.conf`. That file
holds a private key, so it is gitignored. Copy `assets/vpn/wg0.conf.example`
to `wg0.conf`, fill in the values from the server, then rebuild.

## iOS: Packet Tunnel extension (one-time, in Xcode)

The iOS VPN runs inside a Network Extension target that has to be added in
Xcode.

1. Open `ios/Runner.xcworkspace`.
2. File → New → Target → **Network Extension**. Name it `WGExtension`, set the
   bundle ID to `com.yellowtech.yellowconnect.WGExtension` (must match
   `AppConstants.iosTunnelBundleId`), and set the deployment target to iOS 15.
3. Add the **Network Extensions → Packet Tunnel** capability, plus a shared
   **App Groups** entry, to both the Runner and WGExtension targets.
4. Add the `WireGuardKit` Swift package
   (`https://git.wireguard.com/wireguard-apple`) to the WGExtension target.
5. Make `PacketTunnelProvider` read `wgQuickConfig` from
   `protocolConfiguration.providerConfiguration` and start a `WireGuardAdapter`
   with it.

This needs a paid Apple Developer account to run on a real device.
