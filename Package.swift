// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Schematics",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "CoreSchema", targets: ["CoreSchema"]),
        .library(name: "ReactiveSchema", targets: ["ReactiveSchema"]),
        .library(name: "UnidirectionalSchema", targets: ["UnidirectionalSchema"])
    ],
    dependencies: [],
    targets: [
        .target(name: "CoreSchema", dependencies: []),
        .testTarget(name: "CoreSchemaTests", dependencies: ["CoreSchema"]),
        .target(name: "ReactiveSchema", dependencies: ["CoreSchema"]),
        .testTarget(name: "ReactiveSchemaTests", dependencies: ["ReactiveSchema"]),
        .target(name: "UnidirectionalSchema", dependencies: ["ReactiveSchema"]),
        .testTarget(name: "UnidirectionalSchemaTests", dependencies: ["UnidirectionalSchema"])
    ]
)
