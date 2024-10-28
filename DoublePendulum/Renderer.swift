//
//  Renderer.swift
//  DoublePendulum
//
//  Created by Tim Hau on 28.10.24.
//
import MetalKit
import simd

class Renderer: NSObject, MTKViewDelegate {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var renderPipelineState: MTLRenderPipelineState
    var computePipelineState: MTLComputePipelineState
    var texture: MTLTexture
    var width: Int
    var height: Int
    
    var lengths: SIMD2<Float> = SIMD2<Float>(1.0, 1.0);
    var masses: SIMD2<Float> = SIMD2<Float>(1.0, 1.0);

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        let device = MTLCreateSystemDefaultDevice()!
        self.device = device
        self.texture = Renderer.buildTexture(device: device, width: width, height: height)
        self.commandQueue = device.makeCommandQueue()!
        self.renderPipelineState = Renderer.buildRenderPipeline(device: device)
        self.computePipelineState = Renderer.buildComputePipeline(device: device)
        super.init()
    }
    
    static func buildRenderPipeline(device: MTLDevice) -> MTLRenderPipelineState {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        let library = device.makeDefaultLibrary()!
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
        pipelineDescriptor.colorAttachments[0] = buildColorAttachment()
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        do {
            return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Failed to create render pipeline: \(error)")
        }
    }
    
    static func buildComputePipeline(device: MTLDevice) -> MTLComputePipelineState {
        let library = device.makeDefaultLibrary()!
        let function = library.makeFunction(name: "compute_main")!
        
        do {
            return try device.makeComputePipelineState(function: function)
        } catch {
            fatalError("Failed to create compute shader pipeline: \(error)")
        }
    }
    
    static func buildTexture(device: MTLDevice, width: Int, height: Int) -> MTLTexture {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba32Float,
            width: width,
            height: height,
            mipmapped: false)
        textureDescriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        let texture = device.makeTexture(descriptor: textureDescriptor)!
        
        var initData = [Float](repeating: 0.0, count: width * height * 4) //

        for i in 0..<width * height {
            let (x, y) = (i % width, i / width)
            initData[i * 4 + 0] = Float(x) / Float(width)   // theta 0
            initData[i * 4 + 1] = Float(y) / Float(height)  // theta 1
            initData[i * 4 + 2] = 0.5                       // omega 0
            initData[i * 4 + 3] = 0.5                       // omega 1
        }
        
        let region = MTLRegionMake2D(0, 0, width, height)
        let bytesPerRow = width * 4 * MemoryLayout<Float>.size // 4 components (RGBA), 4 bytes per float
        texture.replace(region: region, mipmapLevel: 0, withBytes: initData, bytesPerRow: bytesPerRow)
       
        return texture
    }
    
    func updateMassAndLength(masses: SIMD2<Float>, lengths: SIMD2<Float>) {
        self.masses = masses
        self.lengths = lengths
        self.texture = Renderer.buildTexture(device: device, width: width, height: height)
    }
    
    func massAndLengthBuffer() -> MTLBuffer {
        let data = [masses, lengths]
        return device.makeBuffer(
            bytes: data,
            length: MemoryLayout<SIMD2<Float>>.stride * data.count,
            options: .storageModeShared
        )!
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = view.currentDrawable else {
            print("Not able to get drawable")
            return
        }
        
        guard let renderCommandBuffer = commandQueue.makeCommandBuffer(),
              let computeCommandBuffer = commandQueue.makeCommandBuffer() else {
            print("Not able to get commandBuffer")
            return
        }
       
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            print("Not able to get renderPassDescriptor")
            return
        }
        
        let computeCommandEncoder = computeCommandBuffer.makeComputeCommandEncoder()!
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        computeCommandEncoder.setTexture(texture, index: 0)
        let massAndLengthBuffer = massAndLengthBuffer()
        computeCommandEncoder.setBuffer(massAndLengthBuffer, offset: 0, index: 0)
        let gridSize = MTLSize(width: (width + 15) / 16, height: (height + 15) / 16, depth: 1)
        let threadGroupSize = MTLSize(width: 16, height: 16, depth: 1)
        computeCommandEncoder.dispatchThreadgroups(gridSize, threadsPerThreadgroup: threadGroupSize)
        
        computeCommandEncoder.endEncoding()
        computeCommandBuffer.commit()
        
        let renderCommandEncoder = renderCommandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setFragmentTexture(texture, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderCommandEncoder.endEncoding()
        
        renderCommandBuffer.present(drawable)
        renderCommandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        self.windowSize = size
    }
}
