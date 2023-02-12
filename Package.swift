// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CachedAcyncImage",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "CachedAcyncImage", targets: ["CachedAcyncImage"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "CachedAcyncImage", dependencies: [])
    ]
)
