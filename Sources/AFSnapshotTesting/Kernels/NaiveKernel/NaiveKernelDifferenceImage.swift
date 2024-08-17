//
// NaiveKernelDifferenceImage.swift
// AFSnapshotTesting
//
// Created by Afanasy Koryakin on 07.04.2024.
// Copyright © 2024 Afanasy Koryakin. All rights reserved.
// License: MIT License, https://github.com/afanasykoryakin/apple-metal-snapshot-testing/blob/master/LICENSE
//

import MetalKit

class NaiveKernelDifferenceImage: Kernel {
    init(with configuration: Kernel.Configuration) throws {
        try super.init(with: configuration, function: "naiveKernelTextureRecord")
    }

    func differenceImage(lhs: CGImage, rhs: CGImage, color: MismatchColor) throws -> CGImage {
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

        var color: SIMD4<Float> = SIMD4<Float>(Float(color.red), Float(color.green), Float(color.blue), 1.0)
        let colorBuffer = device.makeBuffer(bytes: &color, length: MemoryLayout<SIMD4<Float>>.size, options: [])
        computeEncoder.setBuffer(colorBuffer, offset: 0, index: 0)

        let outputTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm, 
            width: texture1.width,
            height: texture1.height,
            mipmapped: false
        )

        guard let outputTexture = device.makeTexture(descriptor: outputTextureDescriptor) else {
            throw KernelError.createMTLTexture
        }

        computeEncoder.setTexture(outputTexture, index: 2)

        let width = pipelineState.threadExecutionWidth
        let height = pipelineState.maxTotalThreadsPerThreadgroup / width
        let threadsPerThreadgroup = MTLSizeMake(width, height, 1)
        let threadsPerGrid = MTLSize(width: texture1.width, height: texture1.height, depth: 1)

        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        computeEncoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        guard let ciImage = CIImage(mtlTexture: outputTexture) else {
            throw KernelError.createDifferenceImage
        }
        
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -ciImage.extent.size.height)
        let flippedCIImage = ciImage.transformed(by: transform)

        let context = CIContext(options: [ CIContextOption.workingColorSpace: CGColorSpaceCreateDeviceRGB() ])
        
        guard let differenceImage = context.createCGImage(flippedCIImage, from: flippedCIImage.extent) else {
            throw KernelError.createDifferenceImage
        }

        return differenceImage
    }
}
