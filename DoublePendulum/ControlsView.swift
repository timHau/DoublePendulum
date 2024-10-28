//
//  ControlsView.swift
//  DoublePendulum
//
//  Created by Tim Hau on 28.10.24.
//
import SwiftUI

struct ControlsView: View {
    @Binding var L1: Float
    @Binding var L2: Float
    @Binding var m1: Float
    @Binding var m2: Float

    var body: some View {
        VStack {
            Slider(value: $L1, in: 0.01...10.0, step: 0.5) {
                Text("Length 1: \(String(format: "%.2f", L1))")
            }
            .padding()
            Slider(value: $L2, in: 0.01...10.0, step: 0.5) {
                Text("Length 2: \(String(format: "%.2f", L2))")
            }
            .padding()
            Slider(value: $m1, in: 0.5...5.0, step: 0.5) {
                Text("Mass 1: \(String(format: "%.2f", m1))")
            }
            .padding()
            Slider(value: $m2, in: 0.5...5.0, step: 0.5) {
                Text("Mass 2: \(String(format: "%.2f", m2))")
            }
            .padding()
        }
    }
}
