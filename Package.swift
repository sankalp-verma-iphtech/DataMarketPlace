// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "dataMarketplacePackage",
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
    dependencies: [
        .package(url: "https://github.com/sankalp-verma-iphtech/DataMarketPlace", from: "1.0.0")

    ],
    targets: [
        .target(
            name: "DataMarketplacePackage",
            path: "Sources"
        )
    ]
)
