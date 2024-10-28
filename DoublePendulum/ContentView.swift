//
//  ContentView.swift
//  DoublePendulum
//
//  Created by Tim Hau on 28.10.24.
//

import SwiftUI
import MetalKit
import simd

struct ContentView: NSViewRepresentable {
    @Binding var width: CGFloat
    @Binding var height: CGFloat
    @Binding var L1: Float
    @Binding var L2: Float
    @Binding var m1: Float
    @Binding var m2: Float
    @Environment(\.openWindow) private var openWindow

    func makeCoordinator() -> Renderer {
//        openWindow(id: "Controls")
        return Renderer(width: Int(width), height: Int(height))
    }
    
    func makeNSView(context: NSViewRepresentableContext<ContentView>) -> MTKView {
        let view = MTKView()
        view.frame = .zero
        view.device = context.coordinator.device
        view.preferredFramesPerSecond = 60
        view.enableSetNeedsDisplay = true
        view.framebufferOnly = false
        view.isPaused = false
        view.depthStencilPixelFormat = .depth32Float
        view.colorPixelFormat = .bgra8Unorm
        view.delegate = context.coordinator
        return view
    }
    
    func updateNSView(_ uiView: MTKView, context: NSViewRepresentableContext<ContentView>) {
        let masses = SIMD2<Float>(m1, m2)
        let lengths = SIMD2<Float>(L1, L2)
        context.coordinator.updateMassAndLength(masses: masses, lengths: lengths)
    }
}
