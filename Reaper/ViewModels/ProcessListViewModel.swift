import SwiftUI
import Combine

@MainActor
final class ProcessListViewModel: ObservableObject {
    @Published var groups: [ProcessGroup] = []
    @Published var searchText = ""
    @Published var sortOrder: SortOrder = .cpu
    @Published var systemStats = SystemStats()
    @Published var expandedGroups: Set<pid_t> = []
    @Published var cpuHistory: [Double] = []
    @Published var memoryHistory: [Double] = []

    private let historySize = 20
    private let monitor = ProcessMonitor()
    private var timer: Timer?
    private let ownPID = getpid()

    @AppStorage("refreshInterval") var refreshInterval: Double = 3.0 {
        didSet { startTimer() }
    }

    init() {
        startTimer()
    }

    deinit {
        timer?.invalidate()
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
        refresh()
    }

    func refresh() {
        let processes = monitor.refresh()
        systemStats = SystemStats.current()

        cpuHistory.append(systemStats.totalCPU)
        if cpuHistory.count > historySize { cpuHistory.removeFirst() }
        let memPct = systemStats.totalMemory > 0
            ? Double(systemStats.usedMemory) / Double(systemStats.totalMemory) * 100.0 : 0
        memoryHistory.append(memPct)
        if memoryHistory.count > historySize { memoryHistory.removeFirst() }

        var grouped = buildGroups(from: processes)
        grouped = applySearch(to: grouped)
        grouped = applySorting(to: grouped)

        withAnimation(.easeOut(duration: 0.15)) {
            groups = grouped
        }
    }

    func toggleExpanded(_ groupID: pid_t) {
        withAnimation(.easeOut(duration: 0.15)) {
            if expandedGroups.contains(groupID) {
                expandedGroups.remove(groupID)
            } else {
                expandedGroups.insert(groupID)
            }
        }
    }

    func killProcess(pid: pid_t) {
        _ = ProcessKiller.quit(pid: pid)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.refresh()
        }
    }

    func forceKillProcess(pid: pid_t) {
        _ = ProcessKiller.forceKill(pid: pid)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.refresh()
        }
    }

    func killGroup(_ group: ProcessGroup) {
        _ = ProcessKiller.killGroup(group)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.refresh()
        }
    }

    // MARK: - Grouping

    private func buildGroups(from processes: [ProcessInfo]) -> [ProcessGroup] {
        let filtered = processes.filter { $0.pid != ownPID }
        let processByPID = Dictionary(filtered.map { ($0.pid, $0) }, uniquingKeysWith: { a, _ in a })

        let apps = filtered.filter { $0.isApp }
        let nonApps = filtered.filter { !$0.isApp }

        var assigned = Set<pid_t>()
        var groups: [ProcessGroup] = []

        for app in apps {
            var children = [app]
            assigned.insert(app.pid)

            // Match helpers by walking parent PID chain
            for helper in nonApps where !assigned.contains(helper.pid) {
                if isChild(helper, of: app.pid, processByPID: processByPID) {
                    children.append(helper)
                    assigned.insert(helper.pid)
                }
            }

            // Fallback: bundle ID prefix matching
            if let appBundle = app.bundleIdentifier {
                for helper in nonApps where !assigned.contains(helper.pid) {
                    if let helperBundle = helper.bundleIdentifier,
                       helperBundle.hasPrefix(appBundle) {
                        children.append(helper)
                        assigned.insert(helper.pid)
                    }
                }
            }

            groups.append(ProcessGroup(
                id: app.pid,
                name: app.name,
                icon: app.icon,
                children: children,
                isApp: true
            ))
        }

        // Background catch-all
        let unassigned = nonApps.filter { !assigned.contains($0.pid) }
        if !unassigned.isEmpty {
            groups.append(ProcessGroup(
                id: -1,
                name: "Background",
                icon: NSImage(systemSymbolName: "gearshape.2", accessibilityDescription: nil),
                children: unassigned,
                isApp: false
            ))
        }

        return groups
    }

    private func isChild(_ process: ProcessInfo, of parentPID: pid_t, processByPID: [pid_t: ProcessInfo]) -> Bool {
        var visited = Set<pid_t>()
        var current = process.parentPID

        while current > 0 && !visited.contains(current) {
            if current == parentPID { return true }
            visited.insert(current)
            current = processByPID[current]?.parentPID ?? 0
        }

        return false
    }

    // MARK: - Search & Sort

    private func applySearch(to groups: [ProcessGroup]) -> [ProcessGroup] {
        guard !searchText.isEmpty else { return groups }
        let query = searchText.lowercased()
        return groups.compactMap { group in
            if group.name.lowercased().contains(query) {
                return group
            }
            let matched = group.children.filter { $0.name.lowercased().contains(query) }
            guard !matched.isEmpty else { return nil }
            var g = group
            g.children = matched
            return g
        }
    }

    private func applySorting(to groups: [ProcessGroup]) -> [ProcessGroup] {
        let sortChildren: ([ProcessInfo]) -> [ProcessInfo] = { children in
            switch self.sortOrder {
            case .cpu:    return children.sorted { $0.cpu > $1.cpu }
            case .memory: return children.sorted { $0.memory > $1.memory }
            case .name:   return children.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
            }
        }

        var sorted: [ProcessGroup]
        switch sortOrder {
        case .cpu:    sorted = groups.sorted { $0.totalCPU > $1.totalCPU }
        case .memory: sorted = groups.sorted { $0.totalMemory > $1.totalMemory }
        case .name:   sorted = groups.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        }

        return sorted.map { var g = $0; g.children = sortChildren(g.children); return g }
    }
}
