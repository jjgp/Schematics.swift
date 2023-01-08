// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Schematics",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "FoundationSchema", targets: ["FoundationSchema"]),
        .library(name: "ReactiveSchema", targets: ["ReactiveSchema"]),
        .library(name: "UnidirectionalSchema", targets: ["UnidirectionalSchema"])
    ],
    dependencies: [],
    targets: [
        .target(name: "FoundationSchema", dependencies: []),
        .testTarget(name: "FoundationSchemaTests", dependencies: ["FoundationSchema"]),
        .target(name: "ReactiveSchema", dependencies: ["FoundationSchema"]),
        .testTarget(name: "ReactiveSchemaTests", dependencies: ["ReactiveSchema"]),
        .target(name: "UnidirectionalSchema", dependencies: ["ReactiveSchema"]),
        .testTarget(name: "UnidirectionalSchemaTests", dependencies: ["UnidirectionalSchema"])
    ]
)
