//
//  OverlayView.swift
//  CPU_Meter
//
//  Combines CPU, GPU, and ANE metrics in a resizable overlay window.
//  Uses fixed-width text formatting to prevent clipping at startup.
//
//  © 2025 Jozef Belvončik MIT License
//

import SwiftUI

struct OverlayView: View {
    @StateObject private var cpu = CPUUsageSampler()
    @StateObject private var gpuane = GPUANESampler()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            metricRow(label: "CPU", value: cpu.overall * 100)
            metricRow(label: "GPU", value: gpuane.gpuPercent)
            metricRow(label: "ANE", value: gpuane.anePercent)
        }
        .font(.system(size: 18, weight: .bold, design: .rounded))
        .foregroundColor(.white)
        .frame(minWidth: 160, minHeight: 100)
        .padding(16)
        .background(.black.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func metricRow(label: String, value: Double) -> some View {
        HStack {
            Text(label)
            Spacer()
            if value.isNaN || value.isZero {
                Text("-- %")
            } else {
                Text(String(format: "%.0f %%", value))
            }
        }
        .frame(width: 120)
        .monospacedDigit()
    }
}
