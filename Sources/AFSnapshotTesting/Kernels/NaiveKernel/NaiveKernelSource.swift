//
// NaiveKernelSource.swift
// AFSnapshotTesting
//
// Created by Afanasy Koryakin on 07.04.2024.
// Copyright © 2024 Afanasy Koryakin. All rights reserved.
// License: MIT License, https://github.com/afanasykoryakin/apple-metal-snapshot-testing/blob/master/LICENSE
//

let MSLNaiveKernel = """
#include <metal_stdlib>
using namespace metal;

kernel void naiveKernel(texture2d<float, access::read> inputImage1 [[texture(0)]],
                          texture2d<float, access::read> inputImage2 [[texture(1)]],
                          device atomic_uint* counter [[buffer(0)]],
                          uint2 gid [[thread_position_in_grid]]) {
    if (gid.x >= inputImage1.get_width() || gid.y >= inputImage1.get_height()) {
        return;
    }

    float4 pixel1 = inputImage1.read(gid);
    float4 pixel2 = inputImage2.read(gid);

    bool isPixelNotEqual = !((pixel1.r == pixel2.r) && (pixel1.g == pixel2.g) && (pixel1.b == pixel2.b) && (pixel1.a == pixel2.a));

    if (isPixelNotEqual) {
        atomic_fetch_add_explicit(counter, 1, memory_order_relaxed);
    }
}

kernel void naiveKernelTextureRecord(texture2d<float, access::read> inputImage1 [[texture(0)]],
                          texture2d<float, access::read> inputImage2 [[texture(1)]],
                          texture2d<float, access::write> outputImage [[texture(2)]],
                          constant float4& newColor [[buffer(0)]],
                          uint2 gid [[thread_position_in_grid]]) {
    if (gid.x >= inputImage1.get_width() || gid.y >= inputImage1.get_height()) {
        return;
    }

    float4 pixel1 = inputImage1.read(gid);
    float4 pixel2 = inputImage2.read(gid);

    bool isPixelNotEqual = !((pixel1.r == pixel2.r) && (pixel1.g == pixel2.g) && (pixel1.b == pixel2.b) && (pixel1.a == pixel2.a));

    if (isPixelNotEqual) {
        outputImage.write(newColor, gid);
    } else {
        outputImage.write(pixel1, gid);
    }
}
"""
