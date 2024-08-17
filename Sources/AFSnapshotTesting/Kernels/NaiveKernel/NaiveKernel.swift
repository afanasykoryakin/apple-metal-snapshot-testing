//
// NaiveKernel.swift
// AFSnapshotTesting
//
// Created by Afanasy Koryakin on 07.04.2024.
// Copyright © 2024 Afanasy Koryakin. All rights reserved.
// License: MIT License, https://github.com/afanasykoryakin/apple-metal-snapshot-testing/blob/master/LICENSE
//

import MetalKit

class NaiveKernel: Kernel {
    init(with configuration: Kernel.Configuration) throws {
        try super.init(with: configuration, function: "naiveKernel")
    }

    func difference(lhs: CGImage, rhs: CGImage) throws -> Int {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            throw KernelError.createCommandBuffer
        }

        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            throw KernelError.createCommandEncoder
        }

        computeEncoder.setComputePipelineState(pipelineState)

        let texture1 = try textureLoader.newTexture(cgImage: lhs, options: options)
        let texture2 = try textureLoader.newTexture(cgImage: rhs, options: options)

        computeEncoder.setTexture(texture1, index: 0)
        computeEncoder.setTexture(texture2, index: 1)

        let counterBuffer = device.makeBuffer(length: MemoryLayout<uint>.size, options: .storageModeShared)
        computeEncoder.setBuffer(counterBuffer, offset: 0, index: 0)

        let width = pipelineState.threadExecutionWidth
        let height = pipelineState.maxTotalThreadsPerThreadgroup / width
        let threadsPerThreadgroup = MTLSizeMake(width, height, 1)
        let threadsPerGrid = MTLSize(width: texture1.width, height: texture1.height, depth: 1)

        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        computeEncoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        let resultPointer = counterBuffer!.contents().bindMemory(to: uint.self, capacity: 1)
        let differenceCount = resultPointer.pointee

        return Int(differenceCount)
    }
}
