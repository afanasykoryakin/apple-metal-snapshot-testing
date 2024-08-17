//
// SnapshotTestingTests.swift
// AFSnapshotTesting
//
// Created by Afanasy Koryakin on 08.04.2024.
// Copyright © 2024 Afanasy Koryakin. All rights reserved.
// License: MIT License
//

import XCTest
@testable import AFSnapshotTesting

final class SnapshotTestingTests: XCTestCase {
    let iPhone14 = (size: SnapshotDevice.iPhone14.size, scale: 3)
    lazy var view = UIView(frame: CGRect(origin: .zero, size: iPhone14.size))

    func testNaiveStrategyWithRedBlueGradient() {
        let colors = [ UIColor.red.cgColor, UIColor.blue.cgColor ]
        view.applyGradient(colors: colors, locations: [0.0, 1.0])
        assertSnapshot(view, on: iPhone14)
    }

    func testNaiveStrategyWithBlueRedGradient() {
        let colors = [ UIColor.blue.cgColor, UIColor.red.cgColor ]
        view.applyGradient(colors: colors, locations: [0.0, 1.0])
        assertSnapshot(view, on: iPhone14, color: .green)
    }

    func testNaiveStrategyWithBlueRedPurpleGradient() {
        let colors = [ UIColor.blue.cgColor, UIColor.red.cgColor, UIColor.purple.cgColor ]
        view.applyGradient(colors: colors, locations: [0.0, 0.5, 1.0])
        assertSnapshot(view, on: iPhone14)
    }

    func testNaiveStrategyWithBlueRedPurpleGradient_thresholdIs1000_DifferenceIs1000() {
        let colors = [ UIColor.blue.cgColor, UIColor.red.cgColor, UIColor.purple.cgColor ]
        view.applyGradient(colors: colors, locations: [0.0, 0.5, 1.0])
        assertSnapshot(view, on: iPhone14, as: .naive(threshold: 1000))
    }

    func testClusterStrategyWithRedBlueGradient() {
        let colors = [ UIColor.red.cgColor, UIColor.blue.cgColor ]
        view.applyGradient(colors: colors, locations: [0.0, 1.0])
        assertSnapshot(view, on: iPhone14, as: .cluster(threshold: 0, clusterSize: 2))
    }

    func testClusterStrategyWithBlueRedGradient() {
        let colors = [ UIColor.blue.cgColor, UIColor.red.cgColor ]
        view.applyGradient(colors: colors, locations: [0.0, 1.0])
        assertSnapshot(view, on: iPhone14, as: .cluster(threshold: 0, clusterSize: 2))
    }

    func testClusterStrategyWithBlueRedPurpleGradient() {
        let colors = [ UIColor.blue.cgColor, UIColor.red.cgColor, UIColor.purple.cgColor ]
        view.applyGradient(colors: colors, locations: [0.0, 0.5, 1.0])
        assertSnapshot(view, on: iPhone14, as: .cluster(threshold: 0, clusterSize: 2))
    }
    
    func testClusterStrategyWithBlueRedPurpleGradient_thresholdIs1000_DifferenceIs1000() {
        let colors = [ UIColor.blue.cgColor, UIColor.red.cgColor, UIColor.purple.cgColor ]
        view.applyGradient(colors: colors, locations: [0.0, 0.5, 1.0])
        assertSnapshot(view, on: iPhone14, as: .cluster(threshold: 1000, clusterSize: 2))
    }
}

private extension UIView {
    func applyGradient(colors: [CGColor], locations: [NSNumber]?) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
