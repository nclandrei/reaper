import AppKit

enum ProcessKiller {
    enum KillResult {
        case success
        case accessDenied
        case notFound
        case failed(String)

        var message: String {
            switch self {
            case .success: return "Process terminated"
            case .accessDenied: return "Access denied"
            case .notFound: return "Process not found"
            case .failed(let msg): return msg
            }
        }
    }

    static func quit(pid: pid_t) -> KillResult {
        if let app = NSRunningApplication(processIdentifier: pid), app.terminate() {
            return .success
        }
        return sendSignal(pid: pid, signal: SIGTERM)
    }

    static func forceKill(pid: pid_t) -> KillResult {
        if let app = NSRunningApplication(processIdentifier: pid), app.forceTerminate() {
            return .success
        }
        return sendSignal(pid: pid, signal: SIGKILL)
    }

    static func killGroup(_ group: ProcessGroup) -> [pid_t: KillResult] {
        var results: [pid_t: KillResult] = [:]
        let helpers = group.children.filter { $0.pid != group.id }
        let parent = group.children.first { $0.pid == group.id }
        for helper in helpers {
            results[helper.pid] = forceKill(pid: helper.pid)
        }
        if let parent = parent {
            results[parent.pid] = forceKill(pid: parent.pid)
        }
        return results
    }

    private static func sendSignal(pid: pid_t, signal: Int32) -> KillResult {
        if kill(pid, signal) == 0 {
            return .success
        }
        switch errno {
        case EPERM: return .accessDenied
        case ESRCH: return .notFound
        default: return .failed(String(cString: strerror(errno)))
        }
    }
}
