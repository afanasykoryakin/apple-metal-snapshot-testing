//
// Kernel.swift
// AFSnapshotTesting
//
// Created by Afanasy Koryakin on 07.04.2024.
// Copyright © 2024 Afanasy Koryakin. All rights reserved.
// License: MIT License, https://github.com/afanasykoryakin/apple-metal-snapshot-testing/blob/master/LICENSE
//

import MetalKit

enum KernelError: Error {
    case createMTLTexture
    case createMTLDevice
    case createCommandQueue
    case createShaderFunction
    case createCommandBuffer
    case createCommandEncoder
    case shaderFunction
    case createDifferenceImage
    case invalidParameters(String)
}

class Kernel {
    struct Configuration {
        let metalSource: String
    }

    init(with configuration: Configuration, function: String? = nil) throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw KernelError.createMTLDevice
        }

        guard let commandQueue = device.makeCommandQueue() else {
            throw KernelError.createCommandQueue
        }

        guard let kernelFunctionName = function else {
            throw KernelError.shaderFunction
        }

        let library = try device.makeLibrary(source: configuration.metalSource, options: nil)

        guard let function = library.makeFunction(name: kernelFunctionName) else {
            throw KernelError.createShaderFunction
        }

        self.device = device
        self.commandQueue = commandQueue
        pipelineState = try device.makeComputePipelineState(function: function)
        textureLoader = MTKTextureLoader(device: device)
    }

    let device: MTLDevice
    let pipelineState: MTLComputePipelineState
    let commandQueue: MTLCommandQueue
    let textureLoader: MTKTextureLoader

    let options: [MTKTextureLoader.Option: Any] = [
        .textureStorageMode: MTLStorageMode.private.rawValue,
        .SRGB: false
    ]
}
