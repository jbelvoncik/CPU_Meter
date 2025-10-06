//
//  OverlayView.swift
//  CPU_Meter
//
//  Minimal floating overlay with macOS glass (vibrancy) background
//  and thin white border. Displays only CPU / GPU / ANE percentages.
//
//  © 2025 Jozef Belvončik MIT License
//

import SwiftUI

// Wrapper for macOS visual effect blur
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .hudWindow
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    var state: NSVisualEffectView.State = .active

    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = material
        v.blendingMode = blendingMode
        v.state = state
        return v
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
    }
}

struct OverlayView: View {
    @StateObject private var cpu = CPUUsageSampler()
    @StateObject private var gpuane = GPUANESampler()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            metricRow(label: "CPU", value: cpu.overall * 100)
            metricRow(label: "GPU", value: gpuane.gpuPercent)
            metricRow(label: "ANE", value: gpuane.anePercent)
        }
        .font(.system(size: 20, weight: .bold, design: .rounded))
        .foregroundColor(.white)
        .padding(20)
        .frame(minWidth: 160)
        .background(
            VisualEffectBlur(material: .hudWindow)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
        )
    }

    private func metricRow(label: String, value: Double) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value.isNaN || value.isZero ? "-- %" :
                 String(format: "%.0f %%", value))
        }
        .monospacedDigit()
        .frame(width: 160)
    }
}
