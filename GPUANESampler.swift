import Foundation
import Combine

@MainActor
final class GPUANESampler: ObservableObject {
    @Published var gpuPercent: Double = 0
    @Published var anePercent: Double = 0

    private var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { await self.sample() }
        }
    }

    private func countSensors() -> (gpu: Int, ane: Int) {
        let task = Process()
        task.launchPath = "/usr/sbin/ioreg"
        task.arguments = ["-r", "-c", "AppleARMIODevice"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = nil
        try? task.run()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return (0, 0) }

        let gpuCount = output.components(separatedBy: "AppleARMPMUPowerSensor").count
        let aneCount = output.components(separatedBy: "H11ANE").count
        return (gpuCount, aneCount)
    }

    private func deltaRatio(_ new: Int, _ old: Int, max: Double) -> Double {
        let diff = abs(Double(new - old))
        return min(diff / max * 100.0, 100.0)
    }

    private var prevGPU = 0
    private var prevANE = 0

    private func sample() async {
        let current = countSensors()
        let gpuVal = deltaRatio(current.gpu, prevGPU, max: 50)
        let aneVal = deltaRatio(current.ane, prevANE, max: 5)
        prevGPU = current.gpu
        prevANE = current.ane

        await MainActor.run {
            self.gpuPercent = gpuVal
            self.anePercent = aneVal
        }
    }
}
