// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "datamarketplacepackage",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "DataMarketplacePackage",
            targets: ["DataMarketplacePackage"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DataMarketplacePackage",
            path: "Sources",
            exclude: [".swiftpm"] // Exclude this directory
        )
    ]
)

