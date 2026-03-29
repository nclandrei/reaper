import AppKit

struct ProcessGroup: Identifiable {
    let id: pid_t
    let name: String
    let icon: NSImage?
    var children: [ProcessInfo]
    let isApp: Bool

    var totalCPU: Double {
        children.reduce(0) { $0 + $1.cpu }
    }

    var totalMemory: UInt64 {
        children.reduce(0) { $0 + $1.memory }
    }

    var helperCount: Int {
        max(0, children.count - 1)
    }

    var isBackground: Bool {
        id == -1
    }

    var threatScore: Double {
        totalCPU * 2 + Double(totalMemory) / 1_073_741_824 * 10
    }

    var heatLevel: HeatLevel {
        HeatLevel.forProcess(cpu: totalCPU, memory: totalMemory)
    }
}
