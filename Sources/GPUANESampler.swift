import Foundation
import Combine

class GPUANESampler: ObservableObject {
    @Published var gpuPercent: Double = 0
    @Published var anePercent: Double = 0

    private var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.updateMetrics()
        }
    }

    private func updateMetrics() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/powermetrics")
        process.arguments = ["-n", "1", "--show-process-gpu"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = nil

        do {
            try process.run()
        } catch {
            print("Failed to start powermetrics: \(error)")
            return
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return }

        // Parse GPU Power and frequency
        if let line = output.split(separator: "\n").first(where: { $0.contains("GPU HW active residency") }) {
            if let percent = line.components(separatedBy: .whitespaces)
                .compactMap({ Double($0.replacingOccurrences(of: "%", with: "")) })
                .first {
                DispatchQueue.main.async {
                    self.gpuPercent = percent
                }
            }
        }

        // Parse ANE Power (rough)
        if let line = output.split(separator: "\n").first(where: { $0.contains("ANE Power:") }) {
            if let mw = line.split(separator: " ").compactMap({ Double($0) }).first {
                DispatchQueue.main.async {
                    self.anePercent = mw / 1000.0
                }
            }
        }
    }
}
