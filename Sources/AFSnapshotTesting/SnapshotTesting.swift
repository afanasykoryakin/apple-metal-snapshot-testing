//
// SnapshotTesting.swift
// AFSnapshotTesting
//
// Created by Afanasy Koryakin on 04.02.2024.
// Copyright © 2024 Afanasy Koryakin. All rights reserved.
// License: MIT License, https://github.com/afanasykoryakin/apple-metal-snapshot-testing/blob/master/LICENSE
//

import UIKit
import XCTest
import MetalKit

public extension XCTestCase {
    func assertSnapshot(
        _ viewController: UIViewController,
        on device: SnapshotDevice,
        as strategy: Strategy = .naive(threshold: 0),
        record: Bool = false,
        differenceRecord: Bool = true,
        color: MismatchColor = .green,
        file: StaticString = #file,
        line: UInt = #line,
        testName: String = #function,
        named: String? = nil
    ) {
        assertSnapshot(
            viewController.view,
            on: (size: device.size, scale: device.scale),
            as: strategy,
            record: record,
            differenceRecord: differenceRecord,
            file: file,
            line: line,
            testName: testName,
            named: named
        )
    }

    func assertSnapshot(
        _ viewController: UIViewController,
        on screen: (size: CGSize, scale: Int),
        as strategy: Strategy = .naive(threshold: 0),
        record: Bool = false,
        differenceRecord: Bool = true,
        color: MismatchColor = .green,
        file: StaticString = #file,
        line: UInt = #line,
        testName: String = #function,
        named: String? = nil
    ) {
        assertSnapshot(
            viewController.view,
            on: (size: screen.size, scale: screen.scale),
            as: strategy,
            record: record,
            differenceRecord: differenceRecord,
            file: file,
            line: line,
            testName: testName,
            named: named
        )
    }
    
    func assertSnapshot(
        _ view: UIView,
        on screen: SnapshotDevice,
        as strategy: Strategy = .naive(threshold: 0),
        record: Bool = false,
        differenceRecord: Bool = true,
        color: MismatchColor = .green,
        file: StaticString = #file,
        line: UInt = #line,
        testName: String = #function,
        named: String? = nil
    ) {
        assertSnapshot(
            view,
            on: (size: screen.size, scale: screen.scale),
            as: strategy,
            record: record,
            differenceRecord: differenceRecord,
            file: file,
            line: line,
            testName: testName,
            named: named
        )
    }

    func assertSnapshot(
        _ view: UIView,
        on screen: (size: CGSize, scale: Int),
        as strategy: Strategy = .naive(threshold: 0),
        record: Bool = false,
        differenceRecord: Bool = true,
        color: MismatchColor = .green,
        file: StaticString = #file,
        line: UInt = #line,
        testName: String = #function,
        named: String? = nil
    ) {
        if let errorDescription = validationInput(screen, strategy: strategy) {
            return XCTFail(errorDescription, file: file, line: line)
        }

        let funcName = named ?? testName.replacingOccurrences(of: "()", with: "")
        let className = String(describing: type(of: self))
        let referenceURL = Snapshot.createReferenceURL(name: funcName, class: className, file: file)
        let differenceURL = Snapshot.createDifferenceImageURL(name: funcName, class: className, file: file)

        let referenceSnapshotDoesNotExist = !FileManager.default.fileExists(atPath: referenceURL.path)

        if record || referenceSnapshotDoesNotExist {
            do {
                try Snapshot.renderImage(view: view, on: screen).data()
                    .save(in: referenceURL)
            } catch {
                XCTFail("Failed to save reference snapshot with error: \(error)", file: file, line: line)
            }

            if referenceSnapshotDoesNotExist {
                XCTFail("No reference was found on disk. Automatically recorded snapshot: \(referenceURL)", file: file, line: line)
            }
        } else {
            do {
                let snapshot = try Snapshot.normilize(cgImage: try Snapshot.renderCGImage(view: view, on: screen))
                let referenceSnapshot = try Snapshot.createReferenceSnapshot(from: referenceURL)

                switch strategy {
                    case .naive(threshold: let threshold):
                        let difference = try Snapshot.naiveDifference(snapshot, referenceSnapshot)

                        guard difference > threshold else { return }

                        guard differenceRecord else {
                            throw SnapshotError.snapshotMismatch(description: "Threshold exceeded: current difference (\(difference)) is greater than the specified threshold (\(threshold)).")
                        }

                        let differenceCGImage = try NaiveKernelDifferenceImage(with: .init(metalSource: MSLNaiveKernel))
                            .differenceImage(lhs: snapshot, rhs: referenceSnapshot, color: color)
                        let differenceImage = UIImage(cgImage: differenceCGImage)
                        try differenceImage.data()
                            .save(in: differenceURL)

                        throw SnapshotError.snapshotMismatch(description: "Threshold exceeded: current difference (\(difference)) is greater than the specified threshold (\(threshold)). Difference image save to \(differenceURL)")
                    case .cluster(threshold: let threshold, clusterSize: let clusterSize):
                        let difference = try Snapshot.clusterDifference(snapshot, referenceSnapshot, clusterSize: clusterSize)

                        guard difference > threshold else { return }

                        guard differenceRecord else {
                            throw SnapshotError.snapshotMismatch(description: "Threshold exceeded: current difference (\(difference)) is greater than the specified threshold (\(threshold)).")
                        }

                        let differenceCGImage = try ClusterKernelDifferenceImage(with: .init(metalSource: MSLClusterKernel))
                            .differenceImage(lhs: snapshot, rhs: referenceSnapshot, clusterSize: clusterSize, color: color)
                        let differenceImage = UIImage(cgImage: differenceCGImage)
                        try differenceImage.data()
                            .save(in: differenceURL)

                    throw SnapshotError.snapshotMismatch(description: """
                        Threshold exceeded: current difference (\(difference) pixels) is greater than the specified threshold (\(threshold)). 

                        Difference image save to \(differenceURL)
                        """
                    )
                }
            } catch {
                XCTFail("Failed with error: \(error)", file: file, line: line)
            }
        }
    }
}

func validationInput(_ screen: (size: CGSize, scale: Int), strategy: Strategy) -> String? {
    let pixelsCount = Int((screen.size.height * Double(screen.scale)) * (screen.size.width * Double(screen.scale)))

    if pixelsCount >= 56250000 {
        return "So far, such sizes are not supported"
    }

    if pixelsCount <= 0 {
        return "screen size <= 0"
    }

    if case .naive(threshold: let threshold) = strategy, !(0...pixelsCount).contains(threshold) {
        return "The threshold value for the .naive strategy does not fall within the valid pixel range. Expected a value between 0 and \(pixelsCount), but got \(threshold)."
    }

    if case .cluster(let threshold, _) = strategy, !(0...pixelsCount).contains(threshold) {
        return "The threshold value for the .cluster strategy does not fall within the valid pixel range. Expected a value between 0 and \(pixelsCount), but got \(threshold)."
    }

    if case .cluster(_, let clusterSize) = strategy, !(1...7).contains(clusterSize) {
        return "The cluster size for the .cluster strategy does not fall within the valid range (1 to 7). Got \(clusterSize)."
    }

    return nil
}

enum SnapshotError: Error {
    case snapshotMismatch(description: String)
    case scaleDifference(description: String)
    case failedToCreateCGImage(snapshotName: String)
    case referenceImageNotFound(snapshotName: String)
    case failedToPrepareCGImage(description: String)
    case error(description: String)
}

struct Snapshot {
    static func createReferenceURL(name testName: String, class className: String, file: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("Snapshots")
            .appendingPathComponent(className)
            .appendingPathComponent(testName)
            .appendingPathExtension("png")
    }

    static func createDifferenceImageURL(name testName: String, class className: String, file: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("Difference")
            .appendingPathComponent(className)
            .appendingPathComponent(testName)
            .appendingPathExtension("png")
    }

    static func createReferenceSnapshot(from url: URL) throws -> CGImage {
        guard let referenceSnapshotImage = UIImage(contentsOfFile: url.path) else {
            throw SnapshotError.referenceImageNotFound(snapshotName: url.lastPathComponent)
        }

        guard let referenceSnapshotCGImage = referenceSnapshotImage.cgImage else {
            throw SnapshotError.failedToCreateCGImage(snapshotName: url.lastPathComponent)
        }

        return referenceSnapshotCGImage
    }

    static func renderCGImage(view: UIView, on screen: (size: CGSize, scale: Int)) throws -> CGImage {
        guard let cgImage = try renderImage(view: view, on: screen).cgImage else {
            throw SnapshotError.failedToCreateCGImage(snapshotName: "Render")
        }

        return cgImage
    }

    static func renderImage(view: UIView, on screen: (size: CGSize, scale: Int)) throws -> UIImage {
        view.frame = CGRect(origin: .zero, size: screen.size)
        view.layoutIfNeeded()

        let image = UIGraphicsImageRenderer(size: screen.size).image { context in
            view.layer.render(in: context.cgContext)
        }

        guard image.scale == CGFloat(screen.scale) else {
            throw SnapshotError.scaleDifference(description: "The scale of the selected device (\(screen.scale)) does not match the scale of the simulator or device (\(image.scale)) on which the test is running.")
        }
        
        return image
    }

    private static let clusterKernel: ClusterKernel = try! ClusterKernel(with: Kernel.Configuration(metalSource: MSLClusterKernel))

    static func clusterDifference(_ lhs: CGImage, _ rhs: CGImage, clusterSize: Int) throws -> Int {
        guard lhs.width == rhs.width, lhs.height == rhs.height else {
            throw SnapshotError.snapshotMismatch(description: "Snapshot size does not match. First size: \(lhs.width) x \(lhs.height), Second size: \(rhs.width) x \(rhs.height)")
        }

        return try clusterKernel.difference(lhs: lhs, rhs: rhs, clusterSize: clusterSize)
    }

    private static let naiveKernel: NaiveKernel = try! NaiveKernel(with: Kernel.Configuration(metalSource: MSLNaiveKernel))

    static func naiveDifference(_ lhs: CGImage, _ rhs: CGImage) throws -> Int {
        guard lhs.width == rhs.width, lhs.height == rhs.height else {
            throw SnapshotError.snapshotMismatch(description: "Snapshot size does not match. First size: \(lhs.width) x \(lhs.height), Second size: \(rhs.width) x \(rhs.height)")
        }

        return try naiveKernel.difference(lhs: lhs, rhs: rhs)
    }

    static func normilize(cgImage: CGImage) throws -> CGImage {
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            throw SnapshotError.failedToPrepareCGImage(description: "Failed to create bitmap context")
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let preparingCGImage = context.makeImage() else {
            throw SnapshotError.failedToPrepareCGImage(description: "Failed to get CGImage from context")
        }

        return preparingCGImage
    }
}

private extension UIImage {
    func data() throws -> Data {
        guard let data = pngData() else {
            throw SnapshotError.error(description: "Failed to convert image to PNG data.")
        }
        
        return data
    }
}

private extension Data {
    func save(in url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try write(to: url)
    }
}

public struct SnapshotDevice {
    let size: CGSize
    let scale: Int

    public static let iPhone14ProMax = SnapshotDevice(size: CGSize(width: 430, height: 932), scale: 3)
    public static let iPhone14Pro = SnapshotDevice(size: CGSize(width: 393, height: 852), scale: 3)
    public static let iPhone14 = SnapshotDevice(size: CGSize(width: 390, height: 844), scale: 3)
    public static let iPhoneSE = SnapshotDevice(size: CGSize(width: 320, height: 568), scale: 2)
    public static let iPhone8 = SnapshotDevice(size: CGSize(width: 375, height: 667), scale: 2)
    public static let iPhoneX = SnapshotDevice(size: CGSize(width: 375, height: 812), scale: 3)
    public static let iPhoneXsMax = SnapshotDevice(size: CGSize(width: 414, height: 896), scale: 3)
}

public struct MismatchColor {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat

    public static let red = MismatchColor(red: 1.0, green: 0.0, blue: 0.0)
    public static let green = MismatchColor(red: 0.0, green: 1.0, blue: 0.0)
    public static let blue = MismatchColor(red: 0.0, green: 0.0, blue: 1.0)
}

public enum Strategy {
    case naive(threshold: Int = 0)
    case cluster(threshold: Int = 0, clusterSize: Int = 1)
}
