//
//  DoublePendulumApp.swift
//  DoublePendulum
//
//  Created by Tim Hau on 28.10.24.
//

import SwiftUI

@main
struct DoublePendulumApp: App {
    @State private var windowWidth: CGFloat = 900
    @State private var windowHeight: CGFloat = 900
    
    @State private var L1: Float = 1.0
    @State private var L2: Float = 1.0
    @State private var m1: Float = 1.0
    @State private var m2: Float = 1.0
    
    var body: some Scene {
        WindowGroup("Main Window") {
            ContentView(width: $windowWidth, height: $windowHeight, L1: $L1, L2: $L2, m1: $m1, m2: $m2)
                .frame(width: windowWidth, height: windowHeight)
        }
        .windowResizability(.contentSize)
        
        WindowGroup("Controls", id: "Controls") {
            ControlsView(L1: $L1, L2: $L2, m1: $m1, m2: $m2)
                .frame(width: 500)
                .padding(50)
        }
        .windowResizability(.contentMinSize)
    }
}
