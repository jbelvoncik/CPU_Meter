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
        var iterator: io_iterator_t = 0
        var totalBusy: Double = 0
        var count: Double = 0

        if IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IOAccelerator"), &iterator) == KERN_SUCCESS {
            var service = IOIteratorNext(iterator)
            while service != 0 {
                if let props = getProperties(service),
                   let perf = props["PerformanceStatistics"] as? [String: Any],
                   let busy = perf["GPU Busy"] as? Double {
                    totalBusy += busy
                    count += 1
                }
                IOObjectRelease(service)
                service = IOIteratorNext(iterator)
            }
            IOObjectRelease(iterator)
        }

        DispatchQueue.main.async {
            self.gpuPercent = count > 0 ? min(100.0, totalBusy / count) : 0
            self.anePercent = 0 // placeholder until public ANE telemetry exists
        }
    }

    private func getProperties(_ service: io_service_t) -> [String: Any]? {
        var props: Unmanaged<CFMutableDictionary>?
        guard IORegistryEntryCreateCFProperties(service, &props, kCFAllocatorDefault, 0) == KERN_SUCCESS,
              let dict = props?.takeRetainedValue() as? [String: Any] else { return nil }
        return dict
    }
}
