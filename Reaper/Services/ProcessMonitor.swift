import Foundation
import AppKit

final class ProcessMonitor {
    private var previousSamples: [pid_t: (cpuTime: UInt64, timestamp: TimeInterval)] = [:]
    private let machTimeToNanos: Double = {
        var info = mach_timebase_info_data_t()
        mach_timebase_info(&info)
        return Double(info.numer) / Double(info.denom)
    }()

    func refresh() -> [ProcessInfo] {
        let uid = getuid()
        let rawProcs = enumerateProcesses(uid: uid)
        let now = Date().timeIntervalSince1970
        let runningApps = NSWorkspace.shared.runningApplications
        let appsByPID = Dictionary(
            runningApps.map { ($0.processIdentifier, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        var result: [ProcessInfo] = []

        for raw in rawProcs {
            let cpuTime = raw.cpuUser + raw.cpuSystem
            var cpuPercent = 0.0

            if let prev = previousSamples[raw.pid] {
                let dt = now - prev.timestamp
                if dt > 0 {
                    let delta = cpuTime >= prev.cpuTime ? cpuTime - prev.cpuTime : 0
                    let deltaNanos = Double(delta) * machTimeToNanos
                    cpuPercent = (deltaNanos / 1_000_000_000.0) / dt * 100.0
                    cpuPercent = max(0, min(cpuPercent, 10000))
                }
            }

            previousSamples[raw.pid] = (cpuTime, now)

            let app = appsByPID[raw.pid]
            let isApp = app?.activationPolicy == .regular

            let processPath = app != nil ? nil : executablePath(for: raw.pid)

            result.append(ProcessInfo(
                pid: raw.pid,
                name: app?.localizedName ?? raw.name,
                cpu: cpuPercent,
                memory: raw.memory,
                icon: app?.icon,
                isApp: isApp,
                parentPID: raw.parentPID,
                bundleIdentifier: app?.bundleIdentifier,
                path: processPath
            ))
        }

        let activePIDs = Set(rawProcs.map(\.pid))
        previousSamples = previousSamples.filter { activePIDs.contains($0.key) }

        return result
    }

    // MARK: - Private

    /// Returns the executable path and arguments for a process using KERN_PROCARGS2.
    /// This is the same approach Activity Monitor uses to show full command info.
    private func executablePath(for pid: pid_t) -> String? {
        var mib: [Int32] = [CTL_KERN, KERN_PROCARGS2, pid]
        var size = 0
        guard sysctl(&mib, 3, nil, &size, nil, 0) == 0, size > 0 else { return nil }

        var buffer = [UInt8](repeating: 0, count: size)
        guard sysctl(&mib, 3, &buffer, &size, nil, 0) == 0, size > 4 else { return nil }

        // First 4 bytes: argc
        let argc = buffer.withUnsafeBufferPointer {
            $0.baseAddress!.withMemoryRebound(to: Int32.self, capacity: 1) { $0.pointee }
        }

        // After argc: null-terminated exec_path, then padding nulls, then argv[0..argc-1]
        var offset = 4

        // Skip exec_path
        while offset < size && buffer[offset] != 0 { offset += 1 }
        // Skip trailing nulls
        while offset < size && buffer[offset] == 0 { offset += 1 }

        // Collect up to argc args (but cap at 4 to avoid huge strings)
        var args: [String] = []
        let maxArgs = min(Int(argc), 4)
        for _ in 0..<maxArgs {
            guard offset < size else { break }
            let start = offset
            while offset < size && buffer[offset] != 0 { offset += 1 }
            if let arg = String(bytes: buffer[start..<offset], encoding: .utf8) {
                args.append(arg)
            }
            offset += 1 // skip null
        }

        return args.isEmpty ? nil : args.joined(separator: " ")
    }

    private struct RawProcess {
        let pid: pid_t
        let parentPID: pid_t
        let name: String
        let cpuUser: UInt64
        let cpuSystem: UInt64
        let memory: UInt64
    }

    private func enumerateProcesses(uid: uid_t) -> [RawProcess] {
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_UID, Int32(uid)]
        var size = 0
        guard sysctl(&mib, 4, nil, &size, nil, 0) == 0, size > 0 else { return [] }

        let count = size / MemoryLayout<kinfo_proc>.stride
        var kprocs = [kinfo_proc](repeating: kinfo_proc(), count: count)
        guard sysctl(&mib, 4, &kprocs, &size, nil, 0) == 0 else { return [] }

        let actual = size / MemoryLayout<kinfo_proc>.stride
        var results: [RawProcess] = []
        results.reserveCapacity(actual)

        for i in 0..<actual {
            let kp = kprocs[i]
            let pid = kp.kp_proc.p_pid
            guard pid > 0 else { continue }

            var nameBuffer = [CChar](repeating: 0, count: 256)
            proc_name(pid, &nameBuffer, 256)
            let name = String(cString: nameBuffer)
            guard !name.isEmpty else { continue }

            var taskInfo = proc_taskinfo()
            let infoSize = Int32(MemoryLayout<proc_taskinfo>.size)
            let ret = proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &taskInfo, infoSize)
            guard ret == infoSize else { continue }

            results.append(RawProcess(
                pid: pid,
                parentPID: kp.kp_eproc.e_ppid,
                name: name,
                cpuUser: taskInfo.pti_total_user,
                cpuSystem: taskInfo.pti_total_system,
                memory: taskInfo.pti_resident_size
            ))
        }

        return results
    }
}
