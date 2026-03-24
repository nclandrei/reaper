import Foundation

enum MenuBarStyle: String, CaseIterable, Identifiable {
    case pillBar = "Pill Bar"
    case segments = "Segments"
    case thinLine = "Thin Line"
    case ringGauge = "Ring Gauge"
    case battery = "Battery"
    case dots = "Dots"
    case miniBars = "Mini Bars"
    case dualStack = "Dual Stack"
    case textOnly = "Text Only"

    var id: String { rawValue }

    static var defaultForCPU: MenuBarStyle { .ringGauge }
    static var defaultForMemory: MenuBarStyle { .pillBar }
}
