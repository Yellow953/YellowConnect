# Yellow Connect

## Overview

Yellow Connect is a cross-platform network-utilities app built in Flutter for Android and iOS. The MVP bundles three tools:

- A VPN client (connects to a WireGuard server Joe controls)
- An internet speed checker (download/upload, Wi-Fi vs. mobile)
- A public IP checker

All three sit behind a simple home/dashboard screen, with room to add more tools later. No billing or multi-user accounts in this phase. Goal: a working, installable app plus a running server, in a single build pass.

## Architecture Decision: Self-Hosted WireGuard VPS

**Not** a third-party VPN network (NordLayer-style SDKs charge recurring per-seat fees and hand control of routing/logging to another company — wrong fit for "build my own").

- A self-hosted WireGuard server costs about the same as a coffee subscription per month (or $0, see below), gives full control over logging, server locations, and future features (kill switch, split tunneling), and is the standard approach for indie/solo VPN projects.
- WireGuard is chosen over OpenVPN or a multi-protocol stack (V2Ray/Xray): simpler to configure, lower latency/overhead, first-class native support on both iOS (`NetworkExtension`) and Android (`VpnService`). WireGuard itself is free and open-source (GPLv2).

## Server Plan & Cost

**Recommended: Oracle Cloud's Always Free tier.** Free forever, no time limit. The smallest ARM instance (Ampere A1 — up to 4 cores / 24GB RAM total across free instances, cut to 2 cores/12GB in some regions as of 2026) is far more than one person's WireGuard traffic needs, with 10TB/month transfer and 200GB disk. Sign-up requires a credit card for identity verification only — never charged on the free tier.

Caveats: you're limited to whichever Oracle region you pick at signup, and there are occasional community reports of idle free-tier accounts getting flagged, so it's worth actually using the instance now and then.

It's a normal VPS, so it can also host other unrelated side projects — just be mindful of shared CPU/RAM/bandwidth.

Fallback paid VPS options if Oracle free-tier signup/availability is ever an issue:

| Provider | Monthly Cost | Specs | Notes |
| --- | --- | --- | --- |
| Cloudzy | ~$2.48/mo | Entry VPS | Cheapest, 13 regions |
| 1VPS.com | ~$3.95/mo | Entry VPS | WireGuard-ready image |
| Contabo Cloud VPS 10 | ~€5.50/mo | 200 Mbps port, unlimited fair-use traffic | Good balance of price/reliability |
| CheapWindowsVPS | from $6/mo | Dedicated IP, unmetered bandwidth | |

Budget for MVP: **$0-10/month total** for one server.

## Mobile App Scope

- **Framework:** Flutter (single codebase for Android + iOS)
- **VPN plugin:** `wireguard_flutter` — actively maintained, wraps native APIs, free and open-source
- **Android:** works out of the box on top of `VpnService`; requires `minSdkVersion 21+`
- **iOS:** requires a Packet Tunnel Network Extension target added in Xcode (uses Apple's `NetworkExtension` framework) — the fiddliest part of the whole build. Needs an Apple Developer account (paid, $99/year) to test on a real device and for App Store distribution. That $99/year is Apple's standard developer program fee, not VPN-specific — no other licensing costs anywhere in this stack.

## Tech Stack Summary

| Layer | Choice |
| --- | --- |
| App framework | Flutter (latest stable) |
| VPN plugin | `wireguard_flutter` |
| Server OS | Ubuntu 22.04/24.04 LTS |
| VPN daemon | WireGuard (kernel module, via `wg-quick`) |
| Config/key management | Simple shell scripts or a lightweight admin panel (e.g. `wg-easy`) to generate per-device keys and configs |
| Hosting | Oracle Cloud Always Free VM (ARM), no cost — fall back to a paid VPS (Contabo, Cloudzy, 1VPS) if signup/availability is an issue |
| Speed test | Own pure-Dart engine (`lib/features/speed_test/model/speed_test_engine.dart`) against Cloudflare's free speed endpoints (`speed.cloudflare.com/__down` / `__up`), run in a background isolate; 8s max per phase with a per-phase data budget; no server-side hosting needed |
| IP checker | Public API call to api.ipify.org (or similar) — free, no API key required |
| Network type detection | `connectivity_plus` package, to label results Wi-Fi vs. mobile |

## Technical Guidelines & Architecture

**Architecture pattern: MVP (Model-View-Presenter), adapted for Flutter's declarative widget model.**

| Layer | Role | Flutter mapping |
| --- | --- | --- |
| Model | Data classes + repository logic | Plain Dart classes (e.g. `VpnConfig`, `ConnectionStatus`) and a `VpnRepository` that wraps the `wireguard_flutter` plugin calls and any local storage |
| Presenter | All business logic and UI state, no Flutter widget code | Plain Dart classes (e.g. `ConnectionPresenter`) extending `ChangeNotifier` or exposing a `ValueNotifier`; fully unit-testable with no Flutter framework dependency |
| View | Purely declarative UI | `StatelessWidget`s (or thin `StatefulWidget`s only for animation/lifecycle) that render Presenter state and forward user taps straight to Presenter methods — no business logic in widget code |

Wiring: inject the Repository into the Presenter's constructor, and the Presenter into the View (via `provider` or `riverpod`, or manual constructor injection for something this small — no need for a heavier DI framework at MVP scale).

**Coding conventions**
- Null safety on, `flutter_lints` package enabled with default rules
- Feature-first folder structure: `lib/features/connection/{model,presenter,view}`, `lib/features/speed_test/...`, `lib/features/ip_checker/...`, `lib/features/settings/...`, `lib/features/home/...`, `lib/core/` for shared utilities — this structure is exactly why MVP was picked: each new tool just adds another `features/<name>/` folder with its own Model-Presenter-View, without touching existing ones
- One Presenter per screen/feature; Presenters never import Flutter's `material.dart`
- Async VPN operations (connect/disconnect) return typed results/exceptions, not booleans, so the Presenter can surface specific error states to the View

**Testing**
- Unit tests for every Presenter and Model (pure Dart, no widget pump needed — this is the main payoff of keeping logic out of widgets)
- Widget tests for Views, using a fake/mock Presenter to drive UI states
- One integration/manual test pass per Build Plan phase on a real device, since VPN tunneling behavior can't be fully verified in a simulator

## MVP Feature List

- [ ] Connect / Disconnect toggle
- [ ] Live connection status (connected, connecting, disconnected, error)
- [ ] Single server selection (region picker can be stubbed with one hardcoded server for MVP)
- [ ] Data transferred / connection duration display
- [ ] Basic settings screen (auto-connect on launch, view current IP)
- [ ] Onboarding: request VPN permission (Android) / install profile (iOS) on first launch
- [ ] Internet speed test — download/upload speed, distinguishing Wi-Fi vs. mobile data
- [ ] Public IP checker — shows current IP, updates when VPN connects/disconnects
- [ ] Home/dashboard screen listing the available tools (VPN, Speed Test, IP Checker), with visual room to add more tools later

Out of scope for MVP: multi-region switching, kill switch, split tunneling, accounts/billing, ad blocking.

## Build Plan (Phases)

1. **Server setup** — provision an Oracle Cloud Always Free ARM instance (or a paid VPS as fallback), install WireGuard, generate a server keypair, write a script that adds/removes peer configs.
2. **Flutter project scaffold** — new Flutter app, add `wireguard_flutter`, set up Android manifest permissions and the iOS Network Extension target in Xcode.
3. **Core connect flow** — wire up connect/disconnect using a test peer config, surface connection state in the UI.
4. **UI polish** — status screen, settings screen, onboarding/permission flow.
5. **Speed test & IP checker tools** — build the home/dashboard screen, then wire up the speed test (Cloudflare endpoints, no server needed) and IP checker (ipify API), each as its own Model-Presenter-View per the architecture above.
6. **Config delivery** — decide how the app gets its WireGuard config (bundled for MVP vs. fetched from a small backend endpoint later).
7. **Test on real devices** — both platforms, including cellular data (not just wifi) to confirm the tunnel actually routes traffic.
8. **Package for distribution** — Android APK/AAB; iOS requires the paid Apple Developer account for TestFlight/App Store.

## Open Questions

- [ ] Which Oracle Cloud region to sign up in (affects latency)?
- [ ] Is there an Apple Developer account already set up under YellowTech, or does one need to be created?
- [ ] Config delivery: bundle one fixed config for now, or build a minimal backend to issue per-device configs later?
- [ ] Should the home/dashboard leave a visible placeholder tile for "more tools coming soon," or just show the three current tools until the next one is actually built?