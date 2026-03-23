import Foundation
import Darwin

struct SystemStats {
    var totalCPU: Double = 0
    var usedMemory: UInt64 = 0
    var totalMemory: UInt64 = 0

    private static var previousTicks: (user: UInt32, system: UInt32, idle: UInt32, nice: UInt32)?

    static func current() -> SystemStats {
        var stats = SystemStats()

        // Total physical memory
        var memSize: UInt64 = 0
        var memSizeLen = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &memSize, &memSizeLen, nil, 0)
        stats.totalMemory = memSize

        // VM statistics for active + wired memory
        let host = mach_host_self()
        var vmInfo = vm_statistics64()
        var vmCount = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size
        )
        let vmResult = withUnsafeMutablePointer(to: &vmInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(vmCount)) {
                host_statistics64(host, HOST_VM_INFO64, $0, &vmCount)
            }
        }
        if vmResult == KERN_SUCCESS {
            let pageSize = UInt64(vm_page_size)
            stats.usedMemory = (UInt64(vmInfo.active_count) + UInt64(vmInfo.wire_count)) * pageSize
        }

        // CPU load ticks
        var cpuInfo = host_cpu_load_info()
        var cpuCount = mach_msg_type_number_t(
            MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size
        )
        let cpuResult = withUnsafeMutablePointer(to: &cpuInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(cpuCount)) {
                host_statistics(host, HOST_CPU_LOAD_INFO, $0, &cpuCount)
            }
        }
        if cpuResult == KERN_SUCCESS {
            let user = cpuInfo.cpu_ticks.0
            let system = cpuInfo.cpu_ticks.1
            let idle = cpuInfo.cpu_ticks.2
            let nice = cpuInfo.cpu_ticks.3

            if let prev = previousTicks {
                let ud = Double(user &- prev.user)
                let sd = Double(system &- prev.system)
                let id = Double(idle &- prev.idle)
                let nd = Double(nice &- prev.nice)
                let total = ud + sd + id + nd
                if total > 0 {
                    stats.totalCPU = ((ud + sd + nd) / total) * 100.0
                }
            }
            previousTicks = (user, system, idle, nice)
        }

        return stats
    }
}
