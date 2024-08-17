//
// Utilites.swift
// AFSnapshotTesting
//
// Created by Afanasy Koryakin on 07.04.2024.
// Copyright © 2024 Afanasy Koryakin. All rights reserved.
// License: MIT License
//

import Foundation
import CoreGraphics
import Metal
import UIKit

public func images(
    file: StaticString = #file,
    line: UInt = #line,
    testName: String = #function,
    className: String,
    referenceName: String = "9X9"
) -> (CGImage, CGImage) {
    let imageURL_1 = URL(fileURLWithPath: String(describing: file))
        .deletingLastPathComponent()
        .appendingPathComponent("Snapshots")
        .appendingPathComponent(className)
        .appendingPathComponent(referenceName)
        .appendingPathExtension("png")
    
    let imageURL_2 = URL(fileURLWithPath: String(describing: file))
        .deletingLastPathComponent()
        .appendingPathComponent("Snapshots")
        .appendingPathComponent(className)
        .appendingPathComponent(testName.replacingOccurrences(of: "()", with: ""))
        .appendingPathExtension("png")

    let cgImage1 = UIImage(contentsOfFile: imageURL_1.path)!.cgImage!
    let cgImage2 = UIImage(contentsOfFile: imageURL_2.path)!.cgImage!

    return (cgImage1, cgImage2)
}
