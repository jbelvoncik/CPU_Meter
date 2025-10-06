//
//  OverlayView.swift
//  CPU_Meter
//
//  Combines CPU, GPU, and ANE data into one live overlay.
//  GPU/ANE are power-based approximations from powermetrics --samplers smc.
//
//  © 2025 Jozef Belvončik MIT License
//

import SwiftUI

struct OverlayView: View {
    @StateObject private var cpu = CPUUsageSampler()
    @StateObject private var gpuane = GPUANESampler()

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(format: "CPU %.0f %%", cpu.overall * 100))
            Text(String(format: "GPU %.0f %%", gpuane.gpuPercent))
            Text(String(format: "ANE %.0f %%", gpuane.anePercent))
        }
        .font(.system(size: 18, weight: .bold, design: .rounded))
        .foregroundColor(.white)
        .padding(16)
        .background(.black.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
