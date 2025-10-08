import Foundation
import Combine

final class GPUANESampler: ObservableObject {
    @Published var gpuPercent: Double = 0
    @Published var anePercent: Double = 0

    private var timer: Timer?

    init() {
        startSampling()
    }

    func startSampling() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.updateMetrics()
        }
    }

    private func updateMetrics() {
        let process = Process()
        process.launchPath = "/usr/sbin/ioreg"
        process.arguments = ["-r", "-n", "AGXAccelerator"]

        let pipe = Pipe()
        process.standardOutput = pipe
        try? process.run()
        process.waitUntilExit()

        guard let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(),
                                  encoding: .utf8) else { return }

        if let match = output.range(of: #"\"gpu_busy\" = ([0-9]+)"#, options: .regularExpression) {
            let value = Double(output[match].split(separator: " ").last ?? "0") ?? 0
            DispatchQueue.main.async {
                self.gpuPercent = min(100.0, value)
            }
        } else if let match = output.range(of: #"\"GPU Busy\" = ([0-9]+)"#, options: .regularExpression) {
            let value = Double(output[match].split(separator: " ").last ?? "0") ?? 0
            DispatchQueue.main.async {
                self.gpuPercent = min(100.0, value)
            }
        } else {
            DispatchQueue.main.async {
                self.gpuPercent = 0
            }
        }

        DispatchQueue.main.async {
            self.anePercent = 0
        }
    }
}
