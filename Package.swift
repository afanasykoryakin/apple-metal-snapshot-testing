// swift-tools-version: 5.5

//
// Package.swift
// AFSnapshotTesting
//
// Created by Afanasy Koryakin on 29.12.2023.
// Copyright © 2023 Afanasy Koryakin. All rights reserved.
// License: MIT License
//

import PackageDescription

let package = Package(
    name: "AFSnapshotTesting",
    products: [
        .library(
            name: "AFSnapshotTesting",
            targets: [ "AFSnapshotTesting" ]),
    ],
    targets: [
        .target(name: "AFSnapshotTesting"),
        .target(name: "Services", path: "Tests/Services"),
        .testTarget(
            name: "SnapshotTestingTests",
            dependencies: [ "AFSnapshotTesting" ]
        ),
        .testTarget(
            name: "ClusterKernelTests",
            dependencies: [ "AFSnapshotTesting", "Services" ]
        ),
        .testTarget(
            name: "NaiveKernelTests",
            dependencies: [ "AFSnapshotTesting", "Services" ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
