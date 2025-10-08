import Foundation
import IOKit

final class GPUANESampler: ObservableObject {
    static let shared = GPUANESampler()
    @Published var gpuPercent: Double = 0
    @Published var anePercent: Double = 0

    private var timer: Timer?

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.update()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func update() {
        var load: Double = 0

        if let gpuGroup = IOReportCopyChannelsInGroup("GPU Stats" as CFString, 0)?.takeRetainedValue() as? [CFDictionary] {
            for entry in gpuGroup {
                let dict = entry as NSDictionary
                if let samples = dict["IOReportCurrentValue"] as? Double,
                   let name = dict["IOReportChannelName"] as? String,
                   name.lowercased().contains("busy") {
                    load = max(load, samples)
                }
            }
        }

        DispatchQueue.main.async {
            self.gpuPercent = min(100.0, load)
            self.anePercent = 0 // placeholder for Neural Engine
        }
    }
}
