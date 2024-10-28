//
//  ControlsView.swift
//  DoublePendulum
//
//  Created by Tim Hau on 28.10.24.
//
import SwiftUI

struct ControlsView: View {
    @State private var gravity: Float = 9.81
    @State private var L1: Float = 1.0
    @State private var L2: Float = 1.0
    @State private var m1: Float = 1.0
    @State private var m2: Float = 1.0

    var body: some View {
        VStack {
            HStack {
                Text("Gravity: \(String(format: "%.2f", gravity))")
                Slider(value: $gravity, in: 0.0...15.0, step: 0.1)
            }
            HStack{
                Text("Length 1: \(String(format: "%.2f", L1))")
                Slider(value: $L1, in: 0.01...15.0, step: 0.1)
            }
            HStack {
                Text("Length 1: \(String(format: "%.2f", L2))")
                Slider(value: $L2, in: 0.01...15.0, step: 0.1)
            }
            HStack {
                Text("Mass 1: \(String(format: "%.2f", m1))")
                Slider(value: $m1, in: 0.5...5.0, step: 0.5)
            }
            HStack {
                Text("Mass 2: \(String(format: "%.2f", m2))")
                Slider(value: $m2, in: 0.5...5.0, step: 0.5)
            }
        }
    }
}
