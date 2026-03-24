import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let togglePanel = Self("togglePanel", default: .init(.r, modifiers: [.option, .shift]))
}

final class HotkeyManager {
    static let shared = HotkeyManager()

    func register() {
        KeyboardShortcuts.onKeyUp(for: .togglePanel) {
            Self.togglePanel()
        }
    }

    static func togglePanel() {
        DispatchQueue.main.async {
            // Find the status bar button and click it
            for window in NSApp.windows where window.className.contains("NSStatusBar") {
                (window.contentView as? NSControl)?.performClick(nil)
                return
            }

            // Fallback: find any MenuBarExtra panel and toggle
            for window in NSApp.windows {
                let name = window.className
                if name.contains("MenuBarExtra") || name.contains("StatusItemPopover") {
                    if window.isVisible {
                        window.orderOut(nil)
                    } else {
                        window.makeKeyAndOrderFront(nil)
                        NSApp.activate(ignoringOtherApps: true)
                    }
                    return
                }
            }

            // Last resort: click the status item via CGEvent
            for window in NSApp.windows where window.className.contains("NSStatusBar") {
                let frame = window.frame
                guard let screen = NSScreen.main else { return }
                let clickPoint = CGPoint(x: frame.midX, y: screen.frame.height - frame.midY)

                let down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,
                                   mouseCursorPosition: clickPoint, mouseButton: .left)
                let up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp,
                                 mouseCursorPosition: clickPoint, mouseButton: .left)
                down?.post(tap: .cghidEventTap)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    up?.post(tap: .cghidEventTap)
                }
                return
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        HotkeyManager.shared.register()
    }
}
