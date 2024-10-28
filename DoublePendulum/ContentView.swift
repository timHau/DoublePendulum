//
//  ContentView.swift
//  DoublePendulum
//
//  Created by Tim Hau on 28.10.24.
//

import SwiftUI
import MetalKit

struct ContentView: NSViewRepresentable {
    @Binding var width: CGFloat
    @Binding var height: CGFloat
    @Environment(\.openWindow) private var openWindow

    func makeCoordinator() -> Renderer {
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
    }
}
