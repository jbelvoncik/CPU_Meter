import Foundation

@MainActor
class GPUANESampler: ObservableObject {
    @Published var gpuPercent: Double = 0
    @Published var anePercent: Double = 0

    private var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateMetrics()
        }
    }

    private func updateMetrics() {
        let task = Process()
        task.launchPath = "/usr/sbin/ioreg"
        task.arguments = ["-r", "-c", "IOReporters"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return }

        // GPU heuristic using IOReporters
        if output.contains("GPU") {
            let lines = output.split(separator: "\n").filter { $0.contains("GPU") }
            var busy: Double = 0
            var total: Double = 0
            for line in lines {
                if line.contains("Busy") { busy += 1 }
                total += 1
            }
            gpuPercent = total > 0 ? (busy / total * 100.0) : 0
        }

        // ANE heuristic
        let aneLines = output.split(separator: "\n").filter { $0.contains("ANE") }
        let aneVal = min(Double(aneLines.count) / 20.0 * 100.0, 100.0)
        DispatchQueue.main.async {
            self.anePercent = aneVal
        }
    }
}
