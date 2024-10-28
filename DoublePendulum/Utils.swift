//
//  Utils.swift
//  DoublePendulum
//
//  Created by Tim Hau on 28.10.24.
//
import MetalKit


func buildColorAttachment() -> MTLRenderPipelineColorAttachmentDescriptor {
    let colorAttachment = MTLRenderPipelineColorAttachmentDescriptor()
    colorAttachment.pixelFormat = .bgra8Unorm
    colorAttachment.isBlendingEnabled = true
    colorAttachment.alphaBlendOperation = .add
    colorAttachment.rgbBlendOperation = .add
    colorAttachment.sourceRGBBlendFactor = .sourceAlpha
    colorAttachment.sourceAlphaBlendFactor = .sourceAlpha
    colorAttachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
    colorAttachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
    return colorAttachment
}

func buildVertexAttribute(
    format: MTLVertexFormat,
    bufferIndex: Int,
    offset: Int
) -> MTLVertexAttributeDescriptor {
    let attribute = MTLVertexAttributeDescriptor()
    attribute.format = format
    attribute.bufferIndex = bufferIndex
    attribute.offset = offset
    return attribute
}
