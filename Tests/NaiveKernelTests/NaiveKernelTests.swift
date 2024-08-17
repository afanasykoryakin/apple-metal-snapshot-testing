//
// NaiveKernelTests.swift
// AFSnapshotTesting
//
// Created by Afanasy Koryakin on 07.04.2024.
// Copyright © 2024 Afanasy Koryakin. All rights reserved.
// License: MIT License
//

import XCTest
import Services
@testable import AFSnapshotTesting

final class NaiveKernelTests: XCTestCase {
    let kernel = try! NaiveKernel(with: Kernel.Configuration(metalSource: MSLNaiveKernel))

    func test_WithoutDifference() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs)
        XCTAssertEqual(difference, 0)
    }

    func test_OneDifference() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs)
        XCTAssertEqual(difference, 1)
    }

    func test_TwoDifference() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs)
        XCTAssertEqual(difference, 2)
    }

    func test_ThreeDifference() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs)
        XCTAssertEqual(difference, 3)
    }
    
    func test_FullDifference() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs)
        XCTAssertEqual(difference, 81)
    }
}
