// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Cursors",
    products: [
        .library(
            name: "Cursors",
            targets: ["Cursors"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Cursors",
            dependencies: []),
        .testTarget(
            name: "CursorsTests",
            dependencies: ["Cursors"]),
    ]
)
