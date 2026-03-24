import AppKit

final class HotkeyManager {
    static let shared = HotkeyManager()

    private var globalMonitor: Any?

    // Default: ⌥⇧R (Option+Shift+R), keyCode 15
    private let keyCode: UInt16 = 15
    private let modifiers: NSEvent.ModifierFlags = [.option, .shift]

    func register() {
        guard globalMonitor == nil else { return }

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }
    }

    func unregister() {
        if let globalMonitor { NSEvent.removeMonitor(globalMonitor) }
        globalMonitor = nil
    }

    private func handleKeyEvent(_ event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard event.keyCode == keyCode,
              flags.contains(.option),
              flags.contains(.shift)
        else { return }

        togglePanel()
    }

    private func togglePanel() {
        DispatchQueue.main.async {
            let script = NSAppleScript(source: """
                tell application "System Events"
                    tell process "Reaper"
                        click menu bar item 1 of menu bar 2
                    end tell
                end tell
            """)
            var error: NSDictionary?
            script?.executeAndReturnError(&error)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        HotkeyManager.shared.register()
    }
}
