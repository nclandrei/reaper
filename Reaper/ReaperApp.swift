import SwiftUI
import KeyboardShortcuts

@main
struct ReaperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Empty scene — status item is managed by AppDelegate
        Settings { EmptyView() }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var viewModel = ProcessListViewModel()
    private var eventMonitor: Any?

    @AppStorage("menuBarMetric") var menuBarMetric: String = MenuBarMetric.memory.rawValue
    @AppStorage("cpuStyle") var cpuStyle: String = MenuBarStyle.defaultForCPU.rawValue
    @AppStorage("memoryStyle") var memoryStyle: String = MenuBarStyle.defaultForMemory.rawValue
    @AppStorage("hideMenuBarText") var hideMenuBarText: Bool = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 420, height: 580)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: ContentView(viewModel: viewModel))

        // Hotkey
        KeyboardShortcuts.reset(.togglePanel)
        KeyboardShortcuts.onKeyUp(for: .togglePanel) { [weak self] in
            self?.togglePopover()
        }

        // Close popover when clicking outside
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if self?.popover.isShown == true {
                self?.popover.performClose(nil)
            }
        }

        // Update label on timer
        updateLabel()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async { self?.updateLabel() }
        }
    }

    @objc func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func updateLabel() {
        guard let button = statusItem.button else { return }

        let metric = MenuBarMetric(rawValue: menuBarMetric) ?? .memory
        let styleRaw = metric == .cpu ? cpuStyle : memoryStyle
        let style = MenuBarStyle(rawValue: styleRaw) ?? (metric == .cpu ? .defaultForCPU : .defaultForMemory)
        let stats = viewModel.systemStats

        // Indicator image
        let fill: Double
        switch metric {
        case .cpu: fill = min(1, max(0, stats.totalCPU / 100.0))
        case .memory: fill = stats.totalMemory > 0 ? min(1, Double(stats.usedMemory) / Double(stats.totalMemory)) : 0
        }

        switch style {
        case .pillBar:    button.image = MenuBarRenderer.pillBar(fill: fill)
        case .segments:   button.image = MenuBarRenderer.segments(fill: fill)
        case .thinLine:   button.image = MenuBarRenderer.thinLine(fill: fill)
        case .ringGauge:  button.image = MenuBarRenderer.ringGauge(fill: fill)
        case .battery:    button.image = MenuBarRenderer.battery(fill: fill)
        case .dots:       button.image = MenuBarRenderer.dots(fill: fill)
        case .miniBars:
            let history = metric == .cpu ? viewModel.cpuHistory : viewModel.memoryHistory
            button.image = MenuBarRenderer.miniBars(samples: history)
        case .dualStack:
            let cpuFill = min(1, max(0, stats.totalCPU / 100.0))
            let memFill = stats.totalMemory > 0 ? min(1, Double(stats.usedMemory) / Double(stats.totalMemory)) : 0
            button.image = MenuBarRenderer.dualStack(cpu: cpuFill, mem: memFill)
        case .textOnly:
            button.image = nil
        }

        // Text
        if hideMenuBarText && style != .textOnly {
            button.title = ""
        } else {
            switch style {
            case .dualStack:
                button.title = " \(Int(stats.totalCPU))% \(Formatters.memoryShort(used: stats.usedMemory, total: stats.totalMemory))"
            case .textOnly:
                if metric == .cpu {
                    button.title = "\(Int(stats.totalCPU))%  \(Formatters.memoryShort(used: stats.usedMemory, total: stats.totalMemory))"
                } else {
                    button.title = "\(Formatters.memoryShort(used: stats.usedMemory, total: stats.totalMemory))  \(Int(stats.totalCPU))%"
                }
            default:
                switch metric {
                case .cpu:    button.title = " \(Int(stats.totalCPU))%"
                case .memory: button.title = " \(Formatters.memoryShort(used: stats.usedMemory, total: stats.totalMemory))"
                }
            }
        }

        button.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .medium)
        button.imagePosition = .imageLeading
    }
}
