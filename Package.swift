// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Schematics.swift",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "CoreSchema", targets: ["CoreSchema"]),
        .library(name: "ReactiveSchema", targets: ["ReactiveSchema"]),
        .library(name: "UnidirectionalSchema", targets: ["UnidirectionalSchema"])
    ],
    dependencies: [],
    targets: [
        .target(name: "CoreSchema", dependencies: []),
        .target(name: "ReactiveSchema", dependencies: ["CoreSchema"]),
        .testTarget(name: "ReactiveSchemaTests", dependencies: ["ReactiveSchema"]),
        .target(name: "UnidirectionalSchema", dependencies: ["ReactiveSchema"]),
        .testTarget(name: "UnidirectionalSchemaTests", dependencies: ["UnidirectionalSchema"])
    ]
)
