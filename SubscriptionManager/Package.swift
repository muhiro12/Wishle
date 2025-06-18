// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SubscriptionManager",
    platforms: [
        .iOS(.v18), .macOS(.v15)
    ],
    products: [
        .library(name: "SubscriptionManager", targets: ["SubscriptionManager"])
    ],
    targets: [
        .target(name: "SubscriptionManager"),
        .testTarget(name: "SubscriptionManagerTests", dependencies: ["SubscriptionManager"])
    ]
)
