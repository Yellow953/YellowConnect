Vendored copy of WireGuardKit from https://git.zx2c4.com/wireguard-apple
at revision 2fec12a6e1f6e3460b6ee483aa00ad29cddadab1 (only the three
WireGuardKit targets).

Local change: `Package.swift` bumped from swift-tools-version 5.3 to 5.5.
Upstream uses `.macOS(.v12)` / `.iOS(.v15)`, which require 5.5, and Swift 6.4+
(Xcode 27) refuses to load the manifest otherwise.

Local change: `Sources/WireGuardKitC/WireGuardKitC.h` now includes
`<sys/types.h>` for the `u_int32_t`/`u_char` types it uses; Xcode 27's
explicit module builds reject relying on them being transitively available.
