// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppleWebLogin",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .library(name: "AppleWebLogin", targets: ["AppleWebLogin"]),
    ],
    targets: [
        .target(name: "AppleWebLogin"),
    ]
)
