//
// ClusterKernelTests_DeepTests.swift
// AFSnapshotTesting
//
// Created by Afanasy Koryakin on 07.04.2024.
// Copyright © 2024 Afanasy Koryakin. All rights reserved.
// License: MIT License
//

import XCTest
import Services
@testable import AFSnapshotTesting

final class ClusterKernelTests_DeepTests: XCTestCase {
    let kernel = try! ClusterKernel(with: Kernel.Configuration(metalSource: MSLClusterKernel))

    func testClusterKernelDeep_DeepClusterIsThree_DeepIsTwo() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs, clusterSize: 2)
        XCTAssertEqual(difference, 3)
    }
    
    func testClusterKernelDeep_DeepClusterIsThree_DeepIsThree() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs, clusterSize: 3)
        XCTAssertEqual(difference, 3)
    }
    
    func testClusterKernelDeep_DeepClusterIsThree_DeepIsFive() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs, clusterSize: 5)
        XCTAssertEqual(difference, 0)
    }
    
    func testClusterKernelDeep_DeepClusterIsThree_DeepIsSeven() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs, clusterSize: 7)
        XCTAssertEqual(difference, 0)
    }
    
    func testClusterKernelDeep_DeepClusterIsFive_DeepIsTwo() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs, clusterSize: 2)
        XCTAssertEqual(difference, 5)
    }
    
    func testClusterKernelDeep_DeepClusterIsFive_DeepIsThree() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs, clusterSize: 3)
        XCTAssertEqual(difference, 5)
    }
    
    func testClusterKernelDeep_DeepClusterIsFive_DeepIsFive() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs, clusterSize: 5)
        XCTAssertEqual(difference, 5)
    }
    
    func testClusterKernelDeep_DeepClusterIsFive_DeepIsSeven() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs, clusterSize: 7)
        XCTAssertEqual(difference, 0)
    }
    
    func testClusterKernelDeep_DeepClusterIsSeven_DeepIsTwo() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs, clusterSize: 2)
        XCTAssertEqual(difference, 7)
    }
    
    func testClusterKernelDeep_DeepClusterIsSeven_DeepIsThree() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs, clusterSize: 3)
        XCTAssertEqual(difference, 7)
    }
    
    func testClusterKernelDeep_DeepClusterIsSeven_DeepIsFive() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs, clusterSize: 5)
        XCTAssertEqual(difference, 7)
    }
    
    func testClusterKernelDeep_DeepClusterIsSeven_DeepIsSeven() throws {
        let (lhs, rhs) = images(className: String(describing: type(of: self)))
        let difference = try kernel.difference(lhs: lhs, rhs: rhs, clusterSize: 7)
        XCTAssertEqual(difference, 7)
    }
}
