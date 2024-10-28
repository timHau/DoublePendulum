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
    
    var body: some Scene {
        WindowGroup("Main Window") {
            ContentView(width: $windowWidth, height: $windowHeight)
                .frame(width: windowWidth, height: windowHeight)
        }
        .windowResizability(.contentSize)
    }
}
