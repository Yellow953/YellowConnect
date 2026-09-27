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
```

## Development

```sh
flutter pub get
flutter analyze
flutter run
```
