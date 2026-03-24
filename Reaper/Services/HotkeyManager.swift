import AppKit
import Carbon

final class HotkeyManager {
    static let shared = HotkeyManager()

    private var globalMonitor: Any?
    private var localMonitor: Any?

    // Default: ⌥⇧R (Option+Shift+R)
    // R keyCode = 15
    private let keyCode: UInt16 = 15
    private let modifiers: NSEvent.ModifierFlags = [.option, .shift]

    func register() {
        // Global monitor (when app is not focused)
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }

        // Local monitor (when app is focused)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyEvent(event) == true {
                return nil // consume the event
            }
            return event
        }
    }

    func unregister() {
        if let globalMonitor { NSEvent.removeMonitor(globalMonitor) }
        if let localMonitor { NSEvent.removeMonitor(localMonitor) }
        globalMonitor = nil
        localMonitor = nil
    }

    @discardableResult
    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        guard event.keyCode == keyCode,
              event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(modifiers)
        else { return false }

        togglePanel()
        return true
    }

    private func togglePanel() {
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
