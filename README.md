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

The config is packed into the APK as a plain asset, so anyone holding the APK
can read the key. Don't share builds; if one leaks, remove that peer on the
server and issue a new config.

## Android release signing

Release builds are signed with the key described in `android/key.properties`
(gitignored, like the keystore itself). Without that file they fall back to
the debug key, which is fine for `flutter run --release` but must never be
distributed. To create the key once:

```sh
keytool -genkey -v -keystore ~/yellowconnect-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then create `android/key.properties`:

```properties
storeFile=/Users/<you>/yellowconnect-upload.jks
storePassword=<store password>
keyAlias=upload
keyPassword=<key password>
```

Back up the keystore and passwords somewhere safe: losing them means you can't
publish updates under the same signature.

## iOS: Packet Tunnel extension

The iOS VPN runs inside the `WGExtension` Network Extension target
(`ios/WGExtension/`, bundle ID `com.yellowtech.yellowconnect.WGExtension`,
matching `AppConstants.iosTunnelBundleId`). `PacketTunnelProvider` reads the
`wgQuickConfig` string the plugin passes in `providerConfiguration`, parses it
with `WgQuickParser`, and starts a `WireGuardAdapter`.

- WireGuardKit is vendored in `ios/Packages/WireGuardKit` (see its README for
  local changes).
- The target's "Build wireguard-go" phase compiles `libwg-go.a`, so building
  for iOS needs Go installed: `brew install go`.
- Runner and WGExtension both carry the Packet Tunnel entitlement. Signing it
  needs a paid Apple Developer account; pick the team for both targets under
  Signing & Capabilities in Xcode before running on a device.
- The tunnel can't actually connect in the Simulator; test on a real iPhone.
