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
    let path: String?

    var id: pid_t { pid }

    func matchesSearch(_ query: String) -> Bool {
        let q = query.lowercased()
        if name.lowercased().contains(q) { return true }
        if let path = path, path.lowercased().contains(q) { return true }
        return false
    }
}
