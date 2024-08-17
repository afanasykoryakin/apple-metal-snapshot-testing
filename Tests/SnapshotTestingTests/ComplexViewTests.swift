//
// ComplexViewTests.swift
// AFSnapshotTesting
//
// Created by Afanasy Koryakin on 11.09.2024.
// Copyright © 2024 Afanasy Koryakin. All rights reserved.
// License: MIT License
//

import XCTest
import AFSnapshotTesting

final class ComplexViewTests: XCTestCase {
    func testComplex() {
        let complex = ComplexView()
        assertSnapshot(complex, on: .iPhone14)
    }

    func testComplexSmall() {
        let complex = ComplexView()
        assertSnapshot(complex, on: (size: CGSize(width: 100, height: 300), scale: 3))
    }
    
    func testComplexMedium() {
        let complex = ComplexView()
        assertSnapshot(complex, on: (size: CGSize(width: 300, height: 300), scale: 3))
    }
    
    func testComplexBig() {
        let complex = ComplexView()
        assertSnapshot(complex, on: (size: CGSize(width: 1000, height: 1000), scale: 3))
    }
}
