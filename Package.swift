// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CachedAsyncImage991",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "CachedAsyncImage991", targets: ["CachedAsyncImage991"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "CachedAsyncImage991", dependencies: []),
        .testTarget(name: "CachedAsyncImage991Tests", dependencies: ["CachedAsyncImage991"])
    ]
)
