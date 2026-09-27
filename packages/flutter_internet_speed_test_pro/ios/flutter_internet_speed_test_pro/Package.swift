// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_internet_speed_test_pro",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "flutter-internet-speed-test-pro", targets: ["flutter_internet_speed_test_pro"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "flutter_internet_speed_test_pro",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
