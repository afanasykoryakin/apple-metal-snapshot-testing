//
// InteractiveViewTests.swift
// AFSnapshotTesting
//
// Created by Afanasy Koryakin on 11.09.2024.
// Copyright © 2024 Afanasy Koryakin. All rights reserved.
// License: MIT License
//

import XCTest
import AFSnapshotTesting

final class InteractiveViewTests: XCTestCase {
    func testInteraction() {
        let view = InteractiveView()
        assertSnapshot(view, on: .iPhone14, named: "testInteraction_Init")
        view.buttonTapped()
        assertSnapshot(view, on: .iPhone14, named: "testInteraction_Tapped")
        view.buttonTapped()
        assertSnapshot(view, on: .iPhone14, named: "testInteraction_TappedBack")
        view.startCycleAnimation()
        assertSnapshot(view, on: .iPhone14, named: "testInteraction_cyclestart")
        view.startCycleAnimation()
        assertSnapshot(view, on: .iPhone14, named: "testInteraction_cycleend")
    }
}
