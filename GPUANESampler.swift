import Foundation
import Combine

final class GPUANESampler: ObservableObject {
    @Published var gpuPercent: Double = 0
    @Published var anePercent: Double = 0
    private var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.update()
        }
    }

    private func update() {
        // Run ioreg once and collect lines mentioning GPU/ANE power sensors
        let task = Process()
        task.launchPath = "/usr/sbin/ioreg"
        task.arguments = ["-r", "-c", "AppleARMIODevice"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = nil
        try? task.run()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return }

        // Simple heuristic: count ANE vs GPU lines to simulate load
        let aneLines = output.components(separatedBy: "\n").filter { $0.contains("H11ANE") }.count
        let gpuLines = output.components(separatedBy: "\n").filter { $0.contains("AppleARMPMUPowerSensor") }.count

        // Normalize to rough 0–100%
        let aneVal = min(Double(aneLines) / 30.0 * 100.0, 100)
        let gpuVal = min(Double(gpuLines) / 300.0 * 100.0, 100)

        DispatchQueue.main.async {
            self.anePercent = aneVal
            self.gpuPercent = gpuVal
        }
    }
}
