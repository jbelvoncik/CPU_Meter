import Metal
import Foundation

guard let device = MTLCreateSystemDefaultDevice(),
      let queue = device.makeCommandQueue() else {
    fatalError("No Metal GPU found")
}

let shader = """
#include <metal_stdlib>
using namespace metal;
kernel void burn(device float *data [[ buffer(0) ]],
                 uint id [[ thread_position_in_grid ]]) {
    float x = (float)id;
    for (int i = 0; i < 500000; i++) {
        x = sin(x) * cos(x) + sqrt(fabs(x));
    }
    data[id] = x;
}
"""

let lib = try device.makeLibrary(source: shader, options: nil)
let fn = lib.makeFunction(name: "burn")!
let pipe = try device.makeComputePipelineState(function: fn)
let buf = device.makeBuffer(length: 1_000_000 * MemoryLayout<Float>.stride)!

print("🔥  Running GPU stress (Ctrl-C to stop)")
while true {
    autoreleasepool {
        let cmd = queue.makeCommandBuffer()!
        let enc = cmd.makeComputeCommandEncoder()!
        enc.setComputePipelineState(pipe)
        enc.setBuffer(buf, offset: 0, index: 0)
        let grid = MTLSize(width: 1_000_000, height: 1, depth: 1)
        let tg = MTLSize(width: pipe.maxTotalThreadsPerThreadgroup, height: 1, depth: 1)
        enc.dispatchThreads(grid, threadsPerThreadgroup: tg)
        enc.endEncoding()
        cmd.commit()
    }
}
