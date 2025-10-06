import SwiftUI

struct OverlayView: View {
    @StateObject private var cpu = CPUUsageSampler()
    @StateObject private var gpuane = GPUANESampler()

    // Color scale: green → yellow → red
    private func color(for value: Double) -> Color {
        switch value {
        case 0..<50: return .green
        case 50..<80: return .yellow
        default: return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            metricRow(label: "CPU", value: cpu.overall * 100, color: color(for: cpu.overall * 100))
            metricRow(label: "GPU", value: gpuane.gpuPercent, color: color(for: gpuane.gpuPercent))
            metricRow(label: "ANE", value: gpuane.anePercent, color: color(for: gpuane.anePercent))
        }
        .font(.system(size: 18, weight: .bold, design: .rounded))
        .padding(16)
        .frame(minWidth: 180)
        .background(.black.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func metricRow(label: String, value: Double, color: Color) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value.isNaN ? "-- %" : String(format: "%.0f %%", value))
                .foregroundColor(color)
        }
        .monospacedDigit()
    }
}
