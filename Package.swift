// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Schematics.swift",
    products: [
        .library(
            name: "StoreSchema",
            targets: ["StoreSchema"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "StoreSchema",
            dependencies: []
        ),
        .testTarget(
            name: "StoreSchemaTests",
            dependencies: ["StoreSchema"]
        ),
    ]
)
