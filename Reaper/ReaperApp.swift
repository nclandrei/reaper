import SwiftUI
import KeyboardShortcuts
import ServiceManagement

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
    private let updaterService = UpdaterService()
    private var eventMonitor: Any?

    @AppStorage("menuBarStyle") var menuBarStyleRaw: String = MenuBarStyle.skull.rawValue

    private let settingsViewModel = SettingsViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Enable launch at login on first install
        settingsViewModel.enableLaunchAtLoginOnFirstLaunch()

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
        popover.contentViewController = NSHostingController(rootView: ContentView(viewModel: viewModel, settingsViewModel: settingsViewModel, updaterService: updaterService))

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

        let style = MenuBarStyle(rawValue: menuBarStyleRaw) ?? .skull
        let stats = viewModel.systemStats
        let fill = min(1, max(0, stats.totalCPU / 100.0))

        switch style {
        case .skull:      button.image = MenuBarRenderer.skull(fill: fill)
        case .pillBar:    button.image = MenuBarRenderer.pillBar(fill: fill)
        case .segments:   button.image = MenuBarRenderer.segments(fill: fill)
        case .thinLine:   button.image = MenuBarRenderer.thinLine(fill: fill)
        case .ringGauge:  button.image = MenuBarRenderer.ringGauge(fill: fill)
        case .battery:    button.image = MenuBarRenderer.battery(fill: fill)
        case .dots:       button.image = MenuBarRenderer.dots(fill: fill)
        case .miniBars:   button.image = MenuBarRenderer.miniBars(samples: viewModel.cpuHistory)
        case .dualStack:  button.image = MenuBarRenderer.dualStack(cpu: fill, mem: 0)
        case .textOnly:   button.image = nil
        }

        // Skull shows no text, others show CPU%
        if style == .skull {
            button.title = ""
        } else if style == .textOnly {
            button.title = "\(Int(stats.totalCPU))%"
        } else {
            button.title = " \(Int(stats.totalCPU))%"
        }

        button.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .medium)
        button.imagePosition = .imageLeading
    }
}
