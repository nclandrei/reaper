import AppKit

struct ProcessInfo: Identifiable {
    let pid: pid_t
    let name: String
    let cpu: Double
    let memory: UInt64
    let icon: NSImage?
    let isApp: Bool
    let parentPID: pid_t
    let bundleIdentifier: String?

    var id: pid_t { pid }
}
