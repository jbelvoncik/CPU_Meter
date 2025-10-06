import SwiftUI

struct OverlayView: View {
    @StateObject private var cpu = CPUUsageSampler()
    @StateObject private var gpuane = GPUANESampler()

    private func color(for percent: Double) -> Color {
        switch percent {
        case 0..<50: return .green
        case 50..<80: return .yellow
        default: return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            let cpuValue = cpu.overall * 100
            let gpuValue = gpuane.gpuPercent
            let aneValue = gpuane.anePercent

            metricRow(label: "CPU", value: cpuValue, color: color(for: cpuValue))
            metricRow(label: "GPU", value: gpuValue, color: color(for: gpuValue))
            metricRow(label: "ANE", value: aneValue, color: color(for: aneValue))
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
