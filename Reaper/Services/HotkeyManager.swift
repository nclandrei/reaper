import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let togglePanel = Self("togglePanel", default: .init(.r, modifiers: [.option, .shift]))
}

final class HotkeyManager {
    static let shared = HotkeyManager()

    func register() {
        KeyboardShortcuts.onKeyUp(for: .togglePanel) { [weak self] in
            self?.togglePanel()
        }
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
